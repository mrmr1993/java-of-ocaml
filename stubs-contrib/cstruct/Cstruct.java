/**
 * Real implementations for [cstruct]'s C primitives — bigarray
 * helpers for the [Cstruct.t] type (a [(char, int8_unsigned_elt,
 * c_layout) Bigarray.Array1.t] with offset + length).
 *
 * Not stubs — these are real, just out-of-tree because [cstruct]
 * isn't in the js_of_ocaml built-in runtime.
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

    /** [caml_blit_bigstring_to_bigstring src srcOff dst dstOff len]
     *  with memmove semantics on the same-array case. */
    public static long caml_blit_bigstring_to_bigstring(
            Object src, long srcOff, Object dst, long dstOff, long len) {
        BigArray s = (BigArray) src;
        BigArray d = (BigArray) dst;
        int n = (int) len, so = (int) srcOff, dop = (int) dstOff;
        if (s == d && dop > so) {
            for (int i = n - 1; i >= 0; i--) d.data[dop + i] = s.data[so + i];
        } else {
            for (int i = 0; i < n; i++) d.data[dop + i] = s.data[so + i];
        }
        return 0;
    }

    /** [caml_blit_string_to_bigstring src srcOff dst dstOff len].
     *  Cstruct aliases the [bytes_to_bigstring] external to this
     *  same C symbol; [src] is therefore either a [String] or a
     *  [Bytes]. */
    public static long caml_blit_string_to_bigstring(
            Object src, long srcOff, Object dst, long dstOff, long len) {
        BigArray d = (BigArray) dst;
        int n = (int) len, so = (int) srcOff, dop = (int) dstOff;
        if (src instanceof Bytes) {
            Bytes s = (Bytes) src;
            for (int i = 0; i < n; i++) d.data[dop + i] = Long.valueOf(s.sb.charAt(so + i));
        } else {
            String s = (String) src;
            for (int i = 0; i < n; i++) d.data[dop + i] = Long.valueOf(s.charAt(so + i));
        }
        return 0;
    }

    /** [caml_blit_bigstring_to_string src srcOff dst dstOff len]
     *  (despite the name the destination is a [Bytes.t] —
     *  cstruct's signature has it as such). */
    public static long caml_blit_bigstring_to_string(
            Object src, long srcOff, Object dst, long dstOff, long len) {
        BigArray s = (BigArray) src;
        Bytes d = (Bytes) dst;
        int n = (int) len, so = (int) srcOff, dop = (int) dstOff;
        for (int i = 0; i < n; i++) {
            d.sb.setCharAt(dop + i, (char) (Block.asLong(s.data[so + i]) & 0xFF));
        }
        return 0;
    }
}
