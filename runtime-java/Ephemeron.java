import java.lang.ref.WeakReference;

// OCaml ephemeron runtime. An ephemeron is [size] weak key slots
// plus one "data" slot. In OCaml's intended GC semantics the data
// is considered reachable only while every set key is reachable;
// when any key is collected, the data becomes unreachable too. We
// approximate that on the JVM by storing keys as [WeakReference]s
// and clearing [data] the first time a read notices a key has been
// collected.
//
// Extends [Block] so values produced by [caml_ephe_create] satisfy
// the [checkcast Block] that OCaml's [Obj] module emits on them
// (Base's [Ephemeron] implementation uses [Obj.size] / [Obj.field]
// to traverse the structure). The layout matches what
// [Obj.Ephemeron.length] expects: [Obj.size t - additional_values
// = length], with [additional_values = 2]. That is, the [fields]
// array has [n + 2] slots: [[list_head_sentinel, data, key_0, ...,
// key_{n-1}]]. The sentinel is a placeholder the native OCaml
// runtime uses for its ephemeron-list bookkeeping; we don't need
// it, but keeping the slot makes [length] arithmetic match.
// Tag is 251 (Abstract_tag) to match OCaml's own representation.
public final class Ephemeron extends Block {

    // Key slots start at index [KEY_OFFSET]; [DATA_OFFSET] is the
    // data slot; index 0 is the list-head sentinel.
    private static final int DATA_OFFSET = 1;
    private static final int KEY_OFFSET = 2;

    public Ephemeron(int size) {
        super(251, new Object[size + 2]);
        // Sentinel placeholder — some non-null value so callers
        // that introspect the raw fields see a populated slot.
        this.fields[0] = Integer.valueOf(0);
    }

    // Sweep: clear any weak slot whose referent has been collected
    // and, if any key died, clear the data slot too. Returns true
    // iff every set key is still live afterwards.
    private boolean allKeysLive() {
        boolean ok = true;
        for (int i = KEY_OFFSET; i < this.fields.length; i++) {
            Object slot = this.fields[i];
            if (slot == null) continue;
            if (slot instanceof WeakReference<?>
                && ((WeakReference<?>) slot).get() == null) {
                this.fields[i] = null;
                ok = false;
            }
        }
        if (!ok) this.fields[DATA_OFFSET] = null;
        return ok;
    }

    public static Object create(int n) {
        return new Ephemeron(n);
    }

    public static Object set_key(Object e, int i, Object v) {
        Ephemeron t = (Ephemeron) e;
        t.fields[i + KEY_OFFSET] = new WeakReference<Object>(v);
        return Integer.valueOf(0);
    }

    public static Object unset_key(Object e, int i) {
        Ephemeron t = (Ephemeron) e;
        t.fields[i + KEY_OFFSET] = null;
        return Integer.valueOf(0);
    }

    // Returns [None] = 0, or [Some v] = new Block(0, [v]).
    public static Object get_key(Object e, int i) {
        Ephemeron t = (Ephemeron) e;
        Object slot = t.fields[i + KEY_OFFSET];
        if (slot == null) return Integer.valueOf(0);
        @SuppressWarnings("unchecked")
        WeakReference<Object> w = (WeakReference<Object>) slot;
        Object v = w.get();
        if (v == null) {
            t.fields[i + KEY_OFFSET] = null;
            t.fields[DATA_OFFSET] = null;
            return Integer.valueOf(0);
        }
        return new Block(0, new Object[] { v });
    }

    // Same as [get_key] for immediate values; for block values we
    // shallow-copy to match [Obj.Ephemeron.get_key_copy] semantics.
    public static Object get_key_copy(Object e, int i) {
        Ephemeron t = (Ephemeron) e;
        Object slot = t.fields[i + KEY_OFFSET];
        if (slot == null) return Integer.valueOf(0);
        @SuppressWarnings("unchecked")
        WeakReference<Object> w = (WeakReference<Object>) slot;
        Object v = w.get();
        if (v == null) {
            t.fields[i + KEY_OFFSET] = null;
            t.fields[DATA_OFFSET] = null;
            return Integer.valueOf(0);
        }
        Object copy = (v instanceof Block) ? ((Block) v).dup() : v;
        return new Block(0, new Object[] { copy });
    }

    public static int check_key(Object e, int i) {
        Ephemeron t = (Ephemeron) e;
        Object slot = t.fields[i + KEY_OFFSET];
        if (slot == null) return 0;
        @SuppressWarnings("unchecked")
        WeakReference<Object> w = (WeakReference<Object>) slot;
        if (w.get() == null) {
            t.fields[i + KEY_OFFSET] = null;
            t.fields[DATA_OFFSET] = null;
            return 0;
        }
        return 1;
    }

    public static Object set_data(Object e, Object v) {
        Ephemeron t = (Ephemeron) e;
        t.fields[DATA_OFFSET] = t.allKeysLive() ? v : null;
        return Integer.valueOf(0);
    }

    public static Object unset_data(Object e) {
        Ephemeron t = (Ephemeron) e;
        t.fields[DATA_OFFSET] = null;
        return Integer.valueOf(0);
    }

    public static Object get_data(Object e) {
        Ephemeron t = (Ephemeron) e;
        if (t.fields[DATA_OFFSET] == null) return Integer.valueOf(0);
        if (!t.allKeysLive()) return Integer.valueOf(0);
        return new Block(0, new Object[] { t.fields[DATA_OFFSET] });
    }

    public static Object get_data_copy(Object e) {
        Ephemeron t = (Ephemeron) e;
        if (t.fields[DATA_OFFSET] == null) return Integer.valueOf(0);
        if (!t.allKeysLive()) return Integer.valueOf(0);
        Object v = t.fields[DATA_OFFSET];
        Object copy = (v instanceof Block) ? ((Block) v).dup() : v;
        return new Block(0, new Object[] { copy });
    }

    public static int check_data(Object e) {
        Ephemeron t = (Ephemeron) e;
        if (t.fields[DATA_OFFSET] == null) return 0;
        if (!t.allKeysLive()) return 0;
        return 1;
    }

    public static Object blit_data(Object src, Object dst) {
        Ephemeron s = (Ephemeron) src;
        Ephemeron d = (Ephemeron) dst;
        d.fields[DATA_OFFSET] = s.allKeysLive() ? s.fields[DATA_OFFSET] : null;
        return Integer.valueOf(0);
    }

    // blit_key(a1, i1, a2, i2, len): copy [len] key slots from a1[i1..]
    // to a2[i2..], preserving unset / weak representation.
    public static Object blit_key(Object e1, int i1, Object e2, int i2, int len) {
        Ephemeron a = (Ephemeron) e1;
        Ephemeron b = (Ephemeron) e2;
        // Account for the data slot offset (+1). Handle overlap
        // when copying in-place.
        if (a == b && i2 > i1) {
            for (int k = len - 1; k >= 0; k--) {
                b.fields[i2 + KEY_OFFSET + k] = a.fields[i1 + KEY_OFFSET + k];
            }
        } else {
            for (int k = 0; k < len; k++) {
                b.fields[i2 + KEY_OFFSET + k] = a.fields[i1 + KEY_OFFSET + k];
            }
        }
        return Integer.valueOf(0);
    }
}
