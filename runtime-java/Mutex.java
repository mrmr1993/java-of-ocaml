import java.util.concurrent.locks.ReentrantLock;

// OCaml [Mutex.t] backed by a [ReentrantLock]. ReentrantLock matches
// OCaml mutex semantics: repeated locks by the same thread increment
// a count (double-lock doesn't self-deadlock) and unlock decrements
// it. Condition variables (see [CondVar]) call [.newCondition()] on
// this lock on first wait.
public final class Mutex {
    public final ReentrantLock lock = new ReentrantLock();

    public static Mutex create() { return new Mutex(); }

    public int mlock() {
        lock.lock();
        return 0;
    }

    public int mtry_lock() {
        return lock.tryLock() ? 1 : 0;
    }

    public int munlock() {
        try {
            lock.unlock();
        } catch (IllegalMonitorStateException e) {
            // Not held — OCaml would raise Sys_error. We just swallow.
        }
        return 0;
    }
}
