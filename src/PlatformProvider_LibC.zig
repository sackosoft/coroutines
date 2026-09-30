const std = @import("std");
const builtin = @import("builtin");

const assert = std.debug.assert;

const PlatformProvider = @import("PlatformProvider.zig");
const Kevent = std.c.Kevent;
comptime {
    if (Kevent == void) {
        @compileError(
            "Build target doesn't support `kqueue`: " //
            ++ @tagName(builtin.os.tag) //
            ++ ". For the MVP of the library, this is a hard dependency.");
    }
}

pub fn provider() PlatformProvider {
    return .{
        .ptr = undefined,
        .vtable = .{
            .kqueue = libc_kqueue,
            .kevent = libc_kevent,
            .close = libc_close,
        }
    };
}

fn libc_kqueue(ptr: *anyopaque) error.CreateFailed!i32 {
    _ = ptr;
    const kq = std.c.kqueue();
    if (kq < 0) {
        return error.CreateFailed;
    }
    return kq;
}

fn libc_kevent(
    ptr: *anyopaque,
    kq: i32,
    changelist: []const Kevent,
    eventlist: []Kevent,
    timeout_ns: i96,
) error.Failed!u32 {
    _ = ptr;
    const timeout: std.c.timespec = .{
        .sec = @intCast(@divTrunc(timeout_ns, std.time.ns_per_s)),
        .nsec = @intCast(@mod(timeout_ns, std.time.ns_per_s)),
    };
    const ret = std.c.kevent(
        kq,
        changelist.ptr,
        changelist.len,
        eventlist.ptr,
        eventlist.len,
        &timeout
    );
    if (ret < 0) {
        return error.Failed;
    }
    return @intCast(ret);
}

fn libc_close(ptr: *anyopaque, fd: i32) void {
    _ = ptr;
    const ret = std.c.close(fd);
    assert(ret == 0);
}

