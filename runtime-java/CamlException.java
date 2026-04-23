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
        // Diagnostic: when JAVA_OF_OCAML_TRACE_RAISE is set, print a
        // JVM stack trace at the raise site. Useful for debugging
        // mysterious "Uncaught exception: ..." output from OCaml's
        // top-level handler (which doesn't carry a Java trace).
        if (System.getenv("JAVA_OF_OCAML_TRACE_RAISE") != null) {
            System.err.println("[caml-raise] " + getMessage());
            new RuntimeException("raise site").printStackTrace(System.err);
        }
    }

    /**
     * Suppress JVM stack-trace capture by default. OCaml exceptions
     * carry their own backtrace (via Printexc) — the JVM trace is
     * useless overhead, and [Throwable.fillInStackTrace] dominates
     * profile when OCaml uses exceptions for control flow (e.g.
     * [List.find / Hashtbl.find] raising [Not_found] in a tight
     * loop). Re-enable for diagnostic builds via
     * JAVA_OF_OCAML_TRACE_RAISE — that path explicitly constructs
     * a [RuntimeException] for the trace.
     */
    @Override
    public Throwable fillInStackTrace() { return this; }

    @Override
    public String getMessage() {
        return describe(value);
    }

    private static String describe(Object v) {
        return fmt(v, 3);
    }

    private static String fmt(Object v, int depth) {
        if (v == null) return "null";
        if (v instanceof Block) {
            Block b = (Block) v;
            // An OCaml exception value is a [Block(tag=0, [id; args...])]
            // where [id] is a [Block(tag=248, ["Name"; int])]. Detect
            // that shape and print "Name(args...)"; other blocks fall
            // through to the generic "Block(tag=N)(field0, field1, ...)"
            // path that includes every field (including field 0).
            String ctor = null;
            int firstArg = 0;
            if (b.fields != null && b.fields.length > 0 && b.fields[0] instanceof Block) {
                Block hdr = (Block) b.fields[0];
                if (hdr.tag == 248 && hdr.fields != null
                    && hdr.fields.length > 0 && hdr.fields[0] instanceof String) {
                    ctor = (String) hdr.fields[0];
                    firstArg = 1;
                }
            }
            StringBuilder sb = new StringBuilder();
            sb.append(ctor == null ? ("Block(tag=" + b.tag + ")") : ctor);
            if (b.fields != null && b.fields.length > firstArg) {
                sb.append("(");
                for (int i = firstArg; i < b.fields.length; i++) {
                    if (i > firstArg) sb.append(", ");
                    Object f = b.fields[i];
                    if (depth > 0)
                        sb.append(fmt(f, depth - 1));
                    else if (f == null) sb.append("null");
                    else if (f instanceof Block) sb.append("Block@").append(Integer.toHexString(System.identityHashCode(f)));
                    else sb.append(f);
                }
                sb.append(")");
            }
            return sb.toString();
        }
        if (v instanceof String) return "\"" + ((String)v).replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
        return v.toString();
    }
}
