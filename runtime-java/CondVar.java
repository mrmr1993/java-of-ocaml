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
        try {
            underlying.await();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
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
