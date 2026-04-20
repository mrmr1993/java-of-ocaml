(** Method-splitting IR pass for the JVM 65535-byte [Code]-attribute
    limit.

    Rewrites a [Code.program] whose estimated emitted size exceeds
    [limit] into a head program plus a list of helper programs,
    where the head's branches to cut-point addresses are replaced by
    [Invoke_tail] terminators pointing at the helpers. The emitter
    sees only ordinary programs — no emit-time cut hooks.

    Two complementary strategies are tried in order:
    1. **Structural cut** — partition the reachable-block graph at a
       block [cut_addr] with disjoint head / tail sets and no
       [Pushtrap] region spanning the cut. The tail becomes a helper
       whose entry params are [cut_addr]'s block params.
    2. **Intra-block split** — when no structural cut exists, pick the
       heaviest block and slice its body into a chain of smaller
       blocks joined by [Branch] terminators with live-out vars
       threaded as block params. A greedy backward sweep keyed on
       precomputed cost-from-end and live-count arrays picks each cut
       under a rolling byte budget. The structural step then has the
       joining branches as natural cut candidates.

    Each level's excess is split recursively, bottom-up, so helper
    numbering is stable and helpers never contain oversized code.

    When the program is unsplittable (no structural cut _and_ no
    productive intra-block split), the pass returns the input
    unchanged and the driver falls back to a runtime-throwing stub. *)

type helper =
  { method_name : string
  ; params : Code.Var.t list
  ; prog : Code.program
  ; descriptor : string
  }

type split_result =
  { head : Code.program
  ; helpers : helper list   (** In emission order (bottom-up). *)
  }

type return_kind =
  | Return_object
      (** Helper returns [Ljava/lang/Object;], the head's
          [Invoke_tail] emits [areturn]. Used for closure applies. *)
  | Return_void
      (** Helper returns [V], the head's [Invoke_tail] emits
          [return_void]. Used for [Main]-split helpers (main's body
          ends with [Stop], not [Return v]). *)

val split :
     limit:int
  -> class_name:string
  -> is_static:bool
  -> return_kind:return_kind
  -> ?env_var:Code.Var.t
  -> Code.program
  -> split_result
(** [split ~limit ~class_name ~is_static ~return_kind prog] returns
    a fully-split program whose head and every helper fit under
    [limit] bytes when possible. Helpers invoke themselves on
    [class_name] — virtually when [is_static] is [false] (the usual
    closure-apply case) or statically when [true] (Main or any
    static-method host).

    [env_var] names the enclosing closure's [this] var, if any, so the
    live-in computation can exclude it (it's loaded via [aload 0] and
    doesn't need to flow through a param).

    If the input already fits under [limit], returns
    [{ head = prog; helpers = [] }]. *)

(** {1 Low-level building blocks}

    Exposed mainly for testing. In production, call [split]. *)

type cut =
  { cut_addr : Code.Addr.t
  ; head : Code.Addr.Set.t
  ; tail : Code.Addr.Set.t  (** Includes [cut_addr]. *)
  }

val find_cut : Code.program -> cut option
(** Find the structural cut whose head cost sits closest to
    [limit / 2], or [None] if none is valid. *)
