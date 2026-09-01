const std = @import("std");

const assert = std.debug.assert;

const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");

pub fn setupBaseStackFrame(stack: Stack, f: *const fn() void, args: anytype) void {
    const ArgsType = @TypeOf(args);
    const args_type_info = @typeInfo(ArgsType);
    if (args_type_info != .@"struct") {
        @compileError("expected tuple or struct argument, found " ++ @typeName(ArgsType));
    }

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
        .ext_sp = null,           // caller stack pointer, will be set during first `ctx_switch` call.
        .coro_sp = @ptrCast(ptr), // saved stack pointer, now initialized with the fake base stack frame.
        .status = .created,
        .next = null,
        .prev = null,
    };

    if (args.len > 0) {
        @as(*@TypeOf(args[0]), @ptrCast(&header.args[0])).* = args[0];
    }
    if (args.len > 1) { 
        @as(*@TypeOf(args[1]), @ptrCast(&header.args[1])).* = args[1];
    }
    if (args.len > 2) {
        @as(*@TypeOf(args[2]), @ptrCast(&header.args[2])).* = args[2];
    }
    if (args.len > 3) {
        @as(*@TypeOf(args[3]), @ptrCast(&header.args[3])).* = args[3];
    }
    if (args.len > 4) {
        @compileError("coroutine arguments cannot contain more than " ++ std.fmt.comptimePrint("{d}", .{StackHeader.max_allows_args}) ++ " arguments, found " ++ std.fmt.comptimePrint("{d}", .{args.len}));
    }
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
        \\
        \\.global ctx_restore
        \\ctx_restore:
        \\  movq (%rsi), %rsp # %rsp = new_sp
        \\  movq $0, (%rsi)   # *new_sp = NULL
        \\  popq %r15
        \\  popq %r14
        \\  popq %r13
        \\  popq %r12
        \\  popq %rbx
        \\  popq %rbp
        \\  ret # into whatever called ctx_switch on new_sp's stack
    );
}
/// Saves the current execution context and switches to another.
///
/// Pushes all System V callee-saved registers (rbp, rbx, r12-r15) onto the current
/// stack, stores the resulting stack pointer into `old_sp.*`, then loads the stack
/// pointer from `new_sp.*` and resumes whatever context was previously suspended there
/// (or begins a freshly initialized one).
///
/// Ownership/nullability protocol:
/// - `old_sp.*` is unconditionally overwritten with a non-null value: the suspended
///   context of the caller. Any prior value is discarded, it is expected to be null on
///   entry (a suspended coroutine being resumed has no caller context, a running
///   coroutine using ctx_switch to suspend will be saving to the header's coro_sp which
///   we null on entry).
/// - `new_sp.*` MUST be non-null on entry; this is NOT checked and a null value will
///   crash. Any prior value is discarded (a suspended coroutine being resumed will null
///   the field after restoring the value to %rsp, a running coroutine using ctx_switch to
///   suspend will be setting the header's ext_sp to null since a suspended coroutine
///   has no external caller context).
/// - `old_sp` and `new_sp` MUST NOT alias the same slot; the null store to `new_sp.*`
///   happens after the save to `old_sp.*` and would clobber it.
pub extern fn ctx_switch(old_sp: *?*anyopaque, new_sp: *?*anyopaque) void;

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

// A coroutine's entry function must not `ret` normally because the frame below it was
// fabricated during stack initialization, not by a real call. Instead, the stack is
// seeded so that when the entry function returns, it returns *here*. Reaching
// coro_exit therefore means exactly one thing: the coroutine's function has run to
// completion.
//
// There is no argument passing and no live state to consult, the stack pointer %rsp is
// the only input. Since the entry function has just returned, %rsp sits at or near the
// top of the usable stack region, with the header at the stack allocation's aligned
// upper end. We recover the header address from %rsp alone: round up to the next
// max_stack_size alignment boundary, then step back by sizeof(StackHeader). This is
// why stacks must be allocated with size == alignment == max_stack_size; the header is
// findable from any %rsp within the stack, and coro_exit depends on that.
//
// Having found the header, we:
//   1. Mark status = completed. Done *before* the switch, so the resumed caller observes
//      the final status immediately.
//   2. Point %rsi at header.ext_sp and jump to ctx_restore the resume-only tail of
//      ctx_switch. This is a one-way switch: we deliberately skip the save phase because
//      this stack is dead. There is no frame to return into, so saving callee-saved
//      registers and %rsp would only write a plausible-looking but unusable context into
//      coro_sp.
//
// Header state on arrival:            Header state after the switch:
//   coro_sp = null (running)            coro_sp = null (untouched)
//   ext_sp  = caller ctx (non-null)     ext_sp  = null (set to null by ctx_restore)
//   status  = running/active            status  = completed
//
// Invariants this relies on:
//   - ext_sp is non-null whenever a coroutine is executing: the only way onto this
//     stack is a ctx_switch that stored the caller's context there, and only coro_exit
//     or a yield consumes it. ctx_restore does not check; a null here is a bug
//     upstream and will crash on the first pop.
//   - The header (and whole stack) remain valid memory through the final null-store:
//     ctx_restore writes to ext_sp after moving off this stack, so the stack must not
//     be freed concurrently. In the current single-threaded design the owner can't
//     free until control returns to it, which is after that store by construction.
//
// From the caller's perspective, the original ctx_switch into this
// coroutine simply returns, with status == completed telling it the
// coroutine finished rather than yielded. The stack may then be reused
// or freed; every header field is already in its idle/terminal state, so
// no cleanup is owed here.
const _asm_coro_exit = std.fmt.comptimePrint(
    \\.global coro_exit
    \\coro_exit:
    \\  leaq 0x{x:016}(%rsp), %rax
    \\  andq $~0x{x:016}, %rax
    \\  leaq -0x{x:016}(%rax), %rax
    \\  leaq 0x{x:016}(%rax), %rsi       # %rsi = &header.ext_sp
    \\  movb $0x{x:02}, 0x{x:016}(%rax)  # header.status = .completed
    \\  jmp ctx_restore
    , .{
        Stack.max_stack_size - 1,
        Stack.max_stack_size - 1,
        @sizeOf(StackHeader),
        @offsetOf(StackHeader, "ext_sp"),
        @intFromEnum(StackHeader.Status.completed),
        @offsetOf(StackHeader, "status"),
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
