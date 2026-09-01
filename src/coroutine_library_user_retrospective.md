# Coroutine library user retrospective

## Summary

I built `pipeline_demo.zig`, a bounded producer/worker/consumer pipeline. The producer creates 18 jobs, three worker
coroutines transform them, and a consumer drains the results. The job and result queues have capacity four, so the
coroutines must yield both for cooperative scheduling and for backpressure.

The application runs successfully with the low-level coroutine primitive, but I stopped before turning it into a real
library-driven application. The intended `Runtime` is not currently a usable public API, and the low-level API does not
provide a composable way to attach per-coroutine state. Implementing a second runtime inside the example would hide
those issues rather than exercise the library as a user would.

## What the example uses

`pipeline_demo.zig` currently uses:

- `Coroutine.init` with a selected stack size;
- `Coroutine.enter` to resume a coroutine;
- `Coroutine.yield` to return to the scheduler;
- `stack.header().status` to decide whether a coroutine yielded or completed;
- `Stack.destroy` after the scheduler has regained control and all coroutines have completed.

Because entry points are `fn() void`, the example keeps an `active_app` global and has the scheduler set
`App.current` immediately before entering a coroutine. That is enough for this one-thread experiment, but it is the
main point of friction: the example is forced to build its own context-passing convention around global mutable state.

The example's output is deterministic at the scheduler level and completes with 75 scheduler turns and 54 pipeline
events. All three workers participate, although the distribution is intentionally not balanced (`{ 13, 3, 2 }`), which
also shows that FIFO fairness applies to coroutine turns, not to work distribution. The result order is the order in
which workers finish, rather than input order.

## Verification

These commands succeeded on the current FreeBSD x86-64 environment:

```text
zig test Coroutine.zig
# 9 tests passed

zig run pipeline_demo.zig
# pipeline completed: 18 items, 75 scheduler turns, 54 events

zig run -O ReleaseFast pipeline_demo.zig
# completed with the same result
```

`zig test Runtime.zig` also reports six passing tests, but those tests cover the private intrusive list and stack tests,
not a running runtime. Zig's lazy analysis means the unused `Runtime.step` body does not have to be instantiated by that
test command.

## Blocking issues

### 1. There is no usable runtime surface

`Runtime.zig` has `spawn`, `run`, and `step` declarations, but they are private. `spawn` and `run` are stubs, and the
only state currently present on `Runtime` is a private ready queue. There is no `Runtime.init`, `Runtime.deinit`, or
public way to submit a coroutine.

More importantly, `step` still contains:

```zig
.waiting => rt.wait_queue.append_back(stack),
```

The `wait_queue` field was removed. I forced `step` to instantiate in a temporary copy and Zig reported `no field named
'wait_queue'`. The existing `zig test Runtime.zig` does not catch this because no test calls `step`. A compile-time
usage test or a real public `Runtime.run` call should make this kind of stale implementation impossible to miss.

As a result, a library user cannot use the runtime as the scheduler. The example has to duplicate the ready queue,
current-task bookkeeping, dispatch loop, invalid-state checks, and completion accounting.

### 2. Coroutine entry functions cannot receive user context

The only accepted entry signature is `*const fn() void`. There is no argument, result, error return, closure, or handle
associated with the user function. The x86-64 trampoline already has a register path that moves `%r12` into `%rdi`, but
`Coroutine.init` does not expose or initialize that context value.

For this example, every worker calls `currentTask()` through a global application pointer. This prevents ordinary
composable functions such as `worker(context: *WorkerState)`, makes multiple independent runtimes awkward, and makes
reentrancy or concurrent runtime instances unsafe. A typed `spawn` wrapper or an explicitly documented `*anyopaque`
context passed through the existing trampoline would remove most of this friction.

### 3. Resource ownership is manual and unclear

`Coroutine.init` allocates a stack directly with `Stack.create`; it does not take a pool or allocator. There is no
coroutine release/deinit operation. The example must reach into `task.coroutine.stack.destroy()` itself, and must know
that it is safe only after control has returned to the external scheduler stack.

That is manageable for a fixed example, but it is not a safe application boundary. A failed spawn after several
successful spawns, runtime shutdown with yielded coroutines, and abandoned handles all need an ownership story. The
runtime should own live coroutine records and release completed stacks only after switching back to its stable scheduler
context.

The current stack implementation maps a max-sized 2 MiB virtual region even when the usable stack option is 16 KiB.
That can be a good virtual-memory optimization, but it makes pool ownership and accounting especially important. The
pool work described in `plan.md` should happen before building higher-level APIs: every mapping failure, reuse, wipe,
release, and shutdown path needs one consistent mapping length and all header metadata must be reset.

### 4. Lifecycle state is not a scheduler contract yet

The low-level status enum has `created`, `running`, `yielded`, `waiting`, and `completed`. The design documents a
`ready` state, but the implementation uses `yielded`; `waiting` has no request data or queue owner. `Coroutine.enter` is
also public and returns `void`, so a scheduler has to inspect the hidden stack header after every entry.

The example can handle only `yielded` and `completed`. It deliberately panics if a future wait state appears. There is
no public operation for sleep, readable/writable waits, cancellation, or completion/result inspection. Invalid
operations are mostly debug assertions; in optimized builds those assertions do not form a useful error API.

The low-level `enter2(Stack)` operation further exposes a stack descriptor as an alternative to the `Coroutine` object.
This makes it unclear which abstraction owns a coroutine and which operations are intended for an application versus the
backend/runtime implementation.

### 5. There is no external-event capability

The pipeline has no timers or I/O. Empty queues are handled by repeatedly yielding, which is acceptable for this
closed exercise but would become a busy loop in an application with no ready work. There is no timer request protocol,
monotonic clock abstraction, reactor interface, or readiness wait operation.

This is a fundamental limitation for the stated high-concurrency use case: the context switch works, but the library
cannot currently suspend a coroutine on an external event while allowing the runtime to do useful work.

### 6. Package and testing boundaries are missing

There is no root package/build entry point in the repository. The example imports `Coroutine.zig` by
implementation-relative path and therefore depends on the source directory layout. Backend details, stack headers, and
raw stack descriptors are also directly reachable from application code.

The current tests validate the context switch and stack mapping well enough for this experiment, but they do not
validate a public runtime path, runtime cleanup, a failed spawn, or optimized runtime usage. The lazy compilation
behavior seen with `Runtime.step` makes an explicit package-level smoke test particularly important.

## Recommended next steps

1. **Create a package boundary and smoke test.** Add a root module/build entry point and one test that imports and calls
   the intended public runtime API. Keep `Stack`, `StackHeader`, and architecture entry points private to the package.

2. **Finish ownership before adding events.** Implement one pool per runtime, explicit runtime ownership of live
   coroutine records, and a release path that can reclaim a completed stack. Track active versus cached mappings, clean
   up partial `mmap`/`mprotect` failures, define double-release behavior, and reset every reused header field.

3. **Define a useful spawn contract.** A minimal next API could be conceptually similar to
   `Runtime.spawn(entry, context, options)`, where the context is typed by a generic wrapper or is an explicitly managed
   `*anyopaque`. Give the caller a stable handle, but do not make the handle a movable pointer into an expanding array.

4. **Implement the ready-only runtime as the single source of scheduling policy.** It should own a pool, live registry,
   FIFO ready queue, current coroutine, and stable scheduler context. `spawn`, `run`, and `deinit` should be public.
   After each switch it should inspect a well-defined lifecycle state, requeue ready coroutines, and release completed
   ones. Add tests for two yielding coroutines, many short-lived coroutines, independent runtime instances, and
   reclaimed stacks.

5. **Make lifecycle operations explicit and narrow.** Rename or define the meaning of `yielded` versus `ready`, add
   distinct timer/I/O wait states and request data, and move raw `enter`/`enter2` operations behind the
   runtime/coroutine implementation. Public scheduling operations should return useful errors or have clearly documented
   preconditions rather than relying only on assertions.

6. **Add timers before I/O.** A timer heap and an injectable monotonic clock will establish the request/wake-up protocol
   without introducing a platform reactor. Once that is stable, add a separate FreeBSD `kqueue` reactor for readiness
   waits.

7. **Specify failure, cancellation, and results.** Decide how entry errors, panics, cancellation, shutdown with pending
   waits, and typed results cross a manually switched stack. These choices affect the public handle and cleanup model
   and should not be left implicit.

## Stopping point

The context-switch primitive is usable and the pipeline demonstrates cooperative interleaving, bounded queues, and
explicit completion cleanup. I stopped at the runtime boundary because the missing public scheduler and missing
context/ownership contracts are not problems an application should work around. The generated `pipeline_demo.zig` is
therefore intentionally a small direct-primitive experiment, while this report records the work needed before a normal
single-file application can use the library as a library rather than reimplementing its runtime layer.
