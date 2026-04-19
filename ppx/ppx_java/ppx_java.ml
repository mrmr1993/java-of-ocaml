(* Sugar for the Java FFI.

   Rewrites:
     obj ## meth a1 a2       → Java.Unsafe.meth_call obj "meth"
                                 [| Java.Unsafe.inject a1
                                  ; Java.Unsafe.inject a2 |]
     obj ## meth             → Java.Unsafe.meth_call obj "meth" [||]
     [%java.new "C" a1 ...]  → Java.Unsafe.new_obj "C"
                                 [| Java.Unsafe.inject a1; ... |]
     [%java.static "C" "m" a1 ...]
                             → Java.Unsafe.static_meth_call "C" "m"
                                 [| Java.Unsafe.inject a1; ... |]
     [%java.get obj "field"] → Java.Unsafe.get obj "field"
     [%java.set obj "field" v]
                             → Java.Unsafe.set obj "field" v

   All rewritten forms route through [Java.Unsafe], which dispatches
   reflectively via the [JavaFFI] runtime class. For performance-
   sensitive call sites, users can keep hand-written [external]
   declarations whose primitive name encodes a specific JVM
   descriptor — the compiler's [emit_java_ffi] emits direct
   [invoke*] / [getfield] / [new] sequences for those. *)

open Ppxlib

let build_unsafe_ref ~loc name =
  let txt = Longident.parse ("Java.Unsafe." ^ name) in
  Ast_helper.Exp.ident ~loc { txt; loc }

(* Build [| Java.Unsafe.inject a1; Java.Unsafe.inject a2; ... |] from a
   list of argument expressions. *)
let build_inject_array ~loc args =
  let inject e =
    let inj = build_unsafe_ref ~loc:e.pexp_loc "inject" in
    [%expr [%e inj] [%e e]]
  in
  let wrapped = List.map inject args in
  Ast_helper.Exp.array ~loc wrapped

(* Collect args of a Pexp_apply; only positional args are supported. *)
let pull_positional_args args =
  List.map
    (fun (label, e) ->
      match label with
      | Nolabel -> e
      | _ ->
        Location.raise_errorf
          ~loc:e.pexp_loc
          "ppx_java: labeled / optional arguments not supported at FFI call sites")
    args

let expand_method_call ~loc obj meth args =
  let meth_lit = Ast_helper.Exp.constant ~loc (Pconst_string (meth, loc, None)) in
  let call = build_unsafe_ref ~loc "meth_call" in
  let arr = build_inject_array ~loc args in
  [%expr [%e call] [%e obj] [%e meth_lit] [%e arr]]

(* Extract the [fn args] shape of an extension payload's single
   expression: [%java.X "s1" "s2" a b c] — first N strings are
   positional config, remaining become the inject-array. *)
let extract_apply ~ext_name payload =
  match payload with
  | PStr [ { pstr_desc = Pstr_eval (e, _); _ } ] -> e
  | _ ->
    Location.raise_errorf
      ~loc:Location.none
      "ppx_java: [%s] expects a single expression payload"
      ext_name

let expect_string_arg ~ext_name e =
  match e.pexp_desc with
  | Pexp_constant (Pconst_string (s, _, _)) -> s
  | _ ->
    Location.raise_errorf
      ~loc:e.pexp_loc
      "ppx_java: [%s] expects a string literal here"
      ext_name

let expand_java_new ~loc payload =
  let e = extract_apply ~ext_name:"java.new" payload in
  match e.pexp_desc with
  | Pexp_apply (class_expr, args) ->
    let class_name = expect_string_arg ~ext_name:"java.new" class_expr in
    let args = pull_positional_args args in
    let class_lit = Ast_helper.Exp.constant ~loc (Pconst_string (class_name, loc, None)) in
    let call = build_unsafe_ref ~loc "new_obj" in
    let arr = build_inject_array ~loc args in
    [%expr [%e call] [%e class_lit] [%e arr]]
  | Pexp_constant (Pconst_string (class_name, _, _)) ->
    (* Zero-arg constructor: [%java.new "C"]. *)
    let class_lit = Ast_helper.Exp.constant ~loc (Pconst_string (class_name, loc, None)) in
    let call = build_unsafe_ref ~loc "new_obj" in
    [%expr [%e call] [%e class_lit] [||]]
  | _ ->
    Location.raise_errorf
      ~loc
      "ppx_java: [%%java.new] expects [\"ClassName\" arg1 arg2 ...]"

let expand_java_static ~loc payload =
  let e = extract_apply ~ext_name:"java.static" payload in
  match e.pexp_desc with
  | Pexp_apply (class_expr, meth_and_args) ->
    let class_name = expect_string_arg ~ext_name:"java.static" class_expr in
    (match meth_and_args with
     | (Nolabel, meth_expr) :: rest ->
       let meth_name = expect_string_arg ~ext_name:"java.static" meth_expr in
       let args = pull_positional_args rest in
       let class_lit =
         Ast_helper.Exp.constant ~loc (Pconst_string (class_name, loc, None))
       in
       let meth_lit =
         Ast_helper.Exp.constant ~loc (Pconst_string (meth_name, loc, None))
       in
       let call = build_unsafe_ref ~loc "static_meth_call" in
       let arr = build_inject_array ~loc args in
       [%expr [%e call] [%e class_lit] [%e meth_lit] [%e arr]]
     | _ ->
       Location.raise_errorf
         ~loc
         "ppx_java: [%%java.static] expects [\"Class\" \"method\" args]")
  | _ ->
    Location.raise_errorf ~loc "ppx_java: [%%java.static] expects [\"Class\" \"method\" args]"

let expand_java_get ~loc payload =
  let e = extract_apply ~ext_name:"java.get" payload in
  match e.pexp_desc with
  | Pexp_apply (obj_expr, [ (Nolabel, field_expr) ]) ->
    let field = expect_string_arg ~ext_name:"java.get" field_expr in
    let field_lit = Ast_helper.Exp.constant ~loc (Pconst_string (field, loc, None)) in
    let call = build_unsafe_ref ~loc "get" in
    [%expr [%e call] [%e obj_expr] [%e field_lit]]
  | _ -> Location.raise_errorf ~loc "ppx_java: [%%java.get] expects [obj \"field\"]"

let expand_java_set ~loc payload =
  let e = extract_apply ~ext_name:"java.set" payload in
  match e.pexp_desc with
  | Pexp_apply (obj_expr, [ (Nolabel, field_expr); (Nolabel, value_expr) ]) ->
    let field = expect_string_arg ~ext_name:"java.set" field_expr in
    let field_lit = Ast_helper.Exp.constant ~loc (Pconst_string (field, loc, None)) in
    let call = build_unsafe_ref ~loc "set" in
    [%expr [%e call] [%e obj_expr] [%e field_lit] [%e value_expr]]
  | _ -> Location.raise_errorf ~loc "ppx_java: [%%java.set] expects [obj \"field\" v]"

(* Is this expression [(##)] operator-as-identifier? OCaml doesn't
   treat [obj##meth] specially — it parses as [(##) obj meth] where
   [##] is a normal operator. Since the project doesn't define a
   [##] binding, we hijack the operator entirely: every
   [Pexp_apply ({Pexp_ident "##"}, [obj; meth_ident])] becomes a
   method call. *)
let is_hash_hash e =
  match e.pexp_desc with
  | Pexp_ident { txt = Lident "##"; _ } -> true
  | _ -> false

(* Strip an outer [(##)] to extract the [obj] and method-name. *)
let match_hash_hash e =
  match e.pexp_desc with
  | Pexp_apply (fn, [ (Nolabel, obj); (Nolabel, meth_e) ]) when is_hash_hash fn ->
    let meth =
      match meth_e.pexp_desc with
      | Pexp_ident { txt = Lident n; _ } -> n
      | _ ->
        Location.raise_errorf
          ~loc:meth_e.pexp_loc
          "ppx_java: method name after [##] must be a simple identifier"
    in
    Some (obj, meth)
  | _ -> None

let traverse =
  object (self)
    inherit Ast_traverse.map as super

    method! expression e =
      let loc = e.pexp_loc in
      match e.pexp_desc with
      (* obj##meth a1 a2 — outer [Pexp_apply] whose function is itself
         a [(##) obj meth] apply. *)
      | Pexp_apply (fn, args) when Option.is_some (match_hash_hash fn) ->
        let obj, meth = Option.get (match_hash_hash fn) in
        let obj = self#expression obj in
        let args = pull_positional_args args |> List.map self#expression in
        expand_method_call ~loc obj meth args
      (* Bare obj##meth — zero-arg method call. *)
      | _ when Option.is_some (match_hash_hash e) ->
        let obj, meth = Option.get (match_hash_hash e) in
        let obj = self#expression obj in
        expand_method_call ~loc obj meth []
      (* [%java.new ...], [%java.static ...], [%java.get ...],
         [%java.set ...]. *)
      | Pexp_extension ({ txt = "java.new"; _ }, payload) ->
        expand_java_new ~loc payload
      | Pexp_extension ({ txt = "java.static"; _ }, payload) ->
        expand_java_static ~loc payload
      | Pexp_extension ({ txt = "java.get"; _ }, payload) ->
        expand_java_get ~loc payload
      | Pexp_extension ({ txt = "java.set"; _ }, payload) ->
        expand_java_set ~loc payload
      | _ -> super#expression e
  end

let () =
  Driver.register_transformation
    "ppx_java"
    ~impl:(fun str -> traverse#structure str)
    ~intf:(fun sg -> traverse#signature sg)
