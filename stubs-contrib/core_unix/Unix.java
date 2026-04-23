/**
 * OCaml stdlib [Unix] module C primitives — the [unix_*]-prefixed
 * externals declared in [ocaml/otherlibs/unix/unix.ml]. In
 * [js_of_ocaml]'s runtime these are implemented in [runtime/js/
 * unix.js] (and aliased from [caml_unix_*] for post-5.0 names).
 * We keep them out of our built-in runtime for now because Core's
 * [core_unix] sub-library reuses the same [unix_*] namespace and
 * it's cleaner to ship both together under [stubs-contrib/].
 *
 * ### Implementation strategy
 *
 * Most syscalls return [0] / [Long 0] — sufficient for init-time
 * references that don't consume the result. Where Java offers an
 * obvious equivalent that init code observably depends on
 * ([gettimeofday], [time], [getpid], [gethostname]), we call the
 * JDK API.
 */
import java.lang.management.ManagementFactory;
import java.net.InetAddress;
import java.net.UnknownHostException;

public final class Unix {
    private Unix() {}

    private static final Object ZERO = Long.valueOf(0L);

    // ==== Real implementations (observable by init code) ===============

    /** [unix_gettimeofday] → seconds since epoch as float. */
    public static double gettimeofday(Object ignore) {
        return System.currentTimeMillis() / 1000.0;
    }

    /** [unix_time] → seconds since epoch as int. */
    public static long time(Object ignore) {
        return System.currentTimeMillis() / 1000L;
    }

    /** [unix_getpid]. On Java 8 [ProcessHandle] isn't available;
     *  parse [ManagementFactory.getRuntimeMXBean().getName()]
     *  which returns ["pid@host"]. */
    public static long getpid(Object ignore) {
        String name = ManagementFactory.getRuntimeMXBean().getName();
        int at = name.indexOf('@');
        if (at < 0) return 0;
        try { return Long.parseLong(name.substring(0, at)); }
        catch (NumberFormatException e) { return 0; }
    }

    /** [unix_getppid]. Not reliably available on Java 8; return 0. */
    public static long getppid(Object ignore) { return 0; }

    /** [unix_getuid] — JVM doesn't expose real uid; return 1000
     *  (typical user). */
    public static long getuid(Object ignore) { return 1000L; }

    /** [unix_geteuid]. */
    public static long geteuid(Object ignore) { return 1000L; }

    /** [unix_getgid]. */
    public static long getgid(Object ignore) { return 1000L; }

    /** [unix_getegid]. */
    public static long getegid(Object ignore) { return 1000L; }

    /** [unix_gethostname]. */
    public static String gethostname(Object ignore) {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            return "localhost";
        }
    }

    /** [unix_environment] / [_unsafe] — shape is a [string array]
     *  of "KEY=VALUE" pairs. Stub returns an empty array so Core's
     *  [Sys.getenv] fallbacks don't see garbage. */
    public static Block environment(Object ignore) {
        return new Block(0, new Object[0]);
    }

    // ==== zero-returning syscall stubs =================================

    public static Object zero()                                       { return ZERO; }
    public static Object zero(Object a)                                { return ZERO; }
    public static Object zero(Object a, Object b)                      { return ZERO; }
    public static Object zero(Object a, Object b, Object c)            { return ZERO; }
    public static Object zero(Object a, Object b, Object c, Object d)  { return ZERO; }
    public static Object zero(Object a, Object b, Object c, Object d, Object e) {
        return ZERO;
    }
    public static Object zero(Object a, Object b, Object c, Object d, Object e,
                              Object f) {
        return ZERO;
    }
}
