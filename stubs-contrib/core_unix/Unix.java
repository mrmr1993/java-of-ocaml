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
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.attribute.PosixFileAttributes;
import java.nio.file.attribute.PosixFilePermission;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Set;
import java.util.TimeZone;

public final class Unix {
    private Unix() {}

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

    // ==== tuple-returning syscall stubs ================================
    // Some Unix primitives return tuples / records that OCaml code
    // immediately destructures. Returning [Long 0] causes a
    // "Long cannot be cast to Block" the moment the caller does
    // [let (a, b) = ...]. Supply a Block(tag=0) of zero-Long fields
    // with enough slots for the widest call site so destructuring
    // reads [Long 0] for every component.

    /** [unix_pipe cloexec ()]: returns (read_fd, write_fd) backed
     *  by a real java.nio.channels.Pipe so subsequent read / write
     *  on the fds works. Async uses these for inter-thread
     *  wakeups. */
    public static Block pipeStub(Object cloexec, Object unit) {
        try {
            int[] fds = Channel.unixPipe();
            return new Block(0, new Object[] {
                Long.valueOf(fds[0]), Long.valueOf(fds[1]),
            });
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(15L, "pipe", ""); // EMFILE-ish
        }
    }

    /** [spawn_pipe ()]: same as [unix_pipe] but from the Jane Street
     *  spawn library — the signature is [unit -> fd * fd] (no
     *  cloexec arg). */
    public static Block spawnPipe(Object unit) {
        try {
            int[] fds = Channel.unixPipe();
            return new Block(0, new Object[] {
                Long.valueOf(fds[0]), Long.valueOf(fds[1]),
            });
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(15L, "pipe", "");
        }
    }

    // [spawn_unix_byte] left auto-stubbed. A complete integration
    // with Async's Process.run machinery requires coupling our fd
    // registry into ProcessBuilder's stdio redirection (Pipe-backed
    // fds plumbed as the child's stdin/stdout/stderr) plus waitpid
    // that doesn't deadlock the scheduler — significant enough to be
    // its own piece of work rather than a partial helper here.


    /** [unix_dup]: returns a new fd. We hand back a value >= 3 so
     *  code like [Unix.file_descr_not_standard] (which recurses
     *  until [fd >= 3]) terminates — a 0-returning stub would
     *  infinite-loop at init. */
    public static long dupStub(Object cloexec, Object fd) {
        return 3L;
    }

    /** [unix_fork]: returns a pid. A [0]-returning stub puts OCaml
     *  onto the child-process code path (fork semantics: child
     *  sees 0, parent sees the child pid), which then tries to
     *  [exec] — and because our exec is also stubbed, we end up
     *  in a half-torn-down child-side state with no parent entry
     *  in [popen_processes], so later [close_process] fails with
     *  [EBADF]. Returning 1 keeps OCaml on the parent side, which
     *  registers the "child" in the popen table; the later
     *  [close_process] / [waitpid] on pid 1 then succeed. */
    public static long forkStub(Object unit) {
        return 1L;
    }

    /** [unix_waitpid flags pid]: always reports [(pid, WEXITED 0)].
     *  We don't have real subprocess tracking yet, so every wait
     *  resolves immediately as if the child exited successfully. */
    public static Block waitpidStub(Object flags, Object pid) {
        return new Block(0, new Object[] {
            pid, new Block(0, new Object[] { Long.valueOf(0L) }),
        });
    }

    /** [unix_inchannel_of_filedescr fd]: wrap an fd as an OCaml
     *  [in_channel] — a [Channel] instance in our runtime. A
     *  [Unix.zero] stub would hand back [Long 0], which then
     *  leaks into stdlib's [popen_processes] hashtable as the
     *  key. The later [close_process_in] stores a different
     *  [Channel] instance as its key and the lookup misses with
     *  [EBADF]. Route through [Channel.forDescriptor] for a
     *  consistent [Channel]. */
    public static Channel inchannelOfFiledescr(Object fd) {
        return Channel.forDescriptor((int) Block.asLong(fd));
    }

    /** [unix_outchannel_of_filedescr fd]: same for output. */
    public static Channel outchannelOfFiledescr(Object fd) {
        return Channel.forDescriptor((int) Block.asLong(fd));
    }

    // === REAL IMPLEMENTATION: unix_gethostbyname ======================
    // Resolves a hostname through [java.net.InetAddress]. Returns
    // an OCaml [Unix.host_entry] record:
    //   Block(0, [h_name; h_aliases; h_addrtype; h_addr_list])
    //     h_name      : String
    //     h_aliases   : Block(0, []) — empty array
    //     h_addrtype  : Long(0) = PF_UNIX, Long(1) = PF_INET
    //     h_addr_list : Block(0, [inet_addr ...])
    // [inet_addr] is OCaml-shaped as an opaque [String] of the
    // host-byte-order packed bytes; we follow that.
    public static Block gethostbyname(Object name) {
        String s = (String) name;
        try {
            InetAddress[] addrs = InetAddress.getAllByName(s);
            Object[] addrFields = new Object[addrs.length];
            for (int i = 0; i < addrs.length; i++) {
                byte[] raw = addrs[i].getAddress();
                addrFields[i] = new String(raw, java.nio.charset.StandardCharsets.ISO_8859_1);
            }
            Block addrList = new Block(0, addrFields);
            Block aliases  = new Block(0, new Object[0]);
            return new Block(0, new Object[] {
                addrs[0].getCanonicalHostName(),
                aliases,
                Long.valueOf(1L),  // PF_INET
                addrList,
            });
        } catch (UnknownHostException e) {
            // Match OCaml stdlib semantics: lookup failure raises
            // Not_found, which CLI-flag init paths catch and fall
            // back to a default address.
            throw Ocaml.raiseNotFound();
        }
    }

    // === DELIBERATE STUB: unix_spawn ==================================
    // [Unix.spawn prog argv envopt useShell stdfds]: real impl
    // [fork()] + [execve()]. typical init code runs subprocess probes
    // (e.g. [git rev-parse] for build-tag capture) through here.
    // Returns a fake pid (1) — our [waitpidStub] below already
    // returns [(pid, WEXITED 0)] for any pid, so the probe sees
    // a "successful empty subprocess" and binds whatever default
    // it has for the no-output case.
    public static long spawn(Object prog, Object argv, Object env,
                             Object useShell, Object stdfds) {
        return 1L;
    }

    // === REAL: unix_stat / unix_lstat / unix_fstat ====================
    // Returns a [Unix.stats] record:
    //   { st_dev; st_ino; st_kind; st_perm; st_nlink; st_uid; st_gid;
    //     st_rdev; st_size; st_atime; st_mtime; st_ctime }
    // st_kind variant: 0=REG, 1=DIR, 2=CHR, 3=BLK, 4=LNK, 5=FIFO, 6=SOCK
    // Use [java.nio.file.Files] PosixFileAttributes; falls back to
    // BasicFileAttributes if POSIX isn't supported.
    public static Block stat(Object pathObj) {
        return statPath((String) pathObj, false);
    }

    public static Block lstat(Object pathObj) {
        return statPath((String) pathObj, true);
    }

    public static Block fstat(Object fdObj) {
        // We don't yet maintain a fd → path registry; return a
        // shape-correct zeros block. Callers typically stat() by path
        // during init.
        return makeStat(0, 0, 0, 0, 1, 0, 0, 0, 0, 0.0, 0.0, 0.0);
    }

    private static Block statPath(String path, boolean noFollow) {
        try {
            Path p = Paths.get(path);
            BasicFileAttributes ba;
            int kind = 0; long size = 0; double atime = 0, mtime = 0, ctime = 0;
            try {
                PosixFileAttributes pa = noFollow
                    ? Files.readAttributes(p, PosixFileAttributes.class,
                          java.nio.file.LinkOption.NOFOLLOW_LINKS)
                    : Files.readAttributes(p, PosixFileAttributes.class);
                ba = pa;
            } catch (UnsupportedOperationException ue) {
                ba = noFollow
                    ? Files.readAttributes(p, BasicFileAttributes.class,
                          java.nio.file.LinkOption.NOFOLLOW_LINKS)
                    : Files.readAttributes(p, BasicFileAttributes.class);
            }
            if (ba.isDirectory()) kind = 1;
            else if (ba.isSymbolicLink()) kind = 4;
            else if (ba.isRegularFile()) kind = 0;
            else kind = 2; // approximate other → CHR
            size = ba.size();
            atime = ba.lastAccessTime().toMillis() / 1000.0;
            mtime = ba.lastModifiedTime().toMillis() / 1000.0;
            ctime = ba.creationTime().toMillis() / 1000.0;
            return makeStat(0, 0, kind, 0644, 1, 0, 0, 0, size,
                            atime, mtime, ctime);
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(20L, "stat", path); // ENOENT-ish
        }
    }

    private static Block makeStat(long dev, long ino, int kind, int perm,
                                  long nlink, long uid, long gid, long rdev,
                                  long size, double atime, double mtime,
                                  double ctime) {
        return new Block(0, new Object[] {
            Long.valueOf(dev), Long.valueOf(ino), Long.valueOf(kind),
            Long.valueOf(perm), Long.valueOf(nlink), Long.valueOf(uid),
            Long.valueOf(gid), Long.valueOf(rdev), Long.valueOf(size),
            Double.valueOf(atime), Double.valueOf(mtime), Double.valueOf(ctime),
        });
    }

    // === REAL: core_kernel_time_ns_format =============================
    // [format : float -> string -> string] — seconds-since-epoch +
    // strftime-style format → formatted string. The OCaml Async
    // logger uses this for line timestamps. Translate the common
    // strftime conversions to Java's SimpleDateFormat patterns.
    public static String time_ns_format(double timeSec, Object fmtObj) {
        String fmt = (String) fmtObj;
        StringBuilder out = new StringBuilder();
        StringBuilder lit = new StringBuilder();
        for (int i = 0; i < fmt.length(); i++) {
            char c = fmt.charAt(i);
            if (c == '%' && i + 1 < fmt.length()) {
                if (lit.length() > 0) {
                    out.append("'").append(lit.toString().replace("'", "''")).append("'");
                    lit.setLength(0);
                }
                char spec = fmt.charAt(++i);
                switch (spec) {
                    case 'Y': out.append("yyyy"); break;
                    case 'm': out.append("MM");   break;
                    case 'd': out.append("dd");   break;
                    case 'H': out.append("HH");   break;
                    case 'M': out.append("mm");   break;
                    case 'S': out.append("ss");   break;
                    case 'z': out.append("Z");    break;
                    case 'Z': out.append("zzz");  break;
                    case 'j': out.append("DDD");  break;
                    case 'a': out.append("EEE");  break;
                    case 'A': out.append("EEEE"); break;
                    case 'b': out.append("MMM");  break;
                    case 'B': out.append("MMMM"); break;
                    case '%': lit.append('%');    break;
                    default:  lit.append('%').append(spec);
                }
            } else {
                lit.append(c);
            }
        }
        if (lit.length() > 0) {
            out.append("'").append(lit.toString().replace("'", "''")).append("'");
        }
        SimpleDateFormat sdf = new SimpleDateFormat(out.toString());
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
        return sdf.format(new Date((long) (timeSec * 1000)));
    }

    // === DELIBERATE STUB: dump_core_on_job_delay ======================
    // [Async_unix.Dump_core_on_job_delay.dump_core / watch / tick]:
    // periodic stuck-job watchdog that dumps core on detection. We
    // can't dump core from the JVM and don't have a watchdog of our
    // own; no-op on all three.
    public static long dump_core_on_job_delay_dump_core(Object dumpType) { return 0; }
    public static long dump_core_on_job_delay_watch(double after, Object dumpType) {
        return 0;
    }
    public static long dump_core_on_job_delay_tick(Object u) { return 0; }

    // === DELIBERATE STUB: unix_select =================================
    // [Unix.select : file_descr list * file_descr list * file_descr
    //                list * float -> file_descr list * 3]
    // Returns [([], [], [])] — "nothing ready". Async's main loop
    // uses this for low-level I/O readiness on platforms without
    // epoll; with our [LinuxExt.timerfd_create] returning ENOSYS,
    // Async falls back to its select-with-timeout path. Returning
    // empty lists short-circuits — Async treats it as "no I/O
    // events, retry next cycle" and just keeps looping.
    public static Block select(Object reads, Object writes, Object excepts,
                               double timeout) {
        // Honour the timeout so the Async loop doesn't busy-spin
        // burning 100% CPU. Negative timeout = block indefinitely
        // (we cap at 1s so the JVM can still process signals etc.);
        // 0 = poll; positive = sleep that long before reporting.
        long ms;
        if (timeout < 0)        ms = 1000L;
        else if (timeout == 0)  ms = 1L;
        else                    ms = Math.max(1L, (long) (timeout * 1000.0));
        // Release the runtime lock around the sleep so worker threads
        // (e.g. Async's Fd.syscall_in_thread workers) can acquire it
        // and push results into Async's external_jobs queue between
        // our scheduler ticks.
        boolean held = Ocaml.RUNTIME_LOCK.isHeldByCurrentThread();
        if (held) Ocaml.RUNTIME_LOCK.unlock();
        try { Thread.sleep(ms); }
        catch (InterruptedException e) { Thread.currentThread().interrupt(); }
        finally { if (held) Ocaml.RUNTIME_LOCK.lock(); }

        if (System.getenv("JAVA_OF_OCAML_TRACE_SELECT") != null) {
            System.err.println("[select] reads=" + listToString(reads)
                + " writes=" + listToString(writes) + " timeout=" + timeout);
        }

        // For reads, poll InputStream.available() on each fd —
        // pipe/socket bytes ready or EOF flag-up. For writes, every
        // OutputStream-backed fd is "always writable" semantically
        // (Java's blocking-mode files are; regular files never
        // block on write either). Excepts: nothing ever exceptional.
        Object readyReads  = filterReady(reads, true);
        Object readyWrites = passThroughOutputs(writes);
        return new Block(0, new Object[] {
            readyReads, readyWrites, Long.valueOf(0L),
        });
    }

    /** Walk the OCaml fd list; keep entries whose underlying stream
     *  has bytes ready (or is closed → EOF, surfaced as "ready"
     *  too so the caller's read returns 0). */
    private static Object filterReady(Object list, boolean forRead) {
        java.util.ArrayList<Object> ready = new java.util.ArrayList<>();
        Object node = list;
        while (node instanceof Block) {
            Block cons = (Block) node;
            Object fdObj = cons.fields[0];
            int fd = (int) Block.asLong(fdObj);
            try {
                if (forRead && Channel.fdHasBytesReadable(fd)) ready.add(fdObj);
            } catch (Throwable t) {
                // ignore
            }
            node = cons.fields[1];
        }
        return listOf(ready);
    }

    private static Object passThroughOutputs(Object list) {
        java.util.ArrayList<Object> out = new java.util.ArrayList<>();
        Object node = list;
        while (node instanceof Block) {
            Block cons = (Block) node;
            out.add(cons.fields[0]);  // every write fd reported ready
            node = cons.fields[1];
        }
        return listOf(out);
    }

    private static String listToString(Object list) {
        StringBuilder sb = new StringBuilder("[");
        Object node = list;
        boolean first = true;
        while (node instanceof Block) {
            Block cons = (Block) node;
            if (!first) sb.append(",");
            sb.append(Block.asLong(cons.fields[0]));
            first = false;
            node = cons.fields[1];
        }
        sb.append("]");
        return sb.toString();
    }

    private static Object listOf(java.util.List<Object> xs) {
        Object tail = Long.valueOf(0L);
        for (int i = xs.size() - 1; i >= 0; i--) {
            tail = new Block(0, new Object[] { xs.get(i), tail });
        }
        return tail;
    }

    // === REAL: core_md5_fd ============================================
    // [digest_fd_blocking : int -> string] — read entire fd contents,
    // return 16-byte raw MD5 digest (NOT hex — see core_kernel/md5.ml).
    // Typical caller hashes a config file with this.
    public static String md5_fd(long fd) {
        // We don't yet maintain an fd-registry that maps int → InputStream
        // for arbitrary descriptors; if this is stdin / stdout / stderr
        // we can't really read content. Return MD5 of empty buffer
        // ("d41d…") — typical callers feed the digest into a
        // cache-key, and a fixed digest just means we always hit the
        // same cache slot. Real impl when our fd registry from Stage 2
        // lands.
        try {
            byte[] empty = new byte[0];
            byte[] digest = java.security.MessageDigest.getInstance("MD5").digest(empty);
            char[] out = new char[16];
            for (int i = 0; i < 16; i++) out[i] = (char) (digest[i] & 0xFF);
            return new String(out);
        } catch (java.security.NoSuchAlgorithmException e) {
            throw Ocaml.raiseFailure("MD5 unavailable: " + e.getMessage());
        }
    }

    // === REAL: unix_access / mkdir / unlink / rmdir / chdir / getcwd ==
    public static long access(Object pathObj, Object modes) {
        // Modes is an OCaml list of [R_OK | W_OK | X_OK | F_OK].
        // For init-time probes we just need the file to exist; if it does,
        // return unit. If not, raise Unix_error(ENOENT).
        Path p = Paths.get((String) pathObj);
        if (!Files.exists(p)) {
            throw Ocaml.raiseUnixError(20L, "access", (String) pathObj);
        }
        return 0;
    }

    public static long mkdir(Object pathObj, Object perm) {
        String path = (String) pathObj;
        Path p = Paths.get(path);
        if (Files.exists(p)) {
            // OCaml stdlib raises EEXIST (variant tag 8) for both
            // existing-file and existing-dir; mkdir_p loops catch
            // (EEXIST | EISDIR) -> ().
            throw Ocaml.raiseUnixError(8L, "mkdir", path);
        }
        try {
            Files.createDirectory(p);
            return 0;
        } catch (java.nio.file.NoSuchFileException e) {
            // parent dir missing — variant tag 20 = ENOENT
            throw Ocaml.raiseUnixError(20L, "mkdir", path);
        } catch (java.nio.file.FileAlreadyExistsException e) {
            throw Ocaml.raiseUnixError(8L, "mkdir", path);
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(1L, "mkdir", path); // EACCES = 1
        }
    }

    public static long unlink(Object pathObj) {
        try {
            Files.delete(Paths.get((String) pathObj));
            return 0;
        } catch (java.nio.file.NoSuchFileException e) {
            throw Ocaml.raiseUnixError(20L, "unlink", (String) pathObj);
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(13L, "unlink", (String) pathObj);
        }
    }

    public static long rmdir(Object pathObj) { return unlink(pathObj); }

    public static long chdir(Object pathObj) {
        // JVM has no chdir; record intent but warn. Files.* with
        // relative paths uses [user.dir]; we can't change it.
        System.setProperty("user.dir", (String) pathObj);
        return 0;
    }

    public static String getcwd(Object unit) {
        return System.getProperty("user.dir");
    }

    /** [Unix.chmod path perm] - JVM has limited chmod via setReadable/
     *  setWritable/setExecutable. Translate the POSIX-style perm to
     *  these. */
    public static long chmod(Object pathObj, long perm) {
        java.io.File f = new java.io.File((String) pathObj);
        if (!f.exists()) {
            throw Ocaml.raiseUnixError(20L, "chmod", (String) pathObj);
        }
        f.setReadable((perm & 0444L) != 0, false);
        f.setWritable((perm & 0222L) != 0, false);
        f.setExecutable((perm & 0111L) != 0, false);
        return 0;
    }

    /** [Unix.fchmod fd perm] - same but on a fd. JVM doesn't expose
     *  fchmod; treat as no-op (the fd was opened with our mode
     *  already). */
    public static long fchmod(Object fd, long perm) { return 0; }

    /** [Unix.openfile path flags perm] — delegates to Channel's
     *  fd registry. */
    public static long openfile(Object path, Object flags, long perm) {
        try {
            return Channel.unixOpen((String) path, flags, (int) perm);
        } catch (java.io.FileNotFoundException e) {
            throw Ocaml.raiseUnixError(20L, "open", (String) path);
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(13L, "open", (String) path);
        }
    }

    /** [Unix.write fd buf pos len] - delegates to Channel registry. */
    public static long write(long fd, Object buf, long pos, long len) {
        try {
            return Channel.unixWrite((int) fd, buf, (int) pos, (int) len);
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(5L, "write", "");
        }
    }

    /** [Unix.read fd buf pos len]. */
    public static long read(long fd, Object buf, long pos, long len) {
        try {
            return Channel.unixRead((int) fd, buf, (int) pos, (int) len);
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(5L, "read", "");
        }
    }

    /** [core_unix_read_assume_fd_is_nonblocking_stub]: poll the fd via
     *  InputStream.available; raise Unix_error(EAGAIN) when no data
     *  ready. Returning 0 instead would tell Async "EOF, pipe
     *  closed" and the scheduler permanently de-registers the fd. */
    public static long read_nonblocking(long fd, Object buf, long pos, long len) {
        try {
            int n = Channel.unixReadNonblocking((int) fd, buf, (int) pos, (int) len);
            if (n < 0) {
                throw Ocaml.raiseUnixError(2L, "read", ""); // EAGAIN tag = 2
            }
            return n;
        } catch (java.io.IOException e) {
            throw Ocaml.raiseUnixError(3L, "read", "");     // EBADF tag = 3
        }
    }

    public static long write_nonblocking(long fd, Object buf, long pos, long len) {
        return write(fd, buf, pos, len);
    }

    /** [Unix.error_message err] - a human-readable message for a
     *  Unix.error variant tag. */
    public static String error_message(Object errVariant) {
        long tag;
        if (errVariant instanceof Long) tag = ((Long) errVariant).longValue();
        else if (errVariant instanceof Block) {
            Block b = (Block) errVariant;
            // EUNKNOWNERR of int — print its int payload
            return "Unknown error " + Block.asLong(b.fields[0]);
        }
        else return "Unknown error";
        switch ((int) tag) {
            case 0:  return "Argument list too long";
            case 1:  return "Permission denied";
            case 2:  return "Resource temporarily unavailable";
            case 3:  return "Bad file descriptor";
            case 5:  return "No child processes";
            case 6:  return "Resource deadlock avoided";
            case 8:  return "File exists";
            case 11: return "Interrupted system call";
            case 12: return "Invalid argument";
            case 13: return "Input/output error";
            case 14: return "Is a directory";
            case 15: return "Too many open files";
            case 17: return "File name too long";
            case 18: return "Too many open files in system";
            case 20: return "No such file or directory";
            case 23: return "Out of memory";
            case 24: return "No space left on device";
            case 25: return "Function not implemented";
            case 26: return "Not a directory";
            case 30: return "Operation not permitted";
            case 31: return "Broken pipe";
            case 32: return "Numerical result out of range";
            case 35: return "No such process";
            case 37: return "Resource temporarily unavailable";
            default: return "Unix.error tag " + tag;
        }
    }

    // === DELIBERATE STUB: fcntl ========================================
    // [core_unix_fcntl fd cmd arg]: F_GETFL / F_SETFL / F_GETFD /
    // F_SETFD / F_GETLK / etc. JVM doesn't expose any of these
    // honestly — but Async uses F_GETFL to decide whether a fd is
    // writable / non-blocking. Reporting [O_RDWR | O_NONBLOCK] for
    // every fd lets Async's writer machinery accept any fd we hand
    // it. (POSIX: O_RDWR = 2, O_NONBLOCK = 04000 on Linux.)
    public static long fcntl(Object fd, long cmd, long arg) {
        // Our [LinuxExt.F_GETFL] / [F_SETFL] stubs report Linux's
        // numeric values (3 / 4). Report O_RDWR | O_NONBLOCK on
        // F_GETFL so Async's writer machinery accepts the fd; F_SETFL
        // is a no-op (we can't actually change kernel fd flags).
        if (cmd == 3L) return 2L | 04000L;  // O_RDWR | O_NONBLOCK
        return 0;
    }

    // === DELIBERATE STUB: file-descriptor flag ops ====================
    // [set_close_on_exec fd] / [clear_close_on_exec fd] / [set_nonblock
    // fd] / [clear_nonblock fd]: tweak fd flags. The JVM doesn't model
    // these — sockets / channels track non-blocking mode on the
    // [SelectableChannel] level instead. Returning unit is safe; if a
    // caller later observes the fd not being non-blocking, that
    // surfaces as a wouldblock-style error from the actual I/O call,
    // not from the flag-set call.
    public static long set_close_on_exec(Object fd)   { return 0; }
    public static long clear_close_on_exec(Object fd) { return 0; }
    public static long set_nonblock(Object fd)        { return 0; }
    public static long clear_nonblock(Object fd)      { return 0; }

    // === DELIBERATE STUB: unix_lockf ==================================
    // [Unix.lockf fd cmd len]: F_LOCK / F_TLOCK / F_ULOCK / F_TEST
    // file-locking via fcntl. Callers use this for per-config-dir
    // lockfile so two daemons can't share state. We're single-process
    // here; treat every lock attempt as success. Real impl would
    // need [java.nio.channels.FileChannel.tryLock] plus an fd→
    // FileChannel map.
    public static long lockf(Object fd, Object cmd, long len) { return 0; }

    // === REAL: unix_close =============================================
    // Closes the underlying stream so Pipe writers de-registering
    // their write end signals EOF to readers. Without this, typical
    // open_process_in pattern blocks forever:
    //
    //   let pipe_r, pipe_w = pipe () in
    //   ... fork+exec the child to dup pipe_w as stdout ...
    //   close pipe_w;                       <-- parent closes write end
    //   In_channel.input_lines (in_channel_of_descr pipe_r)
    //
    // We don't actually fork+exec — but the parent's [close pipe_w]
    // *must* close the underlying SinkChannel so the read end sees
    // EOF on its first read (which makes input_lines return [],
    // which the caller pattern-matches and falls through to a
    // sensible default).
    public static long close(Object fd) {
        try {
            int n = (int) Block.asLong(fd);
            Channel.closeFd(n);
        } catch (java.io.IOException e) {
            // Callers catch EBADF in [protect ~finally:close]; pretend
            // the close succeeded.
        }
        return 0;
    }
}
