/**
 * Stubs for [libsodium] (NaCl) ctypes-foreign bindings — the
 * cstubs-indexed [caml__<N>_<nacl_symbol>] entry points covering
 * the curve25519 / XSalsa20Poly1305 box, sign, onetimeauth /
 * poly1305, secretbox, and pwhash families.
 *
 * ### Stubbing strategy
 *
 * We do NOT implement libsodium. The actual cryptographic
 * primitives ([_keypair], [_open], [_seal], [_pwhash], [_sign],
 * etc.) are intentionally NOT in stubs.json — they fall through
 * to the auto-generated "primitive not implemented" stub.
 *
 * The methods in this file are DELIBERATE STUBS for the
 * "constant query" entry points that the test binary's init paths read at
 * module load to size buffers and configure parameters
 * ([*_bytes], [memlimit_*], [opslimit_*], etc.). Each returns
 * the upstream libsodium constant so init proceeds; no crypto
 * is performed. Real callers that proceed past sizing into
 * actual operations hit the auto-stub and fail loudly.
 */
public final class Sodium {
    private Sodium() {}

    // === DELIBERATE STUB: sodium_init() ===============================
    // [sodium.ml] init runs [Sodium.init ()] once at module load to
    // initialize the libsodium runtime (chooses code paths, seeds
    // PRNG, picks AES backend). On real hardware this returns 0
    // ("first call, succeeded"). Returning 0 lets module init bind
    // its return code; no library state to initialize on our side.
    public static long sodium_init(Object u) { return 0; }

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

    // crypto_generichash_blake2b — bytes / keybytes clamps from
    // libsodium. The base [blake2b_bytes] / [_keybytes] live in
    // their own block below.
    public static long blake2b_bytes_min(Object u)        { return 16; }
    public static long blake2b_bytes_max(Object u)        { return 64; }
    public static long blake2b_keybytes_min(Object u)     { return 16; }
    public static long blake2b_keybytes_max(Object u)     { return 64; }

    // crypto_pwhash_argon2i — sizes + the (memlimit, opslimit)
    // [sodium.ml:508-520] eagerly binds [interactive] /
    // [moderate] / [sensitive] difficulty records by reading all
    // six. Values are libsodium's documented defaults.
    public static long pwhash_saltbytes(Object u)             { return 16; }
    public static long pwhash_strbytes(Object u)              { return 128; }
    public static long pwhash_memlimit_interactive(Object u)  { return 67108864L; }   // 64 MiB
    public static long pwhash_memlimit_moderate(Object u)     { return 268435456L; }  // 256 MiB
    public static long pwhash_memlimit_sensitive(Object u)    { return 1073741824L; } // 1 GiB
    public static long pwhash_opslimit_interactive(Object u)  { return 4; }
    public static long pwhash_opslimit_moderate(Object u)     { return 6; }
    public static long pwhash_opslimit_sensitive(Object u)    { return 8; }

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
