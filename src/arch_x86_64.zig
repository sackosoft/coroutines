const std = @import("std");

const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");

pub fn setupBaseStackFrame(stack: Stack, f: *const fn() void) void {
    const ptr = @as([*]usize, @ptrCast(@alignCast(stack.top()))) - 8;

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

// Reached when the function of a coroutine returns instead of yielding.
// There is no valid caller frame left on this stack to `ret` into, so we
// will need to context switch back to a valid call stack, probably the
// runtime/scheduler thread which can handle deallocating the coroutine and
// resuming other ones.
//
// By the time we get here, %rsp should always be at or near the top of the
// usable stack space, with the header right above that. We could make that
// assumption and used fixed offsets into the header from here, but I'm going
// to keep things simple by not making that assumption yet and always doing
// the stack alignment roundup trick to find the stack header. Saved in that
// header is information about the calling context and we can context switch
// back into it, effectively creating a clean "return" from executing the
// coroutine.
//
// I'm not yet sure where coroutine state management lives. I can imagine
// wanting to set the coroutine's state to 'completed' here instead of trying
// to infer that fact or handle it at some other layer. Unfortunately, I think
// that means we will have state management mixed between the ABI and the library
// layers.
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
