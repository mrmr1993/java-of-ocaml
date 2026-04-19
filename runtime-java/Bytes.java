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

  public static int staticCompare(Object a, Object b) {
    int la = staticLength(a), lb = staticLength(b);
    int m = Math.min(la, lb);
    for (int i = 0; i < m; i++) {
      int ca = staticGet(a, i) & 0xFF;
      int cb = staticGet(b, i) & 0xFF;
      if (ca != cb) return ca - cb;
    }
    return la - lb;
  }

  // Wide-load / wide-store helpers — OCaml's [Bytes.get16 / get32 /
  // get64] and set counterparts. Little-endian; matches OCaml's
  // runtime semantics.
  public static int get16(Object o, int i) {
    int b0 = staticGet(o, i) & 0xFF;
    int b1 = staticGet(o, i + 1) & 0xFF;
    return b0 | (b1 << 8);
  }

  public static int get32(Object o, int i) {
    int b0 = staticGet(o, i) & 0xFF;
    int b1 = staticGet(o, i + 1) & 0xFF;
    int b2 = staticGet(o, i + 2) & 0xFF;
    int b3 = staticGet(o, i + 3) & 0xFF;
    return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
  }

  public static long get64(Object o, int i) {
    long r = 0L;
    for (int k = 0; k < 8; k++) r |= ((long) (staticGet(o, i + k) & 0xFF)) << (8 * k);
    return r;
  }

  public static int set16(Bytes b, int i, int v) {
    b.sb.setCharAt(i, (char) (v & 0xFF));
    b.sb.setCharAt(i + 1, (char) ((v >> 8) & 0xFF));
    return 0;
  }

  public static int set32(Bytes b, int i, int v) {
    for (int k = 0; k < 4; k++) b.sb.setCharAt(i + k, (char) ((v >> (8 * k)) & 0xFF));
    return 0;
  }

  public static int set64(Bytes b, int i, long v) {
    for (int k = 0; k < 8; k++) b.sb.setCharAt(i + k, (char) ((v >>> (8 * k)) & 0xFFL));
    return 0;
  }

  // OCaml's [Digest.t = string], so caml_md5_bytes / caml_md5_string
  // return a String (16 bytes), not a Bytes — upstream Stdlib calls
  // [Bytes.unsafe_to_string] on the result and expects String
  // semantics.
  public static String md5(Object s, int ofs, int len) {
    byte[] input = new byte[len];
    for (int i = 0; i < len; i++) input[i] = (byte) (staticGet(s, ofs + i) & 0xFF);
    try {
      java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
      byte[] digest = md.digest(input);
      char[] chars = new char[digest.length];
      for (int i = 0; i < digest.length; i++) chars[i] = (char) (digest[i] & 0xFF);
      return new String(chars);
    } catch (java.security.NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }
}
