// Contains a pointer to a different stack, for when the coroutine is paused or completed
// and control need to return to the calling context.
caller_stack_pointer: *anyopaque,

// Contains a pointer within the current stack, for resuming the coroutine.
saved_stack_pointer: *anyopaque,
