/**
 * [Str] library regex primitives. Our implementation is a
 * "whole-string match" shortcut — [string_match], [partial_match],
 * [search_forward], and [search_backward] all return a
 * [{start=0; end=length(s)}] positions array regardless of the
 * compiled regex, which is opaque to us.
 *
 * Good enough for [ctypes_path.path_of_string] and other callers
 * that only check [Array.length _ > 0] or [Str.matched_string] to
 * recover the input. A real port would need to decode OCaml's
 * [Str.regexp] compiled form into [java.util.regex.Pattern], which
 * isn't tractable without reversing the compiled-regex block
 * layout.
 */
public final class RegexStubs {
    private RegexStubs() {}

    /**
     * Returns [|0; length(s)|] as a Block of Longs. OCaml's [Str]
     * uses the 2-element form for a single match: [.{0} = start,
     * .{1} = end]. Callers reading [Array.length] see 2 → match
     * succeeded; [Str.matched_string] returns [s[0..end]] = [s].
     */
    public static Block whole_match(Object regex, Object s, Object pos) {
        int len = (s instanceof String) ? ((String) s).length() : 0;
        return new Block(0, new Object[] {
            Long.valueOf(0L), Long.valueOf((long) len)
        });
    }

    /** [re_replacement_text]: no replacement performed. */
    public static String empty_replacement(Object repl, Object matched) {
        return "";
    }
}
