import java.lang.ref.WeakReference;

// OCaml ephemeron runtime. An ephemeron is an array of [size] weak
// keys plus one "data" slot. In OCaml's intended GC semantics the
// data is considered reachable only while every set key is reachable;
// when any key is collected, the data becomes unreachable too. We
// approximate that on the JVM by storing keys as [WeakReference]s and
// clearing [data] the first time a read notices a key has been
// collected. Operations are exposed as static methods so
// [jvm_generate]'s [emit_ccall] can invokestatic them directly.
public final class Ephemeron {
    // Each slot is either null (unset) or a WeakReference<Object>.
    private final WeakReference<?>[] keys;
    // Strong reference to the data. Cleared when a dead key is
    // observed during read or during [set_data].
    private Object data;

    public Ephemeron(int size) {
        this.keys = new WeakReference<?>[size];
        this.data = null;
    }

    // Return true if every non-null key slot still has a live
    // referent; side-effect: null out any slot whose referent has
    // been collected (matches jsoo's lazy-clear behaviour), so
    // subsequent [check_key] / [get_key] calls see a consistent
    // state.
    private boolean allKeysLive() {
        boolean ok = true;
        for (int i = 0; i < keys.length; i++) {
            WeakReference<?> w = keys[i];
            if (w == null) continue;
            if (w.get() == null) {
                keys[i] = null;
                ok = false;
            }
        }
        if (!ok) data = null;
        return ok;
    }

    public static Object create(int n) {
        return new Ephemeron(n);
    }

    public static Object set_key(Object e, int i, Object v) {
        Ephemeron t = (Ephemeron) e;
        t.keys[i] = new WeakReference<Object>(v);
        return Integer.valueOf(0);
    }

    public static Object unset_key(Object e, int i) {
        Ephemeron t = (Ephemeron) e;
        t.keys[i] = null;
        return Integer.valueOf(0);
    }

    // Returns [None] = 0, or [Some v] = new Block(0, [v]).
    public static Object get_key(Object e, int i) {
        Ephemeron t = (Ephemeron) e;
        WeakReference<?> w = t.keys[i];
        if (w == null) return Integer.valueOf(0);
        Object v = w.get();
        if (v == null) {
            t.keys[i] = null;
            t.data = null;
            return Integer.valueOf(0);
        }
        return new Block(0, new Object[] { v });
    }

    // [get_key_copy] semantics: same as get_key for immediate
    // values; for block values OCaml wants a shallow copy. We do
    // the copy via [Block.dup] when the referent is a [Block];
    // otherwise the value is immutable and aliasing is safe.
    public static Object get_key_copy(Object e, int i) {
        Ephemeron t = (Ephemeron) e;
        WeakReference<?> w = t.keys[i];
        if (w == null) return Integer.valueOf(0);
        Object v = w.get();
        if (v == null) {
            t.keys[i] = null;
            t.data = null;
            return Integer.valueOf(0);
        }
        Object copy = (v instanceof Block) ? ((Block) v).dup() : v;
        return new Block(0, new Object[] { copy });
    }

    public static int check_key(Object e, int i) {
        Ephemeron t = (Ephemeron) e;
        WeakReference<?> w = t.keys[i];
        if (w == null) return 0;
        if (w.get() == null) {
            t.keys[i] = null;
            t.data = null;
            return 0;
        }
        return 1;
    }

    public static Object set_data(Object e, Object v) {
        Ephemeron t = (Ephemeron) e;
        if (!t.allKeysLive()) {
            t.data = null;
        } else {
            t.data = v;
        }
        return Integer.valueOf(0);
    }

    public static Object unset_data(Object e) {
        ((Ephemeron) e).data = null;
        return Integer.valueOf(0);
    }

    public static Object get_data(Object e) {
        Ephemeron t = (Ephemeron) e;
        if (t.data == null) return Integer.valueOf(0);
        if (!t.allKeysLive()) return Integer.valueOf(0);
        return new Block(0, new Object[] { t.data });
    }

    public static Object get_data_copy(Object e) {
        Ephemeron t = (Ephemeron) e;
        if (t.data == null) return Integer.valueOf(0);
        if (!t.allKeysLive()) return Integer.valueOf(0);
        Object copy = (t.data instanceof Block) ? ((Block) t.data).dup() : t.data;
        return new Block(0, new Object[] { copy });
    }

    public static int check_data(Object e) {
        Ephemeron t = (Ephemeron) e;
        if (t.data == null) return 0;
        if (!t.allKeysLive()) return 0;
        return 1;
    }

    public static Object blit_data(Object src, Object dst) {
        Ephemeron s = (Ephemeron) src;
        Ephemeron d = (Ephemeron) dst;
        d.data = s.allKeysLive() ? s.data : null;
        return Integer.valueOf(0);
    }

    // blit_key(a1, i1, a2, i2, len): copy [len] key slots from a1[i1..]
    // to a2[i2..], preserving whether each slot is unset / weak-referenced.
    public static Object blit_key(Object e1, int i1, Object e2, int i2, int len) {
        Ephemeron a = (Ephemeron) e1;
        Ephemeron b = (Ephemeron) e2;
        // Handle overlap even though a1 and a2 are usually distinct,
        // by copying forward when non-overlapping and backward when
        // necessary.
        if (a == b && i2 > i1) {
            for (int k = len - 1; k >= 0; k--) b.keys[i2 + k] = a.keys[i1 + k];
        } else {
            for (int k = 0; k < len; k++) b.keys[i2 + k] = a.keys[i1 + k];
        }
        return Integer.valueOf(0);
    }
}
