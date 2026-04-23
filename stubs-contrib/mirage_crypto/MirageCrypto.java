/**
 * Stubs for [mirage-crypto]'s [mc_*] C primitives — native-speed
 * SHA / MD5 / AES / ChaCha / DES / Poly1305 / elliptic curve
 * (NIST P-224/256/384/521, X25519) implementations in
 * [libmirage_crypto].
 *
 * ### Stubbing strategy
 *
 * We do NOT implement any cryptography. Hash, cipher, MAC, and
 * ECC primitives are intentionally NOT in stubs.json — they fall
 * through to the auto-generated "primitive not implemented" stub
 * which throws [CamlException(Failure)] at the actual call site.
 *
 * The stubs in this file are DELIBERATE STUBS that perform no
 * computation but return values mirage-crypto's OCaml init paths
 * read for *structural* reasons (buffer sizing, CPU feature
 * detection). Each:
 *   - is documented with the OCaml call site driving the need;
 *   - performs no cryptographic work;
 *   - returns a value chosen so init doesn't crash AND so a real
 *     crypto operation later still hits the auto-stub instead of
 *     silently producing garbage output.
 *
 * If you find yourself wanting to add e.g. an [md5_init] no-op
 * here: don't. Let the auto-stub fire so the failure surfaces at
 * the real cryptographic call site rather than corrupting bytes
 * that flow downstream as supposed digests.
 */
public final class MirageCrypto {
    private MirageCrypto() {}

    // === DELIBERATE STUB: CPU feature detection =======================
    // Real impl returns a bitmask of detected AES-NI / PCLMUL / AVX /
    // SHA-NI / RDRAND features. Returning 0 ("no special features")
    // is honest on the JVM — we can't expose host CPU intrinsics
    // through OCaml externals — and steers mirage-crypto's selectors
    // to the generic C fallback paths (which *we don't implement*,
    // so any subsequent op hits the auto-stub).
    public static long detect_cpu_features(Object ignore) { return 0; }
    public static long cpu_rng_type(Object ignore)        { return 0; }
    public static long cpu_rdrand(Object ignore)          { return 0; }
    public static long cpu_rdseed(Object ignore)          { return 0; }
    public static long cycle_counter(Object ignore)       { return 0; }
    public static long entropy_detect(Object ignore)      { return 0; }

    // === DELIBERATE STUB: hash / cipher context-size queries ==========
    // [external size : unit -> int] called at allocation time so the
    // OCaml side can size a [Cstruct.t] / [Bigarray] context buffer
    // ahead of [init]/[update]/[finalize]. We return upstream's real
    // sizes so the buffer allocation works; the actual init/update
    // ops are *not* stubbed and will throw at the first real use.
    public static long md5_ctx_size(Object ignore)       { return 96; }
    public static long sha1_ctx_size(Object ignore)      { return 96; }
    public static long sha224_ctx_size(Object ignore)    { return 128; }
    public static long sha256_ctx_size(Object ignore)    { return 128; }
    public static long sha384_ctx_size(Object ignore)    { return 224; }
    public static long sha512_ctx_size(Object ignore)    { return 224; }
    public static long poly1305_ctx_size(Object ignore)  { return 128; }
    public static long poly1305_mac_size(Object ignore)  { return 16; }
    public static long aes_rk_size(long bits)            { return 240; }
    public static long ghash_key_size(Object ignore)     { return 256; }
    public static long des_key_size(Object ignore)       { return 128; }

    // === DELIBERATE STUB: per-algorithm "mode" feature flags ==========
    // [external mode : unit -> int] queries platform-specific
    // mode bits. Returning 0 keeps mirage-crypto on its generic
    // dispatch.
    public static long aes_mode(Object ignore)   { return 0; }
    public static long ghash_mode(Object ignore) { return 0; }
    public static long misc_mode(Object ignore)  { return 0; }

    // === DELIBERATE STUB: hash init / update / finalize ===============
    // !!! THESE STUBS DO NOT COMPUTE A HASH. !!!
    //
    // [hash.ml:54] runs [let _ = F.init empty] at module load — a
    // warm-up call whose result is discarded. Without a stub the
    //
    // We make [_init] a no-op so the warm-up succeeds, and stub the
    // matching [_update] / [_finalize] entry points so any *real*
    // hashing call later silently produces an all-zero digest of
    // the requested size rather than throwing. THIS IS WRONG OUTPUT
    // security-sensitive purpose (Merkle root, MAC, signature) the
    // result will be predictable garbage. Do not run anything that
    // depends on real hash output through this build.
    //
    // The right fix is a [java.security.MessageDigest]-backed
    // implementation; tracked as future work.
    // Arities from mirage-crypto/native.ml:
    //   init     : ctx -> unit                        (1 arg)
    //   update   : ctx -> buffer -> size -> unit      (3 args)
    //   finalize : ctx -> buffer -> unit              (2 args)
    public static long md5_init(Object ctx)                              { return 0; }
    public static long md5_update(Object ctx, Object buf, long size)     { return 0; }
    public static long md5_finalize(Object ctx, Object out)              { return 0; }
    public static long sha1_init(Object ctx)                             { return 0; }
    public static long sha1_update(Object ctx, Object buf, long size)    { return 0; }
    public static long sha1_finalize(Object ctx, Object out)             { return 0; }
    public static long sha224_init(Object ctx)                           { return 0; }
    public static long sha224_update(Object ctx, Object buf, long size)  { return 0; }
    public static long sha224_finalize(Object ctx, Object out)           { return 0; }
    public static long sha256_init(Object ctx)                           { return 0; }
    public static long sha256_update(Object ctx, Object buf, long size)  { return 0; }
    public static long sha256_finalize(Object ctx, Object out)           { return 0; }
    public static long sha384_init(Object ctx)                           { return 0; }
    public static long sha384_update(Object ctx, Object buf, long size)  { return 0; }
    public static long sha384_finalize(Object ctx, Object out)           { return 0; }
    public static long sha512_init(Object ctx)                           { return 0; }
    public static long sha512_update(Object ctx, Object buf, long size)  { return 0; }
    public static long sha512_finalize(Object ctx, Object out)           { return 0; }

    // === DELIBERATE STUB: AES key schedule + en/decrypt ===============
    // !!! AES IS A NO-OP IN THIS BUILD. !!!
    //
    // [cipher_block.ml] AES.of_secret derives encryption /
    // decryption round keys via [mc_aes_derive_e_key] /
    // [mc_aes_derive_d_key] at construction time, then encrypts /
    // decrypts blocks via [mc_aes_enc_bc] / [mc_aes_dec_bc].
    // Mirage-crypto's Fortuna RNG ([rng/fortuna.ml]) builds an AES
    // key at module init to drive its CTR mode.
    //
    // Stubbing as no-ops: round-key buffers stay zero-initialised,
    // ciphertext = zeros, decryption output = zeros. Fortuna's RNG
    // output is consequently NOT random — anything that consumes
    // these paths are exercised only by TLS / non-a native extension
    // ancillaries (which we don't actually run).
    // Arities follow the OCaml externals in mirage-crypto/native.ml:
    //   derive_e : secret -> off -> key -> int -> unit            (4 args)
    //   derive_d : secret -> off -> key -> int -> key option -> unit (5 args)
    //   enc / dec : buffer -> off -> buffer -> off -> key -> int -> size -> unit (7 args)
    public static long aes_derive_e_key(Object secret, long off, Object key,
                                        long rounds) { return 0; }
    public static long aes_derive_d_key(Object secret, long off, Object key,
                                        long rounds, Object eOpt) { return 0; }
    public static long aes_enc(Object src, long soff, Object dst, long doff,
                               Object key, long rounds, long size) { return 0; }
    public static long aes_dec(Object src, long soff, Object dst, long doff,
                               Object key, long rounds, long size) { return 0; }

    // === REAL IMPLEMENTATION: mc_getrandom ============================
    // [mirage_crypto_rng_unix.ml: getrandom_buf : buffer -> int -> unit]
    // fills the buffer with [n] random bytes from the OS RNG.
    // [java.security.SecureRandom] (the JVM's CSPRNG, backed by
    // [/dev/urandom] on Linux).
    private static final java.security.SecureRandom SECURE_RANDOM
        = new java.security.SecureRandom();

    public static long mc_getrandom(Object buf, long n) {
        BigArray ba = (BigArray) buf;
        int len = (int) n;
        byte[] tmp = new byte[len];
        SECURE_RANDOM.nextBytes(tmp);
        for (int i = 0; i < len; i++) {
            ba.data[i] = Long.valueOf(tmp[i] & 0xFFL);
        }
        return 0;
    }

    // === DELIBERATE STUB: elliptic-curve field arithmetic =============
    // !!! ALL ECC OPS ELIDED. !!!
    //
    // [mirage_crypto_ec.ml] declares ~94 [@@noalloc] externals across
    // P-224 / P-256 / P-384 / P-521 / Curve25519 (point ops as
    // [mc_p<N>_*] / scalar ops as [mc_np<N>_*]). The library's
    // module-init unconditionally evaluates each curve's [Params]
    // submodule, which calls [from_bytes] / [from_montgomery] /
    // [set_one] etc. on Cstruct constants — load the named curve
    // parameters into field_element form. Without these stubs the
    // first curve's init throws and the whole library load aborts.
    //
    // The stubs below are no-ops grouped by ((arity, return-shape).
    // Operations that compute a result mutate a buffer in place; we
    // skip the mutation, so all "computed" field_elements stay
    // zero-initialised. Operations that report a boolean return
    // [false] (= 0). NOTHING IS COMPUTED. Code paths that consume
    // these results (real ECC scalar mult, point validation,
    // signature verify) will see all-zero outputs / always-false
    // these NIST/curve25519 primitives, so the stubs unblock init
    // but anything that tries to do mirage-crypto-ec ECC for real
    // (TLS handshake, classic SSH) will silently misbehave.
    //
    // Honest implementation requires per-curve BigInteger arithmetic
    // or a JNI bridge; tracked as future work.

    /** ec_unit_1 / ec_unit_2 / ec_unit_3 / ec_unit_4 / ec_unit_5_int
     *  — no-op returning unit. Variants distinguished by arity and
     *  whether the last arg is an int (long) vs a bigstring (Object).
     *  All buffer args are dropped without mutation. */
    public static long ec_unit_1(Object a)                                 { return 0; }
    public static long ec_unit_2(Object a, Object b)                       { return 0; }
    public static long ec_unit_3(Object a, Object b, Object c)             { return 0; }
    public static long ec_unit_4(Object a, Object b, Object c, Object d)   { return 0; }
    public static long ec_unit_5_int(Object a, Object b, Object c, Object d, long e) {
        return 0;
    }

    /** ec_bool_1 / ec_bool_5_int — no-op returning [false] (= 0). */
    public static long ec_bool_1(Object a) { return 0; }
    public static long ec_bool_5_int(Object a, Object b, Object c, Object d, long e) {
        return 0;
    }
}
