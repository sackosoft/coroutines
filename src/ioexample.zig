const std = @import("std");

const assert = std.debug.assert;
const print = std.debug.print;

const Runtime = @import("Runtime.zig");
const Coroutine = @import("Coroutine.zig");

const socket = @import("bindings/sys/socket.zig");
const event = @import("bindings/sys/event.zig");

pub fn main(init: std.process.Init) !void {
    var rt: Runtime = try .initDefault(init.gpa);
    defer rt.deinit();

    const srvsock = socket.socket(
        socket.PF_INET6,
        socket.SOCK_STREAM | socket.SOCK_NONBLOCK | socket.SOCK_CLOEXEC,
        0,
    );
    if (srvsock < 0) {
        print("Unable to open socket, errno={d}\n", .{errno()});
        return error.Socket;
    }
    defer std.c.close(@intCast(srvsock));

    const reuse_addr: c_int = 1;
    var ret = undefined;
    ret = socket.setsockopt(srvsock, socket.SOL_SOCKET, socket.SO_REUSEADDR, &reuse_addr, 1);
    if (ret != 0) {
        print("Unable to setsockopt(SO_REUSEADDR), errno={d}\n", .{errno()});
        return error.SetSockOpt;
    }

    // TODO: Not sure how to initialize for ip6
    const addr: socket.struct_sockaddr = undefined;

    try rt.listen(srvsock, echo, .{});
    rt.run();
}

fn echo() !void {
    var buffer: [1024]u8 = undefined;
    const client_fd = Coroutine.arg0(std.c.fd_t);
    defer {
        const ret = std.c.close(client_fd);
        assert(ret == 0);
    }

    const received = std.c.recv(client_fd, &buffer, buffer.len, 0);
    if (received < 0) {
        return error.RecvFailed;
    }
    if (received == 0) {
        return error.EmptyRecv;
    }

    const sent = std.c.send(client_fd, &buffer, received, std.c.MSG.NOSIGNAL);
    if (sent < 0) {
        return error.SendFailed;
    }
    if (sent != received) {
        return error.EchoTruncated;
    }
}

fn errno() i32 {
    return @intCast(std.c._errno().*);
}
