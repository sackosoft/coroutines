# Task 003: Define spawn context and stable coroutine handles

- **Status:** proposed
- **Priority:** high
- **Depends on:** Tasks 001 and 002
- **Source:** `src/coroutine_library_user_retrospective.md`, recommended next step 3

## Summary

The only entry signature is `*const fn() void`. It carries no per-coroutine argument, result, error, closure, or handle.
The x86-64 trampoline already moves `%r12` into `%rdi`, but `Coroutine.init` does not expose or initialize that context
value.

This prevents normal reusable functions from being spawned with state. The example works around it with a global
application pointer and scheduler-selected current task, which couples all instances to one global convention and makes
reentrancy difficult.

## Evidence

The example needs this global state solely because the library has no context parameter:

```zig
var active_app: *App = undefined;

fn currentTask() *Task {
    return active_app.current orelse
        @panic("coroutine ran without a scheduler current task");
}
```

The current API is conceptually:

```zig
pub fn init(f: *const fn() void, options: CoroutineOptions) !Coroutine
```

The desired direction is conceptually:

```zig
Runtime.spawn(entry, context, options)
```

## Plan

1. Decide whether the public API is a typed generic spawn wrapper, an explicitly managed `*anyopaque` context, or both.
2. Thread the context through the existing trampoline/register path without exposing architecture-specific details to
   users.
3. Define the context lifetime: it must remain valid until the coroutine completes or is cancelled.
4. Define a stable public handle that does not become invalid when a registry grows or moves. A stable record, an
   intrusive header record, or an index-plus-generation handle are possible designs.
5. Decide how an entry function returns a result or failure, even if result delivery is implemented in a later task.
6. Associate each handle with its owning runtime and reject cross-runtime or cross-thread use.
7. Add tests spawning multiple instances of the same entry function with different contexts, including two independent
   runtimes.

## Acceptance criteria

- A user can write a reusable entry function that receives its own state without a global variable.
- Multiple coroutines can use the same entry function with different contexts.
- Two runtimes can coexist without sharing current-task or context state.
- Handles remain stable for their documented lifetime and become detectably invalid after release.
- Context lifetime and ownership rules are documented and tested.
- Application code does not need to know about `%r12`, `%rdi`, or the trampoline ABI.
