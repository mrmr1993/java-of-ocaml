/**
 * [bigstringaf] C primitives — a byte-copy / compare helper
 * library used by parser frameworks like [angstrom]. Upstream C
 * at [bigstringaf_stubs.c] wraps [memcpy] / [memmove] / [memcmp]
 * on raw [Caml_ba_data] pointers.
 *
 * Since our [BigArray.data] stores one boxed cell per byte (an
 * [Object[]] of [Long]s), blit/compare go through the
 * byte-by-byte path rather than a [System.arraycopy] fast-path.
 * Correct; not fast.
 *
 * Representation reminders:
 *   - [t] (bigstring) = [BigArray] instance, kind 12 (char),
 *     1-D. Each cell is a boxed [Long] holding the byte value.
 *   - [Bytes.t] = [Bytes] runtime class, wrapping a
 *     [StringBuilder] whose chars carry byte values.
 *   - [string] = Java [String].
 */
public final class Bigstringaf {
    private Bigstringaf() {}

    private static int bsGet(BigArray ba, int i) {
        return (int) Block.asLong(ba.data[i]);
    }

    private static void bsSet(BigArray ba, int i, int b) {
        ba.data[i] = Long.valueOf(b & 0xFF);
    }

    /** [blit_to_bytes src src_off dst dst_off len]: BigArray → Bytes. */
    public static long blit_to_bytes(Object src, long srcOff,
                                     Object dst, long dstOff, long len) {
        BigArray s = (BigArray) src;
        Bytes d = (Bytes) dst;
        int n = (int) len;
        int soff = (int) srcOff, doff = (int) dstOff;
        for (int i = 0; i < n; i++) {
            d.sb.setCharAt(doff + i, (char) bsGet(s, soff + i));
        }
        return 0;
    }

    /** [blit_to_bigstring src src_off dst dst_off len]: BigArray → BigArray
     *  ([memmove] semantics — safe for overlapping). */
    public static long blit_to_bigstring(Object src, long srcOff,
                                         Object dst, long dstOff, long len) {
        BigArray s = (BigArray) src;
        BigArray d = (BigArray) dst;
        int n = (int) len;
        int soff = (int) srcOff, doff = (int) dstOff;
        // Handle overlap: copy backwards when dst > src within the same array.
        if (s == d && doff > soff) {
            for (int i = n - 1; i >= 0; i--) bsSet(d, doff + i, bsGet(s, soff + i));
        } else {
            for (int i = 0; i < n; i++)     bsSet(d, doff + i, bsGet(s, soff + i));
        }
        return 0;
    }

    /** [blit_from_bytes src src_off dst dst_off len]: Bytes or String
     *  → BigArray. OCaml's stdlib freely casts between Bytes.t and
     *  string via [Bytes.unsafe_of_string], so callers pass either
     *  runtime shape. */
    public static long blit_from_bytes(Object src, long srcOff,
                                       Object dst, long dstOff, long len) {
        BigArray d = (BigArray) dst;
        int n = (int) len;
        int soff = (int) srcOff, doff = (int) dstOff;
        if (src instanceof Bytes) {
            Bytes s = (Bytes) src;
            for (int i = 0; i < n; i++)
                bsSet(d, doff + i, s.sb.charAt(soff + i));
        } else {
            String s = (String) src;
            for (int i = 0; i < n; i++)
                bsSet(d, doff + i, s.charAt(soff + i));
        }
        return 0;
    }

    /** [memcmp_bigstring a a_off b b_off len]: bytewise compare; returns
     *  the first non-zero difference (sign-significant), or 0 if equal. */
    public static long memcmp_bigstring(Object a, long aOff,
                                        Object b, long bOff, long len) {
        BigArray ba1 = (BigArray) a;
        BigArray ba2 = (BigArray) b;
        int n = (int) len;
        int ao = (int) aOff, bo = (int) bOff;
        for (int i = 0; i < n; i++) {
            int d = bsGet(ba1, ao + i) - bsGet(ba2, bo + i);
            if (d != 0) return d;
        }
        return 0;
    }

    /** [memcmp_string ba ba_off s s_off len]: BigArray vs [String]. */
    public static long memcmp_string(Object ba, long baOff,
                                     Object s, long sOff, long len) {
        BigArray b = (BigArray) ba;
        String str = (String) s;
        int n = (int) len;
        int bo = (int) baOff, so = (int) sOff;
        for (int i = 0; i < n; i++) {
            int d = bsGet(b, bo + i) - (str.charAt(so + i) & 0xFF);
            if (d != 0) return d;
        }
        return 0;
    }
}
