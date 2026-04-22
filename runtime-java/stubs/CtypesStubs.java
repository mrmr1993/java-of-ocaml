/**
 * Ctypes long-double arithmetic + complex-number stubs. OCaml
 * [ldouble] and [ldouble_complex] are approximated as Java
 * [double] and a 2-field Block [{re: Double, im: Double}]
 * respectively. Precision is limited to [double]'s 52-bit
 * mantissa — correct enough for init-time constants, but loses
 * bits on real 80-bit [long double] inputs.
 *
 * Also hosts the init no-ops that run when OCaml's ctypes /
 * integers libraries load.
 */
public final class CtypesStubs {
    private CtypesStubs() {}

    // ---- inits (unit return, unit arg) ----
    public static long ldouble_init(Object ignore) { return 0; }
    public static long ldouble_complex_init(Object ignore) { return 0; }
    public static long integers_unsigned_init(Object ignore) { return 0; }

    // ---- constants (unit -> t) ----
    public static double ldouble_min(Object ignore)     { return -Double.MAX_VALUE; }
    public static double ldouble_max(Object ignore)     { return Double.MAX_VALUE; }
    public static double ldouble_epsilon(Object ignore) { return Math.ulp(1.0); }
    public static double ldouble_nan(Object ignore)     { return Double.NaN; }
    public static double ldouble_inf(Object ignore)     { return Double.POSITIVE_INFINITY; }
    public static double ldouble_ninf(Object ignore)    { return Double.NEGATIVE_INFINITY; }
    public static double ldouble_pi(Object ignore)      { return Math.PI; }
    public static double ldouble_e(Object ignore)       { return Math.E; }
    public static double ldouble_euler(Object ignore)   { return 0.5772156649015329; }
    public static long   ldouble_mant_dig(Object ignore){ return 53; }
    public static long   ldouble_size(Object ignore)    { return 8; }

    // ---- unary / conversions ----
    public static double ldouble_of_float(double v) { return v; }
    public static double ldouble_to_float(double v) { return v; }
    public static double ldouble_of_int(long v)     { return (double) v; }
    public static long   ldouble_to_int(double v)   { return (long) v; }
    public static double ldouble_neg(double v)      { return -v; }

    // ---- binary arithmetic ----
    public static double ldouble_add(double a, double b) { return a + b; }
    public static double ldouble_sub(double a, double b) { return a - b; }
    public static double ldouble_mul(double a, double b) { return a * b; }
    public static double ldouble_div(double a, double b) { return a / b; }

    // ---- complex: 1-arg, returns Block {0.0, 0.0} ----
    // The stubs ignore their inputs; enough to satisfy structural
    // init-time usage (shape / dispatch). A real implementation can
    // replace any one entry without touching the manifest.
    public static Block ldouble_complex_1(Object a) {
        return new Block(0, new Object[] {
            Double.valueOf(0.0), Double.valueOf(0.0)
        });
    }

    // ---- complex: 2-arg, returns Block ----
    public static Block ldouble_complex_2(Object a, Object b) {
        return new Block(0, new Object[] {
            Double.valueOf(0.0), Double.valueOf(0.0)
        });
    }

    // ---- complex: 1-arg, returns double (abs, arg, norm, real, imag) ----
    public static double ldouble_complex_to_double_1(Object a) { return 0.0; }
}
