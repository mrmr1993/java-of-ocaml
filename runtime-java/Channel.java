import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.Map;

// OCaml channel: wraps either an output [PrintStream] (for
// print_endline / Printf / ...) or an input [InputStream] with a
// byte-level buffer big enough for caml_ml_input_scan_line's
// newline-search protocol. The runtime also maintains a process-
// wide [FDS] map so caml_sys_open can hand back an int FD that
// caml_ml_open_descriptor_{in,out} later turns into a Channel.
public class Channel {
  public static final Channel stdout = new Channel(System.out);
  public static final Channel stderr = new Channel(System.err);
  public static final Channel stdin = new Channel(System.in);

  // OCaml's predefined [End_of_file] exception descriptor. Populated
  // by Main after globals init from GLOBALS[4]; Channel throws a
  // [CamlException] wrapping this object on EOF so that OCaml's
  // [try … with End_of_file] catches it via the descriptor-identity
  // test the compiler emits.
  public static Object endOfFileExn;

  private final PrintStream out;
  private final InputStream in;

  // Byte-level buffer for input. Holds up to BUF_SIZE bytes; curr
  // is the next byte to consume, end is the number of valid bytes.
  private static final int BUF_SIZE = 65536;
  private final byte[] buf;
  private int bufCurr;
  private int bufEnd;

  // Process-wide FD registry. Used by caml_sys_open to allocate a
  // small integer that caml_ml_open_descriptor_in/out can turn into
  // a Channel.
  private static final Map<Integer, Object> FDS = new HashMap<>();
  private static int nextFd = 3;

  // [CHANNELS] memoises [forDescriptor] so repeated calls on the
  // same fd return the same [Channel] instance. This matters for
  // [popen_processes]-style hashtables in OCaml stdlib that key by
  // channel identity: [Hashtbl.add popen_processes (Process_in
  // ic) pid] at [open_process_in] time, then [Hashtbl.find] at
  // [close_process_in] time. Fresh [new Channel] per call would
  // miss the hash. Separate from [FDS] because we want Channel
  // caching even for stdin/stdout/stderr-style shared instances.
  private static final Map<Integer, Channel> CHANNELS = new HashMap<>();

  /** A never-yielding InputStream — returns -1 (EOF) on every
   *  read. Used to back fake pipe fds so [input_line] on them
   *  raises [End_of_file] (which the test binary-style init code handles
   *  with [may_eof]) instead of a JVM-level IOException.
   *  Named inner class to keep the runtime class-bytes bundle
   *  self-contained without an anonymous [Channel$1]. */
  private static final class EmptyInputStream extends InputStream {
    @Override public int read() { return -1; }
  }
  private static InputStream emptyInputStream() {
    return new EmptyInputStream();
  }

  /** Allocate a fresh unique fd. Used by stubs like [pipeStub]
   *  that need unique ints so downstream hashtable-based dispatch
   *  (e.g. [popen_processes]) doesn't alias entries. */
  public static int allocFd() {
    synchronized (FDS) {
      int fd = nextFd++;
      // Register a benign null stream so [forDescriptor] finds
      // *something* and falls back to [stdout] (harmless for a
      // fake pipe that won't be read/written).
      FDS.put(fd, null);
      return fd;
    }
  }

  public Channel(PrintStream s) {
    this.out = s;
    this.in = null;
    this.buf = null;
    this.bufCurr = 0;
    this.bufEnd = 0;
  }

  public Channel(InputStream s) {
    this.out = null;
    this.in = s;
    this.buf = new byte[BUF_SIZE];
    this.bufCurr = 0;
    this.bufEnd = 0;
  }

  /**
   * Coerce an arbitrary OCaml value to a [Channel]. Either the
   * value already IS a [Channel] (the normal case — [stdlib]'s
   * [open_descriptor_in] wraps a bare fd as a [Channel] before
   * it flows into user code) or it's a boxed int fd (a common
   * leak from Unix / Core pathways that round-trip through
   * [int] before reaching an OCaml [in_channel]-typed slot).
   * The pure-[checkcast Channel] we used to emit at every
   * channel-consuming primitive call exploded on the second
   * case. Routing through here once keeps the emit site short
   * and handles both.
   */
  public static Channel asChannel(Object o) {
    if (o instanceof Channel) return (Channel) o;
    if (o instanceof Long) return forDescriptor((int) ((Long) o).longValue());
    if (o instanceof Integer) return forDescriptor(((Integer) o).intValue());
    return (Channel) o; // let the ClassCast fire with its usual message
  }

  public static Channel forDescriptor(int fd) {
    if (fd == 2) return stderr;
    if (fd == 1) return stdout;
    if (fd == 0) return stdin;
    synchronized (CHANNELS) {
      Channel cached = CHANNELS.get(fd);
      if (cached != null) return cached;
    }
    Object s;
    synchronized (FDS) { s = FDS.get(fd); }
    if (TRACE_FDS) System.err.println("[fd] forDescriptor fd=" + fd
        + " stream=" + (s == null ? "null" : s.getClass().getSimpleName()));
    Channel c;
    if (s instanceof PrintStream) c = new Channel((PrintStream) s);
    else if (s instanceof OutputStream)
      c = new Channel(new PrintStream((OutputStream) s));
    else if (s instanceof InputStream) c = new Channel((InputStream) s);
    else c = new Channel(emptyInputStream());  // fake/empty channel
    synchronized (CHANNELS) { CHANNELS.put(fd, c); }
    return c;
  }

  public static int openFile(String path, Object flagsList, int perm) throws IOException {
    // OCaml open_flag indices:
    //   0=Open_rdonly, 1=Open_wronly, 2=Open_append, 3=Open_creat,
    //   4=Open_trunc,  5=Open_excl,   6=Open_binary, 7=Open_text,
    //   8=Open_nonblock.
    int flags = 0;
    Object node = flagsList;
    while (node instanceof Block) {
      Block cons = (Block) node;
      int flag = (int) Block.asLong(cons.fields[0]);
      flags |= (1 << flag);
      node = cons.fields[1];
    }
    boolean readOnly = (flags & (1 << 0)) != 0;
    boolean append   = (flags & (1 << 2)) != 0;
    int fd;
    synchronized (FDS) {
      fd = nextFd++;
      Object stream;
      if (readOnly) {
        stream = new BufferedInputStream(new FileInputStream(path));
      } else {
        stream = new FileOutputStream(path, append);
      }
      FDS.put(fd, stream);
    }
    traceFd("openFile", fd, path);
    return fd;
  }

  /** Look up the underlying stream for an fd in the registry.
   *  Returns null if the fd isn't registered. */
  public static Object fdGetStream(int fd) {
    synchronized (FDS) { return FDS.get(fd); }
  }

  /** True if [fd] has bytes immediately readable (or is at EOF /
   *  not-an-input-stream — both surface as "no read will block",
   *  which is what select wants to report). */
  public static boolean fdHasBytesReadable(int fd) throws IOException {
    Object s;
    synchronized (FDS) { s = FDS.get(fd); }
    if (!(s instanceof InputStream)) return false;
    return ((InputStream) s).available() > 0;
  }

  public static int closeFd(int fd) throws IOException {
    Object s;
    synchronized (FDS) { s = FDS.remove(fd); }
    if (s instanceof java.io.Closeable) ((java.io.Closeable) s).close();
    return 0;
  }

  /** [Unix.openfile path flags perm] — Unix-style fd open. Flags is
   *  a list of [open_flag] variant indices:
   *    0=O_RDONLY, 1=O_WRONLY, 2=O_RDWR, 3=O_NONBLOCK, 4=O_APPEND,
   *    5=O_CREAT,  6=O_TRUNC,  7=O_EXCL, 8=O_NOCTTY,   9=O_DSYNC,
   *   10=O_SYNC,  11=O_RSYNC, 12=O_SHARE_DELETE, 13=O_CLOEXEC,
   *   14=O_KEEPEXEC.
   *  Returns an int fd registered in [FDS]. */
  /** [Unix.pipe ()] - returns [|read_fd, write_fd|] for an in-process
   *  pipe. java.nio.channels.Pipe gives us a Source/Sink pair we can
   *  register under fresh int fds. */
  public static int[] unixPipe() throws IOException {
    java.nio.channels.Pipe p = java.nio.channels.Pipe.open();
    int rfd, wfd;
    synchronized (FDS) {
      rfd = nextFd++;
      wfd = nextFd++;
      FDS.put(rfd, java.nio.channels.Channels.newInputStream(p.source()));
      FDS.put(wfd, java.nio.channels.Channels.newOutputStream(p.sink()));
    }
    traceFd("pipe-rd", rfd, "");
    traceFd("pipe-wr", wfd, "");
    return new int[] { rfd, wfd };
  }

  /** [Unix.write fd buf pos len]. Looks up [fd] in [FDS]; if it's
   *  a writable stream, writes the slice. Returns bytes written. */
  public static int unixWrite(int fd, Object bufObj, int pos, int len) throws IOException {
    Object stream;
    synchronized (FDS) { stream = FDS.get(fd); }
    if (TRACE_FDS) System.err.println("[fd] unixWrite fd=" + fd + " len=" + len
        + " stream=" + (stream == null ? "null" : stream.getClass().getSimpleName()));
    if (stream == null) throw new IOException("bad fd " + fd);
    String s;
    if (bufObj instanceof Bytes) s = ((Bytes) bufObj).sb.toString();
    else                          s = (String) bufObj;
    byte[] bytes = new byte[len];
    for (int i = 0; i < len; i++) bytes[i] = (byte) s.charAt(pos + i);
    if (stream instanceof OutputStream) {
      ((OutputStream) stream).write(bytes);
      ((OutputStream) stream).flush();
      return len;
    }
    throw new IOException("fd " + fd + " is not writable");
  }

  /** [Unix.read fd buf pos len]. Looks up [fd] in [FDS]; reads up
   *  to [len] bytes into the buffer. Returns bytes read. Throws
   *  IOException if no data available (caller should map to EAGAIN
   *  for non-blocking semantics). */
  public static int unixRead(int fd, Object bufObj, int pos, int len) throws IOException {
    Object stream;
    synchronized (FDS) { stream = FDS.get(fd); }
    if (stream == null) throw new IOException("bad fd " + fd);
    if (!(stream instanceof InputStream)) {
      throw new IOException("fd " + fd + " is not readable");
    }
    InputStream in = (InputStream) stream;
    byte[] tmp = new byte[len];
    int n = in.read(tmp, 0, len);
    if (n < 0) return 0;        // EOF
    if (n == 0) return 0;
    Bytes b = (Bytes) bufObj;
    for (int i = 0; i < n; i++) b.sb.setCharAt(pos + i, (char) (tmp[i] & 0xFF));
    return n;
  }

  /** [Unix.read] non-blocking variant: returns -1 to signal "no data
   *  ready, EAGAIN" without blocking. Caller should map to a
   *  Unix_error(EAGAIN, ...) raise. */
  public static int unixReadNonblocking(int fd, Object bufObj, int pos, int len)
      throws IOException {
    Object stream;
    synchronized (FDS) { stream = FDS.get(fd); }
    if (stream == null) throw new IOException("bad fd " + fd);
    if (!(stream instanceof InputStream)) {
      throw new IOException("fd " + fd + " is not readable");
    }
    InputStream in = (InputStream) stream;
    int avail = in.available();
    if (avail <= 0) return -1;
    int toRead = Math.min(len, avail);
    byte[] tmp = new byte[toRead];
    int n = in.read(tmp, 0, toRead);
    if (n < 0) return 0;
    if (n == 0) return -1;
    Bytes b = (Bytes) bufObj;
    for (int i = 0; i < n; i++) b.sb.setCharAt(pos + i, (char) (tmp[i] & 0xFF));
    return n;
  }

  private static final boolean TRACE_FDS =
      System.getenv("JAVA_OF_OCAML_TRACE_FDS") != null;
  private static void traceFd(String op, int fd, String path) {
    if (TRACE_FDS) System.err.println("[fd] " + op + " fd=" + fd + " " + path);
  }

  public static int unixOpen(String path, Object flagsList, int perm) throws IOException {
    int flags = 0;
    Object node = flagsList;
    while (node instanceof Block) {
      Block cons = (Block) node;
      flags |= (1 << (int) Block.asLong(cons.fields[0]));
      node = cons.fields[1];
    }
    boolean wantWrite  = (flags & ((1 << 1) | (1 << 2))) != 0;
    boolean wantRead   = (flags & ((1 << 0) | (1 << 2))) != 0;
    boolean append     = (flags & (1 << 4)) != 0;
    boolean create     = (flags & (1 << 5)) != 0;
    boolean truncate   = (flags & (1 << 6)) != 0;
    java.io.File f = new java.io.File(path);
    if (create && !f.exists()) f.createNewFile();
    int fd;
    synchronized (FDS) {
      fd = nextFd++;
      Object stream;
      if (wantWrite) {
        stream = new FileOutputStream(f, append && !truncate);
      } else if (wantRead) {
        stream = new BufferedInputStream(new FileInputStream(f));
      } else {
        // No read, no write — open just to test existence. Wrap an
        // empty input stream so subsequent reads behave like EOF.
        stream = emptyInputStream();
      }
      FDS.put(fd, stream);
    }
    traceFd("unixOpen", fd, path);
    return fd;
  }

  public int inputChar() throws IOException {
    if (in == null) throw new IOException("not an input channel");
    if (bufCurr >= bufEnd) {
      int n = in.read(buf);
      if (n <= 0) throw new CamlException(endOfFileExn);
      bufEnd = n;
      bufCurr = 0;
    }
    return buf[bufCurr++] & 0xFF;
  }

  public int input(Bytes dst, int ofs, int len) throws IOException {
    if (in == null) throw new IOException("not an input channel");
    int copied = 0;
    if (bufCurr < bufEnd) {
      int n = Math.min(len, bufEnd - bufCurr);
      for (int i = 0; i < n; i++) dst.set(ofs + i, buf[bufCurr + i] & 0xFF);
      bufCurr += n;
      copied = n;
    }
    if (copied < len) {
      byte[] tmp = new byte[len - copied];
      int n = in.read(tmp, 0, tmp.length);
      if (n > 0) {
        for (int i = 0; i < n; i++) dst.set(ofs + copied + i, tmp[i] & 0xFF);
        copied += n;
      }
    }
    return copied;
  }

  // Scan from bufCurr for a newline. Returns the count-including-
  // newline if one is found in the buffer; returns -(buffered count)
  // if EOF or buffer-full with no newline. Refills the buffer by
  // shifting unread bytes left when necessary.
  public int inputScanLine() throws IOException {
    if (in == null) throw new IOException("not an input channel");
    while (true) {
      for (int p = bufCurr; p < bufEnd; p++) {
        if (buf[p] == '\n') return (p - bufCurr) + 1;
      }
      int leftover = bufEnd - bufCurr;
      if (bufCurr > 0) {
        System.arraycopy(buf, bufCurr, buf, 0, leftover);
        bufCurr = 0;
        bufEnd = leftover;
      }
      if (bufEnd >= buf.length) return -leftover;
      int n = in.read(buf, bufEnd, buf.length - bufEnd);
      if (n <= 0) return -leftover;
      bufEnd += n;
    }
  }

  // Read a big-endian 32-bit int from the stream. [caml_ml_input_int]
  // targets this shape (Stdlib's [input_binary_int]).
  public int inputInt() throws IOException {
    int b0 = inputChar() & 0xFF;
    int b1 = inputChar() & 0xFF;
    int b2 = inputChar() & 0xFF;
    int b3 = inputChar() & 0xFF;
    return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
  }

  public int outputInt(int v) {
    if (out == null) return 0;
    out.write((v >> 24) & 0xFF);
    out.write((v >> 16) & 0xFF);
    out.write((v >> 8) & 0xFF);
    out.write(v & 0xFF);
    return 0;
  }

  // MD5 of the next [len] bytes (or to EOF if len < 0). Drains the
  // buffered window first, then pulls from the stream.
  public String md5(int len) throws IOException {
    if (in == null) throw new IOException("not an input channel");
    try {
      java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
      byte[] chunk = new byte[4096];
      int remaining = len < 0 ? Integer.MAX_VALUE : len;
      while (remaining > 0) {
        if (bufCurr < bufEnd) {
          int take = Math.min(bufEnd - bufCurr, remaining);
          md.update(buf, bufCurr, take);
          bufCurr += take;
          remaining -= take;
        } else {
          int want = Math.min(chunk.length, remaining);
          int n = in.read(chunk, 0, want);
          if (n <= 0) break;
          md.update(chunk, 0, n);
          remaining -= n;
        }
      }
      byte[] digest = md.digest();
      char[] chars = new char[digest.length];
      for (int i = 0; i < digest.length; i++) chars[i] = (char) (digest[i] & 0xFF);
      return new String(chars);
    } catch (java.security.NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }

  public int close() throws IOException {
    if (in != null) in.close();
    if (out != null && out != System.out && out != System.err) out.close();
    return 0;
  }

  public void output(String buf, int ofs, int len) {
    if (out == null) return;
    out.print(buf.substring(ofs, ofs + len));
  }

  public void outputChar(int c) {
    if (out == null) return;
    out.print((char) c);
  }

  public void flush() {
    if (out == null) return;
    out.flush();
  }
}
