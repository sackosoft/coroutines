const std = @import("std");

const assert = std.debug.assert;

const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");

/// Used to initialize the metadata header and initial call stack frame at the top of
/// the memory region pointed to by the given `stack`. The metadata and special stack
/// frame enable the deferred execution of the given `userFunction` which will have access
/// to the given `args`. This is NOT a user-facing contract and should only be used
/// through the `Coroutine` type.
pub fn setupBaseStackFrame(
    stack: Stack,
    userFunction: *const fn() void,
    args: anytype,
) void {
    setupBaseStackFrameSignatureErased(stack, @ptrCast(userFunction), args, .returns_void);
}

/// Used to initialize the metadata header and initial call stack frame at the top of
/// the memory region pointed to by the given `stack`. The metadata and special stack
/// frame enable the deferred execution of the given `userFunction` which will have access
/// to the given `args`. This is NOT a user-facing contract and should only be used
/// through the `Coroutine` type.
pub fn setupBaseStackFrameWithError(
    stack: Stack,
    userFunction: *const fn() anyerror!void,
    args: anytype,
) void {
    setupBaseStackFrameSignatureErased(stack, @ptrCast(userFunction), args, .returns_anyerror_union_void);
}

fn setupBaseStackFrameSignatureErased(
    stack: Stack,
    f: *const anyopaque,
    args: anytype,
    call_convention: StackHeader.CallConvention,
) void {
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
        .call_convention = call_convention,
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

/// A shim between the assembly level calling ABI and the user-provided Zig function.
/// In Debug builds, by default, Zig does some call stack trickery so that it can provide
/// a error return traces (indicating the origin of an error in something akin to a stack
/// trace). See https://ziglang.org/documentation/master/#Error-Return-Traces
/// Unfortunately, when this functionality is enabled, Zig allocates a struct on the stack
/// and secretly passes a pointer to that struct in the first parameter register for
/// all nested function call sites in the generated assembly. Instead of trying to manage
/// that ABI directly with our coroutine machinery, we will instead introduce this shim,
/// which manages that Zig layer internally and exposes a simple function with a void
/// return signature.
export fn invokeEntryWithErrorHandling(userFunction: *anyopaque) void {
    const header = locate_header();

    const f: *const fn() anyerror!void = @ptrCast(@alignCast(userFunction));
    f() catch |e| {
        header.status = .failed;
        header.failure = e;
        return;
    };

    header.status = .completed;
}

export fn invokeEntry(userFunction: *anyopaque) void {
    const header = locate_header();
    const f: *const fn() void = @ptrCast(@alignCast(userFunction));
    f();
    header.status = .completed;
}

comptime {
    asm (
        \\.global ctx_switch
        \\ctx_switch:
        \\    pushq %rbp
        \\    pushq %rbx
        \\    pushq %r12
        \\    pushq %r13
        \\    pushq %r14
        \\    pushq %r15
        \\    movq %rsp, (%rdi) # *old_sp = %rsp
        \\
        \\.global ctx_restore
        \\ctx_restore:
        \\    movq (%rsi), %rsp # %rsp = new_sp
        \\    movq $0, (%rsi)   # *new_sp = NULL
        \\    popq %r15
        \\    popq %r14
        \\    popq %r13
        \\    popq %r12
        \\    popq %rbx
        \\    popq %rbp
        \\    ret # into whatever called ctx_switch on new_sp's stack
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

/// Used to "bounce" from the fake stack frame placed on the stack during coroutine
/// initialization into an active call stack executing the user-specified entrypoint
/// function for their coroutine. Since the user can specify a function which returns
/// `void` or `!void`, we save information about the signature as
/// `StackHeader.call_convention`. This is used to enter one of two shim functions
/// which are responsible for executing the entry point function. See `invokeEntry` and
/// `invokeEntryWithErrorHandling`.
extern fn trampoline() void;
const _asm_trampoline = std.fmt.comptimePrint(

    \\.global trampoline
    \\trampoline:
    \\    pushq %rbp                   # re-align %rsp to 16 before the call
    \\    callq locate_header          # %rax = &header
    \\    lea 0x{x:016}(%rax), %r8     # %r8 = &header.call_convention
    \\    cmpb $0x{x:02}, (%r8)        # (header.call_convention != .returns_void) 
    \\    jz call_conv_void            # if (^):
    \\  call_conv_anyerror_union_void:
    \\    movq %r13, %rdi
    \\    callq invokeEntryWithErrorHandling
    \\    jmp coro_exit
    \\  call_conv_void:                # else:
    \\    movq %r13, %rdi
    \\    callq invokeEntry
    \\    jmp coro_exit
    , .{
        @offsetOf(StackHeader, "call_convention"),
        @intFromEnum(StackHeader.CallConvention.returns_void),
    },
);
comptime { asm (_asm_trampoline); }

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
// Having found the header, we point %rsi at header.ext_sp and jump to ctx_restore the
// resume-only tail of ctx_switch. This is a one-way switch: we deliberately skip the save
// phase because this stack is dead. There is no frame to return into, so saving
// callee-saved registers and %rsp would only write a plausible-looking but unusable
// context into coro_sp.
//
// Header state on arrival:            Header state after the switch:
//   coro_sp = null (running)            coro_sp = null (untouched)
//   ext_sp  = caller ctx (non-null)     ext_sp  = null (set to null by ctx_restore)
//   status  = completed/failed          status  = completed/failed (untouched, set by shims)
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
// From the caller's perspective, the original ctx_switch into this coroutine simply
// returns, with status either set to completed or failed, telling it the coroutine
// finished rather than yielded. The stack may then be reused or freed; every header
// field is already in its idle/terminal state, so no cleanup is owed here.
const _asm_coro_exit = std.fmt.comptimePrint(
    \\.global coro_exit
    \\coro_exit:
    \\    callq locate_header
    \\    leaq 0x{x:016}(%rax), %rsi       # %rsi = &header.ext_sp
    \\    jmp ctx_restore
    , .{
        @offsetOf(StackHeader, "ext_sp"),
    },
);
comptime { asm (_asm_coro_exit); }

/// Used by Zig code to identify the `StackHeader` of the actively running coroutine. This
/// is achieved by exploiting how we have carefully reserved a virtual memory address range
/// with a particular alignment. Since the stack pointer floats within that adress range,
/// at any time we can round up the stack pointer to the alignment boundary, offset it by
/// the size of the header, and return that address as a pointer to the header struct.
pub extern fn locate_header() *StackHeader;
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
