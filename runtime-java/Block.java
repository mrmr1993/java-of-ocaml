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

    // Shallow copy: fresh Block with the same tag and a copy of the
    // fields array. Used by caml_obj_dup / caml_array_dup /
    // caml_update_dummy patterns.
    public Block dup() {
        Object[] copy = new Object[this.fields.length];
        System.arraycopy(this.fields, 0, copy, 0, this.fields.length);
        return new Block(this.tag, copy);
    }
}
