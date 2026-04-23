/**
 * POSIX typedef discriminators from [ctypes]'
 * [src/ctypes/posixTypes.ml] ([PosixTypes] module).
 *
 * Each [typeof_*] returns a [Ctypes_static.arithmetic] variant
 * tag that [posixTypes.ml]'s [mkSigned] / [mkUnsigned] consume to
 * build a typed view. The variant case ordering is:
 *
 *   [Int8=0 | Int16=1 | Int32=2 | Int64=3
 *  | Uint8=4 | Uint16=5 | Uint32=6 | Uint64=7
 *  | Float=8 | Double=9]
 *
 * Values below match the Linux/x86_64 ABI typedefs — [time_t]
 * → [Int64], [mode_t] → [Uint32], etc. [mkSigned] and
 * [mkUnsigned] both [assert false] on a variant outside their
 * signed/unsigned subset, so picking the wrong case would fault at
 * init; these values are correct for that ABI.
 *
 * Upstream [posixTypes.ml] declares 10 [typeof_*] primitives plus
 * [sizeof_sigset_t] / [alignmentof_sigset_t]. That's the set we
 * mirror here, no more.
 */
public final class PosixTypes {
    private PosixTypes() {}

    // ---- typeof_* (arithmetic variant tags) ----
    public static long typeof_clock_t(Object ignore)     { return 3; /* Int64  */ }
    public static long typeof_dev_t(Object ignore)       { return 7; /* Uint64 */ }
    public static long typeof_ino_t(Object ignore)       { return 7; /* Uint64 */ }
    public static long typeof_mode_t(Object ignore)      { return 6; /* Uint32 */ }
    public static long typeof_nlink_t(Object ignore)     { return 7; /* Uint64 */ }
    public static long typeof_off_t(Object ignore)       { return 3; /* Int64  */ }
    public static long typeof_pid_t(Object ignore)       { return 2; /* Int32  */ }
    public static long typeof_ssize_t(Object ignore)     { return 3; /* Int64  */ }
    public static long typeof_time_t(Object ignore)      { return 3; /* Int64  */ }
    public static long typeof_useconds_t(Object ignore)  { return 6; /* Uint32 */ }

    // ---- sizeof / alignmentof for opaque [sigset_t] ----
    public static long sizeof_sigset_t(Object ignore)      { return 128; }
    public static long alignmentof_sigset_t(Object ignore) { return 8; }
}
