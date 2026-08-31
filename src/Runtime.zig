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
        if (!pop_front(&rt.ready_queue)) {
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

fn pop_front(queue: *?Stack, result: *Stack) bool {
    if (queue.*) |q| {
        const temp = q;
        queue = q.header().next;
        result = temp;
        return true;
    }

    return false;
}

fn append_back(queue: *?Stack, item: Stack) void {
    _ = queue;
    _ = item;
    // TODO: These linked list queues need to have a head and tail so I can manage the front and back.
    unreachable;
}
