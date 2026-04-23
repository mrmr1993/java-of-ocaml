/**
 * Iobuf C primitives from the [core_kernel.iobuf] / [core.iobuf_unix]
 * libraries. A large test binary references only three at init
 * time, all of which can stub as no-ops returning [Long 0]:
 *
 *   [iobuf_recvmmsg_assume_fd_is_nonblocking_stub] — batched
 *     [recvmmsg] wrapper; returns [0] (number of messages received).
 *   [iobuf_recvmmsg_ctx] — allocates the [recvmmsg] context struct
 *     used by the above; we return [Long 0] since it's only used
 *     as an opaque handle that flows back into the [_stub] call
 *     and never gets dereferenced in our stubbed path.
 *   [iobuf_unsafe_pokef_double_bytecode] — the OCaml-bytecode
 *     entry point for a native [unsafe_pokef_double] helper;
 *     writes a double into an iobuf. Returns [Long 0] (unit).
 *
 * Upstream C stubs would: fill in a [struct mmsghdr] array via
 * [recvmmsg(2)] (Linux-only syscall), copy to managed buffers,
 * return the count. On the JVM the full implementation would
 * need a [java.nio.channels.DatagramChannel] + manual message
 * framing — out of scope for a stub backend.
 */
public final class Iobuf {
    private Iobuf() {}

}
