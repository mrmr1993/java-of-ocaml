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

    // Fallback for when applyN is invoked on a closure whose arity is
    // larger than N: wrap the supplied args in a PartialClosure that
    // will dispatch once the missing args are provided.
    public Object under(int n, Object[] args) {
        int a = arity();
        if (a > n) {
            return new PartialClosure(this, args, a);
        }
        throw new RuntimeException("closure arity mismatch");
    }
}
