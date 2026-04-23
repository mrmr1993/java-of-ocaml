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

    // ==== NaCl/libsodium size constants ==========================
    // Each of these is an OCaml [external sz : unit -> int], called
    // at init to sanity-check buffer sizes (e.g. [assert (pk_bytes
    // = 32)]). Real libsodium returns the fixed algorithm-specific
    // assertions. Values taken from libsodium's public headers
    // ([crypto_*.h]).

    // crypto_box_curve25519xsalsa20poly1305 (NaCl default "box")
    public static long box_publickeybytes(Object u)    { return 32; }
    public static long box_secretkeybytes(Object u)    { return 32; }
    public static long box_beforenmbytes(Object u)     { return 32; }
    public static long box_noncebytes(Object u)        { return 24; }
    public static long box_zerobytes(Object u)         { return 32; }
    public static long box_boxzerobytes(Object u)      { return 16; }

    // crypto_sign_ed25519
    public static long sign_publickeybytes(Object u)   { return 32; }
    public static long sign_secretkeybytes(Object u)   { return 64; }
    public static long sign_bytes(Object u)            { return 64; }
    public static long sign_seedbytes(Object u)        { return 32; }

    // crypto_scalarmult_curve25519
    public static long scalarmult_bytes(Object u)      { return 32; }
    public static long scalarmult_scalarbytes(Object u){ return 32; }

    // crypto_pwhash_argon2i
    public static long pwhash_saltbytes(Object u)      { return 16; }
    public static long pwhash_strbytes(Object u)       { return 128; }

    // crypto_secretbox_xsalsa20poly1305
    public static long secretbox_keybytes(Object u)    { return 32; }
    public static long secretbox_noncebytes(Object u)  { return 24; }
    public static long secretbox_zerobytes(Object u)   { return 32; }
    public static long secretbox_boxzerobytes(Object u){ return 16; }

    // crypto_stream_xsalsa20
    public static long stream_keybytes(Object u)       { return 32; }
    public static long stream_noncebytes(Object u)     { return 24; }

    // crypto_hash_sha512
    public static long hash_sha512_bytes(Object u)     { return 64; }

    // crypto_generichash_blake2b (keyed hash; default output 32B)
    public static long blake2b_bytes(Object u)         { return 32; }
    public static long blake2b_keybytes(Object u)      { return 32; }

    // crypto_auth_hmacsha512256
    public static long hmacsha512256_keybytes(Object u){ return 32; }
    public static long hmacsha512256_bytes(Object u)   { return 32; }

    // crypto_onetimeauth_poly1305
    public static long poly1305_keybytes(Object u)     { return 32; }
    public static long poly1305_bytes(Object u)        { return 16; }
}
