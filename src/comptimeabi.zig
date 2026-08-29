const Header = struct {};

const vm_stack_align: usize = 1 << 21;

const _asm_locate_header = std.fmt.comptimePrint(
    \\.global locate_header
    \\locate_header:
    \\    leaq 0x{x}(%rsp), %rax
    \\    andq $~0x{x}, %rax
    \\    leaq -{d}(%rax), %rax
    \\    ret
    , .{
        vm_stack_align - 1,
        vm_stack_align - 1,
        @sizeOf(Header),
    },
);

comptime {
    asm (
        _asm_locate_header
    );
}
pub extern fn locate_header() *anyopaque;

const std = @import("std");

test {
    std.debug.print("{s}\n", .{_asm_locate_header});
    const top: usize = @intFromPtr(locate_header()) + @sizeOf(Header);
    try std.testing.expectEqual(0, top % vm_stack_align);
}
