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
        \\  movq %rsp, (%rdi) # save current stack pointer
        \\  movq %rsi, %rsp # adopt the other stack
        \\  popq %r15
        \\  popq %r14
        \\  popq %r13
        \\  popq %r12
        \\  popq %rbx
        \\  popq %rbp
        \\  ret # returns into the other coroutine
    );
}
extern fn ctx_switch(old_sp: **anyopaque, new_sp: *anyopaque) void;

comptime {
    asm (
        \\.global trampoline
        \\trampoline:
        \\  pushq %rbp      # re-align %rsp to 16 before the call
        \\  movq %r12, %rdi # arg, first argument register
        \\  callq *%r13     # call fn(args)
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
