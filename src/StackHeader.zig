/// Contains the saved value of the stack pointer (%rsp register) from the active stack frame that caused
/// the coroutine to run. Usually, this is the call stack of a scheduler function or some kind of event loop.
/// This stack pointer is saved here so that those external functions can be resumed when the coroutine finishes
/// running or yields to wait for something to happen.
ext_sp: *anyopaque,

// Contains the stack pointer (%rsp register) of the coroutine. For coroutine instances that have not yet begin,
// this stack pointer is a special value which enables the function to be started. When the coroutine yields, and
// control flow resumes in an external stack frame, this stack pointer is the saved value from the coroutine's
// function call stack immediately before it was suspended. When whatever condition it yielded for is satisfied,
// the function will resume execution where it left off, in whatever nested stack frame under the coroutine function's
// call stack that it suspended from.
coro_sp: *anyopaque,
