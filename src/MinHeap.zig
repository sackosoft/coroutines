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
        const is_power_of_two = (capacity & (capacity - 1) == 0);
        if (!is_power_of_two) @compileError("MinHeap capacity must be a power of two (e.g. 4, 8, 16, 32, etc.), found: " ++ std.fmt.comptimePrint("{d}", .{capacity}));
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

pub fn insert(this: *MinHeap, when: std.Io.Timestamp, stack: Stack) !void {
    assert(when.nanoseconds <= std.math.maxInt(i64));
    const index = this.getCount();
    if (index == this.items.len) {
        return error.MinHeapFull;
    }
    this.items[index] = .{
        .when = @intCast(when.nanoseconds),
        .stack = stack.vm_base_address,
    };
    this.setCount(index + 1);
    this.minHeapify(index);
}

pub fn extractMin(this: *MinHeap, stack: *Stack) bool {
    const count = this.getCount();
    if (count == 0) {
        return false;
    }

    const last_index = count - 1;
    this.swap(1, last_index);
    this.setCount(last_index);
    this.minHeapify(1);
    stack.* = .{
        .vm_base_address = this.items[last_index].stack,
    };
    return true;
}

fn minHeapify(this: *MinHeap, i: usize) void {
    assert(i > 0);
    const l = leftOf(i);
    const r = rightOf(i);
    var smallest: usize = undefined;

    if (l < this.items.len and this.items[l].when < this.items[i].when) {
        smallest = l;
    } else {
        smallest = i;
    }

    if (r < this.items.len and this.items[r].when < this.items[smallest].when) {
        smallest = r;
    }

    if (smallest != i) {
        this.swap(i, smallest);
        this.minHeapify(smallest);
    }
}
fn swap(this: *MinHeap, i: usize, j: usize) void {
    assert(i > 0);
    assert(j > 0);
    assert(i < this.items.len);
    assert(j < this.items.len);
    const temp = this.items[j];
    this.items[j] = this.items[i];
    this.items[i] = temp;
}

fn leftOf(i: usize) usize {
    assert(i > 0);
    return 2 * i;
}

fn rightOf(i: usize) usize {
    assert(i > 0);
    return 2 * i + 1;
}

fn parentOf(i: usize) usize {
    assert(i > 0);
    return i / 2;
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

