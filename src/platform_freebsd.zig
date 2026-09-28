const std = @import("std");

const assert = std.debug.assert;

const kevent_list_width = 256;

const Platform = @This();

alloc: std.mem.Allocator,
kq: c_int,
change_list: []std.c.Kevent,
event_list: []std.c.Kevent,

pub fn init(alloc: std.mem.Allocator) !Platform {
    const kq = std.c.kqueue();
    if (kq < 0) {
        return error.KQueueCreate;
    }

    return .{
        .alloc = alloc,
        .kq = kq,
        .change_list = try alloc.alloc(std.c.Kevent, kevent_list_width),
        .event_list = try alloc.alloc(std.c.Kevent, kevent_list_width),
    };
}

pub fn deinit(this: *Platform) void {
    this.alloc.free(this.change_list);
    this.alloc.free(this.event_list);

    const ret = std.c.close(this.kq);
    assert(ret == 0);
}

pub const CompletionIterator = struct {
    index: usize,
    slice: []std.c.Kevent,

    pub fn next(this: *CompletionIterator) ?std.c.Kevent {
        const i = this.index;
        this.index += 1;
        return if (i < this.slice.len) this.slice[i] else null;
    }
};
pub fn dequeueCompletions(this: *Platform, timeout_nanoseconds: i96) !CompletionIterator {
    const timeout: std.c.timespec = .{
        .sec = @intCast(@divTrunc(timeout_nanoseconds, std.time.ns_per_s)),
        .nsec = @intCast(@mod(timeout_nanoseconds, std.time.ns_per_s)),
    };
    const ret = std.c.kevent(
        this.kq,
        this.change_list.ptr,
        0,
        this.event_list.ptr,
        kevent_list_width,
        &timeout,
    );
    if (ret < 0) {
        return error.KEvent;
    }

    const nevents: usize = @intCast(ret);
    return .{
        .index = 0,
        .slice = this.event_list[0..nevents],
    };
}
