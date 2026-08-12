const std = @import("std");

const assert = std.debug.assert;
const print = std.debug.print;

const setjmp = @import("bindings/setjmp.zig");
const jmpbuf = setjmp.struct__jmp_buf;

var loop: jmpbuf = undefined;
var delay: jmpbuf = undefined;

pub fn main(init: std.process.Init) !void {
    _ = init;

    const expected: c_int = 42;

    const ret = setjmp.setjmp(&loop);
    if (ret == 0) {
        print("Begin.\n", .{});
        const actual = delay_async(expected);
        print("End. Expected = {d}, Actual = {d}\n", .{expected, actual});
    } else {
        assert(ret == 99);
        setjmp.longjmp(&delay, 99);
        unreachable;
    }
}

fn delay_async(expected: c_int) c_int {
    print("[delay_async] entered.\n", .{});
    const ret = setjmp.setjmp(&delay);
    if (ret == 0) {
        print("[delay_async] longjumping to loop.\n", .{});
        setjmp.longjmp(&loop, 99);
        unreachable;
    } else {
        print("[delay_async] resumed.\n", .{});
        assert(ret == 99);
        print("[delay_async] about to return: segfault occurs next\n", .{});
        return expected;
    }
}
