────────────────────────────────────────────────────────────────────────────────

### 2. Fix pool allocation and release correctness

This should be the first substantive implementation task.

Pool.reserveInternal() always maps Stack.max_stack_size, currently 2 MiB. However, both Pool.deinit() and the
full-cache path in releaseStack() unmap only the selected usable size, such as 4 KiB or 8 KiB. A successful test does
not expose this because partial munmap calls can succeed while leaving most of the mapping behind.

Address the following:

- Store or centrally derive the actual mapping length and use it for every munmap.
- Unmap the full mapping if mprotect() fails after mmap() succeeds.
- Handle mmap() failure using MAP_FAILED as well as null; the generated binding exposes mman.MAP_FAILED.
- Replace the hard-coded 4096-byte page size with a platform-defined page-size query or abstraction.
- Decide whether Pool is owned by value or through an allocated pointer.
- Track active mappings separately from cached mappings, or make the runtime registry responsible for proving that no
active mapping remains at pool shutdown.
- Detect or define behavior for double release.
- Ensure a reused stack reinitializes all metadata, not just the two current header pointers.

The current global pool is especially problematic:

- Coroutine.init() always uses Pool.GlobalPool.
- GlobalPool.alloc is undefined.
- The current coroutine tests allocate stacks and never return them.
- There is no way to have independent pools for independent runtimes.

Refactor coroutine creation so a pool is explicitly supplied internally, for example through an internal
Coroutine.init(pool, ...) operation. The public user-facing entry point should
eventually be Runtime.spawn().

Exit criterion: repeated reserve/release cycles do not leak mappings, failed initialization cleans up correctly, and
separate pool instances operate independently.

────────────────────────────────────────────────────────────────────────────────

### 3. Freeze and test the stack ABI

Before adding lifecycle fields, explicitly lock down the internal ABI currently shared by Zig and assembly.

- Document the two existing pointer fields in StackHeader.
- Add compile-time assertions for:
- field offsets;
- header size;
- header alignment;
- stack alignment assumptions.
- Centralize or mechanically validate constants such as the 2 MiB alignment.
- Keep the first two header fields stable, or update every generated assembly offset together if they must change.
- Add backend tests for:
- first entry;
- yield/resume;
- completion;
- stack alignment;
- invalid resume;
- optimized builds.
- Make the raw context switch and architecture entry points private to the package.

The current backend is already using comptime-generated offsets, which is a good foundation. The missing part is
testing and formally treating the layout as an internal ABI.

Exit criterion: accidental changes to StackHeader or stack-frame setup fail at compile time or in backend tests.

────────────────────────────────────────────────────────────────────────────────

### 4. Add lifecycle and wait-request metadata

Extend StackHeader after the existing pointer fields with the state required by the design.

At minimum, add:

- lifecycle state:
    - created;
    - ready;
    - running;
    - waiting_for_timer;
    - waiting_for_io;
    - completed;
- wait kind and request data;
- owner/runtime association if needed;
- queue links or an equivalent queue representation;
- any generation/sequence value needed to identify stale timer or reactor registrations.


Then implement the state transitions:

- initialization → created;
- Runtime.spawn() → ready;
- scheduler selection → running;
- Coroutine.yield() → ready;
- future Coroutine.sleep() → waiting_for_timer;
- future readiness wait → waiting_for_io;
- entry function return → completed.

The completion path in coro_exit must record completed before switching back to the scheduler stack. The runtime must
not infer completion merely because enter() returned.

Also decide the representation of a public coroutine handle. If queue entries contain pointers to outer Coroutine
descriptors, those descriptors need stable storage; an expanding array must not invalidate them. Intrusive links in
the hidden header or separately allocated stable records are possible solutions.

Exit criterion: every return from a coroutine has an explicit state, all pooled header fields are initialized, and
completed coroutines cannot be resumed.

────────────────────────────────────────────────────────────────────────────────

### 5. Implement the ready-only runtime

Add src/Runtime.zig and implement the smallest useful scheduler without timers or I/O.

Runtime should own:

- one Pool;
- a live-coroutine registry;
- a FIFO ready queue;
- the currently running coroutine;
- scheduler/run state.

Implement:

- Runtime.init;
- Runtime.spawn;
- Runtime.run;
- Runtime.deinit;
- internal coroutine entry from the stable scheduler context.

The dispatch loop should be:

1. pop one coroutine from the ready queue;
2. mark it running;
3. enter it;
4. inspect its header state;
5. requeue ready coroutines;
6. reject unsupported waiting states for now;
7. release completed stacks only after control has returned to the runtime stack;
8. remove completed coroutines from the live registry.

Do not recursively resume a coroutine from inside yield(). A yielding coroutine must be appended to the ready queue
for a later scheduler turn.

Add tests for:

- two coroutines yielding repeatedly;
- predictable FIFO/round-robin ordering;
- many short-lived coroutines;
- different completion orders;
- independent stacks;
- reclaiming completed stacks;
- invalid repeated entry after completion.

Exit criterion: the first real vertical slice works: multiple coroutines interleave using only yield(), then all
stacks are reclaimed.

────────────────────────────────────────────────────────────────────────────────

### 6. Add timers

Only after the ready-only scheduler is stable:

- Choose a monotonic clock abstraction.
- Prefer an injectable/fake clock for deterministic unit tests.
- Implement a timer min-heap ordered by absolute deadline.
- Make Coroutine.sleep(duration) write a timer request and suspend.
- Have the runtime compute the deadline and insert the coroutine.
- Drain all expired timers before selecting ready work.
- When no coroutine is ready, wait until the next deadline rather than busy-spinning.
- Decide whether zero-duration sleep is equivalent to yield().
- Handle deadline overflow and simultaneous deadlines deterministically.

Test different sleep durations, equal deadlines, timer reuse, and runtime termination with pending timers.

Exit criterion: sleeping coroutines resume in deadline order without blocking other runnable coroutines.

────────────────────────────────────────────────────────────────────────────────

Later order

After timers, proceed in this order:

7. Define the reactor interface and implement the first FreeBSD backend, likely kqueue.

8. Add waitReadable() and waitWritable() using the same header request protocol.

9. Define cancellation, failure, result delivery, panic/unwind behavior, and shutdown semantics.

10. Add thread-affinity checks and tests for independent runtimes on separate threads.

11. Add examples, stress tests, stack-overflow tests, diagnostics, benchmarks, and additional architecture isolation.

I would not start with sockets, kqueue, cancellation, or a general async API yet. The immediate dependency chain is:

```text
    pool ownership and cleanup
        -> frozen stack ABI
        -> lifecycle state and completion
        -> ready queue and Runtime.run()
        -> timers
        -> I/O reactor
```

No files were modified during this review.
