const std = @import("std");

pub fn main() !void {
    const c = std.c;

    var address: c.sockaddr.in6 = .{
        .port = std.mem.nativeToBig(u16, 8182),
        .flowinfo = 0,
        .addr = @splat(0),
        .scope_id = 0,
    };

    const fd = c.socket(
        c.AF.INET6,
        c.SOCK.STREAM | c.SOCK.NONBLOCK | c.SOCK.CLOEXEC,
        c.IPPROTO.TCP,
    );

    var enabled: c_int = 1;
    _ = c.setsockopt(
        fd,
        c.SOL.SOCKET,
        c.SO.REUSEADDR,
        &enabled,
        @sizeOf(c_int),
    );

    _ = c.setsockopt(
        fd,
        c.IPPROTO.IPV6,
        c.IPV6.V6ONLY,
        &enabled,
        @sizeOf(c_int),
    );

    _ = c.bind(fd, @ptrCast(&address), @sizeOf(c.sockaddr.in6));
    _ = c.listen(fd, 128);
}
