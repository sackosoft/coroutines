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

    const tcpListener = try rt.listenTcpIp6(8164, 128, .{});
    defer std.c.close(tcpListener.fd);

    try rt.spawnWithError(acceptAndDispatch, .{&rt, &tcpListener});
    try rt.run();
}

fn acceptAndDispatch() !void {
    const rt = Coroutine.arg0(*Runtime);
    const tcpListener = Coroutine.arg1(*TcpListener);

    while (true) {
        // How should the suspention happen? Ultimately, it will need to be a yield
        // + one time registration in the io reactor. Then resumed by the runtime
        // when that registration has an event. Should the TcpListener already be
        // registered in the runtime? That makes sense to me, but there is no association
        // with the Coroutine in that code path. So then I need something like `rt.accept(tcpListener,
        // acceptAndDispatch, .{&rt})` as a different kind of `spawn`. It will have
        // the same problem, though, the function handle is not a coroutine. That
        // leads me back to this location where we need a way to ask the runtime to
        // do the registration and suspend us until the event occurs.
        const connection = rt.accept(tcpListener);
        try rt.spawnWithError(echo, .{connection});
    }
}

fn echo() !void {
}

