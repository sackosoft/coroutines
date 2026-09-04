const std = @import("std");
const mman = @import("bindings/sys/mman.zig");

const assert = std.debug.assert;

const StackHeader = @import("StackHeader.zig");
const Stack = @This();

const max_stack_base_2_log: usize = 21;
pub const max_stack_size: usize = 1 << max_stack_base_2_log;
pub const system_page_size_bytes: usize = std.heap.pageSize();

vm_base_address: *anyopaque,

/// Allocates (using operating system-provided virtual memory mapping syscalls) a runtime
/// stack which can be used as both the task metadata and function call stack for a
/// coroutine.
pub fn create(usable_stack_size_bytes: usize) !Stack {
    if (usable_stack_size_bytes % system_page_size_bytes != 0) {
        return error.StackSizeIsNotPageAligned;
    }

    if (usable_stack_size_bytes > max_stack_size) {
        return error.StackTooLarge;
    }

    const prot = mman.PROT_NONE;
    const flags = mman.MAP_ANON | mman.MAP_ALIGNED(max_stack_base_2_log);

    // Always map virtual memory for the max stack size and align the mapped memory
    // to that max stack size. This way all stack sizes can determine the address of
    // the top of the stack with in constant time by doing some math to round the
    // stack pointer up to the alignment boundary.
    const maybePtr = mman.mmap(
        null,
        max_stack_size,
        prot,
        flags,
        -1,
        0,
    );

    if (maybePtr == mman.MAP_FAILED or maybePtr == null) {
        return error.UnableToMapVirtualMemory;
    }

    const mmap_base = maybePtr.?;
    assert(@intFromPtr(mmap_base) % 16 == 0);
    assert(usable_stack_size_bytes <= max_stack_size);

    const bottom_of_usable_stack_pages = @intFromPtr(mmap_base) + (max_stack_size - usable_stack_size_bytes);
    const mprotect_flags = mman.PROT_READ | mman.PROT_WRITE;

    // Change the protection for the user-specified number of pages at the top of the
    // address range which will act as the "real" usable stack pages.
    var ret = mman.mprotect(
        @ptrFromInt(bottom_of_usable_stack_pages),
        usable_stack_size_bytes,
        mprotect_flags,
    );

    if (ret != 0) {
        ret = mman.munmap(mmap_base, max_stack_size);
        assert(ret == 0);
        return error.UnableToProtectVirtualMemory;
    }

    return .{
        .vm_base_address = mmap_base,
    };
}

pub fn wipe(stack: Stack) !void {
    // TODO: madvise(MADV_FREE) says the following in the FreeBSD man page:
    // "The next time that the page is referenced, the page might be demand zeroed,
    // or might contain the data that was there before the MADV_FREE call"
    // That means `wipe()` is not guaranteed to clear the pages. Any data on the stack
    // may be read back later if the stack is reused. We should do one of the following:
    // * Switch to a new mmap() to overwite the mapped region in the given stack. That
    //   guarantees zero pages to be read back later.
    // * Or, immediately zero the pages before calling madvise. This would require storing
    //   a bit more metadata in each stack header (the size of the usable stack space
    //   within the mapping).
    // For now, I'm not even entirely sure I want to keep the `wipe()` functionality. It
    // was added since we started with a pool implementation for stacks, and in that case
    // it makes sense to advise that the pages can be freed, since a stack that grows
    // can consume core memory without much use to the system while it's idle in the pool.
    const ret = mman.madvise(
        stack.vm_base_address,
        Stack.max_stack_size,
        mman.MADV_FREE,
    );

    if (ret != 0) {
        return error.FailedAdviseFree;
    }
}

pub fn destroy(stack: Stack) void {
    const ret = mman.munmap(
        stack.vm_base_address,
        max_stack_size,
    );
    assert(ret == 0);
}

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
        };
        const ceil = @intFromPtr(stack.getVmTopAddress());

        try std.testing.expect(ceil % max_stack_size == 0);
        const stack_top = @intFromPtr(stack.top());
        try std.testing.expect(stack_top % 16 == 0);
        try std.testing.expectEqual(ceil - @sizeOf(StackHeader) - (@sizeOf(StackHeader) % 16), stack_top);
        try std.testing.expectEqual(ceil - @sizeOf(StackHeader), @intFromPtr(stack.header()));
    }
}

fn assertAddressMapped(probe: *anyopaque) !void {
    var state: u8 = undefined;
    const result = mman.mincore(
        probe,
        system_page_size_bytes,
        @ptrCast(&state)
    );
    try std.testing.expect(result == 0);
}

pub fn assertStackMapped(stack: Stack) !void {
    const ptr = @intFromPtr(stack.vm_base_address);
    try std.testing.expect(ptr % 16 == 0);
    for (0..(Stack.max_stack_size / system_page_size_bytes)) |j| {
        const probe: *anyopaque = @ptrFromInt(ptr + (system_page_size_bytes * j));
        try assertAddressMapped(probe);
    }
}

test "All pages in virtual address range should be mapped" {
    for (0..8) |i| {
        const stack_size = @as(usize, 1) << @as(u6, @intCast(i));
        var stack = try create(system_page_size_bytes * stack_size);
        defer stack.destroy();

        try assertStackMapped(stack);
    }
}

test "All pages in virtual address range should be mapped (after wipe())" {
    for (0..8) |i| {
        const stack_size = @as(usize, 1) << @as(u6, @intCast(i));
        var stack = try create(system_page_size_bytes * stack_size);
        defer stack.destroy();

        try stack.wipe();

        const ptr = @intFromPtr(stack.vm_base_address);
        try std.testing.expect(ptr % 16 == 0);
        for (0..(Stack.max_stack_size / system_page_size_bytes)) |j| {
            const probe: *anyopaque = @ptrFromInt(ptr + (system_page_size_bytes * j));
            try assertAddressMapped(probe);
        }
    }
}

fn assertAddressNotMapped(probe: *anyopaque) !void {
    var state: u8 = undefined;
    const result = mman.mincore(
        probe,
        system_page_size_bytes,
        @ptrCast(&state)
    );
    try std.testing.expect(result != 0);
    try std.testing.expectEqual(@intFromEnum(std.c.E.NOMEM), std.c._errno().*);
}

pub fn assertStackNotMapped(stack: Stack) !void {
    const ptr = @intFromPtr(stack.vm_base_address);
    try std.testing.expect(ptr % 16 == 0);
    for (0..(Stack.max_stack_size / system_page_size_bytes)) |j| {
        const probe: *anyopaque = @ptrFromInt(ptr + (system_page_size_bytes * j));
        try assertAddressNotMapped(probe);
    }
}

test "No pages in virtual address range should be mapped after destroy()" {
    for (0..8) |i| {
        const stack_size = @as(usize, 1) << @as(u6, @intCast(i));
        var stack = try create(system_page_size_bytes * stack_size);

        stack.destroy();

        try assertStackNotMapped(stack);
    }
}

test "Stack.create error cases" {
    try std.testing.expectError(error.StackSizeIsNotPageAligned, Stack.create(1));
    try std.testing.expectError(error.StackSizeIsNotPageAligned, Stack.create(512));
    try std.testing.expectError(error.StackSizeIsNotPageAligned, Stack.create(system_page_size_bytes + 1));
    try std.testing.expectError(error.StackSizeIsNotPageAligned, Stack.create(system_page_size_bytes - 1));

    try std.testing.expectError(error.StackTooLarge, Stack.create(max_stack_size + system_page_size_bytes));
    try std.testing.expectError(error.StackTooLarge, Stack.create(max_stack_size + 2 * system_page_size_bytes));
    try std.testing.expectError(error.StackTooLarge, Stack.create(max_stack_size * 2));
    try std.testing.expectError(error.StackTooLarge, Stack.create(max_stack_size * 8));
    try std.testing.expectError(error.StackTooLarge, Stack.create(max_stack_size * 256));
}
