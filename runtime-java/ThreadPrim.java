// OCaml Thread primitives backed by java.lang.Thread.
//
// OCaml [Thread.t] is opaque — the OCaml side only does reference
// comparison, [Thread.id], and [Thread.join] on the value — so we
// pass java.lang.Thread instances through as [Object] and the OCaml
// compiler treats them as such.
//
// Lives in its own class (rather than hanging off Channel / Block)
// so threading can be pulled into the output classpath independently
// and so signatures don't clutter unrelated runtime files.
public final class ThreadPrim {
    private ThreadPrim() {}

    // caml_thread_new (unit -> unit) -> Thread
    // OCaml's Thread.create wraps the user function + arg in a
    // unit-to-unit closure and passes that here.
    public static java.lang.Thread threadNew(Closure f) {
        java.lang.Thread t = new java.lang.Thread(() -> {
            // Acquire the OCaml runtime lock before running OCaml
            // code so this thread doesn't race the main scheduler
            // (or other workers) on shared OCaml state — the model
            // mirrors caml_master_lock from the C runtime.
            Ocaml.runtimeLock();
            try {
                // [unit] is [Val_int 0] on the OCaml side.
                f.apply1(Integer.valueOf(0));
            } catch (Throwable e) {
                // Uncaught exceptions print to stderr; OCaml's own
                // runtime behaves similarly (the default handler
                // installed by thread_initialize calls
                // [Printexc.print_backtrace]).
                e.printStackTrace();
            } finally {
                if (Ocaml.RUNTIME_LOCK.isHeldByCurrentThread()) {
                    Ocaml.runtimeUnlock();
                }
            }
        });
        t.setDaemon(false);
        t.start();
        return t;
    }

    public static java.lang.Thread threadSelf() {
        return java.lang.Thread.currentThread();
    }

    public static int threadId(java.lang.Thread t) {
        // java.lang.Thread.getId() returns long; cast is lossy for
        // ids past 2^31 but no real JVM has come close. OCaml's
        // Thread.id signature is int.
        return (int) t.getId();
    }

    public static int threadJoin(java.lang.Thread t) {
        try {
            t.join();
        } catch (InterruptedException e) {
            java.lang.Thread.currentThread().interrupt();
        }
        return 0;
    }

    public static int threadYield() {
        java.lang.Thread.yield();
        return 0;
    }

    public static int threadInitialize() { return 0; }
    public static int threadCleanup() { return 0; }
    public static int threadUncaughtException(Object _exn) { return 0; }

    public static int setCurrentThreadName(String name) {
        java.lang.Thread.currentThread().setName(name);
        return 0;
    }
}
