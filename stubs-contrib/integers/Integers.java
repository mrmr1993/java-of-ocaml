/**
 * Stubs for the [integers] opam package ([unsigned_stubs.c] in
 * integers 0.4.0). Not part of js_of_ocaml's built-in runtime —
 * the upstream equivalent is [integers_stubs_js], a separate
 * runtime that user projects depend on via a dune
 * [(libraries integers_stubs_js)] entry. Here we keep the same
 * split: opt in via [--stub-manifest stubs-contrib/integers/
 * stubs.json].
 *
 * ### Naming
 *
 * Methods track the upstream C-entry-point names
 * ([integers_uint32_add], etc.); we drop the [integers_] prefix
 * for brevity. Each manifest key is the full C name.
 *
 * ### Representation
 *
 * Upstream uses [caml_alloc_custom] blocks to box [uint32_t] and
 * [uint64_t] values. We store both as a JVM primitive [long] —
 * OCaml int has already been widened to 64-bit in this compiler,
 * so a plain long round-trips cleanly through our [K_int] slots.
 *
 * For [uint32], we mask inputs to the low 32 bits on every op
 * that would otherwise observe the high bits (arithmetic,
 * shift_right, to_int, of_int, to_string). Unsigned division and
 * remainder are routed through [Long.divideUnsigned] /
 * [remainderUnsigned].
 *
 * For [uint64], we rely on the bit pattern of the JVM long
 * matching the C [uint64_t]; [Long.divideUnsigned] and
 * [parseUnsignedLong] / [toUnsignedString] handle the unsigned
 * semantics.
 *
 * Upstream [uint8] and [uint16] ops are implemented in OCaml on
 * top of boxed [int], so only their [of_string] primitives are
 * externals that need a C-side (hence Java-side) implementation.
 * The _arithmetic_ of [UInt8] / [UInt16] happens entirely in the
 * OCaml [unsigned.ml] — no stubs needed.
 */
public final class Integers {
    private Integers() {}

    // ==== library init (unit -> unit) ==================================

    public static long init(Object ignore) { return 0; }

    // ==== sizeof (unit -> int) =========================================

    /** [sizeof (size_t)] on Linux/x86_64 = 8. */
    public static long size_t_size(Object ignore)     { return 8; }
    /** [sizeof (unsigned short)] = 2. */
    public static long ushort_size(Object ignore)     { return 2; }
    /** [sizeof (unsigned int)] = 4. */
    public static long uint_size(Object ignore)       { return 4; }
    /** [sizeof (unsigned long)] on LP64 = 8. */
    public static long ulong_size(Object ignore)      { return 8; }
    /** [sizeof (unsigned long long)] = 8. */
    public static long ulonglong_size(Object ignore)  { return 8; }

    // Cross-package externs: ctypes_std_view_stubs.ml declares these,
    // but the C symbols live in integers' unsigned_stubs.c. On
    // Linux/x86_64 all three are pointer-sized = 8.
    public static long intptr_t_size(Object ignore)   { return 8; }
    public static long uintptr_t_size(Object ignore)  { return 8; }
    public static long ptrdiff_t_size(Object ignore)  { return 8; }

    // ==== uint8 / uint16 small unsigned of_string ======================
    //
    // Upstream: both are stored as OCaml [int] (tagged), so of_string
    // just parses + masks. Most other uint8/16 ops are OCaml-side.

    public static long uint8_of_string(Object s) {
        long n = Long.parseUnsignedLong((String) s);
        if (n < 0 || n > 0xFFL)
            throw new RuntimeException("int_of_string");
        return n & 0xFFL;
    }

    public static long uint16_of_string(Object s) {
        long n = Long.parseUnsignedLong((String) s);
        if (n < 0 || n > 0xFFFFL)
            throw new RuntimeException("int_of_string");
        return n & 0xFFFFL;
    }

    // ==== uint32 ======================================================

    private static final long U32_MASK = 0xFFFFFFFFL;

    /** [max : unit -> t] — returns [(uint32_t)(-1)] = 0xFFFFFFFF. */
    public static long uint32_max(Object ignore) { return U32_MASK; }

    public static long uint32_add(long a, long b) { return (a + b) & U32_MASK; }
    public static long uint32_sub(long a, long b) { return (a - b) & U32_MASK; }
    public static long uint32_mul(long a, long b) { return (a * b) & U32_MASK; }

    /** [div n d] — upstream raises [Division_by_zero]. */
    public static long uint32_div(long n, long d) {
        if (d == 0) throw new ArithmeticException("/ by zero");
        return (Long.divideUnsigned(n & U32_MASK, d & U32_MASK)) & U32_MASK;
    }

    /** [rem n d] — upstream raises [Division_by_zero]. */
    public static long uint32_rem(long n, long d) {
        if (d == 0) throw new ArithmeticException("/ by zero");
        return (Long.remainderUnsigned(n & U32_MASK, d & U32_MASK)) & U32_MASK;
    }

    public static long uint32_logand(long a, long b) { return (a & b) & U32_MASK; }
    public static long uint32_logor(long a, long b)  { return (a | b) & U32_MASK; }
    public static long uint32_logxor(long a, long b) { return (a ^ b) & U32_MASK; }

    public static long uint32_shift_left(long v, long n) {
        return ((v & U32_MASK) << (n & 31)) & U32_MASK;
    }

    public static long uint32_shift_right(long v, long n) {
        return (v & U32_MASK) >>> (n & 31);
    }

    public static long uint32_of_int(long v) { return v & U32_MASK; }
    public static long uint32_to_int(long v) { return v & U32_MASK; }

    public static long uint32_of_int32(long v) { return v & U32_MASK; }

    /** Upstream's [UInt32.to_int32] binds to [integers_int32_of_uint32]. */
    public static long int32_of_uint32(long v) {
        int i = (int) (v & U32_MASK);
        return (long) i;   // sign-extended int32 in a long slot
    }

    public static long uint32_of_int64(long v) { return v & U32_MASK; }
    public static long uint32_to_int64(long v) { return v & U32_MASK; }

    public static String uint32_to_string(long v) {
        return Long.toUnsignedString(v & U32_MASK);
    }

    public static long uint32_of_string(Object s) {
        long n = Long.parseUnsignedLong((String) s);
        if ((n & ~U32_MASK) != 0)
            throw new RuntimeException("int_of_string");
        return n & U32_MASK;
    }

    // ==== uint64 ======================================================

    /** [max : unit -> t] — returns [(uint64_t)(-1)]. */
    public static long uint64_max(Object ignore) { return -1L; }

    public static long uint64_add(long a, long b) { return a + b; }
    public static long uint64_sub(long a, long b) { return a - b; }
    public static long uint64_mul(long a, long b) { return a * b; }

    public static long uint64_div(long n, long d) {
        if (d == 0) throw new ArithmeticException("/ by zero");
        return Long.divideUnsigned(n, d);
    }

    public static long uint64_rem(long n, long d) {
        if (d == 0) throw new ArithmeticException("/ by zero");
        return Long.remainderUnsigned(n, d);
    }

    public static long uint64_logand(long a, long b) { return a & b; }
    public static long uint64_logor(long a, long b)  { return a | b; }
    public static long uint64_logxor(long a, long b) { return a ^ b; }

    public static long uint64_shift_left(long v, long n)  { return v << (n & 63); }
    public static long uint64_shift_right(long v, long n) { return v >>> (n & 63); }

    public static long uint64_of_int(long v)   { return v; }
    public static long uint64_to_int(long v)   { return v; }
    public static long uint64_of_int64(long v) { return v; }
    public static long uint64_to_int64(long v) { return v; }

    public static String uint64_to_string(long v) {
        return Long.toUnsignedString(v);
    }

    public static long uint64_of_string(Object s) {
        return Long.parseUnsignedLong((String) s);
    }

    // ==== uint32 <-> uint64 cross-conversions ==========================

    /** [UInt64.of_uint32]. Zero-extend to 64 bits. */
    public static long uint64_of_uint32(long v) { return v & U32_MASK; }

    /** [UInt64.to_uint32] — bound as [integers_uint32_of_uint64]. */
    public static long uint32_of_uint64(long v) { return v & U32_MASK; }
}
