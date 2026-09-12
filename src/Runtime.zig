const std = @import("std");

const assert = std.debug.assert;

const Coroutine = @import("Coroutine.zig");
const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");
const IntrusiveStackList = @import("IntrusiveStackList.zig");
const MinHeap = @import("MinHeap.zig");

const os_tag = @import("builtin").target.os.tag;
const Platform = switch (os_tag) {
    .freebsd => @import("platform_freebsd.zig"),
    else => @compileError("Unsupported host platform: " ++ @tagName(os_tag)),
};

const Runtime = @This();

var runtime_counter: u16 = 0;

/// Each instance of the runtime is assigned a unique runtime identifier. This identifier is used to ensure that
/// objects such as registered socket listeners, which are associated with exactly one runtime, do not cross the
/// runtime boundary or leak into a different runtime. For now, coroutines are not checked for runtime ownership,
/// but they should be in debug builds.
rid: u16,
clock: TimeProvider,
sleep_provider: SleepProvider,
ready_queue: IntrusiveStackList,
wait_queue: MinHeap,

pub fn init(
    alloc: std.mem.Allocator,
    clock: TimeProvider,
    sleep_provider: SleepProvider,
) !Runtime {
    const rid = @atomicRmw(u16, &runtime_counter, .Add, 1, .monotonic);
    return .{
        .rid = rid,
        .clock = clock,
        .sleep_provider = sleep_provider,
        .ready_queue = .{},
        .wait_queue = try .init(alloc, 8_192),
    };
}

pub fn initDefault(alloc: std.mem.Allocator) !Runtime {
    return try .init(alloc, DefaultTimeProvider, DefaultSleepProvider);
}

pub fn deinit(this: *Runtime) void {
    var stack: Stack = undefined;
    while (this.wait_queue.popMin(&stack)) {
        stack.destroy();
    }
    this.wait_queue.deinit();

    while (this.ready_queue.try_pop_front(&stack)) {
        stack.destroy();
    }
}

pub const TimeProvider = struct {
    userdata: ?*anyopaque = null,
    source: *const fn(clock_ud: ?*anyopaque) std.Io.Timestamp,
};

// TODO: This needs to be wired up to the runtime and used as specified in ../tasks/009-
pub const SleepProvider = struct {
    context: ?*anyopaque = null,
    source: *const fn(context: ?*anyopaque, std.Io.Duration) error{SleepInterrupted}!void,
};

pub fn spawn(this: *Runtime, entrypoint: *const fn() void, args: anytype) !void {
    const stack = try Coroutine.create(entrypoint, args, .{});
    this.ready_queue.append_back(stack);
}

pub fn spawnWithError(this: *Runtime, entrypoint: *const fn() anyerror!void, args: anytype) !void {
    const stack = try Coroutine.createWithError(entrypoint, args, .{});
    this.ready_queue.append_back(stack);
}

pub fn run(this: *Runtime) !void {
    while (this.ready_queue.count > 0 or this.wait_queue.getCount() > 0) {
        try this.step();
    }
}


pub const TcpListener = packed struct(u64) {
    fd: std.c.fd_t,
    rid: u16,
    kind: enum{TcpIp6},
};
pub const RuntimeSocketOpts = struct {
    reuse_addr: bool = true,
    ip6_only: bool = true,
};
pub fn listenTcpIp6(rt: *Runtime, port: u16, backlog: 128, options: RuntimeSocketOpts) !TcpListener {
    const c = std.c;

    var address: c.sockaddr.in6 = .{
        .port = std.mem.nativeToBig(u16, port),
        .flowinfo = 0,
        .addr = @splat(0),
        .scope_id = 0,
    };

    const fd = c.socket(
        c.AF.INET6,
        c.SOCK.STREAM | c.SOCK.NONBLOCK | c.SOCK.CLOEXEC,
        c.IPPROTO.TCP,
    );
    if (fd < 0) {
        return error.SocketCreate;
    }

    var enabled: c_int = 1;

    var ret: c_int = 0;
    if (options.reuse_addr) {
        ret = c.setsockopt(
            fd,
            c.SOL.SOCKET,
            c.SO.REUSEADDR,
            &enabled,
            @sizeOf(c_int),
        );
        if (ret != 0) {
            return error.SocketOptions;
        }
    }

    if (options.ip6_only) {
        ret = c.setsockopt(
            fd,
            c.IPPROTO.IPV6,
            c.IPV6.V6ONLY,
            &enabled,
            @sizeOf(c_int),
        );
        if (ret != 0) {
            return error.SocketOptions;
        }
    }

    ret = c.bind(fd, @ptrCast(&address), @sizeOf(c.sockaddr.in6));
    if (ret != 0) {
        return error.SocketBind;
    }

    ret = c.listen(fd, 128);
    if (ret != 0) {
        return error.SocketListen;
    }

    return .{
        .fd = fd,
        .kind = .TcpIp6,
        .rid = rt.rid,
    };
}

fn step(this: *Runtime) !void {
    var wait_queue_now = this.now();
    if (this.wait_queue.peek()) |upcoming| {
        const until_upcoming = wait_queue_now.durationTo(upcoming);
        if (this.ready_queue.count == 0 and until_upcoming.nanoseconds > 0) {
            try this.sleep(until_upcoming.nanoseconds);
            wait_queue_now = this.now();
        }
    }

    var stack: Stack = undefined;
    while (this.wait_queue.popMinNotAfter(wait_queue_now, &stack)) {
        const header = stack.header();
        header.status = .yielded;
        header.wait_info = null;
        this.ready_queue.append_back(stack);
    }

    const queue_service_limit: usize = 32;
    for (0..@min(queue_service_limit, this.ready_queue.count)) |_| {
        if(!this.ready_queue.try_pop_front(&stack)) {
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
            .yielded => this.ready_queue.append_back(stack),
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
                        // Note: Always pull a new timestamp instead of using a shared `step()` level timestamp. Using
                        // a shared timestamp makes sense in a lot of cases, but it cannot be used for setting the
                        // sleep data for a coroutine. Doing so could cause the coroutine to wake unexpectedly early,
                        // depending on how much time was spent after the shared timestamp was taken within coroutine
                        // functions.
                        const wake_at = std.Io.Timestamp.addDuration(this.now(), std.Io.Duration.fromNanoseconds(duration));
                        try this.wait_queue.insert(wake_at, stack);
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

fn now(this: *Runtime) std.Io.Timestamp {
    return this.clock.source(this.clock.userdata);
}

fn sleep(this: *Runtime, duration_ns: i96) !void {
    try this.sleep_provider.source(
        this.sleep_provider.context,
        std.Io.Duration.fromNanoseconds(duration_ns),
    );
}

var defaultTimeProviderNanosecondsCounter: i64 = 0;
fn counterTimeProvider(notused: ?*anyopaque) std.Io.Timestamp {
    _ = notused;
    const nanosecondsCounter: *i64 = &defaultTimeProviderNanosecondsCounter;
    nanosecondsCounter.* += 1;
    return std.Io.Timestamp.fromNanoseconds(nanosecondsCounter.*);
}
pub const DefaultTimeProvider: TimeProvider = .{
    .userdata = null,
    .source = &counterTimeProvider,
};

fn counterSleepProvider(context: ?*anyopaque, duration: std.Io.Duration) error{SleepInterrupted}!void {
    _ = context;
    const nanosecondsCounter: *i64 = &defaultTimeProviderNanosecondsCounter;
    assert(duration.nanoseconds < std.math.maxInt(i64));
    nanosecondsCounter.* += @intCast(duration.nanoseconds);
}
pub const DefaultSleepProvider: SleepProvider = .{
    .context = &defaultTimeProviderNanosecondsCounter,
    .source = &counterSleepProvider,
};

fn libcSleepProvider(context: ?*anyopaque, duration: std.Io.Duration) error{SleepInterrupted}!void {
    var wait_duration: std.c.timespec = .{
        .sec = @intCast(duration.nanoseconds / std.time.ns_per_s),
        .nsec = @intCast(duration.nanoseconds % std.time.ns_per_s),
    };
    var unslept_amount: std.c.timespec = .{ .sec = 0, .nsec = 0 };
    assert(context == null);
    const ret = std.c.clock_nanosleep(
        std.c.clockid_t.MONOTONIC,
        0,
        &wait_duration,
        &unslept_amount,
    );
    if (ret != 0) {
        assert(unslept_amount.sec != 0 or unslept_amount.nsec != 0);
        return error.SleepInterrupted;
    }
}
pub const SyscallSleepProvider: SleepProvider = .{
    .context = null,
    .source = &libcSleepProvider,
};

test "Runtime.deinit() should deallocate all coroutines in the ready queue" {
    const T = struct {
        fn testCoro() void {
            Coroutine.yield();
        }
    };
    var rt: Runtime = try .initDefault(std.testing.allocator);
    try rt.spawn(T.testCoro, .{});
    try std.testing.expectEqual(1, rt.ready_queue.count);
    const stack = rt.ready_queue.head.?;
    try Stack.assertStackMapped(stack);
    rt.deinit();
    try Stack.assertStackNotMapped(stack);
}

test "Runtime.deinit() should deallocate all coroutines in the wait queue" {
    const T = struct {
        fn sleepCoro() void {
            Coroutine.sleepNanoseconds(1000);
        }
    };
    var rt: Runtime = try .initDefault(std.testing.allocator);
    try rt.spawn(T.sleepCoro, .{});
    try rt.step();
    try std.testing.expectEqual(1, rt.wait_queue.getCount());
    const stack: Stack = .{ .vm_base_address = rt.wait_queue.items[1].stack};
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
    var rt: Runtime = try .initDefault(std.testing.allocator);
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
    var rt: Runtime = try .initDefault(std.testing.allocator);
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
    var rt: Runtime = try .initDefault(std.testing.allocator);
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

test "step() should wake ready timer-waiting coroutines and run them" {
    const T = struct {
        fn testCoro() void {
            Coroutine.sleepNanoseconds(1);
        }
    };
    var rt: Runtime = try .initDefault(std.testing.allocator);
    defer rt.deinit();
    try rt.spawn(T.testCoro, .{});
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try rt.step();
    try std.testing.expectEqual(1, rt.wait_queue.getCount());
    try rt.step();
    try std.testing.expectEqual(0, rt.ready_queue.count);
    try std.testing.expectEqual(0, rt.wait_queue.getCount());
}

test "step() sleeping coroutines should be ignored until their timer expires" {
    const T = struct {
        fn sleepCoro() void {
            Coroutine.sleepNanoseconds(5);
        }
        fn activeCoro() void {
            Coroutine.yield();
            Coroutine.yield();
            Coroutine.yield();
            Coroutine.yield();
            Coroutine.yield();
        }
    };
    var rt: Runtime = try .initDefault(std.testing.allocator);
    defer rt.deinit();
    try rt.spawn(T.sleepCoro, .{});
    try rt.spawn(T.activeCoro, .{});
    try std.testing.expectEqual(2, rt.ready_queue.count);
    try rt.step();
    try std.testing.expectEqual(1, rt.wait_queue.getCount());
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try rt.step();
    try std.testing.expectEqual(1, rt.wait_queue.getCount());
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try rt.step();
    try std.testing.expectEqual(1, rt.wait_queue.getCount());
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try rt.step();
    try std.testing.expectEqual(1, rt.wait_queue.getCount());
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try rt.step();
    try std.testing.expectEqual(1, rt.wait_queue.getCount());
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try rt.step();
    try std.testing.expectEqual(0, rt.wait_queue.getCount());
    try std.testing.expectEqual(0, rt.ready_queue.count);
}

test "run() drains all coroutine queues before returning" {
    const T = struct {
        fn sleepCoro() void {
            Coroutine.sleepNanoseconds(5);
        }
        fn activeCoro() void {
            Coroutine.yield();
            Coroutine.yield();
            Coroutine.yield();
            Coroutine.yield();
            Coroutine.yield();
        }
    };
    var rt: Runtime = try .initDefault(std.testing.allocator);
    defer rt.deinit();
    try rt.spawn(T.sleepCoro, .{});
    try rt.spawn(T.activeCoro, .{});
    try rt.spawn(T.sleepCoro, .{});
    try rt.spawn(T.activeCoro, .{});
    try rt.spawn(T.sleepCoro, .{});
    try rt.spawn(T.activeCoro, .{});
    try rt.run();
    try std.testing.expectEqual(0, rt.wait_queue.getCount());
    try std.testing.expectEqual(0, rt.ready_queue.count);
}

test "run() halts execution and propagates failed coroutine errors to caller and can be resumed afterward" {
    var side_effect: bool = false;
    const T = struct {
        fn errorCoro() !void {
            return error.ErrorCoroHaltExecution;
        }
        fn deferredCoro() void {
            const side_effect_ptr = Coroutine.arg0(*bool);
            side_effect_ptr.* = true;
        }
    };
    var rt: Runtime = try .initDefault(std.testing.allocator);
    defer rt.deinit();
    try rt.spawnWithError(T.errorCoro, .{});
    try rt.spawn(T.deferredCoro, .{&side_effect});
    try std.testing.expectError(error.ErrorCoroHaltExecution, rt.run());
    try std.testing.expect(!side_effect);
    try std.testing.expectEqual(0, rt.wait_queue.getCount());
    try std.testing.expectEqual(1, rt.ready_queue.count);
    try rt.run();
    try std.testing.expect(side_effect);
    try std.testing.expectEqual(0, rt.wait_queue.getCount());
    try std.testing.expectEqual(0, rt.ready_queue.count);
}

test "step() suspends the thread to wait for for coroutines in the wait queue when ready queue is empty" {
    const sleep_time_ns = 300 * std.time.ns_per_s;
    const T = struct {
        fn sleepCoro() void {
            Coroutine.sleepNanoseconds(sleep_time_ns);
        }
    };
    var rt: Runtime = try .initDefault(std.testing.allocator);
    defer rt.deinit();
    try rt.spawn(T.sleepCoro, .{});
    try rt.step();
    try std.testing.expectEqual(1, rt.wait_queue.getCount());
    try std.testing.expectEqual(0, rt.ready_queue.count);
    try std.testing.expect(defaultTimeProviderNanosecondsCounter < 100);
    try rt.step();
    try std.testing.expectEqual(0, rt.wait_queue.getCount());
    try std.testing.expectEqual(0, rt.ready_queue.count);
    try std.testing.expect(defaultTimeProviderNanosecondsCounter >= sleep_time_ns);
}

