const std = @import("std");

const assert = std.debug.assert;

const Coroutine = @import("Coroutine.zig");
const Stack = @import("Stack.zig");
const IntrusiveStackList = @import("Stack.zig");

const Runtime = @This();

const queue_service_limit: usize = 32;

ready_queue: IntrusiveStackList = .{},

fn spawn(rt: *Runtime, entrypoint: *const fn() void, args: anytype) !void {
    const stack = Coroutine.create(entrypoint, args, .{});
    rt.ready_queue.append_back(stack);
}

fn step(rt: *Runtime) void {
    var stack: Stack = undefined;
    for (0..@min(queue_service_limit, rt.ready_queue.count)) |_| {
        if(!rt.ready_queue.try_pop_front(&stack)) {
            break;
        }

        const header = stack.header();
        assert(header.status != .completed);
        assert(header.status != .running);
        assert(header.status != .waiting);
        assert(header.status != .failed);

        switch (Coroutine.enter(stack)) {
            .created => unreachable,
            .running => unreachable,
            .yielded => rt.ready_queue.append_back(stack),
            .waiting => unreachable, // TODO: Interpret wait request and dispatch appropriate syscalls.
            .failed => unreachable, // TODO: Error callback? Halt the runtime?
            .completed => continue,
        }
    }
}

