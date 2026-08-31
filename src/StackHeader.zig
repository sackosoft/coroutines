pub const Status = enum (u8) {
    created,
    running,
    yielded,
    waiting,
    completed,
};

/// Contains the saved value of the stack pointer (%rsp register) from the active stack
/// frame that caused the coroutine to run. Usually, this is the call stack of a
/// scheduler function or some kind of event loop. This stack pointer is saved here so
/// that those external functions can be resumed when the coroutine finishes running or
/// yields to wait for something to happen.
/// TODO: Optional pointers have a well-defined and stable ABI in zig. We should update
/// ctx_switch to manage this field as an optional pointer type, so we can play nice
/// with zig code referencing it.
ext_sp: *anyopaque,

// Contains the stack pointer (%rsp register) of the coroutine. For coroutine instances
// that have not yet begin, this stack pointer is a special value which enables the
// function to be started. When the coroutine yields, and control flow resumes in an
// external stack frame, this stack pointer is the saved value from the coroutine's
// function call stack immediately before it was suspended. When whatever condition it
// yielded for is satisfied, the function will resume execution where it left off, in
// whatever nested stack frame under the coroutine function's call stack that it
// suspended from.
coro_sp: *anyopaque,

/// Identifies the stage of the lifecycle of the coroutine's execution. Coroutines
/// exist both before and after their execution starts and completes, and at various
/// stages mid-execution. To a single-threaded application, the coroutine should never
/// be observed with the 'running' status, but may be observed as ready or waiting,
/// indicating to a scheduler that the coroutine can be resumed or is waiting for some
/// kind of event (like IO) to complete before it can be resumed.
status: Status,

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
