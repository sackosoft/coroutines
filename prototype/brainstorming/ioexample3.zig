const std = @import("std");

const assert = std.debug.assert;
const print = std.debug.print;

const Runtime = @import("Runtime.zig");
const Coroutine = @import("Coroutine.zig");

const TcpListener = Runtime.TcpListener;

const inet = @import("bindings/arpa/inet.zig");
const socket = @import("bindings/sys/socket.zig");
const event = @import("bindings/sys/event.zig");

pub fn main(init: std.process.Init) !void {
    var rt: Runtime = try .initDefault(init.gpa);
    defer rt.deinit();

    const server_socket = std.c.socket(
        std.c.AF.INET6,
        std.c.SOCK.STREAM | std.c.SOCK.NONBLOCK | std.c.SOCK.CLOEXEC,
        std.c.IPPROTO.TCP,
    );
    if (server_socket < 0) {
        return error.SocketCreate;
    }
    defer std.c.close(server_socket);

    var ret = std.c.bind(server_socket, ...);
    if (ret < 0) {
        return error.SocketBind;
    }
    ret = std.c.listen(server_socket, 128);
    if (ret < 0) {
        return error.SocketListen;
    }

    try rt.spawnWithError(acceptAndDispatch, .{server_socket});
    try rt.run();
}

fn acceptAndDispatch() !void {
    const server_socket = Coroutine.arg0(fd_t);

    while (true) {
        const connection = Coroutine.accept(server_socket);
        try rt.spawnWithError(echo, .{connection});
    }
}

fn echo() !void {
}

