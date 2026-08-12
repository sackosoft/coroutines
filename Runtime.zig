const std = @import("std");

const assert = std.debug.assert;
const print = std.debug.print;

const setjmp = @import("bindings/setjmp.zig");
const jmpbuf = setjmp.struct__jmp_buf;

const Runtime = @This();

var runtime_id_counter: usize = 1;
var runtimes: [2]Runtime = undefined;

runtime_id: usize,
io: std.Io,

task_count: usize = 0,
tasks: [4096]?Coroutine = undefined,
event_loop_point: jmpbuf = undefined,

clock: std.Io.Clock = .awake,

pub fn init(io: std.Io) *Runtime {
    var runtime: Runtime = .{
        .runtime_id = runtime_id_counter,
        .io = io,
    };
    @memset(runtime.tasks[0..], null);

    runtimes[runtime_id_counter] = runtime;
    const result = &runtimes[runtime_id_counter];
    runtime_id_counter += 1;

    return result;
}

pub const Coroutine = struct {
    resume_at: ?std.Io.Timestamp = null,
    resume_point: jmpbuf = undefined,
};

pub fn delay(runtime: *Runtime, duration: std.Io.Duration) void {
    var rt = runtime;
    const now = rt.get_time_now();
    const resume_at = std.Io.Timestamp.addDuration(now, duration);

    var rp: jmpbuf = undefined;
    print("[delay] setjmp with runtime id = {d}\n", .{rt.runtime_id});
    const retval = setjmp.setjmp(&rp);
    if (retval == 0) {
        rt.push(.{
            .resume_at = resume_at,
            .resume_point = rp,
        }) catch unreachable;

        // Jump back into event loop so as to suspend the execution of the caller.
        print("[delay] long jumping with runtime id = {d}\n", .{rt.runtime_id});
        setjmp.longjmp(&rt.event_loop_point, @intCast(rt.runtime_id));
        unreachable;
    } else {
        print("[delay] Resuming with retval={d}\n", .{retval});
        assert(retval >= 0 and retval < runtime_id_counter);
        rt = &runtimes[@intCast(retval)];
        print("[before] Task count = {d}\n", .{rt.task_count});
        rt.task_count -= 1;
        print("[after] Task count = {d}\n", .{rt.task_count});

        setjmp.longjmp(&rt.event_loop_point, @intCast(rt.runtime_id));
        unreachable;
    }
}

pub fn run(runtime: *Runtime, f: *const fn (runtime: *Runtime) Coroutine) !void {
    var rt = runtime;
    const retval = setjmp.setjmp(&rt.event_loop_point);
    if (retval == 0) {
        _ = f(rt);
    } else {
        print("[run] Resuming with retval={d}\n", .{retval});
        assert(retval >= 0 and retval < runtime_id_counter);
        rt = &runtimes[@intCast(retval)];
    }

    print("[loop] Task count = {d}\n", .{rt.task_count});
    while (rt.task_count > 0) {
        const now = rt.get_time_now();

        for (0..rt.task_count) |i| {
            if (rt.tasks[i]) |*task| {
                if (task.resume_at != null and std.Io.Timestamp.durationTo(now, task.resume_at.?).nanoseconds <= 0) {
                    setjmp.longjmp(&task.resume_point, @intCast(rt.runtime_id));
                    unreachable;
                }
            }
        }
    }
}

fn get_time_now(runtime: *Runtime) std.Io.Timestamp {
    return std.Io.Timestamp.now(runtime.io, runtime.clock);
} fn push(runtime: *Runtime, task: Coroutine) !void {
    if (runtime.task_count == runtime.tasks.len) {
        return error.TaskQueueExhausted;
    }

    runtime.tasks[runtime.task_count] = task;
    runtime.task_count += 1;
}
