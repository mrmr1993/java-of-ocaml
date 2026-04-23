/**
 * Stubs for the [postgresql] opam package — OCaml bindings to
 * libpq. Upstream surface is ~114 [PQ*_stub] entry points
 * covering connect, exec, prepared statements, large objects,
 * notifications, and the various metadata getters.
 *
 * ### Stubbing strategy
 *
 * We do NOT implement libpq. Every PQ primitive is intentionally
 * NOT in stubs.json — they fall through to the auto-generated
 * "primitive not implemented" stub, so any actual database
 * operation throws CamlException(Failure) at the call site.
 *
 * The single deliberate stub below is [PQocaml_init], which
 * runs unconditionally at module load right after
 * [Callback.register_exception "Postgresql.Oid"] /
 * [Callback.register "Postgresql.null"]. Upstream uses it to
 * cache OCaml-side callback references on the C runtime; for
 * us there's nothing to cache and the OCaml-side registrations
 * are already done by the time we're called. Returning unit
 * lets module init complete; any real DB call later still
 * throws via the auto-stub.
 */
public final class Postgresql {
    private Postgresql() {}

    /** [PQocaml_init ()]: deliberate no-op. Upstream caches
     *  callback references; we have nothing to cache. */
    public static long ocaml_init(Object unit) { return 0; }

    // === DELIBERATE STUB: ftype <-> oid round-trip ====================
    // [oid_of_ftype : ftype -> int] / [ftype_of_oid : int -> ftype]
    // are called at module load by caqti's [driver_loader] to build
    // a per-driver type table. The real C impl returns the postgres
    // wire-protocol OIDs (BOOL=16, BYTEA=17, ...). We don't actually
    // talk to postgres, so we substitute *identity* — the pair forms
    // a consistent self-inverse mapping, which is what caqti's lookup
    // tables actually depend on. Real DB queries through [exec_*] are
    // unimplemented and will throw via the auto-stub if reached.
    //
    // ftype is a flat variant — nullary constructors flow as
    // [Long N] = constructor index. We pass N straight through.
    public static long oid_of_ftype(Object ftype) {
        return Block.asLong(ftype);
    }

    public static Object ftype_of_oid(long oid) {
        return Long.valueOf(oid);
    }
}
