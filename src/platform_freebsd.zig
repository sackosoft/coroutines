const std = @import("std");

const assert = std.debug.assert;

const PlatformProvider = @import("PlatformProvider.zig");

const kevent_list_width = 256;
const Platform = @This();

alloc: std.mem.Allocator,
pp: PlatformProvider,
kq: i32,
change_list: []std.c.Kevent,
event_list: []std.c.Kevent,

pub fn init(pp: PlatformProvider, alloc: std.mem.Allocator) !Platform {
    const kq = try pp.kqueue();
    return .{
        .alloc = alloc,
        .pp = pp,
        .kq = kq,
        .change_list = try alloc.alloc(std.c.Kevent, kevent_list_width),
        .event_list = try alloc.alloc(std.c.Kevent, kevent_list_width),
    };
}

pub fn deinit(this: Platform) void {
    this.pp.close(this.kq);
    this.alloc.free(this.change_list);
    this.alloc.free(this.event_list);
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
pub fn dequeueCompletions(this: *Platform, timeout_ns: i96) !CompletionIterator {
    const notifications = try this.pp.kevent(
        this.kq,
        this.change_list[0..0], // TODO: Slice only the pending events.
        this.event_list,
        timeout_ns,
    );
    return .{
        .index = 0,
        .slice = notifications,
    };
}
