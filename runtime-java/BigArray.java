// Minimal OCaml [Bigarray.Genarray.t] backing — boxed uniform storage
// in an Object[], one entry per cell, with the OCaml kind / layout /
// dims recorded alongside for caml_ba_kind / _layout / _dim_N.
//
// Not a performance-competitive implementation; every access boxes.
// Sized for the path that currently matters: [Random.State]'s
// 512-entry Int64 buffer pulled in transitively by
// [Filename.temp_file]. Hot-path users should get a typed-storage
// implementation later.
public class BigArray {
    public final int kind;
    public final int layout;  // 0 = C_layout, 1 = Fortran_layout
    public final int[] dims;
    public final Object[] data;

    // OCaml bigarray [kind] codes (see bigarray.mli):
    //   0=Float32, 1=Float64,
    //   2=Int8_signed, 3=Int8_unsigned, 4=Int16_signed, 5=Int16_unsigned,
    //   6=Int32, 7=Int64, 8=Caml_int, 9=Nativeint,
    //   10=Complex32, 11=Complex64, 12=Char.

    public BigArray(int kind, int layout, int[] dims) {
        this.kind = kind;
        this.layout = layout;
        this.dims = dims;
        int total = 1;
        for (int d : dims) total *= d;
        this.data = new Object[total];
        Object zero = defaultZero(kind);
        for (int i = 0; i < total; i++) data[i] = zero;
    }

    private static Object defaultZero(int kind) {
        switch (kind) {
            case 0: case 1: case 10: case 11: return Double.valueOf(0.0);
            case 7: case 9: return Long.valueOf(0L);
            default: return Integer.valueOf(0);
        }
    }

    // caml_ba_create: kind and layout are Val_int-encoded (already
    // unboxed to int by the emitter); [dimsBlock] is a Block whose
    // fields are boxed Integers, one per dimension.
    public static BigArray create(int kind, int layout, Block dimsBlock) {
        int n = dimsBlock.fields.length;
        int[] dims = new int[n];
        for (int i = 0; i < n; i++) {
            dims[i] = (int) Block.asLong(dimsBlock.fields[i]);
        }
        return new BigArray(kind, layout, dims);
    }

    // bigstring_alloc helper: 1-D char (kind 12), c-layout (0), len.
    public static BigArray allocBigstring(long len) {
        return new BigArray(12, 0, new int[] { (int) len });
    }

    public int numDims() { return dims.length; }
    public int dim(int n) { return dims[n]; }
    public int dim1() { return dims[0]; }
    public int dim2() { return dims[1]; }
    public int dim3() { return dims[2]; }

    private int indexC(int i) {
        return (layout == 1) ? (i - 1) : i;
    }

    public Object get1(int i) { return data[indexC(i)]; }
    public Object get2(int i, int j) {
        int ci = indexC(i), cj = indexC(j);
        return data[ci * dims[1] + cj];
    }
    public Object get3(int i, int j, int k) {
        int ci = indexC(i), cj = indexC(j), ck = indexC(k);
        return data[(ci * dims[1] + cj) * dims[2] + ck];
    }

    public int set1(int i, Object v) { data[indexC(i)] = v; return 0; }
    public int set2(int i, int j, Object v) {
        int ci = indexC(i), cj = indexC(j);
        data[ci * dims[1] + cj] = v;
        return 0;
    }
    public int set3(int i, int j, int k, Object v) {
        int ci = indexC(i), cj = indexC(j), ck = indexC(k);
        data[(ci * dims[1] + cj) * dims[2] + ck] = v;
        return 0;
    }

    public int fill(Object v) {
        for (int i = 0; i < data.length; i++) data[i] = v;
        return 0;
    }

    // Bin_prot fast-write helpers: byte-addressed multi-byte writes /
    // reads into a uint8 / char Bigarray, little-endian. Used heavily
    // by Jane Street's Bin_prot on a Bigstring buffer. Each cell in
    // [data] is a boxed OCaml int (now [Long] after 63-bit widening,
    // but legacy module globals may still materialise as [Integer] —
    // route reads through [Block.asLong] for compatibility).
    public static int setU16(BigArray ba, int pos, int v) {
        ba.data[pos    ] = Long.valueOf(v & 0xffL);
        ba.data[pos + 1] = Long.valueOf((v >>> 8) & 0xffL);
        return 0;
    }
    public static int setU32(BigArray ba, int pos, int v) {
        ba.data[pos    ] = Long.valueOf(v & 0xffL);
        ba.data[pos + 1] = Long.valueOf((v >>> 8) & 0xffL);
        ba.data[pos + 2] = Long.valueOf((v >>> 16) & 0xffL);
        ba.data[pos + 3] = Long.valueOf((v >>> 24) & 0xffL);
        return 0;
    }
    public static int setU64(BigArray ba, int pos, long v) {
        for (int k = 0; k < 8; k++) {
            ba.data[pos + k] = Long.valueOf((v >>> (k * 8)) & 0xffL);
        }
        return 0;
    }
    public static int getU16(BigArray ba, int pos) {
        int b0 = (int) Block.asLong(ba.data[pos    ]) & 0xff;
        int b1 = (int) Block.asLong(ba.data[pos + 1]) & 0xff;
        return b0 | (b1 << 8);
    }
    public static int getU32(BigArray ba, int pos) {
        int b0 = (int) Block.asLong(ba.data[pos    ]) & 0xff;
        int b1 = (int) Block.asLong(ba.data[pos + 1]) & 0xff;
        int b2 = (int) Block.asLong(ba.data[pos + 2]) & 0xff;
        int b3 = (int) Block.asLong(ba.data[pos + 3]) & 0xff;
        return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
    }
    public static long getU64(BigArray ba, int pos) {
        long r = 0L;
        for (int k = 0; k < 8; k++) {
            long bk = Block.asLong(ba.data[pos + k]) & 0xffL;
            r |= bk << (k * 8);
        }
        return r;
    }

    public static int blit(BigArray src, BigArray dst) {
        System.arraycopy(src.data, 0, dst.data, 0, Math.min(src.data.length, dst.data.length));
        return 0;
    }

    // OCaml 5's LXM PRNG step — operates on a 4-int64 state stored in
    // [bigarray]. Reproduces the LCG + xorshift mix from the runtime's
    // [caml_lxm_next]; the output is the next 64-bit pseudo-random
    // value and the state is updated in place.
    public static long lxmNext(BigArray st) {
        long M = 0xd1342543de82ef95L;
        long s0 = ((Long) st.data[0]).longValue();
        long s1 = ((Long) st.data[1]).longValue();
        long s2 = ((Long) st.data[2]).longValue();
        long s3 = ((Long) st.data[3]).longValue();
        long z = s1 + s3;
        z = (z ^ (z >>> 32)) * 0xdaba0b6eb09322e3L;
        z = (z ^ (z >>> 32)) * 0xdaba0b6eb09322e3L;
        z = z ^ (z >>> 32);
        long q0 = s0 * M + s1;
        // xorshift on (s2, s3)
        long t = s2 ^ s3;
        long ns2 = Long.rotateLeft(s2, 24) ^ t ^ (t << 16);
        long ns3 = Long.rotateLeft(t, 37);
        st.data[0] = Long.valueOf(q0);
        // s1 stays put
        st.data[2] = Long.valueOf(ns2);
        st.data[3] = Long.valueOf(ns3);
        return z;
    }
}
