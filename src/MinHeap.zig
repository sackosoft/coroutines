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
    assert(when.nanoseconds >= std.math.minInt(i64));
    var i = this.count().* + 1;
    if (i == this.items.len) {
        return error.MinHeapFull;
    }
    this.items[i] = .{
        .when = @intCast(when.nanoseconds),
        .stack = stack.vm_base_address,
    };
    this.count().* = i;

    // Sift up
    while (i > 1 and this.items[parentOf(i)].when > this.items[i].when) {
        this.swap(parentOf(i), i);
        i = parentOf(i);
    }
}

pub fn popMin(this: *MinHeap, stack: *Stack) bool {
    const current_count = this.count().*;
    if (current_count == 0) {
        return false;
    }

    const last_index = current_count;
    this.swap(1, last_index);
    this.count().* = last_index - 1;
    this.siftDown(1);
    stack.* = .{
        .vm_base_address = this.items[last_index].stack,
    };
    return true;
}

pub fn peek(this: *MinHeap) ?std.Io.Timestamp {
    if (this.getCount() == 0) {
        return null;
    }
    return std.Io.Timestamp.fromNanoseconds(@intCast(this.items[1].when));
}

pub fn popMinNotAfter(this: *MinHeap, timestamp: std.Io.Timestamp, stack: *Stack) bool {
    if (this.items[1].when <= timestamp.nanoseconds) {
        return this.popMin(stack);
    }

    return false;
}

// TODO: I think it would make sense to comptle-time specialize MinHeap so functions like "siftDown" can use
// stack-allocated memory with comptime-known maxiumum level of recursion, bounded by the height of the tree.
// Then we can avoid the recursion and use a simple loop.
fn siftDown(this: *MinHeap, i: usize) void {
    assert(i > 0);
    const l = leftOf(i);
    const r = rightOf(i);
    const active_bound = this.count().* + 1;
    var smallest: usize = undefined;

    if (l < active_bound and this.items[l].when < this.items[i].when) {
        smallest = l;
    } else {
        smallest = i;
    }

    if (r < active_bound and this.items[r].when < this.items[smallest].when) {
        smallest = r;
    }

    if (smallest != i) {
        this.swap(i, smallest);
        this.siftDown(smallest);
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

pub fn getCount(this: *MinHeap) usize {
    return this.count().*;
}

fn count(this: *MinHeap) *usize {
    return @as(*usize, @ptrCast(&this.items[0].when));
}

fn testStack(id: usize) Stack {
    return .{ .vm_base_address = @ptrFromInt(0x1000 + id * 16) };
}

fn testTimestamp(nanoseconds: i64) std.Io.Timestamp {
    return std.Io.Timestamp.fromNanoseconds(nanoseconds);
}

fn assertPopMin(heap: *MinHeap, expected: Stack) !void { 
    var actual = testStack(0);
    try std.testing.expect(heap.popMin(&actual));
    try std.testing.expectEqual(expected, actual);
}

fn assertPopMinNotAfter(heap: *MinHeap, timestamp: i96, expected: Stack) !void { 
    var actual = testStack(0);
    try std.testing.expect(heap.popMinNotAfter(std.Io.Timestamp.fromNanoseconds(timestamp), &actual));
    try std.testing.expectEqual(expected, actual);
}

fn assertEmpty(heap: *MinHeap) !void {
    const unchanged = testStack(0);
    var actual = unchanged;
    try std.testing.expect(!heap.popMin(&actual));
    try std.testing.expectEqual(unchanged, actual);
    try std.testing.expectEqual(0, heap.count().*);
}

test "init() creates an empty heap and deinit() releases its allocation" {
    var heap = try MinHeap.init(std.testing.allocator, 4);
    defer heap.deinit();

    try assertEmpty(&heap);
}

test "init() propagates allocation failures" {
    var failing_allocator = std.testing.FailingAllocator.init(std.testing.allocator, .{
        .fail_index = 0,
    });

    try std.testing.expectError(
        error.OutOfMemory,
        MinHeap.init(failing_allocator.allocator(), 4),
    );
}

test "insert() and popMin() handle a single item" {
    var heap = try MinHeap.init(std.testing.allocator, 4);
    defer heap.deinit();

    const expected = testStack(1);
    try heap.insert(testTimestamp(42), expected);
    try assertPopMin(&heap, expected);
    try assertEmpty(&heap);
}

test "peek() returns null when heap is empty" {
    var heap = try MinHeap.init(std.testing.allocator, 16);
    defer heap.deinit();

    try std.testing.expect(heap.peek() == null);
}

test "peek() returns lowest timestamp" {
    const Entry = struct { when: i64, stack: Stack, expected_min: i64 };
    const entries = [_]Entry{
        .{ .when = 4, .stack = testStack(4), .expected_min = 4 },
        .{ .when = 2, .stack = testStack(2), .expected_min = 2 },
        .{ .when = 3, .stack = testStack(3), .expected_min = 2 },
        .{ .when = 1, .stack = testStack(1), .expected_min = 1 },
        .{ .when = 0, .stack = testStack(0), .expected_min = 0 },
        .{ .when = 5, .stack = testStack(5), .expected_min = 0 },
    };

    for (0..entries.len) |i| {
        var heap = try MinHeap.init(std.testing.allocator, 16);
        defer heap.deinit();

        var entry: Entry = undefined;
        for(0..i+1) |j| {
            entry = entries[j];
            try heap.insert(testTimestamp(entry.when), entry.stack);
        }

        try std.testing.expectEqual(testTimestamp(entry.expected_min), heap.peek().?);
    }
}

test "popMin() returns stacks in ascending order" {
    var heap = try MinHeap.init(std.testing.allocator, 16);
    defer heap.deinit();

    const entries = [_]struct { when: i64, stack: Stack }{
        .{ .when = 5, .stack = testStack(5) },
        .{ .when = 3, .stack = testStack(3) },
        .{ .when = 4, .stack = testStack(4) },
        .{ .when = 1, .stack = testStack(1) },
        .{ .when = 2, .stack = testStack(2) },
        .{ .when = 6, .stack = testStack(6) },
    };

    for (entries) |entry| {
        try heap.insert(testTimestamp(entry.when), entry.stack);
    }

    for (1..7) |i| {
        const expected = testStack(i);
        try assertPopMin(&heap, expected);
    }
    try assertEmpty(&heap);
}

test "popMinBefore() returns stacks in ascending order until threshold" {
    var heap = try MinHeap.init(std.testing.allocator, 16);
    defer heap.deinit();

    const entries = [_]struct { when: i64, stack: Stack }{
        .{ .when = 5, .stack = testStack(5) },
        .{ .when = 3, .stack = testStack(3) },
        .{ .when = 4, .stack = testStack(4) },
        .{ .when = 1, .stack = testStack(1) },
        .{ .when = 2, .stack = testStack(2) },
        .{ .when = 6, .stack = testStack(6) },
    };

    for (entries) |entry| {
        try heap.insert(testTimestamp(entry.when), entry.stack);
    }

    try assertPopMinNotAfter(&heap, 4, testStack(1));
    try assertPopMinNotAfter(&heap, 4, testStack(2));
    try assertPopMinNotAfter(&heap, 4, testStack(3));
    try assertPopMinNotAfter(&heap, 4, testStack(4));
    try std.testing.expect(heap.count().* == 2);
}

test "insert() preserves all entries with equal deadlines" {
    var heap = try MinHeap.init(std.testing.allocator, 8);
    defer heap.deinit();

    const entries = [_]Stack{
        testStack(1),
        testStack(2),
        testStack(3),
        testStack(4),
    };
    for (entries) |stack| {
        try heap.insert(testTimestamp(100), stack);
    }

    var seen = [_]bool{false} ** entries.len;
    for (entries) |_| {
        var actual = testStack(0);
        try std.testing.expect(heap.popMin(&actual));

        var found = false;
        for (entries, 0..) |expected, index| {
            if (!seen[index] and actual.vm_base_address == expected.vm_base_address) {
                seen[index] = true;
                found = true;
                break;
            }
        }
        try std.testing.expect(found);
    }
    for (seen) |was_seen| {
        try std.testing.expect(was_seen);
    }
    try assertEmpty(&heap);
}

test "insert() reports MinHeapFull and retains existing entries" {
    const capacity = 8;
    var heap = try MinHeap.init(std.testing.allocator, capacity);
    defer heap.deinit();

    var inserted: usize = 0;
    var reached_capacity = false;
    for (0..capacity + 1) |_| {
        const id = inserted + 1;
        if (heap.insert(testTimestamp(@intCast(id)), testStack(id))) |_| {
            inserted = id;
        } else |err| {
            try std.testing.expectEqual(error.MinHeapFull, err);
            reached_capacity = true;
            break;
        }
    }
    try std.testing.expect(reached_capacity);
    try std.testing.expect(inserted > 0);

    try std.testing.expectError(
        error.MinHeapFull,
        heap.insert(testTimestamp(0), testStack(inserted + 1)),
    );
    for (1..inserted + 1) |id| {
        const expected = testStack(id);
        try assertPopMin(&heap, expected);
    }
    try assertEmpty(&heap);
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
