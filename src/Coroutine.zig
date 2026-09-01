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
    stack_size: StackSize = .KiB_128,
};

pub const Coroutine = @This();

stack: Stack,

pub fn create(f: *const fn() void, args: anytype, options: CoroutineOptions) !Stack {
    const ArgsType = @TypeOf(args);
    const args_type_info = @typeInfo(ArgsType);
    if (args_type_info != .@"struct") {
        @compileError("expected tuple or struct argument, found " ++ @typeName(ArgsType));
    }

    const stack = try createStack(options);
    backend.setupBaseStackFrame(stack, f, args);
    return stack;
}

fn createStack(options: CoroutineOptions) !Stack {
    return try switch (options.stack_size) {
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
}

pub fn yield() void {
    const header = backend.locate_header();
    assert(header.status == .running);
    header.status = .yielded;
    assert(header.ext_sp != null);
    backend.ctx_switch(&header.coro_sp, &header.ext_sp);
}

pub fn enter(stack: Stack) StackHeader.Status {
    const header = stack.header();
    assert(header.status != .running);
    assert(header.status != .completed);
    assert(header.status != .waiting);
    header.status = .running;
    assert(header.ext_sp == null);
    assert(header.coro_sp != null);
    backend.ctx_switch(&header.ext_sp, &header.coro_sp);
    assert(header.status != .running);
    assert(header.status != .created);
    return header.status;
}

pub fn arg0(T: type) T {
    return argInternal(T, 0);
}

pub fn arg1(T: type) T {
    return argInternal(T, 1);
}

pub fn arg2(T: type) T {
    return argInternal(T, 2);
}

pub fn arg3(T: type) T {
    return argInternal(T, 3);
}

fn argInternal(T: type, index: usize) T {
    comptime assert(@sizeOf(T) <= @sizeOf(usize));
    const header = backend.locate_header();
    assert(index < header.args.len);

    return switch (@typeInfo(T)) {
        .bool, .int, .float, .pointer, .@"struct", .comptime_float, .comptime_int, .@"enum", .optional,
        => @as(*T, @ptrCast(&header.args[index])).*,

        .type, .void, .noreturn, .array, .undefined, .null, .error_union, .error_set,
        .@"union", .@"fn", .@"opaque", .frame, .@"anyframe", .vector, .enum_literal,
        => {
            @compileError("Unsupported coroutine argument: " ++ @typeName(T));
        },
    };
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

    const stack = try Coroutine.create(setTestVal, .{}, .{});
    const status = Coroutine.enter(stack);
    try std.testing.expectEqual(expected, test_val);
    try std.testing.expectEqual(.completed, status);
}

test "coroutine yielded coroutine has no observabe side effects until restarted" {
    test_val = initial;

    const stack = try Coroutine.create(setTestValAfterYield, .{}, .{});
    var status: StackHeader.Status = undefined;
    status = Coroutine.enter(stack);
    try std.testing.expectEqual(initial, test_val);
    try std.testing.expectEqual(.yielded, status);
    status = Coroutine.enter(stack);
    try std.testing.expectEqual(expected, test_val);
    try std.testing.expectEqual(.completed, status);
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

    var stack = try Coroutine.create(mutexLockThenYield, .{}, .{});
    try std.testing.expectEqual(.created, stack.header().status);

    const A = struct {
        fn enterCoroutineInBackground(s: Stack) !void {
            const status = Coroutine.enter(s);
            try std.testing.expectEqual(.yielded, status);
            e3.set(mutexLockThenYieldIo);
        }
    };

    const t = try std.Thread.spawn(.{}, A.enterCoroutineInBackground, .{stack});
    try e2.wait(mutexLockThenYieldIo);
    try std.testing.expectEqual(.running, stack.header().status);

    e1.set(mutexLockThenYieldIo);
    try e3.wait(mutexLockThenYieldIo);
    try std.testing.expectEqual(.yielded, stack.header().status);
    std.Thread.join(t);

    const status = Coroutine.enter(stack);
    try std.testing.expectEqual(.completed, status);
    try std.testing.expectEqual(.completed, stack.header().status);
}

fn empty() void {
}
test "Coroutines should manage ext_sp and coro_sp as optional pointers" {
    const stack = try Coroutine.create(empty, .{}, .{});
    try std.testing.expect(stack.header().ext_sp == null);
    try std.testing.expect(stack.header().coro_sp != null);
    const coro_sp = @intFromPtr(stack.header().coro_sp.?);
    try std.testing.expect(coro_sp > @intFromPtr(stack.vm_base_address));
    try std.testing.expect(coro_sp < (@intFromPtr(stack.vm_base_address) + Stack.max_stack_size));

    const actual = Coroutine.enter(stack);
    try std.testing.expectEqual(.completed, actual);
    try std.testing.expect(stack.header().ext_sp == null);
    try std.testing.expect(stack.header().coro_sp == null);
}

const SmallStruct = struct {
    a: u32,
    b: u32,
};
var capturedArg0: ?*anyopaque = undefined;
var capturedArg1: usize = undefined;
var capturedArg2: SmallStruct = undefined;
var capturedArg3: u18 = undefined;
fn coroWithArgs() void {
    capturedArg0 = Coroutine.arg0(@TypeOf(capturedArg0));
    capturedArg1 = Coroutine.arg1(@TypeOf(capturedArg1));
    capturedArg2 = Coroutine.arg2(@TypeOf(capturedArg2));
    capturedArg3 = Coroutine.arg3(@TypeOf(capturedArg3));
}
test "Coroutines should support passing arguments via stack header state (argN() functions)" {
    capturedArg0 = null;
    capturedArg1 = 0;
    capturedArg2 = .{ .a = 0, .b = 0 };
    capturedArg3 = 0;

    const expectedArg0: ?*anyopaque = @ptrFromInt(0x0012417a);
    const expectedArg1: usize = 5813891235;
    const expectedArg2: SmallStruct = .{ .a = 12489, .b = 6819812 };
    const expectedArg3: u18 = 69420;

    const stack = try Coroutine.create(
        coroWithArgs,
        .{ expectedArg0, expectedArg1, expectedArg2, expectedArg3, },
        .{}
    );
    const status = Coroutine.enter(stack);

    try std.testing.expectEqual(.completed, status);
    try std.testing.expectEqual(expectedArg0, capturedArg0);
    try std.testing.expectEqual(expectedArg1, capturedArg1);
    try std.testing.expectEqual(expectedArg2, capturedArg2);
    try std.testing.expectEqual(expectedArg3, capturedArg3);
}
