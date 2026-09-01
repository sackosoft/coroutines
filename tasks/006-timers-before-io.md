# Task 006: Add timers before integrating I/O

- **Status:** proposed
- **Priority:** after the ready-only runtime
- **Depends on:** Tasks 004 and 005
- **Source:** `src/coroutine_library_user_retrospective.md`, recommended next step 6

## Summary

The current library can switch stacks but cannot suspend a coroutine on an external event. The pipeline handles empty
queues by repeatedly yielding. That is acceptable for a closed computation, but an event-driven application would
busy-loop when no work is ready.

There is no monotonic clock abstraction, timer request, timer heap, sleep operation, or event-loop timeout calculation.
Timers are the smallest external-event feature and should establish the request/wake-up protocol before a
platform-specific reactor is introduced.

## Evidence

The example's empty-queue behavior is a spin through cooperative turns:

```zig
const result = active_app.results.pop() orelse {
    Coroutine.yield();
    continue;
};
```

The retrospective identified the missing capabilities as:

```text
no timer request protocol, monotonic clock abstraction, reactor interface,
or readiness wait operation
```

## Plan

1. Define a monotonic clock interface and an injectable fake clock for deterministic tests.
2. Add a timer wait request to the coroutine lifecycle metadata and expose `Coroutine.sleep` through the runtime-owned
   public API.
3. Decide whether zero-duration sleep is equivalent to `yield`.
4. Have the runtime convert a sleep request into an absolute deadline and insert it into a min-heap ordered by deadline
   and a deterministic tie-breaker.
5. Drain all expired timers before selecting ready work.
6. When no coroutine is ready, calculate the duration until the earliest timer instead of busy-spinning. The eventual
   reactor should wait for that timeout.
7. Handle deadline overflow, simultaneous deadlines, timer cancellation/replacement, and stale timer registrations.
8. Test different durations, equal deadlines, timer reuse, zero-duration waits, and shutdown with pending timers.
9. After the timer contract is stable, define a reactor interface and implement FreeBSD `kqueue` readiness waits as a
   separate task.

## Acceptance criteria

- A sleeping coroutine yields without blocking other runnable coroutines.
- Coroutines resume in deadline order, with deterministic ordering for equal deadlines.
- The runtime does not spin when only future timers remain.
- Fake-clock tests do not depend on wall-clock timing.
- Pending timers are either cancelled or safely owned during runtime shutdown.
- The timer request protocol can be extended to readiness events without changing scheduler ownership rules.
