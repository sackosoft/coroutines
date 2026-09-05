const std = @import("std");

const assert = std.debug.assert;

const Coroutine = @import("Coroutine.zig");
const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");
const IntrusiveStackList = @import("IntrusiveStackList.zig");

const Runtime = @This();

clock: TimeProvider,
ready_queue: IntrusiveStackList,
wait_queue: StackTimerMinHeap,

pub fn init(
    clock: TimeProvider,
) Runtime {
    return .{
        .clock = clock,
        .ready_queue = .{},
    };
}

pub fn deinit(rt: *Runtime) void {
    var stack: Stack = undefined;
    while (rt.ready_queue.try_pop_front(&stack)) {
        stack.destroy();
    }
}

const TimeProvider = struct {
    userdata: ?*anyopaque = null,
    source: *const fn(clock_ud: ?*anyopaque) std.Io.Timestamp,
};

var counter: i64 = 0;
fn counterTimeProvider(notused: ?*anyopaque) std.Io.Timestamp {
    _ = notused;
    const now = @atomicRmw(i64, &counter, .Add, 1, .monotonic);
    return std.Io.Timestamp.fromNanoseconds(now);
}
const DefaultTimeProvider: TimeProvider = .{
    .userdata = null,
    .source = &counterTimeProvider,
};

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

fn step(rt: *Runtime) !void {
    const queue_service_limit: usize = 32;
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
            .waiting => {
                assert(stack.header().wait_info != null); // A coroutine with .waiting status *must* set header.wait_info to the desired operation
                switch (stack.header().wait_info.?) {
                    .fixed_interval_delay_in_ns => |duration| {
                        // TODO: Should waits be registered with the IO Reactor (like kqueue)? I think probably yes.
                        // TODO: I think it makes sense to be able to schedule a recurring coroutine which is triggered
                        // on a stable interval. I feel like wiring that into the reactor is simpler than managing our
                        // own wait queue.
                        // TODO: When we add support for the io reactor, we should pre-allocate a batch of kevents and
                        // initialize them as we process coroutines. That way we can submit a batch of these events
                        // as a single syscall instead doing many.
                        rt.wait_queue.add(rt.now(), duration, stack);
                    }
                }
            },
            .failed => {
                // TODO: Should an error halt the runtime? Should an error be propagated upwards?
                // Or should we let the user provide an error callback handler? I'm leaning toward
                // stopping the runtime and returning the error, since we do not have very much
                // information about the function or what went wrong. In my opinion, we should strive
                // for a "perfect" execution, where errors are reserved for a fatal problem which
                // requires that we propagate the failure upward (and halt/deallocate the runtime).
                // Trying to handle errors as part of normal operation seems like it will leave open
                // the door for failures as acceptable.
                assert(stack.header().failure != null); // A coroutine with .failed status *must* set header.failure to the error that occurred.
                const err = stack.header().failure.?;
                stack.destroy();
                return err;
            },
            .completed => {
                stack.destroy();
            },
        }
    }
}

test "Runtime.deinit() should deallocate all coroutines in the ready queue" {
    const T = struct {
        fn testCoro() void {
            Coroutine.yield();
        }
    };
    var rt: Runtime = .init(DefaultTimeProvider);
    try rt.spawn(T.testCoro, .{});
    try std.testing.expectEqual(1, rt.ready_queue.count);
    const stack = rt.ready_queue.head.?;
    try Stack.assertStackMapped(stack);
    rt.deinit();
    try Stack.assertStackNotMapped(stack);
}

test "failed coroutines should stop the runtime, deallocate the failed coroutine and return the error" {
    const T = struct {
        fn testCoro() !void {
            return error.FailedCoroutinesShouldBeDeallocated;
        }
    };
    var rt: Runtime = .init(DefaultTimeProvider);
    defer rt.deinit();
    try rt.spawnWithError(T.testCoro, .{});
    try std.testing.expectEqual(1, rt.ready_queue.count);
    const stack = rt.ready_queue.head.?;
    try Stack.assertStackMapped(stack);
    try std.testing.expectError(error.FailedCoroutinesShouldBeDeallocated, rt.step());
    try std.testing.expectEqual(0, rt.ready_queue.count);
    try Stack.assertStackNotMapped(stack);
}

test "completed coroutines should be deallocated" {
    const T = struct {
        fn testCoro() void {}
    };
    var rt: Runtime = .init(DefaultTimeProvider);
    defer rt.deinit();
    try rt.spawn(T.testCoro, .{});
    try std.testing.expectEqual(1, rt.ready_queue.count);
    const stack = rt.ready_queue.head.?;
    try Stack.assertStackMapped(stack);
    try rt.step();
    try std.testing.expectEqual(0, rt.ready_queue.count);
    try Stack.assertStackNotMapped(stack);
}

test "step() should not run continuations in the same cycle" {
    const T = struct {
        fn testCoro() !void {
            Coroutine.yield();
            return error.NoContinuationsSameCycleTest;
        }
    };
    var rt: Runtime = .init(DefaultTimeProvider);
    defer rt.deinit();
    try rt.spawnWithError(T.testCoro, .{});
    try rt.step();
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try std.testing.expectEqual(null, rt.ready_queue.head.?.header().failure);
    const result = Coroutine.enter(rt.ready_queue.head.?);
    try std.testing.expectEqual(StackHeader.Status.failed, result);
    try std.testing.expectEqual(StackHeader.Status.failed, rt.ready_queue.head.?.header().status);
    try std.testing.expectEqual(error.NoContinuationsSameCycleTest, rt.ready_queue.head.?.header().failure.?);
}

