// Undersupplied application: holds a target Closure, the args already
// captured, and a caller's declared arity. Each applyN appends its
// new args to [captured] and either builds a deeper PartialClosure (if
// still short of [targetArity]) or dispatches through a caller's
// own applyN at saturation.
public final class PartialClosure extends Closure {
    public final Closure target;
    public final Object[] captured;
    public final int targetArity;

    public PartialClosure(Closure target, Object[] captured, int targetArity) {
        super();
        this.target = target;
        this.captured = captured;
        this.targetArity = targetArity;
    }

    @Override
    public int arity() {
        return targetArity - captured.length;
    }

    // Called once [captured] has been topped up to [targetArity].
    // Dispatches through a caller's concrete applyN override.
    public Object dispatchSaturated(Object[] combined) {
        switch (combined.length) {
            case 1:
                return target.apply1(combined[0]);
            case 2:
                return target.apply2(combined[0], combined[1]);
            case 3:
                return target.apply3(combined[0], combined[1], combined[2]);
            case 4:
                return target.apply4(combined[0], combined[1], combined[2],
                                     combined[3]);
            case 5:
                return target.apply5(combined[0], combined[1], combined[2],
                                     combined[3], combined[4]);
            case 6:
                return target.apply6(combined[0], combined[1], combined[2],
                                     combined[3], combined[4], combined[5]);
            case 7:
                return target.apply7(combined[0], combined[1], combined[2],
                                     combined[3], combined[4], combined[5],
                                     combined[6]);
            default:
                throw new RuntimeException("unsupported partial-closure arity");
        }
    }

    private Object applyCombined(Object[] combined) {
        if (combined.length < targetArity) {
            return new PartialClosure(target, combined, targetArity);
        }
        return dispatchSaturated(combined);
    }

    private Object[] combine(Object[] extra) {
        int capLen = captured.length;
        Object[] combined = new Object[capLen + extra.length];
        System.arraycopy(captured, 0, combined, 0, capLen);
        System.arraycopy(extra, 0, combined, capLen, extra.length);
        return combined;
    }

    @Override
    public Object apply1(Object a1) {
        return applyCombined(combine(new Object[] { a1 }));
    }

    @Override
    public Object apply2(Object a1, Object a2) {
        return applyCombined(combine(new Object[] { a1, a2 }));
    }

    @Override
    public Object apply3(Object a1, Object a2, Object a3) {
        return applyCombined(combine(new Object[] { a1, a2, a3 }));
    }

    @Override
    public Object apply4(Object a1, Object a2, Object a3, Object a4) {
        return applyCombined(combine(new Object[] { a1, a2, a3, a4 }));
    }

    @Override
    public Object apply5(Object a1, Object a2, Object a3, Object a4,
                         Object a5) {
        return applyCombined(combine(new Object[] { a1, a2, a3, a4, a5 }));
    }

    @Override
    public Object apply6(Object a1, Object a2, Object a3, Object a4,
                         Object a5, Object a6) {
        return applyCombined(
            combine(new Object[] { a1, a2, a3, a4, a5, a6 }));
    }

    @Override
    public Object apply7(Object a1, Object a2, Object a3, Object a4,
                         Object a5, Object a6, Object a7) {
        return applyCombined(
            combine(new Object[] { a1, a2, a3, a4, a5, a6, a7 }));
    }
}
