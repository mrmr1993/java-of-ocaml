/**
 * Stubs for [async_ssl]'s cstubs-generated OpenSSL bindings.
 * Each primitive is named [async_ssl_stub_NN_<openssl_symbol>]
 * where [NN] is a cstubs-assigned index and [<openssl_symbol>]
 * is the libcrypto / libssl function the stub wraps
 * ([SSL_CTX_new], [OBJ_txt2nid], [ENGINE_load_builtin_engines],
 * etc.).
 *
 * A real implementation would require either linking OpenSSL via
 * JNI or re-implementing TLS on [javax.net.ssl]. Neither is in
 * scope here. We return [0] / [null] placeholders which are
 * sufficient for init — [async_ssl]'s startup code registers
 * error strings and creates a shared [SSL_CTX] but doesn't
 * actually open a connection. If the workload reaches a real
 * [Ssl.Connection.create_client] call, it'll fail because the
 * stubbed context is inert; that's expected.
 *
 * Implementation note: the stubs use arity-overloaded [zero]
 * methods (0..6 [Object] args), and shorthand manifest entries
 * route each primitive to the matching overload based on
 * call-site arity.
 */
public final class AsyncSsl {
    private AsyncSsl() {}

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
