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
}

const StackHeader = struct {
    caller_sp: *anyopaque,
};

const Stack = struct {
    vm_base_address: *anyopaque,
    pool_free_list: *FreeList,

    pub fn top(this: *Stack) *anyopaque {
        const ceil = @intFromPtr(this.ceiling());
        return @ptrFromInt(ceil - @sizeOf(StackHeader));
    }

    pub fn header(this: *Stack) *StackHeader {
        const head: [*]StackHeader = @ptrCast(this.ceiling());
        head -= 1;
        return @ptrCast(head);
    }

    pub fn free(this: *Stack) !void {
        var ret = mman.madvise(
            this.vm_base_address,
            max_stack_size,
            mman.MADV_FREE
        );

        if (ret != 0) {
            // Avoid deep stack frames not getting cleaned up and "leaking"
            // physical pages of memory that are not used.
            ret = mman.munmap(this.vm_base_address, max_stack_size);
            if (ret != 0) {
                return error.MadvAndMunmapFailed;
            }

            return;
        }

        var free_list = this.pool_free_list;
        var node = try free_list.parent_pool.alloc.create(FreeListNode);
        node.stack = this.*;
        node.next = free_list.free_list;
        free_list.free_list = node;
        free_list.count += 1;
    }

    /// Returns the max_stack_size-aligned boundary of the highest address of the given
    /// virtual memory mapping.
    fn ceiling(stack: *Stack) *anyopaque {
        const base = @intFromPtr(stack.vm_base_address);
        assert(base % max_stack_size == 0);
        return @ptrFromInt(base + max_stack_size);
    }
};

const FreeListNode = struct {
    stack: Stack,
    next: ?*FreeListNode,
};

const FreeList = struct {
    count: usize = 0,
    free_list: ?*FreeListNode = null,
    parent_pool: *StackPool = undefined,
};

pub const StackPool = struct {
    alloc: std.mem.Allocator,
    free_lists: [11]FreeList = .{.{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}, .{}},

    pub fn init(alloc: std.mem.Allocator) !*StackPool {
        var stack_pool = try alloc.create(StackPool);
        stack_pool.alloc = alloc;
        for (0..stack_pool.free_lists.len) |i| {
            stack_pool.free_lists[i].parent_pool = stack_pool;
        }
        return stack_pool;
    }

    pub fn deinit(this: *StackPool) void {
        for (0..this.free_lists.len) |i| {
            var node = this.free_lists[i].free_list;
            while (node != null) {
                const n = node.?;
                node = n.next;
                this.alloc.destroy(n);
            }
        }
        this.alloc.destroy(this);
    }

    pub fn reserveStack4KiB(this: *StackPool) !Stack {
        return this.reserve(1);
    }

    pub fn reserveStack8KiB(this: *StackPool) !Stack {
        return this.reserve(2);
    }

    pub fn reserveStack16KiB(this: *StackPool) !Stack {
        return this.reserve(4);
    }

    pub fn reserveStack32KiB(this: *StackPool) !Stack {
        return this.reserve(8);
    }

    pub fn reserveStack64KiB(this: *StackPool) !Stack {
        return this.reserve(16);
    }

    pub fn reserveStack128KiB(this: *StackPool) !Stack {
        return this.reserve(32);
    }

    pub fn reserveStack256KiB(this: *StackPool) !Stack {
        return this.reserve(64);
    }

    pub fn reserveStack512KiB(this: *StackPool) !Stack {
        return this.reserve(128);
    }

    pub fn reserveStack1MiB(this: *StackPool) !Stack {
        return this.reserve(256);
    }

    pub fn reserveStack2MiB(this: *StackPool) !Stack {
        return this.reserve(512);
    }

    fn reserve(this: *StackPool, usable_stack_pages: u9) !Stack {
        assert(usable_stack_pages > 0);

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
        const stack_size_bytes: usize = usable_stack_pages * system_page_size_bytes;
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
            .pool_free_list = &this.free_lists[base2LogToIndex(usable_stack_pages)],
        };
    }

    fn base2LogToIndex(b: u9) usize {
        return switch (b) {
            1 => 0,
            2 => 1,
            4 => 2,
            8 => 3,
            16 => 4,
            32 => 5,
            64 => 6,
            128 => 7,
            256 => 8,
            512 => 9,
            1024 => 10,
            2048 => 11,
            _ => unreachable,
        };
    }
};
