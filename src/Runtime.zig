const std = @import("std");

const assert = std.debug.assert;

const Coroutine = @import("Coroutine.zig");
const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");
const IntrusiveStackList = @import("IntrusiveStackList.zig");

const Runtime = @This();

const queue_service_limit: usize = 32;

ready_queue: IntrusiveStackList = .{},

pub fn deinit(rt: *Runtime) void {
    var stack: Stack = undefined;
    while (rt.ready_queue.try_pop_front(&stack)) {
        stack.destroy();
    }
}

pub fn spawn(rt: *Runtime, entrypoint: *const fn() void, args: anytype) !void {
    const stack = try Coroutine.create(entrypoint, args, .{});
    rt.ready_queue.append_back(stack);
}

pub fn spawnWithError(rt: *Runtime, entrypoint: *const fn() anyerror!void, args: anytype) !void {
    const stack = try Coroutine.createWithError(entrypoint, args, .{});
    rt.ready_queue.append_back(stack);
}

pub fn run(rt: *Runtime) !void {
    _ = rt;
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
            .completed => {
                stack.destroy();
            },
        }
    }
}
test "Runtime.deinit() should deallocate all coroutines in the ready queue" {
    const T = struct {
        fn testCoro() !void {
            Coroutine.yield();
        }
    };

    var rt: Runtime = .{};
    try rt.spawnWithError(T.testCoro, .{});
    try std.testing.expectEqual(1, rt.ready_queue.count);
    const stack = rt.ready_queue.head.?;
    try Stack.assertStackMapped(stack);
    rt.deinit();
    try Stack.assertStackNotMapped(stack);
}

test "step() should not run continuations in the same cycle" {
    const T = struct {
        fn testCoro() !void {
            Coroutine.yield();
            return error.NoContinuationsSameCycleTest;
        }
    };
    var rt: Runtime = .{};
    defer rt.deinit();
    try rt.spawnWithError(T.testCoro, .{});
    rt.step();
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try std.testing.expectEqual(null, rt.ready_queue.head.?.header().failure);
    const result = Coroutine.enter(rt.ready_queue.head.?);
    try std.testing.expectEqual(StackHeader.Status.failed, result);
    try std.testing.expectEqual(StackHeader.Status.failed, rt.ready_queue.head.?.header().status);
    try std.testing.expectEqual(error.NoContinuationsSameCycleTest, rt.ready_queue.head.?.header().failure.?);
}

