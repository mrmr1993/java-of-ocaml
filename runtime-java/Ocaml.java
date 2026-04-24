/**
 * Helper library for Java-authored OCaml C-primitive stubs. Import
 * these statically (or use full paths) to keep stub bodies short —
 * unboxing, boxing, block construction, and OCaml-shaped exceptions.
 *
 * The conventions mirror the rest of the runtime:
 *   OCaml int   ↔ java.lang.Long       (64-bit, via Block.asLong)
 *   OCaml float ↔ java.lang.Double
 *   OCaml string↔ java.lang.String
 *   block       ↔ Block (tag + Object[] fields)
 *   unit / None / [] / false ↔ Long(0)
 */
public final class Ocaml {
    private Ocaml() {}

    // -------- unbox --------

    public static long asLong(Object o) { return Block.asLong(o); }

    public static int asInt(Object o) { return (int) Block.asLong(o); }

    public static double asDouble(Object o) {
        return ((Double) o).doubleValue();
    }

    public static String asString(Object o) { return (String) o; }

    public static Block asBlock(Object o) { return (Block) o; }

    // -------- box --------

    public static Long box(long v) { return Long.valueOf(v); }
    public static Double box(double v) { return Double.valueOf(v); }

    // -------- build --------

    public static Block block(int tag, Object... fields) {
        return new Block(tag, fields);
    }

    public static Block emptyBlock(int tag) {
        return new Block(tag, new Object[0]);
    }

    public static Block some(Object v) {
        return new Block(0, new Object[] { v });
    }

    /** Integer array packaged as a Block tag 0 of boxed Longs. */
    public static Block intArray(long... xs) {
        Object[] fields = new Object[xs.length];
        for (int i = 0; i < xs.length; i++) fields[i] = Long.valueOf(xs[i]);
        return new Block(0, fields);
    }

    // -------- truthy test for OCaml conditionals --------

    /**
     * OCaml's `if` treats only `false` (== int 0) as falsy. Everything
     * else — non-zero ints, blocks, closures, strings, doubles — is
     * truthy.
     *
     * Our previous Cond K_obj emission assumed the scrutinee was
     * either a [Block] or a boxed int. If it got a [Closure] (which
     * is a reference but not a [Block] in our runtime — [Closure]
     * doesn't extend [Block]), the generated code fell through to
     * [Block.asLong] on the closure and ClassCastException'd.
     * Route through [isTruthy] for mixed-kind scrutinees so every
     * concrete runtime value decodes correctly.
     */
    public static int isTruthy(Object o) {
        if (o instanceof Long) return ((Long) o).longValue() != 0 ? 1 : 0;
        if (o instanceof Integer) return ((Integer) o).intValue() != 0 ? 1 : 0;
        // Block / Closure / String / Double / BigArray / Bytes / etc. —
        // all non-zero-int → truthy.
        return 1;
    }

    // -------- OO dispatch --------

    /**
     * Look up a method closure on an OCaml object by its hash tag.
     * Mirrors [caml_get_public_method] in OCaml's [runtime/obj.c]:
     *
     *   meths = obj.fields[0]                 // method-table Block
     *   li = 3, hi = meths.fields[0]          // search window
     *   while li < hi:
     *     mi = ((li+hi) >> 1) | 1             // guarantee odd mi
     *     if tag < meths.fields[mi]: hi = mi-2
     *     else:                       li = mi
     *   return meths.fields[li-1]
     *
     * Method tables store alternating (method, tag) pairs starting
     * at index 2, sorted by tag. The `| 1` keeps [mi] pointing at
     * a tag slot; [li-1] is then the matching method slot.
     *
     * Upstream's interp.c carries an inline cache (a PC-local field
     * mutated on hit). We skip it — correctness doesn't depend on
     * it, and a profiler can flag the extra binary search later.
     */
    public static Object getPublicMethod(Object obj, long tag) {
        Block o = (Block) obj;
        Block meths = (Block) o.fields[0];
        // Upstream's [Field(meths,0)] reads [len] as an OCaml-tagged
        // integer: physically `(len << 1) | 1`. Our runtime stores
        // OCaml ints as plain [Long]s (no tag bit), so we
        // reconstruct the tagged form to match the algorithm's
        // bounds expectations — otherwise the binary search
        // collapses for any class with more than one public method.
        long len = Block.asLong(meths.fields[0]);
        int hi = (int) ((len << 1) | 1);
        int li = 3;
        while (li < hi) {
            int mi = ((li + hi) >> 1) | 1;
            long t = Block.asLong(meths.fields[mi]);
            if (tag < t) hi = mi - 2;
            else li = mi;
        }
        return meths.fields[li - 1];
    }

    // -------- predefined exception identifiers --------

    /** OCaml's predefined [Failure] exception identifier (a tag-248
     *  Block stored at [GLOBALS[2]] after globals init). The compiler
     *  wires this field once globals are populated. Used by
     *  [raiseFailure] and by the auto-generated "primitive not
     *  implemented" stubs so OCaml's [try ... with _] / [with Failure _]
     *  catches them. Stays [null] until globals init runs (i.e. for
     *  programs that don't link Stdlib's predefined exceptions);
     *  [raiseFailure] falls back to a fresh fabricated identifier in
     *  that case so it still throws something OCaml-shaped. */
    public static Object failureExn;

    /** OCaml's predefined [Not_found] exception identifier
     *  ([GLOBALS[6]]). Used by stubs that need to signal "lookup
     *  failed" the way OCaml stdlib does (e.g. [Unix.gethostbyname]
     *  on an unresolvable name, [Hashtbl.find] on a missing key). */
    public static Object notFoundExn;

    /** OCaml's predefined [Sys_error] ([GLOBALS[1]]). Used by stubs
     *  raising stdlib I/O errors (e.g. open_in on missing file). */
    public static Object sysErrorExn;

    /** Throw a [CamlException] wrapping [Failure msg]. The shape is
     *  [Block(0, [failureExn, msg])] so OCaml's [try ... with Failure _]
     *  matches by reference identity on field 0. */
    public static RuntimeException raiseFailure(String msg) {
        Object id = failureExn;
        if (id == null) {
            // Pre-globals-init or no Stdlib linked: fabricate a
            // descriptor so we still throw a CamlException.
            id = new Block(248, new Object[] { "Failure", Long.valueOf(-1L) });
        }
        throw new CamlException(new Block(0, new Object[] { id, msg }));
    }

    /** Throw a [CamlException] for an auto-generated "primitive not
     *  implemented" stub. Logs to stderr *before* throwing so the
     *  message survives OCaml-level [try ... with _] handlers that
     *  would otherwise swallow it (e.g. when [sexp_of_exn] fires
     *  while formatting another exception and trips a second
     *  exception that obscures the original).
     *
     *  Quieted by JAVA_OF_OCAML_QUIET_STUBS=1 for test runs where a
     *  [try ... with _] path legitimately depends on an auto-stub
     *  firing (e.g. feature-availability probes) and doesn't want
     *  stderr clutter. */
    public static RuntimeException raiseUnimplementedPrim(String primName) {
        if (System.getenv("JAVA_OF_OCAML_QUIET_STUBS") == null) {
            System.err.println(
                "[java_of_ocaml] unimplemented C primitive: " + primName);
        }
        throw raiseFailure("C primitive " + primName + " is not implemented");
    }

    /** Throw a [CamlException] wrapping [Sys_error msg]. Same shape
     *  as [Failure msg]: Block(0, [sysErrorExn, msg]). */
    public static RuntimeException raiseSysError(String msg) {
        Object id = sysErrorExn;
        if (id == null) {
            id = new Block(248, new Object[] { "Sys_error", Long.valueOf(-1L) });
        }
        throw new CamlException(new Block(0, new Object[] { id, msg }));
    }

    /** Throw a [CamlException] wrapping [Not_found]. Constructor is
     *  nullary, so the payload is just the descriptor itself. */
    public static RuntimeException raiseNotFound() {
        Object id = notFoundExn;
        if (id == null) {
            id = new Block(248, new Object[] { "Not_found", Long.valueOf(-1L) });
        }
        throw new CamlException(id);
    }

    // -------- OCaml runtime lock --------
    //
    // OCaml's threading model assumes that only one OS thread runs
    // OCaml code at a time. The C runtime enforces this with
    // [caml_master_lock] (see otherlibs/systhreads/st_stubs.c):
    //   - before entering a "blocking section" (I/O syscall, sleep,
    //     condition wait), the thread releases the lock;
    //   - after, it re-acquires.
    //
    // Pure OCaml code (e.g. Thread_safe_queue.enqueue / dequeue)
    // assumes context switches can only happen at allocation /
    // external-call boundaries. The JVM does not honor that
    // assumption — its threads run truly concurrently — so without a
    // matching lock here, OCaml's concurrent data structures get
    // corrupted (notably the squeue Async uses to ferry results from
    // worker-thread syscalls back to the main scheduler).
    //
    // We mirror the C runtime's model with a single ReentrantLock
    // owned at startup by the main thread. Java-side stubs that
    // perform genuinely blocking work (Unix.select sleep, Mutex
    // wait, etc.) bracket the wait with [runtimeUnlock] /
    // [runtimeLock]. Worker threads spawned via [ThreadPrim] start
    // by acquiring the lock before they begin running OCaml code.

    public static final java.util.concurrent.locks.ReentrantLock RUNTIME_LOCK
        = new java.util.concurrent.locks.ReentrantLock();

    /** Acquire the runtime lock. Blocks if another thread holds it. */
    public static void runtimeLock() { RUNTIME_LOCK.lock(); }

    /** Release the runtime lock. Caller must hold it. */
    public static void runtimeUnlock() { RUNTIME_LOCK.unlock(); }

    /** Run [r] with the runtime lock released. Restores the lock
     *  state on exit (even on exception). */
    public static <T extends Throwable> void blockingSection(
            java.util.concurrent.Callable<Void> body) throws Exception {
        boolean held = RUNTIME_LOCK.isHeldByCurrentThread();
        if (held) RUNTIME_LOCK.unlock();
        try { body.call(); }
        finally { if (held) RUNTIME_LOCK.lock(); }
    }

    // -------- OO / exception identifier allocation --------
    //
    // OCaml's runtime hands out a fresh int id per new extension
    // constructor / object via [caml_fresh_oo_id] + [caml_set_oo_id].
    // Ids are stored in field 1 of the tag-248 identifier block and
    // used for reference-identity comparisons — in particular sexp /
    // hash lookups keyed by [Obj.Extension_constructor.id].
    //
    // Previously compile-time per-call-site counter. That collapsed
    // to a single value for every runtime invocation of a shared
    // creator closure, so [sexp_of_exn] found the *first* registered
    // exception converter for every exception and mis-called it. The
    // generated [[@@deriving sexp]] converter then asserted false
    // on the mismatch. Runtime counter fixes it.

    private static final java.util.concurrent.atomic.AtomicLong NEXT_OO_ID
        = new java.util.concurrent.atomic.AtomicLong(0);

    public static long freshOoId() {
        return NEXT_OO_ID.getAndIncrement();
    }

    // -------- Callback.register / Callback.register_exception --------
    //
    // OCaml programs expose values (closures, exception descriptors) to
    // the C side via [Callback.register] / [Callback.register_exception],
    // which call [caml_register_named_value name v]. Our backend wires
    // that primitive to [Ocaml.registerNamedValue] so Java-side stubs
    // can retrieve the registered value with [Ocaml.namedValue name].
    //
    // Common callers: [Unix] registers its [Unix_error] exception so C
    // stubs can raise it; [Digestif] registers internal continuations;
    // application code registers exit-handler closures. Anything else that wants to
    // bridge OCaml identities into Java stubs goes through here.

    private static final java.util.concurrent.ConcurrentHashMap<String, Object>
        NAMED_VALUES = new java.util.concurrent.ConcurrentHashMap<>();

    public static long registerNamedValue(Object name, Object value) {
        String key = (String) name;
        if (value != null) NAMED_VALUES.put(key, value);
        else NAMED_VALUES.remove(key);
        return 0;
    }

    /** Returns the OCaml value registered under [name], or [null] if
     *  no registration has happened yet. */
    public static Object namedValue(String name) {
        return NAMED_VALUES.get(name);
    }

    /** Throw a [CamlException] wrapping [Unix.Unix_error(err, syscall, arg)].
     *  [err] is a variant tag index from [stubs-contrib/core_unix/
     *  CoreUnix.java#errnoToVariantIndex] — e.g. 25 for ENOSYS,
     *  2 for EAGAIN. Requires [Unix.Unix_error] to have been
     *  registered via [Callback.register_exception] — which happens
     *  early in any program that links the Unix stdlib. */
    public static RuntimeException raiseUnixError(
            long errVariant, String syscall, String arg) {
        Object id = namedValue("Unix.Unix_error");
        if (id == null) {
            id = new Block(248, new Object[] {
                "Unix.Unix_error", Long.valueOf(-1L),
            });
        }
        throw new CamlException(new Block(0, new Object[] {
            id, Long.valueOf(errVariant), syscall, arg,
        }));
    }

    // -------- sentinels --------

    public static final Object unit = Long.valueOf(0L);
    public static final Object none = Long.valueOf(0L);
    public static final Object emptyList = Long.valueOf(0L);
    public static final Object bool_false = Long.valueOf(0L);
    public static final Object bool_true = Long.valueOf(1L);
}
