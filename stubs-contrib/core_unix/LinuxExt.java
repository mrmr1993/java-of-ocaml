/**
 * Linux-specific Core extensions from [core.linux_ext]. Wraps
 * Linux-only syscalls: [epoll(7)], [eventfd(2)], [timerfd(2)],
 * [xattr(7)], [sysinfo(2)], [prctl(2)], [sendfile(2)], plus
 * socket / scheduler extras.
 *
 * ### Constants (real Linux/x86_64 ABI values)
 *
 * The flag-bit and clock-ID constants must match the kernel ABI
 * exactly — [Core.Linux_ext] wraps each in a [Flags.Make] shell
 * that asserts each bit is non-zero. We return the same values
 * [core/linux_ext/linux_ext_stubs.c] returns on Linux/x86_64.
 *
 * ### Syscall stubs (zero-returners)
 *
 * [epoll_create], [epoll_wait], [epoll_ctl_*], [eventfd],
 * [eventfd_read/write], [timerfd_create/gettime/settime],
 * [xattr_get/set], [sysinfo], [getpriority/setpriority],
 * [pr_get/set_name], [pr_get/set_pdeathsig_stub],
 * [sched_getaffinity/setaffinity], [send_*_no_sigpipe_stub],
 * [sendfile_stub], [peer_credentials], [getxattr/setxattr],
 * [gettcpopt_bool_stub/settcpopt_bool_stub],
 * [bind_to_interface / get_bind_to_interface /
 * get_ipv4_address_for_interface / get_terminal_size]: all
 * stub to [0] for init-time callers that only reference them.
 *
 * A real [epoll] implementation on JVM would delegate to
 * [java.nio.channels.Selector] — out of scope here.
 */
public final class LinuxExt {
    private LinuxExt() {}

    // ==== epoll event bits (from <sys/epoll.h>) ========================

    public static long EPOLLIN_flag(Object ignore)       { return 0x001; }
    public static long EPOLLPRI_flag(Object ignore)      { return 0x002; }
    public static long EPOLLOUT_flag(Object ignore)      { return 0x004; }
    public static long EPOLLERR_flag(Object ignore)      { return 0x008; }
    public static long EPOLLHUP_flag(Object ignore)      { return 0x010; }
    public static long EPOLLRDHUP_flag(Object ignore)    { return 0x2000; }
    public static long EPOLLET_flag(Object ignore)       { return 0x80000000L; }
    public static long EPOLLONESHOT_flag(Object ignore)  { return 0x40000000L; }

    /** [sizeof(struct epoll_event)] on Linux/x86_64 = 12
     *  (packed: 4-byte events + 8-byte data, no padding since GCC's
     *  [__attribute__((packed))] on that struct in the kernel header). */
    public static long sizeof_epoll_event(Object ignore) { return 12; }
    /** [offsetof(epoll_event, events)] = 0. */
    public static long offsetof_readyflags(Object ignore){ return 0; }
    /** [offsetof(epoll_event, data.fd)] = 4 (first field of the
     *  union, after the 4-byte events). */
    public static long offsetof_readyfd(Object ignore)   { return 4; }

    // ==== eventfd flags (<sys/eventfd.h>) ==============================

    public static long EFD_CLOEXEC(Object ignore)   { return 0x80000; }
    public static long EFD_NONBLOCK(Object ignore)  { return 0x800; }
    public static long EFD_SEMAPHORE(Object ignore) { return 1; }

    // ==== timerfd (<sys/timerfd.h>) ====================================

    public static long CLOCK_MONOTONIC(Object ignore) { return 1; }
    public static long CLOCK_REALTIME(Object ignore)  { return 0; }
    public static long TFD_CLOEXEC(Object ignore)     { return 0x80000; }
    public static long TFD_NONBLOCK(Object ignore)    { return 0x800; }

    // ==== xattr (<sys/xattr.h>) ========================================

    public static long XATTR_CREATE_flag(Object ignore)  { return 1; }
    public static long XATTR_REPLACE_flag(Object ignore) { return 2; }

    // ==== syscall zero-returners =======================================

    private static final Object ZERO = Long.valueOf(0L);

    public static Object zero(Object a)                                { return ZERO; }
    public static Object zero(Object a, Object b)                      { return ZERO; }
    public static Object zero(Object a, Object b, Object c)            { return ZERO; }
    public static Object zero(Object a, Object b, Object c, Object d)  { return ZERO; }
    public static Object zero(Object a, Object b, Object c, Object d, Object e) {
        return ZERO;
    }
    public static Object zero(Object a, Object b, Object c, Object d, Object e,
                              Object f) {
        return ZERO;
    }
}
