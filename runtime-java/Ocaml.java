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

    // -------- sentinels --------

    public static final Object unit = Long.valueOf(0L);
    public static final Object none = Long.valueOf(0L);
    public static final Object emptyList = Long.valueOf(0L);
    public static final Object bool_false = Long.valueOf(0L);
    public static final Object bool_true = Long.valueOf(1L);
}
