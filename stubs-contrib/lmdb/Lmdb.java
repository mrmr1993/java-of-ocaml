/**
 * Stubs for the [lmdb] opam package's C primitives —
 * Lightning-Memory-Mapped Database bindings under the
 * [mdbs_*] prefix.
 *
 * Only [mdbs_init] is stubbed: it runs unconditionally at
 * module load and the OCaml side immediately destructures its
 * return into a 46-element flag array. Without a shape-correct
 * stub the whole bytecode fails to load. Every other [mdbs_*]
 * primitive is left out so the auto-generated "C primitive X
 * is not implemented" stub fires at the first real call site,
 * surfacing exactly which lmdb operation a caller is trying
 * to use.
 */
public final class Lmdb {
    private Lmdb() {}

    /** [mdbs_init ()]: returns [((string * int * int * int) * int array)]
     *  — a nested tuple of ((version_string, major, minor, patch),
     *  flag_codes_array). The destructuring binds 46 named flag
     *  values out of the array; length must match exactly or the
     *  pattern raises Match_failure at module init. */
    public static Block init(Object unit) {
        Block versionTuple = new Block(0, new Object[] {
            "lmdb-jni-stub", Long.valueOf(0L), Long.valueOf(0L), Long.valueOf(0L),
        });
        Object[] flags = new Object[46];
        for (int i = 0; i < flags.length; i++) flags[i] = Long.valueOf(0L);
        Block errCodes = new Block(0, flags);
        return new Block(0, new Object[] { versionTuple, errCodes });
    }
}
