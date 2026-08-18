const std = @import("std");
const mman = @import("bindings/sys/mman.zig");

const assert = std.debug.assert;
const print = std.debug.print;

const system_page_size_bytes: usize = 4096;
const max_stack_base_2_log: usize = 21;
const max_stack_size: usize = 1 << max_stack_base_2_log;

pub fn main(init: std.process.Init) !void {
    var stack_pool = try StackPool.init(init.gpa);
    defer stack_pool.deinit();

    const stack = try stack_pool.reserveStack4KiB();
    defer stack_pool.releaseStack(stack);
}

const StackHeader = struct {
    caller_sp: *anyopaque,
};

const Stack = struct {
    vm_base_address: *anyopaque,
    pool_free_list_index: usize,

    pub fn header(this: *Stack) *StackHeader {
        const head: [*]StackHeader = @ptrCast(this.ceiling());
        head -= 1;
        return @ptrCast(head);
    }

    pub fn top(this: *Stack) *anyopaque {
        const ceil = @intFromPtr(this.ceiling());
        return @ptrFromInt(ceil - @sizeOf(StackHeader));
    }

    /// Returns the max_stack_size-aligned boundary of the highest address of the given
    /// virtual memory mapping.
    fn ceiling(stack: *Stack) *anyopaque {
        const base = @intFromPtr(stack.vm_base_address);
        assert(base % max_stack_size == 0);
        return @ptrFromInt(base + max_stack_size);
    }
};

const FreeList = struct {
    count: usize = 0,
    free_stacks: [1024]?Stack = undefined,
};

pub const StackPool = struct {
    alloc: std.mem.Allocator,
    free_lists: [10]FreeList = undefined,

    pub fn init(alloc: std.mem.Allocator) !*StackPool {
        const this = try alloc.create(StackPool);
        this.* = StackPool{
            .alloc = alloc,
            .free_lists = .{.{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}},
        };

        for (0 .. this.free_lists.len) |i| {
            @memset(this.free_lists[i].free_stacks[0..], null);
        }
        return this;
    }

    pub fn deinit(this: *StackPool) void {
        for (0..this.free_lists.len) |i| {
            const size: usize = system_page_size_bytes * std.math.pow(usize, 2, i);

            const free_stacks: []?Stack = this.free_lists[i].free_stacks[0..];
            for (free_stacks) |free_stack| {
                if (free_stack) |fs| {
                    const ret = mman.munmap(fs.vm_base_address, size);
                    assert(ret == 0); // munmap should hopefully never fail
                }
            }
            @memset(free_stacks, null);
        }
        this.alloc.destroy(this);
    }

    pub fn reserveStack4KiB(this: *StackPool) !Stack {
        return this.reserve(0);
    }

    pub fn reserveStack8KiB(this: *StackPool) !Stack {
        return this.reserve(1);
    }

    pub fn reserveStack16KiB(this: *StackPool) !Stack {
        return this.reserve(2);
    }

    pub fn reserveStack32KiB(this: *StackPool) !Stack {
        return this.reserve(3);
    }

    pub fn reserveStack64KiB(this: *StackPool) !Stack {
        return this.reserve(4);
    }

    pub fn reserveStack128KiB(this: *StackPool) !Stack {
        return this.reserve(5);
    }

    pub fn reserveStack256KiB(this: *StackPool) !Stack {
        return this.reserve(6);
    }

    pub fn reserveStack512KiB(this: *StackPool) !Stack {
        return this.reserve(7);
    }

    pub fn reserveStack1MiB(this: *StackPool) !Stack {
        return this.reserve(8);
    }

    pub fn reserveStack2MiB(this: *StackPool) !Stack {
        return this.reserve(9);
    }

    pub fn releaseStack(this: *StackPool, stack: Stack) void {
        var free_list = this.free_lists[stack.pool_free_list_index];

        if (free_list.count == free_list.free_stacks.len) {
            const size: usize = system_page_size_bytes * std.math.pow(usize, 2, stack.pool_free_list_index);
            const ret = mman.munmap(stack.vm_base_address, size);
            assert(ret == 0);
            return;
        } else {
            const ret = mman.madvise(
                stack.vm_base_address,
                max_stack_size,
                mman.MADV_FREE,
            );
            assert(ret == 0);
        }

        free_list.count += 1;
        for (0..free_list.free_stacks.len) |i| {
            if (free_list.free_stacks[i] == null) {
                free_list.free_stacks[i] = stack;
                return;
            }
        }

        unreachable;
    }

    fn reserve(this: *StackPool, pool_index: usize) !Stack {
        assert(pool_index < this.free_lists.len);

        var free_list = this.free_lists[pool_index];
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

        if (maybePtr == null) {
            return error.VirtualMemoryAllocate;
        }

        const mmap_base = maybePtr.?;
        const stack_size_bytes: usize = poolIndexToStackPages(pool_index) * system_page_size_bytes;
        assert(stack_size_bytes < max_stack_size);

        const bottom_of_usable_stack_pages = @intFromPtr(mmap_base) + (max_stack_size - stack_size_bytes);
        const mprotect_flags = mman.PROT_READ | mman.PROT_WRITE;

        // Change the protection for the user-specified number of pages at the top of the
        // address range which will act as the "real" usable stack pages.
        const ret = mman.mprotect(
            @ptrFromInt(bottom_of_usable_stack_pages),
            stack_size_bytes,
            mprotect_flags,
        );

        if (ret != 0) {
            return error.VirtualMemoryProtect;
        }

        return .{
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
};
