open Code

type stats = { folded : int }

(* Resolve a prim arg to a literal constant, consulting the local
   env for [Pv] and returning the raw constant for [Pc]. Returns
   [None] otherwise. *)
let resolve env = function
  | Pc c -> Some c
  | Pv v ->
    (match Hashtbl.find_opt env v with
     | Some c -> Some c
     | None -> None)

(* JVM ints wrap at 32 bits — keep fold results inside that band so
   a later emitter can always represent them with [iconst] / [bipush]
   / [sipush] / [ldc] without needing [long]. The OCaml bytecode's
   native int is 63-bit but our backend already truncates, so
   matching that behaviour on the constant path is strictly safer. *)
let wrap n =
  let n = n land 0xffffffff in
  if n >= 0x80000000 then n - 0x100000000 else n

let i n = Some (Int (wrap n))

let fold_int_binop op a b =
  match op with
  | "add_int" -> Some (a + b)
  | "sub_int" -> Some (a - b)
  | "mul_int" -> Some (a * b)
  | "div_int" -> if b = 0 then None else Some (a / b)
  | "mod_int" -> if b = 0 then None else Some (a mod b)
  | "and_int" -> Some (a land b)
  | "or_int" -> Some (a lor b)
  | "xor_int" -> Some (a lxor b)
  | "lsl_int" -> Some (a lsl (b land 31))
  | "lsr_int" -> Some ((a land 0xffffffff) lsr (b land 31))
  | "asr_int" -> Some (a asr (b land 31))
  | _ -> None

let fold_prim env (p : prim) (args : prim_arg list) : constant option =
  let consts = List.filter_map (resolve env) args in
  if List.length consts <> List.length args
  then None
  else
    match p, consts with
    | Not, [ Int n ] -> i (1 - n)
    | IsInt, [ Int _ ] -> i 1
    | IsInt, [ Block _ ] | IsInt, [ Float _ ] | IsInt, [ String _ ] -> i 0
    | Eq, [ Int a; Int b ] -> i (if a = b then 1 else 0)
    | Neq, [ Int a; Int b ] -> i (if a <> b then 1 else 0)
    | Lt, [ Int a; Int b ] -> i (if a < b then 1 else 0)
    | Le, [ Int a; Int b ] -> i (if a <= b then 1 else 0)
    | Gt, [ Int a; Int b ] -> i (if a > b then 1 else 0)
    | Ge, [ Int a; Int b ] -> i (if a >= b then 1 else 0)
    | Ult, [ Int a; Int b ] ->
      (* Unsigned compare: treat as 32-bit unsigned. *)
      let ua = a land 0xffffffff and ub = b land 0xffffffff in
      i (if ua < ub then 1 else 0)
    | Uge, [ Int a; Int b ] ->
      let ua = a land 0xffffffff and ub = b land 0xffffffff in
      i (if ua >= ub then 1 else 0)
    | Vectlength, [ Block (_, fs) ] -> i (Array.length fs)
    | Extern "neg_int", [ Int n ] -> i (-n)
    | Extern name, [ Int a; Int b ] ->
      (match fold_int_binop name a b with
       | Some n -> i n
       | None -> None)
    | _ -> None

let run (prog : program) : program * stats =
  let folded = ref 0 in
  let blocks =
    Addr.Map.map
      (fun b ->
        let env = Hashtbl.create 8 in
        let body =
          List.map
            (fun instr ->
              match instr with
              | Let (x, Constant c) ->
                Hashtbl.replace env x c;
                instr
              | Let (x, Prim (p, args)) ->
                (match fold_prim env p args with
                 | Some c ->
                   incr folded;
                   Hashtbl.replace env x c;
                   Let (x, Constant c)
                 | None -> instr)
              | _ -> instr)
            b.body
        in
        { b with body })
      prog.blocks
  in
  { prog with blocks }, { folded = !folded }

let f prog =
  let prog, _ = run prog in
  prog
