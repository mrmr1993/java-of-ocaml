/**
 * Long-double complex stubs from [ctypes]' [src/ctypes/complexL.ml]
 * ([ComplexL] module). Represented as a 2-field [Block] of
 * [Double] for the real and imaginary parts. All operators here
 * are placeholders returning [{re=0.0, im=0.0}] regardless of
 * input — upgrade to real arithmetic in the consistency pass.
 *
 * OCaml shapes of the upstream externals:
 *   - Unary:   [t -> t] or [t -> LDouble.t]
 *   - Binary:  [t -> t -> t]
 *   - [make]:  [LDouble.t -> LDouble.t -> t]
 *   - [re]/[im]/[arg]: [t -> LDouble.t]
 */
public final class ComplexL {
    private ComplexL() {}

    /** library init — unit return. */
    public static long init(Object ignore) { return 0; }

    /**
     * 1-arg complex → complex (placeholder zero). Covers upstream
     * [neg], [conj], [exp], [log], [sqrt], [inv], …
     */
    public static Block complex_1(Object a) {
        return new Block(0, new Object[] {
            Double.valueOf(0.0), Double.valueOf(0.0)
        });
    }

    /**
     * 2-arg complex × complex → complex (placeholder zero).
     * Covers [make], [add], [sub], [mul], [div], [pow], [polar].
     */
    public static Block complex_2(Object a, Object b) {
        return new Block(0, new Object[] {
            Double.valueOf(0.0), Double.valueOf(0.0)
        });
    }

    /**
     * 1-arg complex → [LDouble] (double). Covers [re], [im],
     * [abs], [arg], [norm].
     */
    public static double to_double_1(Object a) { return 0.0; }
}
