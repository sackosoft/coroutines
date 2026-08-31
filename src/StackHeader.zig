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
/// Note: this field is meant to be managed 100% by higher level users of the library,
/// it should NOT be interacted with by the backend architecture or assembly machinery
/// since the nullable pointer type is part of the Zig ABI which has no guaranteed
/// representation or stability.
next: ?*anyopaque = null,

/// Used by schedulers or other external runtimes to create an intrusive doubly linked
/// list of stacks, instead of allocating and managing data structures separately.
/// Note: this field is meant to be managed 100% by higher level users of the library,
/// it should NOT be interacted with by the backend architecture or assembly machinery
/// since the nullable pointer type is part of the Zig ABI which has no guaranteed
/// representation or stability.
prev: ?*anyopaque = null,
