const std = @import("std");

const assert = std.debug.assert;

const Coroutine = @import("Coroutine.zig");
const Stack = @import("Stack.zig");

const Runtime = @This();

const queue_service_limit: usize = 1000;

ready_queue: IntrusiveStackList = .{},

fn spawn(rt: *Runtime) void {
    _ = rt;
}

fn run(rt: *Runtime) void {
    _ = rt;
}

fn step(rt: *Runtime) void {
    // Each turn we take working on the ready queue will consume at most the coroutines in the queue before we start.
    // Because coroutines we work on can trigger new items to be added to the back of the queue, we could end up in an
    // infinite loop, which is not what we want. We need to be able to break out and do the other book keeping work
    // like checking for completed items in the wait queue before taking another turn in the ready queue. We will also
    // bound the number of serviced items to a fixed count.
    if (rt.ready_queue.tail) |end| {
        var stack: Stack = undefined;
        for (0..queue_service_limit) |_| {
            if(!rt.ready_queue.try_pop_front(&stack)) {
                break;
            }

            const header = stack.header();
            assert(header.status != .completed);
            assert(header.status != .running);
            assert(header.status != .waiting);

            switch (Coroutine.enter2(stack)) {
                .created => unreachable,
                .running => unreachable,
                .yielded => rt.ready_queue.append_back(stack),
                .waiting => rt.wait_queue.append_back(stack),
                .completed => continue,
            }

            if (stack.vm_base_address == end.vm_base_address) {
                break;
            }
        }
    }
}

const IntrusiveStackList = struct {
    // TODO: Add a .count tracking the number of items in total. This would simplify the logic for servicing queues
    // to a simple pop n items instead of tracking which item is the end and making sure we don't go past it.
    head: ?Stack = null,
    tail: ?Stack = null,

    fn try_pop_front(this: *IntrusiveStackList, result: *Stack) bool {
        const head_null = this.head == null;
        assert(head_null == (this.tail == null));
        if (head_null) {
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
            assert(removed.header().prev == null);
            const new_head: Stack = .{ .vm_base_address = removed.header().next.? };
            new_head.header().prev = null;
            this.head = new_head;
            removed.header().prev = null;
            removed.header().next = null;
            result.* = removed;
            return true;
        }
    }

    fn try_pop_back(this: *IntrusiveStackList, result: *Stack) bool {
        const tail_null = this.tail == null;
        assert(tail_null == (this.head == null));
        if (tail_null) {
            return false;
        } else if (this.tail.?.vm_base_address == this.head.?.vm_base_address) {
            const removed =  this.tail.?;
            assert(removed.header().prev == null);
            assert(removed.header().next == null);
            this.head = null;
            this.tail = null;
            result.* = removed;
            return true;
        } else {
            const removed = this.tail.?;
            assert(removed.header().next == null);
            assert(removed.header().prev != null);
            const new_tail: Stack = .{ .vm_base_address = removed.header().prev.? };
            new_tail.header().next = null;
            this.tail = new_tail;
            removed.header().prev = null;
            removed.header().next = null;
            result.* = removed;
            return true;
        }
    }

    fn append_back(this: *IntrusiveStackList, item: Stack) void {
        assert(item.header().next == null);
        assert(item.header().prev == null);
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

    fn remove(this: *IntrusiveStackList, item: Stack) void {
        if (this.head != null and this.head.?.vm_base_address == item.vm_base_address) {
            var s: Stack = undefined;
            const success = this.try_pop_front(&s);
            assert(success);
            assert(s.vm_base_address == item.vm_base_address);
        } else if (this.tail != null and this.tail.?.vm_base_address == item.vm_base_address) {
            var s: Stack = undefined;
            const success = this.try_pop_back(&s);
            assert(success);
            assert(s.vm_base_address == item.vm_base_address);
        } else {
            // TODO: Assert the item is actually somewhere in the middle of this instance and not some other instance.
            // That would be a strange violation of my assumptions.
            // TODO: Assert that the item is not a head or tail based on the pointers in the header. That would also
            // be a strange violation of my assumptions.
            const prev = item.header().prev;
            const next = item.header().next;
            assert(prev != null);
            assert(next != null);
            const prev_header = (Stack{.vm_base_address = prev.?}).header();
            const next_header = (Stack{.vm_base_address = next.?}).header();
            prev_header.next = next.?;
            next_header.prev = prev.?;
            item.header().next = null;
            item.header().prev = null;
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
    try std.testing.expectEqual(s3, result); // Unchanged
    try std.testing.expect(list.head == null);
    try std.testing.expect(list.tail == null);

    list.append_back(s1);
    list.append_back(s2);
    list.append_back(s3);
    try std.testing.expect(list.try_pop_back(&result));
    try std.testing.expectEqual(s3, result);
    try std.testing.expect(list.try_pop_back(&result));
    try std.testing.expectEqual(s2, result);
    try std.testing.expect(list.try_pop_back(&result));
    try std.testing.expectEqual(s1, result);
    try std.testing.expect(!list.try_pop_back(&result));
    try std.testing.expectEqual(s1, result); // Unchanged
    try std.testing.expect(list.head == null);
    try std.testing.expect(list.tail == null);

    list.append_back(s1);
    list.append_back(s2);
    list.append_back(s3);
    list.remove(s2);
    try std.testing.expect(s2.header().next == null);
    try std.testing.expect(s2.header().prev == null);
    try std.testing.expect(list.head != null);
    try std.testing.expect(list.tail != null);
    try std.testing.expectEqual(s1, list.head.?);
    try std.testing.expectEqual(s3, list.tail.?);
    try std.testing.expect(s1.header().prev == null);
    try std.testing.expect(s1.header().next != null);
    try std.testing.expectEqual(s1.header().next.?, s3.vm_base_address);
    try std.testing.expect(s3.header().next == null);
    try std.testing.expect(s3.header().prev != null);
    try std.testing.expectEqual(s3.header().prev.?, s1.vm_base_address);

    list.remove(s3);
    try std.testing.expect(s3.header().next == null);
    try std.testing.expect(s3.header().prev == null);
    try std.testing.expect(list.head != null);
    try std.testing.expect(list.tail != null);
    try std.testing.expectEqual(s1, list.head.?);
    try std.testing.expectEqual(s1, list.tail.?);

    list.remove(s1);
    try std.testing.expect(s1.header().next == null);
    try std.testing.expect(s1.header().prev == null);
    try std.testing.expect(list.head == null);
    try std.testing.expect(list.tail == null);
}
