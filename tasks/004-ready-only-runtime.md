# Task 004: Implement the ready-only runtime

- **Status:** proposed
- **Priority:** first vertical slice
- **Depends on:** Tasks 001, 002, and 003
- **Coordinates with:** Task 005
- **Source:** `src/coroutine_library_user_retrospective.md`, recommended next step 4

## Summary

The library currently provides a context-switch primitive but not a usable scheduler. `Runtime.zig` has private `spawn`,
`run`, and `step` declarations; `spawn` and `run` are stubs, and `step` references a removed `wait_queue`. There is no
public `Runtime.init`, `Runtime.spawn`, `Runtime.run`, or `Runtime.deinit` path.

`pipeline_demo.zig` therefore duplicates the scheduler, including its ready queue, current-task bookkeeping, dispatch
loop, status inspection, completion count, and stack cleanup. That duplication should be replaced by the library's
runtime, not expanded in application code.

## Evidence

The example has to implement the dispatch loop itself:

```zig
while (self.completed_tasks < task_count) {
    const task = self.ready.pop() orelse
        @panic("ready queue became empty before all tasks completed");
    self.current = task;
    task.coroutine.enter();
    self.current = null;

    switch (task.coroutine.stack.header().status) {
        .created, .running => @panic("coroutine returned with an invalid status"),
        .waiting => @panic("the demo has no wait queue"),
        .yielded => self.enqueue(task),
        .completed => self.completed_tasks += 1,
    }
}
```

## Plan

1. Make `Runtime` own one pool, a stable scheduler context, a live-coroutine registry, a FIFO ready queue, and the
   currently running coroutine.
2. Implement public `Runtime.init`, `Runtime.spawn`, `Runtime.run`, and `Runtime.deinit`.
3. Ensure every entry into a coroutine originates from the runtime's stable scheduler context.
4. Have `spawn` initialize ownership and lifecycle metadata, then enqueue the new coroutine as ready.
5. Run one ready coroutine per scheduler turn. A yielded coroutine is appended for a later turn; it is never recursively
   resumed from inside `yield`.
6. Inspect the explicit lifecycle state after every switch. Do not infer completion merely because control returned.
7. Release completed stacks only after control has returned to the runtime stack, then remove them from the live
   registry.
8. Define behavior when the ready queue is empty while live coroutines are waiting or when no progress is possible.
9. Add tests for FIFO/round-robin ordering, two repeatedly yielding coroutines, many short-lived coroutines, completion
   in different orders, independent stacks, and reclaimed mappings.

## Acceptance criteria

- A normal application can schedule coroutines without implementing its own dispatch loop.
- Two or more coroutines interleave predictably using only cooperative `yield`.
- Completed stacks are reclaimed and removed from the live registry.
- No coroutine is resumed recursively from `yield`.
- Invalid state transitions are rejected through the chosen error/contract mechanism.
- The runtime test suite proves stack cleanup and independent runtime ownership.
