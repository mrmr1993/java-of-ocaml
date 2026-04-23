// Polymorphic structural comparison, matching OCaml's Stdlib.compare
// semantics on the value shapes java_of_ocaml emits:
//
//   - Integer (tagged int / immediate)
//   - Double  (boxed float)
//   - String  (OCaml string)
//   - Block   (tag + Object[])
//   - Closure (function; comparison is "functional value" error in OCaml)
//
// Returns negative / zero / positive from compare; boolean from the
// helpers. Wired via caml_compare / caml_equal / ... in prim.ml.
//
// Not a perfect spec match: NaN ordering follows OCaml's
// "partial_order then treats NaN as distinct" convention only
// approximately, and custom_tag / infix_tag / floatarray aren't
// modelled (our runtime doesn't produce them yet).
public final class Compare {
    private Compare() {}

    public static int compare(Object a, Object b) {
        if (a == b) return 0;
        if (a == null) return -1;
        if (b == null) return 1;

        // Integral: OCaml [int] is now JVM [Long]; [Integer] still
        // appears for Int32 / small-int globals pre-widening. Compare
        // numerically across the two.
        if ((a instanceof Long || a instanceof Integer)
            && (b instanceof Long || b instanceof Integer)) {
            return Long.compare(((Number) a).longValue(), ((Number) b).longValue());
        }
        if (a instanceof Double && b instanceof Double) {
            return Double.compare((Double) a, (Double) b);
        }
        if (a instanceof String && b instanceof String) {
            return ((String) a).compareTo((String) b);
        }
        if (a instanceof Block && b instanceof Block) {
            return compareBlock((Block) a, (Block) b);
        }

        // Mixed kinds: OCaml orders as int < float < string < block.
        return typeRank(a) - typeRank(b);
    }

    private static int compareBlock(Block a, Block b) {
        int tagCmp = Integer.compare(a.tag, b.tag);
        if (tagCmp != 0) return tagCmp;
        int len = Math.min(a.fields.length, b.fields.length);
        for (int i = 0; i < len; i++) {
            int c = compare(a.fields[i], b.fields[i]);
            if (c != 0) return c;
        }
        return Integer.compare(a.fields.length, b.fields.length);
    }

    private static int typeRank(Object o) {
        // Integer and Long both carry integral values in our runtime
        // (plain OCaml [int] is boxed [Integer]; [Int64]/[Nativeint]
        // are boxed [Long]). They sort together under OCaml's
        // ordering: a comparison between, say, an [int] and an
        // [Int64] via polymorphic [compare] is a type error in
        // well-typed OCaml, so ordering them consistently here is
        // fine as long as equal values compare equal.
        if (o instanceof Integer || o instanceof Long) return 0;
        if (o instanceof Double) return 1;
        if (o instanceof String) return 2;
        if (o instanceof Block) return 3;
        if (o instanceof Closure) return 4;
        return 5;
    }

    /**
     * Polymorphic hash matching our [equal]: two structurally-equal
     * values produce the same int. HashMap-keyed data structures
     * (e.g. OCaml [Hashtbl]) depend on the [hash]/[equal] contract
     * — before this method existed, [caml_hash] used identity
     * hashing on [Block] instances while [caml_equal] was
     * structural, so freshly-constructed [Process_in ic] blocks
     * missed in [Hashtbl.find popen_processes] even though an
     * earlier-added block with the same [ic] was present.
     *
     * The hash follows OCaml's [Hashtbl.hash] spirit: recurse on
     * Block fields and mix via [31 * acc + field_hash], depth-
     * bounded to keep cycles (Ephemeron / recursive records)
     * from blowing the stack. Primitive values use [hashCode]
     * directly; closures fall back to identity hash (OCaml
     * considers functional values hash-incomparable, we just
     * need consistency with [equal]'s identity check for them).
     */
    public static int hash(Object o) {
        return hashDepth(o, 10);
    }

    private static int hashDepth(Object o, int depth) {
        if (o == null) return 0;
        if (o instanceof Long) {
            long v = ((Long) o).longValue();
            return (int) (v ^ (v >>> 32));
        }
        if (o instanceof Integer) return ((Integer) o).intValue();
        if (o instanceof Double) return ((Double) o).hashCode();
        if (o instanceof String) return ((String) o).hashCode();
        if (o instanceof Block) {
            Block b = (Block) o;
            int h = b.tag;
            if (depth <= 0) return h;   // cap recursion
            int n = Math.min(b.fields.length, 8); // cap per-block fan-out
            for (int i = 0; i < n; i++) {
                h = 31 * h + hashDepth(b.fields[i], depth - 1);
            }
            return h;
        }
        // Closures / arbitrary refs: identity hash. OCaml [Hashtbl]
        // rarely keys on functional values; consistency with
        // equal's identity check is what matters here.
        return System.identityHashCode(o);
    }

    public static int equal(Object a, Object b) {
        if (a == b) return 1;
        if (a == null || b == null) return 0;
        if ((a instanceof Long || a instanceof Integer)
            && (b instanceof Long || b instanceof Integer)) {
            return ((Number) a).longValue() == ((Number) b).longValue() ? 1 : 0;
        }
        if (a instanceof Double && b instanceof Double) {
            return ((double) (Double) a == (double) (Double) b) ? 1 : 0;
        }
        if (a instanceof String && b instanceof String) {
            return a.equals(b) ? 1 : 0;
        }
        if (a instanceof Block && b instanceof Block) {
            return (compareBlock((Block) a, (Block) b) == 0) ? 1 : 0;
        }
        return 0;
    }

    public static int notequal(Object a, Object b) { return 1 - equal(a, b); }

    public static int lessthan(Object a, Object b) {
        return compare(a, b) < 0 ? 1 : 0;
    }

    public static int lessequal(Object a, Object b) {
        return compare(a, b) <= 0 ? 1 : 0;
    }

    public static int greaterthan(Object a, Object b) {
        return compare(a, b) > 0 ? 1 : 0;
    }

    public static int greaterequal(Object a, Object b) {
        return compare(a, b) >= 0 ? 1 : 0;
    }
}
