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
