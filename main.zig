const std = @import("std");
const Runtime = @import("Runtime.zig");
const Task = Runtime.Task;

const assert = std.debug.assert;
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    var rt = Runtime.init(init.io);
    defer rt.deinit();

    try rt.run(&main_async);
}

pub fn main_async(runtime: *Runtime) Task {
    print("Delaying for 1.0 seconds\n", .{});
    runtime.delay(std.Io.Duration.fromSeconds(1));
    print("Done!\n", .{});
    return Task.done;
}

