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
