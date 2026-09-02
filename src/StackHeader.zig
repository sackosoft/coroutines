//! This header manages all state of a coroutine and supports intrusive data structures.
//! The core machinery of the coroutine library is based on `coro_sp` and `ext_sp` which
//! track, the stack pointer register value for the stack of the coroutine, or the stack
//! of an external stack (like a scheduler or runtime), respectively.
//!
//! Context-switch state. `ext_sp` and `coro_sp` together encode the coroutine's
//! execution state; each is non-null in exactly the states listed below, and the
//! backend assembly for `ctx_switch`/`ctx_restore`/`coro_exit` is the only code that
//! may write them while the coroutine is live.
//!
//!   State      ext_sp        coro_sp       Meaning
//!   ---------  ------------  ------------  --------------------------------
//!   ready      null          non-null      Not running; can be switched into.
//!   running    non-null      null          Executing on its own stack.
//!   completed  null          null          Function returned; stack reusable.
//!
//! Transitions (all made in assembly, not by Zig code):
//!   created -> running:  ctx_switch(&coro_sp is the *target*): the caller's
//!                        %rsp is stored into ext_sp, coro_sp is loaded into
//!                        %rsp and then nulled.
//!   running -> yielded:  a yield calls ctx_switch the other way: the
//!           -> waiting:  coroutine's %rsp is stored into coro_sp, ext_sp is
//!                        loaded and nulled.
//!   running -> completed: coro_exit jumps to ctx_restore: ext_sp is loaded
//!                        and nulled, coro_sp is never written (stays null).
//!
//! Exactly one of the two fields is non-null at any instant except in the terminal
//! `completed` state.

pub const Status = enum (u8) {
    created,
    running,
    yielded,
    waiting,
    completed,
    failed,
};

pub const CallConvention = enum (u8) {
    returns_void = 0,
    returns_anyerror_union_void = 1,
};

pub const max_allows_args: comptime_int = @typeInfo(@FieldType(@This(), "args")).array.len;

/// The suspended context of whatever external code switched into this coroutine (a
/// scheduler or event-loop). Written by `ctx_switch` on entry (the caller's %rsp after
/// pushing callee-saved registers) and consumed-and-nulled by the switch that leaves
/// the coroutine, whether that's a yield or `coro_exit`.
///
/// Invariants:
/// - Non-null when the coroutine is currently executing.
/// - Null while the coroutine is in any suspended status (created, waiting, yielded,
///   completed).
/// - Must be null when switching *into* the coroutine. Assert this before resuming.
/// - The pointer targets live frames on the *caller's* stack. It must never outlive a
///   switch back to that caller. Internally, it is set to null so that no stale value
///   survives.
ext_sp: ?*anyopaque,

/// The suspended context of the coroutine itself. For a coroutine that has not yet
/// started, this is a fabricated initial context: a stack seeded so that switching
/// into it "returns" into the entry function (with `coro_exit` planted below it as the
/// return address for when the entry function itself returns). After a yield, it is
/// the coroutine's real %rsp from the moment of suspension, which may be arbitrarily
/// deep in frames nested under the entry function; ready to be resumed mid-execution.
///
/// Invariants:
/// - Non-null when the coroutine is in any suspended status (created, waiting, yielded,
///   completed).
/// - Null when the coroutine is currently executing.
/// - Points into this coroutine's own stack allocation, below the header. It is only
///   meaningful together with that allocation; if the stack is freed or reused, any copy
///   of this pointer is dead.
coro_sp: ?*anyopaque,

/// Identifies the stage of the lifecycle of the coroutine's execution. Coroutines
/// exist both before and after their execution starts and completes, and at various
/// stages mid-execution. To a single-threaded application, the coroutine should never
/// be observed with the 'running' status, but may be observed as ready or waiting,
/// indicating to a scheduler that the coroutine can be resumed or is waiting for some
/// kind of event (like IO) to complete before it can be resumed.
status: Status,

/// Used by the coroutine backend to correctly call into the coroutine's entry function.
/// Dependending on the signature of the function the user provided for the coroutine,
/// we either need some setup to safely call into an error-returning zig function
/// (`*const fn() !void`), or we can use a very simple no-setup code path to call into
/// a void-returning zig function (`*const fn() void`).
call_convention: CallConvention,

/// Contains the error returned by the coroutine's entry function. Always null before
/// and during execution, set when the coroutine's entry function returns. This field
/// always has a value when the coroutine enters the 'failed' status, and is always null
/// for any other status.
failure: ?anyerror = null,

/// Used by schedulers or other external runtimes to create an intrusive singly linked
/// list of stacks, instead of allocating and managing data structures separately.
/// Note: this field is meant to be opaque user-data owned by higher level implementations
/// like a runtime or event loop. This field shall not be touched by the coroutine
/// assembly backend or library internals.
next: ?*anyopaque = null,

/// Used by schedulers or other external runtimes to create an intrusive doubly linked
/// list of stacks, instead of allocating and managing data structures separately.
/// Note: this field is meant to be opaque user-data owned by higher level implementations
/// like a runtime or event loop. This field shall not be touched by the coroutine
/// assembly backend or library internals.
prev: ?*anyopaque = null,

/// An area of backing storage for up to four pointer-sized arguments to the coroutine,
/// available to the entrypoint function of the coroutine and all nested stack frames
/// during execution.
args: [4]usize = .{0, 0, 0, 0},
