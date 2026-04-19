// OCaml heap block: a tag plus an Object[] for the fields.
//
// Variants, tuples, records, cons cells, array-like values — anything
// MAKEBLOCK produces — flow through this class. [tag] distinguishes
// variant constructors (0 for default, subsequent integers for the
// other data-carrying cases); [fields] carries the payload, one entry
// per constructor argument / record field / tuple component.
// Not [final] — [Ephemeron] subclasses it so [Obj.size] /
// [Obj.field] traversals via [checkcast Block] succeed on
// [caml_ephe_*]-produced values.
public class Block {
    // [tag] is mutable to support Lazy's state transitions:
    // caml_lazy_update_to_forcing flips the tag from [lazy_tag=246]
    // to [forcing_tag=244]; caml_lazy_update_to_forward rewrites to
    // [forward_tag=250] after evaluation; caml_lazy_reset_to_lazy
    // restores [lazy_tag] on exceptional failure. Outside the lazy
    // state machine the tag never changes.
    public int tag;
    public final Object[] fields;

    public Block(int tag, Object[] fields) {
        this.tag = tag;
        this.fields = fields;
    }

    // Widen any boxed-number representation (Integer from
    // Int32/Nativeint/small-Int64 globals, or Long from
    // Int64 operations) to a primitive long. Centralised here so
    // every Int64 / Nativeint unbox path uses the same loose
    // contract; the two OCaml types marshal into the same
    // custom-tag block shape and the bytecode data section
    // materialises them uniformly — so constants boxed as Integer
    // (to match Int32 / old behaviour) need to flow into long-typed
    // operations without a ClassCastException.
    public static long asLong(Object o) {
        if (o instanceof Long) return ((Long) o).longValue();
        if (o instanceof Integer) return ((Integer) o).intValue();
        if (o instanceof Number) return ((Number) o).longValue();
        // Unknown; mirror Long.longValue() on a mis-cast.
        return ((Long) o).longValue();
    }

    // caml_array_concat helper. OCaml-level [list_of_arrays] is a
    // cons-chain whose head is a Block (the next array to concat)
    // and tail is the rest — Nil = Val_int 0 = Integer(0) (or null).
    public static Block concatList(Object list) {
        int total = 0;
        Object node = list;
        while (node instanceof Block) {
            Block cons = (Block) node;
            Block head = (Block) cons.fields[0];
            total += head.fields.length;
            node = cons.fields[1];
        }
        Object[] out = new Object[total];
        int off = 0;
        node = list;
        while (node instanceof Block) {
            Block cons = (Block) node;
            Block head = (Block) cons.fields[0];
            System.arraycopy(head.fields, 0, out, off, head.fields.length);
            off += head.fields.length;
            node = cons.fields[1];
        }
        return new Block(0, out);
    }

    // Float-array allocation helpers — Block(0, Object[]) holding
    // boxed Doubles.
    public static Block createFloat(int n) {
        Object[] arr = new Object[Math.max(0, n)];
        Double z = Double.valueOf(0.0);
        for (int i = 0; i < arr.length; i++) arr[i] = z;
        return new Block(0, arr);
    }

    public static Block createFloatInit(int n, Object init) {
        Object[] arr = new Object[Math.max(0, n)];
        for (int i = 0; i < arr.length; i++) arr[i] = init;
        return new Block(0, arr);
    }

    // Shallow copy: fresh Block with the same tag and a copy of the
    // fields array. Used by caml_obj_dup / caml_array_dup /
    // caml_update_dummy patterns.
    public Block dup() {
        Object[] copy = new Object[this.fields.length];
        System.arraycopy(this.fields, 0, copy, 0, this.fields.length);
        return new Block(this.tag, copy);
    }
}
