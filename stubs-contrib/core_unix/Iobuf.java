/**
 * Iobuf C primitives from the [core_kernel.iobuf] / [core.iobuf_unix]
 * libraries.
 *
 * ### Stubbing strategy
 *
 * Most [iobuf_*] primitives are intentionally NOT listed in
 * stubs.json — they fall through to the auto-generated
 * "primitive not implemented" stub which throws
 * [CamlException(Failure)] at the actual call site.
 *
 * The handful below are DELIBERATE STUBS with elided
 * functionality, retained only because typical module-load
 * sequence does feature-detection probes that pattern-match on
 * the C primitive's *return value* rather than catching an
 * exception. Without a successful (well, gracefully-failing)
 * call here, the whole module init aborts before any user code
 * runs. Each stub:
 *   - returns a value that decodes as "feature unavailable"
 *     under the OCaml caller's expected encoding;
 *   - documents the OCaml call site driving the requirement;
 *   - performs no real I/O whatsoever.
 */
public final class Iobuf {
    private Iobuf() {}

    // === DELIBERATE STUB: recvmmsg-availability probe =================
    // [iobuf_unix.ml:115-126] runs a recvmmsg call against fd=-1 at
    // module load to discover whether the syscall is supported. The
    // result is decoded via [Syscall_result.Int.to_result]:
    //   t >= 0 → Ok ...
    //   t  < 0 → Error (Unix_error.of_errno (-t))
    // and pattern-matched [| Error ENOSYS -> Or_error.unimplemented "..."
    //                        | _ -> Ok recvmmsg_assume_fd_is_nonblocking].
    // Returning -38 (Linux ENOSYS) lets the probe complete with
    // [Or_error.unimplemented]; module init proceeds. Real callers
    // that try to actually use the wrapper later will hit the
    // [Or_error.unimplemented] check and bail cleanly.
    //
    // The [iobuf_recvmmsg_ctx] companion returns an opaque [Long 0]
    // since the probe immediately passes it back to the
    // assume_fd_is_nonblocking call which we also stub.

    /** [iobuf_recvmmsg_ctx]: opaque context handle. Never read. */
    public static Object iobuf_recvmmsg_ctx(Object iobufs) {
        return Long.valueOf(0L);
    }

    /** [iobuf_recvmmsg_assume_fd_is_nonblocking_stub]: returns the
     *  [Syscall_result.Int.t] encoding of [Error ENOSYS]
     *  (= -Linux_ENOSYS_code = -38). Performs no syscall. */
    public static long iobuf_recvmmsg_assume_fd_is_nonblocking(
            Object fd, Object iobufs, Object ctx) {
        return -38L;
    }
}
