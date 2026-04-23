/**
 * Stubs for the [integers] opam package. Not part of
 * js_of_ocaml's built-in runtime — the upstream equivalent is
 * [integers_stubs_js], a separate runtime that users depend on via
 * a dune [(libraries integers_stubs_js)] entry. Here we keep the
 * same split: opt in via [--stub-manifest stubs-contrib/integers/
 * stubs.json] at compile time.
 *
 * OCaml's backing [int] is signed 64-bit [long] in this compiler,
 * so most unsigned ops are direct passthroughs on Java [long];
 * divide / remainder / string-conversion route through
 * [Long.divideUnsigned] / [remainderUnsigned] /
 * [toUnsignedString] / [parseUnsignedLong].
 *
 * Methods use primitive [long] / [double] parameters where
 * possible so the compiler keeps values as [K_int] / [K_float]
 * across the call.
 */
public final class Integers {
    private Integers() {}

    // ---- library init (unit return) ----
    public static long init(Object ignore) { return 0; }

    // ---- range / size constants ----
    public static long uint8_max(Object ignore)  { return 0xFFL; }
    public static long uint8_min(Object ignore)  { return 0; }
    public static long uint16_max(Object ignore) { return 0xFFFFL; }
    public static long uint16_min(Object ignore) { return 0; }
    public static long uint32_max(Object ignore) { return 0xFFFFFFFFL; }
    public static long uint32_min(Object ignore) { return 0; }
    public static long uint64_max(Object ignore) { return -1L; }
    public static long uint64_min(Object ignore) { return 0; }

    public static long size_t_size(Object ignore)     { return 8; }
    public static long ushort_size(Object ignore)     { return 2; }
    public static long uint_size(Object ignore)       { return 4; }
    public static long ulong_size(Object ignore)      { return 8; }
    public static long ulonglong_size(Object ignore)  { return 8; }
    public static long intptr_t_size(Object ignore)   { return 8; }
    public static long uintptr_t_size(Object ignore)  { return 8; }
    public static long ptrdiff_t_size(Object ignore)  { return 8; }

    // ---- cross-width / cross-type conversions (passthrough) ----
    public static long passthrough(long v) { return v; }

    // ---- binary arithmetic ----
    public static long add(long a, long b)    { return a + b; }
    public static long sub(long a, long b)    { return a - b; }
    public static long mul(long a, long b)    { return a * b; }
    public static long div(long a, long b)    { return Long.divideUnsigned(a, b); }
    public static long rem(long a, long b)    { return Long.remainderUnsigned(a, b); }
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
