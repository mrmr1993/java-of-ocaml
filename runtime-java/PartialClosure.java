import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.concurrent.ConcurrentHashMap;

// Undersupplied application: holds a target Closure, the args already
// captured, and a caller's declared arity. Each applyN appends its
// new args to [captured] and either builds a deeper PartialClosure (if
// still short of [targetArity]) or dispatches through a caller's
// own applyN at saturation.
public final class PartialClosure extends Closure {
    // Cache of (subclass, arity) -> applyN Method handle for the
    // reflective fallback path used when arity > 16.
    private static final ConcurrentHashMap<Class<?>, Method> APPLY_METHOD_CACHE
        = new ConcurrentHashMap<>();

    private static Method resolveApplyMethod(Class<?> cls, int arity) {
        Method cached = APPLY_METHOD_CACHE.get(cls);
        if (cached != null) return cached;
        Class<?>[] paramTypes = new Class<?>[arity];
        for (int i = 0; i < arity; i++) paramTypes[i] = Object.class;
        try {
            Method m = cls.getMethod("apply" + arity, paramTypes);
            APPLY_METHOD_CACHE.putIfAbsent(cls, m);
            return m;
        } catch (NoSuchMethodException e) {
            throw new RuntimeException(
                "no apply" + arity + " method on " + cls.getName(), e);
        }
    }

    static Object reflectiveApply(Closure target, Object[] args) {
        Method m = resolveApplyMethod(target.getClass(), args.length);
        try {
            return m.invoke(target, args);
        } catch (InvocationTargetException e) {
            Throwable cause = e.getCause();
            if (cause instanceof RuntimeException) throw (RuntimeException) cause;
            if (cause instanceof Error) throw (Error) cause;
            throw new RuntimeException(cause);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
    }

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
    public Object dispatchSaturated(Object[] c) {
        switch (c.length) {
            case 1: return target.apply1(c[0]);
            case 2: return target.apply2(c[0], c[1]);
            case 3: return target.apply3(c[0], c[1], c[2]);
            case 4: return target.apply4(c[0], c[1], c[2], c[3]);
            case 5: return target.apply5(c[0], c[1], c[2], c[3], c[4]);
            case 6: return target.apply6(c[0], c[1], c[2], c[3], c[4], c[5]);
            case 7:
                return target.apply7(c[0], c[1], c[2], c[3], c[4], c[5],
                                     c[6]);
            case 8:
                return target.apply8(c[0], c[1], c[2], c[3], c[4], c[5],
                                     c[6], c[7]);
            case 9:
                return target.apply9(c[0], c[1], c[2], c[3], c[4], c[5],
                                     c[6], c[7], c[8]);
            case 10:
                return target.apply10(c[0], c[1], c[2], c[3], c[4], c[5],
                                      c[6], c[7], c[8], c[9]);
            case 11:
                return target.apply11(c[0], c[1], c[2], c[3], c[4], c[5],
                                      c[6], c[7], c[8], c[9], c[10]);
            case 12:
                return target.apply12(c[0], c[1], c[2], c[3], c[4], c[5],
                                      c[6], c[7], c[8], c[9], c[10], c[11]);
            case 13:
                return target.apply13(c[0], c[1], c[2], c[3], c[4], c[5],
                                      c[6], c[7], c[8], c[9], c[10], c[11],
                                      c[12]);
            case 14:
                return target.apply14(c[0], c[1], c[2], c[3], c[4], c[5],
                                      c[6], c[7], c[8], c[9], c[10], c[11],
                                      c[12], c[13]);
            case 15:
                return target.apply15(c[0], c[1], c[2], c[3], c[4], c[5],
                                      c[6], c[7], c[8], c[9], c[10], c[11],
                                      c[12], c[13], c[14]);
            case 16:
                return target.apply16(c[0], c[1], c[2], c[3], c[4], c[5],
                                      c[6], c[7], c[8], c[9], c[10], c[11],
                                      c[12], c[13], c[14], c[15]);
            default:
                // Arity > 16: the [Closure] base class has no
                // [applyN] for this N (since the base only declares
                // up to apply16). Fall back to reflection on the
                // generated subclass's own [applyN]. Cached per
                // class so the lookup cost is amortised.
                return reflectiveApply(target, c);
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

    @Override
    public Object apply8(Object a1, Object a2, Object a3, Object a4,
                         Object a5, Object a6, Object a7, Object a8) {
        return applyCombined(
            combine(new Object[] { a1, a2, a3, a4, a5, a6, a7, a8 }));
    }

    @Override
    public Object apply9(Object a1, Object a2, Object a3, Object a4,
                         Object a5, Object a6, Object a7, Object a8,
                         Object a9) {
        return applyCombined(combine(new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9
        }));
    }

    @Override
    public Object apply10(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10) {
        return applyCombined(combine(new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10
        }));
    }

    @Override
    public Object apply11(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11) {
        return applyCombined(combine(new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11
        }));
    }

    @Override
    public Object apply12(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12) {
        return applyCombined(combine(new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12
        }));
    }

    @Override
    public Object apply13(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12,
                          Object a13) {
        return applyCombined(combine(new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13
        }));
    }

    @Override
    public Object apply14(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12,
                          Object a13, Object a14) {
        return applyCombined(combine(new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14
        }));
    }

    @Override
    public Object apply15(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12,
                          Object a13, Object a14, Object a15) {
        return applyCombined(combine(new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
        }));
    }

    @Override
    public Object apply16(Object a1, Object a2, Object a3, Object a4,
                          Object a5, Object a6, Object a7, Object a8,
                          Object a9, Object a10, Object a11, Object a12,
                          Object a13, Object a14, Object a15, Object a16) {
        return applyCombined(combine(new Object[] {
            a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14,
            a15, a16
        }));
    }
}
