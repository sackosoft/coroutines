# Task 005: Make lifecycle states and scheduling operations explicit

- **Status:** proposed
- **Priority:** high
- **Depends on:** Tasks 002 and 004
- **Source:** `src/coroutine_library_user_retrospective.md`, recommended next step 5

## Summary

The implementation has `created`, `running`, `yielded`, `waiting`, and `completed`, while the design describes a
`ready` state. `yielded` has no public scheduler contract beyond the caller inspecting a hidden stack header. `waiting`
carries no request, owner, deadline, descriptor, or generation information.

Raw entry operations are also public. `Coroutine.enter` returns `void`, permits the caller to inspect implementation
metadata directly, and relies primarily on assertions for invalid use. `enter2(Stack)` exposes a second low-level
ownership model. This makes it unclear which operations belong to an application and which are backend/runtime
internals.

## Evidence

The current status enum is:

```zig
pub const Status = enum (u8) {
    created,
    running,
    yielded,
    waiting,
    completed,
};
```

The example can only handle two states and must panic for the others:

```zig
switch (task.coroutine.stack.header().status) {
    .yielded => self.enqueue(task),
    .completed => self.completed_tasks += 1,
    .waiting => @panic("the demo has no wait queue"),
    .created, .running => @panic("coroutine returned with an invalid status"),
}
```

## Plan

1. Specify the state machine and terminology, especially whether `yielded` is an internal suspension event or the stable
   scheduler-visible `ready` state.
2. Add explicit timer and I/O wait states plus request storage for deadlines, descriptors, interests, owner, and
   generation or sequence values.
3. Define legal transitions and ownership for every public scheduling operation.
4. Keep raw context switching, `enter2`, stack headers, and architecture entry points behind the runtime/coroutine
   implementation boundary.
5. Provide narrow public operations such as `yield`, `sleep`, and readiness waits that record a scheduling request
   before switching back to the runtime.
6. Replace assertion-only invalid-use behavior with documented errors or explicit preconditions appropriate for debug
   and optimized builds.
7. Add compile-time layout assertions and backend tests for first entry, yield/resume, completion, invalid resume, and
   optimized builds.

## Acceptance criteria

- Every return to the runtime has one explicit, documented lifecycle state.
- A completed, running, or already-queued coroutine cannot be resumed incorrectly.
- Waiting states contain enough information for a runtime to register and later wake the coroutine.
- Ordinary application code does not inspect `StackHeader` or call raw stack entry functions.
- State transitions are tested independently of the eventual timer and reactor implementations.
