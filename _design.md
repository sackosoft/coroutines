# Coroutine Runtime Design

## Status and scope

This document describes the target design distilled from the current coroutine implementation and the tutoring discussion.
It is a design direction, not a statement that all of these pieces are implemented today.

The initial target is:

- stackful, cooperative coroutines;
- one `Runtime` and one stack `Pool` per owning operating-system thread;
- timer and readiness-based I/O waits;
- public `Runtime` and `Coroutine` APIs;
- opaque stack layout and architecture-specific ABI details;
- x86-64 as the first supported architecture, with FreeBSD system interfaces initially available.

The runtime is not intended to provide preemptive scheduling. A coroutine that performs a blocking system call or runs forever
without yielding blocks its entire owning thread.

## Terminology

- **Coroutine**: the schedulable unit of execution. It includes the user function, its saved register/stack continuation,
its lifecycle state, and its scheduler metadata. In this design, `Coroutine` also fills the conceptual role often called a task.
- **Runtime**: the scheduler and event loop that owns a collection of coroutines, chooses which one runs, processes timers
and I/O readiness, and releases coroutine resources.
- **Pool**: the allocator and cache for coroutine stack mappings. A pool is owned by one runtime and is not shared between runtimes or threads.
- **Stack**: an implementation descriptor for one virtual-memory mapping. It is not the public coroutine abstraction.
- **Stack header**: hidden metadata stored at the high end of a coroutine's stack mapping. It contains the saved execution
pointers and the coroutine's scheduler state.
- **Reactor**: the operating-system-facing component that waits for file-descriptor readiness and reports events to the runtime
. A FreeBSD `kqueue` backend is a likely first implementation; the reactor should be abstracted from the scheduler.

## Layered architecture

```text
user coroutine functions
          |
          v
  public Coroutine / Runtime API
          |
          v
  Runtime scheduler and event loop
       |              |
       v              v
  timer queue       I/O reactor
          |
          v
  Coroutine execution primitive
          |
          v
  architecture backend
          |
          v
  Stack / Pool / mmap
```

The layers are related, but their responsibilities should remain distinct:

### 1. Virtual-memory and stack-pool domain

`Pool.zig` owns allocation and reuse of stack mappings. It should:

- reserve a max-sized, suitably aligned virtual-memory region;
- enable only the requested usable stack pages;
- leave the remaining lower portion protected so downward stack overflow faults;
- cache released mappings by size;
- release mappings when the cache is full or the pool is destroyed.

`Stack.zig` describes the mapping and computes the hidden header and usable stack boundary. It should not know about scheduling policy or event sources.

The current implementation maps `max_stack_size` (2 MiB) for every stack and uses a 2 MiB alignment boundary. The selected
usable region is at the high-address end of that mapping. The stack grows toward lower addresses.

A runtime owns the lifetime of its coroutines and delegates mapping allocation and release to its pool. The pool owns cached
mapping resources, but it must not be responsible for discovering active coroutines that the runtime still owns.

### 2. Architecture and context-switch domain

`arch_x86_64.zig` is the private x86-64 backend. It owns the machine-level ABI for:

- creating an initial fake register frame;
- switching callee-saved registers and stack pointers;
- entering the user function through a trampoline;
- returning from a user function through a completion path;
- locating the current stack header from the active stack pointer.

The backend is allowed to depend on the exact `StackHeader` layout. That layout is an internal ABI owned by this project,
but it must be documented and kept synchronized between Zig and assembly.

The current frame uses the following arrangement:

- `header.caller_stack_pointer` is at header offset `0`;
- `header.saved_stack_pointer` is at header offset `8`;
- the initial fake register frame is below the header;
- the fake frame restores the user entry function into `%r13`;
- `%r12` is available as an internal context value and is moved into `%rdi` by the trampoline;
- the trampoline calls the entry function and then jumps to `coro_exit` rather than returning through a nonexistent caller frame.

Additional header fields may be appended, but reordering the two pointer fields or changing their offsets requires a corresponding
backend change. Magic constants such as the 2 MiB alignment and header offsets should eventually be centralized or mechanically checked.

### 3. Coroutine execution domain

`Coroutine` is the schedulable public abstraction. Its implementation combines:

- a stack allocation;
- the saved continuation for that stack;
- lifecycle state;
- wait-request metadata;
- any queue links or ownership information needed by the runtime.

The hidden header is the natural home for this metadata because:

- it has the same lifetime as the stack mapping;
- it can be located from inside a running coroutine without a global `current_coroutine` pointer;
- it remains stable even if a small outer `Coroutine` descriptor is moved or copied;
- the runtime can inspect it immediately after `Coroutine.enter()` returns.

The low-level operation that only switches back to the runtime should remain private. Public operations describe scheduling intent and then use that primitive:

```text
internal suspend_to_runtime:
    save the active coroutine continuation
    switch to the continuation captured by the runtime

Coroutine.yield:
    mark the active coroutine ready
    suspend_to_runtime

Coroutine.sleep(duration):
    write a timer wait request into the active header
    mark the active coroutine waiting for a timer
    suspend_to_runtime

Coroutine.waitReadable(fd):
    write a readable-wait request into the active header
    mark the active coroutine waiting for I/O
    suspend_to_runtime
```

These operations do not require users to pass a task or runtime pointer through their application call graph. They locate the active header internally. The runtime and coroutine implementation may know about one another, and the header may contain an internal owner/runtime reference for affinity checks, but that reference is not part of the user-facing function signature.

The preferred interaction is a request protocol: a coroutine writes its wait request into its header, returns to the runtime, and the runtime consumes the request by inserting the coroutine into the appropriate timer or reactor structure.

### 4. Runtime and scheduler domain

`Runtime` owns:

- one `Pool`;
- all live coroutine resources, including a registry needed for cleanup;
- the ready queue;
- the timer queue;
- the I/O reactor;
- scheduler bookkeeping and the current running coroutine;
- the thread-affinity invariant for its coroutines.

All calls to `Coroutine.enter()` should originate from the runtime's stable scheduler context. A coroutine must not be resumed by an unrelated runtime or by another operating-system thread.

After the runtime enters a coroutine, the coroutine eventually returns control by yielding or completing. The runtime then inspects the header and dispatches according to its state. It must never infer the state merely from the fact that `enter()` returned.

A typical dispatch looks like:

```text
select a coroutine from the ready queue
mark it running
enter it from the runtime scheduler context

inspect its header:
    ready:
        append it to the ready queue
    waiting_for_timer:
        insert it into the timer queue
    waiting_for_io:
        register it with the reactor
    completed:
        release its stack and remove it from the live registry
```

A coroutine stack may be released only after control has returned to the runtime's stack. A coroutine must not destroy its own active stack from inside its body or completion trampoline.

## Coroutine state machine

The minimum useful states are:

```text
created -> ready -> running
                       |
          +------------+-------------+
          |            |             |
          v            v             v
        ready    waiting_timer   waiting_io
                         |             |
                         +------+------+ 
                                |
                                v
                               ready

running -> completed
```

The intended transitions are:

| Current state | Operation | Next state | Runtime action |
| --- | --- | --- | --- |
| created | spawn completes | ready | enqueue |
| ready | scheduler selects it | running | enter it |
| running | `Coroutine.yield()` | ready | enqueue after return |
| running | `Coroutine.sleep(d)` | waiting for timer | add to timer queue |
| running | readiness wait | waiting for I/O | register with reactor |
| waiting for timer | deadline reached | ready | enqueue |
| waiting for I/O | matching event | ready | enqueue |
| running | entry function returns | completed | release after return |

Cancellation, failure, and result delivery are additional terminal or observable states that must be designed explicitly rather than overloaded onto `completed`.

### Meaning of `Coroutine.yield()`

`Coroutine.yield()` means:

> The coroutine is still runnable, but it voluntarily gives the runtime an opportunity to run other work.

It therefore performs `running -> ready`. It is useful for cooperative fairness, CPU-heavy loops, and tests, but a timer/I/O event loop can still function for tasks that only suspend on external events.

The ready queue should use a non-recursive scheduling policy. A coroutine that yields is queued for a later scheduler turn, rather than immediately calling itself recursively.

## Timer and I/O event loop

The first event-loop milestone should support timers only. A timer wait writes a duration or equivalent request into the header. The runtime computes the absolute deadline using its monotonic clock and places the coroutine in a priority queue ordered by wake time.

The general loop is:

```text
while live coroutines remain:
    move all expired timers to the ready queue

    if the ready queue is non-empty:
        run one ready coroutine
        consume its resulting header state
        continue

    timeout = time until the next timer, or no timeout if none exists
    wait in the I/O reactor for that timeout
    move resulting I/O events and expired timers to the ready queue
```

When a sleeping coroutine is resumed, its `sleep()` call returns and normal user code continues. A wait operation therefore behaves like a synchronous-looking operation on top of a nonblocking scheduler.

I/O operations must use nonblocking descriptors or an equivalent asynchronous interface. A blocking read, write, connect, or accept would block the whole runtime thread. The reactor must associate readiness registrations with hidden coroutine headers and wake the corresponding coroutine when the event arrives.

## Ownership and lifetime rules

### Runtime

- One runtime owns one pool and one scheduler domain.
- It owns every live coroutine until that coroutine completes, is cancelled, or the runtime shuts down.
- It is responsible for removing coroutines from ready, timer, and reactor structures before releasing their stacks.
- It must not be deinitialized while a coroutine is actively executing on its stack.
- A normal `run()` completion should leave no live coroutine requiring later user cleanup, unless the API explicitly chooses to return handles with that responsibility.

### Coroutine

- A coroutine owns its logical execution state, stored in its hidden header.
- Its stack mapping is managed on its behalf by the owning runtime and pool.
- It must not be resumed after completion or after its resources have been released.
- It is thread-affine to its owning runtime.
- A public handle must become invalid or clearly unusable after the runtime releases the coroutine.

### Pool

- A pool may cache released mappings, but cached mappings are not live coroutines.
- Reuse must reinitialize every header field and queue link; no timer, descriptor, state, or continuation may leak from the previous occupant.
- Pool operations are not thread-safe by default. Separate pools are the intended way to support separate runtime threads.
- The pool must account for both cached and active mappings during shutdown, either directly or through an explicit runtime-owned release protocol.

### User code

- User functions do not receive a mandatory task pointer merely to use coroutine operations.
- User code must use nonblocking operations when it wants concurrency within a runtime.
- User code may call scheduling operations only from the currently running coroutine context.

## Public API shape

The exact Zig signatures remain open, but the intended shape is:

```text
Runtime.init(...)
Runtime.spawn(entry, options)
Runtime.run()
Runtime.deinit()

Coroutine.yield()
Coroutine.sleep(duration)       // a millisecond convenience may be provided
Coroutine.waitReadable(fd)
Coroutine.waitWritable(fd)
```

`Runtime` and `Coroutine` are public library concepts. Stack descriptors, header fields, fake frames, register conventions
, and assembly entry points are implementation details.

The user entry function should not require a task pointer for ordinary use. The existing trampoline already has an internal
context-register path if a future API needs typed user context, but that context should be hidden behind `spawn` rather than
threaded through every application function.

## Current implementation versus target

Already present in the current canonical files:

- aligned virtual-memory stack allocation and reuse in `Pool.zig`;
- stack/header address calculations in `Stack.zig`;
- x86-64 context switching, trampoline, completion path, and header location;
- initial coroutine creation, entry, and suspension in `Coroutine.zig`;
- tests covering stack layout, stack reuse, first entry, and suspension/resumption.

Not yet present or incomplete:

- runtime-owned pools and removal of normal dependence on `Pool.GlobalPool`;
- coroutine lifecycle state in the header;
- completion-state recording in `coro_exit`;
- a safe coroutine release/deinitialization path;
- ready queues and a scheduler loop;
- timer queue and `Coroutine.sleep()`;
- an I/O reactor and readiness waits;
- cancellation, errors, results, and shutdown semantics;
- a stable package/build/test structure;
- cleanup of stale duplicate implementations and imports.

The current `Pool` implementation also needs resource-safety review before it is treated as a library boundary. In particular, it maps a max-sized region but some unmap paths use only the selected usable size, and error paths need to release partially initialized mappings.
