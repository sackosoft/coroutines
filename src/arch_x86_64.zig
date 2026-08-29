const std = @import("std");

const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");

pub fn setupBaseStackFrame(stack: Stack, f: *const fn() void) void {
    const ptr = @as([*]u64, @ptrCast(@alignCast(stack.top()))) - 8;

    ptr[7] = 0;                        // Fake return address, backtrace stopper.
    ptr[6] = @intFromPtr(&trampoline); // ctx_switch()'s `ret` pops this into the instruction pointer %rip
    ptr[5] = 0;                        // Becomes %rbp
    ptr[4] = 0;                        // Becomes %rbx
    ptr[3] = 0;                        // Becomes %r12
    ptr[2] = @intFromPtr(f);           // Becomes %r13
    ptr[1] = 0;                        // Becomes %r14
    ptr[0] = 0;                        // Becomes %r15

    const header = stack.header();
    header.* = .{
        .caller_stack_pointer = undefined,    // caller stack pointer, will be set during first `ctx_switch` call.
        .saved_stack_pointer = @ptrCast(ptr), // saved stack pointer, now initialized with the fake base stack frame.
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
pub extern fn ctx_switch(old_sp: **anyopaque, new_sp: *anyopaque) void;

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
const _asm_coro_exit = std.fmt.comptimePrint(
    \\.global coro_exit
    \\coro_exit:
    \\  leaq 0x{x:016}(%rsp), %rax
    \\  andq $~0x{x:016}, %rax
    \\  leaq -0x{x:016}(%rax), %rax
    \\  leaq 0x{x:016}(%rax), %rdi
    \\  movq 0x{x:016}(%rax), %rsi
    \\  jmp ctx_switch
    , .{
        Stack.max_stack_size - 1,
        Stack.max_stack_size - 1,
        @sizeOf(StackHeader),
        @offsetOf(StackHeader, "saved_stack_pointer"),
        @offsetOf(StackHeader, "caller_stack_pointer"),
    },
);
comptime { asm (_asm_coro_exit); }

const _asm_locate_header = std.fmt.comptimePrint(
    \\.global locate_header
    \\locate_header:
    \\    leaq 0x{x:016}(%rsp), %rax
    \\    andq $~0x{x:016}, %rax
    \\    leaq -0x{x:016}(%rax), %rax
    \\    ret
    , .{
        Stack.max_stack_size - 1,
        Stack.max_stack_size - 1,
        @sizeOf(StackHeader),
    },
);
comptime { asm (_asm_locate_header); }
pub extern fn locate_header() *StackHeader;
