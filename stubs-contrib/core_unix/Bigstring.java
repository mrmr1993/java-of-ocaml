/**
 * Bigstring C primitives from [base_bigstring], [core_kernel.
 * bigstring], and [core.bigstring_unix]. Upstream implements each
 * as a thin wrapper around [read(2)] / [write(2)] / [sendmsg(2)]
 * / [memcpy(3)] on the raw [Bigarray.Array1] buffer.
 *
 * ### Representation
 *
 * An OCaml [Bigstring.t] is a 1-D [Bigarray.Array1.t] of chars.
 * Our runtime represents this as a [BigArray] class (built-in).
 * [bigstring_alloc] creates one of those via
 * [BigArray.allocBigstring].
 *
 * ### Stubbing strategy
 *
 * Only primitives with a real implementation, or no-op
 * registration calls that genuinely run unconditionally at module
 * load (currently [bigstring_init_stub]), are listed here. Every
 * other [bigstring_*_stub] is intentionally left out of the
 * manifest so the auto-generated "primitive not implemented" stub
 * fires at the first real call site. That keeps us honest about
 * what's stubbed for shape vs. what's actually implemented.
 */
public final class Bigstring {
    private Bigstring() {}

    /**
     * [bigstring_alloc pos len]. Upstream:
     * [caml_ba_alloc_dims(CAML_BA_UINT8 | CAML_BA_C_LAYOUT, 1, NULL, len)].
     * Ignores [pos]; allocates a 1-D char bigarray of size [len].
     */
    public static Object bigstring_alloc(Object pos, long len) {
        return BigArray.allocBigstring(len);
    }

    // ==== blit primitives ============================================
    // Without these, [Bigstring.of_string] silently produces a
    // zero-filled bigstring and downstream [bin_io] reads garbage
    // — which surfaces as "version read 0 does not match expected

    private static int byteAt(BigArray ba, int i) {
        return (int) Block.asLong(ba.data[i]) & 0xFF;
    }

    private static void setByte(BigArray ba, int i, int b) {
        ba.data[i] = Long.valueOf(b & 0xFF);
    }

    /** [bigstring_blit_string_bigstring_stub]: string → bigstring. */
    public static long blitStringToBigstring(Object src, long srcPos,
                                             Object dst, long dstPos,
                                             long len) {
        String s = (String) src;
        BigArray d = (BigArray) dst;
        int n = (int) len, so = (int) srcPos, dop = (int) dstPos;
        for (int i = 0; i < n; i++) setByte(d, dop + i, s.charAt(so + i));
        return 0;
    }

    /** [bigstring_blit_bytes_bigstring_stub]: Bytes → bigstring. */
    public static long blitBytesToBigstring(Object src, long srcPos,
                                            Object dst, long dstPos,
                                            long len) {
        BigArray d = (BigArray) dst;
        int n = (int) len, so = (int) srcPos, dop = (int) dstPos;
        if (src instanceof Bytes) {
            Bytes s = (Bytes) src;
            for (int i = 0; i < n; i++) setByte(d, dop + i, s.sb.charAt(so + i));
        } else {
            // Caller may pass a string via [Bytes.unsafe_of_string].
            String s = (String) src;
            for (int i = 0; i < n; i++) setByte(d, dop + i, s.charAt(so + i));
        }
        return 0;
    }

    /** [bigstring_blit_bigstring_bytes_stub]: bigstring → Bytes. */
    public static long blitBigstringToBytes(Object src, long srcPos,
                                            Object dst, long dstPos,
                                            long len) {
        BigArray s = (BigArray) src;
        Bytes d = (Bytes) dst;
        int n = (int) len, so = (int) srcPos, dop = (int) dstPos;
        for (int i = 0; i < n; i++) d.sb.setCharAt(dop + i, (char) byteAt(s, so + i));
        return 0;
    }

    /** [bigstring_blit_stub]: bigstring → bigstring (memmove semantics). */
    public static long blitBigstringToBigstring(Object src, long srcPos,
                                                Object dst, long dstPos,
                                                long len) {
        BigArray s = (BigArray) src;
        BigArray d = (BigArray) dst;
        int n = (int) len, so = (int) srcPos, dop = (int) dstPos;
        if (s == d && dop > so) {
            for (int i = n - 1; i >= 0; i--) setByte(d, dop + i, byteAt(s, so + i));
        } else {
            for (int i = 0; i < n; i++) setByte(d, dop + i, byteAt(s, so + i));
        }
        return 0;
    }

    /** [bigstring_memcmp_stub]: bytewise comparison; first non-zero
     *  difference (sign-significant), or 0 if equal. */
    public static long memcmp(Object a, long aPos, Object b, long bPos,
                              long len) {
        BigArray ba = (BigArray) a;
        BigArray bb = (BigArray) b;
        int n = (int) len, ao = (int) aPos, bo = (int) bPos;
        for (int i = 0; i < n; i++) {
            int d = byteAt(ba, ao + i) - byteAt(bb, bo + i);
            if (d != 0) return d;
        }
        return 0;
    }

    /** [bigstring_memset_stub]: fill [len] bytes starting at [pos] with [c]. */
    public static long memset(Object dst, long pos, long len, long c) {
        BigArray d = (BigArray) dst;
        int n = (int) len, po = (int) pos, cv = (int) c;
        for (int i = 0; i < n; i++) setByte(d, po + i, cv);
        return 0;
    }

    /** [bigstring_init_stub]: called once at [Bigstring_unix] module
     *  load right after [Callback.register_exception] for the Bigstring
     *  IO exceptions. Upstream registers signal handlers; nothing for
     *  us to do. Listed explicitly so it doesn't get caught by the
     *  general "primitive not implemented" throw. */
    public static long init_stub(Object unit) { return 0; }

    /** [bigstring_is_mmapped_stub bstr]: always false — our BigArray
     *  isn't backed by a real mmap. */
    public static long is_mmapped_stub(Object bstr) { return 0; }

    /** [bigstring_destroy_stub bstr]: free the underlying buffer.
     *  No-op — JVM GC handles BigArray collection. */
    public static long destroy_stub(Object bstr) { return 0; }

    /** [bigstring_writev_stub fd iovecs count]: scatter-gather write
     *  of [count] iovecs (each is a record [{buf; pos; len}]) to fd.
     *  Async's Writer uses this to flush its buffered iovec chain.
     *  Returns total bytes written. */
    public static long writev_stub(long fd, Object iovecs, long count) {
        try {
            Object stream = Channel.fdGetStream((int) fd);
            if (!(stream instanceof java.io.OutputStream)) {
                throw new java.io.IOException("fd " + fd + " not writable");
            }
            java.io.OutputStream out = (java.io.OutputStream) stream;
            Block iov = (Block) iovecs;
            int n = (int) count;
            long total = 0;
            for (int i = 0; i < n; i++) {
                Block rec = (Block) iov.fields[i];
                BigArray buf = (BigArray) rec.fields[0];
                int pos = (int) Block.asLong(rec.fields[1]);
                int len = (int) Block.asLong(rec.fields[2]);
                byte[] tmp = new byte[len];
                for (int j = 0; j < len; j++) {
                    tmp[j] = (byte) (Block.asLong(buf.data[pos + j]) & 0xFF);
                }
                out.write(tmp);
                total += len;
            }
            out.flush();
            return total;
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(5L, "writev", "");
        }
    }

    /** [bigstring_write_assume_fd_is_nonblocking_stub fd pos len bstr]:
     *  Async's Writer uses this to flush its accumulated Bigstring
     *  buffer to an fd. We delegate to the same Channel registry used
     *  by [Unix.write]: pull bytes out of the BigArray, push them
     *  through the OutputStream wrapping the fd. Returns bytes written. */
    public static long write_nonblocking(long fd, long pos, long len, Object bstr) {
        try {
            int n = (int) len;
            int p = (int) pos;
            BigArray ba = (BigArray) bstr;
            byte[] tmp = new byte[n];
            for (int i = 0; i < n; i++) {
                tmp[i] = (byte) (Block.asLong(ba.data[p + i]) & 0xFF);
            }
            Object stream = Channel.fdGetStream((int) fd);
            if (!(stream instanceof java.io.OutputStream)) {
                throw new java.io.IOException("fd " + fd + " not writable");
            }
            ((java.io.OutputStream) stream).write(tmp);
            ((java.io.OutputStream) stream).flush();
            return n;
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(5L, "write", "");
        }
    }

    /** [bigstring_read_assume_fd_is_nonblocking_stub fd pos len bstr]:
     *  read up to len bytes from fd into bstr at pos. Returns a
     *  Syscall_result.Int.t — encoded as the number of bytes read
     *  (>= 0) or -errno (< 0). Returning 0 on EOF, -EAGAIN when
     *  no data ready (Async treats negative-EAGAIN as "retry next
     *  cycle"). */
    public static long read_nonblocking(long fd, long pos, long len, Object bstr) {
        try {
            int n = (int) len;
            int p = (int) pos;
            Object stream = Channel.fdGetStream((int) fd);
            if (!(stream instanceof java.io.InputStream)) {
                return -3L;  // EBADF
            }
            java.io.InputStream in = (java.io.InputStream) stream;
            int avail = in.available();
            if (avail <= 0) return -11L;  // -EAGAIN (Linux errno 11)
            int toRead = Math.min(n, avail);
            byte[] tmp = new byte[toRead];
            int r = in.read(tmp, 0, toRead);
            if (r <= 0) return -11L;
            BigArray ba = (BigArray) bstr;
            for (int i = 0; i < r; i++) {
                ba.data[p + i] = Long.valueOf(tmp[i] & 0xFFL);
            }
            return r;
        } catch (java.io.IOException e) {
            return -5L;  // -EIO
        }
    }
}
