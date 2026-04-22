/**
 * Arithmetic, conversions, and parsing for the [integers] library's
 * unsigned-integer types (uint8..uint64, size_t, uint, ulong,
 * ulonglong). OCaml's backing [int] is already a signed 64-bit
 * [long] on this compiler, so most unsigned ops pass through
 * to Java's signed [long] arithmetic; divide/remainder and
 * to/from_string route through [Long.divideUnsigned] /
 * [remainderUnsigned] / [toUnsignedString] / [parseUnsignedLong]
 * for correct unsigned semantics.
 *
 * Every method uses primitive [long] parameters + return so the
 * compiler keeps values as [K_int] across the call — no
 * [Long.valueOf] / [asLong] round-trip per op. This matters: the
 * integers_* family is hot on Core's [Int63] and [Time_ns.Span]
 * paths.
 */
public final class IntegersStubs {
    private IntegersStubs() {}

    // ---- conversions: [of_int] / [to_int] / cross-width / cross-type ----
    public static long passthrough(long v) { return v; }

    // ---- binary arithmetic ----
    public static long add(long a, long b) { return a + b; }
    public static long sub(long a, long b) { return a - b; }
    public static long mul(long a, long b) { return a * b; }
    public static long div(long a, long b) { return Long.divideUnsigned(a, b); }
    public static long rem(long a, long b) { return Long.remainderUnsigned(a, b); }
    public static long logand(long a, long b) { return a & b; }
    public static long logor(long a, long b)  { return a | b; }
    public static long logxor(long a, long b) { return a ^ b; }

    // Shifts: OCaml passes a second [int] (= long); narrow to JVM int.
    public static long shift_left(long v, long n)  { return v << (int) n; }
    public static long shift_right(long v, long n) { return v >>> (int) n; }

    // ---- string <-> unsigned ----
    public static String to_string(long v) { return Long.toUnsignedString(v); }
    public static long of_string(Object s) {
        return Long.parseUnsignedLong((String) s);
    }
}
