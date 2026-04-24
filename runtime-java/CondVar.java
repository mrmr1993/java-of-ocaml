import java.util.concurrent.locks.Condition;

// OCaml [Condition.t]. OCaml decouples the condition from any
// specific mutex at creation time and rebinds at each [wait c m]
// call; Java's [Condition] is bound to the lock it was created
// from. We resolve the mismatch by lazily materialising the
// underlying [Condition] on the first [wait] and assuming subsequent
// waits use the same mutex (which is the only sensible use in OCaml
// — signalling a condition waited on with different mutexes is a
// race by construction).
public final class CondVar {
    private volatile Condition underlying;

    public static CondVar create() { return new CondVar(); }

    public int cwait(Mutex m) {
        if (underlying == null) {
            synchronized (this) {
                if (underlying == null) underlying = m.lock.newCondition();
            }
        }
        // Release the OCaml runtime lock around await so the signaller
        // can acquire it and run any OCaml code (e.g. enqueue into a
        // shared squeue) before signalling us. Without this, the
        // main thread holds the runtime lock the whole time it's
        // sleeping in [select / cwait], starving worker threads
        // that need to push results back into Async.
        boolean held = Ocaml.RUNTIME_LOCK.isHeldByCurrentThread();
        if (held) Ocaml.RUNTIME_LOCK.unlock();
        try {
            underlying.await();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            if (held) Ocaml.RUNTIME_LOCK.lock();
        }
        return 0;
    }

    public int csignal() {
        Condition u = underlying;
        if (u != null) u.signal();
        return 0;
    }

    public int cbroadcast() {
        Condition u = underlying;
        if (u != null) u.signalAll();
        return 0;
    }
}
