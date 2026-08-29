const Header = struct {};
const Header8 = struct {
    a: *anyopaque,
};
const Header16 = struct {
    a: *anyopaque,
    b: *anyopaque,
};
const Header32 = struct {
    a: *anyopaque,
    b: *anyopaque,
    c: *anyopaque,
    d: *anyopaque,
};
const Header64 = struct {
    a: *anyopaque,
    b: *anyopaque,
    c: *anyopaque,
    d: *anyopaque,
    e: *anyopaque,
    f: *anyopaque,
    g: *anyopaque,
    h: *anyopaque,
};
const Header128 = struct {
    a: *anyopaque,
    b: *anyopaque,
    c: *anyopaque,
    d: *anyopaque,
    e: *anyopaque,
    f: *anyopaque,
    g: *anyopaque,
    h: *anyopaque,
    i: *anyopaque,
    j: *anyopaque,
    k: *anyopaque,
    l: *anyopaque,
    m: *anyopaque,
    n: *anyopaque,
    o: *anyopaque,
    p: *anyopaque,
};

const vm_stack_align: usize = 1 << 21;

const _asm_locate_header = genAsmLocateHeader(Header16, vm_stack_align);

fn genAsmLocateHeader(comptime T: type, comptime stack_align: usize) *const [161:0]u8 {
    return std.fmt.comptimePrint(
        \\.global locate_header
        \\locate_header:
        \\    leaq 0x{x:016}(%rsp), %rax
        \\    andq $~0x{x:016}, %rax
        \\    leaq -0x{x:016}(%rax), %rax
        \\    ret
        , .{
            stack_align - 1,
            stack_align - 1,
            @sizeOf(T),
        },
    );
}

comptime {
    asm (
        _asm_locate_header
    );
}
pub extern fn locate_header() *anyopaque;

const std = @import("std");

test {
    std.debug.print("{s}\n", .{_asm_locate_header});
    try std.testing.expectEqual(
        0,
        (@intFromPtr(locate_header()) + @sizeOf(Header16)) % vm_stack_align);
}
