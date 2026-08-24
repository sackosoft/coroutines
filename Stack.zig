const std = @import("std");

const assert = std.debug.assert;

pub const max_stack_base_2_log: usize = 21;
pub const max_stack_size: usize = 1 << max_stack_base_2_log;

pub const StackHeader = struct {
    // Contains a pointer to a different stack, for when the coroutine is paused or completed
    // and control need to return to the calling context.
    caller_stack_pointer: *anyopaque,

    // Contains a pointer within the current stack, for resuming the coroutine.
    saved_stack_pointer: *anyopaque,
};

pub const Stack = struct {
    vm_base_address: *anyopaque,
    pool_free_list_index: usize,

    pub fn header(this: *const Stack) *StackHeader {
        const head: [*]StackHeader = @ptrCast(@alignCast(this.vm_top_address()));
        return @ptrCast(head - 1);
    }

    pub fn top(this: *const Stack) *anyopaque {
        const ceil = @intFromPtr(this.vm_top_address());
        return @ptrFromInt(ceil - @sizeOf(StackHeader));
    }

    /// Returns the max_stack_size-aligned boundary of the highest address of the given
    /// virtual memory mapping.
    fn vm_top_address(stack: *const Stack) *anyopaque {
        const base = @intFromPtr(stack.vm_base_address);
        assert(base % max_stack_size == 0);
        return @ptrFromInt(base + max_stack_size);
    }
};

test "stack address functions" {
    for (0..10) |i| {
        const stack: Stack = .{
            .vm_base_address = @ptrFromInt((500 + i) * max_stack_size),
            .pool_free_list_index = undefined,
        };
        const ceil = @intFromPtr(stack.vm_top_address());

        try std.testing.expect(ceil % max_stack_size == 0);
        try std.testing.expectEqual(ceil - @sizeOf(StackHeader), @intFromPtr(stack.top()));
        try std.testing.expectEqual(ceil - @sizeOf(StackHeader), @intFromPtr(stack.header()));
    }
}

