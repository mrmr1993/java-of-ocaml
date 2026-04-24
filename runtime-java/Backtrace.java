// Exception-backtrace plumbing for java-of-ocaml.
//
// OCaml's runtime captures a backtrace on every [raise] iff
// [Printexc.record_backtrace] has been called with [true] (or
// [OCAMLRUNPARAM=b] was set). Capturing is expensive enough that
// OCaml keeps it off by default. We mirror that: a single volatile
// flag gates whether [CamlException.fillInStackTrace] walks the
// JVM stack.
//
// The flag defaults to [false]. It flips on when:
//   - [Printexc.record_backtrace true] calls [caml_record_backtrace]
//     which is wired to [setRecording] below, or
//   - the process starts with [OCAMLRUNPARAM=b] (or [b=1] / [b=t]).
public final class Backtrace {
    private Backtrace() {}

    private static volatile boolean recording = readEnvFlag();

    private static boolean readEnvFlag() {
        String env = System.getenv("OCAMLRUNPARAM");
        if (env == null) env = System.getenv("CAMLRUNPARAM");
        if (env == null) return false;
        // OCaml's runtime parses a comma-separated list; the [b]
        // option enables backtrace recording. Accept bare [b], [b=1],
        // or [b=t].
        for (String part : env.split(",")) {
            String p = part.trim();
            if (p.equals("b") || p.equals("b=1") || p.equals("b=t")) {
                return true;
            }
        }
        return false;
    }

    public static boolean isRecording() {
        return recording;
    }

    // Bound to [caml_record_backtrace]. OCaml passes [0] for false,
    // anything else for true.
    public static void setRecording(int flag) {
        recording = (flag != 0);
    }

    // Bound to [caml_backtrace_status]. OCaml expects [0] / [1].
    public static int getStatus() {
        return recording ? 1 : 0;
    }

    // Render a CamlException's stack trace in OCaml's
    //   Raised at <Module.defname> in file "<file>", line N, characters C1-C2
    // style. Each frame consults the class's SourceFile attribute for
    // the filename and the LineNumberTable for the line; character
    // ranges aren't exposed by java.lang.StackTraceElement so we
    // print line-only. Prints nothing when recording was off (the
    // exception has no captured frames).
    public static String format(Throwable t) {
        if (t == null) return "";
        StackTraceElement[] frames = t.getStackTrace();
        if (frames == null || frames.length == 0) return "";
        StringBuilder sb = new StringBuilder();
        boolean first = true;
        for (StackTraceElement f : frames) {
            String cls = f.getClassName();
            // Skip noise from the raise plumbing and java.* / sun.*
            // frames introduced by reflection or the runtime lock.
            if (cls.equals("CamlException")) continue;
            if (cls.startsWith("java.") || cls.startsWith("sun.")) continue;
            String file = f.getFileName();
            int line = f.getLineNumber();
            sb.append(first ? "Raised at " : "Called from ");
            sb.append(cls).append('.').append(f.getMethodName());
            if (file != null) {
                sb.append(" in file \"").append(file).append('"');
            }
            if (line > 0) {
                sb.append(", line ").append(line);
            }
            sb.append('\n');
            first = false;
        }
        return sb.toString();
    }

    // Print "Fatal error: exception <pretty>" + backtrace, mirroring
    // OCaml's uncaught-exception formatter. Used by generated Main
    // methods to replace the JVM's default Throwable.printStackTrace
    // when a CamlException escapes.
    public static void printUncaught(CamlException e) {
        System.err.print("Fatal error: exception ");
        System.err.println(e.getMessage());
        String trace = format(e);
        if (trace.length() > 0) {
            System.err.print(trace);
        } else if (!recording) {
            // Hint the user at the feature — matches OCaml's
            // "(Program not linked with -g, cannot print stack backtrace)"
            // behavior when backtrace-on-uncaught isn't enabled.
            System.err.println(
                "(Backtrace recording disabled; set OCAMLRUNPARAM=b for backtraces.)");
        }
    }
}
