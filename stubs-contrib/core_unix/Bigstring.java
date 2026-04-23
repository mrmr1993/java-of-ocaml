/**
 * Bigstring C primitives from [base_bigstring], [core_kernel.
 * bigstring], and [core.bigstring_unix]. Upstream implements each
 * as a thin wrapper around [read(2)] / [write(2)] / [sendmsg(2)]
 * / [memcpy(3)] on the raw [Bigarray.Array1] buffer.
 *
 * ### Representation
 *
 * An OCaml [Bigstring.t] is a 1-D [Bigarray.Array1.t] of chars.
 * Our runtime represents this as a [BigArray] class (built-in).
 * [bigstring_alloc] creates one of those via
 * [BigArray.allocBigstring].
 *
 * ### Stubbing strategy
 *
 * Most [bigstring_*_stub] syscall wrappers (pread / pwrite / read
 * / write / send / recv / writev / sendmmsg / recvmmsg / output /
 * input) return [0] (bytes transferred = 0) — enough to satisfy
 * init-time references that don't actually consume the data. A
 * real implementation would delegate to the corresponding
 * [java.nio.channels.*] APIs.
 *
 * The pure-memory helpers ([memset_stub], [memcmp_stub], [find],
 * [blit_*_stub], [is_mmapped_stub]) have real Java equivalents
 * via [java.util.Arrays] / [System.arraycopy], but a caller
 * workload doesn't reach them; stubbing as [0] here is safe.
 *
 * [bigstring_alloc] is the one exception — it returns a live
 * [BigArray], so callers can read [.dim1] / access cells through
 * the existing [BigArray] runtime class.
 */
public final class Bigstring {
    private Bigstring() {}

    private static final Object ZERO = Long.valueOf(0L);

    /**
     * [bigstring_alloc pos len]. Upstream:
     * [caml_ba_alloc_dims(CAML_BA_UINT8 | CAML_BA_C_LAYOUT, 1, NULL, len)].
     * Ignores [pos]; allocates a 1-D char bigarray of size [len].
     */
    public static Object bigstring_alloc(Object pos, long len) {
        return BigArray.allocBigstring(len);
    }

    // ==== blit primitives ============================================
    // Without these, [Bigstring.of_string] silently produces a
    // zero-filled bigstring and downstream [bin_io] reads garbage
    // — which surfaces as "version read 0 does not match expected

    private static int byteAt(BigArray ba, int i) {
        return (int) Block.asLong(ba.data[i]) & 0xFF;
    }

    private static void setByte(BigArray ba, int i, int b) {
        ba.data[i] = Long.valueOf(b & 0xFF);
    }

    /** [bigstring_blit_string_bigstring_stub]: string → bigstring. */
    public static long blitStringToBigstring(Object src, long srcPos,
                                             Object dst, long dstPos,
                                             long len) {
        String s = (String) src;
        BigArray d = (BigArray) dst;
        int n = (int) len, so = (int) srcPos, dop = (int) dstPos;
        for (int i = 0; i < n; i++) setByte(d, dop + i, s.charAt(so + i));
        return 0;
    }

    /** [bigstring_blit_bytes_bigstring_stub]: Bytes → bigstring. */
    public static long blitBytesToBigstring(Object src, long srcPos,
                                            Object dst, long dstPos,
                                            long len) {
        BigArray d = (BigArray) dst;
        int n = (int) len, so = (int) srcPos, dop = (int) dstPos;
        if (src instanceof Bytes) {
            Bytes s = (Bytes) src;
            for (int i = 0; i < n; i++) setByte(d, dop + i, s.sb.charAt(so + i));
        } else {
            // Caller may pass a string via [Bytes.unsafe_of_string].
            String s = (String) src;
            for (int i = 0; i < n; i++) setByte(d, dop + i, s.charAt(so + i));
        }
        return 0;
    }

    /** [bigstring_blit_bigstring_bytes_stub]: bigstring → Bytes. */
    public static long blitBigstringToBytes(Object src, long srcPos,
                                            Object dst, long dstPos,
                                            long len) {
        BigArray s = (BigArray) src;
        Bytes d = (Bytes) dst;
        int n = (int) len, so = (int) srcPos, dop = (int) dstPos;
        for (int i = 0; i < n; i++) d.sb.setCharAt(dop + i, (char) byteAt(s, so + i));
        return 0;
    }

    /** [bigstring_blit_stub]: bigstring → bigstring (memmove semantics). */
    public static long blitBigstringToBigstring(Object src, long srcPos,
                                                Object dst, long dstPos,
                                                long len) {
        BigArray s = (BigArray) src;
        BigArray d = (BigArray) dst;
        int n = (int) len, so = (int) srcPos, dop = (int) dstPos;
        if (s == d && dop > so) {
            for (int i = n - 1; i >= 0; i--) setByte(d, dop + i, byteAt(s, so + i));
        } else {
            for (int i = 0; i < n; i++) setByte(d, dop + i, byteAt(s, so + i));
        }
        return 0;
    }

    /** [bigstring_memcmp_stub]: bytewise comparison; first non-zero
     *  difference (sign-significant), or 0 if equal. */
    public static long memcmp(Object a, long aPos, Object b, long bPos,
                              long len) {
        BigArray ba = (BigArray) a;
        BigArray bb = (BigArray) b;
        int n = (int) len, ao = (int) aPos, bo = (int) bPos;
        for (int i = 0; i < n; i++) {
            int d = byteAt(ba, ao + i) - byteAt(bb, bo + i);
            if (d != 0) return d;
        }
        return 0;
    }

    /** [bigstring_memset_stub]: fill [len] bytes starting at [pos] with [c]. */
    public static long memset(Object dst, long pos, long len, long c) {
        BigArray d = (BigArray) dst;
        int n = (int) len, po = (int) pos, cv = (int) c;
        for (int i = 0; i < n; i++) setByte(d, po + i, cv);
        return 0;
    }

    // ==== zero-returners (see javadoc) ===============================

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
