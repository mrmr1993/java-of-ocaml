/**
 * Stubs for [mirage-crypto]'s [mc_*] C primitives — native-speed
 * SHA / MD5 / AES / ChaCha / DES / Poly1305 / elliptic curve
 * (NIST P-224/256/384/521, X25519) implementations in [libmirage_crypto].
 *
 * Upstream these are hand-written C in the [mirage-crypto]
 * [src-native/] directory with CPU-feature-gated intrinsics (AES-NI,
 * PCLMULQDQ, RDRAND). No Java equivalent in scope here; every
 * primitive returns a plausible shape so init code can query
 * [ctx_size], [cpu_features], etc. without immediately tripping.
 *
 * Context-size queries return fixed constants sufficient for the
 * [BigArray]-backed allocation in [mirage-crypto]'s OCaml wrappers
 * ([Digestif]-like pattern: allocate a ctx bigarray, pass to
 * [init] / [update] / [finalize]). Actual hashing / encryption will
 * fail silently (or produce zeros) if reached; that's expected —
 * programs using these primitives in earnest should migrate to pure
 * OCaml backends (see [digestif.ocaml] for a precedent) or run on
 * a JVM with a JNI bridge to libmirage_crypto.
 *
 * Overloaded [zero] / [unit] methods service the bulk of the 151
 * primitive surface via the shorthand manifest form; specific
 * constants (ctx sizes, aes_rk_size, etc.) get their own method.
 */
public final class MirageCrypto {
    private MirageCrypto() {}

    private static final Object UNIT = Long.valueOf(0L);

    // ==== arity-overloaded no-ops ===================================

    // ==== CPU feature queries ======================================
    // Real impl returns a bitmask of detected AES-NI / PCLMUL /
    // AVX / SHA-NI / RDRAND features. Zero means "no special
    // features"; mirage-crypto's selectors fall back to the
    // generic C paths when this is zero.
    //
    // OCaml externals declared as [unit -> int] bind to the C
    // function as a 1-arg call passing [()]. All the [()J]-style
    // "query" primitives must therefore take one [Object] at the
    // JVM level even though the underlying semantics are nullary.
    public static long detect_cpu_features(Object ignore) { return 0; }
    public static long cpu_rng_type(Object ignore)        { return 0; }
    public static long cpu_rdrand(Object ignore) { return 0; }
    public static long cpu_rdseed(Object ignore) { return 0; }
    public static long cycle_counter(Object ignore)    { return 0; }
    public static long entropy_detect(Object ignore) { return 0; }
    public static long getrandom(Object buf, long off, long len) { return 0; }

    // ==== Hash context sizes =======================================
    // OCaml externals like [external size : unit -> int] bind as
    // 1-arg calls passing [()], so these take one [Object].
    public static long md5_ctx_size(Object ignore)       { return 96; }
    public static long sha1_ctx_size(Object ignore)      { return 96; }
    public static long sha224_ctx_size(Object ignore)    { return 128; }
    public static long sha256_ctx_size(Object ignore)    { return 128; }
    public static long sha384_ctx_size(Object ignore)    { return 224; }
    public static long sha512_ctx_size(Object ignore)    { return 224; }
    public static long poly1305_ctx_size(Object ignore)  { return 128; }
    public static long poly1305_mac_size(Object ignore)  { return 16; }
    public static long aes_rk_size(long bits) {
        // Round-keys: 11 * 16 for AES-128, 13 * 16 for AES-192,
        // 15 * 16 for AES-256. 240 covers all three.
        return 240;
    }
    public static long ghash_key_size(Object ignore) { return 256; }
    public static long des_key_size(Object ignore)   { return 128; }

    // ==== Cipher / hash ops (all no-ops) ===========================
    public static long md5_init(Object ctx)                                  { return 0; }
    public static long md5_update(Object ctx, Object buf, long off, long len) { return 0; }
    public static long md5_finalize(Object ctx, Object out, long off)        { return 0; }

    public static long sha1_init(Object ctx)                                  { return 0; }
    public static long sha1_update(Object ctx, Object buf, long off, long len) { return 0; }
    public static long sha1_finalize(Object ctx, Object out, long off)        { return 0; }

    public static long sha224_init(Object ctx)                                  { return 0; }
    public static long sha224_update(Object ctx, Object buf, long off, long len) { return 0; }
    public static long sha224_finalize(Object ctx, Object out, long off)        { return 0; }

    public static long sha256_init(Object ctx)                                  { return 0; }
    public static long sha256_update(Object ctx, Object buf, long off, long len) { return 0; }
    public static long sha256_finalize(Object ctx, Object out, long off)        { return 0; }

    public static long sha384_init(Object ctx)                                  { return 0; }
    public static long sha384_update(Object ctx, Object buf, long off, long len) { return 0; }
    public static long sha384_finalize(Object ctx, Object out, long off)        { return 0; }

    public static long sha512_init(Object ctx)                                  { return 0; }
    public static long sha512_update(Object ctx, Object buf, long off, long len) { return 0; }
    public static long sha512_finalize(Object ctx, Object out, long off)        { return 0; }

    public static long poly1305_init(Object ctx, Object key, long off)          { return 0; }
    public static long poly1305_update(Object ctx, Object buf, long off, long len) { return 0; }
    public static long poly1305_finalize(Object ctx, Object out, long off)      { return 0; }

    // ==== AES =====================================================
    public static long aes_mode(Object ignore)                                    { return 0; }
    public static long aes_derive_e_key(Object key, long koff, long klen,
                                        Object rk, long roff)                    { return 0; }
    public static long aes_derive_d_key(Object key, long koff, long klen,
                                        Object rk, long roff,
                                        Object rk_prev, long rpoff)              { return 0; }
    public static long aes_enc_bc(Object src, long soff, Object dst, long doff,
                                  Object rk, long roff, long rounds, long blocks) {
        return 0;
    }
    public static long aes_dec_bc(Object src, long soff, Object dst, long doff,
                                  Object rk, long roff, long rounds, long blocks) {
        return 0;
    }

    // ==== GHASH (AES-GCM) =========================================
    public static long ghash_mode(Object ignore)                                      { return 0; }
    public static long ghash_init_key(Object key, long koff, Object state, long soff) { return 0; }
    public static long ghash(Object state, long soff, Object buf, long boff, long len) { return 0; }

    // ==== DES =====================================================
    public static long des_ddes(Object key, long koff, Object src, long soff,
                                Object dst, long doff, long blocks, long mode) {
        return 0;
    }
    public static long des_des3key(Object key, long koff, Object out, long ooff,
                                   long mode) { return 0; }
    public static long des_cp3key(Object a, long aoff, Object b, long boff,
                                  Object out, long ooff) { return 0; }
    public static long des_use3key(Object a, long aoff) { return 0; }

    // ==== ChaCha20 ================================================
    public static long chacha_round(Object src, long soff, Object dst, long doff,
                                    Object key, long koff, Object ctr, long cooff,
                                    long rounds, long blocks) { return 0; }

    // ==== Misc / counters / xor ===================================
    public static long misc_mode(Object ignore)                                    { return 0; }
    public static long xor_into(Object src, long soff, Object dst, long doff,
                                long len) { return 0; }
    public static long count_8_be(Object ctr, long coff, long n) { return 0; }
    public static long count_16_be(Object ctr, long coff, long n) { return 0; }
    public static long count_16_be_4(Object ctr, long coff, long n) { return 0; }

    // ==== Elliptic curves: NIST P-224/256/384/521 =================
    // The OCaml wrappers treat these as opaque BigArray blobs; we
    // zero the output and return 0. Actual scalar mults will
    // produce the identity element, which is not cryptographically
    // meaningful but also won't segfault — callers will observe
    // garbage, not undefined behaviour.
    //
    // Grouped as: [p<N>_*] = projective point ops,
    //             [np<N>_*] = scalar (mod n) arithmetic.
    // Same signature family: all take (Object, long) buffer
    // references; we can route all of them through [zero] via the
    // manifest's overload shorthand.

    // ==== Curve25519 ==============================================
    public static long x25519_scalar_mult_generic(Object s, long soff,
                                                  Object p, long poff,
                                                  Object out, long ooff) { return 0; }
    public static long _25519_scalar_mult_base(Object out, long ooff,
                                               Object s, long soff) { return 0; }
    public static long _25519_double_scalar_mult(Object out, long ooff,
                                                 Object s1, long s1off,
                                                 Object p, long poff,
                                                 Object s2, long s2off) { return 0; }
    public static long _25519_muladd(Object out, long ooff,
                                     Object a, long aoff,
                                     Object b, long boff,
                                     Object c, long coff) { return 0; }
    public static long _25519_reduce_l(Object out, long ooff) { return 0; }
    public static long _25519_pub_ok(Object p, long poff) { return 0; }
}
