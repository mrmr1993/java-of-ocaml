/**
 * [mtime.clock.os] C primitives — monotonic clock readings.
 *
 * Real implementation: routes to [System.nanoTime()] which is
 * the JVM's monotonic nanosecond timer. Suitable for elapsed-
 * time measurement; not wall-clock.
 *
 * Not a stub — the values here are real and useful. Listed in
 * stubs-contrib only because [mtime] isn't part of the
 * js_of_ocaml built-in runtime.
 */
public final class Mtime {
    private Mtime() {}

    private static final long ORIGIN_NS = System.nanoTime();

    /** [mtime_clock.ml: elapsed_ns ()] — ns since process start. */
    public static long elapsed_ns(Object u) {
        return System.nanoTime() - ORIGIN_NS;
    }

    /** [mtime_clock.ml: now_ns ()] — JVM's raw monotonic ns
     *  reading. Mtime documents both [elapsed_ns] and [now_ns] as
     *  monotonic but with different origins; we use the JVM clock
     *  directly here so callers can compute differences across the
     *  two without surprises. */
    public static long now_ns(Object u) {
        return System.nanoTime();
    }

    /** [mtime_clock.ml: period_ns ()] — clock resolution as
     *  [int64 option]. JVM doesn't expose this; return [None]
     *  (= Long(0)) so callers fall back to "unknown". */
    public static Object period_ns(Object u) {
        return Long.valueOf(0L);
    }
}
