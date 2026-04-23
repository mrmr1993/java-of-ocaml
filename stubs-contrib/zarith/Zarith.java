import java.math.BigInteger;

/**
 * Real(-ish) adapter for [zarith]'s arbitrary-precision integer
 * primitives — wraps [java.math.BigInteger] and threads it through
 * OCaml's [Z.t] surface.
 *
 * Representation: every [Z.t] value on the Java side is a
 * [java.math.BigInteger]. We never return the OCaml small-int
 * representation, even for values that fit in a word — zarith's
 * OCaml wrappers do [Obj.is_int] fast-path branches for the small-
 * int case, and if we sometimes return a boxed [Long] and sometimes
 * a [BigInteger], the branch goes one way while the C binding (us)
 * expects the other. Always blocks is safe; always-small-int would
 * lose out on the full Z range. Blocks it is.
 *
 * Performance: fine for init paths; BigInteger is 10-100x slower
 * than native GMP on hot paths. the test binary's startup probably only does
 * a few dozen Z ops, so this is good enough.
 *
 * The few "mathematically impossible" primitives (install_frametable,
 * initialize_nat) are GC/runtime hooks for native GMP — we don't
 * have a GMP arena, so they're no-ops.
 */
public final class Zarith {
    private Zarith() {}

    private static BigInteger z(Object o) {
        if (o instanceof BigInteger) return (BigInteger) o;
        // Tolerate small-int arguments that some callers pass without
        // going through [ml_z_of_int] (e.g. literal constants that
        // OCaml happened to emit as immediates).
        return BigInteger.valueOf(Block.asLong(o));
    }

    // ==== GC / runtime hooks (no-ops) ============================
    public static long ml_z_init(Object unit)            { return 0; }
    public static long ml_z_install_frametable(Object u) { return 0; }
    public static long initialize_nat(Object u)          { return 0; }

    // ==== Constructors ===========================================
    public static Object ml_z_of_int(long n)         { return BigInteger.valueOf(n); }
    public static Object ml_z_of_int32(long n)       { return BigInteger.valueOf((int) n); }
    public static Object ml_z_of_int64(long n)       { return BigInteger.valueOf(n); }
    public static Object ml_z_of_nativeint(long n)   { return BigInteger.valueOf(n); }

    public static Object ml_z_of_float(double d) {
        if (Double.isNaN(d) || Double.isInfinite(d)) {
            throw new CamlException(new Block(0, new Object[]{
                "Z.of_float: not a finite number"
            }));
        }
        return BigInteger.valueOf((long) d);
    }

    /** [of_substring_base base s pos len]: parse a numeric string. */
    public static Object ml_z_of_substring_base(long base, Object s, long pos, long len) {
        String str = (String) s;
        String sub = str.substring((int) pos, (int) (pos + len));
        int b = (int) base;
        if (b == 0) {
            // Auto-detect prefix per Z.of_string.
            if (sub.startsWith("0x") || sub.startsWith("0X")) {
                b = 16;
                sub = sub.substring(2);
            } else if (sub.startsWith("0o") || sub.startsWith("0O")) {
                b = 8;
                sub = sub.substring(2);
            } else if (sub.startsWith("0b") || sub.startsWith("0B")) {
                b = 2;
                sub = sub.substring(2);
            } else {
                b = 10;
            }
        }
        return new BigInteger(sub, b);
    }

    /** [of_bits s]: parse a little-endian byte string. Interprets
     *  [s] as an unsigned two's-complement-style sequence and
     *  returns the corresponding [BigInteger]. */
    public static Object ml_z_of_bits(Object s) {
        String str = (String) s;
        byte[] bytes = new byte[str.length()];
        // little-endian → reverse for BigInteger (which is big-endian)
        for (int i = 0; i < str.length(); i++) {
            bytes[str.length() - 1 - i] = (byte) str.charAt(i);
        }
        return new BigInteger(1, bytes);
    }

    // ==== Extractors =============================================
    public static long ml_z_to_int(Object z)       { return z(z).longValueExact(); }
    public static long ml_z_to_int32(Object z)     { return z(z).intValueExact(); }
    public static long ml_z_to_int64(Object z)     { return z(z).longValueExact(); }
    public static long ml_z_to_nativeint(Object z) { return z(z).longValueExact(); }

    public static Object ml_z_to_bits(Object z) {
        BigInteger v = z(z).abs();
        byte[] be = v.toByteArray();
        // Strip BigInteger's sign-extension byte if present.
        int start = (be.length > 1 && be[0] == 0) ? 1 : 0;
        int n = be.length - start;
        char[] cs = new char[n];
        for (int i = 0; i < n; i++) {
            cs[i] = (char) (be[be.length - 1 - i] & 0xFF);
        }
        return new String(cs);
    }

    // ==== Arithmetic =============================================
    public static Object ml_z_neg(Object a)             { return z(a).negate(); }
    public static Object ml_z_abs(Object a)             { return z(a).abs(); }
    public static Object ml_z_succ(Object a)            { return z(a).add(BigInteger.ONE); }
    public static Object ml_z_pred(Object a)            { return z(a).subtract(BigInteger.ONE); }
    public static Object ml_z_add(Object a, Object b)   { return z(a).add(z(b)); }
    public static Object ml_z_sub(Object a, Object b)   { return z(a).subtract(z(b)); }
    public static Object ml_z_mul(Object a, Object b)   { return z(a).multiply(z(b)); }
    public static Object ml_z_div(Object a, Object b)   { return z(a).divide(z(b)); }
    public static Object ml_z_rem(Object a, Object b)   { return z(a).remainder(z(b)); }
    public static Object ml_z_divexact(Object a, Object b) { return z(a).divide(z(b)); }

    /** [cdiv]: ceiling division toward +∞. */
    public static Object ml_z_cdiv(Object a, Object b) {
        BigInteger x = z(a), y = z(b);
        BigInteger[] qr = x.divideAndRemainder(y);
        BigInteger q = qr[0], r = qr[1];
        if (r.signum() != 0 && r.signum() == y.signum()) {
            q = q.add(BigInteger.ONE);
        }
        return q;
    }

    /** [fdiv]: floor division toward -∞. */
    public static Object ml_z_fdiv(Object a, Object b) {
        BigInteger x = z(a), y = z(b);
        BigInteger[] qr = x.divideAndRemainder(y);
        BigInteger q = qr[0], r = qr[1];
        if (r.signum() != 0 && r.signum() != y.signum()) {
            q = q.subtract(BigInteger.ONE);
        }
        return q;
    }

    /** [div_rem]: returns a Block tagged 0 holding {quotient,
     *  remainder} — matches zarith's OCaml wrapper expectation. */
    public static Object ml_z_div_rem(Object a, Object b) {
        BigInteger[] qr = z(a).divideAndRemainder(z(b));
        return new Block(0, new Object[]{ qr[0], qr[1] });
    }

    public static Object ml_z_pow(Object a, long n)     { return z(a).pow((int) n); }

    // ==== Bitwise =================================================
    public static Object ml_z_logand(Object a, Object b) { return z(a).and(z(b)); }
    public static Object ml_z_logor(Object a, Object b)  { return z(a).or(z(b)); }
    public static Object ml_z_logxor(Object a, Object b) { return z(a).xor(z(b)); }
    public static Object ml_z_lognot(Object a)           { return z(a).not(); }
    public static Object ml_z_shift_left(Object a, long n)  { return z(a).shiftLeft((int) n); }
    public static Object ml_z_shift_right(Object a, long n) { return z(a).shiftRight((int) n); }

    /** [extract z pos len]: unsigned bit-slice. */
    public static Object ml_z_extract(Object a, long pos, long len) {
        BigInteger v = z(a).shiftRight((int) pos);
        BigInteger mask = BigInteger.ONE.shiftLeft((int) len).subtract(BigInteger.ONE);
        return v.and(mask);
    }

    public static long ml_z_testbit(Object a, long n)    { return z(a).testBit((int) n) ? 1 : 0; }
    public static long ml_z_popcount(Object a)           { return z(a).bitCount(); }
    public static long ml_z_numbits(Object a)            { return z(a).bitLength(); }

    // ==== GCD =====================================================
    public static Object ml_z_gcd(Object a, Object b) {
        return z(a).abs().gcd(z(b).abs());
    }

    /** [gcdext_intern a b]: returns Block{gcd, u, v} with a*u + b*v = gcd.
     *  Java's [BigInteger] has no built-in extended gcd; implement
     *  Euclid's iterative form. */
    public static Object ml_z_gcdext_intern(Object ao, Object bo) {
        BigInteger a = z(ao).abs(), b = z(bo).abs();
        BigInteger old_r = a, r = b;
        BigInteger old_s = BigInteger.ONE, s = BigInteger.ZERO;
        BigInteger old_t = BigInteger.ZERO, t = BigInteger.ONE;
        while (r.signum() != 0) {
            BigInteger q = old_r.divide(r);
            BigInteger tmp;
            tmp = r;    r = old_r.subtract(q.multiply(r));       old_r = tmp;
            tmp = s;    s = old_s.subtract(q.multiply(s));       old_s = tmp;
            tmp = t;    t = old_t.subtract(q.multiply(t));       old_t = tmp;
        }
        return new Block(0, new Object[]{ old_r, old_s, old_t });
    }

    // ==== Predicates =============================================
    public static long ml_z_sign(Object a)      { return z(a).signum(); }
    public static long ml_z_compare(Object a, Object b) { return z(a).compareTo(z(b)); }
    public static long ml_z_equal(Object a, Object b)   { return z(a).equals(z(b)) ? 1 : 0; }

    public static long ml_z_fits_int(Object a) {
        BigInteger v = z(a);
        // OCaml int on 64-bit is 63-bit signed.
        BigInteger max = BigInteger.ONE.shiftLeft(62).subtract(BigInteger.ONE);
        BigInteger min = BigInteger.ONE.shiftLeft(62).negate();
        return (v.compareTo(min) >= 0 && v.compareTo(max) <= 0) ? 1 : 0;
    }
    public static long ml_z_fits_int32(Object a) {
        BigInteger v = z(a);
        return (v.bitLength() < 32) ? 1 : 0;
    }
    public static long ml_z_fits_int64(Object a) {
        BigInteger v = z(a);
        return (v.bitLength() < 64) ? 1 : 0;
    }
    public static long ml_z_fits_nativeint(Object a) { return ml_z_fits_int64(a); }

    // ==== Hashing + formatting ===================================
    public static long ml_z_hash(Object a)      { return z(a).hashCode(); }

    public static Object ml_z_format(Object fmt, Object a) {
        // Zarith's format string is printf-like ("%d", "%x", "%o",
        // "%b"). Sufficient to support the common cases here.
        String f = (String) fmt;
        BigInteger v = z(a);
        if (f.endsWith("d")) return v.toString(10);
        if (f.endsWith("x")) return v.toString(16);
        if (f.endsWith("X")) return v.toString(16).toUpperCase();
        if (f.endsWith("o")) return v.toString(8);
        if (f.endsWith("b")) return v.toString(2);
        return v.toString(10);
    }
}
