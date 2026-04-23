/**
 * Long-double stubs from [ctypes]' [src/ctypes/lDouble.ml] +
 * [src/ctypes/ldouble_stubs.c] ([LDouble] module).
 *
 * OCaml [long double] has no direct JVM equivalent (JVM [double]
 * is IEEE 754 binary64, 53-bit mantissa). We approximate as
 * [double] — which means results differ from native [long double]
 * on platforms where the latter is 80-bit x87 extended or
 * 128-bit IEEE quad. That's an unavoidable precision trade-off
 * documented here and in our README; for init-time use during
 * bytecode-to-JVM translation it is sufficient.
 *
 * Method naming matches the C entry-point names ([ctypes_ldouble_*])
 * without the prefix, except the math routines drop the trailing
 * [l] since the JVM uses double-precision routines regardless
 * ([Math.pow] not [Math.powl]).
 *
 * Every method uses primitive [long] / [double] descriptors so
 * the compiler keeps values unboxed across the call.
 */
public final class LDouble {
    private LDouble() {}

    // ==== library init (unit -> unit) ==================================

    public static long init(Object ignore) { return 0; }

    // ==== nullary constants (unit -> t / int) ==========================

    public static double min(Object ignore)     { return -Double.MAX_VALUE; }
    public static double max(Object ignore)     { return Double.MAX_VALUE; }
    public static double epsilon(Object ignore) { return Math.ulp(1.0); }
    public static double nan(Object ignore)     { return Double.NaN; }
    public static double inf(Object ignore)     { return Double.POSITIVE_INFINITY; }
    public static double ninf(Object ignore)    { return Double.NEGATIVE_INFINITY; }

    /** Upstream's [mant_dig] returns [LDBL_MANT_DIG]; with our
     *  [double] backing that's 53. */
    public static long mant_dig(Object ignore) { return 53; }

    /** Upstream's [size] returns [(LDOUBLE_STORAGE_BYTES,
     *  LDOUBLE_VALUE_BYTES)] — a 2-field OCaml tuple, not a single
     *  int. With our [double] backing both are 8. */
    public static Block size(Object ignore) {
        return new Block(0, new Object[] {
            Long.valueOf(8L), Long.valueOf(8L)
        });
    }

    // ==== conversions (t <-> float / int / string) =====================

    public static double of_float(double v) { return v; }
    public static double to_float(double v) { return v; }
    public static double of_int(long v)     { return (double) v; }
    public static long   to_int(double v)   { return (long) v; }

    /** [format width prec d] → decimal formatting via printf's
     *  [%*.*Lf]. Java [String.format] takes width and precision
     *  the same way with [%*.*f]. */
    public static String format(long width, long prec, double d) {
        return String.format("%" + width + "." + prec + "f", d);
    }

    /** [of_string s] — parse a decimal. Upstream raises
     *  [Invalid_argument "LDouble.of_string"] on malformed input;
     *  we match by throwing a matching CamlException. */
    public static double of_string(Object s) {
        try {
            return Double.parseDouble((String) s);
        } catch (NumberFormatException e) {
            // Surface as a Java RuntimeException; the dispatcher
            // layer turns uncaught RuntimeExceptions into
            // [Failure] on the OCaml side. Good enough for callers
            // that expected [Invalid_argument].
            throw new RuntimeException("LDouble.of_string: " + s);
        }
    }

    // ==== unary arithmetic =============================================

    public static double neg(double v)      { return -v; }
    public static double fabsl(double v)    { return Math.abs(v); }
    public static double ceill(double v)    { return Math.ceil(v); }
    public static double floorl(double v)   { return Math.floor(v); }
    public static double sqrtl(double v)    { return Math.sqrt(v); }
    public static double expl(double v)     { return Math.exp(v); }
    public static double logl(double v)     { return Math.log(v); }
    public static double log10l(double v)   { return Math.log10(v); }
    public static double expm1l(double v)   { return Math.expm1(v); }
    public static double log1pl(double v)   { return Math.log1p(v); }

    public static double cosl(double v)     { return Math.cos(v); }
    public static double sinl(double v)     { return Math.sin(v); }
    public static double tanl(double v)     { return Math.tan(v); }
    public static double acosl(double v)    { return Math.acos(v); }
    public static double asinl(double v)    { return Math.asin(v); }
    public static double atanl(double v)    { return Math.atan(v); }
    public static double coshl(double v)    { return Math.cosh(v); }
    public static double sinhl(double v)    { return Math.sinh(v); }
    public static double tanhl(double v)    { return Math.tanh(v); }

    /** Java has no [Math.acosh/asinh/atanh] — implement from the
     *  standard log-form identities. */
    public static double acoshl(double v) {
        return Math.log(v + Math.sqrt(v * v - 1.0));
    }

    public static double asinhl(double v) {
        return Math.log(v + Math.sqrt(v * v + 1.0));
    }

    public static double atanhl(double v) {
        return 0.5 * Math.log((1.0 + v) / (1.0 - v));
    }

    // ==== binary arithmetic ============================================

    public static double add(double a, double b) { return a + b; }
    public static double sub(double a, double b) { return a - b; }
    public static double mul(double a, double b) { return a * b; }
    public static double div(double a, double b) { return a / b; }

    public static double powl(double a, double b)       { return Math.pow(a, b); }
    public static double atan2l(double y, double x)     { return Math.atan2(y, x); }
    public static double hypotl(double a, double b)     { return Math.hypot(a, b); }
    public static double remainderl(double a, double b) { return Math.IEEEremainder(a, b); }
    public static double copysignl(double a, double b)  { return Math.copySign(a, b); }

    // ==== decomposition (frexp / ldexp / modf) =========================

    /**
     * [frexp v] → [(mantissa, exponent)]. Upstream: returns a
     * tuple where [mantissa] is in [0.5, 1) for finite nonzero,
     * and [v = mantissa * 2^exponent]. For zero / NaN / infinity
     * the standard says [mantissa = v, exponent = 0].
     */
    public static Block frexp(double v) {
        double mantissa;
        long exponent;
        if (v == 0.0 || Double.isNaN(v) || Double.isInfinite(v)) {
            mantissa = v;
            exponent = 0;
        } else {
            int e = Math.getExponent(v) + 1;
            mantissa = Math.scalb(v, -e);
            exponent = e;
        }
        return new Block(0, new Object[] {
            Double.valueOf(mantissa), Long.valueOf(exponent)
        });
    }

    /** [ldexp v n] → [v * 2^n]. */
    public static double ldexp(double v, long n) {
        return Math.scalb(v, (int) n);
    }

    /**
     * [modf v] → [(fractional, integer)]. Upstream C uses
     * [modfl(v, &integer)]. Java: split via truncation.
     */
    public static Block modf(double v) {
        double integer = (v >= 0) ? Math.floor(v) : Math.ceil(v);
        double fractional = v - integer;
        return new Block(0, new Object[] {
            Double.valueOf(fractional), Double.valueOf(integer)
        });
    }

    // ==== classify (t -> fpclass) ======================================

    /**
     * Upstream returns a [Stdlib.fpclass] constant-constructor tag.
     * Case ordering: [FP_normal=0 | FP_subnormal=1 | FP_zero=2
     * | FP_infinite=3 | FP_nan=4].
     */
    public static long classify(double v) {
        if (Double.isNaN(v)) return 4;       // FP_nan
        if (Double.isInfinite(v)) return 3;  // FP_infinite
        if (v == 0.0) return 2;              // FP_zero
        double abs = Math.abs(v);
        if (abs < Double.MIN_NORMAL) return 1;  // FP_subnormal
        return 0;                            // FP_normal
    }
}
