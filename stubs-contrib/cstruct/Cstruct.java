/**
 * Stubs for [cstruct]'s C primitives — bigarray helpers for the
 * [Cstruct.t] type (a [(char, int8_unsigned_elt, c_layout)
 * Bigarray.Array1.t] with offset + length).
 *
 * [caml_fill_bigstring] is the only init-time primitive (backs
 * [Cstruct.memset]). Real impl calls [memset] on the raw data
 * pointer; we iterate and box through the per-cell representation
 * used by our [BigArray] runtime class.
 */
public final class Cstruct {
    private Cstruct() {}

    /** [caml_fill_bigstring ba off len v]: set [len] bytes starting
     *  at [off] to the byte [v]. */
    public static long caml_fill_bigstring(Object ba, long off, long len, long v) {
        BigArray a = (BigArray) ba;
        int start = (int) off;
        int n = (int) len;
        Long boxed = Long.valueOf(v & 0xFF);
        for (int i = 0; i < n; i++) {
            a.data[start + i] = boxed;
        }
        return 0;
    }
}
