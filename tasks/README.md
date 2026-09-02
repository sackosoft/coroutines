# Coroutine runtime task plan

These tasks convert the recommendations in `../src/coroutine_library_user_retrospective.md` into an ordered
implementation backlog. They intentionally separate the package boundary, ownership, spawn contract, ready-only
scheduler, lifecycle contract, timers, and terminal-state semantics.

## Recommended order

1. `001-package-boundary-and-smoke-test.md`
2. `002-runtime-ownership-and-stack-pool.md`
3. `003-spawn-context-and-stable-handles.md`
4. `004-ready-only-runtime.md`
5. `005-lifecycle-and-scheduling-contract.md`
6. `006-timers-before-io.md`
7. `007-runtime-failure-and-cancellation.md`

Task 004 is the first useful vertical slice. Tasks 003 and 005 define parts of its API and should be developed together
where necessary. Task 006 should establish the event-wait protocol before a FreeBSD `kqueue` reactor is added. Task 007
contains the terminal-state decisions that should be settled before exposing long-lived application handles.

## Shared verification goals

- Keep the low-level context-switch tests passing on supported architectures.
- Exercise every public runtime operation from a package-level test so Zig's lazy analysis cannot hide unfinished code.
- Test debug and optimized builds.
- Test stack ownership, cleanup, and reuse rather than relying only on successful coroutine output.
- Keep architecture-specific ABI details out of ordinary application code.
