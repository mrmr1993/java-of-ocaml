// JVM exception carrier for OCaml [raise] / [try ... with].
//
// OCaml raises an OCaml value; at the JVM level we wrap that value in
// a [CamlException] and throw it. The exception-handler prelude
// emitted at each [PUSHTRAP] unwraps [value] and hands it back as the
// OCaml-level exception argument.
public final class CamlException extends RuntimeException {
    public final Object value;

    public CamlException(Object value) {
        super();
        this.value = value;
    }

    @Override
    public String getMessage() {
        return describe(value);
    }

    private static String describe(Object v) {
        if (v == null) return "null";
        if (v instanceof Block) {
            Block b = (Block) v;
            StringBuilder sb = new StringBuilder();
            String ctor = null;
            if (b.fields != null && b.fields.length > 0 && b.fields[0] instanceof Block) {
                Block hdr = (Block) b.fields[0];
                if (hdr.fields != null && hdr.fields.length > 0
                    && hdr.fields[0] instanceof String) {
                    ctor = (String) hdr.fields[0];
                }
            }
            sb.append(ctor == null ? ("Block(tag=" + b.tag + ")") : ctor);
            if (b.fields != null && b.fields.length > 1) {
                sb.append("(");
                for (int i = 1; i < b.fields.length; i++) {
                    if (i > 1) sb.append(", ");
                    Object f = b.fields[i];
                    sb.append(f == null ? "null" : f.toString());
                }
                sb.append(")");
            }
            return sb.toString();
        }
        return v.toString();
    }
}
