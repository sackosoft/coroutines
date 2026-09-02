const std = @import("std");

const Coroutine = @import("Coroutine.zig");
const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");

fn f() void {
    Coroutine.yield();
}

pub fn main() !void {
    const stack = try Coroutine.create(f, .{}, .{});
    defer stack.destroy();

    var status: StackHeader.Status = undefined;
    status = Coroutine.enter(stack);
    std.debug.print("{t}\n", .{status});

    status = Coroutine.enter(stack);
    std.debug.print("{t}\n", .{status});
}
