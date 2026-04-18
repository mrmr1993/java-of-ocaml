import java.io.PrintStream;

public class Channel {
  public static final Channel stdout = new Channel(System.out);
  public static final Channel stderr = new Channel(System.err);

  private final PrintStream stream;

  public Channel(PrintStream s) {
    this.stream = s;
  }

  public static Channel forDescriptor(int fd) {
    if (fd == 2) return stderr;
    return stdout;
  }

  public void output(String buf, int ofs, int len) {
    if (stream == null) return;
    stream.print(buf.substring(ofs, ofs + len));
  }

  public void outputChar(int c) {
    if (stream == null) return;
    stream.print((char) c);
  }

  public void flush() {
    if (stream == null) return;
    stream.flush();
  }
}
