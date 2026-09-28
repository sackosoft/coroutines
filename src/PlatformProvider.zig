const std = @import("std");
const builtin = @import("builtin");

const assert = std.debug.assert;

const PlatformProvider = @This();

const Kevent = std.c.Kevent;
comptime {
    if (Kevent == void) {
        @compileError(
            "Build target doesn't support `kqueue`: " //
            ++ @tagName(builtin.os.tag) //
            ++ ". For the MVP of the library, this is a hard dependency.");
    }
}

ptr: *anyopaque,
vtable: *const VTable,

pub const VTable = struct {
    kqueue: *const fn (ptr: *anyopaque) error.CreateFailed!i32,
    kevent: *const fn(
        ptr: *anyopaque,
        kq: i32,
        changelist: []const Kevent,
        eventlist: []Kevent,
        timeout_ns: i96,
    ) error.Failed!u32,
    close: *const fn(ptr: *anyopaque, fd: i32) void,
};

pub inline fn kqueue(this: *PlatformProvider) error.CreateFailed!i32 {
    return this.vtable.kqueue(this.ptr);
}

pub inline fn kevent(
    this: *PlatformProvider,
    kq: i32,
    changelist: []const Kevent,
    eventlist: []Kevent,
    timeout_ns: i96,
) error.Failed![]Kevent {
    const ret = try this.vtable.kevent(
        this.ptr,
        kq,
        changelist.ptr,
        changelist.len,
        eventlist.ptr,
        eventlist.len,
        timeout_ns,
    );
    return eventlist[0..ret];
}

pub inline fn close(this: *PlatformProvider, fd: i32) void {
    return this.vtable.close(this.ptr, fd);
}

pub const libc_instance: PlatformProvider = .{
    .vtable = .{
        .kqueue = libc_kqueue,
        .kevent = libc_kevent,
        .close = libc_close,
    }
};

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

