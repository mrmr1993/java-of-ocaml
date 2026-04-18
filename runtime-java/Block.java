// OCaml heap block: a tag plus an Object[] for the fields.
//
// Variants, tuples, records, cons cells, array-like values — anything
// MAKEBLOCK produces — flow through this class. [tag] distinguishes
// variant constructors (0 for default, subsequent integers for the
// other data-carrying cases); [fields] carries the payload, one entry
// per constructor argument / record field / tuple component.
public final class Block {
    public final int tag;
    public final Object[] fields;

    public Block(int tag, Object[] fields) {
        this.tag = tag;
        this.fields = fields;
    }
}
