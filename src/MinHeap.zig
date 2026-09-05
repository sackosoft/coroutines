const std = @import("std");

const assert = std.debug.assert;

const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");

const MinHeap = @This();

const Item = struct {
    when: i96,
    stack: *anyopaque
};
alloc: std.mem.Allocator,
items: []Item = undefined,
count: usize = 0,

pub fn init(alloc: std.mem.Allocator, capacity: usize) !MinHeap {
    return .{
        .alloc = alloc,
        .count = 0,
        .items = try alloc.alloc(Item, capacity),
    };
}

pub fn deinit(this: *MinHeap) void {
    this.alloc.free(this.items);
}

pub fn add(this: *MinHeap, when: std.Io.Timestamp, stack: Stack) void {
    _ = this;
    _ = when;
    _ = stack;
}

fn leftOf(parent: usize) usize {
    return 1 + (parent * 2);
}
fn rightOf(parent: usize) usize {
    return (1 + parent) * 2;
}
fn parentOf(child: usize) usize {
    if (child % 2 == 0) {
        return (child / 2) - 1;
    } else {
        return (child - 1) / 2;
    }
}

test "parentOf()/leftOf()/rightOf() test matrix" {
    //            0
    //     1               2
    //  3     4        5      6
    // 7 8   9 10   11  12  13  14
    const test_cases = [_]struct{usize, usize, usize}{
        .{0, 1, 2},
        .{1, 3, 4},
        .{2, 5, 6},
        .{3, 7, 8},
        .{4, 9, 10},
        .{5, 11, 12},
        .{6, 13, 14},
    };

    for (test_cases) |test_case| {
        var parent: usize = undefined;
        var left: usize = undefined;
        var right: usize = undefined;
        parent, left, right = test_case;

        try std.testing.expectEqual(left, leftOf(parent));
        try std.testing.expectEqual(right, rightOf(parent));
        try std.testing.expectEqual(parent, parentOf(left));
        try std.testing.expectEqual(parent, parentOf(right));
    }
}

