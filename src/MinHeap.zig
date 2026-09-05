const std = @import("std");

const assert = std.debug.assert;

const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");

const MinHeap = @This();

const Item = struct {
    when: i64,
    stack: *anyopaque
};
alloc: std.mem.Allocator,

/// Items[0] does not contain an item and is reserved to contain a "count" property. This makes the
/// datastructure 1-indexed.
items: []Item,

pub fn init(alloc: std.mem.Allocator, comptime capacity: usize) !MinHeap {
    comptime {
        if (capacity < 4) @compileError("MinHeap capacity must be at least four, found: " ++ std.fmt.comptimePrint("{d}", .{capacity}));
        if (!isValidHeapSize(capacity)) @compileError("MinHeap capacity must be a power of two (e.g. 4, 8, 16, 32, etc.), found: " ++ std.fmt.comptimePrint("{d}", .{capacity}));
    }

    const heap: MinHeap = .{
        .alloc = alloc,
        .items = try alloc.alloc(Item, capacity),
    };
    heap.items[0].when = 0;
    return heap;
}

pub fn deinit(this: *MinHeap) void {
    this.alloc.free(this.items);
}

pub fn add(this: *MinHeap, when: std.Io.Timestamp, stack: Stack) void {
    assert(when.nanoseconds <= std.math.maxInt(i64));

    _ = this;
    _ = stack;
}

fn leftOf(heap_size: usize, i: usize, result: *usize) bool {
    assert(i > 0);
    assert(isValidHeapSize(heap_size));
    if (i >= (heap_size / 2)) {
        return false;
    }

    result.* = 2 * i;
    return true;
}

fn rightOf(heap_size: usize, i: usize, result: *usize) bool {
    assert(i > 0);
    assert(isValidHeapSize(heap_size));
    if (i >= (heap_size / 2)) {
        return false;
    }

    result.* = 2 * i + 1;
    return true;
}

fn parentOf(i: usize, result: *usize) bool {
    assert(i > 0);
    if (i <= 1) {
        return false;
    }

    const parent = i / 2;
    result.* = parent;
    return true;
}

fn isValidHeapSize(v: usize) bool {
    const is_power_of_two = (v & (v - 1) == 0);
    return is_power_of_two;
}

fn getCount(this: *MinHeap) usize {
    return @as(*usize, @ptrCast(&this.items[0].when)).*;
}

fn setCount(this: *MinHeap, count: usize) void {
    @as(*usize, @ptrCast(&this.items[0].when)).* = count;
}

test "valid parentOf()/leftOf()/rightOf() test matrix" {
    //            1
    //     2               3
    //  4     5        6      7
    // 8 9   10 11   12  13  14  15
    const test_cases = [_]struct{usize, usize, usize}{
        .{1, 2, 3},
        .{2, 4, 5},
        .{3, 6, 7},
        .{4, 8, 9},
        .{5, 10, 11},
        .{6, 12, 13},
        .{7, 14, 15},
    };

    var actual: usize = undefined;
    for (test_cases) |test_case| {
        var parent: usize = undefined;
        var left: usize = undefined;
        var right: usize = undefined;
        parent, left, right = test_case;

        try std.testing.expect(leftOf(512, parent, &actual));
        try std.testing.expectEqual(left, actual);

        try std.testing.expect(rightOf(512, parent, &actual));
        try std.testing.expectEqual(right, actual);

        try std.testing.expect(parentOf(left, &actual));
        try std.testing.expectEqual(parent, actual);

        try std.testing.expect(parentOf(right, &actual));
        try std.testing.expectEqual(parent, actual);
    }
}


test "parentOf() refuses to find parent of root element" {
    var actual: usize = undefined;
    try std.testing.expect(!parentOf(1, &actual));
}


test "leftOf() and rightOf() refuse to find children for leaf nodes" {
    //            1
    //     2               3
    //  4     5        6      7
    // 8 9  10 11    12 13  14 15
    const heap_size: usize = 16;
    const leaf_nodes_indices = [_]usize{
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
    };

    var actual: usize = undefined;
    for (leaf_nodes_indices) |leaf_node_index| {
        try std.testing.expect(!leftOf(heap_size, leaf_node_index, &actual));
        try std.testing.expect(!rightOf(heap_size, leaf_node_index, &actual));
    }
}

