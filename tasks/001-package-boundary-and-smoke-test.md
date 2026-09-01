# Task 001: Establish a package boundary and smoke test

- **Status:** proposed
- **Priority:** prerequisite
- **Depends on:** none
- **Source:** `src/coroutine_library_user_retrospective.md`, recommended next step 1

## Summary

The repository has no root package/build entry point for an application to consume. A user currently imports
`Coroutine.zig` by implementation-relative path and can directly reach stack headers, stack descriptors, and
architecture code. The intended `Runtime` API is also not exercised by the existing test commands.

The current tests expose an additional hazard: Zig's lazy analysis allows an unused function body to remain unchecked.
`zig test Runtime.zig` reports passing tests even though the unfinished scheduler body references a removed field.

## Evidence

The stale implementation contains:

```zig
.waiting => rt.wait_queue.append_back(stack),
```

`wait_queue` is not a field on `Runtime`. Instantiating `step` in a temporary probe produced:

```text
Runtime_probe_tmp.zig:44:32: error: no field named 'wait_queue'
```

The unmodified test command still reports six passing tests because those tests exercise the intrusive list and stack
code, not `Runtime.step`:

```text
zig test Runtime.zig
# 6 tests passed
```

## Plan

1. Add the intended root module/build entry point and document the command used to build, run, and test applications.
2. Define the public package surface around `Runtime` and the public coroutine handle/operations.
3. Keep `Stack`, `StackHeader`, raw context-switch functions, and architecture-specific entry points internal to the
   package where possible.
4. Add a package-level smoke test that imports the public surface and calls every intended runtime lifecycle operation.
5. Make the smoke test instantiate the scheduler path, not merely import the type, so stale private bodies are analyzed.
6. Decide whether examples live under an examples directory or are built as named package targets.

## Acceptance criteria

- A new application can import the library without relying on the source directory layout.
- There is one documented build/test command for the package.
- The smoke test exercises public initialization, spawning, running, and shutdown.
- The test suite fails if a scheduler implementation references removed fields such as `wait_queue`.
- Internal stack and assembly details are not required in ordinary application source.
