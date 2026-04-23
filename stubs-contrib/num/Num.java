import java.math.BigInteger;

/**
 * Adapter for OCaml's [Num]/[nat] library — the pre-[Zarith]
 * big-integer type that some libraries still transitively pull in.
 *
 * A [nat] is a mutable little-endian digit array: digit 0 is the
 * least-significant, digit [length-1] is the most-significant. In
 * upstream OCaml each digit is a machine word ([nativeint]); we
 * use 30 bits per digit (the conservative choice that survives
 * OCaml's 31-bit [int] on 32-bit platforms + keeps all
 * [nth_digit_nat] return values non-negative in OCaml's 63-bit
 * [int]). Arithmetic primitives convert the relevant digit slice
 * to [BigInteger], operate, and write back — same pattern as our
 * [Zarith] adapter but with mutable destination semantics to
 * match [Num]'s C API.
 */
public final class Num {
    private Num() {}

    // Keep digit width below 31 so that digit values always fit
    // OCaml's 63-bit int when [nth_digit_nat] returns one.
    public static final int BITS_PER_DIGIT = 30;
    public static final long DIGIT_MASK = (1L << BITS_PER_DIGIT) - 1L;

    /** Wrapper so a [nat] flows through the runtime as a single
     *  [Object]. Direct long[] can't be a Block field cleanly; a
     *  tiny class keeps signatures trivial and gives callers a
     *  stable shape. */
    public static final class Nat {
        public final long[] d;
        public Nat(int len) { this.d = new long[len]; }
    }

    private static Nat asNat(Object o) { return (Nat) o; }

    /** Read a slice of digits as a non-negative [BigInteger]. */
    private static BigInteger toBig(Nat n, int ofs, int len) {
        BigInteger v = BigInteger.ZERO;
        for (int i = len - 1; i >= 0; i--) {
            v = v.shiftLeft(BITS_PER_DIGIT)
                 .or(BigInteger.valueOf(n.d[ofs + i] & DIGIT_MASK));
        }
        return v;
    }

    /** Write [v]'s digits into [n[ofs..ofs+len)]. Extra low-order
     *  bits fit; high-order bits of [v] beyond [len*BITS_PER_DIGIT]
     *  are silently truncated, matching the C [nat]'s handling of
     *  overflow (callers size the destination to avoid this). */
    private static void fromBig(BigInteger v, Nat n, int ofs, int len) {
        BigInteger mask = BigInteger.valueOf(DIGIT_MASK);
        for (int i = 0; i < len; i++) {
            n.d[ofs + i] = v.and(mask).longValue();
            v = v.shiftRight(BITS_PER_DIGIT);
        }
    }

    // ==== Allocation / I/O ========================================
    public static Object create_nat(long size) { return new Nat((int) size); }

    public static long set_to_zero_nat(Object nat, long ofs, long len) {
        Nat n = asNat(nat);
        int o = (int) ofs;
        for (int i = 0; i < len; i++) n.d[o + i] = 0;
        return 0;
    }

    public static long blit_nat(Object dest, long dofs,
                                Object src,  long sofs, long len) {
        Nat d = asNat(dest), s = asNat(src);
        int doff = (int) dofs, soff = (int) sofs, n = (int) len;
        // System.arraycopy handles overlap for same-array copies.
        System.arraycopy(s.d, soff, d.d, doff, n);
        return 0;
    }

    public static long set_digit_nat(Object nat, long i, long v) {
        asNat(nat).d[(int) i] = v & DIGIT_MASK;
        return 0;
    }

    public static long nth_digit_nat(Object nat, long i) {
        return asNat(nat).d[(int) i] & DIGIT_MASK;
    }

    public static long num_digits_nat(Object nat, long ofs, long len) {
        Nat n = asNat(nat);
        int o = (int) ofs;
        int last = -1;
        for (int i = 0; i < len; i++) if (n.d[o + i] != 0) last = i;
        return last + 1;
    }

    // ==== Arithmetic ==============================================
    public static long add_nat(Object dest, long dofs, long dlen,
                               Object src,  long sofs, long slen,
                               long carry_in) {
        Nat d = asNat(dest), s = asNat(src);
        BigInteger a = toBig(d, (int) dofs, (int) dlen);
        BigInteger b = toBig(s, (int) sofs, (int) slen);
        BigInteger sum = a.add(b).add(BigInteger.valueOf(carry_in & 1L));
        fromBig(sum, d, (int) dofs, (int) dlen);
        // Carry out = overflow past dest's capacity.
        BigInteger cap = BigInteger.ONE.shiftLeft(BITS_PER_DIGIT * (int) dlen);
        return sum.compareTo(cap) >= 0 ? 1 : 0;
    }

    public static long sub_nat(Object dest, long dofs, long dlen,
                               Object src,  long sofs, long slen,
                               long borrow_in) {
        Nat d = asNat(dest), s = asNat(src);
        BigInteger a = toBig(d, (int) dofs, (int) dlen);
        BigInteger b = toBig(s, (int) sofs, (int) slen);
        BigInteger diff = a.subtract(b).subtract(BigInteger.valueOf(borrow_in & 1L));
        // nat sub semantics: if diff < 0, borrow out = 1 and result
        // wraps modulo 2^(BITS_PER_DIGIT * dlen).
        long borrow_out;
        if (diff.signum() < 0) {
            diff = diff.add(BigInteger.ONE.shiftLeft(BITS_PER_DIGIT * (int) dlen));
            borrow_out = 0; // inverted from add: 0 means "borrow happened"
        } else {
            borrow_out = 1;
        }
        fromBig(diff, d, (int) dofs, (int) dlen);
        return borrow_out;
    }

    public static long incr_nat(Object nat, long ofs, long len, long carry) {
        Nat n = asNat(nat);
        BigInteger v = toBig(n, (int) ofs, (int) len)
                         .add(BigInteger.valueOf(carry & 1L));
        BigInteger cap = BigInteger.ONE.shiftLeft(BITS_PER_DIGIT * (int) len);
        long out = v.compareTo(cap) >= 0 ? 1 : 0;
        fromBig(v, n, (int) ofs, (int) len);
        return out;
    }

    public static long decr_nat(Object nat, long ofs, long len, long borrow) {
        Nat n = asNat(nat);
        BigInteger v = toBig(n, (int) ofs, (int) len)
                         .subtract(BigInteger.valueOf(borrow & 1L));
        long out;
        if (v.signum() < 0) {
            v = v.add(BigInteger.ONE.shiftLeft(BITS_PER_DIGIT * (int) len));
            out = 0;
        } else {
            out = 1;
        }
        fromBig(v, n, (int) ofs, (int) len);
        return out;
    }

    public static long complement_nat(Object nat, long ofs, long len) {
        Nat n = asNat(nat);
        int o = (int) ofs;
        for (int i = 0; i < len; i++) n.d[o + i] = (~n.d[o + i]) & DIGIT_MASK;
        return 0;
    }

    public static long mult_digit_nat(Object dest, long dofs, long dlen,
                                      Object src,  long sofs, long slen,
                                      Object digit_nat, long dig_ofs) {
        Nat dn = asNat(digit_nat);
        long dig = dn.d[(int) dig_ofs] & DIGIT_MASK;
        Nat d = asNat(dest), s = asNat(src);
        BigInteger a = toBig(d, (int) dofs, (int) dlen);
        BigInteger b = toBig(s, (int) sofs, (int) slen);
        BigInteger prod = a.add(b.multiply(BigInteger.valueOf(dig)));
        BigInteger cap = BigInteger.ONE.shiftLeft(BITS_PER_DIGIT * (int) dlen);
        long carry = prod.compareTo(cap) >= 0 ? 1 : 0;
        fromBig(prod, d, (int) dofs, (int) dlen);
        return carry;
    }

    public static long mult_nat(Object dest, long dofs, long dlen,
                                Object src1, long s1ofs, long s1len,
                                Object src2, long s2ofs, long s2len) {
        Nat d = asNat(dest), s1 = asNat(src1), s2 = asNat(src2);
        BigInteger a = toBig(s1, (int) s1ofs, (int) s1len);
        BigInteger b = toBig(s2, (int) s2ofs, (int) s2len);
        BigInteger prev = toBig(d, (int) dofs, (int) dlen);
        BigInteger prod = prev.add(a.multiply(b));
        BigInteger cap = BigInteger.ONE.shiftLeft(BITS_PER_DIGIT * (int) dlen);
        long carry = prod.compareTo(cap) >= 0 ? 1 : 0;
        fromBig(prod, d, (int) dofs, (int) dlen);
        return carry;
    }

    public static long square_nat(Object dest, long dofs, long dlen,
                                  Object src,  long sofs, long slen) {
        Nat d = asNat(dest), s = asNat(src);
        BigInteger a = toBig(s, (int) sofs, (int) slen);
        BigInteger prev = toBig(d, (int) dofs, (int) dlen);
        BigInteger prod = prev.add(a.multiply(a));
        BigInteger cap = BigInteger.ONE.shiftLeft(BITS_PER_DIGIT * (int) dlen);
        long carry = prod.compareTo(cap) >= 0 ? 1 : 0;
        fromBig(prod, d, (int) dofs, (int) dlen);
        return carry;
    }

    public static long shift_left_nat(Object dest, long dofs, long dlen,
                                      Object src,  long sofs, long slen) {
        // [src[sofs..sofs+slen)] holds the shift count in digit 0.
        Nat d = asNat(dest), s = asNat(src);
        long sh = s.d[(int) sofs] & DIGIT_MASK;
        BigInteger v = toBig(d, (int) dofs, (int) dlen).shiftLeft((int) sh);
        BigInteger cap = BigInteger.ONE.shiftLeft(BITS_PER_DIGIT * (int) dlen);
        long carry = v.compareTo(cap) >= 0 ? 1 : 0;
        fromBig(v, d, (int) dofs, (int) dlen);
        return carry;
    }

    public static long shift_right_nat(Object dest, long dofs, long dlen,
                                       Object src,  long sofs, long slen) {
        Nat d = asNat(dest), s = asNat(src);
        long sh = s.d[(int) sofs] & DIGIT_MASK;
        BigInteger v = toBig(d, (int) dofs, (int) dlen);
        BigInteger cap_sh = BigInteger.ONE.shiftLeft((int) sh);
        BigInteger[] qr = v.divideAndRemainder(cap_sh);
        // Write the remainder (bits shifted out) into src[sofs]
        // following the nat API, then write the quotient back.
        s.d[(int) sofs] = qr[1].longValue() & DIGIT_MASK;
        fromBig(qr[0], d, (int) dofs, (int) dlen);
        return 0;
    }

    public static long div_digit_nat(Object quot, long qofs,
                                     Object rem,  long rofs,
                                     Object src,  long sofs, long slen,
                                     long divisor_dig) {
        Nat q = asNat(quot), r = asNat(rem), s = asNat(src);
        BigInteger dividend = toBig(s, (int) sofs, (int) slen);
        BigInteger divisor  = BigInteger.valueOf(divisor_dig & DIGIT_MASK);
        BigInteger[] qr = dividend.divideAndRemainder(divisor);
        fromBig(qr[0], q, (int) qofs, (int) slen);
        r.d[(int) rofs] = qr[1].longValue() & DIGIT_MASK;
        return 0;
    }

    public static long div_nat(Object n1, long o1, long l1,
                               Object n2, long o2, long l2) {
        // [n1/n2] quotient goes into n1[o1+l2..o1+l1), remainder
        // into n1[o1..o1+l2). n2 is the divisor; length l2.
        Nat a = asNat(n1), b = asNat(n2);
        BigInteger dividend = toBig(a, (int) o1, (int) l1);
        BigInteger divisor  = toBig(b, (int) o2, (int) l2);
        BigInteger[] qr = dividend.divideAndRemainder(divisor);
        fromBig(qr[1], a, (int) o1, (int) l2);
        fromBig(qr[0], a, (int) o1 + (int) l2, (int) l1 - (int) l2);
        return 0;
    }

    // ==== Comparison ==============================================
    public static long compare_digits_nat(Object a, long ao, Object b, long bo) {
        long x = asNat(a).d[(int) ao] & DIGIT_MASK;
        long y = asNat(b).d[(int) bo] & DIGIT_MASK;
        return Long.compare(x, y);
    }

    public static long compare_nat(Object a, long ao, long alen,
                                   Object b, long bo, long blen) {
        BigInteger x = toBig(asNat(a), (int) ao, (int) alen);
        BigInteger y = toBig(asNat(b), (int) bo, (int) blen);
        return x.compareTo(y);
    }

    // ==== Digit-wise bitwise ======================================
    public static long land_digit_nat(Object a, long ao, Object b, long bo) {
        Nat na = asNat(a); Nat nb = asNat(b);
        na.d[(int) ao] = (na.d[(int) ao] & nb.d[(int) bo]) & DIGIT_MASK;
        return 0;
    }

    public static long lor_digit_nat(Object a, long ao, Object b, long bo) {
        Nat na = asNat(a); Nat nb = asNat(b);
        na.d[(int) ao] = (na.d[(int) ao] | nb.d[(int) bo]) & DIGIT_MASK;
        return 0;
    }

    public static long lxor_digit_nat(Object a, long ao, Object b, long bo) {
        Nat na = asNat(a); Nat nb = asNat(b);
        na.d[(int) ao] = (na.d[(int) ao] ^ nb.d[(int) bo]) & DIGIT_MASK;
        return 0;
    }
}
