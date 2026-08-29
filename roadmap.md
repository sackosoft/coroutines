# Coroutine Runtime Roadmap

This roadmap turns the target in `design.md` into incremental implementation milestones. Each phase should leave the project
in a testable state. The order intentionally builds the scheduler around the already-working stack-switching primitive before
adding operating-system I/O.

## Phase 0 — Establish the canonical project boundary

- Choose `Pool.zig`, `Stack.zig`, `Coroutine.zig`, and `arch_x86_64.zig` as the canonical implementation.
- Stop importing the stale `StackPool.zig` implementation from current code.
- Define a package/root module and a repeatable build and test command. Add a `build.zig` or equivalent package configuration
if that remains the intended Zig workflow.
- Decide which public declarations are exported and which stack/ABI declarations remain internal.
- Keep old experiments under an explicitly historical area or remove them once their useful tests and notes have been preserved.
- Make the current `Runtime.zig` either compile as a deliberate stub or remove it until the first scheduler slice is ready.

**Exit criteria:** a clean build/test command exists, canonical imports are unambiguous, and the existing coroutine and pool
tests run through the package boundary.

## Phase 1 — Make stack-pool ownership and cleanup correct

- Remove normal coroutine dependence on `Pool.GlobalPool`.
- Make each `Runtime` own one `Pool`, and make coroutine creation allocate from that pool.
- Define the ownership transfer for a reserved stack: pool to coroutine, coroutine to runtime, and runtime back to pool.
- Add an explicit release/deinitialization path for a coroutine after the runtime has returned to its scheduler stack.
- Track active mappings separately from cached mappings, or make the runtime registry responsible for releasing all active mappings before pool shutdown.
- Fix partial-failure paths, especially a failed `mprotect` after a successful `mmap`.
- Verify that every `munmap` uses the size actually mapped. The current implementation maps the max stack size but has unmap paths based on the usable stack size.
- Validate double release, use-after-release, pool shutdown with live coroutines, and reuse of every header field.
- Replace hard-coded system page-size assumptions with a platform-defined value where necessary.
- Document whether stack mappings may be reused after `madvise(MADV_FREE)` and what must be reinitialized.

**Exit criteria:** repeated create/run/release cycles have no mapping leaks, partial allocations are cleaned up, and separate
pool instances can be used independently.

## Phase 2 — Freeze and test the internal stack ABI

- Write down the exact `StackHeader` layout and assembly offsets.
- Preserve or deliberately update the offsets of `caller_stack_pointer` and `saved_stack_pointer`.
- Replace scattered magic values such as `0x1fffff`, `21`, `16`, and `64` with shared constants or compile-time checks where possible.
- Define the internal state and wait-request fields that will be appended to the header.
- Add compile-time or runtime layout assertions for header size, alignment, and field offsets.
- Decide how the initial entry context is represented. The existing `%r12 -> %rdi` trampoline path can carry an internal context
without exposing it to user functions.
- Add backend tests for first entry, yield/resume, completion, stack alignment, and invalid resume attempts.
- Confirm the backend's behavior for the target ABI, compiler optimization levels, and debug/release builds.
- Add a clear architecture-selection failure for unsupported targets.

**Exit criteria:** the Zig header layout and x86-64 assembly agree, and backend tests detect accidental ABI drift.

## Phase 3 — Implement the unified `Coroutine` lifecycle

- Add a lifecycle state enum to the hidden header. At minimum:
  - `created`;
  - `ready`;
  - `running`;
  - `waiting_for_timer`;
  - `waiting_for_io`;
  - `completed`.
- Add a wait-request representation: wait kind, duration/deadline data, file descriptor, readiness interest, and any operation
identifier required by the reactor.
- Add queue membership or intrusive queue links if that is the chosen representation.
- Add an internal owner/runtime association for thread-affinity and validity checks if needed.
- Make initialization establish every header field, including fields that may have stale values after pool reuse.
- Make the raw stack switch private to the coroutine implementation.
- Define `Coroutine.yield()` as `running -> ready` followed by the raw switch.
- Add a contextless `Coroutine.sleep()` that writes a timer request and switches back to the runtime.
- Add the completion transition in the trampoline or `coro_exit` before switching back to the runtime.
- Reject or safely ignore `enter()` on `created`, `completed`, cancelled, or already-running coroutines according to the chosen
API contract.

**Exit criteria:** a coroutine can explicitly report ready, timer-waiting, or completed state through its header, and the
low-level implementation no longer needs a global current-coroutine variable.

## Phase 4 — Build the scheduler without external events

- Implement `Runtime` with:
  - one owned pool;
  - a live-coroutine registry;
  - a FIFO ready queue;
  - a scheduler/current-coroutine record;
  - run and shutdown state.
- Implement `spawn` to allocate, initialize, and enqueue a coroutine.
- Enter coroutines only from the runtime's stable scheduler context.
- After each `enter()` returns, inspect the header state and dispatch it rather than assuming every return means ready.
- Implement round-robin scheduling for multiple ready coroutines.
- Ensure a yielding coroutine is appended to the queue rather than recursively resumed.
- Release completed coroutine stacks only after the scheduler has regained control.
- Define runtime termination when the live registry is empty or when no progress is possible.
- Test two and many coroutines that yield repeatedly, complete in different orders, and use independent stacks.

**Exit criteria:** multiple coroutines interleave predictably using only `yield()`, and all completed stacks are reclaimed.

## Phase 5 — Add the timer event loop

- Select a monotonic clock abstraction. Keep the event-loop logic testable with an injectable/fake clock if practical.
- Implement a min-heap or equivalent priority queue of timer-waiting coroutine headers.
- When a coroutine requests sleep, compute its deadline in the runtime and insert it into the timer queue.
- Drain all expired timers before selecting the next blocking wait.
- If ready work exists, run it without blocking in the OS reactor.
- If no ready work exists, calculate the timeout until the earliest timer.
- Handle timer cancellation, replacement, and stale queue entries safely.
- Decide whether zero-duration sleeps are equivalent to `yield()` or remain a distinct timer request.
- Test ordering, simultaneous deadlines, long sleeps, timer reuse, and runtime shutdown with pending timers.

**Exit criteria:** two coroutines can sleep for different durations and resume in deadline order without blocking the runtime thread unnecessarily.

## Phase 6 — Add an I/O reactor

- Define the reactor interface independently of the scheduler, for example:
  - register readable interest;
  - register writable interest;
  - deregister or cancel interest;
  - wait with a timeout;
  - return readiness, error, hangup, and cancellation events.
- Implement the first platform backend, likely FreeBSD `kqueue`, or select the appropriate `std.Io` integration after examining its ownership and polling model.
- Add contextless coroutine operations such as `waitReadable(fd)` and `waitWritable(fd)` that write requests into the active header.
- Register requests only after the runtime receives them from `enter()`.
- Wake the correct coroutine when a matching event arrives.
- Integrate reactor timeout calculation with the timer queue.
- Define behavior for repeated waits, simultaneous readable/writable interests, closed descriptors, error events, and descriptor
reuse.
- Ensure all descriptors used by the library are nonblocking or otherwise safe for cooperative scheduling.

**Exit criteria:** a coroutine can suspend while waiting for a nonblocking file descriptor, another coroutine can run, and
the first coroutine resumes when the reactor reports readiness.

## Phase 7 — Define errors, cancellation, results, and shutdown

- Decide whether user entry functions may return errors and how those errors are stored and observed.
- Decide whether a coroutine can return a typed result and how another public API obtains it.
- Define panic/unwind behavior across a manually switched stack.
- Add cancellation state and specify when cancellation is observed: at explicit checkpoints, during waits, or both.
- Remove cancelled coroutines from ready, timer, and reactor queues before releasing them.
- Define whether `Runtime.run()` propagates the first failure, aggregates failures, or exposes them through handles.
- Define what happens when `deinit()` is called with ready, waiting, running, or completed coroutines.
- Add join/await semantics only after the basic event loop lifecycle is stable.

**Exit criteria:** every terminal path has an ownership-safe cleanup story and users can observe completion, failure, or cancellation
without touching stack internals.

## Phase 8 — Thread ownership and scaling model

- Make the one-runtime-per-thread rule explicit in the API and documentation.
- Store or validate the owning runtime/thread identity for each coroutine.
- Reject cross-thread `enter`, `yield`, and release operations.
- Remove the global pool from normal operation and audit all other global mutable state.
- If cross-thread work submission is desired later, add an explicit message queue or scheduler handoff rather than migrating a live stack implicitly.
- Decide whether a runtime may be created and destroyed repeatedly on the same thread.
- Add tests with two independent runtimes and pools running on two threads.

**Exit criteria:** independent runtimes can execute concurrently without sharing stacks, queues, or mutable scheduler state
, and invalid cross-thread use is detected.

## Phase 9 — Package quality and verification

- Add examples demonstrating:
  - cooperative yielding;
  - timer sleeps;
  - two concurrent nonblocking I/O operations;
  - runtime shutdown and cleanup.
- Add stress tests for thousands of short-lived coroutines, stack-size classes, stack reuse, and queue churn.
- Add tests for stack overflow protection and the smallest supported stack.
- Test debug, optimized, and sanitizer configurations where stack switching permits them.
- Add diagnostics for coroutine state, owner runtime, wait reason, deadline, and descriptor without exposing raw ABI details as public API.
- Benchmark context-switch cost, stack allocation/reuse, timer scheduling, and I/O wakeups.
- Document platform support and the limitations of cooperative scheduling.
- Keep architecture-specific code isolated so another backend can be added without changing scheduler policy.

**Exit criteria:** the project has a documented public API, repeatable tests, resource and state diagnostics, and a clear
separation between portable runtime logic and platform backends.

## Suggested first implementation slice

The smallest useful vertical slice is:

1. Per-runtime `Pool` ownership and safe stack release.
2. Header lifecycle state plus completion marking.
3. A FIFO ready queue.
4. `Runtime.spawn`, `Runtime.run`, and `Coroutine.yield()`.
5. Tests with two coroutines that yield and complete.
6. A timer heap and `Coroutine.sleep()`.

Do not begin with sockets or a general `asyncio`-style API. Once this slice works, the timer request protocol will establish
the same scheduler contract that readiness-based I/O can later reuse.
