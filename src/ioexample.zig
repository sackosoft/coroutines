const std = @import("std");

const assert = std.debug.assert;
const print = std.debug.print;

const Runtime = @import("Runtime.zig");
const Coroutine = @import("Coroutine.zig");

const inet = @import("bindings/arpa/inet.zig");
const socket = @import("bindings/sys/socket.zig");
const event = @import("bindings/sys/event.zig");

pub fn main(init: std.process.Init) !void {
    var rt: Runtime = try .initDefault(init.gpa);
    defer rt.deinit();

    // try rt.serve(
    //     "::",
    //     5200,
    //     echoServer,
    //     .{
    //         .address_kind = .ip6,
    //         .protocol = .tcp,
    //     },
    // );
    // rt.run();
    try rt.spawn(listener, .{&rt});
    try rt.run();
}

const max_concurrent_connections = 128;

// TODO: Create Fixed buffer (n = allowed number of connecting clients) for origin address of incoming connections
// TODO: Create counter variable of "hot" connections (incoming connections not yet handed off to a separate coroutine
// for handling).
// Listener will hand over the address of a slot in the buffer and the address of active connections variable when
// spawning coroutine to handle the connection. Spawned coroutine will read from that address (probably save locally to
// its stack) then clear the slot and atomic decrement the connection counter.
var originAddresses: [max_concurrent_connections]socket.struct_sockaddr = undefined;
var originCount: usize = 0;

fn listener() !void {
    const runtime: *Runtime = Coroutine.arg0(*Runtime);

    // create socket
    // setsockopt
    // init sockaddr
    // bind socket to sockaddr
    // listen
    // register kevent
    // accept
    const listenSocket = socket.socket(
        socket.PF_INET6,
        socket.SOCK_STREAM | socket.SOCK_NONBLOCK | socket.SOCK_CLOEXEC,
        socket.IPPROTO_TCP,
    );

    if (listenSocket < 0) {
        return error.SocketFailure;
    }

    const enabled: c_int = 1;
    if (0 != socket.setsockopt(listenSocket, socket.SOL_SOCKET, socket.SO_REUSEADDR, &enabled, 1)) {
        return error.SetSockOptReuseAddr;
    }

    const addr: std.c.sockaddr.in6 = .{
        .port = inet.htons(8182),
        .flowinfo = 0,
        .addr = std.mem.zeroes([16]u8),
        .scope_id = 0,
    };
    if (0 != socket.bind(listenSocket, @ptrCast(&addr), @sizeOf(std.c.sockaddr.in6))) {
        return error.SocketBindToAddress;
    }

    // register EVFILT_READ + EV_ADD for the given socket
    // yield until active
    // Coroutine.accept(listenSocket);

    try Coroutine.listen(listenSocket, max_concurrent_connections);
    while (true) {
        Coroutine.accept();
        const originAddress: [*c]socket.struct_sockaddr = @ptrCast(&originAddresses[originCount]);
        var socklen: socket.socklen_t = undefined;
        const connectionSocket = socket.accept(listenSocket, originAddress, &socklen);
        if (connectionSocket < 0) {
            return error.SocketAccept;
        } else {
            originCount += 1;
            runtime.spawn(echoServer, .{connectionSocket, originAddress, &originCount});
        }
    }
}

fn echoServer() !void {
    var buffer: [1024]u8 = undefined;
    const client_fd = Coroutine.arg0(std.c.fd_t);
    defer {
        const ret = std.c.close(client_fd);
        assert(ret == 0);
    }
    const originAddressPtr = Coroutine.arg0(*?socket.struct_sockaddr);
    const originAddress = originAddressPtr.*;
    originAddressPtr.* = null;
    const client_fd = Coroutine.arg0(std.c.fd_t);

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
