/**
 * Stubs for {@code Core_unix} C primitives that the OCaml bytecode
 * needs during module init but that our runtime doesn't fully
 * implement. Shapes match the OCaml-side type declarations in
 * {@code core_unix}; correctness beyond structural-shape is not
 * required for init paths — the actual syscall semantics would be
 * the next step after this.
 */
public final class CoreUnixStubs {
    private CoreUnixStubs() {}

    /**
     * {@code getrlimit resource} — returns {@code {rlim_cur;
     * rlim_max}} where each field is {@code Rlim.t = Infinity |
     * Limit of Int63}. We return [Limit max_int63; Limit max_int63];
     * OCaml code reads both fields as optional "no limit" sentinels.
     */
    public static Object core_unix_getrlimit(Object resource) {
        Object limit = new Block(0, new Object[] {
            Long.valueOf(0x3fffffffffffffffL)
        });
        return new Block(0, new Object[] { limit, limit });
    }

    /** Parse IPv4 "a.b.c.d" → 32-bit integer. Stub: always 127.0.0.1. */
    public static long inet4_addr_to_int(Object s) {
        return 0x7F000001L;
    }

    /** Inverse — stub returns "127.0.0.1" regardless. */
    public static String inet4_addr_of_int(long v) {
        return "127.0.0.1";
    }

    /** [errno_to_error_variant]. Return EAGAIN=11 consistently. */
    public static long error_of_code(long code) { return 11; }

    /** [error_variant_to_errno]. Return 0 (no error). */
    public static long code_of_error(Object e) { return 0; }

    /** [bigstring_alloc pos len]. Size is [len]; [pos] is ignored. */
    public static Object bigstring_alloc(Object pos, long len) {
        return BigArray.allocBigstring(len);
    }
}
