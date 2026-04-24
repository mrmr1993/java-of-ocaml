// Trampoline sentinel for OCaml tail calls.
//
// OCaml's [APPTERM*] opcodes are tail-position function applications:
// the current frame's locals are discarded, the target is called, and
// its result is the enclosing caller's result. On native OCaml this
// reuses the current stack frame (O(1)); on a JVM the
// [invokevirtual + areturn] lowering consumes a new frame per call,
// so deeply-recursive tail chains overflow the stack.
//
// To sidestep that, the compiler emits "return a [Bounce]" at every
// tail-position [Apply] instead of a real [invokevirtual]. The
// [Closure.apply<N>] driver in the base class unwinds the returned
// Bounce in a [while (r instanceof Bounce) r = r.step();] loop, so
// the whole chain runs in a single JVM frame.
//
// [Bounce] captures [(callee, args)]. [step] dispatches to the
// appropriate [tailApply<N>] by [args.length]; anything beyond arity
// 7 falls through to [under], matching [Closure.apply<N>]'s existing
// over-arity handling.
public final class Bounce {
    public final Closure callee;
    public final Object[] args;

    public Bounce(Closure callee, Object[] args) {
        this.callee = callee;
        this.args = args;
    }

    // Invoke the trampolined call. The returned value is either a
    // real result or another [Bounce] — the driver loop in
    // [Closure.apply<N>] iterates until neither.
    public Object step() {
        switch (args.length) {
            case 1: return callee.tailApply1(args[0]);
            case 2: return callee.tailApply2(args[0], args[1]);
            case 3: return callee.tailApply3(args[0], args[1], args[2]);
            case 4: return callee.tailApply4(args[0], args[1], args[2],
                                             args[3]);
            case 5: return callee.tailApply5(args[0], args[1], args[2],
                                             args[3], args[4]);
            case 6: return callee.tailApply6(args[0], args[1], args[2],
                                             args[3], args[4], args[5]);
            case 7: return callee.tailApply7(args[0], args[1], args[2],
                                             args[3], args[4], args[5],
                                             args[6]);
            default: return callee.under(args.length, args);
        }
    }
}
