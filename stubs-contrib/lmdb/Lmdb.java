/**
 * Stubs for the [lmdb] opam package's C primitives —
 * Lightning-Memory-Mapped Database bindings under the
 * [mdbs_*] prefix. Upstream wraps libraries/mdb.h.
 *
 * For the test binary init, we just need the primitives to exist and
 * return something benign. Real DB interaction (env_open,
 * txn_begin, get/put) would require either a JNA bridge to
 * liblmdb.so (opt-in follow-up) or a pure-Java re-impl. This
 * bundle is intentionally minimal: arity-overloaded [zero]
 * methods matched to the primitive signatures, plus a few
 * non-zero returns where init code immediately inspects the
 * result.
 */
public final class Lmdb {
    private Lmdb() {}

    private static final Object ZERO = Long.valueOf(0L);

    // ==== arity-overloaded no-ops ==================================
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
    public static Object zero(Object a, Object b, Object c, Object d, Object e,
                              Object f, Object g) {
        return ZERO;
    }

    // ==== String-returning primitives ==============================
    // [mdb_strerror] turns an error code into a human-readable
    // string. OCaml callers pass it to [Failure] / [printf] —
    // returning [""] keeps downstream string handling happy
    // without the null-vs-empty-string trap.
    public static String strerror(Object code) { return ""; }

    /** [mdbs_env_get_path env path_out]: writes the env's path
     *  string pointer into path_out. Returning empty unit. */
    public static Object envGetPath(Object env, Object out) { return ZERO; }

    /** [mdbs_init ()]: returns [((string * int * int * int) * int array)]
     *  — a nested tuple of ((version_string, major, minor, patch),
     *  error_codes_array). OCaml-side init immediately destructures
     *  it, so the outer [Long 0] from [zero] crashes with
     *  Long-cannot-be-cast-to-Block. Return a properly nested
     *  Block tree with zero-valued defaults. */
    public static Block init(Object unit) {
        Block versionTuple = new Block(0, new Object[] {
            "lmdb-jni-stub",       // version string
            Long.valueOf(0L),      // major
            Long.valueOf(0L),      // minor
            Long.valueOf(0L),      // patch
        });
        // The destructuring in lmdb_bindings.ml binds 46 named flag
        // values out of this array. Length must match exactly or the
        // [|...|] pattern raises Match_failure at module init.
        Object[] flags = new Object[46];
        for (int i = 0; i < flags.length; i++) flags[i] = Long.valueOf(0L);
        Block errCodes = new Block(0, flags);
        return new Block(0, new Object[] { versionTuple, errCodes });
    }

    // ==== block-returning (tuple / record) primitives ==============
    // Init-time callers of these expect a Block they can
    // destructure. [zero] (= Long 0) crashes the first field
    // access with "Long cannot be cast to Block".

    /** [mdbs_stat dbi / env_stat env]: returns [{ms_psize; ms_depth;
     *  ms_branch_pages; ms_leaf_pages; ms_overflow_pages; ms_entries}]
     *  = 6 zeroed fields. */
    public static Block stat() { return zeroTuple(6); }
    public static Block stat(Object a) { return zeroTuple(6); }
    public static Block stat(Object a, Object b) { return zeroTuple(6); }
    public static Block stat(Object a, Object b, Object c) { return zeroTuple(6); }

    /** [mdbs_env_info env]: returns a record with ~5 fields. */
    public static Block envInfo() { return zeroTuple(6); }
    public static Block envInfo(Object a) { return zeroTuple(6); }

    /** [mdbs_get txn dbi key]: returns the value bound to [key],
     *  or raises Not_found. For init we return a zero-byte
     *  Bytes-like value wrapped in a Block so downstream
     *  destructure doesn't crash. */
    public static Object get(Object a, Object b, Object c) {
        return zeroTuple(2);
    }
    public static Object get(Object a, Object b, Object c, Object d) {
        return zeroTuple(2);
    }

    /** [mdbs_cursor_get cursor op]: (key, value) tuple. */
    public static Block cursorGet() { return zeroTuple(2); }
    public static Block cursorGet(Object a) { return zeroTuple(2); }
    public static Block cursorGet(Object a, Object b) { return zeroTuple(2); }
    public static Block cursorGet(Object a, Object b, Object c) { return zeroTuple(2); }

    private static Block zeroTuple(int n) {
        Object[] fs = new Object[n];
        for (int i = 0; i < n; i++) fs[i] = Long.valueOf(0L);
        return new Block(0, fs);
    }
}
