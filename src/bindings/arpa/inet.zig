const __root = @This();
pub const __builtin = @import("std").zig.c_translation.builtins;
pub const __helpers = @import("std").zig.c_translation.helpers;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __int_least8_t = __int8_t;
pub const __int_least16_t = __int16_t;
pub const __int_least32_t = __int32_t;
pub const __int_least64_t = __int64_t;
pub const __intmax_t = __int64_t;
pub const __uint_least8_t = __uint8_t;
pub const __uint_least16_t = __uint16_t;
pub const __uint_least32_t = __uint32_t;
pub const __uint_least64_t = __uint64_t;
pub const __uintmax_t = __uint64_t;
pub const __intptr_t = __int64_t;
pub const __intfptr_t = __int64_t;
pub const __uintptr_t = __uint64_t;
pub const __uintfptr_t = __uint64_t;
pub const __vm_offset_t = __uint64_t;
pub const __vm_size_t = __uint64_t;
pub const __size_t = __uint64_t;
pub const __ssize_t = __int64_t;
pub const __ptrdiff_t = __int64_t;
pub const __clock_t = __int32_t;
pub const __critical_t = __int64_t;
pub const __double_t = f64;
pub const __float_t = f32;
pub const __int_fast8_t = __int32_t;
pub const __int_fast16_t = __int32_t;
pub const __int_fast32_t = __int32_t;
pub const __int_fast64_t = __int64_t;
pub const __register_t = __int64_t;
pub const __segsz_t = __int64_t;
pub const __time_t = __int64_t;
pub const __uint_fast8_t = __uint32_t;
pub const __uint_fast16_t = __uint32_t;
pub const __uint_fast32_t = __uint32_t;
pub const __uint_fast64_t = __uint64_t;
pub const __u_register_t = __uint64_t;
pub const __vm_paddr_t = __uint64_t;
pub const ___wchar_t = c_int;
pub const __blksize_t = __int32_t;
pub const __blkcnt_t = __int64_t;
pub const __clockid_t = __int32_t;
pub const __fflags_t = __uint32_t;
pub const __fsblkcnt_t = __uint64_t;
pub const __fsfilcnt_t = __uint64_t;
pub const __gid_t = __uint32_t;
pub const __id_t = __int64_t;
pub const __ino_t = __uint64_t;
pub const __key_t = c_long;
pub const __lwpid_t = __int32_t;
pub const __mode_t = __uint16_t;
pub const __accmode_t = c_int;
pub const __nl_item = c_int;
pub const __nlink_t = __uint64_t;
pub const __off_t = __int64_t;
pub const __off64_t = __int64_t;
pub const __pid_t = __int32_t;
pub const __sbintime_t = __int64_t;
pub const __rlim_t = __int64_t;
pub const __sa_family_t = __uint8_t;
pub const __socklen_t = __uint32_t;
pub const __suseconds_t = c_long;
pub const struct___timer = opaque {};
pub const __timer_t = ?*struct___timer;
pub const struct___mq = opaque {};
pub const __mqd_t = ?*struct___mq;
pub const __uid_t = __uint32_t;
pub const __useconds_t = c_uint;
pub const __cpuwhich_t = c_int;
pub const __cpulevel_t = c_int;
pub const __cpusetid_t = c_int;
pub const __daddr_t = __int64_t;
pub const __ct_rune_t = c_int;
pub const __rune_t = __ct_rune_t;
pub const __wint_t = __ct_rune_t;
pub const __char16_t = __uint_least16_t;
pub const __char32_t = __uint_least32_t;
pub const __max_align_t = extern struct {
    __max_align1: c_longlong = 0,
    __max_align2: c_longdouble = 0,
};
pub const __acl_tag_t = __uint32_t;
pub const __acl_perm_t = __uint32_t;
pub const __acl_entry_type_t = __uint16_t;
pub const __acl_flag_t = __uint16_t;
pub const __acl_type_t = __uint32_t;
pub const __acl_permset_t = [*c]__uint32_t;
pub const __acl_flagset_t = [*c]__uint16_t;
pub const __dev_t = __uint64_t;
pub const __fixpt_t = __uint32_t;
pub const __mbstate_t = extern union {
    __mbstate8: [128]u8,
    _mbstateL: __int64_t,
};
pub const __rman_res_t = __uintmax_t;
pub const struct___va_list_tag_1 = extern struct {
    unnamed_0: c_uint = 0,
    unnamed_1: c_uint = 0,
    unnamed_2: ?*anyopaque = null,
    unnamed_3: ?*anyopaque = null,
};
pub const __builtin_va_list = [1]struct___va_list_tag_1;
pub const __va_list = __builtin_va_list;
pub const __gnuc_va_list = __va_list;
pub const in_addr_t = u32;
pub const in_port_t = u16;
pub const socklen_t = __socklen_t;
pub const struct_in_addr = extern struct {
    s_addr: in_addr_t = 0,
    pub const __inet_ntoa = __root.__inet_ntoa;
    pub const __inet_lnaof = __root.__inet_lnaof;
    pub const __inet_netof = __root.__inet_netof;
    pub const __inet_ntoa_r = __root.__inet_ntoa_r;
    pub const ntoa = __root.__inet_ntoa;
    pub const lnaof = __root.__inet_lnaof;
    pub const netof = __root.__inet_netof;
    pub const r = __root.__inet_ntoa_r;
};
pub extern fn htonl(u32) u32;
pub extern fn htons(u16) u16;
pub extern fn ntohl(u32) u32;
pub extern fn ntohs(u16) u16;
pub extern fn __inet_addr([*c]const u8) in_addr_t;
pub extern fn __inet_ntoa(struct_in_addr) [*c]u8;
pub extern fn __inet_ntop(c_int, noalias ?*const anyopaque, noalias [*c]u8, socklen_t) [*c]const u8;
pub extern fn __inet_pton(c_int, noalias [*c]const u8, noalias ?*anyopaque) c_int;
pub extern fn __inet_aton([*c]const u8, [*c]struct_in_addr) c_int;
pub extern fn __inet_lnaof(struct_in_addr) in_addr_t;
pub extern fn __inet_makeaddr(in_addr_t, in_addr_t) struct_in_addr;
pub extern fn __inet_neta(in_addr_t, [*c]u8, usize) [*c]u8;
pub extern fn __inet_netof(struct_in_addr) in_addr_t;
pub extern fn __inet_network([*c]const u8) in_addr_t;
pub extern fn __inet_net_ntop(c_int, ?*const anyopaque, c_int, [*c]u8, usize) [*c]u8;
pub extern fn __inet_net_pton(c_int, [*c]const u8, ?*anyopaque, usize) c_int;
pub extern fn __inet_ntoa_r(struct_in_addr, buf: [*c]u8, size: socklen_t) [*c]u8;
pub extern fn __inet_cidr_ntop(c_int, ?*const anyopaque, c_int, [*c]u8, usize) [*c]u8;
pub extern fn __inet_cidr_pton(c_int, [*c]const u8, ?*anyopaque, [*c]c_int) c_int;
pub extern fn __inet_nsap_addr([*c]const u8, [*c]u8, c_int) c_uint;
pub extern fn __inet_nsap_ntoa(c_int, [*c]const u8, [*c]u8) [*c]u8;

pub const __VERSION__ = "Aro aro-zig";
pub const __Aro__ = "";
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const __STDC_EMBED_NOT_FOUND__ = @as(c_int, 0);
pub const __STDC_EMBED_FOUND__ = @as(c_int, 1);
pub const __STDC_EMBED_EMPTY__ = @as(c_int, 2);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __ARO_EMULATE_NO__ = @as(c_int, 0);
pub const __ARO_EMULATE_CLANG__ = @as(c_int, 1);
pub const __ARO_EMULATE_GCC__ = @as(c_int, 2);
pub const __ARO_EMULATE_MSVC__ = @as(c_int, 3);
pub const __ARO_EMULATE__ = __ARO_EMULATE_CLANG__;
pub inline fn __building_module(x: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &x;
    return @as(c_int, 0);
}
pub const __FreeBSD__ = @as(c_int, 15);
pub const __FreeBSD_cc_version = __helpers.promoteIntLiteral(c_int, 150001, .decimal);
pub const unix = @as(c_int, 1);
pub const __unix = @as(c_int, 1);
pub const __unix__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`"); // <builtin>:32:9
pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`"); // <builtin>:33:9
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __PKU__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __SGX__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __CRC32__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __FLOAT128__ = @as(c_int, 1);
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const __ELF__ = @as(c_int, 1);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __ATOMIC_BOOL_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WINT_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_SHORT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_INT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LLONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_POINTER_LOCK_FREE = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 8);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SCHAR_WIDTH__ = @as(c_int, 8);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_WIDTH__ = @as(c_int, 64);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __LONG_LONG_WIDTH__ = @as(c_int, 64);
pub const __WCHAR_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __INTMAX_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIG_ATOMIC_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __BITINT_MAXWIDTH__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 10);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTPTR_TYPE__ = c_long;
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // <builtin>:145:9
pub const __INTMAX_C = __helpers.L_SUFFIX;
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // <builtin>:148:9
pub const __UINTMAX_C = __helpers.UL_SUFFIX;
pub const __PTRDIFF_TYPE__ = c_long;
pub const __SIZE_TYPE__ = c_ulong;
pub const __WCHAR_TYPE__ = c_int;
pub const __WINT_TYPE__ = c_int;
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub inline fn __INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub inline fn __INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub inline fn __INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT64_TYPE__ = c_long;
pub const __INT64_FMTd__ = "ld";
pub const __INT64_FMTi__ = "li";
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`"); // <builtin>:174:9
pub const __INT64_C = __helpers.L_SUFFIX;
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub inline fn __UINT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub inline fn __UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`"); // <builtin>:199:9
pub const __UINT32_C = __helpers.U_SUFFIX;
pub const __UINT32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulong;
pub const __UINT64_FMTo__ = "lo";
pub const __UINT64_FMTu__ = "lu";
pub const __UINT64_FMTx__ = "lx";
pub const __UINT64_FMTX__ = "lX";
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`"); // <builtin>:208:9
pub const __UINT64_C = __helpers.UL_SUFFIX;
pub const __UINT64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __INT64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const INT_LEAST8_FMTd__ = "hhd";
pub const INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const UINT_LEAST8_FMTo__ = "hho";
pub const UINT_LEAST8_FMTu__ = "hhu";
pub const UINT_LEAST8_FMTx__ = "hhx";
pub const UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const INT_FAST8_FMTd__ = "hhd";
pub const INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const UINT_FAST8_FMTo__ = "hho";
pub const UINT_FAST8_FMTu__ = "hhu";
pub const UINT_FAST8_FMTx__ = "hhx";
pub const UINT_FAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const INT_LEAST16_FMTd__ = "hd";
pub const INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_LEAST16_FMTo__ = "ho";
pub const UINT_LEAST16_FMTu__ = "hu";
pub const UINT_LEAST16_FMTx__ = "hx";
pub const UINT_LEAST16_FMTX__ = "hX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const INT_FAST16_FMTd__ = "hd";
pub const INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_FAST16_FMTo__ = "ho";
pub const UINT_FAST16_FMTu__ = "hu";
pub const UINT_FAST16_FMTx__ = "hx";
pub const UINT_FAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const INT_LEAST32_FMTd__ = "d";
pub const INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_LEAST32_FMTo__ = "o";
pub const UINT_LEAST32_FMTu__ = "u";
pub const UINT_LEAST32_FMTx__ = "x";
pub const UINT_LEAST32_FMTX__ = "X";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const INT_FAST32_FMTd__ = "d";
pub const INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_FAST32_FMTo__ = "o";
pub const UINT_FAST32_FMTu__ = "u";
pub const UINT_FAST32_FMTx__ = "x";
pub const UINT_FAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_long;
pub const __INT_LEAST64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const INT_LEAST64_FMTd__ = "ld";
pub const INT_LEAST64_FMTi__ = "li";
pub const __UINT_LEAST64_TYPE__ = c_ulong;
pub const __UINT_LEAST64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_LEAST64_FMTo__ = "lo";
pub const UINT_LEAST64_FMTu__ = "lu";
pub const UINT_LEAST64_FMTx__ = "lx";
pub const UINT_LEAST64_FMTX__ = "lX";
pub const __INT_FAST64_TYPE__ = c_long;
pub const __INT_FAST64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const INT_FAST64_FMTd__ = "ld";
pub const INT_FAST64_FMTi__ = "li";
pub const __UINT_FAST64_TYPE__ = c_ulong;
pub const __UINT_FAST64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST64_FMTo__ = "lo";
pub const UINT_FAST64_FMTu__ = "lu";
pub const UINT_FAST64_FMTx__ = "lx";
pub const UINT_FAST64_FMTX__ = "lX";
pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
pub const __FLT16_HAS_DENORM__ = "";
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
pub const __FLT16_HAS_INFINITY__ = "";
pub const __FLT16_HAS_QUIET_NAN__ = "";
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = "";
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = "";
pub const __FLT_HAS_QUIET_NAN__ = "";
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_HAS_DENORM__ = "";
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = "";
pub const __DBL_HAS_QUIET_NAN__ = "";
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = "";
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = "";
pub const __LDBL_HAS_QUIET_NAN__ = "";
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __FLT_EVAL_METHOD__ = @as(c_int, 0);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __FreeBSD_version = __helpers.promoteIntLiteral(c_int, 1500500, .decimal);
pub const _ARPA_INET_H_ = "";
pub const _SYS_CDEFS_H_ = "";
pub const __BEGIN_DECLS = "";
pub const __END_DECLS = "";
pub inline fn __GNUC_PREREQ__(ma: anytype, mi: anytype) @TypeOf((__GNUC__ > ma) or ((__GNUC__ == ma) and (__GNUC_MINOR__ >= mi))) {
    _ = &ma;
    _ = &mi;
    return (__GNUC__ > ma) or ((__GNUC__ == ma) and (__GNUC_MINOR__ >= mi));
}
pub const __compiler_membar = @compileError("unable to translate C expr: unexpected token '__asm'"); // /usr/include/sys/cdefs.h:93:9
pub const __CC_SUPPORTS___INLINE = @as(c_int, 1);
pub const __CC_SUPPORTS_SYMVER = @as(c_int, 1);
pub inline fn __P(protos: anytype) @TypeOf(protos) {
    _ = &protos;
    return protos;
}
pub const __CONCAT1 = @compileError("unable to translate C expr: unexpected token '##'"); // /usr/include/sys/cdefs.h:122:9
pub inline fn __CONCAT(x: anytype, y: anytype) @TypeOf(__CONCAT1(x, y)) {
    _ = &x;
    _ = &y;
    return __CONCAT1(x, y);
}
pub const __STRING = @compileError("unable to translate C expr: unexpected token ''"); // /usr/include/sys/cdefs.h:124:9
pub inline fn __XSTRING(x: anytype) @TypeOf(__STRING(x)) {
    _ = &x;
    return __STRING(x);
}
pub const __volatile = @compileError("unable to translate C expr: unexpected token 'volatile'"); // /usr/include/sys/cdefs.h:127:9
pub const __weak_symbol = @compileError("unable to translate macro: undefined identifier `__weak__`"); // /usr/include/sys/cdefs.h:152:9
pub const __dead2 = @compileError("unable to translate macro: undefined identifier `__noreturn__`"); // /usr/include/sys/cdefs.h:153:9
pub const __pure2 = @compileError("unable to translate C expr: unexpected token '__attribute__'"); // /usr/include/sys/cdefs.h:154:9
pub const __unused = @compileError("unable to translate macro: undefined identifier `__unused__`"); // /usr/include/sys/cdefs.h:155:9
pub const __used = @compileError("unable to translate macro: undefined identifier `__used__`"); // /usr/include/sys/cdefs.h:156:9
pub const __deprecated = @compileError("unable to translate macro: undefined identifier `__deprecated__`"); // /usr/include/sys/cdefs.h:157:9
pub const __deprecated1 = @compileError("unable to translate macro: undefined identifier `__deprecated__`"); // /usr/include/sys/cdefs.h:158:9
pub const __packed = @compileError("unable to translate macro: undefined identifier `__packed__`"); // /usr/include/sys/cdefs.h:159:9
pub const __aligned = @compileError("unable to translate macro: undefined identifier `__aligned__`"); // /usr/include/sys/cdefs.h:160:9
pub const __section = @compileError("unable to translate macro: undefined identifier `__section__`"); // /usr/include/sys/cdefs.h:161:9
pub const __writeonly = __unused;
pub const __alloc_size = @compileError("unable to translate macro: undefined identifier `__alloc_size__`"); // /usr/include/sys/cdefs.h:163:9
pub const __alloc_size2 = @compileError("unable to translate macro: undefined identifier `__alloc_size__`"); // /usr/include/sys/cdefs.h:164:9
pub const __alloc_align = @compileError("unable to translate macro: undefined identifier `__alloc_align__`"); // /usr/include/sys/cdefs.h:165:9
pub const __generic = @compileError("unable to translate C expr: expected type instead got ''"); // /usr/include/sys/cdefs.h:227:9
pub const __min_size = @compileError("unable to translate C expr: unexpected token 'static'"); // /usr/include/sys/cdefs.h:244:9
pub const __malloc_like = @compileError("unable to translate macro: undefined identifier `__malloc__`"); // /usr/include/sys/cdefs.h:249:9
pub const __pure = @compileError("unable to translate macro: undefined identifier `__pure__`"); // /usr/include/sys/cdefs.h:250:9
pub const __always_inline = @compileError("unable to translate macro: undefined identifier `__always_inline__`"); // /usr/include/sys/cdefs.h:252:9
pub const __noinline = @compileError("unable to translate macro: undefined identifier `__noinline__`"); // /usr/include/sys/cdefs.h:253:9
pub const __fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`"); // /usr/include/sys/cdefs.h:254:9
pub const __result_use_check = @compileError("unable to translate macro: undefined identifier `__warn_unused_result__`"); // /usr/include/sys/cdefs.h:255:9
pub const __returns_twice = @compileError("unable to translate macro: undefined identifier `__returns_twice__`"); // /usr/include/sys/cdefs.h:256:9
pub inline fn __unreachable() @TypeOf(__builtin.@"unreachable"()) {
    return __builtin.@"unreachable"();
}
pub const __LONG_LONG_SUPPORTED = "";
pub const __noexcept = "";
pub inline fn __noexcept_if(__c: anytype) void {
    _ = &__c;
    return;
}
pub const __nodiscard = "";
pub const __restrict = @compileError("unable to translate C expr: unexpected token 'restrict'"); // /usr/include/sys/cdefs.h:331:9
pub inline fn __predict_true(exp: anytype) @TypeOf(__builtin.expect(exp, @as(c_int, 1))) {
    _ = &exp;
    return __builtin.expect(exp, @as(c_int, 1));
}
pub inline fn __predict_false(exp: anytype) @TypeOf(__builtin.expect(exp, @as(c_int, 0))) {
    _ = &exp;
    return __builtin.expect(exp, @as(c_int, 0));
}
pub const __null_sentinel = @compileError("unable to translate macro: undefined identifier `__sentinel__`"); // /usr/include/sys/cdefs.h:344:9
pub const __exported = @compileError("unable to translate macro: undefined identifier `__visibility__`"); // /usr/include/sys/cdefs.h:345:9
pub const __hidden = @compileError("unable to translate macro: undefined identifier `__visibility__`"); // /usr/include/sys/cdefs.h:346:9
pub const __offsetof = @compileError("unable to translate macro: undefined identifier `__builtin_offsetof`"); // /usr/include/sys/cdefs.h:352:9
pub inline fn __rangeof(@"type": anytype, start: anytype, end: anytype) @TypeOf(__offsetof(@"type", end) - __offsetof(@"type", start)) {
    _ = &@"type";
    _ = &start;
    _ = &end;
    return __offsetof(@"type", end) - __offsetof(@"type", start);
}
pub const __containerof = @compileError("unable to translate macro: undefined identifier `__x`"); // /usr/include/sys/cdefs.h:362:9
pub const __printflike = @compileError("unable to translate macro: undefined identifier `__format__`"); // /usr/include/sys/cdefs.h:371:9
pub const __scanflike = @compileError("unable to translate macro: undefined identifier `__format__`"); // /usr/include/sys/cdefs.h:373:9
pub const __format_arg = @compileError("unable to translate macro: undefined identifier `__format_arg__`"); // /usr/include/sys/cdefs.h:375:9
pub const __strfmonlike = @compileError("unable to translate macro: undefined identifier `__format__`"); // /usr/include/sys/cdefs.h:376:9
pub const __strftimelike = @compileError("unable to translate macro: undefined identifier `__format__`"); // /usr/include/sys/cdefs.h:378:9
pub const __printf0like = @compileError("unable to translate macro: undefined identifier `__format__`"); // /usr/include/sys/cdefs.h:391:9
pub const __strong_reference = @compileError("unable to translate macro: undefined identifier `__alias__`"); // /usr/include/sys/cdefs.h:397:9
pub const __weak_reference = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:400:9
pub const __warn_references = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:403:9
pub const __sym_compat = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:408:9
pub const __sym_default = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:410:9
pub const __GLOBL = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:429:9
pub const __WEAK = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:430:9
pub const __IDSTRING = @compileError("unable to translate C expr: unexpected token '__asm__'"); // /usr/include/sys/cdefs.h:432:9
pub const __FBSDID = @compileError("unable to translate macro: undefined identifier `__rcsid_`"); // /usr/include/sys/cdefs.h:441:9
pub const __RCSID = @compileError("unable to translate macro: undefined identifier `__rcsid_`"); // /usr/include/sys/cdefs.h:449:9
pub const __RCSID_SOURCE = @compileError("unable to translate macro: undefined identifier `__rcsid_source_`"); // /usr/include/sys/cdefs.h:457:9
pub const __SCCSID = @compileError("unable to translate macro: undefined identifier `__sccsid_`"); // /usr/include/sys/cdefs.h:465:9
pub const __COPYRIGHT = @compileError("unable to translate macro: undefined identifier `__copyright_`"); // /usr/include/sys/cdefs.h:473:9
pub const __DECONST = @compileError("unable to translate C expr: unexpected token 'const'"); // /usr/include/sys/cdefs.h:480:9
pub const __DEVOLATILE = @compileError("unable to translate C expr: unexpected token 'volatile'"); // /usr/include/sys/cdefs.h:484:9
pub const __DEQUALIFY = @compileError("unable to translate C expr: unexpected token 'const'"); // /usr/include/sys/cdefs.h:488:9
pub const __RENAME = @compileError("unable to translate C expr: unexpected token '__asm'"); // /usr/include/sys/cdefs.h:492:9
pub const _SYS__VISIBLE_H_ = "";
pub const __POSIX_VISIBLE = __helpers.promoteIntLiteral(c_int, 202405, .decimal);
pub const __XSI_VISIBLE = @as(c_int, 800);
pub const __BSD_VISIBLE = @as(c_int, 1);
pub const __ISO_C_VISIBLE = @as(c_int, 2023);
pub const __EXT1_VISIBLE = @as(c_int, 1);
pub const _Nonnull = "";
pub const _Nullable = "";
pub const _Null_unspecified = "";
pub const __NULLABILITY_PRAGMA_PUSH = "";
pub const __NULLABILITY_PRAGMA_POP = "";
pub inline fn __arg_type_tag(arg_kind: anytype, arg_idx: anytype, type_tag_idx: anytype) void {
    _ = &arg_kind;
    _ = &arg_idx;
    _ = &type_tag_idx;
    return;
}
pub inline fn __datatype_type_tag(kind: anytype, @"type": anytype) void {
    _ = &kind;
    _ = &@"type";
    return;
}
pub inline fn __lock_annotate(x: anytype) void {
    _ = &x;
    return;
}
pub const __lockable = @compileError("unable to translate macro: undefined identifier `lockable`"); // /usr/include/sys/cdefs.h:551:9
pub const __locks_exclusive = @compileError("unable to translate macro: undefined identifier `exclusive_lock_function`"); // /usr/include/sys/cdefs.h:554:9
pub const __locks_shared = @compileError("unable to translate macro: undefined identifier `shared_lock_function`"); // /usr/include/sys/cdefs.h:556:9
pub const __trylocks_exclusive = @compileError("unable to translate macro: undefined identifier `exclusive_trylock_function`"); // /usr/include/sys/cdefs.h:560:9
pub const __trylocks_shared = @compileError("unable to translate macro: undefined identifier `shared_trylock_function`"); // /usr/include/sys/cdefs.h:562:9
pub const __unlocks = @compileError("unable to translate macro: undefined identifier `unlock_function`"); // /usr/include/sys/cdefs.h:566:9
pub const __asserts_exclusive = @compileError("unable to translate macro: undefined identifier `assert_exclusive_lock`"); // /usr/include/sys/cdefs.h:569:9
pub const __asserts_shared = @compileError("unable to translate macro: undefined identifier `assert_shared_lock`"); // /usr/include/sys/cdefs.h:571:9
pub const __requires_exclusive = @compileError("unable to translate macro: undefined identifier `exclusive_locks_required`"); // /usr/include/sys/cdefs.h:575:9
pub const __requires_shared = @compileError("unable to translate macro: undefined identifier `shared_locks_required`"); // /usr/include/sys/cdefs.h:577:9
pub const __requires_unlocked = @compileError("unable to translate macro: undefined identifier `locks_excluded`"); // /usr/include/sys/cdefs.h:579:9
pub const __no_lock_analysis = @compileError("unable to translate macro: undefined identifier `no_thread_safety_analysis`"); // /usr/include/sys/cdefs.h:583:9
pub const __nosanitizeaddress = "";
pub const __nosanitizecoverage = "";
pub const __nosanitizememory = "";
pub const __nosanitizethread = "";
pub const __nostackprotector = @compileError("unable to translate macro: undefined identifier `no_stack_protector`"); // /usr/include/sys/cdefs.h:623:9
pub const __guarded_by = @compileError("unable to translate macro: undefined identifier `guarded_by`"); // /usr/include/sys/cdefs.h:630:9
pub const __pt_guarded_by = @compileError("unable to translate macro: undefined identifier `pt_guarded_by`"); // /usr/include/sys/cdefs.h:631:9
pub const __align_up = @compileError("unable to translate macro: undefined identifier `__builtin_align_up`"); // /usr/include/sys/cdefs.h:648:9
pub const __align_down = @compileError("unable to translate macro: undefined identifier `__builtin_align_down`"); // /usr/include/sys/cdefs.h:649:9
pub const __is_aligned = @compileError("unable to translate macro: undefined identifier `__builtin_is_aligned`"); // /usr/include/sys/cdefs.h:650:9
pub const _SYS__TYPES_H_ = "";
pub const _MACHINE__TYPES_H_ = "";
pub const _MACHINE__LIMITS_H_ = "";
pub const __CHAR_BIT = @as(c_int, 8);
pub const __SCHAR_MAX = @as(c_int, 0x7f);
pub const __SCHAR_MIN = -@as(c_int, 0x7f) - @as(c_int, 1);
pub const __UCHAR_MAX = @as(c_int, 0xff);
pub const __USHRT_MAX = __helpers.promoteIntLiteral(c_int, 0xffff, .hex);
pub const __SHRT_MAX = @as(c_int, 0x7fff);
pub const __SHRT_MIN = -@as(c_int, 0x7fff) - @as(c_int, 1);
pub const __UINT_MAX = __helpers.promoteIntLiteral(c_int, 0xffffffff, .hex);
pub const __INT_MAX = __helpers.promoteIntLiteral(c_int, 0x7fffffff, .hex);
pub const __INT_MIN = -__helpers.promoteIntLiteral(c_int, 0x7fffffff, .hex) - @as(c_int, 1);
pub const __ULONG_MAX = __helpers.promoteIntLiteral(c_int, 0xffffffffffffffff, .hex);
pub const __LONG_MAX = __helpers.promoteIntLiteral(c_int, 0x7fffffffffffffff, .hex);
pub const __LONG_MIN = -__helpers.promoteIntLiteral(c_int, 0x7fffffffffffffff, .hex) - @as(c_int, 1);
pub const __ULLONG_MAX = @as(c_ulonglong, 0xffffffffffffffff);
pub const __LLONG_MAX = @as(c_longlong, 0x7fffffffffffffff);
pub const __LLONG_MIN = -@as(c_longlong, 0x7fffffffffffffff) - @as(c_int, 1);
pub const __SSIZE_MAX = __LONG_MAX;
pub const __SIZE_T_MAX = __ULONG_MAX;
pub const __OFF_MAX = __LONG_MAX;
pub const __OFF_MIN = __LONG_MIN;
pub const __UQUAD_MAX = __ULONG_MAX;
pub const __QUAD_MAX = __LONG_MAX;
pub const __QUAD_MIN = __LONG_MIN;
pub const __LONG_BIT = @as(c_int, 64);
pub const __WORD_BIT = @as(c_int, 32);
pub const __MINSIGSTKSZ = @as(c_int, 512) * @as(c_int, 4);
pub const __NO_STRICT_ALIGNMENT = "";
pub const __WCHAR_MIN = __INT_MIN;
pub const __WCHAR_MAX = __INT_MAX;
pub const __GNUC_VA_LIST = "";
pub const __INO64 = "";
pub const _MACHINE_ENDIAN_H_ = "";
pub const _SYS__ENDIAN_H_ = "";
pub const _BYTE_ORDER = __BYTE_ORDER__;
pub const _LITTLE_ENDIAN = __ORDER_LITTLE_ENDIAN__;
pub const _BIG_ENDIAN = __ORDER_BIG_ENDIAN__;
pub const _PDP_ENDIAN = __ORDER_PDP_ENDIAN__;
pub const _QUAD_HIGHWORD = @as(c_int, 1);
pub const _QUAD_LOWWORD = @as(c_int, 0);
pub const LITTLE_ENDIAN = _LITTLE_ENDIAN;
pub const BIG_ENDIAN = _BIG_ENDIAN;
pub const PDP_ENDIAN = _PDP_ENDIAN;
pub const BYTE_ORDER = _BYTE_ORDER;
pub inline fn __bswap16(x: anytype) @TypeOf(__builtin.bswap16(x)) {
    _ = &x;
    return __builtin.bswap16(x);
}
pub inline fn __bswap32(x: anytype) @TypeOf(__builtin.bswap32(x)) {
    _ = &x;
    return __builtin.bswap32(x);
}
pub inline fn __bswap64(x: anytype) @TypeOf(__builtin.bswap64(x)) {
    _ = &x;
    return __builtin.bswap64(x);
}
pub inline fn __ntohl(x: anytype) @TypeOf(__bswap32(x)) {
    _ = &x;
    return __bswap32(x);
}
pub inline fn __ntohs(x: anytype) @TypeOf(__bswap16(x)) {
    _ = &x;
    return __bswap16(x);
}
pub inline fn __htonl(x: anytype) @TypeOf(__bswap32(x)) {
    _ = &x;
    return __bswap32(x);
}
pub inline fn __htons(x: anytype) @TypeOf(__bswap16(x)) {
    _ = &x;
    return __bswap16(x);
}
pub inline fn htobe16(x: anytype) @TypeOf(__bswap16(x)) {
    _ = &x;
    return __bswap16(x);
}
pub inline fn htobe32(x: anytype) @TypeOf(__bswap32(x)) {
    _ = &x;
    return __bswap32(x);
}
pub inline fn htobe64(x: anytype) @TypeOf(__bswap64(x)) {
    _ = &x;
    return __bswap64(x);
}
pub inline fn htole16(x: anytype) u16 {
    _ = &x;
    return __helpers.cast(u16, x);
}
pub inline fn htole32(x: anytype) u32 {
    _ = &x;
    return __helpers.cast(u32, x);
}
pub const htole64 = @compileError("unable to translate macro: undefined identifier `uint64_t`"); // /usr/include/sys/_endian.h:111:9
pub inline fn be16toh(x: anytype) @TypeOf(__bswap16(x)) {
    _ = &x;
    return __bswap16(x);
}
pub inline fn be32toh(x: anytype) @TypeOf(__bswap32(x)) {
    _ = &x;
    return __bswap32(x);
}
pub inline fn be64toh(x: anytype) @TypeOf(__bswap64(x)) {
    _ = &x;
    return __bswap64(x);
}
pub inline fn le16toh(x: anytype) u16 {
    _ = &x;
    return __helpers.cast(u16, x);
}
pub inline fn le32toh(x: anytype) u32 {
    _ = &x;
    return __helpers.cast(u32, x);
}
pub const le64toh = @compileError("unable to translate macro: undefined identifier `uint64_t`"); // /usr/include/sys/_endian.h:118:9
pub const INET_ADDRSTRLEN = @as(c_int, 16);
pub const INET6_ADDRSTRLEN = @as(c_int, 46);
pub const _UINT16_T_DECLARED = "";
pub const _UINT32_T_DECLARED = "";
pub const _IN_ADDR_T_DECLARED = "";
pub const _IN_PORT_T_DECLARED = "";
pub const _SIZE_T_DECLARED = "";
pub const _SOCKLEN_T_DECLARED = "";
pub const _STRUCT_IN_ADDR_DECLARED = "";
pub const inet_addr = __inet_addr;
pub const inet_aton = __inet_aton;
pub const inet_lnaof = __inet_lnaof;
pub const inet_makeaddr = __inet_makeaddr;
pub const inet_neta = __inet_neta;
pub const inet_netof = __inet_netof;
pub const inet_network = __inet_network;
pub const inet_net_ntop = __inet_net_ntop;
pub const inet_net_pton = __inet_net_pton;
pub const inet_cidr_ntop = __inet_cidr_ntop;
pub const inet_cidr_pton = __inet_cidr_pton;
pub const inet_ntoa = __inet_ntoa;
pub const inet_ntoa_r = __inet_ntoa_r;
pub const inet_pton = __inet_pton;
pub const inet_ntop = __inet_ntop;
pub const inet_nsap_addr = __inet_nsap_addr;
pub const inet_nsap_ntoa = __inet_nsap_ntoa;
pub const _BYTEORDER_PROTOTYPED = "";
pub const _BYTEORDER_FUNC_DEFINED = "";
pub const __timer = struct___timer;
pub const __mq = struct___mq;
pub const in_addr = struct_in_addr;
