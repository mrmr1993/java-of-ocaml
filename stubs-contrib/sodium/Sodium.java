/**
 * Stubs for [libsodium] (NaCl) ctypes-foreign bindings used via
 * the test binary's [sodium] or [hacl_star]-style ocaml wrapper. Each
 * primitive is cstubs-indexed as [caml__<N>_<nacl_symbol>]; the
 * set covers Curve25519/XSalsa20Poly1305 box + sign +
 * onetimeauth/poly1305 + secretbox families.
 *
 * Identical pattern to [AsyncSsl]: route every call through
 * arity-overloaded [zero] methods. Init-time paths only query
 * "*bytes" sizes and allocate buffers — actual crypto would need
 * a real libsodium bridge (JNI) or a pure-Java NaCl port, neither
 * in scope here.
 */
public final class Sodium {
    private Sodium() {}

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
    public static Object zero(Object a, Object b, Object c, Object d, Object e,
                              Object f, Object g) {
        return ZERO;
    }
}
