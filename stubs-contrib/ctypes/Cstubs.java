/**
 * Miscellaneous [ctypes] C primitives spread across:
 *
 *   - [src/ctypes/ctypes_memory_stubs.c] — raw-pointer allocation
 *     and read/write. [ctypes_allocate] / [block_address] / [read]
 *     / [write] / [read_pointer] / [write_pointer] /
 *     [string_of_pointer] / [memcpy] / [use].
 *   - [src/ctypes/ctypes_roots.c] — GC-root bookkeeping for
 *     closure-safe FFI callbacks. [caml_roots_create / _get /
 *     _set / _release].
 *   - [src/ctypes/ctypes_bigarray_stubs.c] — bigarray helpers.
 *     [ctypes_bigarray_view], [ctypes_bigarray_address].
 *   - [src/ctypes/ctypes_std_view_stubs.c] — misc string/pointer
 *     view coercions.
 *
 * All of these are referenced during init by ctypes-using modules
 * to build type descriptors, without ever being invoked by real
 * foreign calls on our workloads. Stubbing as [0] / empty blocks
 * is sufficient for init; callers that actually try to read or
 * write through a returned pointer will see [0] behaviour and
 * fail gracefully rather than segfault.
 */
public final class Cstubs {
    private Cstubs() {}

    private static final Object ZERO = Long.valueOf(0L);

    // ==== Memory (ctypes_memory_stubs.c) ==============================

    /** [allocate n count] — return a managed buffer of [n*count] bytes.
     *  We return [0]; callers that dereference will get [0] reads. */
    public static long allocate(long n, long count) { return 0; }

    public static long memcpy(Object dst, long doff, Object src, long soff,
                              long len) {
        return 0;
    }

    public static Object read(Object prim, Object fat) { return ZERO; }
    public static long write(Object prim, Object v, Object fat) { return 0; }

    public static long read_pointer(Object fat)                 { return 0; }
    public static long write_pointer(Object p, Object fat)      { return 0; }

    public static String string_of_pointer(Object p) { return "<ptr>"; }

    /** [use v] — a no-op used to pin a value against GC. */
    public static long use(Object v) { return 0; }

    public static String string_of_prim(Object prim, Object fat) { return ""; }

    public static String string_of_array(Object ba) { return ""; }

    public static String string_of_cstring(Object p) { return ""; }

    public static Object cstring_of_string(Object s) { return s; }

    // ==== Roots (ctypes_roots.c) ======================================

    /** Upstream: allocate a fresh GC-rooted int→value map. Stub
     *  returns an opaque [0]. Callers use [set] / [get] /
     *  [release] against it. */
    public static long caml_roots_create(Object ignore) { return 0; }

    public static long caml_roots_set(long h, long idx, Object v) { return 0; }
    public static Object caml_roots_get(long h, long idx)         { return ZERO; }
    public static long caml_roots_release(long h)                 { return 0; }

    // ==== Bigarray (ctypes_bigarray_stubs.c) ==========================

    /** [bigarray_view kind dims ptr typ] — create an OCaml bigarray
     *  viewing a raw C buffer. Stub returns a 0-element BigArray
     *  (safe placeholder; callers that actually index will throw). */
    public static Object bigarray_view(Object kind, Object dims,
                                       Object ptr, Object typ) {
        return BigArray.allocBigstring(0L);
    }

    public static long bigarray_address(Object ba) { return 0; }
}
