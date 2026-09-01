const std = @import("std");
const Coroutine = @import("Coroutine.zig");

const item_count = 18;
const worker_count = 3;
const task_count = worker_count + 2;
const queue_capacity = 4;
const production_batch = worker_count;
const max_events = item_count * 3;

const Role = enum {
    producer,
    worker,
    consumer,
};

const Job = struct {
    sequence: usize,
    value: u32,
};

const Result = struct {
    sequence: usize,
    value: u32,
    worker_id: usize,
};

const Event = struct {
    role: Role,
    actor: usize,
    sequence: usize,
};

fn RingBuffer(comptime T: type, comptime capacity: usize) type {
    return struct {
        const Self = @This();

        items: [capacity]T = undefined,
        head: usize = 0,
        tail: usize = 0,
        length: usize = 0,

        fn push(self: *Self, item: T) bool {
            if (self.length == capacity) return false;

            self.items[self.tail] = item;
            self.tail = (self.tail + 1) % capacity;
            self.length += 1;
            return true;
        }

        fn pop(self: *Self) ?T {
            if (self.length == 0) return null;

            const item = self.items[self.head];
            self.head = (self.head + 1) % capacity;
            self.length -= 1;
            return item;
        }
    };
}

const Task = struct {
    coroutine: Coroutine = undefined,
    role: Role = .producer,
    actor: usize = 0,
    initialized: bool = false,
};

const App = struct {
    const ReadyQueue = RingBuffer(*Task, task_count);
    const JobQueue = RingBuffer(Job, queue_capacity);
    const ResultQueue = RingBuffer(Result, queue_capacity);

    tasks: [task_count]Task = undefined,
    ready: ReadyQueue = .{},
    jobs: JobQueue = .{},
    results: ResultQueue = .{},
    events: [max_events]Event = undefined,
    observed: [item_count]Result = undefined,
    event_count: usize = 0,
    source_next: usize = 0,
    source_done: bool = false,
    processed: usize = 0,
    worker_processed: [worker_count]usize = [_]usize{0} ** worker_count,
    consumed: usize = 0,
    completed_tasks: usize = 0,
    turns: usize = 0,
    current: ?*Task = null,

    fn initTask(
        self: *App,
        slot: usize,
        role: Role,
        actor: usize,
        entry: *const fn () void,
    ) !void {
        self.tasks[slot] = .{
            .coroutine = try Coroutine.init(entry, .{ .stack_size = .KiB_16 }),
            .role = role,
            .actor = actor,
            .initialized = true,
        };
        self.enqueue(&self.tasks[slot]);
    }

    fn enqueue(self: *App, task: *Task) void {
        std.debug.assert(task.coroutine.stack.header().next == null);
        std.debug.assert(task.coroutine.stack.header().prev == null);
        std.debug.assert(self.ready.push(task));
    }

    fn record(self: *App, role: Role, actor: usize, sequence: usize) void {
        std.debug.assert(self.event_count < self.events.len);
        self.events[self.event_count] = .{
            .role = role,
            .actor = actor,
            .sequence = sequence,
        };
        self.event_count += 1;
    }

    fn run(self: *App) void {
        while (self.completed_tasks < task_count) {
            const task = self.ready.pop() orelse @panic("ready queue became empty before all tasks completed");
            self.current = task;
            task.coroutine.enter();
            self.current = null;

            switch (task.coroutine.stack.header().status) {
                .created, .running => @panic("coroutine returned with an invalid status"),
                .waiting => @panic("the demo has no wait queue"),
                .yielded => self.enqueue(task),
                .completed => self.completed_tasks += 1,
            }
            self.turns += 1;
        }
    }

    fn deinit(self: *App) void {
        std.debug.assert(self.current == null);
        for (&self.tasks) |*task| {
            if (!task.initialized) continue;

            std.debug.assert(task.coroutine.stack.header().status != .running);
            task.coroutine.stack.destroy();
            task.initialized = false;
        }
    }
};

var active_app: *App = undefined;

fn currentTask() *Task {
    return active_app.current orelse @panic("coroutine ran without a scheduler current task");
}

fn producerMain() void {
    while (active_app.source_next < item_count) {
        if (active_app.jobs.length == queue_capacity) {
            Coroutine.yield();
            continue;
        }

        const sequence = active_app.source_next;
        std.debug.assert(active_app.jobs.push(.{
            .sequence = sequence,
            .value = @as(u32, @intCast(sequence + 1)),
        }));
        active_app.source_next += 1;
        active_app.record(.producer, 0, sequence);

        if (active_app.source_next % production_batch == 0) {
            Coroutine.yield();
        }
    }

    active_app.source_done = true;
}

fn workerMain() void {
    const worker_id = currentTask().actor;

    while (true) {
        const job = active_app.jobs.pop() orelse {
            if (active_app.source_done) break;
            Coroutine.yield();
            continue;
        };

        const result = Result{
            .sequence = job.sequence,
            .value = job.value * 17 + @as(u32, @intCast(worker_id)),
            .worker_id = worker_id,
        };
        while (!active_app.results.push(result)) {
            Coroutine.yield();
        }

        active_app.processed += 1;
        active_app.worker_processed[worker_id] += 1;
        active_app.record(.worker, worker_id, job.sequence);
        Coroutine.yield();
    }
}

fn consumerMain() void {
    while (active_app.consumed < item_count) {
        const result = active_app.results.pop() orelse {
            Coroutine.yield();
            continue;
        };

        active_app.observed[active_app.consumed] = result;
        active_app.consumed += 1;
        active_app.record(.consumer, 0, result.sequence);
        Coroutine.yield();
    }
}

pub fn main() !void {
    var app: App = .{};
    active_app = &app;
    defer app.deinit();

    try app.initTask(0, .producer, 0, producerMain);
    inline for (0..worker_count) |worker_id| {
        try app.initTask(worker_id + 1, .worker, worker_id, workerMain);
    }
    try app.initTask(worker_count + 1, .consumer, 0, consumerMain);

    app.run();

    std.debug.assert(app.source_next == item_count);
    std.debug.assert(app.source_done);
    std.debug.assert(app.processed == item_count);
    std.debug.assert(app.consumed == item_count);
    for (app.worker_processed) |processed| {
        std.debug.assert(processed > 0);
    }

    std.debug.print(
        "pipeline completed: {d} items, {d} scheduler turns, {d} events\n",
        .{ app.consumed, app.turns, app.event_count },
    );
    std.debug.print("worker distribution: {any}\n", .{app.worker_processed});
    for (app.observed[0..app.consumed]) |result| {
        std.debug.print(
            "  item {d} -> {d} (worker {d})\n",
            .{ result.sequence, result.value, result.worker_id },
        );
    }
}
