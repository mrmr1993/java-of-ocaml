/**
 * Long-double complex stubs from [ctypes]' [src/ctypes/complexL.ml]
 * + [src/ctypes/ldouble_stubs.c] ([ComplexL] module).
 *
 * A [t] is represented as a 2-field [Block] of [Double]:
 * [{re, im}]. The wrapping code expects this concrete shape from
 * [ctypes_ldouble_complex_make] and [..._real] / [..._imag] read
 * back through it.
 *
 * Precision: same caveat as [LDouble] — we approximate [long
 * double _Complex] as two IEEE binary64, losing bits on platforms
 * where [long double] is 80- or 128-bit. Algorithms below follow
 * the standard complex identities and [libm]'s [csqrtl] / [clogl]
 * / [cexpl] / [cpowl] semantics.
 *
 * Method-naming matches the C entry-point names ([cargl], [cexpl],
 * [conjl], [csqrtl], [clogl], [cpowl]) for functions that use the
 * libm suffix; [make], [real], [imag], [neg], [add], [sub], [mul],
 * [div] keep their plain names.
 */
public final class ComplexL {
    private ComplexL() {}

    // ==== library init (unit -> unit) ==================================

    public static long init(Object ignore) { return 0; }

    // ==== block shape helpers ==========================================

    private static double re(Object z) {
        Block b = (Block) z;
        return ((Double) b.fields[0]).doubleValue();
    }

    private static double im(Object z) {
        Block b = (Block) z;
        return ((Double) b.fields[1]).doubleValue();
    }

    private static Block box(double re, double im) {
        return new Block(0, new Object[] {
            Double.valueOf(re), Double.valueOf(im)
        });
    }

    // ==== construction / projection ====================================

    /** [make r i] — upstream: [make : LDouble.t -> LDouble.t -> t]. */
    public static Block make(double r, double i) { return box(r, i); }

    public static double real(Object z) { return re(z); }
    public static double imag(Object z) { return im(z); }

    // ==== unary ========================================================

    public static Block neg(Object z) {
        return box(-re(z), -im(z));
    }

    /** [conj (a + bi)] = [a - bi]. */
    public static Block conjl(Object z) {
        return box(re(z), -im(z));
    }

    // ==== binary arithmetic ============================================

    public static Block add(Object a, Object b) {
        return box(re(a) + re(b), im(a) + im(b));
    }

    public static Block sub(Object a, Object b) {
        return box(re(a) - re(b), im(a) - im(b));
    }

    /** [(a + bi) * (c + di) = (ac - bd) + (ad + bc)i]. */
    public static Block mul(Object a, Object b) {
        double ar = re(a), ai = im(a), br = re(b), bi = im(b);
        return box(ar * br - ai * bi, ar * bi + ai * br);
    }

    /** [(a + bi) / (c + di) = ((ac + bd) + (bc - ad)i) / (c² + d²)]. */
    public static Block div(Object a, Object b) {
        double ar = re(a), ai = im(a), br = re(b), bi = im(b);
        double denom = br * br + bi * bi;
        return box((ar * br + ai * bi) / denom, (ai * br - ar * bi) / denom);
    }

    // ==== transcendental ==============================================

    /** [cargl z] = [atan2(im, re)]. */
    public static double cargl(Object z) {
        return Math.atan2(im(z), re(z));
    }

    /**
     * Principal complex square root. For [z = a + bi] with
     * modulus [r = |z|]:
     *   [u = sqrt((r + a) / 2)]
     *   [v = sign(b) * sqrt((r - a) / 2)]
     * and [sqrt(z) = u + v·i]. Handles the [b = 0] and [a < 0]
     * branch of the standard principal-branch convention.
     */
    public static Block csqrtl(Object z) {
        double a = re(z), b = im(z);
        if (a == 0.0 && b == 0.0) return box(0.0, 0.0);
        double r = Math.hypot(a, b);
        double u = Math.sqrt((r + a) * 0.5);
        double v = Math.sqrt((r - a) * 0.5);
        if (b < 0) v = -v;
        return box(u, v);
    }

    /** [exp(a + bi)] = [e^a * (cos b + i sin b)]. */
    public static Block cexpl(Object z) {
        double a = re(z), b = im(z);
        double ea = Math.exp(a);
        return box(ea * Math.cos(b), ea * Math.sin(b));
    }

    /** [log z] = [log|z| + i·arg(z)]. */
    public static Block clogl(Object z) {
        double a = re(z), b = im(z);
        return box(Math.log(Math.hypot(a, b)), Math.atan2(b, a));
    }

    /** [z^w] = [exp(w · log z)]. */
    public static Block cpowl(Object a, Object b) {
        // w = b; compute w * log a, then exp.
        double ar = re(a), ai = im(a);
        double logR = Math.log(Math.hypot(ar, ai));
        double logI = Math.atan2(ai, ar);
        // w * log a = (wr * logR - wi * logI) + i (wr * logI + wi * logR)
        double wr = re(b), wi = im(b);
        double pr = wr * logR - wi * logI;
        double pi = wr * logI + wi * logR;
        // exp
        double epr = Math.exp(pr);
        return box(epr * Math.cos(pi), epr * Math.sin(pi));
    }
}
