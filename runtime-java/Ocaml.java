/**
 * Helper library for Java-authored OCaml C-primitive stubs. Import
 * these statically (or use full paths) to keep stub bodies short —
 * unboxing, boxing, block construction, and OCaml-shaped exceptions.
 *
 * The conventions mirror the rest of the runtime:
 *   OCaml int   ↔ java.lang.Long       (64-bit, via Block.asLong)
 *   OCaml float ↔ java.lang.Double
 *   OCaml string↔ java.lang.String
 *   block       ↔ Block (tag + Object[] fields)
 *   unit / None / [] / false ↔ Long(0)
 */
public final class Ocaml {
    private Ocaml() {}

    // -------- unbox --------

    public static long asLong(Object o) { return Block.asLong(o); }

    public static int asInt(Object o) { return (int) Block.asLong(o); }

    public static double asDouble(Object o) {
        return ((Double) o).doubleValue();
    }

    public static String asString(Object o) { return (String) o; }

    public static Block asBlock(Object o) { return (Block) o; }

    // -------- box --------

    public static Long box(long v) { return Long.valueOf(v); }
    public static Double box(double v) { return Double.valueOf(v); }

    // -------- build --------

    public static Block block(int tag, Object... fields) {
        return new Block(tag, fields);
    }

    public static Block emptyBlock(int tag) {
        return new Block(tag, new Object[0]);
    }

    public static Block some(Object v) {
        return new Block(0, new Object[] { v });
    }

    /** Integer array packaged as a Block tag 0 of boxed Longs. */
    public static Block intArray(long... xs) {
        Object[] fields = new Object[xs.length];
        for (int i = 0; i < xs.length; i++) fields[i] = Long.valueOf(xs[i]);
        return new Block(0, fields);
    }

    // -------- truthy test for OCaml conditionals --------

    /**
     * OCaml's `if` treats only `false` (== int 0) as falsy. Everything
     * else — non-zero ints, blocks, closures, strings, doubles — is
     * truthy.
     *
     * Our previous Cond K_obj emission assumed the scrutinee was
     * either a [Block] or a boxed int. If it got a [Closure] (which
     * is a reference but not a [Block] in our runtime — [Closure]
     * doesn't extend [Block]), the generated code fell through to
     * [Block.asLong] on the closure and ClassCastException'd.
     * Route through [isTruthy] for mixed-kind scrutinees so every
     * concrete runtime value decodes correctly.
     */
    public static int isTruthy(Object o) {
        if (o instanceof Long) return ((Long) o).longValue() != 0 ? 1 : 0;
        if (o instanceof Integer) return ((Integer) o).intValue() != 0 ? 1 : 0;
        // Block / Closure / String / Double / BigArray / Bytes / etc. —
        // all non-zero-int → truthy.
        return 1;
    }

    // -------- OO dispatch --------

    /**
     * Look up a method closure on an OCaml object by its hash tag.
     * Mirrors [caml_get_public_method] in OCaml's [runtime/obj.c]:
     *
     *   meths = obj.fields[0]                 // method-table Block
     *   li = 3, hi = meths.fields[0]          // search window
     *   while li < hi:
     *     mi = ((li+hi) >> 1) | 1             // guarantee odd mi
     *     if tag < meths.fields[mi]: hi = mi-2
     *     else:                       li = mi
     *   return meths.fields[li-1]
     *
     * Method tables store alternating (method, tag) pairs starting
     * at index 2, sorted by tag. The `| 1` keeps [mi] pointing at
     * a tag slot; [li-1] is then the matching method slot.
     *
     * Upstream's interp.c carries an inline cache (a PC-local field
     * mutated on hit). We skip it — correctness doesn't depend on
     * it, and a profiler can flag the extra binary search later.
     */
    public static Object getPublicMethod(Object obj, long tag) {
        Block o = (Block) obj;
        Block meths = (Block) o.fields[0];
        // Upstream's [Field(meths,0)] reads [len] as an OCaml-tagged
        // integer: physically `(len << 1) | 1`. Our runtime stores
        // OCaml ints as plain [Long]s (no tag bit), so we
        // reconstruct the tagged form to match the algorithm's
        // bounds expectations — otherwise the binary search
        // collapses for any class with more than one public method.
        long len = Block.asLong(meths.fields[0]);
        int hi = (int) ((len << 1) | 1);
        int li = 3;
        while (li < hi) {
            int mi = ((li + hi) >> 1) | 1;
            long t = Block.asLong(meths.fields[mi]);
            if (tag < t) hi = mi - 2;
            else li = mi;
        }
        return meths.fields[li - 1];
    }

    // -------- predefined exception identifiers --------

    /** OCaml's predefined [Failure] exception identifier (a tag-248
     *  Block stored at [GLOBALS[2]] after globals init). The compiler
     *  wires this field once globals are populated. Used by
     *  [raiseFailure] and by the auto-generated "primitive not
     *  implemented" stubs so OCaml's [try ... with _] / [with Failure _]
     *  catches them. Stays [null] until globals init runs (i.e. for
     *  programs that don't link Stdlib's predefined exceptions);
     *  [raiseFailure] falls back to a fresh fabricated identifier in
     *  that case so it still throws something OCaml-shaped. */
    public static Object failureExn;

    /** Throw a [CamlException] wrapping [Failure msg]. The shape is
     *  [Block(0, [failureExn, msg])] so OCaml's [try ... with Failure _]
     *  matches by reference identity on field 0. */
    public static RuntimeException raiseFailure(String msg) {
        Object id = failureExn;
        if (id == null) {
            // Pre-globals-init or no Stdlib linked: fabricate a
            // descriptor so we still throw a CamlException.
            id = new Block(248, new Object[] { "Failure", Long.valueOf(-1L) });
        }
        throw new CamlException(new Block(0, new Object[] { id, msg }));
    }

    // -------- sentinels --------

    public static final Object unit = Long.valueOf(0L);
    public static final Object none = Long.valueOf(0L);
    public static final Object emptyList = Long.valueOf(0L);
    public static final Object bool_false = Long.valueOf(0L);
    public static final Object bool_true = Long.valueOf(1L);
}
