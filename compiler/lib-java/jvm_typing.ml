type t = { kinds : Kind.kind Code.Var.Hashtbl.t }

let kind_of_constant (c : Code.constant) : Kind.kind =
  match c with
  | Int _ -> K_int
  | Float _ -> K_float
  | String _ -> K_string
  | Block (_, fields) ->
    K_block (List.init (Array.length fields) (fun _ -> Kind.K_obj))
  | Null -> K_obj

let kind_of_prim (p : Code.prim) : Kind.kind =
  match p with
  | Vectlength -> K_int
  | Array_get -> K_obj
  | Not | IsInt | Eq | Neq | Lt | Le | Gt | Ge | Ult | Uge -> K_int
  | Extern s ->
    (match s with
     | "add_int" | "sub_int" | "mul_int" | "div_int" | "mod_int"
     | "and_int" | "or_int" | "xor_int" | "lsl_int" | "lsr_int"
     | "asr_int" | "neg_int" | "get_byte" ->
       K_int
     | _ -> K_obj)

let kind_of_expr (e : Code.expr) : Kind.kind =
  match e with
  | Apply _ -> K_obj
  | Block (_, fields) ->
    K_block (List.init (Array.length fields) (fun _ -> Kind.K_obj))
  | Field _ -> K_obj
  | Closure { body = body_pc, _; _ } ->
    (* Tag with the class name so jvm_generate's set_sibling handler
       can recover it via kind lookup. The class name is derivable
       from the body pc via the compile driver's body_pc → name
       table, but jvm_typing doesn't have access to that map — pass
       the pc itself as the "name" placeholder and let
       jvm_generate resolve when needed. *)
    K_closure { name = string_of_int body_pc; captures = [] }
  | Constant c -> kind_of_constant c
  | Prim (p, _) -> kind_of_prim p

let rec join (a : Kind.kind) (b : Kind.kind) : Kind.kind =
  match a, b with
  | K_obj, _ | _, K_obj -> K_obj
  | K_int, K_int -> K_int
  | K_float, K_float -> K_float
  | K_string, K_string -> K_string
  | K_block ks1, K_block ks2 when List.length ks1 = List.length ks2 ->
    K_block (List.map2 join ks1 ks2)
  | K_closure c, K_closure c' when c.name = c'.name -> a
  | _ -> K_obj

let infer (program : Code.program) : t =
  let kinds = Code.Var.Hashtbl.create 64 in
  let set v k =
    match Code.Var.Hashtbl.find_opt kinds v with
    | Some k' -> Code.Var.Hashtbl.replace kinds v (join k k')
    | None -> Code.Var.Hashtbl.add kinds v k
  in
  Code.Addr.Map.iter
    (fun _ (b : Code.block) ->
      List.iter
        (fun i ->
          match (i : Code.instr) with
          | Let (x, e) -> set x (kind_of_expr e)
          | Set_field _ | Offset_ref _ | Array_set _ | Source_pc _ -> ())
        b.body)
    program.blocks;
  { kinds }

let kind t v =
  match Code.Var.Hashtbl.find_opt t.kinds v with
  | Some k -> k
  | None -> Kind.K_obj
