/**
 * Real implementation of the [re2] opam package's [mlre2_*]
 * C primitives, backed by [java.util.regex.Pattern].
 *
 * Not a stub — the operations here compile patterns, match
 * strings, extract submatches, and rewrite templates. The
 * backend is Java's regex engine rather than Google's C++ re2,
 * so a few corner cases differ:
 *
 * - Java supports backtracking, re2 doesn't. Pathological
 *   patterns that re2 rejects at compile time may succeed here
 *   (and run slow); patterns that re2 accepts as linear may
 *   backtrack in Java.
 * - The [max_mem] option is ignored — Java regex memory use is
 *   bounded differently.
 * - [never_capture] / [one_line] / [posix_syntax] /
 *   [word_boundary] options map onto Java's flag bits where an
 *   equivalent exists; otherwise they're tracked on the options
 *   object but don't alter compilation (documented per-field).
 *
 * Representation:
 *   [re2] type `t`          -> an [Re2.Regex] instance
 *   [re2] type `multiple`   -> an [Re2.Multiple] instance
 *   [Options.C_repr.t]      -> an [Re2.Options] instance
 *   [Options.Encoding.C_repr.t] (int) -> 0 = Latin1, 1 = Utf8
 */
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

public final class Re2 {
    private Re2() {}

    private static final long ENCODING_LATIN1 = 0L;
    private static final long ENCODING_UTF8   = 1L;

    // === Options =====================================================

    public static final class Options {
        public boolean caseSensitive = true;
        public boolean dotNl         = false;
        public long    encoding      = ENCODING_UTF8;
        public boolean literal       = false;
        public boolean logErrors     = true;
        public boolean longestMatch  = false;
        public long    maxMem        = 8_388_608L; // re2 default
        public boolean neverCapture  = false;
        public boolean neverNl       = false;
        public boolean oneLine       = false;
        public boolean perlClasses   = false;
        public boolean posixSyntax   = false;
        public boolean wordBoundary  = false;

        int toPatternFlags() {
            int f = 0;
            if (!caseSensitive) f |= Pattern.CASE_INSENSITIVE;
            if (dotNl)          f |= Pattern.DOTALL;
            if (literal)        f |= Pattern.LITERAL;
            if (!oneLine)       f |= Pattern.MULTILINE;
            return f;
        }
    }

    // === Regex handle ================================================

    public static final class Regex {
        public final Pattern pattern;
        public final String source;
        public final Options options;
        public final int groupCount;

        Regex(Pattern pattern, String source, Options options) {
            this.pattern = pattern;
            this.source = source;
            this.options = options;
            // matcher.groupCount() — whole match is group 0; declared
            // captures are 1..N.
            Matcher m = pattern.matcher("");
            this.groupCount = m.groupCount();
        }
    }

    public static final class Multiple {
        public final Options options;
        public final List<Pattern> patterns = new ArrayList<>();
        public Multiple(Options options) { this.options = options; }
    }

    // === Encoding constants ==========================================

    public static long encoding_get_latin1(Object u) { return ENCODING_LATIN1; }
    public static long encoding_get_utf8(Object u)   { return ENCODING_UTF8; }

    // === Options getters / setters ===================================

    public static long opt_case_sensitive(Object o) { return asOpts(o).caseSensitive ? 1 : 0; }
    public static long opt_set_case_sensitive(Object o, long v) {
        asOpts(o).caseSensitive = v != 0; return 0;
    }
    public static long opt_dot_nl(Object o) { return asOpts(o).dotNl ? 1 : 0; }
    public static long opt_set_dot_nl(Object o, long v) {
        asOpts(o).dotNl = v != 0; return 0;
    }
    public static long opt_encoding(Object o) { return asOpts(o).encoding; }
    public static long opt_set_encoding(Object o, long v) {
        asOpts(o).encoding = v; return 0;
    }
    public static long opt_literal(Object o) { return asOpts(o).literal ? 1 : 0; }
    public static long opt_set_literal(Object o, long v) {
        asOpts(o).literal = v != 0; return 0;
    }
    public static long opt_log_errors(Object o) { return asOpts(o).logErrors ? 1 : 0; }
    public static long opt_set_log_errors(Object o, long v) {
        asOpts(o).logErrors = v != 0; return 0;
    }
    public static long opt_longest_match(Object o) { return asOpts(o).longestMatch ? 1 : 0; }
    public static long opt_set_longest_match(Object o, long v) {
        asOpts(o).longestMatch = v != 0; return 0;
    }
    public static long opt_max_mem(Object o) { return asOpts(o).maxMem; }
    public static long opt_set_max_mem(Object o, long v) {
        asOpts(o).maxMem = v; return 0;
    }
    public static long opt_never_capture(Object o) { return asOpts(o).neverCapture ? 1 : 0; }
    public static long opt_set_never_capture(Object o, long v) {
        asOpts(o).neverCapture = v != 0; return 0;
    }
    public static long opt_never_nl(Object o) { return asOpts(o).neverNl ? 1 : 0; }
    public static long opt_set_never_nl(Object o, long v) {
        asOpts(o).neverNl = v != 0; return 0;
    }
    public static long opt_one_line(Object o) { return asOpts(o).oneLine ? 1 : 0; }
    public static long opt_set_one_line(Object o, long v) {
        asOpts(o).oneLine = v != 0; return 0;
    }
    public static long opt_perl_classes(Object o) { return asOpts(o).perlClasses ? 1 : 0; }
    public static long opt_set_perl_classes(Object o, long v) {
        asOpts(o).perlClasses = v != 0; return 0;
    }
    public static long opt_posix_syntax(Object o) { return asOpts(o).posixSyntax ? 1 : 0; }
    public static long opt_set_posix_syntax(Object o, long v) {
        asOpts(o).posixSyntax = v != 0; return 0;
    }
    public static long opt_word_boundary(Object o) { return asOpts(o).wordBoundary ? 1 : 0; }
    public static long opt_set_word_boundary(Object o, long v) {
        asOpts(o).wordBoundary = v != 0; return 0;
    }

    /** [create_quiet ()]: fresh default options. "Quiet" = with
     *  [log_errors = false]; we honor that. */
    public static Object opt_create_quiet(Object u) {
        Options o = new Options();
        o.logErrors = false;
        return o;
    }

    // === Regex operations ============================================

    /** [mlre2__init]: one-time registration. Callback exceptions are
     *  already registered OCaml-side by the time we get here. */
    public static long init(Object u) { return 0; }

    /** [mlre2__create_re opts pat]: compile [pat] under [opts]. */
    public static Object create_re(Object opts, Object pat) {
        Options o = asOpts(opts);
        String source = (String) pat;
        try {
            Pattern p = Pattern.compile(source, o.toPatternFlags());
            return new Regex(p, source, o);
        } catch (PatternSyntaxException e) {
            throw Ocaml.raiseFailure("Regex_compile_failed: " + e.getMessage());
        }
    }

    public static long num_submatches(Object re) {
        return asRegex(re).groupCount + 1; // whole match + declared groups
    }

    /** [submatch_index r name]: index of the named capture group, or
     *  [-1] if no such group. */
    public static long submatch_index(Object re, Object name) {
        String n = (String) name;
        Regex r = asRegex(re);
        // Java exposes no direct "name -> index" API pre-14. Probe by
        // attempting to reference the group on a dummy matcher; if the
        // pattern doesn't declare it we catch IllegalArgumentException.
        Matcher m = r.pattern.matcher("");
        try {
            m.group(n);
            // [Matcher.group(String)] before a match raises
            // IllegalStateException, but if the name isn't a declared
            // group it raises IllegalArgumentException first.
            return findNamedGroupIndex(r.pattern.pattern(), n);
        } catch (IllegalStateException ok) {
            // Named group exists; look up its index.
            return findNamedGroupIndex(r.pattern.pattern(), n);
        } catch (IllegalArgumentException e) {
            return -1L;
        }
    }

    private static long findNamedGroupIndex(String source, String name) {
        // Walk the source looking for [(?<name>...]. Track '(' depth
        // to count declared capture groups.
        int depth = 0, idx = 0;
        for (int i = 0; i < source.length(); i++) {
            char c = source.charAt(i);
            if (c == '\\' && i + 1 < source.length()) { i++; continue; }
            if (c != '(') continue;
            // Skip non-capturing groups, lookaheads, etc.
            if (i + 1 < source.length() && source.charAt(i + 1) == '?') {
                int j = i + 2;
                if (j < source.length() && source.charAt(j) == '<') {
                    // Named group: parse name up to '>'.
                    int start = j + 1, end = start;
                    while (end < source.length() && source.charAt(end) != '>') end++;
                    if (end >= source.length()) continue;
                    String gname = source.substring(start, end);
                    idx++;
                    if (gname.equals(name)) return idx;
                    continue;
                }
                // Non-capturing / lookahead / options — doesn't count.
                continue;
            }
            idx++;
        }
        return -1L;
    }

    public static String pattern(Object re) { return asRegex(re).source; }

    public static Object options(Object re) { return asRegex(re).options; }

    /** [matches r s]: does [r] match anywhere in [s]? */
    public static long matches(Object re, Object s) {
        return asRegex(re).pattern.matcher((String) s).find() ? 1 : 0;
    }

    /** [find_all r sub s]: collect every non-overlapping match's [sub]
     *  submatch. Returns an OCaml string list (tag 0 = :: / 0 = []). */
    public static Object find_all(Object re, long sub, Object s) {
        Regex r = asRegex(re);
        Matcher m = r.pattern.matcher((String) s);
        List<String> out = new ArrayList<>();
        while (m.find()) {
            try {
                String g = m.group((int) sub);
                if (g != null) out.add(g);
            } catch (IndexOutOfBoundsException e) {
                throw Ocaml.raiseFailure("Regex_no_such_subpattern: " + sub);
            }
        }
        return ocamlList(out);
    }

    /** [find_first r sub s]: first match's [sub] submatch, or raise. */
    public static String find_first(Object re, long sub, Object s) {
        Regex r = asRegex(re);
        Matcher m = r.pattern.matcher((String) s);
        if (!m.find()) throw Ocaml.raiseFailure("Regex_match_failed");
        try {
            String g = m.group((int) sub);
            if (g == null) {
                throw Ocaml.raiseFailure("Regex_submatch_did_not_capture: " + sub);
            }
            return g;
        } catch (IndexOutOfBoundsException e) {
            throw Ocaml.raiseFailure("Regex_no_such_subpattern: " + sub);
        }
    }

    /** [rewrite_exn r template s]: substitute [\N] refs in [template]
     *  with captures from the match of [r] against [s]. */
    public static String rewrite_exn(Object re, Object template, Object s) {
        Regex r = asRegex(re);
        String tmpl = (String) template;
        String input = (String) s;
        // Re2's template syntax uses [\N] for submatch N. Java's
        // replaceAll uses [$N]. Translate \N -> $N (and \\ -> \).
        String javaTmpl = re2TemplateToJava(tmpl);
        try {
            return r.pattern.matcher(input).replaceAll(javaTmpl);
        } catch (IndexOutOfBoundsException | IllegalArgumentException e) {
            throw Ocaml.raiseFailure("Regex_rewrite_template_invalid: " + tmpl);
        }
    }

    public static long valid_rewrite_template(Object re, Object template) {
        // Best-effort: check for unmatched or out-of-range backrefs.
        Regex r = asRegex(re);
        String t = (String) template;
        int declared = r.groupCount;
        for (int i = 0; i < t.length(); i++) {
            if (t.charAt(i) == '\\' && i + 1 < t.length()) {
                char next = t.charAt(i + 1);
                if (next >= '0' && next <= '9') {
                    int idx = next - '0';
                    if (idx > declared) return 0;
                }
                i++;
            }
        }
        return 1;
    }

    /** [escape s]: quote [s] so it matches literally in a pattern. */
    public static String escape(Object s) {
        return Pattern.quote((String) s);
    }

    // === Multiple (regex set) =========================================

    public static Object multiple_create(Object opts) {
        return new Multiple(asOpts(opts));
    }

    public static long multiple_add(Object mul, Object pat) {
        Multiple m = asMultiple(mul);
        String source = (String) pat;
        try {
            m.patterns.add(Pattern.compile(source, m.options.toPatternFlags()));
            return m.patterns.size() - 1;
        } catch (PatternSyntaxException e) {
            throw Ocaml.raiseFailure("Regex_compile_failed: " + e.getMessage());
        }
    }

    public static long multiple_compile(Object mul) { return 0; }

    /** [multiple_match m s]: return indices of every pattern in [m]
     *  that matches somewhere in [s]. */
    public static Object multiple_match(Object mul, Object s) {
        Multiple m = asMultiple(mul);
        String input = (String) s;
        List<Long> hits = new ArrayList<>();
        for (int i = 0; i < m.patterns.size(); i++) {
            if (m.patterns.get(i).matcher(input).find()) {
                hits.add((long) i);
            }
        }
        Object[] fields = new Object[hits.size()];
        for (int i = 0; i < hits.size(); i++) fields[i] = hits.get(i);
        return new Block(0, fields);
    }

    /** [iter_next r pos n s]: advance one match starting at [pos].
     *  Returns [(next_pos, None)] at end, or
     *  [(next_pos, Some [| Some (start, end); ... |])].
     *
     *  The outer tuple is Block(0, [nextPos; submatchesOpt]).
     *  [submatchesOpt] = Long(0) for None, Block(0, [array]) for Some.
     *  The array is Block(0, [Some (s, e) | None ...]) where each
     *  element is Block(0, [Block(0, [s, e])]) for Some / Long(0) for
     *  None. */
    public static Object iter_next(Object re, long pos, long n, Object s) {
        Regex r = asRegex(re);
        String input = (String) s;
        int startSearch = (int) pos;
        if (startSearch < 0 || startSearch > input.length()) {
            // end: (pos, None)
            return new Block(0, new Object[] {
                Long.valueOf(input.length()), Long.valueOf(0L),
            });
        }
        Matcher m = r.pattern.matcher(input);
        if (!m.find(startSearch)) {
            return new Block(0, new Object[] {
                Long.valueOf(input.length()), Long.valueOf(0L),
            });
        }
        int groups = (int) n;
        Object[] spans = new Object[groups];
        for (int i = 0; i < groups; i++) {
            int gs = -1, ge = -1;
            try {
                gs = m.start(i);
                ge = m.end(i);
            } catch (IndexOutOfBoundsException | IllegalStateException e) {
                gs = -1;
            }
            if (gs < 0) {
                spans[i] = Long.valueOf(0L); // None
            } else {
                Block inner = new Block(0, new Object[] {
                    Long.valueOf(gs), Long.valueOf(ge),
                });
                spans[i] = new Block(0, new Object[] { inner }); // Some
            }
        }
        Block arrBlock = new Block(0, spans);
        Block someArr  = new Block(0, new Object[] { arrBlock });
        long nextPos = m.end();
        if (nextPos == m.start()) nextPos++; // avoid infinite loop on empty match
        return new Block(0, new Object[] {
            Long.valueOf(nextPos), someArr,
        });
    }

    // === helpers =====================================================

    private static Options asOpts(Object o) { return (Options) o; }
    private static Regex   asRegex(Object o) { return (Regex) o; }
    private static Multiple asMultiple(Object o) { return (Multiple) o; }

    /** Build an OCaml string list from a Java List. */
    private static Object ocamlList(List<String> xs) {
        Object tail = Long.valueOf(0L); // []
        for (int i = xs.size() - 1; i >= 0; i--) {
            tail = new Block(0, new Object[] { xs.get(i), tail });
        }
        return tail;
    }

    /** Translate Re2 rewrite template syntax ([\N] backrefs) to Java's
     *  [Matcher.replaceAll] template syntax ([$N] backrefs). */
    private static String re2TemplateToJava(String t) {
        StringBuilder b = new StringBuilder();
        for (int i = 0; i < t.length(); i++) {
            char c = t.charAt(i);
            if (c == '\\' && i + 1 < t.length()) {
                char next = t.charAt(i + 1);
                if (next >= '0' && next <= '9') {
                    b.append('$').append(next);
                    i++;
                    continue;
                }
                if (next == '\\') {
                    b.append('\\').append('\\');
                    i++;
                    continue;
                }
            }
            if (c == '$')  { b.append("\\$"); continue; }
            b.append(c);
        }
        return b.toString();
    }
}
