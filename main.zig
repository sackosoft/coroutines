const std = @import("std");
const mman = @import("bindings/sys/mman.zig");

const assert = std.debug.assert;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    _ = init;

    const stack = try create_coroutine_stack(2);
    defer destroy_coroutine_stack(stack);
    print(
        "mmap created a stack at [{p} to {p}] ({d} KiB)\n",
        .{stack.base, stack.top, @divTrunc(@intFromPtr(stack.top) - @intFromPtr(stack.base), 1024)}
    );

    const coro = init_coroutine(stack, example);
    print(
        "Coroutine created, in suspended state, sp={p}\n",
        .{coro.sp},
    );

    var old_stack_pointer: *anyopaque = undefined;
    ctx_switch(&old_stack_pointer, coro.sp);
}

fn example() void {
    print("Hello, world!\n", .{});
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
    const ptr = @as([*]u64, @ptrCast(@alignCast(stack.top))) - 8;
    ptr[7] = 0; // Fake return address, backtrace stopper.
    ptr[6] = @intFromPtr(&trampoline); // ctx_switch()'s `ret` pops this into the instruction pointer %rip
    ptr[5] = 0; // Becomes %rbp
    ptr[4] = 0; // Becomes %rbx
    ptr[3] = 0; // Becomes %r12
    ptr[2] = @intFromPtr(f); // Becomes %r13
    ptr[1] = 0; // Becomes %r14
    ptr[0] = 0; // Becomes %r15

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
        // \\callq coro_exit # must be noreturn
    );
}
extern fn trampoline() void;

pub fn create_coroutine_stack(requested_pages: u8) !Stack {
    const page_size_bytes: usize = 4096;
    const stack_size_bytes = page_size_bytes * @as(usize, @intCast(requested_pages));

    const ptr = mman.mmap(
        null,
        stack_size_bytes,
        mman.PROT_READ | mman.PROT_WRITE,
        mman.MAP_STACK,
        -1,
        0,
    );

    if (ptr) |p| {
        const top_unaligned = @intFromPtr(p) + stack_size_bytes;
        return .{
            .top = @ptrFromInt(top_unaligned - (top_unaligned % 16)),
            .base = p,
            .size = stack_size_bytes,
        };
    }

    return error.NullMmapResponse;
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
