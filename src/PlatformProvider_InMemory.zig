const std = @import("std");
const builtin = @import("builtin");

const assert = std.debug.assert;

const PlatformProvider = @import("PlatformProvider.zig");

const PlatformProviderContext = struct {
    i: usize,
    fds: [32]bool, // false == closed handle, true == opened handle
    clock: *i64,
};
var pp_ctx: PlatformProviderContext = .{
    .i = 0,
    .fds = std.mem.zeroes([32]bool),
    .clock = undefined,
};

pub fn provider(clock: *i64) PlatformProvider {
    pp_ctx.clock = clock;
    return .{
        .ptr = &pp_ctx,
        .vtable = &.{
            .kqueue = dummy_kqueue,
            .kevent = dummy_kevent,
            .close = dummy_close,
        }
    };
}

fn dummy_kqueue(ptr: *anyopaque) error{CreateFailed}!i32 {
    var ppc: *PlatformProviderContext = @ptrCast(@alignCast(ptr));
    ppc.i += 1;
    const kq = ppc.i;
    ppc.fds[kq] = true;
    assert(kq > 0);
    assert(kq <= std.math.maxInt(i32));
    return @intCast(kq);
}

fn dummy_kevent(
    ptr: *anyopaque,
    kq: i32,
    changelist: []const std.c.Kevent,
    eventlist: []std.c.Kevent,
    timeout_ns: i96,
) error{Failed}!u32 {
    const ppc: *PlatformProviderContext = @ptrCast(@alignCast(ptr));
    assert(kq > 0);
    if (ppc.fds[@as(usize, @intCast(kq))] != true) {
        return error.Failed;
    }

    // TODO: Make the wait behavior conditional on how many results are avaialble.
    ppc.clock.* += @intCast(timeout_ns);

    _ = changelist;
    _ = eventlist;
    return 0;
}

fn dummy_close(ptr: *anyopaque, fd: i32) void {
    var ppc: *PlatformProviderContext = @ptrCast(@alignCast(ptr));
    assert(fd > 0);
    const index: usize = @intCast(fd);
    assert(ppc.fds[index]);
    ppc.fds[index] = false;
}
