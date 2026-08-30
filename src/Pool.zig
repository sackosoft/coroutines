const std = @import("std");
const mman = @import("bindings/sys/mman.zig");

const assert = std.debug.assert;
const print = std.debug.print;

const system_page_size_bytes: usize = std.heap.pageSize();
const Stack = @import("Stack.zig");

const Pool = @This();

pub var GlobalPool: Pool = (struct {
    fn globalInit() Pool {
        var pool = Pool{
            .alloc = undefined,
            .free_lists = .{.{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}},
        };

        for (0 .. pool.free_lists.len) |i| {
            @memset(pool.free_lists[i].free_stacks[0..], null);
        }

        return pool;
    }
}).globalInit();

alloc: std.mem.Allocator,
free_lists: [10]FreeList = undefined,

const FreeList = struct {
    count: usize = 0,
    free_stacks: [1024]?Stack = undefined,
};

pub fn init(alloc: std.mem.Allocator) !*Pool {
    const this = try alloc.create(Pool);
    this.* = Pool{
        .alloc = alloc,
        .free_lists = .{.{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}},
    };

    for (0 .. this.free_lists.len) |i| {
        @memset(this.free_lists[i].free_stacks[0..], null);
    }
    return this;
}

pub fn deinit(this: *Pool) void {
    for (0..this.free_lists.len) |i| {
        const free_stacks: []?Stack = this.free_lists[i].free_stacks[0..];
        for (free_stacks) |free_stack| {
            if (free_stack) |fs| {
                const ret = mman.munmap(fs.vm_base_address, Stack.max_stack_size);
                assert(ret == 0); // munmap should hopefully never fail
            }
        }
        @memset(free_stacks, null);
    }
    this.alloc.destroy(this);
}

pub fn reserveStack4KiB(this: *Pool) !Stack {
    return this.reserveInternal(0);
}

pub fn reserveStack8KiB(this: *Pool) !Stack {
    return this.reserveInternal(1);
}

pub fn reserveStack16KiB(this: *Pool) !Stack {
    return this.reserveInternal(2);
}

pub fn reserveStack32KiB(this: *Pool) !Stack {
    return this.reserveInternal(3);
}

pub fn reserveStack64KiB(this: *Pool) !Stack {
    return this.reserveInternal(4);
}

pub fn reserveStack128KiB(this: *Pool) !Stack {
    return this.reserveInternal(5);
}

pub fn reserveStack256KiB(this: *Pool) !Stack {
    return this.reserveInternal(6);
}

pub fn reserveStack512KiB(this: *Pool) !Stack {
    return this.reserveInternal(7);
}

pub fn reserveStack1MiB(this: *Pool) !Stack {
    return this.reserveInternal(8);
}

pub fn reserveStack2MiB(this: *Pool) !Stack {
    return this.reserveInternal(9);
}

pub fn releaseStack(this: *Pool, stack: Stack) void {
    var free_list = &this.free_lists[stack.pool_free_list_index];

    if (free_list.count == free_list.free_stacks.len) {
        const ret = mman.munmap(stack.vm_base_address, Stack.max_stack_size);
        assert(ret == 0);
        return;
    } else {
        const ret = mman.madvise(
            stack.vm_base_address,
            Stack.max_stack_size,
            mman.MADV_FREE,
        );
        assert(ret == 0);
    }

    for (0..free_list.free_stacks.len) |i| {
        if (free_list.free_stacks[i] == null) {
            free_list.count += 1;
            free_list.free_stacks[i] = stack;
            return;
        }
    }

    unreachable;
}

fn reserveInternal(this: *Pool, pool_index: usize) !Stack {
    assert(pool_index < this.free_lists.len);

    var free_list = &this.free_lists[pool_index];
    if (free_list.count > 0) {
        for (0..free_list.free_stacks.len) |i| {
            if (free_list.free_stacks[i]) |fs| {
                free_list.free_stacks[i] = null;
                free_list.count -= 1;
                return fs;
            }
        }
    }

    const prot = mman.PROT_NONE;
    const flags = mman.MAP_ANON | mman.MAP_ALIGNED(Stack.max_stack_base_2_log);

    // Always map virtual memory for the max stack size and align the mapped memory
    // to that max stack size. This way all stack sizes can determine the address of
    // the top of the stack with in constant time by doing some math to round the
    // stack pointer up to the alignment boundary.
    const maybePtr = mman.mmap(
        null,
        Stack.max_stack_size,
        prot,
        flags,
        -1,
        0,
    );

    if (maybePtr == null) {
        return error.VirtualMemoryAllocate;
    }

    const mmap_base = maybePtr.?;
    const usable_stack_size_bytes: usize = poolIndexToStackPages(pool_index) * system_page_size_bytes;
    assert(usable_stack_size_bytes <= Stack.max_stack_size);

    const bottom_of_usable_stack_pages = @intFromPtr(mmap_base) + (Stack.max_stack_size - usable_stack_size_bytes);
    const mprotect_flags = mman.PROT_READ | mman.PROT_WRITE;

    // Change the protection for the user-specified number of pages at the top of the
    // address range which will act as the "real" usable stack pages.
    const ret = mman.mprotect(
        @ptrFromInt(bottom_of_usable_stack_pages),
        usable_stack_size_bytes,
        mprotect_flags,
    );

    if (ret != 0) {
        return error.VirtualMemoryProtect;
    }

    return .{
        .vm_top_address = @ptrFromInt(@intFromPtr(mmap_base) + Stack.max_stack_size),
        .vm_base_address = mmap_base,
        .pool_free_list_index = pool_index,
    };
}

fn poolIndexToStackPages(index: usize) usize {
    return switch (index) {
        0 => 1,
        1 => 2,
        2 => 4,
        3 => 8,
        4 => 16,
        5 => 32,
        6 => 64,
        7 => 128,
        8 => 256,
        9 => 512,
        else => unreachable,
    };
}

test "stack reuse 4KiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack4KiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack4KiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}

test "stack reuse 8KiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack8KiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack8KiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}

test "stack reuse 16KiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack16KiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack16KiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}

test "stack reuse 32KiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack32KiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack32KiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}

test "stack reuse 64KiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack64KiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack64KiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}


test "stack reuse 128KiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack128KiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack128KiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}

test "stack reuse 256KiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack256KiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack256KiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}

test "stack reuse 512KiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack512KiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack512KiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}

test "stack reuse 1MiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack1MiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack1MiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
}

test "stack reuse 2MiB" {
    var stack_pool = try Pool.init(std.testing.allocator);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack2MiB();
    const addr1 = @intFromPtr(stack.vm_base_address);
    stack_pool.releaseStack(stack);

    const stack2 = try stack_pool.reserveStack2MiB();
    const addr2 = @intFromPtr(stack2.vm_base_address);
    stack_pool.releaseStack(stack2);

    try std.testing.expectEqual(addr1, addr2);
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

test "when a stack is deallocated, all pages should be munmap'ed" {
    var pool = try Pool.init(std.testing.allocator);
    const stack = try pool.reserveStack2MiB();
    pool.releaseStack(stack);
    pool.deinit();

    const ptr = @intFromPtr(stack.vm_base_address);
    for (0..(Stack.max_stack_size / system_page_size_bytes)) |i| {
        const probe: *anyopaque = @ptrFromInt(ptr + (system_page_size_bytes * i));
        try assertAddressNotMapped(probe);
    }
}

