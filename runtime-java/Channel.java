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

  public static Channel forDescriptor(int fd) {
    if (fd == 2) return stderr;
    if (fd == 1) return stdout;
    if (fd == 0) return stdin;
    Object s;
    synchronized (FDS) { s = FDS.get(fd); }
    if (s instanceof PrintStream) return new Channel((PrintStream) s);
    if (s instanceof OutputStream) return new Channel(new PrintStream((OutputStream) s));
    if (s instanceof InputStream) return new Channel((InputStream) s);
    return stdout;
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
      int flag = ((Integer) cons.fields[0]).intValue();
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
    return fd;
  }

  public static int closeFd(int fd) throws IOException {
    Object s;
    synchronized (FDS) { s = FDS.remove(fd); }
    if (s instanceof java.io.Closeable) ((java.io.Closeable) s).close();
    return 0;
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
