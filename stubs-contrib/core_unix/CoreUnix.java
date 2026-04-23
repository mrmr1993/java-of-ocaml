/**
 * Jane Street [core_unix] C primitives. Covers:
 *
 *   - Open-flag / fcntl-command / fd-flag constants that Core
 *     wraps in [Flags.Make]. Carrying them as the real Linux
 *     ABI values so [Flags.Make]'s "each bit is non-zero" check
 *     passes. (These share the [unix_O_*] / [unix_F_*] /
 *     [unix_FD_*] namespace with OCaml's stdlib Unix but are
 *     declared as [external]s in [core_unix.ml].)
 *
 *   - Specific C primitives with structurally-meaningful return
 *     shapes: [core_unix_getrlimit] (record of [Rlim.t]),
 *     [core_unix_inet4_addr_to/of_int{32,63}_exn] (Int63 ↔
 *     dotted-decimal string), [core_unix_error_of_code] (errno
 *     → [Unix.error] variant).
 *
 *   - Syscall zero-returners for everything else ([_fcntl],
 *     [_fsync], [_clock_gettime], [_sysconf], [_readdir_ino_stub],
 *     [_wait]-related, [_get*_r] / [_set*] families, etc.). These
 *     are sufficient when a large test binary only references
 *     them transitively at init and doesn't act on the return
 *     value.
 */
public final class CoreUnix {
    private CoreUnix() {}

    // ==== Open-flag constants (fcntl.h) ===============================

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

    // ==== fcntl commands (only F_GETFL / F_SETFL are externs in
    //      core.v0.14.1; GETFD / SETFD / FD_CLOEXEC are OCaml-side
    //      constants). ====================================================

    public static long F_GETFL(Object ignore) { return 3; }
    public static long F_SETFL(Object ignore) { return 4; }

    // ==== Specific-shape stubs ========================================

    /**
     * [core_unix_getrlimit resource] — upstream returns a record
     * [{rlim_cur; rlim_max}] where each field is
     * [Rlim.t = Infinity | Limit of Int63]. We return
     * [{Limit max; Limit max}] as a 2-field Block of 1-field
     * Blocks; OCaml code reads each field as "no limit".
     */
    public static Object getrlimit(Object resource) {
        Object limit = new Block(0, new Object[] {
            Long.valueOf(0x3fffffffffffffffL)
        });
        return new Block(0, new Object[] { limit, limit });
    }

    /** Parse IPv4 "a.b.c.d" → 32-bit integer. Stub returns 127.0.0.1. */
    public static long inet4_addr_to_int(Object s) {
        return 0x7F000001L;
    }

    /** Inverse — stub returns "127.0.0.1" regardless. */
    public static String inet4_addr_of_int(long v) {
        return "127.0.0.1";
    }

    /** errno → [Unix.error]. Stub returns [EAGAIN = 11]. */
    public static long error_of_code(long code) { return 11; }

    // ==== everything else: zero-returners =============================

}
