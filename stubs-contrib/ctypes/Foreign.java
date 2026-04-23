/**
 * Stubs for the [ctypes-foreign] opam package — [libffi] bindings
 * ([Ctypes_ffi_stubs], [Dl], ffi type constructors). Equivalent
 * to [ctypes_ffi_stubs.ml] + [ffi_call_stubs.c] upstream.
 *
 * js_of_ocaml **forbids** [ctypes.foreign] entirely on JS targets
 * — dynamic FFI to native libraries is meaningless in a browser /
 * JVM. We follow the same stance in spirit but stub each primitive
 * as a no-op rather than refusing to compile, so programs that
 * merely reference [ctypes.foreign] in a platform-gated code path
 * (e.g. mac-only [_NSGetExecutablePath] binding) initialise
 * cleanly and only fail if a call actually reaches libffi.
 *
 * Every function here returns [0] / empty / identity-shaped
 * placeholder. If a compiled program ever reaches
 * [Foreign.foreign "..."] via these stubs and invokes the result,
 * the native call fails at "primitive C_CALL into zero-stubbed
 * callspec" semantics (it doesn't actually dereference anything,
 * so the program will error gracefully rather than segfault).
 */
public final class Foreign {
    private Foreign() {}

    private static final Object ZERO = Long.valueOf(0L);

    // ==== libffi type constructors =====================================

    // The ctypes OCaml wrapper compares returned ffitype pointers
    // against [Ctypes_ptr.Raw.null] (= 0) and raises
    // "libffi does not support passing …" on null. Return 1 as a
    // non-null placeholder; we never actually dereference it
    // because real libffi calls don't happen in this backend.
    public static long primitive_ffitype(Object prim) { return 1; }
    public static long pointer_ffitype(Object ignore) { return 1; }
    public static long void_ffitype(Object ignore)     { return 1; }

    public static long allocate_struct_ffitype(long n)    { return 1; }
    public static long struct_ffitype_set_argument(Object s, long i, Object t) {
        return 0;
    }
    public static long complete_structspec(Object s) { return 0; }
    public static long block_address(Object s)       { return 0; }

    // ==== libffi call-specification building ==========================

    public static long allocate_callspec(boolean checkErrno, boolean runtimeLock,
                                         boolean threadReg) {
        return 0;
    }
    public static long add_argument(Object cs, Object t)             { return 0; }
    public static long prep_callspec(Object cs, long abi, Object rt) { return 0; }

    /** [ctypes_call name fnptr cs ret_writer arg_readers] — invoke a
     *  foreign function. We can't actually dispatch, so return a
     *  zero-shaped result; callers that depend on a real return
     *  value will observe [0] / [null]. */
    public static Object call(Object name, Object fnptr, Object cs,
                              Object retW, Object argsR) {
        return ZERO;
    }

    // ==== closure callbacks (for OCaml functions passed as C callbacks)

    public static long set_closure_callback(Object retrieve) { return 0; }
    public static long setup_thread_registration(Object ignore) { return 0; }
    public static long make_function_pointer(Object cs, long key) { return 0; }
    public static long raw_address_of_function_pointer(Object fnptr) { return 0; }

    // ==== Dl (dynamic loader wrappers) ================================

    /** [ctypes_dlopen filename flags] — returns an opaque handle. */
    public static long dlopen(Object filename, long flags) { return 0; }
    public static long dlclose(long handle)                { return 0; }
    public static String dlerror(Object ignore)            { return ""; }
    public static long dlsym(long handle, Object sym)      { return 0; }
    public static long resolve_dl_flag(long flag)          { return 0; }
}
