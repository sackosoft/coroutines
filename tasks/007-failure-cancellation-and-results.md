# Task 007: Specify failures, cancellation, results, and shutdown

- **Status:** proposed
- **Priority:** API contract
- **Depends on:** Tasks 003, 004, 005, and 006
- **Source:** `src/coroutine_library_user_retrospective.md`, recommended next step 7

## Summary

The current entry function is `fn() void`, so a coroutine cannot return a typed result or an error through the library.
There is no cancellation state, failure propagation policy, panic/unwind contract, join operation, or shutdown behavior
for ready and waiting coroutines.

These decisions affect handle lifetime, stack cleanup, timer/reactor deregistration, and whether a runtime can safely
report failure to its caller. They should be explicit before application code begins to depend on accidental behavior
across a manually switched stack.

## Evidence

The current creation signature has no result or failure channel:

```zig
pub fn init(f: *const fn() void, options: CoroutineOptions) !Coroutine
```

The only terminal state currently available to a scheduler is:

```zig
.completed
```

The retrospective identified the unresolved questions as entry errors, panics, cancellation, shutdown with pending
waits, and typed results crossing a manually switched stack.

## Plan

1. Decide whether entry functions may return errors, and whether `Runtime.run` returns the first error, aggregates
   failures, or exposes them through handles.
2. Define the public result model: typed result wrappers, erased result storage, join/await operations, and result
   lifetime.
3. Define cancellation state and when cancellation is observed: explicit checkpoints, waits, shutdown, or all of these.
4. Ensure cancellation removes a coroutine from ready, timer, and reactor queues before releasing its stack.
5. Decide how panics and unwinding interact with fabricated stack frames and context switching. Do not assume ordinary
   unwinding is safe until it is tested for the supported build modes.
6. Define runtime shutdown for created, ready, waiting, running, completed, failed, and cancelled coroutines.
7. Make handles report completion, failure, cancellation, and invalid-after-release states without exposing stack
   internals.
8. Add tests for successful results, entry errors, cancellation at checkpoints, cancellation during waits, panic
   behavior, pending-event cleanup, repeated joins, and shutdown.

## Acceptance criteria

- Every coroutine termination path has a defined owner and cleanup sequence.
- Applications can observe success, failure, and cancellation through the public handle/API.
- Cancellation cannot leave stale timer, descriptor, or ready-queue registrations.
- Runtime shutdown has documented behavior for every lifecycle state.
- Panic/unwind behavior is either supported and tested or explicitly rejected by the API.
- Result and error lifetimes remain valid for the documented handle lifetime.
