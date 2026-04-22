/**
 * Numeric-constant C primitives referenced during module init.
 * Every method returns a primitive [long] (JVM descriptor [()J])
 * so the compiler keeps the value as [K_int] and downstream code
 * consumes it without going through [Long.valueOf] / [asLong].
 *
 * Groups: unix O_* / F_* / FD_* open / fcntl flags; core_linux
 * epoll / eventfd / timerfd bits; integers_* range + size
 * constants; ctypes POSIX typeof / sizeof / alignmentof.
 *
 * The ctypes_typeof_* values are [Ctypes_static.arithmetic] variant
 * tags: Int8=0 Int16=1 Int32=2 Int64=3 Uint8=4 Uint16=5 Uint32=6
 * Uint64=7 Float=8 Double=9. Using Linux/x86_64 ABI typedefs (so
 * [mkSigned] / [mkUnsigned] in posixTypes.ml don't [assert false]).
 */
public final class ConstantStubs {
    private ConstantStubs() {}

    // ---- unix O_* (Linux fcntl.h) ----
    public static long unix_O_RDONLY(Object ignore) { return 0; }
    public static long unix_O_WRONLY(Object ignore) { return 1; }
    public static long unix_O_RDWR(Object ignore) { return 2; }
    public static long unix_O_CREAT(Object ignore) { return 0x40; }
    public static long unix_O_EXCL(Object ignore) { return 0x80; }
    public static long unix_O_NOCTTY(Object ignore) { return 0x100; }
    public static long unix_O_TRUNC(Object ignore) { return 0x200; }
    public static long unix_O_APPEND(Object ignore) { return 0x400; }
    public static long unix_O_NONBLOCK(Object ignore) { return 0x800; }
    public static long unix_O_DSYNC(Object ignore) { return 0x1000; }
    public static long unix_O_ASYNC(Object ignore) { return 0x2000; }
    public static long unix_O_DIRECT(Object ignore) { return 0x4000; }
    public static long unix_O_DIRECTORY(Object ignore) { return 0x10000; }
    public static long unix_O_NOFOLLOW(Object ignore) { return 0x20000; }
    public static long unix_O_NOATIME(Object ignore) { return 0x40000; }
    public static long unix_O_CLOEXEC(Object ignore) { return 0x80000; }
    public static long unix_O_SYNC(Object ignore) { return 0x101000; }
    public static long unix_O_RSYNC(Object ignore) { return 0x101000; }

    // ---- unix F_*, FD_* (fcntl commands + flags) ----
    public static long unix_F_GETFD(Object ignore) { return 1; }
    public static long unix_F_SETFD(Object ignore) { return 2; }
    public static long unix_F_GETFL(Object ignore) { return 3; }
    public static long unix_F_SETFL(Object ignore) { return 4; }
    public static long unix_FD_CLOEXEC(Object ignore) { return 1; }

    // ---- core_linux epoll / eventfd / timerfd ----
    public static long core_linux_epoll_EPOLLIN_flag(Object ignore) { return 0x001; }
    public static long core_linux_epoll_EPOLLPRI_flag(Object ignore) { return 0x002; }
    public static long core_linux_epoll_EPOLLOUT_flag(Object ignore) { return 0x004; }
    public static long core_linux_epoll_EPOLLERR_flag(Object ignore) { return 0x008; }
    public static long core_linux_epoll_EPOLLHUP_flag(Object ignore) { return 0x010; }
    public static long core_linux_epoll_EPOLLET_flag(Object ignore) { return 0x80000000L; }
    public static long core_linux_epoll_EPOLLONESHOT_flag(Object ignore) { return 0x40000000L; }
    public static long core_linux_epoll_sizeof_epoll_event(Object ignore) { return 12; }
    public static long core_linux_epoll_offsetof_readyfd(Object ignore) { return 4; }
    public static long core_linux_epoll_offsetof_readyflags(Object ignore) { return 0; }

    public static long core_linux_eventfd_EFD_CLOEXEC(Object ignore) { return 0x80000; }
    public static long core_linux_eventfd_EFD_NONBLOCK(Object ignore) { return 0x800; }
    public static long core_linux_eventfd_EFD_SEMAPHORE(Object ignore) { return 1; }

    public static long core_linux_timerfd_CLOCK_MONOTONIC(Object ignore) { return 1; }
    public static long core_linux_timerfd_CLOCK_REALTIME(Object ignore) { return 0; }
    public static long core_linux_timerfd_TFD_CLOEXEC(Object ignore) { return 0x80000; }
    public static long core_linux_timerfd_TFD_NONBLOCK(Object ignore) { return 0x800; }

    public static long core_linux_xattr_XATTR_CREATE_flag(Object ignore) { return 1; }
    public static long core_linux_xattr_XATTR_REPLACE_flag(Object ignore) { return 2; }

    // ---- integers library: ranges + sizes ----
    public static long integers_uint8_max(Object ignore) { return 0xFFL; }
    public static long integers_uint8_min(Object ignore) { return 0; }
    public static long integers_uint16_max(Object ignore) { return 0xFFFFL; }
    public static long integers_uint16_min(Object ignore) { return 0; }
    public static long integers_uint32_max(Object ignore) { return 0xFFFFFFFFL; }
    public static long integers_uint32_min(Object ignore) { return 0; }
    public static long integers_uint64_max(Object ignore) { return -1L; }  // all bits set
    public static long integers_uint64_min(Object ignore) { return 0; }

    public static long integers_size_t_size(Object ignore) { return 8; }
    public static long integers_ushort_size(Object ignore) { return 2; }
    public static long integers_uint_size(Object ignore) { return 4; }
    public static long integers_ulong_size(Object ignore) { return 8; }
    public static long integers_ulonglong_size(Object ignore) { return 8; }
    public static long integers_intptr_t_size(Object ignore) { return 8; }
    public static long integers_uintptr_t_size(Object ignore) { return 8; }
    public static long integers_ptrdiff_t_size(Object ignore) { return 8; }

    // ---- ctypes typeof_* (arithmetic variant tags) ----
    public static long ctypes_typeof_clock_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_dev_t(Object ignore) { return 7; /* Uint64 */ }
    public static long ctypes_typeof_ino_t(Object ignore) { return 7; /* Uint64 */ }
    public static long ctypes_typeof_mode_t(Object ignore) { return 6; /* Uint32 */ }
    public static long ctypes_typeof_nlink_t(Object ignore) { return 7; /* Uint64 */ }
    public static long ctypes_typeof_off_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_pid_t(Object ignore) { return 2; /* Int32 */ }
    public static long ctypes_typeof_ssize_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_time_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_useconds_t(Object ignore) { return 6; /* Uint32 */ }
    public static long ctypes_typeof_uid_t(Object ignore) { return 6; /* Uint32 */ }
    public static long ctypes_typeof_gid_t(Object ignore) { return 6; /* Uint32 */ }
    public static long ctypes_typeof_blkcnt_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_blksize_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_fsblkcnt_t(Object ignore) { return 7; /* Uint64 */ }
    public static long ctypes_typeof_fsfilcnt_t(Object ignore) { return 7; /* Uint64 */ }
    public static long ctypes_typeof_id_t(Object ignore) { return 6; /* Uint32 */ }
    public static long ctypes_typeof_key_t(Object ignore) { return 2; /* Int32 */ }
    public static long ctypes_typeof_suseconds_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_speed_t(Object ignore) { return 6; /* Uint32 */ }
    public static long ctypes_typeof_cc_t(Object ignore) { return 4; /* Uint8 */ }
    public static long ctypes_typeof_tcflag_t(Object ignore) { return 6; /* Uint32 */ }
    public static long ctypes_typeof_nfds_t(Object ignore) { return 7; /* Uint64 */ }
    public static long ctypes_typeof_rlim_t(Object ignore) { return 7; /* Uint64 */ }
    public static long ctypes_typeof_socklen_t(Object ignore) { return 6; /* Uint32 */ }
    public static long ctypes_typeof_intptr_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_uintptr_t(Object ignore) { return 7; /* Uint64 */ }
    public static long ctypes_typeof_ptrdiff_t(Object ignore) { return 3; /* Int64 */ }
    public static long ctypes_typeof_sigset_t(Object ignore) { return 7; /* Uint64, opaque */ }

    // ---- ctypes alignment / size of opaque POSIX types ----
    public static long ctypes_alignmentof_sigset_t(Object ignore) { return 8; }
    public static long ctypes_alignmentof_fd_set(Object ignore) { return 8; }
    public static long ctypes_sizeof_sigset_t(Object ignore) { return 128; }
    public static long ctypes_sizeof_fd_set(Object ignore) { return 128; }
}
