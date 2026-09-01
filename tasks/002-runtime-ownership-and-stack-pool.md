# Task 002: Define runtime ownership and make stack pooling safe

- **Status:** proposed
- **Priority:** prerequisite
- **Depends on:** Task 001
- **Source:** `src/coroutine_library_user_retrospective.md`, recommended next step 2

## Summary

`Coroutine.init` allocates a stack directly through `Stack.create`; it does not take a pool or allocator. There is no
coroutine release/deinit operation, so an application must reach through the abstraction and call `Stack.destroy`
directly. The runtime has no live-coroutine registry that can prove which mappings are active during shutdown.

The current stack design maps a max-sized 2 MiB virtual region even when the requested usable stack is smaller. That
can be a useful guard-region and virtual-address strategy, but it makes mapping length, active ownership, cache state,
and cleanup rules important. The repository's design notes also describe pool failure modes that need to be resolved
before a runtime owns stacks.

## Evidence

The example has to perform cleanup manually:

```zig
fn deinit(self: *App) void {
    for (&self.tasks) |*task| {
        if (!task.initialized) continue;
        std.debug.assert(task.coroutine.stack.header().status != .running);
        task.coroutine.stack.destroy();
        task.initialized = false;
    }
}
```

The example also constructs coroutines without an owning pool:

```zig
.coroutine = try Coroutine.init(entry, .{ .stack_size = .KiB_16 }),
```

## Plan

1. Choose and document ownership: one pool owned by each runtime, with a clear transfer from pool to live coroutine and
   back to the pool after completion.
2. Implement or finish the pool abstraction without reintroducing a global pool dependency.
3. Store or centrally derive the actual mapping length and use it for every `munmap` path.
4. Clean up a successful `mmap` when `mprotect` fails, and handle both `MAP_FAILED` and null mapping results.
5. Replace hard-coded page-size assumptions with the platform page-size abstraction.
6. Track active mappings separately from cached mappings, or make the runtime registry responsible for releasing every
   active mapping before pool shutdown.
7. Define double-release, release-after-shutdown, and shutdown-with-live-coroutines behavior.
8. Reinitialize every reused header field, including lifecycle, wait, owner, generation, and queue metadata.
9. Add tests for repeated reserve/release cycles, failed initialization, reuse, partial failure, and independent pools.
10. Expose only a safe release path to the runtime/application layer; do not require users to destroy a raw stack.

## Acceptance criteria

- Repeated reserve/release cycles do not leak mappings.
- A failed stack initialization releases all partially acquired resources.
- A runtime can own two independent pools without shared global state.
- Pool shutdown has defined behavior for active and cached mappings.
- Reusing a stack cannot retain state from its previous coroutine.
- A completed stack is reclaimed only after control is back on the runtime's scheduler stack.
- Tests cover double release and invalid ownership transitions.
