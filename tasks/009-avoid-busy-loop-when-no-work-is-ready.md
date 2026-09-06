# Task 009: Avoid a hot busy wait loop calling `step()` when no coroutines are ready and none can be promoted from waiting to ready.

## Summary

When the ready queue is empty, and all coroutines in the wait queue need longer to wait, the runtime should sleep. This
allows the operating system's scheduler to run other processes instead of busy looping inside the runtime's process.


## Notes

Whatever we implement should also be generic in the same way that the clock is. It's a top priority for the runtime
to support deterministic simulation testing and running without blocking the current thread. Whatever callback we use
for sleeping could simply increment the clock by the sleep time which effectively emulates the process suspending for
a certain amount of time.
