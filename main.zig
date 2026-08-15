const std = @import("std");
const mman = @import("bindings/sys/mman.zig");

const assert = std.debug.assert;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    _ = init;

    const coro_stack = try create_coroutine_stack(2);
    defer destroy_coroutine_stack(coro_stack);
    print(
        "mmap created a stack at [{p} to {p}] ({d} KiB)\n",
        .{coro_stack.base, coro_stack.top, @divTrunc(@intFromPtr(coro_stack.top) - @intFromPtr(coro_stack.base), 1024)}
    );

    const coro = init_coroutine(coro_stack, example);
    print(
        "Coroutine created, in suspended state, sp={p}\n",
        .{coro.sp},
    );

    // ctx_switch's first move is `movq %rsp, (%rdi)`, so passing the
    // coroutine's own reserved top-of-stack slot as `old_sp` deposits the
    // scheduler's resume-sp directly into the coroutine's stack memory --
    // no global/TLS storage required. coro_exit reads it back out when the
    // coroutine function returns.
    ctx_switch(@ptrCast(@alignCast(coro.stack.top)), coro.sp);

    print("Coroutine returned control to scheduler, example_result={d}\n", .{example_result});
}

// Note: deliberately not calling std.debug.print (or anything that touches
// std.Io's stderr locking / terminal detection) from inside the coroutine
// itself. That path appears to rely on being reached through a normal,
// unwind-info-bearing call chain -- even a plain indirect `callq` into it
// from hand-written asm (nothing to do with coroutines/stacks) reliably
// crashes deep inside std.Io.Threaded's ANSI-detection code. That's a
// pre-existing hazard of this Zig std revision, orthogonal to the
// coroutine stack-switching mechanism being exercised here, so we just
// avoid it inside the coroutine body and report results via plain memory
// instead, printing from the normal stack once control returns.
var example_result: u64 = 0;

fn example() void {
    var sum: u64 = 0;
    var i: u64 = 0;
    while (i < 1000) : (i += 1) {
        sum +%= helper(i);
    }
    example_result = sum;
}

fn helper(x: u64) u64 {
    var buf: [64]u8 = undefined;
    @memset(&buf, @truncate(x));
    return buf[0] +% x;
}

const Coroutine = struct {
    stack: Stack,
    sp: *anyopaque,
};

const Stack = struct {
    top: *anyopaque,
    base: *anyopaque,
    size: usize,
};

pub fn init_coroutine(stack: Stack, f: *const fn() void) Coroutine {
    // stack.top's first 8 bytes are reserved for the resume-sp slot (see
    // create_coroutine_stack); the fake register frame sits below that.
    const ptr = @as([*]u64, @ptrCast(@alignCast(stack.top))) - 8;
    ptr[7] = 0;                        // Fake return address, backtrace stopper.
    ptr[6] = @intFromPtr(&trampoline); // ctx_switch()'s `ret` pops this into the instruction pointer %rip
    ptr[5] = 0;                        // Becomes %rbp
    ptr[4] = 0;                        // Becomes %rbx
    ptr[3] = 0;                        // Becomes %r12
    ptr[2] = @intFromPtr(f);           // Becomes %r13
    ptr[1] = 0;                        // Becomes %r14
    ptr[0] = 0;                        // Becomes %r15

    return .{
        .stack = stack,
        .sp = @ptrCast(ptr),
    };
}

comptime {
    asm (
        \\.global ctx_switch
        \\ctx_switch:
        \\  pushq %rbp
        \\  pushq %rbx
        \\  pushq %r12
        \\  pushq %r13
        \\  pushq %r14
        \\  pushq %r15
        \\  movq %rsp, (%rdi) # *old_sp = %rsp
        \\  movq %rsi, %rsp   # %rsp = new_sp
        \\  popq %r15
        \\  popq %r14
        \\  popq %r13
        \\  popq %r12
        \\  popq %rbx
        \\  popq %rbp
        \\  ret # into whatever called ctx_switch on new_sp's stack
    );
}
extern fn ctx_switch(old_sp: **anyopaque, new_sp: *anyopaque) void;

comptime {
    asm (
        \\.global trampoline
        \\trampoline:
        \\  pushq %rbp      # re-align %rsp to 16 before the call
        \\  movq %r12, %rdi
        \\  callq *%r13
        \\  jmp coro_exit   # never `ret` out of a coroutine stack
    );
}
extern fn trampoline() void;

// Reached when a coroutine function returns instead of yielding. There is
// no valid caller frame left on this stack to `ret` into, so we
// ctx_switch back to whoever resumed us instead.
//
// By the time we get here, %rsp is always exactly `stack.top - 16`:
// ctx_switch's own `ret` lands at trampoline with %rsp = stack.top - 8,
// trampoline's `pushq %rbp` makes it stack.top - 16, and a
// SysV-ABI-compliant callee (the coroutine fn) returns with %rsp restored
// to its value at the call site. So `16(%rsp)` is always stack.top: the
// resume-sp slot written by ctx_switch when we were resumed. (If
// trampoline's prologue ever changes, this offset must change with it.)
comptime {
    asm (
        \\.global coro_exit
        \\coro_exit:
        \\  movq %rsp, %rdi     # old_sp write target: dead stack memory, discarded
        \\  movq 16(%rsp), %rsi # new_sp: resume-sp slot at stack.top
        \\  jmp ctx_switch
    );
}
extern fn coro_exit() void;

// `requested_pages` is the number of *usable* stack pages the caller
// gets; it says nothing about guard pages, which are an implementation
// detail added on top and kept invisible to the caller. One additional
// guard page is always mapped directly below the usable region and left
// PROT_NONE, so a coroutine that overflows its stack faults immediately
// instead of silently corrupting whatever memory happens to sit below it.
pub fn create_coroutine_stack(requested_pages: u8) !Stack {
    if (requested_pages == 0) return error.ZeroPageStackRequested;

    const page_size_bytes: usize = 4096;
    const usable_bytes = page_size_bytes * @as(usize, requested_pages);
    const guard_bytes = page_size_bytes;
    const total_bytes = guard_bytes + usable_bytes;

    const ptr = mman.mmap(
        null,
        total_bytes,
        mman.PROT_READ | mman.PROT_WRITE,
        mman.MAP_STACK,
        -1,
        0,
    );

    const p = ptr orelse return error.NullMmapResponse;

    // mmap'd anonymous pages are zero-filled by the kernel already; assert
    // that invariant instead of paying for a redundant memset.
    const usable: [*]u8 = @ptrCast(@as([*]u8, @ptrCast(p)) + guard_bytes);
    for (usable[0..usable_bytes]) |byte| assert(byte == 0);

    if (mman.mprotect(p, guard_bytes, mman.PROT_NONE) != 0) {
        print("mprotect returned errno = {d}\n", .{errno()});
        std.process.exit(1);
    }

    // Reserve 16 bytes (one aligned unit) at the very top for the
    // resume-sp slot: the address a resumer's ctx_switch writes its own
    // sp into, and coro_exit reads back to switch back out.
    const top_unaligned = @intFromPtr(p) + total_bytes - 16;
    return .{
        .top = @ptrFromInt(top_unaligned - (top_unaligned % 16)),
        .base = p,
        .size = total_bytes,
    };
}

pub fn destroy_coroutine_stack(stack: Stack) void {
    const ret = mman.munmap(stack.base, stack.size);
    if (ret != 0) {
        print("munmap returned errno = {d}\n", .{errno()});
        std.process.exit(1);
    }
}

fn errno() i32 {
    return @intCast(std.c._errno().*);
}

const testing = std.testing;

test "create_coroutine_stack: zero pages is rejected" {
    try testing.expectError(error.ZeroPageStackRequested, create_coroutine_stack(0));
}

test "create_coroutine_stack: usable-page contract and alignment" {
    const page_size_bytes: usize = 4096;
    const requested_pages: u8 = 2;

    const stack = try create_coroutine_stack(requested_pages);
    defer destroy_coroutine_stack(stack);

    // stack.size includes the guard page the caller never asked for.
    try testing.expectEqual(
        page_size_bytes * (1 + @as(usize, requested_pages)),
        stack.size,
    );

    // stack.top is used directly as an initial %rsp, so it must be
    // 16-byte aligned, and it sits 16 bytes below the mapping end to
    // leave room for the resume-sp slot.
    const mapping_end = @intFromPtr(stack.base) + stack.size;
    try testing.expectEqual(mapping_end - 16, @intFromPtr(stack.top));
    try testing.expectEqual(@as(usize, 0), @intFromPtr(stack.top) % 16);

    try testing.expect(@intFromPtr(stack.top) >= @intFromPtr(stack.base) + page_size_bytes);
}

test "create_coroutine_stack: 1-page stack does not panic (regression)" {
    // The guard-page bookkeeping used to underflow for small page counts
    // and panic; 1 page is now the smallest legal request.
    const stack = try create_coroutine_stack(1);
    defer destroy_coroutine_stack(stack);
    try testing.expect(@intFromPtr(stack.top) > @intFromPtr(stack.base));
}

test "create_coroutine_stack: usable region is zeroed" {
    const stack = try create_coroutine_stack(2);
    defer destroy_coroutine_stack(stack);

    const usable_start: [*]const u8 = @ptrFromInt(@intFromPtr(stack.base) + 4096);
    const usable_len = stack.size - 4096;
    for (usable_start[0..usable_len]) |byte| {
        try testing.expectEqual(@as(u8, 0), byte);
    }
}

test "create_coroutine_stack: guard page faults on access" {
    // A SIGSEGV would take the whole test binary down, so fork a child to
    // touch the guard page (stack.base) and confirm it dies by signal.
    const stack = try create_coroutine_stack(1);
    defer destroy_coroutine_stack(stack);

    const child = std.c.fork();
    if (child == 0) {
        // Zig's SIGSEGV handler would otherwise dump a backtrace to the
        // shared test output; the real assertion is the waitpid below.
        _ = std.c.close(2);
        const guard_byte: *volatile u8 = @ptrCast(stack.base);
        guard_byte.* = 1; // must fault; never returns
        std.c._exit(1); // only reached if the guard page failed to fault
    }
    try testing.expect(child > 0);

    var status: c_int = 0;
    _ = std.c.waitpid(child, &status, 0);

    // FreeBSD/POSIX WIFSIGNALED(status): low 7 bits are the signal number
    // and are nonzero (0x7f is reserved for stopped processes) when the
    // child was terminated by a signal rather than exiting normally.
    const low7 = status & 0x7f;
    const signaled = low7 != 0 and low7 != 0x7f;
    try testing.expect(signaled);
}

fn test_noop_fn() void {}

test "init_coroutine: fake register frame is laid out as ctx_switch expects" {
    const stack = try create_coroutine_stack(2);
    defer destroy_coroutine_stack(stack);

    const coro = init_coroutine(stack, test_noop_fn);

    try testing.expectEqual(@intFromPtr(stack.top) - 64, @intFromPtr(coro.sp));

    const words: [*]const u64 = @ptrCast(@alignCast(coro.sp));
    try testing.expectEqual(@as(u64, 0), words[7]); // fake return address
    try testing.expectEqual(@intFromPtr(&trampoline), words[6]); // trampoline
    try testing.expectEqual(@as(u64, 0), words[5]); // %rbp
    try testing.expectEqual(@as(u64, 0), words[4]); // %rbx
    try testing.expectEqual(@as(u64, 0), words[3]); // %r12 (fn arg)
    try testing.expectEqual(@intFromPtr(&test_noop_fn), words[2]); // %r13 (fn)
    try testing.expectEqual(@as(u64, 0), words[1]); // %r14
    try testing.expectEqual(@as(u64, 0), words[0]); // %r15

    try testing.expectEqual(@intFromPtr(stack.base), @intFromPtr(coro.stack.base));
    try testing.expectEqual(stack.size, coro.stack.size);
}

var test_ran_flag: bool = false;

fn test_sets_flag() void {
    test_ran_flag = true;
}

fn resume_coroutine(coro: Coroutine) void {
    ctx_switch(@ptrCast(@alignCast(coro.stack.top)), coro.sp);
}

test "coroutine round trip: function body executes and returns control" {
    test_ran_flag = false;

    const stack = try create_coroutine_stack(2);
    defer destroy_coroutine_stack(stack);
    const coro = init_coroutine(stack, test_sets_flag);

    resume_coroutine(coro);

    // If coro_exit's return path were broken, we would never reach this
    // line at all (segfault) rather than observe a wrong value.
    try testing.expect(test_ran_flag);
}

var test_sum_result: u64 = 0;

fn test_computes_sum() void {
    var sum: u64 = 0;
    var i: u64 = 0;
    while (i < 100) : (i += 1) {
        var buf: [32]u8 = undefined;
        @memset(&buf, @truncate(i));
        sum +%= buf[0] +% i;
    }
    test_sum_result = sum;
}

test "coroutine round trip: coroutine can use its own stack and report results" {
    test_sum_result = 0;

    const stack = try create_coroutine_stack(2);
    defer destroy_coroutine_stack(stack);
    const coro = init_coroutine(stack, test_computes_sum);

    resume_coroutine(coro);

    var expected: u64 = 0;
    var i: u64 = 0;
    while (i < 100) : (i += 1) {
        expected +%= i +% i;
    }
    try testing.expectEqual(expected, test_sum_result);
}

var test_a_ran: bool = false;
var test_b_ran: bool = false;

fn test_a_body() void {
    test_a_ran = true;
}

fn test_b_body() void {
    test_b_ran = true;
}

test "coroutine round trip: multiple independent coroutines run sequentially" {
    test_a_ran = false;
    test_b_ran = false;

    const stack_a = try create_coroutine_stack(2);
    defer destroy_coroutine_stack(stack_a);
    const stack_b = try create_coroutine_stack(2);
    defer destroy_coroutine_stack(stack_b);

    const coro_a = init_coroutine(stack_a, test_a_body);
    const coro_b = init_coroutine(stack_b, test_b_body);

    resume_coroutine(coro_a);
    try testing.expect(test_a_ran);
    try testing.expect(!test_b_ran);

    // Sanity check the scheduler-side stack/registers are intact between
    // switches -- ordinary computation here shouldn't be disturbed by
    // whatever ctx_switch/coro_exit did to get back to us.
    var scratch: u64 = 0;
    for (0..10) |i| scratch +%= i;
    try testing.expectEqual(@as(u64, 45), scratch);

    resume_coroutine(coro_b);
    try testing.expect(test_a_ran);
    try testing.expect(test_b_ran);
}
