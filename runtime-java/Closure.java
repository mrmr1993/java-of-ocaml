// Base class for OCaml closures.
//
// Each OCaml function is compiled to a concrete subclass of Closure
// that overrides [arity] and the [tailApplyN] matching its source
// arity (for 1 <= N <= 7) or [applyN] (for 8 <= N <= 16). The direct-
// arity entry-point [applyN] the OCaml compiler picks at the call
// site hits the subclass via virtual dispatch:
//
//   - For N in [1..7], [applyN] is a [final] method in this base
//     class that drives the trampoline. It calls [tailApplyN] (which
//     the subclass overrides) and unwinds any returned [Bounce]
//     sentinel in a [while] loop, so deeply-recursive tail chains
//     run in a single JVM frame rather than consuming a frame per
//     call. A miscall where N != arity() falls through the default
//     [tailApplyN] in this base class to [under], which packages the
//     args into a [PartialClosure] (undersupply) or chunks them
//     (oversupply).
//
//   - For N in [8..16], [applyN] is still virtual (no trampoline —
//     large-arity tail calls are rare enough not to be worth the
//     plumbing). Subclasses override [applyN] directly; the base
//     impl routes to [under] for arity mismatches.
public class Closure {
    public Closure() {
        super();
    }

    // Subclasses override to return the function's declared arity.
    public int arity() {
        return 0;
    }

    // --- Tail-trampolined apply entry points (arities 1..7) ------------
    //
    // Each [applyN] below is [final]: it drives the trampoline loop
    // and routes to the subclass via [tailApplyN]. Subclasses must
    // override [tailApplyN], not [applyN].

    public final Object apply1(Object a1) {
        Object r = tailApply1(a1);
        while (r instanceof Bounce) r = ((Bounce) r).step();
        return r;
    }

    public final Object apply2(Object a1, Object a2) {
        Object r = tailApply2(a1, a2);
        while (r instanceof Bounce) r = ((Bounce) r).step();
        return r;
    }

    public final Object apply3(Object a1, Object a2, Object a3) {
        Object r = tailApply3(a1, a2, a3);
        while (r instanceof Bounce) r = ((Bounce) r).step();
        return r;
    }

    public final Object apply4(Object a1, Object a2, Object a3, Object a4) {
        Object r = tailApply4(a1, a2, a3, a4);
        while (r instanceof Bounce) r = ((Bounce) r).step();
        return r;
    }

    public final Object apply5(Object a1, Object a2, Object a3, Object a4,
                               Object a5) {
        Object r = tailApply5(a1, a2, a3, a4, a5);
        while (r instanceof Bounce) r = ((Bounce) r).step();
        return r;
    }

    public final Object apply6(Object a1, Object a2, Object a3, Object a4,
                               Object a5, Object a6) {
        Object r = tailApply6(a1, a2, a3, a4, a5, a6);
        while (r instanceof Bounce) r = ((Bounce) r).step();
        return r;
    }

    public final Object apply7(Object a1, Object a2, Object a3, Object a4,
                               Object a5, Object a6, Object a7) {
        Object r = tailApply7(a1, a2, a3, a4, a5, a6, a7);
        while (r instanceof Bounce) r = ((Bounce) r).step();
        return r;
    }

    // --- Trampoline step methods (arities 1..7) -----------------------
    //
    // Overridden by generated closure subclasses whose declared arity
    // matches the index. The default impl routes to [under] so
    // arity-mismatched calls still behave correctly (undersupply =>
    // PartialClosure; oversupply => chunked re-apply).

    public Object tailApply1(Object a1) {
        Object[] args = new Object[] { a1 };
        return under(1, args);
    }

    public Object tailApply2(Object a1, Object a2) {
        Object[] args = new Object[] { a1, a2 };
        return under(2, args);
    }

    public Object tailApply3(Object a1, Object a2, Object a3) {
        Object[] args = new Object[] { a1, a2, a3 };
        return under(3, args);
    }

    public Object tailApply4(Object a1, Object a2, Object a3, Object a4) {
        Object[] args = new Object[] { a1, a2, a3, a4 };
        return under(4, args);
    }

    public Object tailApply5(Object a1, Object a2, Object a3, Object a4,
                             Object a5) {
        Object[] args = new Object[] { a1, a2, a3, a4, a5 };
        return under(5, args);
    }

    public Object tailApply6(Object a1, Object a2, Object a3, Object a4,
                             Object a5, Object a6) {
        Object[] args = new Object[] { a1, a2, a3, a4, a5, a6 };
        return under(6, args);
    }

    public Object tailApply7(Object a1, Object a2, Object a3, Object a4,
                             Object a5, Object a6, Object a7) {
        Object[] args = new Object[] { a1, a2, a3, a4, a5, a6, a7 };
        return under(7, args);
    }

    // --- High-arity apply entry points (arities 8..16) -----------------
    //
    // Non-final, virtual — subclasses override directly. No trampoline
    // plumbing for these; high-arity tail chains are rare in practice.

    public Object apply8(Object a1, Object a2, Object a3, Object a4,
                         Object a5, Object a6, Object a7, Object a8) {
        Object[] args = new Object[] { a1, a2, a3, a4, a5, a6, a7, a8 };
        return under(8, args);
    }

    public Object apply9(Object a1, Object a2, Object a3, Object a4,
                         Object a5, Object a6, Object a7, Object a8,
                         Object a9) {
        Object[] args = new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9
        };
        return under(9, args);
    }

    public Object apply10(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10) {
        Object[] args = new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10
        };
        return under(10, args);
    }

    public Object apply11(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11) {
        Object[] args = new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11
        };
        return under(11, args);
    }

    public Object apply12(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12) {
        Object[] args = new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12
        };
        return under(12, args);
    }

    public Object apply13(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12,
                          Object a13) {
        Object[] args = new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13
        };
        return under(13, args);
    }

    public Object apply14(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12,
                          Object a13, Object a14) {
        Object[] args = new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14
        };
        return under(14, args);
    }

    public Object apply15(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12,
                          Object a13, Object a14, Object a15) {
        Object[] args = new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
        };
        return under(15, args);
    }

    public Object apply16(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12,
                          Object a13, Object a14, Object a15, Object a16) {
        Object[] args = new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14,
            a15, a16
        };
        return under(16, args);
    }

    // Fallback when applyN is invoked on a closure whose arity is
    // different from N:
    //   a > n (undersupply) — package the supplied args into a
    //   PartialClosure that dispatches once the missing args arrive.
    //   a < n (oversupply)  — the closure's result is itself a closure
    //   that should consume the remaining args. Apply the declared
    //   arity with the first [a] args, then invoke the returned
    //   closure with the rest. (OCaml supports this directly; it
    //   shows up constantly in curried Printf / List.iter patterns.)
    public Object under(int n, Object[] args) {
        int a = arity();
        if (a > n) {
            return new PartialClosure(this, args, a);
        }
        // Oversupply: split args into two runs.
        Object first = this;
        int i = 0;
        while (i < n) {
            int k = Math.min(((Closure) first).arity(), n - i);
            Object[] slice = new Object[k];
            for (int j = 0; j < k; j++) slice[j] = args[i + j];
            first = applyK((Closure) first, k, slice);
            i += k;
            if (i >= n) return first;
        }
        return first;
    }

    // Dispatch [c.applyK(slice)] by arity.
    private static Object applyK(Closure c, int k, Object[] s) {
        switch (k) {
            case 1: return c.apply1(s[0]);
            case 2: return c.apply2(s[0], s[1]);
            case 3: return c.apply3(s[0], s[1], s[2]);
            case 4: return c.apply4(s[0], s[1], s[2], s[3]);
            case 5: return c.apply5(s[0], s[1], s[2], s[3], s[4]);
            case 6: return c.apply6(s[0], s[1], s[2], s[3], s[4], s[5]);
            case 7: return c.apply7(s[0], s[1], s[2], s[3], s[4], s[5], s[6]);
            case 8:
                return c.apply8(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                s[7]);
            case 9:
                return c.apply9(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                s[7], s[8]);
            case 10:
                return c.apply10(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                 s[7], s[8], s[9]);
            case 11:
                return c.apply11(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                 s[7], s[8], s[9], s[10]);
            case 12:
                return c.apply12(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                 s[7], s[8], s[9], s[10], s[11]);
            case 13:
                return c.apply13(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                 s[7], s[8], s[9], s[10], s[11], s[12]);
            case 14:
                return c.apply14(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                 s[7], s[8], s[9], s[10], s[11], s[12],
                                 s[13]);
            case 15:
                return c.apply15(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                 s[7], s[8], s[9], s[10], s[11], s[12],
                                 s[13], s[14]);
            case 16:
                return c.apply16(s[0], s[1], s[2], s[3], s[4], s[5], s[6],
                                 s[7], s[8], s[9], s[10], s[11], s[12],
                                 s[13], s[14], s[15]);
            default:
                // k > 16: no apply{k} on the [Closure] base. The
                // generated subclass [c]'s own apply{k} is the
                // declared arity entry point — dispatch reflectively.
                return PartialClosure.reflectiveApply(c, s);
        }
    }
}
