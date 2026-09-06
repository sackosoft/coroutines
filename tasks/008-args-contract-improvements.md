# Task 008: Improve the behavior for arguments tuple to `Runtime.spawn` and `Runtime.spawnWithError`

## Summary

Using comptime constants as arguments in the `args` tuple `Runtime.spawn` and `Runtime.spawnWithError` creates
some friction for users. 

## Current implementation

Here's an example of reasonable looking usage of this API:

```zig
fn example() void {}

fn createExampleCoroutine(rt: *Runtime) !void {
    try rt.spawn(example, .{42});
}
```

However, this example produces a compiler error:

> error: cannot store comptime-only type 'comptime_int' at runtime

The `.{42}` corresponds to `args: anytype` which provides no destination type whatsoever.

This requires users to be more explicit about what is being passed in, with a little bit more friction as a result.
Here is the working example code:

```zig
fn example() void {}

fn createExampleCoroutine(rt: *Runtime) !void {
    try rt.spawn(example, .{@as(usize, 42)});
}
```

## Decisions to make

* Should we use some more comptime code to inspect the arguments and use heuristics to translate them to corresponding
pointer-sized types? 
    - For example, we could check if the `comptime_int` is negative, converting it to a i64 if so before
      storing it in the args of the header.

* Should the API for passing arguments to coroutines be more concrete and strongly typed?


