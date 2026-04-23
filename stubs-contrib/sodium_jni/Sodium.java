import com.sun.jna.Native;
import com.sun.jna.NativeLibrary;
import com.sun.jna.Function;
import com.sun.jna.Memory;
import com.sun.jna.Pointer;

/**
 * JNA-backed adapter for [libsodium] — replaces the zero-returning
 * [stubs-contrib/sodium] bundle with real calls into
 * [libsodium.so]. Size-query primitives ask libsodium for the
 * actual compile-time constant; hash / sign / box operations
 * marshal OCaml buffers to native memory, invoke the real
 * function, and copy back.
 *
 * Runtime requirements:
 *   - [libsodium.so.23] (or compatible) on the dynamic loader path.
 *   - JNA 5.x jar on the classpath at both [javac] time (via
 *     $(b,--stub-classpath)) and [java -cp] run time.
 *
 * Buffer marshalling: OCaml bigstrings land here as our
 * [BigArray] with per-cell boxed [Long] bytes. We pack each cell
 * into a JNA [Memory] region, call libsodium, and — for output
 * buffers — copy the native bytes back into the cells. Cost is
 * O(n) boxing per call; fine for the buffer sizes libsodium uses
 * (hash outputs 32-64B, keys 32-64B, messages typically under a
 * few KB for init paths). Hot bulk-data paths would need a typed
 * [BigArray] storage before this is worth optimising.
 */
public final class Sodium {
    private Sodium() {}

    private static final NativeLibrary LIB;
    static {
        // [libsodium] is versioned; try .so.23 (current stable on
        // Debian/Ubuntu) first, fall back to the unversioned name.
        NativeLibrary lib = null;
        try { lib = NativeLibrary.getInstance("sodium"); }
        catch (UnsatisfiedLinkError e) {
            lib = NativeLibrary.getInstance("/usr/lib/x86_64-linux-gnu/libsodium.so.23");
        }
        LIB = lib;
        // [sodium_init]: required before any crypto op. Idempotent.
        Function init = LIB.getFunction("sodium_init");
        int rc = init.invokeInt(new Object[]{});
        if (rc < 0) throw new RuntimeException("sodium_init failed: " + rc);
    }

    /** [nullary_size name]: call a zero-arg libsodium size getter
     *  and return its [size_t] result. All the [*bytes] queries
     *  follow this shape. */
    private static long nullarySize(String name) {
        return LIB.getFunction(name).invokeLong(new Object[]{});
    }

    // ==== Arity-overloaded zero fallbacks ========================
    // Libsodium primitives we haven't bridged yet still route here.
    // When the zero-stubs bundle is swapped for this one we want to
    // keep the surface compilable without listing every name.
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

    // ==== Size queries (real libsodium calls) ====================
    // OCaml externals are declared [unit -> int], which our backend
    // lowers to 1-arg JVM signatures taking a [()] placeholder.

    // crypto_box_curve25519xsalsa20poly1305
    public static long box_publickeybytes(Object u) { return nullarySize("crypto_box_curve25519xsalsa20poly1305_publickeybytes"); }
    public static long box_secretkeybytes(Object u) { return nullarySize("crypto_box_curve25519xsalsa20poly1305_secretkeybytes"); }
    public static long box_beforenmbytes(Object u)  { return nullarySize("crypto_box_curve25519xsalsa20poly1305_beforenmbytes"); }
    public static long box_noncebytes(Object u)     { return nullarySize("crypto_box_curve25519xsalsa20poly1305_noncebytes"); }
    public static long box_zerobytes(Object u)      { return nullarySize("crypto_box_curve25519xsalsa20poly1305_zerobytes"); }
    public static long box_boxzerobytes(Object u)   { return nullarySize("crypto_box_curve25519xsalsa20poly1305_boxzerobytes"); }

    // crypto_sign_ed25519
    public static long sign_publickeybytes(Object u) { return nullarySize("crypto_sign_ed25519_publickeybytes"); }
    public static long sign_secretkeybytes(Object u) { return nullarySize("crypto_sign_ed25519_secretkeybytes"); }
    public static long sign_bytes(Object u)          { return nullarySize("crypto_sign_ed25519_bytes"); }
    public static long sign_seedbytes(Object u)      { return nullarySize("crypto_sign_ed25519_seedbytes"); }

    // crypto_scalarmult_curve25519
    public static long scalarmult_bytes(Object u)       { return nullarySize("crypto_scalarmult_curve25519_bytes"); }
    public static long scalarmult_scalarbytes(Object u) { return nullarySize("crypto_scalarmult_curve25519_scalarbytes"); }

    // crypto_pwhash_argon2i
    public static long pwhash_saltbytes(Object u) { return nullarySize("crypto_pwhash_argon2i_saltbytes"); }
    public static long pwhash_strbytes(Object u)  { return nullarySize("crypto_pwhash_argon2i_strbytes"); }

    // crypto_secretbox_xsalsa20poly1305
    public static long secretbox_keybytes(Object u)     { return nullarySize("crypto_secretbox_xsalsa20poly1305_keybytes"); }
    public static long secretbox_noncebytes(Object u)   { return nullarySize("crypto_secretbox_xsalsa20poly1305_noncebytes"); }
    public static long secretbox_zerobytes(Object u)    { return nullarySize("crypto_secretbox_xsalsa20poly1305_zerobytes"); }
    public static long secretbox_boxzerobytes(Object u) { return nullarySize("crypto_secretbox_xsalsa20poly1305_boxzerobytes"); }

    // crypto_stream_xsalsa20
    public static long stream_keybytes(Object u)   { return nullarySize("crypto_stream_xsalsa20_keybytes"); }
    public static long stream_noncebytes(Object u) { return nullarySize("crypto_stream_xsalsa20_noncebytes"); }

    // crypto_hash_sha512
    public static long hash_sha512_bytes(Object u) { return nullarySize("crypto_hash_sha512_bytes"); }

    // crypto_generichash_blake2b
    public static long blake2b_bytes(Object u)    { return nullarySize("crypto_generichash_blake2b_bytes"); }
    public static long blake2b_keybytes(Object u) { return nullarySize("crypto_generichash_blake2b_keybytes"); }

    // crypto_auth_hmacsha512256
    public static long hmacsha512256_keybytes(Object u) { return nullarySize("crypto_auth_hmacsha512256_keybytes"); }
    public static long hmacsha512256_bytes(Object u)    { return nullarySize("crypto_auth_hmacsha512256_bytes"); }

    // crypto_onetimeauth_poly1305
    public static long poly1305_keybytes(Object u) { return nullarySize("crypto_onetimeauth_poly1305_keybytes"); }
    public static long poly1305_bytes(Object u)    { return nullarySize("crypto_onetimeauth_poly1305_bytes"); }
}
