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
}
