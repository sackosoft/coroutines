const std = @import("std");

const assert = std.debug.assert;
const print = std.debug.print;

const setjmp = @import("bindings/setjmp.zig");
const jmpbuf = setjmp.struct__jmp_buf;

const Runtime = @This();

io: std.Io,
clock: std.Io.Clock = .awake,

pub fn init(io: std.Io) Runtime {
    return .{
        .io = io,
    };
}

pub fn deinit(rt: *Runtime) void {
    _ = rt;
    return;
}

pub const Task = struct {
    pub const done: @This() = .{};
};

pub fn delay(runtime: *Runtime, duration: std.Io.Duration) void {
    _ = runtime;
    _ = duration;
}

pub fn run(runtime: *Runtime, f: *const fn (runtime: *Runtime) Task) !void {
    _ = runtime;
    _ = f;
}

fn get_time_now(runtime: *Runtime) std.Io.Timestamp {
    return std.Io.Timestamp.now(runtime.io, runtime.clock);
}
