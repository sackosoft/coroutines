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

    try rt.serve(
        "::",
        5200,
        echoServer,
        .{
            .address_kind = .ip6,
            .protocol = .tcp,
        },
    );
    rt.run();
}

fn echoServer() !void {
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
