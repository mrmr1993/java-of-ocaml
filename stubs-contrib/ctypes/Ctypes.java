/**
 * Stubs for the [ctypes] opam package. Not part of js_of_ocaml's
 * runtime — users of ctypes on JS targets supply their own stubs
 * via dune's [javascript_files] stanza or forbid the dependency at
 * link time. Here we follow the same split: opt-in only via
 * [--stub-manifest stubs-contrib/ctypes/stubs.json].
 *
 * Two sub-families covered:
 *
 *  - [ldouble] / [ldouble_complex] arithmetic — OCaml [long double]
 *    is approximated as Java [double] (losing precision beyond
 *    53 bits), and [ldouble_complex] as a 2-field block of
 *    [Double]. All binary ops use primitive-[double] descriptors
 *    so values stay [K_float] across the call.
 *
 *  - POSIX typedef discriminators ([typeof_time_t], etc.) returning
 *    the corresponding [Ctypes_static.arithmetic] variant tag —
 *    [Int8=0 | Int16=1 | Int32=2 | Int64=3 | Uint8=4 | Uint16=5 |
 *    Uint32=6 | Uint64=7 | Float=8 | Double=9]. Sizes match the
 *    Linux/x86_64 ABI, which is what [ctypes/posixTypes.ml]'s
 *    [mkSigned] / [mkUnsigned] require.
 */
public final class Ctypes {
    private Ctypes() {}

    // ---- library init (unit return) ----
    public static long ldouble_init(Object ignore) { return 0; }
    public static long ldouble_complex_init(Object ignore) { return 0; }

    // ---- ldouble constants ----
    public static double ldouble_min(Object ignore)     { return -Double.MAX_VALUE; }
    public static double ldouble_max(Object ignore)     { return Double.MAX_VALUE; }
    public static double ldouble_epsilon(Object ignore) { return Math.ulp(1.0); }
    public static double ldouble_nan(Object ignore)     { return Double.NaN; }
    public static double ldouble_inf(Object ignore)     { return Double.POSITIVE_INFINITY; }
    public static double ldouble_ninf(Object ignore)    { return Double.NEGATIVE_INFINITY; }
    public static double ldouble_pi(Object ignore)      { return Math.PI; }
    public static double ldouble_e(Object ignore)       { return Math.E; }
    public static double ldouble_euler(Object ignore)   { return 0.5772156649015329; }
    public static long   ldouble_mant_dig(Object ignore){ return 53; }
    public static long   ldouble_size(Object ignore)    { return 8; }

    // ---- ldouble unary / conversions ----
    public static double ldouble_of_float(double v) { return v; }
    public static double ldouble_to_float(double v) { return v; }
    public static double ldouble_of_int(long v)     { return (double) v; }
    public static long   ldouble_to_int(double v)   { return (long) v; }
    public static double ldouble_neg(double v)      { return -v; }

    // ---- ldouble binary arithmetic ----
    public static double ldouble_add(double a, double b) { return a + b; }
    public static double ldouble_sub(double a, double b) { return a - b; }
    public static double ldouble_mul(double a, double b) { return a * b; }
    public static double ldouble_div(double a, double b) { return a / b; }

    // ---- complex: return Block {re=0.0, im=0.0} placeholder ----
    public static Block ldouble_complex_1(Object a) {
        return new Block(0, new Object[] {
            Double.valueOf(0.0), Double.valueOf(0.0)
        });
    }

    public static Block ldouble_complex_2(Object a, Object b) {
        return new Block(0, new Object[] {
            Double.valueOf(0.0), Double.valueOf(0.0)
        });
    }

    // ---- complex -> double (abs, arg, norm, real, imag) ----
    public static double ldouble_complex_to_double_1(Object a) { return 0.0; }

    // ---- POSIX typeof_* : Ctypes_static.arithmetic variant tags ----
    public static long typeof_clock_t(Object ignore)     { return 3; /* Int64 */ }
    public static long typeof_dev_t(Object ignore)       { return 7; /* Uint64 */ }
    public static long typeof_ino_t(Object ignore)       { return 7; /* Uint64 */ }
    public static long typeof_mode_t(Object ignore)      { return 6; /* Uint32 */ }
    public static long typeof_nlink_t(Object ignore)     { return 7; /* Uint64 */ }
    public static long typeof_off_t(Object ignore)       { return 3; /* Int64 */ }
    public static long typeof_pid_t(Object ignore)       { return 2; /* Int32 */ }
    public static long typeof_ssize_t(Object ignore)     { return 3; /* Int64 */ }
    public static long typeof_time_t(Object ignore)      { return 3; /* Int64 */ }
    public static long typeof_useconds_t(Object ignore)  { return 6; /* Uint32 */ }
    public static long typeof_uid_t(Object ignore)       { return 6; /* Uint32 */ }
    public static long typeof_gid_t(Object ignore)       { return 6; /* Uint32 */ }
    public static long typeof_blkcnt_t(Object ignore)    { return 3; /* Int64 */ }
    public static long typeof_blksize_t(Object ignore)   { return 3; /* Int64 */ }
    public static long typeof_fsblkcnt_t(Object ignore)  { return 7; /* Uint64 */ }
    public static long typeof_fsfilcnt_t(Object ignore)  { return 7; /* Uint64 */ }
    public static long typeof_id_t(Object ignore)        { return 6; /* Uint32 */ }
    public static long typeof_key_t(Object ignore)       { return 2; /* Int32 */ }
    public static long typeof_suseconds_t(Object ignore) { return 3; /* Int64 */ }
    public static long typeof_speed_t(Object ignore)     { return 6; /* Uint32 */ }
    public static long typeof_cc_t(Object ignore)        { return 4; /* Uint8 */ }
    public static long typeof_tcflag_t(Object ignore)    { return 6; /* Uint32 */ }
    public static long typeof_nfds_t(Object ignore)      { return 7; /* Uint64 */ }
    public static long typeof_rlim_t(Object ignore)      { return 7; /* Uint64 */ }
    public static long typeof_socklen_t(Object ignore)   { return 6; /* Uint32 */ }
    public static long typeof_intptr_t(Object ignore)    { return 3; /* Int64 */ }
    public static long typeof_uintptr_t(Object ignore)   { return 7; /* Uint64 */ }
    public static long typeof_ptrdiff_t(Object ignore)   { return 3; /* Int64 */ }
    public static long typeof_sigset_t(Object ignore)    { return 7; /* Uint64, opaque */ }

    // ---- alignment / size of opaque POSIX types ----
    public static long alignmentof_sigset_t(Object ignore) { return 8; }
    public static long alignmentof_fd_set(Object ignore)   { return 8; }
    public static long sizeof_sigset_t(Object ignore)      { return 128; }
    public static long sizeof_fd_set(Object ignore)        { return 128; }
}
