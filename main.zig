const std = @import("std");
const Runtime = @import("Runtime.zig");
const Coroutine = Runtime.Coroutine;

const assert = std.debug.assert;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    var runtime = Runtime.init(init.io);
    try runtime.run(&main_async);
}

pub fn main_async(runtime: *Runtime) Coroutine {
    print("Delaying for 1.0 seconds\n", .{});
    runtime.delay(std.Io.Duration.fromSeconds(1));
    print("Done!\n", .{});

    return .{};
}

