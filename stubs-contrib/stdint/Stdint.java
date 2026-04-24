/**
 * Stubs for the [stdint] opam package — fixed-width integer
 * types ([int8] / [int16] / [int24] / [int32] / [int40] /
 * [int48] / [int56] / [int64] / [int128] and their unsigned
 * twins). Upstream uses C custom-block representations behind
 * ~480 externals.
 *
 * ### Representation
 *
 * Every width is represented as a JVM primitive [long] (boxed
 * [java.lang.Long] when crossing into [Object]-typed slots). For
 * widths [W < 64], we mask / sign-extend on input where it
 * matters; for [W = 64] the bit pattern carries directly. For
 * [W = 128], the high half is dropped — typical init paths only
 * touch a handful of int128 constants and it's enough that the
 * primitive returns *something* without throwing. If real
 * 128-bit arithmetic ever runs through here, this needs a
 * BigInteger-backed Block.
 *
 * Conversion ops are mostly mask + sign-extend; the underlying
 * value carrier doesn't change.
 *
 * The full primitive surface (~480 names) is mapped through
 * stubs.json. Most route to a small set of typed helpers below;
 * arity-1 / arity-2 fall-through to [zero] only for ops whose
 * downstream impact at init is benign.
 */
public final class Stdint {
    private Stdint() {}

    private static final Object ZERO = Long.valueOf(0L);

    // ==== arity-overloaded fallback ================================

    // ==== unboxing helpers =========================================
    private static long L(Object o) {
        if (o instanceof Long) return ((Long) o).longValue();
        if (o instanceof Integer) return ((Integer) o).longValue();
        if (o instanceof Number) return ((Number) o).longValue();
        return 0L;
    }
    private static double D(Object o) {
        if (o instanceof Double) return ((Double) o).doubleValue();
        if (o instanceof Number) return ((Number) o).doubleValue();
        return 0.0;
    }
    private static long mask(long v, int bits) {
        if (bits >= 64) return v;
        return v & ((1L << bits) - 1L);
    }
    private static long sext(long v, int bits) {
        if (bits >= 64) return v;
        long m = 1L << (bits - 1);
        long masked = mask(v, bits);
        return (masked ^ m) - m;
    }

    // ==== conversions: of_int / of_float / to_int / to_float =======
    // Width is encoded by which manifest entry routes here, but
    // we don't carry it through — we just mask/sign-extend in
    // the per-width entry below.

    // signed of_int: sign-extend representation (no truncation
    // of the source).
    public static Object signedOfInt8(Object x)   { return Long.valueOf(sext(L(x), 8)); }
    public static Object signedOfInt16(Object x)  { return Long.valueOf(sext(L(x), 16)); }
    public static Object signedOfInt24(Object x)  { return Long.valueOf(sext(L(x), 24)); }
    public static Object signedOfInt32(Object x)  { return Long.valueOf(sext(L(x), 32)); }
    public static Object signedOfInt40(Object x)  { return Long.valueOf(sext(L(x), 40)); }
    public static Object signedOfInt48(Object x)  { return Long.valueOf(sext(L(x), 48)); }
    public static Object signedOfInt56(Object x)  { return Long.valueOf(sext(L(x), 56)); }
    public static Object signedOfInt64(Object x)  { return Long.valueOf(L(x)); }
    public static Object signedOfInt128(Object x) { return Long.valueOf(L(x)); }

    public static Object unsignedOfInt8(Object x)   { return Long.valueOf(mask(L(x), 8)); }
    public static Object unsignedOfInt16(Object x)  { return Long.valueOf(mask(L(x), 16)); }
    public static Object unsignedOfInt24(Object x)  { return Long.valueOf(mask(L(x), 24)); }
    public static Object unsignedOfInt32(Object x)  { return Long.valueOf(mask(L(x), 32)); }
    public static Object unsignedOfInt40(Object x)  { return Long.valueOf(mask(L(x), 40)); }
    public static Object unsignedOfInt48(Object x)  { return Long.valueOf(mask(L(x), 48)); }
    public static Object unsignedOfInt56(Object x)  { return Long.valueOf(mask(L(x), 56)); }
    public static Object unsignedOfInt64(Object x)  { return Long.valueOf(L(x)); }
    public static Object unsignedOfInt128(Object x) { return Long.valueOf(L(x)); }

    // float conversions: store as int bits at the requested width,
    // sign-extending or masking as needed. Init paths use
    // these for converting captured constants.
    public static Object signedOfFloat8(Object x)   { return Long.valueOf(sext((long) D(x), 8)); }
    public static Object signedOfFloat16(Object x)  { return Long.valueOf(sext((long) D(x), 16)); }
    public static Object signedOfFloat24(Object x)  { return Long.valueOf(sext((long) D(x), 24)); }
    public static Object signedOfFloat32(Object x)  { return Long.valueOf((long) D(x)); }
    public static Object signedOfFloat40(Object x)  { return Long.valueOf(sext((long) D(x), 40)); }
    public static Object signedOfFloat48(Object x)  { return Long.valueOf(sext((long) D(x), 48)); }
    public static Object signedOfFloat56(Object x)  { return Long.valueOf(sext((long) D(x), 56)); }
    public static Object signedOfFloat64(Object x)  { return Long.valueOf((long) D(x)); }
    public static Object signedOfFloat128(Object x) { return Long.valueOf((long) D(x)); }

    public static Object floatOfSigned(Object x) { return Double.valueOf((double) L(x)); }

    // to_int / to_nativeint: return as Long, no width adjustment
    // (caller already truncated appropriately).
    public static Object toLong(Object x) { return Long.valueOf(L(x)); }

    // ==== arithmetic at a given width ==============================
    public static Object addS(Object a, Object b, int bits) {
        return Long.valueOf(sext(L(a) + L(b), bits));
    }
    public static Object subS(Object a, Object b, int bits) {
        return Long.valueOf(sext(L(a) - L(b), bits));
    }
    public static Object mulS(Object a, Object b, int bits) {
        return Long.valueOf(sext(L(a) * L(b), bits));
    }
    public static Object addU(Object a, Object b, int bits) {
        return Long.valueOf(mask(L(a) + L(b), bits));
    }
    public static Object subU(Object a, Object b, int bits) {
        return Long.valueOf(mask(L(a) - L(b), bits));
    }
    public static Object mulU(Object a, Object b, int bits) {
        return Long.valueOf(mask(L(a) * L(b), bits));
    }

    // Per-width signed arithmetic — explicit to keep the
    // manifest's per-entry mapping mechanical.
    public static Object addSigned8(Object a, Object b)   { return addS(a, b, 8); }
    public static Object addSigned16(Object a, Object b)  { return addS(a, b, 16); }
    public static Object addSigned24(Object a, Object b)  { return addS(a, b, 24); }
    public static Object addSigned32(Object a, Object b)  { return addS(a, b, 32); }
    public static Object addSigned40(Object a, Object b)  { return addS(a, b, 40); }
    public static Object addSigned48(Object a, Object b)  { return addS(a, b, 48); }
    public static Object addSigned56(Object a, Object b)  { return addS(a, b, 56); }
    public static Object addSigned64(Object a, Object b)  { return Long.valueOf(L(a) + L(b)); }
    public static Object addSigned128(Object a, Object b) { return Long.valueOf(L(a) + L(b)); }

    public static Object subSigned8(Object a, Object b)   { return subS(a, b, 8); }
    public static Object subSigned16(Object a, Object b)  { return subS(a, b, 16); }
    public static Object subSigned24(Object a, Object b)  { return subS(a, b, 24); }
    public static Object subSigned32(Object a, Object b)  { return subS(a, b, 32); }
    public static Object subSigned40(Object a, Object b)  { return subS(a, b, 40); }
    public static Object subSigned48(Object a, Object b)  { return subS(a, b, 48); }
    public static Object subSigned56(Object a, Object b)  { return subS(a, b, 56); }
    public static Object subSigned64(Object a, Object b)  { return Long.valueOf(L(a) - L(b)); }
    public static Object subSigned128(Object a, Object b) { return Long.valueOf(L(a) - L(b)); }

    public static Object mulSigned8(Object a, Object b)   { return mulS(a, b, 8); }
    public static Object mulSigned16(Object a, Object b)  { return mulS(a, b, 16); }
    public static Object mulSigned24(Object a, Object b)  { return mulS(a, b, 24); }
    public static Object mulSigned32(Object a, Object b)  { return mulS(a, b, 32); }
    public static Object mulSigned40(Object a, Object b)  { return mulS(a, b, 40); }
    public static Object mulSigned48(Object a, Object b)  { return mulS(a, b, 48); }
    public static Object mulSigned56(Object a, Object b)  { return mulS(a, b, 56); }
    public static Object mulSigned64(Object a, Object b)  { return Long.valueOf(L(a) * L(b)); }
    public static Object mulSigned128(Object a, Object b) { return Long.valueOf(L(a) * L(b)); }

    public static Object divSigned(Object a, Object b) {
        long bv = L(b);
        return Long.valueOf(bv == 0 ? 0L : L(a) / bv);
    }
    public static Object modSigned(Object a, Object b) {
        long bv = L(b);
        return Long.valueOf(bv == 0 ? 0L : L(a) % bv);
    }
    public static Object negSigned8(Object a)   { return Long.valueOf(sext(-L(a), 8)); }
    public static Object negSigned16(Object a)  { return Long.valueOf(sext(-L(a), 16)); }
    public static Object negSigned24(Object a)  { return Long.valueOf(sext(-L(a), 24)); }
    public static Object negSigned32(Object a)  { return Long.valueOf(sext(-L(a), 32)); }
    public static Object negSigned40(Object a)  { return Long.valueOf(sext(-L(a), 40)); }
    public static Object negSigned48(Object a)  { return Long.valueOf(sext(-L(a), 48)); }
    public static Object negSigned56(Object a)  { return Long.valueOf(sext(-L(a), 56)); }
    public static Object negSigned64(Object a)  { return Long.valueOf(-L(a)); }
    public static Object negSigned128(Object a) { return Long.valueOf(-L(a)); }
    public static Object absSigned(Object a)    { return Long.valueOf(Math.abs(L(a))); }

    public static Object andOp(Object a, Object b) { return Long.valueOf(L(a) & L(b)); }
    public static Object orOp(Object a, Object b)  { return Long.valueOf(L(a) | L(b)); }
    public static Object xorOp(Object a, Object b) { return Long.valueOf(L(a) ^ L(b)); }

    public static Object shlSigned8(Object a, Object n)   { return Long.valueOf(sext(L(a) << (L(n) & 7), 8)); }
    public static Object shlSigned16(Object a, Object n)  { return Long.valueOf(sext(L(a) << (L(n) & 15), 16)); }
    public static Object shlSigned24(Object a, Object n)  { return Long.valueOf(sext(L(a) << (L(n) & 31), 24)); }
    public static Object shlSigned32(Object a, Object n)  { return Long.valueOf(sext(L(a) << (L(n) & 31), 32)); }
    public static Object shlSigned40(Object a, Object n)  { return Long.valueOf(sext(L(a) << (L(n) & 63), 40)); }
    public static Object shlSigned48(Object a, Object n)  { return Long.valueOf(sext(L(a) << (L(n) & 63), 48)); }
    public static Object shlSigned56(Object a, Object n)  { return Long.valueOf(sext(L(a) << (L(n) & 63), 56)); }
    public static Object shlSigned64(Object a, Object n)  { return Long.valueOf(L(a) << (L(n) & 63)); }
    public static Object shlSigned128(Object a, Object n) { return Long.valueOf(L(a) << (L(n) & 63)); }

    public static Object shrSigned(Object a, Object n)   { return Long.valueOf(L(a) >> (L(n) & 63)); }
    public static Object shrUnsigned(Object a, Object n) { return Long.valueOf(L(a) >>> (L(n) & 63)); }

    // div / mod for unsigned widths route to JVM unsigned ops.
    public static Object divUnsigned(Object a, Object b) {
        long bv = L(b);
        return Long.valueOf(bv == 0 ? 0L : Long.divideUnsigned(L(a), bv));
    }
    public static Object modUnsigned(Object a, Object b) {
        long bv = L(b);
        return Long.valueOf(bv == 0 ? 0L : Long.remainderUnsigned(L(a), bv));
    }

    // ==== misc ====================================================
    // Custom-ops registration is a no-op on JVM (we don't have
    // OCaml's custom-block plumbing); the side effect is just to
    // make subsequent allocations carry the right ops vtable, and
    // since our Long carrier doesn't need one, returning unit is
    // safe.
    public static Object initCustomOps()                                  { return ZERO; }
    public static Object initCustomOps(Object a)                          { return ZERO; }
    public static Object initCustomOps(Object a, Object b)                { return ZERO; }
    public static Object initCustomOps(Object a, Object b, Object c)      { return ZERO; }

    // min_int / max_int per width — return the bit pattern OCaml
    // expects so that downstream guards (capture into module
    // globals etc.) see plausible values.
    public static Object maxIntS(int bits) {
        if (bits >= 64) return Long.valueOf(Long.MAX_VALUE);
        return Long.valueOf((1L << (bits - 1)) - 1L);
    }
    public static Object minIntS(int bits) {
        if (bits >= 64) return Long.valueOf(Long.MIN_VALUE);
        return Long.valueOf(-(1L << (bits - 1)));
    }
    public static Object maxIntU(int bits) {
        if (bits >= 64) return Long.valueOf(-1L);
        return Long.valueOf((1L << bits) - 1L);
    }

    // The OCaml-side declarations are [unit -> t], so the
    // primitive call passes the unit value as a single argument.
    // Methods take [Object] and ignore it.
    public static Object maxIntS8(Object u)    { return maxIntS(8); }
    public static Object maxIntS16(Object u)   { return maxIntS(16); }
    public static Object maxIntS24(Object u)   { return maxIntS(24); }
    public static Object maxIntS32(Object u)   { return maxIntS(32); }
    public static Object maxIntS40(Object u)   { return maxIntS(40); }
    public static Object maxIntS48(Object u)   { return maxIntS(48); }
    public static Object maxIntS56(Object u)   { return maxIntS(56); }
    public static Object maxIntS64(Object u)   { return maxIntS(64); }
    public static Object maxIntS128(Object u)  { return maxIntS(64); }

    public static Object minIntS8(Object u)    { return minIntS(8); }
    public static Object minIntS16(Object u)   { return minIntS(16); }
    public static Object minIntS24(Object u)   { return minIntS(24); }
    public static Object minIntS32(Object u)   { return minIntS(32); }
    public static Object minIntS40(Object u)   { return minIntS(40); }
    public static Object minIntS48(Object u)   { return minIntS(48); }
    public static Object minIntS56(Object u)   { return minIntS(56); }
    public static Object minIntS64(Object u)   { return minIntS(64); }
    public static Object minIntS128(Object u)  { return minIntS(64); }

    public static Object maxIntU8(Object u)    { return maxIntU(8); }
    public static Object maxIntU16(Object u)   { return maxIntU(16); }
    public static Object maxIntU24(Object u)   { return maxIntU(24); }
    public static Object maxIntU32(Object u)   { return maxIntU(32); }
    public static Object maxIntU40(Object u)   { return maxIntU(40); }
    public static Object maxIntU48(Object u)   { return maxIntU(48); }
    public static Object maxIntU56(Object u)   { return maxIntU(56); }
    public static Object maxIntU64(Object u)   { return maxIntU(64); }
    public static Object maxIntU128(Object u)  { return maxIntU(64); }

    // Bit pattern helpers for float conversion at int32 / int64
    // widths (the only widths where stdint exposes them).
    public static Object floatOfBits32(Object x) {
        return Double.valueOf((double) Float.intBitsToFloat((int) L(x)));
    }
    public static Object bitsOfFloat32(Object x) {
        return Long.valueOf(Float.floatToRawIntBits((float) D(x)) & 0xFFFFFFFFL);
    }
    public static Object floatOfBits64(Object x) {
        return Double.valueOf(Double.longBitsToDouble(L(x)));
    }
    public static Object bitsOfFloat64(Object x) {
        return Long.valueOf(Double.doubleToRawLongBits(D(x)));
    }
}
