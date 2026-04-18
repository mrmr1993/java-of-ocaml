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
}
