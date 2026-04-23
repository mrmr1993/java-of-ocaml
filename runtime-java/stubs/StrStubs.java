/**
 * [Str] regex primitives. A port of
 * [ocaml/otherlibs/str/strstubs.c]'s bytecode-NFA interpreter.
 *
 * The OCaml-side [Str.regexp] compiles a pattern into an immutable
 * 6-field [Block {prog; cpool; normtable; numgroups; numregisters;
 * startchars}]; this class interprets that program on an input
 * string, returning the group-position array the C version does.
 *
 * ### Representation
 *
 *   - regex:  [Block(tag=0, [long[] prog-as-Block, String[] cpool,
 *                            String normtable, long numgroups,
 *                            long numregisters, long startchars])]
 *   - text:   [String]
 *   - result: [Block(tag=0, [long g0s, long g0e, long g1s, long g1e,
 *                            ...])] on success; empty [Block(0, [])]
 *             on no match.
 *
 * Group N's start/end are stored at [2N, 2N+1]; [-1] flags unmatched
 * groups. Group 0 is the whole match.
 */
public final class StrStubs {
    private StrStubs() {}

    // ==== opcodes (order matches [strstubs.c]'s enum) ==================

    private static final int CHAR          = 0;
    private static final int CHARNORM      = 1;
    private static final int STRING        = 2;
    private static final int STRINGNORM    = 3;
    private static final int CHARCLASS     = 4;
    private static final int BOL           = 5;
    private static final int EOL           = 6;
    private static final int WORDBOUNDARY  = 7;
    private static final int BEGGROUP      = 8;
    private static final int ENDGROUP      = 9;
    private static final int REFGROUP      = 10;
    private static final int ACCEPT        = 11;
    private static final int SIMPLEOPT     = 12;
    private static final int SIMPLESTAR    = 13;
    private static final int SIMPLEPLUS    = 14;
    private static final int GOTO          = 15;
    private static final int PUSHBACK      = 16;
    private static final int SETMARK       = 17;
    private static final int CHECKPROGRESS = 18;

    /** From strstubs.c's [re_word_letters]: digits, [A-Z_], [a-z],
     *  Latin-1 alphabetics. Used by [WORDBOUNDARY]. */
    private static final boolean[] WORD_LETTER = new boolean[256];
    static {
        for (int c = '0'; c <= '9'; c++) WORD_LETTER[c] = true;
        for (int c = 'A'; c <= 'Z'; c++) WORD_LETTER[c] = true;
        for (int c = 'a'; c <= 'z'; c++) WORD_LETTER[c] = true;
        WORD_LETTER['_'] = true;
        for (int c = 0xC0; c <= 0xFF; c++)
            if (c != 0xD7 && c != 0xF7) WORD_LETTER[c] = true;
    }

    private static int op(long i)        { return (int) (i & 0xFF); }
    private static int arg(long i)       { return (int) ((i >>> 8) & 0xFFFFFF); }
    private static int signedArg(long i) { return (int) (i >> 8); }

    /** Cpool bitset test: [set] is a 32-byte string of bits, [c] is
     *  the char to check. */
    private static boolean inBitset(String set, int c) {
        return (set.charAt(c >>> 3) & (1 << (c & 7))) != 0;
    }

    // ==== entry points =================================================

    public static Block re_string_match(Object re, Object str, Object pos) {
        String s = (String) str;
        int p = (int) Block.asLong(pos);
        if (p < 0 || p > s.length())
            throw new RuntimeException("Str.string_match");
        Block r = matchAt((Block) re, s, p, /*partial=*/false);
        return r == null ? empty() : r;
    }

    public static Block re_partial_match(Object re, Object str, Object pos) {
        String s = (String) str;
        int p = (int) Block.asLong(pos);
        if (p < 0 || p > s.length())
            throw new RuntimeException("Str.string_partial_match");
        Block r = matchAt((Block) re, s, p, /*partial=*/true);
        return r == null ? empty() : r;
    }

    public static Block re_search_forward(Object re, Object str, Object pos) {
        Block rb = (Block) re;
        String s = (String) str;
        int p = (int) Block.asLong(pos);
        if (p < 0 || p > s.length())
            throw new RuntimeException("Str.search_forward");
        int startchars = (int) Block.asLong(rb.fields[5]);
        if (startchars == -1) {
            for (int txt = p; txt <= s.length(); txt++) {
                Block r = matchAt(rb, s, txt, false);
                if (r != null) return r;
            }
        } else {
            Block cpool = (Block) rb.fields[1];
            String sc = (String) cpool.fields[startchars];
            int txt = p;
            while (txt <= s.length()) {
                while (txt < s.length() && sc.charAt(s.charAt(txt)) == 0) txt++;
                Block r = matchAt(rb, s, txt, false);
                if (r != null) return r;
                txt++;
            }
        }
        return empty();
    }

    public static Block re_search_backward(Object re, Object str, Object pos) {
        Block rb = (Block) re;
        String s = (String) str;
        int p = (int) Block.asLong(pos);
        if (p < 0 || p > s.length())
            throw new RuntimeException("Str.search_backward");
        int startchars = (int) Block.asLong(rb.fields[5]);
        if (startchars == -1) {
            for (int txt = p; txt >= 0; txt--) {
                Block r = matchAt(rb, s, txt, false);
                if (r != null) return r;
            }
        } else {
            Block cpool = (Block) rb.fields[1];
            String sc = (String) cpool.fields[startchars];
            int txt = p;
            while (txt >= 0) {
                while (txt > 0 && sc.charAt(s.charAt(txt)) == 0) txt--;
                Block r = matchAt(rb, s, txt, false);
                if (r != null) return r;
                txt--;
            }
        }
        return empty();
    }

    public static String re_replacement_text(Object repl, Object groups,
                                             Object orig) {
        String r = (String) repl;
        String o = (String) orig;
        Block g = (Block) groups;
        StringBuilder out = new StringBuilder(r.length());
        int n = r.length();
        for (int i = 0; i < n; i++) {
            char c = r.charAt(i);
            if (c != '\\') { out.append(c); continue; }
            if (i + 1 >= n)
                throw new RuntimeException(
                    "Str.replace: illegal backslash sequence");
            i++;
            char d = r.charAt(i);
            if (d == '\\') { out.append('\\'); continue; }
            if (d >= '0' && d <= '9') {
                int idx = d - '0';
                if (idx * 2 >= g.fields.length)
                    throw new RuntimeException(
                        "Str.replace: reference to unmatched group");
                int gs = (int) Block.asLong(g.fields[idx * 2]);
                int ge = (int) Block.asLong(g.fields[idx * 2 + 1]);
                if (gs < 0)
                    throw new RuntimeException(
                        "Str.replace: reference to unmatched group");
                out.append(o, gs, ge);
            } else {
                out.append('\\').append(d);
            }
        }
        return out.toString();
    }

    // ==== core matcher =================================================

    /** A backtrack-stack frame. Two flavours, discriminated by
     *  whether [pc] is non-negative:
     *    - pc >= 0:  "retry from [pc] with [txt=undoIndex]"
     *    - pc == -1: "restore [undoTarget[undoIndex]] = undoValue" */
    private static final class BPoint {
        int pc;          // -1 for undo frames
        int txt;          // for pc-frames: text position to restore
        int[] undoTarget; // for undo frames
        int undoIndex;    // for undo frames (and: txt for pc frames)
        int undoValue;    // for undo frames
    }

    /** Try [re] anchored at position [txt] in [s]. Return group
     *  array (as a Block of longs), or [null] on failure. */
    private static Block matchAt(Block re, String s, int txt, boolean partial) {
        Block prog    = (Block) re.fields[0];
        Block cpool   = (Block) re.fields[1];
        String normt  = (String) re.fields[2];
        int numgroups = (int) Block.asLong(re.fields[3]);
        int numregs   = (int) Block.asLong(re.fields[4]);
        int endtxt    = s.length();

        int[] gs = new int[numgroups];
        int[] ge = new int[numgroups];
        java.util.Arrays.fill(gs, -1);
        java.util.Arrays.fill(ge, -1);
        gs[0] = txt;

        int[] regs = new int[numregs];
        java.util.Arrays.fill(regs, -1);

        java.util.ArrayList<BPoint> stack = new java.util.ArrayList<>();
        int pc = 0;

        while (true) {
            long instr = Block.asLong(prog.fields[pc]);
            pc++;
            int opcode = op(instr);
            boolean fail = false;
            boolean prefixFail = false;

            switch (opcode) {
            case CHAR:
                if (txt == endtxt)      prefixFail = true;
                else if (s.charAt(txt) != arg(instr)) fail = true;
                else txt++;
                break;

            case CHARNORM:
                if (txt == endtxt)      prefixFail = true;
                else if (normt.charAt(s.charAt(txt)) != arg(instr)) fail = true;
                else txt++;
                break;

            case STRING: {
                String lit = (String) cpool.fields[arg(instr)];
                for (int i = 0; i < lit.length(); i++) {
                    if (txt == endtxt) { prefixFail = true; break; }
                    if (lit.charAt(i) != s.charAt(txt)) { fail = true; break; }
                    txt++;
                }
                break;
            }

            case STRINGNORM: {
                String lit = (String) cpool.fields[arg(instr)];
                for (int i = 0; i < lit.length(); i++) {
                    if (txt == endtxt) { prefixFail = true; break; }
                    if (lit.charAt(i) != normt.charAt(s.charAt(txt))) {
                        fail = true; break;
                    }
                    txt++;
                }
                break;
            }

            case CHARCLASS:
                if (txt == endtxt) prefixFail = true;
                else if (!inBitset((String) cpool.fields[arg(instr)],
                                   s.charAt(txt))) fail = true;
                else txt++;
                break;

            case BOL:
                if (txt > 0 && s.charAt(txt - 1) != '\n') fail = true;
                break;

            case EOL:
                if (txt < endtxt && s.charAt(txt) != '\n') fail = true;
                break;

            case WORDBOUNDARY:
                if (txt == 0) {
                    if (txt == endtxt) prefixFail = true;
                    else if (!WORD_LETTER[s.charAt(0) & 0xFF]) fail = true;
                } else if (txt == endtxt) {
                    if (!WORD_LETTER[s.charAt(txt - 1) & 0xFF]) fail = true;
                } else {
                    boolean a = WORD_LETTER[s.charAt(txt - 1) & 0xFF];
                    boolean b = WORD_LETTER[s.charAt(txt) & 0xFF];
                    if (a == b) fail = true;
                }
                break;

            case BEGGROUP: {
                int n = arg(instr);
                pushUndo(stack, gs, n, gs[n]);
                gs[n] = txt;
                break;
            }

            case ENDGROUP: {
                int n = arg(instr);
                pushUndo(stack, ge, n, ge[n]);
                ge[n] = txt;
                break;
            }

            case REFGROUP: {
                int n = arg(instr);
                if (gs[n] < 0 || ge[n] < 0) fail = true;
                else {
                    for (int p = gs[n]; p < ge[n]; p++) {
                        if (txt == endtxt) { prefixFail = true; break; }
                        if (s.charAt(p) != s.charAt(txt)) { fail = true; break; }
                        txt++;
                    }
                }
                break;
            }

            case ACCEPT:
                ge[0] = txt;
                return buildGroups(gs, ge);

            case SIMPLEOPT: {
                String set = (String) cpool.fields[arg(instr)];
                if (txt < endtxt && inBitset(set, s.charAt(txt))) txt++;
                break;
            }

            case SIMPLESTAR: {
                String set = (String) cpool.fields[arg(instr)];
                while (txt < endtxt && inBitset(set, s.charAt(txt))) txt++;
                break;
            }

            case SIMPLEPLUS: {
                String set = (String) cpool.fields[arg(instr)];
                if (txt == endtxt) { prefixFail = true; break; }
                if (!inBitset(set, s.charAt(txt))) { fail = true; break; }
                txt++;
                while (txt < endtxt && inBitset(set, s.charAt(txt))) txt++;
                break;
            }

            case GOTO:
                pc += signedArg(instr);
                break;

            case PUSHBACK:
                pushPc(stack, pc + signedArg(instr), txt);
                break;

            case SETMARK: {
                int n = arg(instr);
                pushUndo(stack, regs, n, regs[n]);
                regs[n] = txt;
                break;
            }

            case CHECKPROGRESS: {
                int n = arg(instr);
                if (regs[n] == txt) fail = true;
                break;
            }

            default:
                throw new RuntimeException("Str: unknown opcode " + opcode);
            }

            if (prefixFail && partial) { ge[0] = txt; return buildGroups(gs, ge); }
            if (prefixFail || fail) {
                int[] restored = backtrack(stack);
                if (restored == null) return null;
                pc = restored[0];
                txt = restored[1];
            }
        }
    }

    private static void pushPc(java.util.ArrayList<BPoint> stack, int pc, int txt) {
        BPoint p = new BPoint();
        p.pc = pc;
        p.undoIndex = txt;
        stack.add(p);
    }

    private static void pushUndo(java.util.ArrayList<BPoint> stack,
                                 int[] target, int idx, int oldVal) {
        BPoint p = new BPoint();
        p.pc = -1;
        p.undoTarget = target;
        p.undoIndex = idx;
        p.undoValue = oldVal;
        stack.add(p);
    }

    /** Pop frames until we find a PC frame; restore any undo frames on
     *  the way. Returns [{pc, txt}] or null if the stack is empty. */
    private static int[] backtrack(java.util.ArrayList<BPoint> stack) {
        while (!stack.isEmpty()) {
            BPoint p = stack.remove(stack.size() - 1);
            if (p.pc >= 0) return new int[] { p.pc, p.undoIndex };
            p.undoTarget[p.undoIndex] = p.undoValue;
        }
        return null;
    }

    private static Block buildGroups(int[] gs, int[] ge) {
        Object[] f = new Object[gs.length * 2];
        for (int i = 0; i < gs.length; i++) {
            f[i * 2]     = Long.valueOf(gs[i]);
            f[i * 2 + 1] = Long.valueOf(ge[i]);
        }
        return new Block(0, f);
    }

    private static Block empty() { return new Block(0, new Object[0]); }
}
