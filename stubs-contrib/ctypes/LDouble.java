/**
 * Long-double stubs from [ctypes]' [src/ctypes/lDouble.ml] ([LDouble]
 * module). OCaml [long double] has no direct JVM equivalent, so
 * everything is approximated as [double] — which loses precision
 * beyond 53 bits of mantissa. Correct enough for init-time
 * constants; a real workload doing precision-critical long-double
 * math would need a BigDecimal-backed replacement.
 *
 * Every method uses primitive [long] / [double] descriptors so the
 * compiler keeps values unboxed across the call.
 */
public final class LDouble {
    private LDouble() {}

    // ---- library init (unit return) ----
    public static long init(Object ignore) { return 0; }

    // ---- numeric constants ----
    public static double min(Object ignore)     { return -Double.MAX_VALUE; }
    public static double max(Object ignore)     { return Double.MAX_VALUE; }
    public static double epsilon(Object ignore) { return Math.ulp(1.0); }
    public static double nan(Object ignore)     { return Double.NaN; }
    public static double inf(Object ignore)     { return Double.POSITIVE_INFINITY; }
    public static double ninf(Object ignore)    { return Double.NEGATIVE_INFINITY; }
    public static double pi(Object ignore)      { return Math.PI; }
    public static double e(Object ignore)       { return Math.E; }
    public static double euler(Object ignore)   { return 0.5772156649015329; }
    public static long   mant_dig(Object ignore){ return 53; }
    public static long   size(Object ignore)    { return 8; }

    // ---- unary / conversions ----
    public static double of_float(double v) { return v; }
    public static double to_float(double v) { return v; }
    public static double of_int(long v)     { return (double) v; }
    public static long   to_int(double v)   { return (long) v; }
    public static double neg(double v)      { return -v; }

    // ---- binary arithmetic ----
    public static double add(double a, double b) { return a + b; }
    public static double sub(double a, double b) { return a - b; }
    public static double mul(double a, double b) { return a * b; }
    public static double div(double a, double b) { return a / b; }
}
