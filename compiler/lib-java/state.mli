(** The emitter's mutable state.

    Threads through every [emit_*] function in the compile driver. Tracks
    the OCaml bytecode stack (via [slots]), the JVM accumulator value
    (via [acc_live] / [acc_kind]), the JVM local-variable allocator, and
    a collection of side-tables used by the per-opcode dispatch. *)

open Kind
open Function_info

type cmp_op = Eq | Ne | Lt | Le | Gt | Ge

type slot_info = { kind : kind; local : int }

type branch_snapshot =
  { s_oc_stack_depth : int
  ; s_slots : slot_info list
  }

type state =
  { code : Jvm.Code.t
  ; globals : Obj.t array
  ; prims : string array
      (** The bytecode's PRIM section, indexed by primitive number. Read
          when dispatching a C_CALL to a primitive we haven't
          implemented, to produce a readable runtime-error message. *)
  ; supported_prims : Prim.table
      (** Prim-index → (name, handler, is_seed). The seed bit is only
          consulted by the range detector, but it rides along so we can
          share one table. *)
  ; functions : (int, function_info) Hashtbl.t
      (** [closure{,rec}_pc → function_info]. *)
  ; fn_by_name : (string, function_info) Hashtbl.t
      (** Function class name → info. Read on APPLY to pick the return-
          kind unboxing. *)
  ; pc_to_label : (int, Jvm.Code.label) Hashtbl.t
  ; branch_target_state : (int, branch_snapshot) Hashtbl.t
      (** Target PC → state to restore when its label is marked. *)
  ; mutable acc_live : bool
  ; mutable acc_kind : kind
  ; mutable slots : slot_info list
      (** Most-recently-pushed first. Length always equals
          [oc_stack_depth]. *)
  ; mutable oc_stack_depth : int
  ; mutable next_local : int
      (** Monotonically-increasing allocator for JVM locals that back
          OCaml-stack values. Locals are never recycled — closure
          captures rely on live locals surviving past slot-pop events. *)
  ; mutable pending_cmp : cmp_op option
  ; nargs : int
  ; ncaps : int
  ; capture_kinds : kind list
  ; enclosing_function_name : string option
      (** [None] inside [main]; [Some name] inside a function body. *)
  ; pending_handlers : (int, Jvm.Code.label) Hashtbl.t
      (** Bytecode PC of a try-with handler → JVM label where the
          [CamlException] unwrap prelude must be emitted just before
          the user's own handler label. *)
  ; mutable open_traps : (Jvm.Code.label * Jvm.Code.label) list
      (** Stack of [(try-region-start, handler-prelude-label)]. *)
  ; fresh_oo_id_counter : int ref
  ; mutable pending_retaddrs : int
      (** Number of [PUSH_RETADDR]s whose matching [APPLY] is still
          outstanding. Each bumps and un-bumps this counter so the
          three sentinel slots get popped post-APPLY. *)
  }

val ensure_kind : state -> kind -> unit
(** If [state.acc_kind = K_obj], emit a [checkcast]/unbox to [target] and
    update the tracker. If [acc_kind] already matches [target],
    no-op. If it's an incompatible specific kind, fail — that's a
    compiler-internal bug. *)

val record_branch_target : state -> int -> unit

val stack_slot_local : state:state -> int -> int

val top_slot_local : state:state -> int

val allocate_local : state -> int
(** Allocate the next JVM local for an OCaml-stack push. Monotonic. *)

val allocate_local_for_kind : state -> kind -> int
(** Like [allocate_local] but reserves [Kind.local_slots_for_kind kind]
    slots (2 for [K_float], 1 for every other kind). Returns the low
    index of the reservation. *)

val kind_of_slot_from_top : state:state -> int -> kind

val push_slot : state -> kind -> int -> unit

val pop_slots : state -> int -> unit

val consume_top : state -> unit
(** [pop_slots state 1] — one-arg arithmetic consumes the top slot
    (acc + top). Used by every arith emitter. *)

val label_at : state -> int -> Jvm.Code.label

val drop_live_acc : state -> unit
(** If the acc is live, pop its JVM-operand-stack slots (1 for most
    kinds, 2 for [K_float]). A no-op when the acc is dead. *)

val overwrite_acc : state -> kind -> (unit -> unit) -> unit
(** [overwrite_acc state kind emit] pops the current live acc (if any),
    calls [emit] to produce the new acc value, and records the new
    [kind]. *)

val box_acc_to_object : state -> unit
(** If [state.acc_kind = K_int], emit [Integer.valueOf] to box the acc
    into an Object reference. Otherwise a no-op. Does not touch
    [state.acc_kind] — callers that care about the resulting kind
    update it themselves. *)

val emit_throw_unsupported : state -> string -> unit
(** Emit [throw new java.lang.UnsupportedOperationException(msg)].
    Used as a placeholder for opcodes we haven't implemented yet.
    Resets [acc_live=false], [acc_kind=K_int]. *)
