/**
 * Stubs for Jane Street's [core_unix] / [core_linux] / bigstring /
 * iobuf C primitives. Not part of js_of_ocaml's built-in
 * runtime — these libraries don't ship JS stubs either. Opt in
 * via [--stub-manifest stubs-contrib/core_unix/stubs.json].
 *
 * The package is large; groups here:
 *
 *   - [unix_O_*] / [unix_F_*] / [unix_FD_*]: syscall flag
 *     constants (Linux fcntl.h). In [core v0.14.1] these still
 *     carry the [unix_*] prefix despite being core_unix-owned.
 *   - [core_linux_*_flag], [core_linux_*_offsetof_*]: kernel ABI
 *     bits for epoll / eventfd / timerfd / xattr.
 *   - [core_unix_getrlimit] / inet4_* / error_of_code: small
 *     stubs returning structurally-valid shapes so Core's init
 *     checks pass.
 *   - [bigstring_alloc]: routes to [BigArray.allocBigstring].
 *   - Zero-returners ([unix_close], [unix_open], [bigstring_*_stub],
 *     [iobuf_*], the ~200-prim family): overloads of [zero] by
 *     arity; the manifest's shorthand form picks the right one
 *     per call site.
 */
public final class CoreUnix {
    private CoreUnix() {}

    // ===== Zero-returning bulk (unix / core_unix / core_linux /
    // bigstring / iobuf syscall family). Overloaded by arity so
    // shorthand manifest entries pick the matching Java method. =====

    private static final Object ZERO = Long.valueOf(0L);

    public static Object zero()                                       { return ZERO; }
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

    // ===== core_unix syscall flags (returned as primitive long so
    // the compiler keeps them as K_int). =====

    public static long O_RDONLY(Object ignore)    { return 0; }
    public static long O_WRONLY(Object ignore)    { return 1; }
    public static long O_RDWR(Object ignore)      { return 2; }
    public static long O_CREAT(Object ignore)     { return 0x40; }
    public static long O_EXCL(Object ignore)      { return 0x80; }
    public static long O_NOCTTY(Object ignore)    { return 0x100; }
    public static long O_TRUNC(Object ignore)     { return 0x200; }
    public static long O_APPEND(Object ignore)    { return 0x400; }
    public static long O_NONBLOCK(Object ignore)  { return 0x800; }
    public static long O_DSYNC(Object ignore)     { return 0x1000; }
    public static long O_ASYNC(Object ignore)     { return 0x2000; }
    public static long O_DIRECT(Object ignore)    { return 0x4000; }
    public static long O_DIRECTORY(Object ignore) { return 0x10000; }
    public static long O_NOFOLLOW(Object ignore)  { return 0x20000; }
    public static long O_NOATIME(Object ignore)   { return 0x40000; }
    public static long O_CLOEXEC(Object ignore)   { return 0x80000; }
    public static long O_SYNC(Object ignore)      { return 0x101000; }
    public static long O_RSYNC(Object ignore)     { return 0x101000; }

    public static long F_GETFD(Object ignore)     { return 1; }
    public static long F_SETFD(Object ignore)     { return 2; }
    public static long F_GETFL(Object ignore)     { return 3; }
    public static long F_SETFL(Object ignore)     { return 4; }
    public static long FD_CLOEXEC(Object ignore)  { return 1; }

    // ===== core_linux epoll / eventfd / timerfd / xattr ABI =====

    public static long EPOLLIN_flag(Object ignore)       { return 0x001; }
    public static long EPOLLPRI_flag(Object ignore)      { return 0x002; }
    public static long EPOLLOUT_flag(Object ignore)      { return 0x004; }
    public static long EPOLLERR_flag(Object ignore)      { return 0x008; }
    public static long EPOLLHUP_flag(Object ignore)      { return 0x010; }
    public static long EPOLLET_flag(Object ignore)       { return 0x80000000L; }
    public static long EPOLLONESHOT_flag(Object ignore)  { return 0x40000000L; }
    public static long sizeof_epoll_event(Object ignore) { return 12; }
    public static long offsetof_readyfd(Object ignore)   { return 4; }
    public static long offsetof_readyflags(Object ignore){ return 0; }

    public static long EFD_CLOEXEC(Object ignore)   { return 0x80000; }
    public static long EFD_NONBLOCK(Object ignore)  { return 0x800; }
    public static long EFD_SEMAPHORE(Object ignore) { return 1; }

    public static long CLOCK_MONOTONIC(Object ignore) { return 1; }
    public static long CLOCK_REALTIME(Object ignore)  { return 0; }
    public static long TFD_CLOEXEC(Object ignore)     { return 0x80000; }
    public static long TFD_NONBLOCK(Object ignore)    { return 0x800; }

    public static long XATTR_CREATE_flag(Object ignore)  { return 1; }
    public static long XATTR_REPLACE_flag(Object ignore) { return 2; }

    // ===== core_unix special-case stubs =====

    /**
     * [getrlimit resource] — returns [{rlim_cur; rlim_max}] where
     * each field is [Rlim.t = Infinity | Limit of Int63]. Return
     * [{Limit max; Limit max}]; OCaml reads each field as an
     * optional "no limit" sentinel.
     */
    public static Object getrlimit(Object resource) {
        Object limit = new Block(0, new Object[] {
            Long.valueOf(0x3fffffffffffffffL)
        });
        return new Block(0, new Object[] { limit, limit });
    }

    /** Parse IPv4 "a.b.c.d" → 32-bit integer. Stub: 127.0.0.1. */
    public static long inet4_addr_to_int(Object s) {
        return 0x7F000001L;
    }

    /** Inverse — stub returns "127.0.0.1" regardless. */
    public static String inet4_addr_of_int(long v) {
        return "127.0.0.1";
    }

    /** errno → Unix.error. EAGAIN=11 consistently. */
    public static long error_of_code(long code) { return 11; }

    /** Unix.error → errno. 0 (no error). */
    public static long code_of_error(Object e) { return 0; }

    /**
     * [bigstring_alloc pos len]. Size is [len]; [pos] is ignored.
     * Delegates to the built-in [BigArray] runtime class.
     */
    public static Object bigstring_alloc(Object pos, long len) {
        return BigArray.allocBigstring(len);
    }
}
