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
pub const sa_family_t = __sa_family_t;
pub const struct_in_addr = extern struct {
    s_addr: in_addr_t = 0,
};
pub const socklen_t = __socklen_t;
pub const struct_sockaddr_storage = extern struct {
    ss_len: u8 = 0,
    ss_family: sa_family_t = 0,
    __ss_pad1: [6]u8 = @import("std").mem.zeroes([6]u8),
    __ss_align: __int64_t = 0,
    __ss_pad2: [112]u8 = @import("std").mem.zeroes([112]u8),
};
pub const struct_sockaddr_in = extern struct {
    sin_len: u8 = 0,
    sin_family: sa_family_t = 0,
    sin_port: in_port_t = 0,
    sin_addr: struct_in_addr = @import("std").mem.zeroes(struct_in_addr),
    sin_zero: [8]u8 = @import("std").mem.zeroes([8]u8),
};
pub extern fn htonl(u32) u32;
pub extern fn htons(u16) u16;
pub extern fn ntohl(u32) u32;
pub extern fn ntohs(u16) u16;
pub const struct_ip_mreq = extern struct {
    imr_multiaddr: struct_in_addr = @import("std").mem.zeroes(struct_in_addr),
    imr_interface: struct_in_addr = @import("std").mem.zeroes(struct_in_addr),
};
pub const struct_ip_mreqn = extern struct {
    imr_multiaddr: struct_in_addr = @import("std").mem.zeroes(struct_in_addr),
    imr_address: struct_in_addr = @import("std").mem.zeroes(struct_in_addr),
    imr_ifindex: c_int = 0,
};
pub const struct_ip_mreq_source = extern struct {
    imr_multiaddr: struct_in_addr = @import("std").mem.zeroes(struct_in_addr),
    imr_sourceaddr: struct_in_addr = @import("std").mem.zeroes(struct_in_addr),
    imr_interface: struct_in_addr = @import("std").mem.zeroes(struct_in_addr),
};
pub const struct_group_req = extern struct {
    gr_interface: u32 = 0,
    gr_group: struct_sockaddr_storage = @import("std").mem.zeroes(struct_sockaddr_storage),
};
pub const struct_group_source_req = extern struct {
    gsr_interface: u32 = 0,
    gsr_group: struct_sockaddr_storage = @import("std").mem.zeroes(struct_sockaddr_storage),
    gsr_source: struct_sockaddr_storage = @import("std").mem.zeroes(struct_sockaddr_storage),
};
pub const struct___msfilterreq = extern struct {
    msfr_ifindex: u32 = 0,
    msfr_fmode: u32 = 0,
    msfr_nsrcs: u32 = 0,
    msfr_group: struct_sockaddr_storage = @import("std").mem.zeroes(struct_sockaddr_storage),
    msfr_srcs: [*c]struct_sockaddr_storage = null,
};
pub const struct_sockaddr = opaque {};
pub extern fn setipv4sourcefilter(c_int, struct_in_addr, struct_in_addr, u32, u32, [*c]struct_in_addr) c_int;
pub extern fn getipv4sourcefilter(c_int, struct_in_addr, struct_in_addr, [*c]u32, [*c]u32, [*c]struct_in_addr) c_int;
pub extern fn setsourcefilter(c_int, u32, ?*struct_sockaddr, socklen_t, u32, u32, [*c]struct_sockaddr_storage) c_int;
pub extern fn getsourcefilter(c_int, u32, ?*struct_sockaddr, socklen_t, [*c]u32, [*c]u32, [*c]struct_sockaddr_storage) c_int;
const union_unnamed_2 = extern union {
    __u6_addr8: [16]u8,
    __u6_addr16: [8]u16,
    __u6_addr32: [4]u32,
};
pub const struct_in6_addr = extern struct {
    __u6_addr: union_unnamed_2 = @import("std").mem.zeroes(union_unnamed_2),
};
pub const struct_sockaddr_in6 = extern struct {
    sin6_len: u8 = 0,
    sin6_family: sa_family_t = 0,
    sin6_port: in_port_t = 0,
    sin6_flowinfo: u32 = 0,
    sin6_addr: struct_in6_addr = @import("std").mem.zeroes(struct_in6_addr),
    sin6_scope_id: u32 = 0,
};
pub extern const in6addr_any: struct_in6_addr;
pub extern const in6addr_loopback: struct_in6_addr;
pub extern const in6addr_nodelocal_allnodes: struct_in6_addr;
pub extern const in6addr_linklocal_allnodes: struct_in6_addr;
pub extern const in6addr_linklocal_allrouters: struct_in6_addr;
pub extern const in6addr_linklocal_allv2routers: struct_in6_addr;
pub const struct_nhop_object = opaque {};
pub const struct_llentry_3 = opaque {};
pub const struct_route_in6 = extern struct {
    ro_nh: ?*struct_nhop_object = null,
    ro_lle: ?*struct_llentry_3 = null,
    ro_prepend: [*c]u8 = null,
    ro_plen: u16 = 0,
    ro_flags: u16 = 0,
    ro_mtu: u16 = 0,
    spare: u16 = 0,
    ro_dst: struct_sockaddr_in6 = @import("std").mem.zeroes(struct_sockaddr_in6),
};
pub const struct_ipv6_mreq = extern struct {
    ipv6mr_multiaddr: struct_in6_addr = @import("std").mem.zeroes(struct_in6_addr),
    ipv6mr_interface: c_uint = 0,
};
pub const struct_in6_pktinfo = extern struct {
    ipi6_addr: struct_in6_addr = @import("std").mem.zeroes(struct_in6_addr),
    ipi6_ifindex: c_uint = 0,
};
pub const struct_ip6_mtuinfo = extern struct {
    ip6m_addr: struct_sockaddr_in6 = @import("std").mem.zeroes(struct_sockaddr_in6),
    ip6m_mtu: u32 = 0,
};
pub const struct_cmsghdr = opaque {
    pub const inet6_option_append = __root.inet6_option_append;
    pub const inet6_option_alloc = __root.inet6_option_alloc;
    pub const inet6_option_next = __root.inet6_option_next;
    pub const inet6_option_find = __root.inet6_option_find;
    pub const inet6_rthdr_add = __root.inet6_rthdr_add;
    pub const inet6_rthdr_lasthop = __root.inet6_rthdr_lasthop;
    pub const inet6_rthdr_segments = __root.inet6_rthdr_segments;
    pub const inet6_rthdr_getaddr = __root.inet6_rthdr_getaddr;
    pub const inet6_rthdr_getflags = __root.inet6_rthdr_getflags;
    pub const append = __root.inet6_option_append;
    pub const alloc = __root.inet6_option_alloc;
    pub const next = __root.inet6_option_next;
    pub const find = __root.inet6_option_find;
    pub const add = __root.inet6_rthdr_add;
    pub const lasthop = __root.inet6_rthdr_lasthop;
    pub const segments = __root.inet6_rthdr_segments;
    pub const getaddr = __root.inet6_rthdr_getaddr;
    pub const getflags = __root.inet6_rthdr_getflags;
};
pub extern fn inet6_option_space(c_int) c_int;
pub extern fn inet6_option_init(?*anyopaque, [*c]?*struct_cmsghdr, c_int) c_int;
pub extern fn inet6_option_append(?*struct_cmsghdr, [*c]const u8, c_int, c_int) c_int;
pub extern fn inet6_option_alloc(?*struct_cmsghdr, c_int, c_int, c_int) [*c]u8;
pub extern fn inet6_option_next(?*const struct_cmsghdr, [*c][*c]u8) c_int;
pub extern fn inet6_option_find(?*const struct_cmsghdr, [*c][*c]u8, c_int) c_int;
pub extern fn inet6_rthdr_space(c_int, c_int) usize;
pub extern fn inet6_rthdr_init(?*anyopaque, c_int) ?*struct_cmsghdr;
pub extern fn inet6_rthdr_add(?*struct_cmsghdr, [*c]const struct_in6_addr, c_uint) c_int;
pub extern fn inet6_rthdr_lasthop(?*struct_cmsghdr, c_uint) c_int;
pub extern fn inet6_rthdr_segments(?*const struct_cmsghdr) c_int;
pub extern fn inet6_rthdr_getaddr(?*struct_cmsghdr, c_int) [*c]struct_in6_addr;
pub extern fn inet6_rthdr_getflags(?*const struct_cmsghdr, c_int) c_int;
pub extern fn inet6_opt_init(?*anyopaque, socklen_t) c_int;
pub extern fn inet6_opt_append(?*anyopaque, socklen_t, c_int, u8, socklen_t, u8, [*c]?*anyopaque) c_int;
pub extern fn inet6_opt_finish(?*anyopaque, socklen_t, c_int) c_int;
pub extern fn inet6_opt_set_val(?*anyopaque, c_int, ?*anyopaque, socklen_t) c_int;
pub extern fn inet6_opt_next(?*anyopaque, socklen_t, c_int, [*c]u8, [*c]socklen_t, [*c]?*anyopaque) c_int;
pub extern fn inet6_opt_find(?*anyopaque, socklen_t, c_int, u8, [*c]socklen_t, [*c]?*anyopaque) c_int;
pub extern fn inet6_opt_get_val(?*anyopaque, c_int, ?*anyopaque, socklen_t) c_int;
pub extern fn inet6_rth_space(c_int, c_int) socklen_t;
pub extern fn inet6_rth_init(?*anyopaque, socklen_t, c_int, c_int) ?*anyopaque;
pub extern fn inet6_rth_add(?*anyopaque, [*c]const struct_in6_addr) c_int;
pub extern fn inet6_rth_reverse(?*const anyopaque, ?*anyopaque) c_int;
pub extern fn inet6_rth_segments(?*const anyopaque) c_int;
pub extern fn inet6_rth_getaddr(?*const anyopaque, c_int) [*c]struct_in6_addr;

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
pub const _NETINET_IN_H_ = "";
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
pub const IPPROTO_IP = @as(c_int, 0);
pub const IPPROTO_ICMP = @as(c_int, 1);
pub const IPPROTO_TCP = @as(c_int, 6);
pub const IPPROTO_UDP = @as(c_int, 17);
pub const INADDR_ANY = __helpers.cast(in_addr_t, @as(c_int, 0x00000000));
pub const INADDR_BROADCAST = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xffffffff, .hex));
pub const _UINT8_T_DECLARED = "";
pub const _UINT16_T_DECLARED = "";
pub const _UINT32_T_DECLARED = "";
pub const _IN_ADDR_T_DECLARED = "";
pub const _IN_PORT_T_DECLARED = "";
pub const _SA_FAMILY_T_DECLARED = "";
pub const _STRUCT_IN_ADDR_DECLARED = "";
pub const _SOCKLEN_T_DECLARED = "";
pub const _SYS__SOCKADDR_STORAGE_H_ = "";
pub const _SS_MAXSIZE = @as(c_uint, 128);
pub const _SS_ALIGNSIZE = __helpers.sizeof(__int64_t);
pub const _SS_PAD1SIZE = (_SS_ALIGNSIZE - __helpers.sizeof(u8)) - __helpers.sizeof(sa_family_t);
pub const _SS_PAD2SIZE = (((_SS_MAXSIZE - __helpers.sizeof(u8)) - __helpers.sizeof(sa_family_t)) - _SS_PAD1SIZE) - _SS_ALIGNSIZE;
pub const _BYTEORDER_PROTOTYPED = "";
pub const _BYTEORDER_FUNC_DEFINED = "";
pub const IPPROTO_IPV6 = @as(c_int, 41);
pub const IPPROTO_RAW = @as(c_int, 255);
pub const INET_ADDRSTRLEN = @as(c_int, 16);
pub const IPPROTO_HOPOPTS = @as(c_int, 0);
pub const IPPROTO_IGMP = @as(c_int, 2);
pub const IPPROTO_GGP = @as(c_int, 3);
pub const IPPROTO_IPV4 = @as(c_int, 4);
pub const IPPROTO_IPIP = IPPROTO_IPV4;
pub const IPPROTO_ST = @as(c_int, 7);
pub const IPPROTO_EGP = @as(c_int, 8);
pub const IPPROTO_PIGP = @as(c_int, 9);
pub const IPPROTO_RCCMON = @as(c_int, 10);
pub const IPPROTO_NVPII = @as(c_int, 11);
pub const IPPROTO_PUP = @as(c_int, 12);
pub const IPPROTO_ARGUS = @as(c_int, 13);
pub const IPPROTO_EMCON = @as(c_int, 14);
pub const IPPROTO_XNET = @as(c_int, 15);
pub const IPPROTO_CHAOS = @as(c_int, 16);
pub const IPPROTO_MUX = @as(c_int, 18);
pub const IPPROTO_MEAS = @as(c_int, 19);
pub const IPPROTO_HMP = @as(c_int, 20);
pub const IPPROTO_PRM = @as(c_int, 21);
pub const IPPROTO_IDP = @as(c_int, 22);
pub const IPPROTO_TRUNK1 = @as(c_int, 23);
pub const IPPROTO_TRUNK2 = @as(c_int, 24);
pub const IPPROTO_LEAF1 = @as(c_int, 25);
pub const IPPROTO_LEAF2 = @as(c_int, 26);
pub const IPPROTO_RDP = @as(c_int, 27);
pub const IPPROTO_IRTP = @as(c_int, 28);
pub const IPPROTO_TP = @as(c_int, 29);
pub const IPPROTO_BLT = @as(c_int, 30);
pub const IPPROTO_NSP = @as(c_int, 31);
pub const IPPROTO_INP = @as(c_int, 32);
pub const IPPROTO_DCCP = @as(c_int, 33);
pub const IPPROTO_3PC = @as(c_int, 34);
pub const IPPROTO_IDPR = @as(c_int, 35);
pub const IPPROTO_XTP = @as(c_int, 36);
pub const IPPROTO_DDP = @as(c_int, 37);
pub const IPPROTO_CMTP = @as(c_int, 38);
pub const IPPROTO_TPXX = @as(c_int, 39);
pub const IPPROTO_IL = @as(c_int, 40);
pub const IPPROTO_SDRP = @as(c_int, 42);
pub const IPPROTO_ROUTING = @as(c_int, 43);
pub const IPPROTO_FRAGMENT = @as(c_int, 44);
pub const IPPROTO_IDRP = @as(c_int, 45);
pub const IPPROTO_RSVP = @as(c_int, 46);
pub const IPPROTO_GRE = @as(c_int, 47);
pub const IPPROTO_MHRP = @as(c_int, 48);
pub const IPPROTO_BHA = @as(c_int, 49);
pub const IPPROTO_ESP = @as(c_int, 50);
pub const IPPROTO_AH = @as(c_int, 51);
pub const IPPROTO_INLSP = @as(c_int, 52);
pub const IPPROTO_SWIPE = @as(c_int, 53);
pub const IPPROTO_NHRP = @as(c_int, 54);
pub const IPPROTO_MOBILE = @as(c_int, 55);
pub const IPPROTO_TLSP = @as(c_int, 56);
pub const IPPROTO_SKIP = @as(c_int, 57);
pub const IPPROTO_ICMPV6 = @as(c_int, 58);
pub const IPPROTO_NONE = @as(c_int, 59);
pub const IPPROTO_DSTOPTS = @as(c_int, 60);
pub const IPPROTO_AHIP = @as(c_int, 61);
pub const IPPROTO_CFTP = @as(c_int, 62);
pub const IPPROTO_HELLO = @as(c_int, 63);
pub const IPPROTO_SATEXPAK = @as(c_int, 64);
pub const IPPROTO_KRYPTOLAN = @as(c_int, 65);
pub const IPPROTO_RVD = @as(c_int, 66);
pub const IPPROTO_IPPC = @as(c_int, 67);
pub const IPPROTO_ADFS = @as(c_int, 68);
pub const IPPROTO_SATMON = @as(c_int, 69);
pub const IPPROTO_VISA = @as(c_int, 70);
pub const IPPROTO_IPCV = @as(c_int, 71);
pub const IPPROTO_CPNX = @as(c_int, 72);
pub const IPPROTO_CPHB = @as(c_int, 73);
pub const IPPROTO_WSN = @as(c_int, 74);
pub const IPPROTO_PVP = @as(c_int, 75);
pub const IPPROTO_BRSATMON = @as(c_int, 76);
pub const IPPROTO_ND = @as(c_int, 77);
pub const IPPROTO_WBMON = @as(c_int, 78);
pub const IPPROTO_WBEXPAK = @as(c_int, 79);
pub const IPPROTO_EON = @as(c_int, 80);
pub const IPPROTO_VMTP = @as(c_int, 81);
pub const IPPROTO_SVMTP = @as(c_int, 82);
pub const IPPROTO_VINES = @as(c_int, 83);
pub const IPPROTO_TTP = @as(c_int, 84);
pub const IPPROTO_IGP = @as(c_int, 85);
pub const IPPROTO_DGP = @as(c_int, 86);
pub const IPPROTO_TCF = @as(c_int, 87);
pub const IPPROTO_IGRP = @as(c_int, 88);
pub const IPPROTO_OSPFIGP = @as(c_int, 89);
pub const IPPROTO_SRPC = @as(c_int, 90);
pub const IPPROTO_LARP = @as(c_int, 91);
pub const IPPROTO_MTP = @as(c_int, 92);
pub const IPPROTO_AX25 = @as(c_int, 93);
pub const IPPROTO_IPEIP = @as(c_int, 94);
pub const IPPROTO_MICP = @as(c_int, 95);
pub const IPPROTO_SCCSP = @as(c_int, 96);
pub const IPPROTO_ETHERIP = @as(c_int, 97);
pub const IPPROTO_ENCAP = @as(c_int, 98);
pub const IPPROTO_APES = @as(c_int, 99);
pub const IPPROTO_GMTP = @as(c_int, 100);
pub const IPPROTO_IPCOMP = @as(c_int, 108);
pub const IPPROTO_SCTP = @as(c_int, 132);
pub const IPPROTO_MH = @as(c_int, 135);
pub const IPPROTO_UDPLITE = @as(c_int, 136);
pub const IPPROTO_HIP = @as(c_int, 139);
pub const IPPROTO_SHIM6 = @as(c_int, 140);
pub const IPPROTO_PIM = @as(c_int, 103);
pub const IPPROTO_CARP = @as(c_int, 112);
pub const IPPROTO_PGM = @as(c_int, 113);
pub const IPPROTO_MPLS = @as(c_int, 137);
pub const IPPROTO_PFSYNC = @as(c_int, 240);
pub const IPPROTO_RESERVED_253 = @as(c_int, 253);
pub const IPPROTO_RESERVED_254 = @as(c_int, 254);
pub const IPPROTO_OLD_DIVERT = @as(c_int, 254);
pub const IPPROTO_MAX = @as(c_int, 256);
pub const IPPROTO_DONE = @as(c_int, 257);
pub const IPPROTO_DIVERT = @as(c_int, 258);
pub const IPPROTO_SEND = @as(c_int, 259);
pub const IPPROTO_SPACER = @as(c_int, 32767);
pub const IPPORT_RESERVED = @as(c_int, 1024);
pub const IPPORT_EPHEMERALFIRST = @as(c_int, 10000);
pub const IPPORT_EPHEMERALLAST = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const IPPORT_HIFIRSTAUTO = __helpers.promoteIntLiteral(c_int, 49152, .decimal);
pub const IPPORT_HILASTAUTO = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const IPPORT_RESERVEDSTART = @as(c_int, 600);
pub const IPPORT_MAX = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const IN_HISTORICAL_NETS = "";
pub inline fn IN_CLASSA(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0x80000000, .hex)) == @as(c_int, 0)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0x80000000, .hex)) == @as(c_int, 0);
}
pub const IN_CLASSA_NET = __helpers.promoteIntLiteral(c_int, 0xff000000, .hex);
pub const IN_CLASSA_NSHIFT = @as(c_int, 24);
pub const IN_CLASSA_HOST = __helpers.promoteIntLiteral(c_int, 0x00ffffff, .hex);
pub const IN_CLASSA_MAX = @as(c_int, 128);
pub inline fn IN_CLASSB(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xc0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0x80000000, .hex)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xc0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0x80000000, .hex);
}
pub const IN_CLASSB_NET = __helpers.promoteIntLiteral(c_int, 0xffff0000, .hex);
pub const IN_CLASSB_NSHIFT = @as(c_int, 16);
pub const IN_CLASSB_HOST = __helpers.promoteIntLiteral(c_int, 0x0000ffff, .hex);
pub const IN_CLASSB_MAX = __helpers.promoteIntLiteral(c_int, 65536, .decimal);
pub inline fn IN_CLASSC(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xe0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xc0000000, .hex)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xe0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xc0000000, .hex);
}
pub const IN_CLASSC_NET = __helpers.promoteIntLiteral(c_int, 0xffffff00, .hex);
pub const IN_CLASSC_NSHIFT = @as(c_int, 8);
pub const IN_CLASSC_HOST = @as(c_int, 0x000000ff);
pub const IN_NETMASK_DEFAULT = __helpers.promoteIntLiteral(c_int, 0xffffff00, .hex);
pub inline fn IN_MULTICAST(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xe0000000, .hex)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xe0000000, .hex);
}
pub inline fn IN_CLASSD(i: anytype) @TypeOf(IN_MULTICAST(i)) {
    _ = &i;
    return IN_MULTICAST(i);
}
pub const IN_CLASSD_NET = __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex);
pub const IN_CLASSD_NSHIFT = @as(c_int, 28);
pub const IN_CLASSD_HOST = __helpers.promoteIntLiteral(c_int, 0x0fffffff, .hex);
pub inline fn IN_EXPERIMENTAL(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex);
}
pub inline fn IN_BADCLASS(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xf0000000, .hex);
}
pub inline fn IN_LINKLOCAL(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xffff0000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xa9fe0000, .hex)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xffff0000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xa9fe0000, .hex);
}
pub inline fn IN_LOOPBACK(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xff000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0x7f000000, .hex)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xff000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0x7f000000, .hex);
}
pub inline fn IN_ZERONET(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xff000000, .hex)) == @as(c_int, 0)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xff000000, .hex)) == @as(c_int, 0);
}
pub inline fn IN_PRIVATE(i: anytype) @TypeOf((((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xff000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0x0a000000, .hex)) or ((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xfff00000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xac100000, .hex))) or ((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xffff0000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xc0a80000, .hex))) {
    _ = &i;
    return (((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xff000000, .hex)) == __helpers.promoteIntLiteral(c_int, 0x0a000000, .hex)) or ((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xfff00000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xac100000, .hex))) or ((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xffff0000, .hex)) == __helpers.promoteIntLiteral(c_int, 0xc0a80000, .hex));
}
pub inline fn IN_LOCAL_GROUP(i: anytype) @TypeOf((__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xffffff00, .hex)) == __helpers.promoteIntLiteral(c_int, 0xe0000000, .hex)) {
    _ = &i;
    return (__helpers.cast(in_addr_t, i) & __helpers.promoteIntLiteral(c_int, 0xffffff00, .hex)) == __helpers.promoteIntLiteral(c_int, 0xe0000000, .hex);
}
pub inline fn IN_ANY_LOCAL(i: anytype) @TypeOf((IN_LINKLOCAL(i) != 0) or (IN_LOCAL_GROUP(i) != 0)) {
    _ = &i;
    return (IN_LINKLOCAL(i) != 0) or (IN_LOCAL_GROUP(i) != 0);
}
pub const INADDR_LOOPBACK = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0x7f000001, .hex));
pub const INADDR_NONE = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xffffffff, .hex));
pub const INADDR_UNSPEC_GROUP = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xe0000000, .hex));
pub const INADDR_ALLHOSTS_GROUP = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xe0000001, .hex));
pub const INADDR_ALLRTRS_GROUP = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xe0000002, .hex));
pub const INADDR_ALLRPTS_GROUP = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xe0000016, .hex));
pub const INADDR_CARP_GROUP = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xe0000012, .hex));
pub const INADDR_PFSYNC_GROUP = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xe00000f0, .hex));
pub const INADDR_ALLMDNS_GROUP = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xe00000fb, .hex));
pub const INADDR_MAX_LOCAL_GROUP = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xe00000ff, .hex));
pub const IN_LOOPBACKNET = @as(c_int, 127);
pub const IN_RFC3021_MASK = __helpers.cast(in_addr_t, __helpers.promoteIntLiteral(c_int, 0xfffffffe, .hex));
pub const IP_OPTIONS = @as(c_int, 1);
pub const IP_HDRINCL = @as(c_int, 2);
pub const IP_TOS = @as(c_int, 3);
pub const IP_TTL = @as(c_int, 4);
pub const IP_RECVOPTS = @as(c_int, 5);
pub const IP_RECVRETOPTS = @as(c_int, 6);
pub const IP_RECVDSTADDR = @as(c_int, 7);
pub const IP_SENDSRCADDR = IP_RECVDSTADDR;
pub const IP_RETOPTS = @as(c_int, 8);
pub const IP_MULTICAST_IF = @as(c_int, 9);
pub const IP_MULTICAST_TTL = @as(c_int, 10);
pub const IP_MULTICAST_LOOP = @as(c_int, 11);
pub const IP_ADD_MEMBERSHIP = @as(c_int, 12);
pub const IP_DROP_MEMBERSHIP = @as(c_int, 13);
pub const IP_MULTICAST_VIF = @as(c_int, 14);
pub const IP_RSVP_ON = @as(c_int, 15);
pub const IP_RSVP_OFF = @as(c_int, 16);
pub const IP_RSVP_VIF_ON = @as(c_int, 17);
pub const IP_RSVP_VIF_OFF = @as(c_int, 18);
pub const IP_PORTRANGE = @as(c_int, 19);
pub const IP_RECVIF = @as(c_int, 20);
pub const IP_IPSEC_POLICY = @as(c_int, 21);
pub const IP_ONESBCAST = @as(c_int, 23);
pub const IP_BINDANY = @as(c_int, 24);
pub const IP_ORIGDSTADDR = @as(c_int, 27);
pub const IP_RECVORIGDSTADDR = IP_ORIGDSTADDR;
pub const IP_FW_TABLE_ADD = @as(c_int, 40);
pub const IP_FW_TABLE_DEL = @as(c_int, 41);
pub const IP_FW_TABLE_FLUSH = @as(c_int, 42);
pub const IP_FW_TABLE_GETSIZE = @as(c_int, 43);
pub const IP_FW_TABLE_LIST = @as(c_int, 44);
pub const IP_FW3 = @as(c_int, 48);
pub const IP_DUMMYNET3 = @as(c_int, 49);
pub const IP_FW_ADD = @as(c_int, 50);
pub const IP_FW_DEL = @as(c_int, 51);
pub const IP_FW_FLUSH = @as(c_int, 52);
pub const IP_FW_ZERO = @as(c_int, 53);
pub const IP_FW_GET = @as(c_int, 54);
pub const IP_FW_RESETLOG = @as(c_int, 55);
pub const IP_FW_NAT_CFG = @as(c_int, 56);
pub const IP_FW_NAT_DEL = @as(c_int, 57);
pub const IP_FW_NAT_GET_CONFIG = @as(c_int, 58);
pub const IP_FW_NAT_GET_LOG = @as(c_int, 59);
pub const IP_DUMMYNET_CONFIGURE = @as(c_int, 60);
pub const IP_DUMMYNET_DEL = @as(c_int, 61);
pub const IP_DUMMYNET_FLUSH = @as(c_int, 62);
pub const IP_DUMMYNET_GET = @as(c_int, 64);
pub const IP_RECVTTL = @as(c_int, 65);
pub const IP_MINTTL = @as(c_int, 66);
pub const IP_DONTFRAG = @as(c_int, 67);
pub const IP_RECVTOS = @as(c_int, 68);
pub const IP_ADD_SOURCE_MEMBERSHIP = @as(c_int, 70);
pub const IP_DROP_SOURCE_MEMBERSHIP = @as(c_int, 71);
pub const IP_BLOCK_SOURCE = @as(c_int, 72);
pub const IP_UNBLOCK_SOURCE = @as(c_int, 73);
pub const IP_MSFILTER = @as(c_int, 74);
pub const IP_VLAN_PCP = @as(c_int, 75);
pub const MCAST_JOIN_GROUP = @as(c_int, 80);
pub const MCAST_LEAVE_GROUP = @as(c_int, 81);
pub const MCAST_JOIN_SOURCE_GROUP = @as(c_int, 82);
pub const MCAST_LEAVE_SOURCE_GROUP = @as(c_int, 83);
pub const MCAST_BLOCK_SOURCE = @as(c_int, 84);
pub const MCAST_UNBLOCK_SOURCE = @as(c_int, 85);
pub const IP_FLOWID = @as(c_int, 90);
pub const IP_FLOWTYPE = @as(c_int, 91);
pub const IP_RSSBUCKETID = @as(c_int, 92);
pub const IP_RECVFLOWID = @as(c_int, 93);
pub const IP_RECVRSSBUCKETID = @as(c_int, 94);
pub const IP_DEFAULT_MULTICAST_TTL = @as(c_int, 1);
pub const IP_DEFAULT_MULTICAST_LOOP = @as(c_int, 1);
pub const IP_MAX_MEMBERSHIPS = @as(c_int, 4095);
pub const IP_MAX_GROUP_SRC_FILTER = @as(c_int, 512);
pub const IP_MAX_SOCK_SRC_FILTER = @as(c_int, 128);
pub const IP_MAX_SOCK_MUTE_FILTER = @as(c_int, 128);
pub const __MSFILTERREQ_DEFINED = "";
pub const MCAST_UNDEFINED = @as(c_int, 0);
pub const MCAST_INCLUDE = @as(c_int, 1);
pub const MCAST_EXCLUDE = @as(c_int, 2);
pub const IP_PORTRANGE_DEFAULT = @as(c_int, 0);
pub const IP_PORTRANGE_HIGH = @as(c_int, 1);
pub const IP_PORTRANGE_LOW = @as(c_int, 2);
pub const IPCTL_FORWARDING = @as(c_int, 1);
pub const IPCTL_SENDREDIRECTS = @as(c_int, 2);
pub const IPCTL_DEFTTL = @as(c_int, 3);
pub const IPCTL_SOURCEROUTE = @as(c_int, 8);
pub const IPCTL_DIRECTEDBROADCAST = @as(c_int, 9);
pub const IPCTL_INTRQMAXLEN = @as(c_int, 10);
pub const IPCTL_INTRQDROPS = @as(c_int, 11);
pub const IPCTL_STATS = @as(c_int, 12);
pub const IPCTL_ACCEPTSOURCEROUTE = @as(c_int, 13);
pub const IPCTL_FASTFORWARDING = @as(c_int, 14);
pub const IPCTL_GIF_TTL = @as(c_int, 16);
pub const IPCTL_INTRDQMAXLEN = @as(c_int, 17);
pub const IPCTL_INTRDQDROPS = @as(c_int, 18);
pub const _NETINET6_IN6_H_ = "";
pub const __KAME__ = "";
pub const __KAME_VERSION = "FreeBSD";
pub const IPV6PORT_RESERVED = @as(c_int, 1024);
pub const IPV6PORT_ANONMIN = __helpers.promoteIntLiteral(c_int, 49152, .decimal);
pub const IPV6PORT_ANONMAX = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const IPV6PORT_RESERVEDMIN = @as(c_int, 600);
pub const IPV6PORT_RESERVEDMAX = IPV6PORT_RESERVED - @as(c_int, 1);
pub const s6_addr = @compileError("unable to translate macro: undefined identifier `__u6_addr`"); // /usr/include/netinet6/in6.h:102:9
pub const s6_addr8 = @compileError("unable to translate macro: undefined identifier `__u6_addr`"); // /usr/include/netinet6/in6.h:110:9
pub const s6_addr16 = @compileError("unable to translate macro: undefined identifier `__u6_addr`"); // /usr/include/netinet6/in6.h:111:9
pub const s6_addr32 = @compileError("unable to translate macro: undefined identifier `__u6_addr`"); // /usr/include/netinet6/in6.h:112:9
pub const INET6_ADDRSTRLEN = @as(c_int, 46);
pub const SIN6_LEN = "";
pub const IN6ADDR_ANY_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/netinet6/in6.h:191:9
pub const IN6ADDR_LOOPBACK_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/netinet6/in6.h:194:9
pub const IN6ADDR_NODELOCAL_ALLNODES_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/netinet6/in6.h:197:9
pub const IN6ADDR_INTFACELOCAL_ALLNODES_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/netinet6/in6.h:200:9
pub const IN6ADDR_LINKLOCAL_ALLNODES_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/netinet6/in6.h:203:9
pub const IN6ADDR_LINKLOCAL_ALLROUTERS_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/netinet6/in6.h:206:9
pub const IN6ADDR_LINKLOCAL_ALLV2ROUTERS_INIT = @compileError("unable to translate C expr: unexpected token '{'"); // /usr/include/netinet6/in6.h:209:9
pub const IN6_ARE_ADDR_EQUAL = @compileError("unable to translate macro: undefined identifier `memcmp`"); // /usr/include/netinet6/in6.h:227:9
pub inline fn IN6_IS_ADDR_UNSPECIFIED(a: anytype) @TypeOf((((a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0)) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 1)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 2)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 3)))] == @as(c_int, 0))) {
    _ = &a;
    return (((a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0)) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 1)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 2)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 3)))] == @as(c_int, 0));
}
pub inline fn IN6_IS_ADDR_LOOPBACK(a: anytype) @TypeOf((((a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0)) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 1)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 2)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 3)))] == ntohl(@as(c_int, 1)))) {
    _ = &a;
    return (((a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0)) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 1)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 2)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 3)))] == ntohl(@as(c_int, 1)));
}
pub inline fn IN6_IS_ADDR_V4COMPAT(a: anytype) @TypeOf(((((a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0)) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 1)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 2)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 3)))] != @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 3)))] != ntohl(@as(c_int, 1)))) {
    _ = &a;
    return ((((a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0)) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 1)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 2)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 3)))] != @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 3)))] != ntohl(@as(c_int, 1)));
}
pub inline fn IN6_IS_ADDR_V4MAPPED(a: anytype) @TypeOf(((a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0)) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 1)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 2)))] == ntohl(__helpers.promoteIntLiteral(c_int, 0x0000ffff, .hex)))) {
    _ = &a;
    return ((a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0)) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 1)))] == @as(c_int, 0))) and (a.*.__u6_addr.__u6_addr32[@as(usize, @intCast(@as(c_int, 2)))] == ntohl(__helpers.promoteIntLiteral(c_int, 0x0000ffff, .hex)));
}
pub const __IPV6_ADDR_SCOPE_NODELOCAL = @as(c_int, 0x01);
pub const __IPV6_ADDR_SCOPE_INTFACELOCAL = @as(c_int, 0x01);
pub const __IPV6_ADDR_SCOPE_LINKLOCAL = @as(c_int, 0x02);
pub const __IPV6_ADDR_SCOPE_SITELOCAL = @as(c_int, 0x05);
pub const __IPV6_ADDR_SCOPE_ORGLOCAL = @as(c_int, 0x08);
pub const __IPV6_ADDR_SCOPE_GLOBAL = @as(c_int, 0x0e);
pub inline fn IN6_IS_ADDR_LINKLOCAL(a: anytype) @TypeOf((a.*.s6_addr[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0xfe)) and ((a.*.s6_addr[@as(usize, @intCast(@as(c_int, 1)))] & @as(c_int, 0xc0)) == @as(c_int, 0x80))) {
    _ = &a;
    return (a.*.s6_addr[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0xfe)) and ((a.*.s6_addr[@as(usize, @intCast(@as(c_int, 1)))] & @as(c_int, 0xc0)) == @as(c_int, 0x80));
}
pub inline fn IN6_IS_ADDR_SITELOCAL(a: anytype) @TypeOf((a.*.s6_addr[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0xfe)) and ((a.*.s6_addr[@as(usize, @intCast(@as(c_int, 1)))] & @as(c_int, 0xc0)) == @as(c_int, 0xc0))) {
    _ = &a;
    return (a.*.s6_addr[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0xfe)) and ((a.*.s6_addr[@as(usize, @intCast(@as(c_int, 1)))] & @as(c_int, 0xc0)) == @as(c_int, 0xc0));
}
pub inline fn IN6_IS_ADDR_MULTICAST(a: anytype) @TypeOf(a.*.s6_addr[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0xff)) {
    _ = &a;
    return a.*.s6_addr[@as(usize, @intCast(@as(c_int, 0)))] == @as(c_int, 0xff);
}
pub inline fn __IPV6_ADDR_MC_SCOPE(a: anytype) @TypeOf(a.*.s6_addr[@as(usize, @intCast(@as(c_int, 1)))] & @as(c_int, 0x0f)) {
    _ = &a;
    return a.*.s6_addr[@as(usize, @intCast(@as(c_int, 1)))] & @as(c_int, 0x0f);
}
pub inline fn IN6_IS_ADDR_MC_NODELOCAL(a: anytype) @TypeOf((IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_NODELOCAL)) {
    _ = &a;
    return (IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_NODELOCAL);
}
pub inline fn IN6_IS_ADDR_MC_LINKLOCAL(a: anytype) @TypeOf((IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_LINKLOCAL)) {
    _ = &a;
    return (IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_LINKLOCAL);
}
pub inline fn IN6_IS_ADDR_MC_SITELOCAL(a: anytype) @TypeOf((IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_SITELOCAL)) {
    _ = &a;
    return (IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_SITELOCAL);
}
pub inline fn IN6_IS_ADDR_MC_ORGLOCAL(a: anytype) @TypeOf((IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_ORGLOCAL)) {
    _ = &a;
    return (IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_ORGLOCAL);
}
pub inline fn IN6_IS_ADDR_MC_GLOBAL(a: anytype) @TypeOf((IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_GLOBAL)) {
    _ = &a;
    return (IN6_IS_ADDR_MULTICAST(a) != 0) and (__IPV6_ADDR_MC_SCOPE(a) == __IPV6_ADDR_SCOPE_GLOBAL);
}
pub const IPV6_SOCKOPT_RESERVED1 = @as(c_int, 3);
pub const IPV6_UNICAST_HOPS = @as(c_int, 4);
pub const IPV6_MULTICAST_IF = @as(c_int, 9);
pub const IPV6_MULTICAST_HOPS = @as(c_int, 10);
pub const IPV6_MULTICAST_LOOP = @as(c_int, 11);
pub const IPV6_JOIN_GROUP = @as(c_int, 12);
pub const IPV6_LEAVE_GROUP = @as(c_int, 13);
pub const IPV6_PORTRANGE = @as(c_int, 14);
pub const ICMP6_FILTER = @as(c_int, 18);
pub const IPV6_CHECKSUM = @as(c_int, 26);
pub const IPV6_V6ONLY = @as(c_int, 27);
pub const IPV6_BINDV6ONLY = IPV6_V6ONLY;
pub const IPV6_IPSEC_POLICY = @as(c_int, 28);
pub const IPV6_FW_ADD = @as(c_int, 30);
pub const IPV6_FW_DEL = @as(c_int, 31);
pub const IPV6_FW_FLUSH = @as(c_int, 32);
pub const IPV6_FW_ZERO = @as(c_int, 33);
pub const IPV6_FW_GET = @as(c_int, 34);
pub const IPV6_RTHDRDSTOPTS = @as(c_int, 35);
pub const IPV6_RECVPKTINFO = @as(c_int, 36);
pub const IPV6_RECVHOPLIMIT = @as(c_int, 37);
pub const IPV6_RECVRTHDR = @as(c_int, 38);
pub const IPV6_RECVHOPOPTS = @as(c_int, 39);
pub const IPV6_RECVDSTOPTS = @as(c_int, 40);
pub const IPV6_USE_MIN_MTU = @as(c_int, 42);
pub const IPV6_RECVPATHMTU = @as(c_int, 43);
pub const IPV6_PATHMTU = @as(c_int, 44);
pub const IPV6_PKTINFO = @as(c_int, 46);
pub const IPV6_HOPLIMIT = @as(c_int, 47);
pub const IPV6_NEXTHOP = @as(c_int, 48);
pub const IPV6_HOPOPTS = @as(c_int, 49);
pub const IPV6_DSTOPTS = @as(c_int, 50);
pub const IPV6_RTHDR = @as(c_int, 51);
pub const IPV6_RECVTCLASS = @as(c_int, 57);
pub const IPV6_AUTOFLOWLABEL = @as(c_int, 59);
pub const IPV6_TCLASS = @as(c_int, 61);
pub const IPV6_DONTFRAG = @as(c_int, 62);
pub const IPV6_PREFER_TEMPADDR = @as(c_int, 63);
pub const IPV6_BINDANY = @as(c_int, 64);
pub const IPV6_FLOWID = @as(c_int, 67);
pub const IPV6_FLOWTYPE = @as(c_int, 68);
pub const IPV6_RSSBUCKETID = @as(c_int, 69);
pub const IPV6_RECVFLOWID = @as(c_int, 70);
pub const IPV6_RECVRSSBUCKETID = @as(c_int, 71);
pub const IPV6_ORIGDSTADDR = @as(c_int, 72);
pub const IPV6_RECVORIGDSTADDR = IPV6_ORIGDSTADDR;
pub const IPV6_MSFILTER = @as(c_int, 74);
pub const IPV6_VLAN_PCP = @as(c_int, 75);
pub const IPV6_RTHDR_LOOSE = @as(c_int, 0);
pub const IPV6_RTHDR_STRICT = @as(c_int, 1);
pub const IPV6_RTHDR_TYPE_0 = @as(c_int, 0);
pub const IPV6_DEFAULT_MULTICAST_HOPS = @as(c_int, 1);
pub const IPV6_DEFAULT_MULTICAST_LOOP = @as(c_int, 1);
pub const IPV6_MAX_MEMBERSHIPS = @as(c_int, 4095);
pub const IPV6_MAX_GROUP_SRC_FILTER = @as(c_int, 512);
pub const IPV6_MAX_SOCK_SRC_FILTER = @as(c_int, 128);
pub const IPV6_PORTRANGE_DEFAULT = @as(c_int, 0);
pub const IPV6_PORTRANGE_HIGH = @as(c_int, 1);
pub const IPV6_PORTRANGE_LOW = @as(c_int, 2);
pub const IPV6PROTO_MAXID = IPPROTO_PIM + @as(c_int, 1);
pub const IPV6CTL_FORWARDING = @as(c_int, 1);
pub const IPV6CTL_SENDREDIRECTS = @as(c_int, 2);
pub const IPV6CTL_DEFHLIM = @as(c_int, 3);
pub const IPV6CTL_FORWSRCRT = @as(c_int, 5);
pub const IPV6CTL_STATS = @as(c_int, 6);
pub const IPV6CTL_MRTSTATS = @as(c_int, 7);
pub const IPV6CTL_MRTPROTO = @as(c_int, 8);
pub const IPV6CTL_MAXFRAGPACKETS = @as(c_int, 9);
pub const IPV6CTL_SOURCECHECK = @as(c_int, 10);
pub const IPV6CTL_SOURCECHECK_LOGINT = @as(c_int, 11);
pub const IPV6CTL_ACCEPT_RTADV = @as(c_int, 12);
pub const IPV6CTL_LOG_INTERVAL = @as(c_int, 14);
pub const IPV6CTL_HDRNESTLIMIT = @as(c_int, 15);
pub const IPV6CTL_DAD_COUNT = @as(c_int, 16);
pub const IPV6CTL_AUTO_FLOWLABEL = @as(c_int, 17);
pub const IPV6CTL_DEFMCASTHLIM = @as(c_int, 18);
pub const IPV6CTL_GIF_HLIM = @as(c_int, 19);
pub const IPV6CTL_KAME_VERSION = @as(c_int, 20);
pub const IPV6CTL_USE_DEPRECATED = @as(c_int, 21);
pub const IPV6CTL_RR_PRUNE = @as(c_int, 22);
pub const IPV6CTL_V6ONLY = @as(c_int, 24);
pub const IPV6CTL_USETEMPADDR = @as(c_int, 32);
pub const IPV6CTL_TEMPPLTIME = @as(c_int, 33);
pub const IPV6CTL_TEMPVLTIME = @as(c_int, 34);
pub const IPV6CTL_AUTO_LINKLOCAL = @as(c_int, 35);
pub const IPV6CTL_RIP6STATS = @as(c_int, 36);
pub const IPV6CTL_PREFER_TEMPADDR = @as(c_int, 37);
pub const IPV6CTL_ADDRCTLPOLICY = @as(c_int, 38);
pub const IPV6CTL_USE_DEFAULTZONE = @as(c_int, 39);
pub const IPV6CTL_MAXFRAGS = @as(c_int, 41);
pub const IPV6CTL_MCAST_PMTU = @as(c_int, 44);
pub const IPV6CTL_STEALTH = @as(c_int, 45);
pub const ICMPV6CTL_ND6_ONLINKNSRFC4861 = @as(c_int, 47);
pub const IPV6CTL_NO_RADR = @as(c_int, 48);
pub const IPV6CTL_NORBIT_RAIF = @as(c_int, 49);
pub const IPV6CTL_RFC6204W3 = @as(c_int, 50);
pub const IPV6CTL_INTRQMAXLEN = @as(c_int, 51);
pub const IPV6CTL_INTRDQMAXLEN = @as(c_int, 52);
pub const IPV6CTL_MAXFRAGSPERPACKET = @as(c_int, 53);
pub const IPV6CTL_MAXFRAGBUCKETSIZE = @as(c_int, 54);
pub const IPV6CTL_MAXID = @as(c_int, 55);
pub const M_FASTFWD_OURS = @compileError("unable to translate macro: undefined identifier `M_PROTO1`"); // /usr/include/netinet6/in6.h:650:9
pub const M_IP6_NEXTHOP = @compileError("unable to translate macro: undefined identifier `M_PROTO2`"); // /usr/include/netinet6/in6.h:651:9
pub const M_IP_NEXTHOP = @compileError("unable to translate macro: undefined identifier `M_PROTO2`"); // /usr/include/netinet6/in6.h:652:9
pub const M_SKIP_FIREWALL = @compileError("unable to translate macro: undefined identifier `M_PROTO3`"); // /usr/include/netinet6/in6.h:653:9
pub const M_AUTHIPHDR = @compileError("unable to translate macro: undefined identifier `M_PROTO4`"); // /usr/include/netinet6/in6.h:654:9
pub const M_DECRYPTED = @compileError("unable to translate macro: undefined identifier `M_PROTO5`"); // /usr/include/netinet6/in6.h:655:9
pub const M_LOOP = @compileError("unable to translate macro: undefined identifier `M_PROTO6`"); // /usr/include/netinet6/in6.h:656:9
pub const M_AUTHIPDGM = @compileError("unable to translate macro: undefined identifier `M_PROTO7`"); // /usr/include/netinet6/in6.h:657:9
pub const M_RTALERT_MLD = @compileError("unable to translate macro: undefined identifier `M_PROTO8`"); // /usr/include/netinet6/in6.h:658:9
pub const M_FRAGMENTED = @compileError("unable to translate macro: undefined identifier `M_PROTO9`"); // /usr/include/netinet6/in6.h:659:9
pub const _SIZE_T_DECLARED = "";
pub const __timer = struct___timer;
pub const __mq = struct___mq;
pub const in_addr = struct_in_addr;
pub const sockaddr_storage = struct_sockaddr_storage;
pub const sockaddr_in = struct_sockaddr_in;
pub const ip_mreq = struct_ip_mreq;
pub const ip_mreqn = struct_ip_mreqn;
pub const ip_mreq_source = struct_ip_mreq_source;
pub const group_req = struct_group_req;
pub const group_source_req = struct_group_source_req;
pub const __msfilterreq = struct___msfilterreq;
pub const sockaddr = struct_sockaddr;
pub const in6_addr = struct_in6_addr;
pub const sockaddr_in6 = struct_sockaddr_in6;
pub const nhop_object = struct_nhop_object;
pub const route_in6 = struct_route_in6;
pub const ipv6_mreq = struct_ipv6_mreq;
pub const in6_pktinfo = struct_in6_pktinfo;
pub const ip6_mtuinfo = struct_ip6_mtuinfo;
pub const cmsghdr = struct_cmsghdr;
