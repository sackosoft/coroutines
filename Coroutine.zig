const std = @import("std");
const StackPool = @import("StackPool.zig");

const assert = std.debug.assert;

const cpu = @import("builtin").target.cpu.arch;
const backend = switch (cpu) {
    .x86_64 => @import("arch_x86_64.zig"),
    else => @compileError("Unsupported target CPU architecture: " + @tagName(cpu)),
};

const Stack = @import("Stack.zig").Stack;
const Pool = @import("Pool.zig");
const GlobalPool = &Pool.GlobalPool;

pub const StackSize = enum { KiB_4, KiB_8, KiB_16, KiB_32, KiB_64, KiB_128, KiB_256, KiB_512, MiB_1, MiB_2 };
pub const CoroutineOptions = struct {
    stack_size: StackSize = .KiB_8,
};

pub const Coroutine = struct {
    stack: Stack,

    pub fn init(f: *const fn() void, options: CoroutineOptions) !Coroutine {
        const stack = try switch (options.stack_size) {
            .KiB_4 => GlobalPool.reserveStack4KiB(),
            .KiB_8 => GlobalPool.reserveStack8KiB(),
            .KiB_16 => GlobalPool.reserveStack16KiB(),
            .KiB_32 => GlobalPool.reserveStack32KiB(),
            .KiB_64 => GlobalPool.reserveStack64KiB(),
            .KiB_128 => GlobalPool.reserveStack128KiB(),
            .KiB_256 => GlobalPool.reserveStack256KiB(),
            .KiB_512 => GlobalPool.reserveStack512KiB(),
            .MiB_1 => GlobalPool.reserveStack1MiB(),
            .MiB_2 => GlobalPool.reserveStack2MiB(),
        };

        backend.setupBaseStackFrame(stack, f);

        return .{
            .stack = stack,
        };
    }

    pub fn coroutine_suspend(coroutine: *Coroutine) void {
        const header = coroutine.stack.header();
        backend.ctx_switch(&header.saved_stack_pointer, header.caller_stack_pointer);
    }

    pub fn coroutine_resume(coroutine: *Coroutine) void {
        const header = coroutine.stack.header();
        backend.ctx_switch(&header.caller_stack_pointer, header.saved_stack_pointer);
    }
};

const expected: u32 = 810812;
var test_val: u32 = 0;
fn setTestVal() void {
    test_val = expected;
}
test "coroutine suspend" {
    var co = try Coroutine.init(setTestVal, .{});
    co.coroutine_resume();
    try std.testing.expectEqual(expected, test_val);
}
