module Addr = struct
  type t = int

  let zero = 0
  let succ x = x + 1
  let to_string = string_of_int

  module Map = Map.Make (Int)
  module Set = Set.Make (Int)
end

module Var = struct
  type t = int

  let counter = ref 0
  let names : (int, string) Hashtbl.t = Hashtbl.create 128

  let fresh () =
    let x = !counter in
    incr counter;
    x

  let fresh_n name =
    let x = fresh () in
    Hashtbl.replace names x name;
    x

  let idx x = x
  let equal = Int.equal
  let compare = Int.compare
  let get_name x = Hashtbl.find_opt names x
  let reset () = counter := 0; Hashtbl.clear names
  let count () = !counter

  let print fmt x =
    match Hashtbl.find_opt names x with
    | Some n -> Format.fprintf fmt "%s_%d" n x
    | None -> Format.fprintf fmt "v%d" x

  module Map = Map.Make (Int)
  module Set = Set.Make (Int)
  module Hashtbl = Hashtbl.Make (struct
    type t = int

    let equal = Int.equal
    let hash = Hashtbl.hash
  end)
end

type cont = Addr.t * Var.t list

type constant =
  | Int of int
  | Float of float
  | String of string
  | Block of int * constant array
  | Null

type prim =
  | Vectlength
  | Array_get
  | Not
  | IsInt
  | Eq
  | Neq
  | Lt
  | Le
  | Gt
  | Ge
  | Ult
  | Uge
  | Extern of string

type prim_arg =
  | Pv of Var.t
  | Pc of constant

type expr =
  | Apply of { f : Var.t; args : Var.t list; exact : bool }
  | Block of int * Var.t array
  | Field of Var.t * int
  | Closure of { captures : Var.t list; body : cont }
  | Constant of constant
  | Prim of prim * prim_arg list

type instr =
  | Let of Var.t * expr
  | Assign of Var.t * Var.t
  | Set_field of Var.t * int * Var.t
  | Offset_ref of Var.t * int
  | Array_set of Var.t * Var.t * Var.t

type last =
  | Return of Var.t
  | Raise of Var.t
  | Stop
  | Branch of cont
  | Cond of Var.t * cont * cont
  | Switch of Var.t * cont array * cont array
  | Pushtrap of cont * Var.t * cont
  | Poptrap of cont
  | Invoke_tail of
      { class_ : string
      ; method_ : string
      ; descriptor : string
      ; args : Var.t list
      ; is_static : bool
      }
      (** Tail-call a helper method on the same class (or on Main for
          static helpers), load each arg as a JVM [Object], and
          [areturn] the result. Emitted by [Method_split] when a
          program is rewritten to spill blocks into auxiliary methods
          for the JVM 65535-byte [Code]-attribute limit. *)

type block =
  { params : Var.t list
  ; body : instr list
  ; branch : last
  }

type program =
  { start : Addr.t
  ; blocks : block Addr.Map.t
  ; free_pc : Addr.t
  }

module Print = struct
  let rec constant fmt = function
    | Int i -> Format.fprintf fmt "%d" i
    | Float f -> Format.fprintf fmt "%g" f
    | String s -> Format.fprintf fmt "%S" s
    | Block (tag, fields) ->
      Format.fprintf fmt "<%d>[" tag;
      Array.iteri
        (fun i c ->
          if i > 0 then Format.fprintf fmt ", ";
          constant fmt c)
        fields;
      Format.fprintf fmt "]"
    | Null -> Format.fprintf fmt "null"

  let prim fmt = function
    | Vectlength -> Format.fprintf fmt "vectlength"
    | Array_get -> Format.fprintf fmt "array_get"
    | Not -> Format.fprintf fmt "not"
    | IsInt -> Format.fprintf fmt "is_int"
    | Eq -> Format.fprintf fmt "eq"
    | Neq -> Format.fprintf fmt "neq"
    | Lt -> Format.fprintf fmt "lt"
    | Le -> Format.fprintf fmt "le"
    | Gt -> Format.fprintf fmt "gt"
    | Ge -> Format.fprintf fmt "ge"
    | Ult -> Format.fprintf fmt "ult"
    | Uge -> Format.fprintf fmt "uge"
    | Extern s -> Format.fprintf fmt "%%%s" s

  let prim_arg fmt = function
    | Pv v -> Var.print fmt v
    | Pc c -> constant fmt c

  let rec var_list fmt = function
    | [] -> ()
    | [ v ] -> Var.print fmt v
    | v :: vs ->
      Var.print fmt v;
      Format.fprintf fmt ", ";
      var_list fmt vs

  let expr fmt = function
    | Apply { f; args; exact } ->
      Format.fprintf
        fmt
        "apply%s(%a, %a)"
        (if exact then "" else "~")
        Var.print
        f
        var_list
        args
    | Block (tag, fields) ->
      Format.fprintf fmt "{%d: " tag;
      Array.iteri
        (fun i v ->
          if i > 0 then Format.fprintf fmt ", ";
          Var.print fmt v)
        fields;
      Format.fprintf fmt "}"
    | Field (v, i) -> Format.fprintf fmt "%a[%d]" Var.print v i
    | Closure { captures; body = addr, args } ->
      Format.fprintf
        fmt
        "closure(captures=[%a]; -> %d(%a))"
        var_list
        captures
        addr
        var_list
        args
    | Constant c -> constant fmt c
    | Prim (p, args) ->
      prim fmt p;
      Format.fprintf fmt "(";
      List.iteri
        (fun i a ->
          if i > 0 then Format.fprintf fmt ", ";
          prim_arg fmt a)
        args;
      Format.fprintf fmt ")"

  let instr fmt = function
    | Let (x, e) -> Format.fprintf fmt "let %a = %a" Var.print x expr e
    | Assign (x, y) -> Format.fprintf fmt "%a := %a" Var.print x Var.print y
    | Set_field (x, i, y) ->
      Format.fprintf fmt "%a[%d] <- %a" Var.print x i Var.print y
    | Offset_ref (x, i) -> Format.fprintf fmt "%a[0] += %d" Var.print x i
    | Array_set (a, i, v) ->
      Format.fprintf fmt "%a[%a] <- %a" Var.print a Var.print i Var.print v

  let cont fmt (addr, args) =
    Format.fprintf fmt "%d(%a)" addr var_list args

  let last fmt = function
    | Return v -> Format.fprintf fmt "return %a" Var.print v
    | Raise v -> Format.fprintf fmt "raise %a" Var.print v
    | Stop -> Format.fprintf fmt "stop"
    | Branch c -> Format.fprintf fmt "branch %a" cont c
    | Cond (v, t, e) ->
      Format.fprintf fmt "if %a then %a else %a" Var.print v cont t cont e
    | Switch (v, ints, tags) ->
      Format.fprintf fmt "switch %a [" Var.print v;
      Array.iteri
        (fun i c ->
          if i > 0 then Format.fprintf fmt " | ";
          Format.fprintf fmt "int %d -> %a" i cont c)
        ints;
      Array.iteri
        (fun i c ->
          Format.fprintf fmt " | tag %d -> %a" i cont c)
        tags;
      Format.fprintf fmt "]"
    | Pushtrap (body, x, handler) ->
      Format.fprintf
        fmt
        "pushtrap %a (%a -> %a)"
        cont
        body
        Var.print
        x
        cont
        handler
    | Poptrap c -> Format.fprintf fmt "poptrap %a" cont c
    | Invoke_tail { class_; method_; descriptor; args; is_static } ->
      Format.fprintf
        fmt
        "invoke_tail %s%s.%s%s(%a)"
        (if is_static then "static " else "")
        class_
        method_
        descriptor
        var_list
        args

  let block fmt addr { params; body; branch = br } =
    Format.fprintf fmt "block %d(%a):@\n" addr var_list params;
    List.iter
      (fun i -> Format.fprintf fmt "  %a@\n" instr i)
      body;
    Format.fprintf fmt "  %a@\n" last br

  let program fmt p =
    Format.fprintf fmt "program (start = %d):@\n" p.start;
    Addr.Map.iter (fun addr b -> block fmt addr b) p.blocks
end

let fold_children p addr f init =
  let b = Addr.Map.find addr p.blocks in
  let step (a, _args) acc = f a acc in
  match b.branch with
  | Return _ | Raise _ | Stop | Invoke_tail _ -> init
  | Branch c -> step c init
  | Cond (_, c1, c2) -> init |> step c1 |> step c2
  | Switch (_, ints, tags) ->
    let after_ints = Array.fold_left (fun acc c -> step c acc) init ints in
    Array.fold_left (fun acc c -> step c acc) after_ints tags
  | Pushtrap (body, _, handler) -> init |> step body |> step handler
  | Poptrap c -> step c init
