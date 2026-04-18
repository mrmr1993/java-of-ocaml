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

        // Integer first — most common, fast path.
        if (a instanceof Integer && b instanceof Integer) {
            return Integer.compare((Integer) a, (Integer) b);
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
        if (o instanceof Integer) return 0;
        if (o instanceof Double) return 1;
        if (o instanceof String) return 2;
        if (o instanceof Block) return 3;
        if (o instanceof Closure) return 4;
        return 5;
    }

    public static int equal(Object a, Object b) {
        if (a == b) return 1;
        if (a == null || b == null) return 0;
        if (a instanceof Integer && b instanceof Integer) {
            return a.equals(b) ? 1 : 0;
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
