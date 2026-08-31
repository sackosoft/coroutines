const std = @import("std");

const assert = std.debug.assert;

const cpu = @import("builtin").target.cpu.arch;
const backend = switch (cpu) {
    .x86_64 => @import("arch_x86_64.zig"),
    else => @compileError("Unsupported target CPU architecture: " ++ @tagName(cpu)),
};
const Stack = @import("Stack.zig");
const StackHeader = @import("StackHeader.zig");

pub const StackSize = enum { KiB_4, KiB_8, KiB_16, KiB_32, KiB_64, KiB_128, KiB_256, KiB_512, MiB_1, MiB_2 };
pub const CoroutineOptions = struct {
    stack_size: StackSize = .KiB_8,
};

pub const Coroutine = @This();

stack: Stack,

pub fn init(f: *const fn() void, options: CoroutineOptions) !Coroutine {
    const stack = try switch (options.stack_size) {
        .KiB_4 => Stack.create(1 * Stack.system_page_size_bytes),
        .KiB_8 => Stack.create(2 * Stack.system_page_size_bytes),
        .KiB_16 => Stack.create(4 * Stack.system_page_size_bytes),
        .KiB_32 => Stack.create(8 * Stack.system_page_size_bytes),
        .KiB_64 => Stack.create(16 * Stack.system_page_size_bytes),
        .KiB_128 => Stack.create(32 * Stack.system_page_size_bytes),
        .KiB_256 => Stack.create(64 * Stack.system_page_size_bytes),
        .KiB_512 => Stack.create(128 * Stack.system_page_size_bytes),
        .MiB_1 => Stack.create(256 * Stack.system_page_size_bytes),
        .MiB_2 => Stack.create(512 * Stack.system_page_size_bytes),
    };

    backend.setupBaseStackFrame(stack, f);

    return .{
        .stack = stack,
    };
}

pub fn yield() void {
    const header = backend.locate_header();
    assert(header.status == .running);
    header.status = .yielded;
    backend.ctx_switch(&header.coro_sp, header.ext_sp);
}

pub fn enter(coroutine: *Coroutine) void {
    const header = coroutine.stack.header();
    assert(header.status != .completed);
    assert(header.status != .running);
    header.status = .running;
    backend.ctx_switch(&header.ext_sp, header.coro_sp);
}

pub fn enter2(stack: Stack) StackHeader.Status {
    const header = stack.header();
    assert(header.status != .running);
    assert(header.status != .completed);
    header.status = .running;
    backend.ctx_switch(&header.ext_sp, header.coro_sp);
    assert(header.status != .running);
    assert(header.status != .created);
    return header.status;
}

const expected: u32 = 810812;
const initial: u32 = 123;
var test_val: u32 = initial;
fn setTestVal() void {
    test_val = expected;
}
fn setTestValAfterYield() void {
    Coroutine.yield();
    test_val = expected;
}
test "coroutine begin has observable side effects and returns to calling stack" {
    test_val = initial;

    var co = try Coroutine.init(setTestVal, .{});
    co.enter();
    try std.testing.expectEqual(expected, test_val);
}

test "coroutine yielded coroutine has no observabe side effects until restarted" {
    test_val = initial;

    var co = try Coroutine.init(setTestValAfterYield, .{});
    co.enter();
    try std.testing.expectEqual(initial, test_val);
    co.enter();
    try std.testing.expectEqual(expected, test_val);
}

var mutexLockThenYieldIo: std.Io = undefined;
var e1: std.Io.Event = undefined;
var e2: std.Io.Event = undefined;
var e3: std.Io.Event = undefined;
var mutexToCheckIfRunning: std.Io.Mutex = undefined;
var proceedToTestSignal: std.Io.Condition = undefined;
fn mutexLockThenYield() void {
    e2.set(mutexLockThenYieldIo);
    e1.wait(mutexLockThenYieldIo) catch unreachable;
    Coroutine.yield();
}
test "Coroutine should properly track all lifecycle statuses" {
    mutexLockThenYieldIo = std.testing.io;
    e1 = .unset;
    e2 = .unset;
    e3 = .unset;

    var co = try Coroutine.init(mutexLockThenYield, .{});
    try std.testing.expectEqual(.created, co.stack.header().status);

    const A = struct {
        fn enterCoroutineInBackground(coroutine: *Coroutine) !void {
            coroutine.enter();
            e3.set(mutexLockThenYieldIo);
        }
    };

    const t = try std.Thread.spawn(.{}, A.enterCoroutineInBackground, .{&co});
    try e2.wait(mutexLockThenYieldIo);
    try std.testing.expectEqual(.running, co.stack.header().status);

    e1.set(mutexLockThenYieldIo);
    try e3.wait(mutexLockThenYieldIo);
    try std.testing.expectEqual(.yielded, co.stack.header().status);
    std.Thread.join(t);

    co.enter();
    try std.testing.expectEqual(.completed, co.stack.header().status);
}
