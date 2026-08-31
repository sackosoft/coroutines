const Coroutine = @import("Coroutine.zig");

const Runtime = @This();

ready_queue: []Coroutine = undefined,

fn step(rt: *Runtime) void {

    if (rt.ready_queue.pop()) |coro| {
        coro.enter();
    } else {
    }
}
