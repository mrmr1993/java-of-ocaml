(** Main-init splitter: turns the monolithic [Code.program] produced
    by [Parse_bytecode.parse_main] into a list of per-compilation-
    unit sub-programs, so each unit's init compiles to its own JVM
    method and main becomes a sequence of normal [invokestatic]
    calls instead of a long [Invoke_tail] chain.

    The transform is opt-in: when [plan] cannot establish that the
    split is structurally safe (CFG edges stay within a unit, no
    active trap region crosses a unit boundary, every cross-unit
    block is attributable to exactly one unit), it returns
    [Rejected] with a human-readable reason and the caller must
    fall back to the single-program [Method_split] path. *)

type unit_slice =
  { modname : string
        (** Originating OCaml module name (e.g. [Stdlib], [Mina_base]). *)
  ; method_name : string
        (** JVM method name for this unit's init — a sanitised form
            of [modname] with a suffix when the set isn't unique
            ([init_Foo], [init_Foo_2]). *)
  ; prog : Code.program
        (** Sub-program covering this unit's blocks. Its [start] is
            the entry block derived from [unit.start_pc]. *)
  }

type plan =
  { units : unit_slice list
        (** In source-order: unit N depends on having run units
            0..N-1. The driver must invoke each in this order. *)
  ; driver_entry_addr : Code.Addr.t
        (** The original program's [start] address. May be a
            parser-synthesized prelude block that doesn't live in
            any unit; in that case [driver_entry_addr] is included
            in the first slice's program. *)
  }

type result =
  | Split of plan
  | Rejected of string

val plan : Code.program -> units:Bytecode.Unit.t list -> result

(** Derive the list of "extra block-start PCs" to pass into
    [Parse_bytecode.parse_main] so that each unit's first
    instruction begins a fresh block. Without this, blocks from
    adjacent units get fused by the parser's straight-line walker
    and the splitter rejects everything. *)
val extra_block_starts : Bytecode.Unit.t list -> int list
