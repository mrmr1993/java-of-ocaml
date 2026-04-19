(** A builder for a method body (the bytes of a [Code] attribute). *)

type t

(** Opaque forward-reference labels. Create with [fresh_label]; emit references
    with any of the branch ops; pin to the current position with [mark_label]. *)
type label

val create : Jvm_constant_pool.t -> t

val fresh_label : t -> label

val label_id : label -> int
(** Monotonically-increasing id, stable across the method body.
    Useful for debug prints correlating labels to PCs. *)

val mark_label : t -> label -> unit

val set_min_locals : t -> int -> unit
(** Ensure [max_locals] is at least [n]. *)

(** {1 Loads / stack manipulation} *)

val ldc_string : t -> string -> unit

val ldc_int : t -> int -> unit
(** Push an [int]. Chooses the tightest of iconst_* / bipush / sipush / ldc. *)

val dup : t -> unit

val dup2 : t -> unit

val pop_top : t -> unit

val aconst_null : t -> unit
(** Push the null reference (JVM [aconst_null], 0x01). *)

val swap : t -> unit

(** {1 Local-variable loads/stores} *)

val istore : t -> int -> unit
val iload : t -> int -> unit
val astore : t -> int -> unit
val aload : t -> int -> unit
val dstore : t -> int -> unit
val dload : t -> int -> unit

val ldc_double : t -> float -> unit
(** Push a double constant (JVM [ldc2_w]; occupies 2 operand slots). *)

val pop2 : t -> unit
(** Discard the top 2 operand-stack slots (JVM [pop2], 0x58). Used to
    drop a double or a pair of category-1 values. *)

(** {1 Arrays} *)

val newarray_int : t -> unit
val iaload : t -> unit
val iastore : t -> unit
val arraylength : t -> unit
val anewarray : t -> string -> unit
val aaload : t -> unit
val aastore : t -> unit

(** {1 References} *)

val checkcast : t -> string -> unit
val new_ : t -> string -> unit

val invokespecial :
  t -> class_:string -> method_:string -> descriptor:string -> unit

val getfield :
  t -> class_:string -> field:string -> descriptor:string -> unit

val putfield :
  t -> class_:string -> field:string -> descriptor:string -> unit

(** {1 Integer arithmetic} *)

val iadd : t -> unit
val isub : t -> unit
val imul : t -> unit
val idiv : t -> unit
val irem : t -> unit
val ineg : t -> unit
val iand : t -> unit
val ior : t -> unit
val ixor : t -> unit
val ishl : t -> unit
val ishr : t -> unit
val iushr : t -> unit

(** {1 Double arithmetic / conversions} *)

val dadd : t -> unit
val dsub : t -> unit
val dmul : t -> unit
val ddiv : t -> unit
val dneg : t -> unit

val dcmpl : t -> unit
(** JVM [dcmpl]: pops 2 doubles and pushes -1/0/1; NaN pushes -1. *)

val dcmpg : t -> unit
(** JVM [dcmpg]: pops 2 doubles and pushes -1/0/1; NaN pushes +1. *)

val d2i : t -> unit
val i2d : t -> unit

(** {1 Branches} *)

val if_icmpeq : t -> label -> unit
val if_icmpne : t -> label -> unit
val if_icmplt : t -> label -> unit
val if_icmple : t -> label -> unit
val if_icmpgt : t -> label -> unit
val if_icmpge : t -> label -> unit

val ifeq : t -> label -> unit
val ifne : t -> label -> unit
val iflt : t -> label -> unit
val ifge : t -> label -> unit
val ifgt : t -> label -> unit
val ifle : t -> label -> unit

val if_acmpeq : t -> label -> unit
val if_acmpne : t -> label -> unit

val goto : t -> label -> unit

val goto_w : t -> label -> unit
(** 4-byte branch-offset [goto]. Use when a caller may be further
    than the signed 16-bit range (~32 KB) from the branch PC. *)

val tableswitch :
  t -> default:label -> low:int -> high:int -> label array -> unit
(** Emit a [tableswitch]: pops an int selector and branches to
    [targets.(selector - low)] if [low <= selector <= high], else to
    [default]. [Array.length targets] must equal [high - low + 1].
    Uses 4-byte offsets, so targets may be arbitrarily far. *)

val instanceof_ : t -> string -> unit

val athrow : t -> unit

val add_exception_handler :
  t
  -> start_lbl:label
  -> end_lbl:label
  -> handler_lbl:label
  -> catch_class:string option
  -> unit

val handler_stack_prelude : t -> unit

(** {1 Static/virtual dispatch} *)

val getstatic :
  t -> class_:string -> field:string -> descriptor:string -> unit

val putstatic :
  t -> class_:string -> field:string -> descriptor:string -> unit

val invokevirtual :
  t -> class_:string -> method_:string -> descriptor:string -> unit

val invokestatic :
  t -> class_:string -> method_:string -> descriptor:string -> unit

val return_void : t -> unit
val ireturn : t -> unit
val areturn : t -> unit

(** {1 Finalisation}

    Used by the class-file assembler. After [contents] runs, labels are
    resolved, [max_stack] and [max_locals] are final, and the exception table
    can be read off. *)

val contents : t -> string

val max_stack : t -> int

val max_locals : t -> int

val exception_entries : t -> (int * int * int * int) list
(** [(start_pc, end_pc, handler_pc, catch_type_cp_idx)] for each registered
    handler, in registration order. May only be called after [contents]. *)
