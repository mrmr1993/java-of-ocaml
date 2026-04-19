// Base class for OCaml closures.
//
// Each OCaml function is compiled to a concrete subclass of Closure
// that overrides [arity] and the [applyN] matching its source arity.
// Calling [applyN] with N == arity hits the subclass override; calling
// it with N < arity falls through to [under], which packages the
// arguments into a PartialClosure for later completion. Calling with
// N > arity is a compile-time mistake and throws.
//
// The OCaml compiler statically picks the right applyN for each call
// site based on the number of args being passed; the K-vs-arity
// mismatch is resolved at runtime via the virtual dispatch on arity().
public class Closure {
    public Closure() {
        super();
    }

    // Subclasses override to return the function's declared arity.
    public int arity() {
        return 0;
    }

    public Object apply1(Object a1) {
        Object[] args = new Object[] { a1 };
        return under(1, args);
    }

    public Object apply2(Object a1, Object a2) {
        Object[] args = new Object[] { a1, a2 };
        return under(2, args);
    }

    public Object apply3(Object a1, Object a2, Object a3) {
        Object[] args = new Object[] { a1, a2, a3 };
        return under(3, args);
    }

    public Object apply4(Object a1, Object a2, Object a3, Object a4) {
        Object[] args = new Object[] { a1, a2, a3, a4 };
        return under(4, args);
    }

    public Object apply5(Object a1, Object a2, Object a3, Object a4,
                         Object a5) {
        Object[] args = new Object[] { a1, a2, a3, a4, a5 };
        return under(5, args);
    }

    public Object apply6(Object a1, Object a2, Object a3, Object a4,
                         Object a5, Object a6) {
        Object[] args = new Object[] { a1, a2, a3, a4, a5, a6 };
        return under(6, args);
    }

    public Object apply7(Object a1, Object a2, Object a3, Object a4,
                         Object a5, Object a6, Object a7) {
        Object[] args = new Object[] { a1, a2, a3, a4, a5, a6, a7 };
        return under(7, args);
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
            default:
                throw new RuntimeException(
                    "closure oversupply split: k=" + k + " out of supported range");
        }
    }
}
