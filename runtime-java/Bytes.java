public class Bytes {
  public final StringBuilder sb;

  public Bytes(int n) {
    // Defensive clamp: Buffer.create and friends compute the initial
    // size via [max size 1] but OCaml's [Sys.max_string_length]
    // arithmetic may produce a small/negative value here under our
    // 32-bit int representation. StringBuilder throws
    // NegativeArraySizeException for n < 0; treat it as 0.
    int m = Math.max(0, n);
    this.sb = new StringBuilder(m);
    for (int i = 0; i < m; i++) this.sb.append('\0');
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

  // Bytes/String polymorphism helpers.
  //
  // OCaml's Bytes and String share a single runtime representation, so
  // Stdlib freely interchanges them via [Bytes.unsafe_of_string] /
  // [Bytes.unsafe_to_string]. Our [Bytes] and [java.lang.String] are
  // distinct classes, so when Stdlib invokes [caml_bytes_get] (or
  // similar) on a value that actually flowed in as a String, a direct
  // [checkcast Bytes] would ClassCastException. These static helpers
  // accept [Object] and dispatch on the runtime class, treating
  // Strings as read-only byte sequences.
  public static int staticLength(Object o) {
    if (o instanceof Bytes) return ((Bytes) o).sb.length();
    return ((String) o).length();
  }

  public static int staticGet(Object o, int i) {
    if (o instanceof Bytes) return ((Bytes) o).sb.charAt(i);
    return ((String) o).charAt(i);
  }

  public static void staticSet(Object o, int i, int c) {
    ((Bytes) o).sb.setCharAt(i, (char) c);
  }

  public static String staticAsString(Object o) {
    if (o instanceof Bytes) return ((Bytes) o).sb.toString();
    return (String) o;
  }
}
