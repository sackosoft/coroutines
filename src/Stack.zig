const std = @import("std");

const assert = std.debug.assert;

const StackHeader = @import("StackHeader.zig");
const Stack = @This();

pub const max_stack_base_2_log: usize = 21;
pub const max_stack_size: usize = 1 << max_stack_base_2_log;

vm_top_address: *anyopaque,
vm_base_address: *anyopaque,
pool_free_list_index: usize,

pub fn header(this: *const Stack) *StackHeader {
    const head: [*]StackHeader = @ptrCast(@alignCast(this.vm_top_address));
    return @ptrCast(head - 1);
}

pub fn top(this: *const Stack) *anyopaque {
    const ceil = @intFromPtr(this.vm_top_address);
    return @ptrFromInt(ceil - @sizeOf(StackHeader));
}

test "stack address functions" {
    for (0..1000) |i| {
        const base: *anyopaque = @ptrFromInt((0xFFFF + i) * max_stack_size);
        const stack: Stack = .{
            .vm_base_address = base,
            .vm_top_address = @ptrFromInt(@intFromPtr(base) + max_stack_size),
            .pool_free_list_index = undefined,
        };
        const ceil = @intFromPtr(stack.vm_top_address);

        try std.testing.expect(ceil % max_stack_size == 0);
        try std.testing.expectEqual(ceil - @sizeOf(StackHeader), @intFromPtr(stack.top()));
        try std.testing.expectEqual(ceil - @sizeOf(StackHeader), @intFromPtr(stack.header()));
    }
}

