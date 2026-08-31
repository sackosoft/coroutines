const std = @import("std");

const Stack = @import("Stack.zig");

pub fn main(init: std.process.Init) !void {
    var stacks: [1_000_000]Stack = undefined;
    for (0..1000) |i| {
        for (0..1000) |j| {
            stacks[i * 1000 + j] = try Stack.create(4096);
        }

        std.debug.print("Created {d}k stacks\n", .{i});
        try std.Io.sleep(init.io, .fromMilliseconds(100), .real);
    }
}
