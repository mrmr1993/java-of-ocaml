// Placeholder closure returned by [caml_alloc_dummy_function]. Later
// patched to its real target by [caml_update_dummy]. Used by the
// bytecode pattern OCaml emits for recursive definitions whose right-
// hand side is a function, including the function-shape entries
// CamlinternalMod fills in for recursive modules.
//
// Applying the dummy before [caml_update_dummy] has run raises — a
// user-visible "Undefined_recursive_module" in OCaml, but we only
// have the stack trace to show; wrapping it in the same Camlinternal
// exception would need the source-side module name to be threaded
// through, which isn't available from the runtime side.
public class DummyClosure extends Closure {
    public Closure target;

    public int arity() {
        if (target == null) {
            throw new RuntimeException(
                "undefined recursive closure (DummyClosure.arity)");
        }
        return target.arity();
    }

    // Delegates live in [tailApply<N>] (not [apply<N>]): the base
    // class's [final apply<N>] drives the trampoline, and having
    // [target] return whatever [target.apply<N>] returns would
    // short-circuit the driver loop by calling through to a fresh
    // [apply<N>] on [target] — one JVM frame per hop. Overriding
    // the virtual [tailApply<N>] slot keeps the driver in the
    // caller's frame.

    public Object tailApply1(Object a1) {
        if (target == null) throw undefined();
        return target.tailApply1(a1);
    }

    public Object tailApply2(Object a1, Object a2) {
        if (target == null) throw undefined();
        return target.tailApply2(a1, a2);
    }

    public Object tailApply3(Object a1, Object a2, Object a3) {
        if (target == null) throw undefined();
        return target.tailApply3(a1, a2, a3);
    }

    public Object tailApply4(Object a1, Object a2, Object a3, Object a4) {
        if (target == null) throw undefined();
        return target.tailApply4(a1, a2, a3, a4);
    }

    public Object tailApply5(Object a1, Object a2, Object a3, Object a4,
                             Object a5) {
        if (target == null) throw undefined();
        return target.tailApply5(a1, a2, a3, a4, a5);
    }

    public Object tailApply6(Object a1, Object a2, Object a3, Object a4,
                             Object a5, Object a6) {
        if (target == null) throw undefined();
        return target.tailApply6(a1, a2, a3, a4, a5, a6);
    }

    public Object tailApply7(Object a1, Object a2, Object a3, Object a4,
                             Object a5, Object a6, Object a7) {
        if (target == null) throw undefined();
        return target.tailApply7(a1, a2, a3, a4, a5, a6, a7);
    }

    private static RuntimeException undefined() {
        return new RuntimeException(
            "undefined recursive closure (DummyClosure.apply)");
    }

    // Runtime side of caml_update_dummy: the caller hands us the
    // value produced by the real recursive body, which may be any
    // Closure subclass. We just remember it; all subsequent applies
    // forward to [target]. Returning [Object] keeps the call-site
    // polymorphism simple (some paths want void, some want a result
    // they can discard).
    public static Object updateTarget(Object dummy, Object real) {
        ((DummyClosure) dummy).target = (Closure) real;
        return null;
    }
}
