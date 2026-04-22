/**
 * Zero-returning stubs for ~200 OCaml C primitives we don't
 * actually implement — unix / core_unix / core_linux / bigstring /
 * iobuf syscalls, init hooks, and blit operations. They're
 * referenced during module init but almost never called at runtime
 * on paths that matter; returning [Long(0)] is a successful
 * syscall result in Core's conventions (0 bytes written / read,
 * errno 0, unit return) and matches what C stubs traditionally
 * produce for these shapes.
 *
 * Overloaded by arity: manifest entries use the shorthand
 * [Class.method] form, and the compiler builds a matching
 * [(Object...)Object] descriptor from the call site, picking the
 * right overload automatically.
 */
public final class ZeroStubs {
    private ZeroStubs() {}

    private static final Object ZERO = Long.valueOf(0L);

    public static Object zero()                                       { return ZERO; }
    public static Object zero(Object a)                                { return ZERO; }
    public static Object zero(Object a, Object b)                      { return ZERO; }
    public static Object zero(Object a, Object b, Object c)            { return ZERO; }
    public static Object zero(Object a, Object b, Object c, Object d)  { return ZERO; }
    public static Object zero(Object a, Object b, Object c, Object d, Object e) {
        return ZERO;
    }
    public static Object zero(Object a, Object b, Object c, Object d, Object e,
                              Object f) {
        return ZERO;
    }
}
