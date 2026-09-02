# Task 007: Define runtime failure and cancellation semantics

- **Status:** proposed
- **Priority:** high — lifecycle and runtime API contract
- **Depends on:** Tasks 003, 004, 005, and 006
- **Scope:** MVP failure, cancellation, cleanup, and shutdown behavior

## Summary

The coroutine execution primitive now supports exactly two user entry-function signatures:

```zig
pub fn create(f: *const fn() void, args: anytype, options: CoroutineOptions) !Stack
pub fn createWithError(f: *const fn() anyerror!void, args: anytype, options: CoroutineOptions) !Stack
```

Both forms accept up to four pointer-sized arguments, which the coroutine can read through `arg0` through `arg3`.
The MVP does not need typed result transport or additional user-function signatures. User code can use its arguments and
error return to express the input and output contract required at this stage.

The low-level coroutine path records an entry-function error in `StackHeader.failure` and reports it with
`StackHeader.status == .failed`. The remaining work is to define how a runtime observes, dispatches, propagates, and
cleans up those failures, and how cancellation interacts with every lifecycle state.

Cancellation is cooperative. The library must not promise to interrupt a coroutine that is actively executing on its
stack, because the runtime has no preemptive stack-safety mechanism.

## Current implementation

- `StackHeader.Status` contains the terminal states `.completed` and `.failed`.
- `StackHeader.failure` stores the error returned by an error-returning entry function.
- `Coroutine.create` supports `fn() void` entries.
- `Coroutine.createWithError` supports `fn() anyerror!void` entries.
- The architecture backend uses a Zig shim to invoke error-returning functions without exposing Zig's error-return ABI to
  the assembly context-switch primitive.
- `Coroutine.enter` returns the resulting `StackHeader.Status` and rejects re-entry into `.completed` or `.failed`.
- `Runtime.zig` contains an early ready-queue implementation, but its spawn and scheduling API is not complete.
- The runtime currently treats `.failed` as an unfinished policy decision rather than a handled terminal state.
- There is no cancellation request state, cancellation API, live-coroutine registry, or shutdown protocol.
- Timer and I/O wait queues are not yet implemented, but cancellation must account for them when they are added.

## Decisions to make

### 1. Failure ownership and propagation

Distinguish errors raised while creating or scheduling a coroutine from errors returned by its entry function:

- Allocation and setup errors are ordinary errors returned by `create`, `createWithError`, or the future runtime spawn API.
- An entry-function error is a terminal result recorded in the coroutine's metadata after control returns to the runtime.
- A failed coroutine must never be re-entered, requeued as ready, or released while it is still executing.

Choose and document the MVP runtime policy for entry failures:

- whether the runtime continues scheduling other coroutines after one fails;
- whether `Runtime.run` returns the first failure, an aggregate, or only a run-level status;
- whether a stable coroutine handle exposes the failure after completion;
- whether failures are delivered through a callback, a join operation, or another explicit API.

The policy must preserve the error for as long as the documented handle or runtime observation remains valid. It must not
require application code to depend on the raw `StackHeader` layout.

### 2. Cancellation model

Define cancellation as an explicit scheduler request rather than an asynchronous interruption:

- Decide whether cancellation uses a separate `.cancelled` terminal status, a cancellation flag, or both.
- Define the public operation for requesting cancellation and its behavior when called repeatedly.
- Define when a request becomes observable for created, ready, waiting, and running coroutines.
- Decide which scheduling operations act as cancellation checkpoints.
- Define whether cancellation is reported as a distinct outcome or represented by a standard error such as
  `error.Cancelled`.
- Define the result of cancelling a coroutine that is already `.completed` or `.failed`.

A running coroutine must be allowed to continue until it reaches an agreed checkpoint or returns. Cancellation must not
free or invalidate its stack while it is executing.

### 3. Queue, wait, and registry cleanup

Every cancellation and terminal-failure path must remove the coroutine from all ownership and scheduling structures before
its stack is released:

- ready queue;
- timer queue;
- I/O reactor registrations;
- live-coroutine registry;
- intrusive queue links stored in the header.

A wakeup or readiness event that arrives after cancellation must not resume the cancelled coroutine or refer to a released
stack. Timer and reactor entries need an explicit removal, generation, or stale-event strategy before those subsystems are
considered complete.

### 4. Shutdown

Define `Runtime` shutdown for coroutines in each state:

- created;
- ready;
- running;
- waiting for a timer or I/O event;
- completed;
- failed;
- cancelled, if cancellation is represented separately.

Shutdown must request cancellation for all eligible live coroutines, deregister pending waits, drain scheduler structures,
and release stacks only after control has returned to the runtime's own stack. It must be invalid to deinitialize a runtime
while one of its coroutines is actively executing.

### 5. Public lifetime and observation contract

Define when a coroutine handle becomes invalid, how long `failure` remains observable, and who owns stack release. The public
runtime API should expose terminal outcomes without requiring callers to enter a stack directly or inspect architecture
metadata.

## Implementation and test plan

1. Add the selected failure policy to the runtime dispatch loop. Replace the current `.failed` placeholder with explicit
   propagation, retention, or cleanup behavior.
2. Add the chosen cancellation metadata and API, keeping cancellation cooperative and thread-affine.
3. Add cleanup helpers that remove a coroutine from every queue or registration before release.
4. Add runtime-owned tracking for every live coroutine so shutdown does not depend on discovering stacks indirectly.
5. Define and implement shutdown ordering for ready, waiting, failed, completed, and cancellation-requested coroutines.
6. Keep the two supported entry signatures and four-argument access path as the complete MVP function contract. Do not add
   typed result signatures or generalize the assembly ABI in this task.
7. Test successful and failing entry functions, including failure observation after `enter` returns and rejection of failed
   re-entry.
8. Test failure behavior with multiple coroutines and verify the selected continue, stop, or aggregation policy.
9. Test cancellation before first entry, while ready, while waiting, at a checkpoint, after completion, and after failure.
10. Test that cancellation and failure cannot leave stale intrusive links, timers, reactor registrations, or live handles.
11. Test runtime shutdown with coroutines in every supported state.
12. Run the context-switch and runtime tests in Debug, ReleaseSafe, and ReleaseFast configurations.

## Acceptance criteria

- The two supported entry signatures and four-argument input contract are documented as the MVP boundary.
- Entry-function failures consistently produce `.failed` with a non-null `failure` before the runtime observes the state.
- The runtime has an explicit, tested policy for reporting or retaining entry failures.
- A failed or completed coroutine cannot be resumed, requeued, or released unsafely.
- Cancellation semantics are cooperative, documented, idempotent, and tested for every lifecycle state.
- Cancellation removes all queue, wait, registry, and handle ownership before stack release.
- Late timer or I/O events cannot resume a cancelled or released coroutine.
- Runtime shutdown has a defined behavior and cleanup sequence for every lifecycle state.
- No public API or test depends on manually decoding Zig's error-return ABI or exposing typed result signatures.
- Debug and optimized builds verify the same terminal-state and ownership invariants.
