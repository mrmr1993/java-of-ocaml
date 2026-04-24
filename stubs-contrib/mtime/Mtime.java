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

    // === REAL: time_now / time_stamp_counter / clock_gettime ==========
    // [Time_now.nanoseconds_since_unix_epoch_or_zero]: wall-clock ns
    // since Unix epoch. JVM has currentTimeMillis (ms-precision); we
    // multiply by 1_000_000. Sub-ms resolution would need
    // [Instant.now()] — not free, but worth doing if this path
    // shows up in profiling.
    public static long time_now_nanoseconds_since_unix_epoch_or_zero(Object u) {
        return System.currentTimeMillis() * 1_000_000L;
    }

    // [Time_stamp_counter.now] / [tsc_get]: a monotonic counter used
    // for deltas. The OCaml side eventually converts to ns via a
    // calibration constant; we use [System.nanoTime()] directly so
    // calibration isn't needed (1 tsc tick = 1 ns under our impl).
    public static long tsc_get(Object u) {
        return System.nanoTime();
    }

    // [core_unix_clock_gettime]: POSIX clock_gettime. Returns time as
    // float-seconds. We collapse all clock IDs to System.nanoTime()
    // (monotonic) or currentTimeMillis (real) — fine for the
    // measure-elapsed-time use callers typically have. Clock id is an int
    // variant index; 0 = REALTIME, 1 = MONOTONIC, etc.
    public static double clock_gettime(long clock) {
        if (clock == 0) {
            // REALTIME — wall clock
            return System.currentTimeMillis() / 1000.0;
        }
        // MONOTONIC / MONOTONIC_RAW / PROCESS_CPUTIME / THREAD_CPUTIME
        return System.nanoTime() / 1_000_000_000.0;
    }

    public static long clock_settime(long clock, double t) {
        // No-op — JVM can't change the system clock.
        return 0;
    }

    public static double clock_getres(long clock) {
        // 1 ns resolution for the monotonic clocks; ms for REALTIME.
        return clock == 0 ? 0.001 : 1.0e-9;
    }
}
