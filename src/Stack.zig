const std = @import("std");

const assert = std.debug.assert;

const StackHeader = @import("StackHeader.zig");
const Stack = @This();

pub const max_stack_base_2_log: usize = 21;
pub const max_stack_size: usize = 1 << max_stack_base_2_log;

vm_base_address: *anyopaque,
pool_free_list_index: usize,

pub fn header(this: *const Stack) *StackHeader {
    const head: [*]StackHeader = @ptrCast(@alignCast(this.getVmTopAddress()));
    return @ptrCast(head - 1);
}

/// Returns a 16-byte aligned pointer to the top most address of usable stack space (below the header and any required
/// padding to enforce alignment requirements of the underlying ABI).
pub fn top(this: *const Stack) *anyopaque {
    const ceil = @intFromPtr(this.getVmTopAddress());
    const candidate = ceil - @sizeOf(StackHeader);
    const ptr = candidate - (candidate % 16);
    assert(ptr % 16 == 0);
    return @ptrFromInt(ptr);
}

fn getVmTopAddress(this: *const Stack) *anyopaque {
    const ptr = @intFromPtr(this.vm_base_address);
    assert(ptr % 16 == 0);
    return @ptrFromInt(ptr + max_stack_size);
}

test "stack address functions" {
    for (0..1000) |i| {
        const base: *anyopaque = @ptrFromInt((0xFFFF + i) * max_stack_size);
        const stack: Stack = .{
            .vm_base_address = base,
            .pool_free_list_index = undefined,
        };
        const ceil = @intFromPtr(stack.getVmTopAddress());

        try std.testing.expect(ceil % max_stack_size == 0);
        const stack_top = @intFromPtr(stack.top());
        try std.testing.expect(stack_top % 16 == 0);
        try std.testing.expectEqual(ceil - @sizeOf(StackHeader) - (@sizeOf(StackHeader) % 16), stack_top);
        try std.testing.expectEqual(ceil - @sizeOf(StackHeader), @intFromPtr(stack.header()));
    }
}

