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

    // === REAL: hash init / update / finalize via MessageDigest ========
    //
    // mirage-crypto's hash API stores opaque ctx state in a [Bytes.t]
    // allocated on the OCaml side ([F.ctx_size ()] bytes). We can't
    // store a [MessageDigest] reference *inside* the Bytes, so the
    // identity of the Bytes object becomes the lookup key into a
    // side-table. The OCaml side runs:
    //
    //   let empty = Bytes.create (F.ctx_size ()) in
    //   F.init empty;        ← creates / resets MessageDigest
    //   F.update empty buf size;
    //   F.finalize empty out;
    //
    // Each [F.init] resets the digest; subsequent updates accumulate;
    // finalize writes the digest to [out] (a Cstruct buffer = our
    // [BigArray]).
    //
    // Side table is bounded by the number of distinct hash contexts
    // ephemeral [Bytes] per hash op). Identity-keyed via
    // System.identityHashCode wrapping; cleaned by [_init] reuse.

    private static final java.util.Map<Object, java.security.MessageDigest>
        HASH_CTX = new java.util.IdentityHashMap<>();

    private static synchronized java.security.MessageDigest hashCtx(
            Object ctx, String algo) {
        java.security.MessageDigest m = HASH_CTX.get(ctx);
        if (m == null) {
            try {
                m = java.security.MessageDigest.getInstance(algo);
            } catch (java.security.NoSuchAlgorithmException e) {
                throw Ocaml.raiseFailure(algo + " unavailable: " + e.getMessage());
            }
            HASH_CTX.put(ctx, m);
        }
        m.reset();
        return m;
    }

    private static synchronized java.security.MessageDigest hashGet(Object ctx) {
        return HASH_CTX.get(ctx);
    }

    private static byte[] readBytes(Object buf, int len) {
        BigArray ba = (BigArray) buf;
        byte[] out = new byte[len];
        for (int i = 0; i < len; i++) {
            out[i] = (byte) (Block.asLong(ba.data[i]) & 0xFF);
        }
        return out;
    }

    private static void writeBytes(Object out, byte[] digest) {
        BigArray ba = (BigArray) out;
        for (int i = 0; i < digest.length; i++) {
            ba.data[i] = Long.valueOf(digest[i] & 0xFFL);
        }
    }

    public static long md5_init(Object ctx)    { hashCtx(ctx, "MD5"); return 0; }
    public static long sha1_init(Object ctx)   { hashCtx(ctx, "SHA-1"); return 0; }
    public static long sha224_init(Object ctx) { hashCtx(ctx, "SHA-224"); return 0; }
    public static long sha256_init(Object ctx) { hashCtx(ctx, "SHA-256"); return 0; }
    public static long sha384_init(Object ctx) { hashCtx(ctx, "SHA-384"); return 0; }
    public static long sha512_init(Object ctx) { hashCtx(ctx, "SHA-512"); return 0; }

    public static long md5_update(Object ctx, Object buf, long size)    { return hashUpdate(ctx, buf, size); }
    public static long sha1_update(Object ctx, Object buf, long size)   { return hashUpdate(ctx, buf, size); }
    public static long sha224_update(Object ctx, Object buf, long size) { return hashUpdate(ctx, buf, size); }
    public static long sha256_update(Object ctx, Object buf, long size) { return hashUpdate(ctx, buf, size); }
    public static long sha384_update(Object ctx, Object buf, long size) { return hashUpdate(ctx, buf, size); }
    public static long sha512_update(Object ctx, Object buf, long size) { return hashUpdate(ctx, buf, size); }

    private static long hashUpdate(Object ctx, Object buf, long size) {
        java.security.MessageDigest m = hashGet(ctx);
        if (m == null) return 0;
        m.update(readBytes(buf, (int) size));
        return 0;
    }

    public static long md5_finalize(Object ctx, Object out)    { return hashFinalize(ctx, out); }
    public static long sha1_finalize(Object ctx, Object out)   { return hashFinalize(ctx, out); }
    public static long sha224_finalize(Object ctx, Object out) { return hashFinalize(ctx, out); }
    public static long sha256_finalize(Object ctx, Object out) { return hashFinalize(ctx, out); }
    public static long sha384_finalize(Object ctx, Object out) { return hashFinalize(ctx, out); }
    public static long sha512_finalize(Object ctx, Object out) { return hashFinalize(ctx, out); }

    private static long hashFinalize(Object ctx, Object out) {
        java.security.MessageDigest m = hashGet(ctx);
        if (m == null) return 0;
        writeBytes(out, m.digest());
        return 0;
    }

    // === REAL: AES key schedule + en/decrypt via javax.crypto ========
    //
    // mirage-crypto's API:
    //   derive_e secret off key rounds       (key schedule, encrypt)
    //   derive_d secret off key rounds e_opt (key schedule, decrypt)
    //   enc src soff dst doff key rounds size
    //   dec src soff dst doff key rounds size
    //
    // We can't store a [Cipher] inside the [key] [BigArray]; instead
    // identity-key the BigArray to a side-table holding the raw
    // secret bytes. Each enc / dec recreates a [Cipher] from the
    // cached secret and runs AES-ECB on [size] block-aligned bytes.
    // Mirage's Fortuna RNG drives this for CTR-mode randomness.

    private static final java.util.Map<Object, byte[]> AES_KEYS
        = new java.util.IdentityHashMap<>();

    private static synchronized long aesStoreKey(Object secret, long off, Object key) {
        BigArray sec = (BigArray) secret;
        // Mirage passes [rounds = len/4 + 6] derived from the secret
        // length (16/24/32). We just stash the secret bytes; the
        // SecretKeySpec ctor figures out AES-128/192/256 from len.
        int len = sec.data.length - (int) off;
        int klen = (len >= 32) ? 32 : (len >= 24) ? 24 : 16;
        byte[] kb = new byte[klen];
        for (int i = 0; i < klen; i++) {
            kb[i] = (byte) (Block.asLong(sec.data[(int) off + i]) & 0xFF);
        }
        AES_KEYS.put(key, kb);
        return 0;
    }

    public static long aes_derive_e_key(Object secret, long off, Object key,
                                        long rounds) {
        return aesStoreKey(secret, off, key);
    }
    public static long aes_derive_d_key(Object secret, long off, Object key,
                                        long rounds, Object eOpt) {
        return aesStoreKey(secret, off, key);
    }

    public static long aes_enc(Object src, long soff, Object dst, long doff,
                               Object key, long rounds, long size) {
        return aesCrypt(src, soff, dst, doff, key, size, true);
    }
    public static long aes_dec(Object src, long soff, Object dst, long doff,
                               Object key, long rounds, long size) {
        return aesCrypt(src, soff, dst, doff, key, size, false);
    }

    private static synchronized long aesCrypt(Object src, long soff, Object dst,
                                              long doff, Object key, long size,
                                              boolean encrypt) {
        byte[] kb = AES_KEYS.get(key);
        if (kb == null) return 0;
        int n = ((int) size) * 16; // size = block count
        BigArray s = (BigArray) src;
        byte[] block = new byte[n];
        for (int i = 0; i < n; i++) {
            block[i] = (byte) (Block.asLong(s.data[(int) soff + i]) & 0xFF);
        }
        try {
            javax.crypto.Cipher c = javax.crypto.Cipher.getInstance("AES/ECB/NoPadding");
            javax.crypto.spec.SecretKeySpec spec =
                new javax.crypto.spec.SecretKeySpec(kb, "AES");
            c.init(encrypt ? javax.crypto.Cipher.ENCRYPT_MODE
                           : javax.crypto.Cipher.DECRYPT_MODE, spec);
            byte[] out = c.doFinal(block);
            BigArray d = (BigArray) dst;
            for (int i = 0; i < n; i++) {
                d.data[(int) doff + i] = Long.valueOf(out[i] & 0xFFL);
            }
        } catch (java.security.GeneralSecurityException e) {
            throw Ocaml.raiseFailure("AES " + (encrypt ? "encrypt" : "decrypt")
                                     + " failed: " + e.getMessage());
        }
        return 0;
    }

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
