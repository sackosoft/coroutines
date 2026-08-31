const std = @import("std");

const assert = std.debug.assert;

const Coroutine = @import("Coroutine.zig");
const Stack = @import("Stack.zig");

const Runtime = @This();

wait_queue: ?Stack = undefined,
ready_queue: ?Stack = undefined,

fn step(rt: *Runtime) void {
    // Shove all completed waits into the ready queue.
    while(true) {
        var stack: Stack = undefined;
        if (!pop_front(&rt.wait_queue, &stack)) {
            break;
        }

        const header = stack.header();
        assert(header.status == .waiting);
        if (header.wait_done) {
            if (rt.ready_queue) |s| {
                header.next = s.vm_base_address;
            }
            rt.ready_queue = stack;
        }
    }

    // TODO: This can be an infinite loop which I'm not 100% sure I want. I think it makes
    // more sense to either do individual operations or run through each list no more than
    // once. Especially the ready_queue which can both enter a coroutine, then put it on
    // the back of the ready_queuew when it yields, then pick it up later and run again.
    // The whole runtime should be doing that, but I think that a `step()` should not. It
    // needs a chance to check again for completions in the wait_queue.
    while (true) {
        var stack: Stack = undefined;
        if (!pop_front(&rt.ready_queue, &stack)) {
            break;
        }

        const header = stack.header();
        assert(header.status != .completed);
        assert(header.status != .running);
        Coroutine.enter2(stack);

        switch (header.status) {
            .created => unreachable,
            .running => unreachable,
            .yielded => append_back(&rt.ready_queue, stack),
            .waiting => append_back(&rt.wait_queue, stack),
            .completed => continue,
        }
    }
}
fn pop_front(a: *?Stack, b: *Stack) bool { _ = a; _ = b; return false; }
fn append_back(a: *?Stack, b: Stack) void { _ = a; _ = b; }

const IntrusiveStackList = struct {
    head: ?Stack = null,
    tail: ?Stack = null,

    fn try_pop_front(this: *IntrusiveStackList, result: *Stack) bool {
        const head_null = this.head == null;
        assert(head_null == (this.tail == null));
        if (head_null) {
            assert(this.tail == null);
            return false;
        } else if (this.head.?.vm_base_address == this.tail.?.vm_base_address) {
            const removed =  this.head.?;
            assert(removed.header().prev == null);
            assert(removed.header().next == null);
            this.head = null;
            this.tail = null;
            result.* = removed;
            return true;
        } else {
            const removed = this.head.?;
            assert(removed.header().next != null);
            const new_head: Stack = .{ .vm_base_address = removed.header().next.? };
            new_head.header().prev = null;
            this.head = new_head;
            removed.header().prev = null;
            removed.header().next = null;
            result.* = removed;
            return true;
        }
    }

    fn append_back(this: *IntrusiveStackList, item: Stack) void {
        if (this.head == null and this.tail == null) {
            assert(item.header().prev == null);
            assert(item.header().next == null);
            this.head = item;
            this.tail = item;
            return;
        } else {
            assert(this.head != null and this.tail != null);
            const tail = this.tail.?;
            tail.header().next = item.vm_base_address;
            item.header().prev = tail.vm_base_address;
            item.header().next = null;
            this.tail = item;
        }
    }
};

test "IntrusiveStackList operations and edge cases" {
    var list: IntrusiveStackList = .{};
    const expected_uninitialized: Stack = .{ .vm_base_address = @ptrFromInt(0x1a8f3900) };
    const s1: Stack = try .create(4096);
    defer s1.destroy();
    const s2: Stack = try .create(4096);
    defer s2.destroy();
    const s3: Stack = try .create(4096);
    defer s3.destroy();
    var result: Stack = expected_uninitialized;

    try std.testing.expect(!list.try_pop_front(&result));
    try std.testing.expectEqual(expected_uninitialized, result);

    list.append_back(s1);
    try std.testing.expect(s1.header().next == null);
    try std.testing.expect(s1.header().prev == null);
    try std.testing.expect(list.head != null);
    try std.testing.expect(list.tail != null);
    try std.testing.expectEqual(s1, list.head.?);
    try std.testing.expectEqual(s1, list.tail.?);

    try std.testing.expect(list.try_pop_front(&result));
    try std.testing.expectEqual(s1, result);
    try std.testing.expect(list.head == null);
    try std.testing.expect(list.tail == null);

    list.append_back(s1);
    list.append_back(s2);
    try std.testing.expect(list.head != null);
    try std.testing.expect(list.tail != null);
    try std.testing.expectEqual(s1, list.head.?);
    try std.testing.expectEqual(s2, list.tail.?);
    try std.testing.expect(s1.header().prev == null);
    try std.testing.expect(s1.header().next != null);
    try std.testing.expectEqual(s1.header().next.?, s2.vm_base_address);
    try std.testing.expect(s2.header().next == null);
    try std.testing.expect(s2.header().prev != null);
    try std.testing.expectEqual(s2.header().prev.?, s1.vm_base_address);

    list.append_back(s3);
    try std.testing.expect(list.tail != null);
    try std.testing.expectEqual(s3, list.tail.?);
    try std.testing.expect(s2.header().next != null);
    try std.testing.expect(s2.header().prev != null);
    try std.testing.expectEqual(s2.header().next.?, s3.vm_base_address);
    try std.testing.expectEqual(s2.header().prev.?, s1.vm_base_address);
    try std.testing.expect(s3.header().next == null);
    try std.testing.expect(s3.header().prev != null);
    try std.testing.expectEqual(s3.header().prev.?, s2.vm_base_address);

    try std.testing.expect(list.try_pop_front(&result));
    try std.testing.expectEqual(s1, result);
    try std.testing.expect(list.try_pop_front(&result));
    try std.testing.expectEqual(s2, result);
    try std.testing.expect(list.try_pop_front(&result));
    try std.testing.expectEqual(s3, result);
    try std.testing.expect(!list.try_pop_front(&result));
    try std.testing.expectEqual(s3, result);
}
