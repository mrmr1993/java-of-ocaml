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

    /** [core_unix_uname ()]: returns a [Utsname.t] record with
     *  fields [{sysname; nodename; release; version; machine}]. */
    public static Block uname(Object unit) {
        return new Block(0, new Object[] {
            System.getProperty("os.name", "Linux"),
            System.getProperty("user.name", "unknown"),
            System.getProperty("os.version", "unknown"),
            System.getProperty("java.vm.name", "JVM"),
            System.getProperty("os.arch", "x86_64"),
        });
    }

    /** [core_unix_sysconf : sysconf -> int64 option]: returns the
     *  system limit for the given variant tag (NCHILDREN_MAX,
     *  PAGESIZE, etc). Reporting [None] = Long(0) makes the test binary fall
     *  back to its hardcoded defaults. */
    public static Object sysconf(Object conf) {
        return Long.valueOf(0L);
    }

    /** [core_unix_error_of_code]: Linux errno → [Unix.error] variant
     *  tag. The OCaml [Unix.error] type is a flat variant; nullary
     *  constructors are represented as their declaration index. The
     *  table below covers the codes that the test binary init / common
     *  feature-unavailable probes actually inspect; everything else
     *  collapses to [EUNKNOWNERR n] (constructor index 67, with the
     *  raw code wrapped). Honest enough that pattern-matches on
     *  specific errors (e.g. [Error ENOSYS]) hit the right branch. */
    public static Object error_of_code(long code) {
        int idx = errnoToVariantIndex((int) code);
        if (idx >= 0) return Long.valueOf(idx);
        // EUNKNOWNERR of int — non-nullary, so it's a Block.
        return new Block(0, new Object[] { Long.valueOf(code) });
    }

    private static int errnoToVariantIndex(int code) {
        // Linux errno → [Unix.error] declaration index. -1 means
        // fall through to EUNKNOWNERR.
        switch (code) {
            case 7:   return 0;   // E2BIG
            case 13:  return 1;   // EACCES
            case 11:  return 2;   // EAGAIN
            case 9:   return 3;   // EBADF
            case 16:  return 4;   // EBUSY
            case 10:  return 5;   // ECHILD
            case 35:  return 6;   // EDEADLK
            case 33:  return 7;   // EDOM
            case 17:  return 8;   // EEXIST
            case 14:  return 9;   // EFAULT
            case 27:  return 10;  // EFBIG
            case 4:   return 11;  // EINTR
            case 22:  return 12;  // EINVAL
            case 5:   return 13;  // EIO
            case 21:  return 14;  // EISDIR
            case 24:  return 15;  // EMFILE
            case 31:  return 16;  // EMLINK
            case 36:  return 17;  // ENAMETOOLONG
            case 23:  return 18;  // ENFILE
            case 19:  return 19;  // ENODEV
            case 2:   return 20;  // ENOENT
            case 8:   return 21;  // ENOEXEC
            case 37:  return 22;  // ENOLCK
            case 12:  return 23;  // ENOMEM
            case 28:  return 24;  // ENOSPC
            case 38:  return 25;  // ENOSYS
            case 20:  return 26;  // ENOTDIR
            case 39:  return 27;  // ENOTEMPTY
            case 25:  return 28;  // ENOTTY
            case 6:   return 29;  // ENXIO
            case 1:   return 30;  // EPERM
            case 32:  return 31;  // EPIPE
            case 34:  return 32;  // ERANGE
            case 30:  return 33;  // EROFS
            case 29:  return 34;  // ESPIPE
            case 3:   return 35;  // ESRCH
            case 18:  return 36;  // EXDEV
            // EWOULDBLOCK is its own variant (index 37) but shares
            // errno 11 with EAGAIN on Linux; the EAGAIN case above
            // wins. Pattern matches against either work because
            // OCaml stdlib already collapses them upstream.
            case 115: return 38;  // EINPROGRESS
            case 114: return 39;  // EALREADY
            case 88:  return 40;  // ENOTSOCK
            case 89:  return 41;  // EDESTADDRREQ
            case 90:  return 42;  // EMSGSIZE
            case 91:  return 43;  // EPROTOTYPE
            case 92:  return 44;  // ENOPROTOOPT
            case 93:  return 45;  // EPROTONOSUPPORT
            case 94:  return 46;  // ESOCKTNOSUPPORT
            case 95:  return 47;  // EOPNOTSUPP
            case 96:  return 48;  // EPFNOSUPPORT
            case 97:  return 49;  // EAFNOSUPPORT
            case 98:  return 50;  // EADDRINUSE
            case 99:  return 51;  // EADDRNOTAVAIL
            case 100: return 52;  // ENETDOWN
            case 101: return 53;  // ENETUNREACH
            case 102: return 54;  // ENETRESET
            case 103: return 55;  // ECONNABORTED
            case 104: return 56;  // ECONNRESET
            case 105: return 57;  // ENOBUFS
            case 106: return 58;  // EISCONN
            case 107: return 59;  // ENOTCONN
            case 108: return 60;  // ESHUTDOWN
            case 109: return 61;  // ETOOMANYREFS
            case 110: return 62;  // ETIMEDOUT
            case 111: return 63;  // ECONNREFUSED
            case 112: return 64;  // EHOSTDOWN
            case 113: return 65;  // EHOSTUNREACH
            case 40:  return 66;  // ELOOP
            case 75:  return 67;  // EOVERFLOW
            default:  return -1;
        }
    }
}
