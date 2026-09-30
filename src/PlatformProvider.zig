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
    kqueue: *const fn (ptr: *anyopaque) error{CreateFailed}!i32,
    kevent: *const fn(
        ptr: *anyopaque,
        kq: i32,
        changelist: []const Kevent,
        eventlist: []Kevent,
        timeout_ns: i96,
    ) error{Failed}!u32,
    close: *const fn(ptr: *anyopaque, fd: i32) void,
};

pub inline fn kqueue(this: *const PlatformProvider) error{CreateFailed}!i32 {
    return this.vtable.kqueue(this.ptr);
}

pub inline fn kevent(
    this: *const PlatformProvider,
    kq: i32,
    changelist: []const Kevent,
    eventlist: []Kevent,
    timeout_ns: i96,
) error{Failed}![]Kevent {
    const ret = try this.vtable.kevent(
        this.ptr,
        kq,
        changelist,
        eventlist,
        timeout_ns,
    );
    assert(ret <= eventlist.len);
    return eventlist[0..ret];
}

pub inline fn close(this: *const PlatformProvider, fd: i32) void {
    return this.vtable.close(this.ptr, fd);
}
