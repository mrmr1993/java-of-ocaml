public class Bytes {
  public final StringBuilder sb;

  public Bytes(int n) {
    this.sb = new StringBuilder(n);
    for (int i = 0; i < n; i++) this.sb.append('\0');
  }

  public Bytes(String s) {
    this.sb = new StringBuilder(s);
  }

  public static Bytes ofString(String s) {
    return new Bytes(s);
  }

  public String asString() {
    return sb.toString();
  }

  public int length() {
    return sb.length();
  }

  public int get(int i) {
    return sb.charAt(i);
  }

  public void set(int i, int c) {
    sb.setCharAt(i, (char) c);
  }

  public void fill(int ofs, int len, int c) {
    char cc = (char) c;
    for (int i = 0; i < len; i++) sb.setCharAt(ofs + i, cc);
  }

  public void blitString(String src, int sofs, int dofs, int len) {
    for (int i = 0; i < len; i++) sb.setCharAt(dofs + i, src.charAt(sofs + i));
  }

  public void blitBytes(Bytes src, int sofs, int dofs, int len) {
    for (int i = 0; i < len; i++) sb.setCharAt(dofs + i, src.sb.charAt(sofs + i));
  }

  public boolean contentEquals(Bytes other) {
    if (sb.length() != other.sb.length()) return false;
    for (int i = 0; i < sb.length(); i++) {
      if (sb.charAt(i) != other.sb.charAt(i)) return false;
    }
    return true;
  }
}
