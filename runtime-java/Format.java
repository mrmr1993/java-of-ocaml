// OCaml runtime-format helpers.
//
// [caml_format_int] and [caml_format_float] take an OCaml format spec
// (e.g. "%d", "%5x", "%.3f", "%-8s") and render an int or a double.
// Rather than parse every corner of the grammar, we translate to the
// closest-matching Java [String.format] spec. That covers the usual
// Printf.printf output cleanly; obscure combinations (sign flags,
// locale variants, the "#" alternate form, etc.) may differ from
// OCaml's exact output but won't crash.
public class Format {
    public static String formatInt(String fmt, int n) {
        return String.format(normalize(fmt, false), n);
    }

    public static String formatFloat(String fmt, double d) {
        return String.format(normalize(fmt, true), d);
    }

    // Float math helpers that java.lang.Math doesn't provide in older
    // JVMs — implement them via well-known identities.
    public static double asinh(double x) {
        // asinh(x) = ln(x + sqrt(x*x + 1))
        return Math.log(x + Math.sqrt(x * x + 1));
    }
    public static double acosh(double x) {
        // acosh(x) = ln(x + sqrt(x*x - 1)), x >= 1
        return Math.log(x + Math.sqrt(x * x - 1));
    }
    public static double atanh(double x) {
        // atanh(x) = 0.5 * ln((1+x) / (1-x)), |x| < 1
        return 0.5 * Math.log((1 + x) / (1 - x));
    }
    public static double exp2(double x) {
        return Math.pow(2.0, x);
    }
    // Ordinary error function — use Abramowitz & Stegun's common
    // approximation. Accuracy ~1e-7, which matches what most OCaml
    // code expects from [Float.erf] for plotting / stats.
    public static double erf(double x) {
        double sign = x < 0 ? -1 : 1;
        x = Math.abs(x);
        double t = 1.0 / (1.0 + 0.3275911 * x);
        double y = 1.0 - (((((1.061405429 * t + -1.453152027) * t)
                 + 1.421413741) * t + -0.284496736) * t + 0.254829592) * t * Math.exp(-x * x);
        return sign * y;
    }
    public static double erfc(double x) {
        return 1.0 - erf(x);
    }
    public static double fma(double a, double b, double c) {
        // Math.fma exists on Java 9+. We target older; compute
        // a*b+c directly. Loses the "single-rounding" property of
        // FMA, but callers using fma for that specific guarantee
        // are rare; functional correctness is preserved.
        return a * b + c;
    }
    // [frexp d] → Block{0,[mantissa:double; exponent:int]}.
    public static Block frexp(double d) {
        if (d == 0.0 || Double.isNaN(d) || Double.isInfinite(d)) {
            Object[] fs = { Double.valueOf(d), Integer.valueOf(0) };
            return new Block(0, fs);
        }
        long bits = Double.doubleToRawLongBits(d);
        int exp = (int) ((bits >> 52) & 0x7FF) - 1022;
        long m = (bits & ~(0x7FFL << 52)) | (1022L << 52);
        double mantissa = Double.longBitsToDouble(m);
        Object[] fs = { Double.valueOf(mantissa), Integer.valueOf(exp) };
        return new Block(0, fs);
    }

    // Map OCaml's %i / %ni / %li / %Li etc. onto Java's %d; leave %d /
    // %x / %X / %o / %u / %f / %e / %g / %E / %G untouched; strip
    // OCaml's width-qualifier prefixes (n/l/L) that Java doesn't
    // accept. Falls back to the closest sensible Java spec.
    private static String normalize(String fmt, boolean isFloat) {
        // OCaml uses [%i] for integers; Java uses [%d].
        StringBuilder out = new StringBuilder();
        int i = 0;
        while (i < fmt.length()) {
            char c = fmt.charAt(i);
            if (c == '%') {
                out.append('%');
                i++;
                // flags / width / precision / length-modifier run
                while (i < fmt.length()) {
                    char d = fmt.charAt(i);
                    if (d == 'l' || d == 'L' || d == 'n') {
                        // OCaml's length modifiers — drop, Java doesn't use them.
                        i++;
                    } else if (d == 'i' || d == 'u') {
                        // [%i] and [%u] → Java [%d].
                        out.append('d');
                        i++;
                        break;
                    } else if (d == 'F') {
                        // OCaml [%F] → Java [%f].
                        out.append('f');
                        i++;
                        break;
                    } else {
                        out.append(d);
                        i++;
                        if ("dxXoefgEGsc%".indexOf(d) >= 0) break;
                    }
                }
            } else {
                out.append(c);
                i++;
            }
        }
        return out.toString();
    }
}
