open Kind
open Function_info
open State

let self_closure_ref state =
  match state.enclosing_function_name with
  | None ->
    failwith
      "java_of_ocaml: OFFSETCLOSURE0/PUSHOFFSETCLOSURE0 outside a function"
  | Some fname ->
    (* Self-closure: the captures aren't in separate locals anymore — they
       live as instance fields on [this]. We don't need to re-list them;
       what we need is a closure_ref whose [name] matches this method's
       class so APPLY emits the right invokevirtual. The [captures] list
       is left empty because the runtime representation of "self" is just
       [this] (no extra locals to load). *)
    { name = fname; captures = [] }

let emit_offsetclosure0 state =
  let cref = self_closure_ref state in
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.aload state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_closure cref

let emit_pushoffsetclosure0 state =
  let cref = self_closure_ref state in
  let was_live = state.acc_live in
  Emit_stack.emit_push state;
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.aload state.code 0;
  state.acc_live <- true;
  state.acc_kind <- K_closure cref

(* Resolve OFFSETCLOSURE N to the sibling within the enclosing function's
   CLOSUREREC group. OCaml lays out each function's code pointer 3 words
   apart in the shared closure block, so offset N corresponds to moving
   [N/3] sibling positions. *)
let resolve_sibling state offset =
  let self_fi =
    match state.enclosing_function_name with
    | None -> failwith "java_of_ocaml: OFFSETCLOSURE outside a function"
    | Some name ->
      (match Hashtbl.find_opt state.fn_by_name name with
       | Some fi -> fi
       | None ->
         failwith
           (Printf.sprintf
              "java_of_ocaml: enclosing function %s not registered"
              name))
  in
  let target_idx = self_fi.group_idx + (offset / 3) in
  if target_idx < 0 || target_idx >= Array.length self_fi.group
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: OFFSETCLOSURE %d out of range for group of %d"
         offset
         (Array.length self_fi.group));
  self_fi, self_fi.group.(target_idx), target_idx

let emit_offsetclosure state offset =
  if offset = 0 then emit_offsetclosure0 state
  else (
    let self_fi, target_fi, target_idx = resolve_sibling state offset in
    if state.acc_live then Jvm.Code.pop_top state.code;
    Jvm.Code.aload state.code 0;
    Jvm.Code.getfield
      state.code
      ~class_:self_fi.name
      ~field:(Printf.sprintf "sibling_%d" target_idx)
      ~descriptor:"LClosure;";
    state.acc_live <- true;
    state.acc_kind <- K_closure { name = target_fi.name; captures = [] })

let emit_pushoffsetclosure state offset =
  if offset = 0 then emit_pushoffsetclosure0 state
  else (
    let self_fi, target_fi, target_idx = resolve_sibling state offset in
    let was_live = state.acc_live in
    Emit_stack.emit_push state;
    if was_live then Jvm.Code.pop_top state.code;
    Jvm.Code.aload state.code 0;
    Jvm.Code.getfield
      state.code
      ~class_:self_fi.name
      ~field:(Printf.sprintf "sibling_%d" target_idx)
      ~descriptor:"LClosure;";
    state.acc_live <- true;
    state.acc_kind <- K_closure { name = target_fi.name; captures = [] })

let capture_kind_at state cap_index =
  try List.nth state.capture_kinds cap_index with
  | _ ->
    failwith
      (Printf.sprintf
         "java_of_ocaml: ENVACC capture index %d out of range (ncaps=%d)"
         cap_index
         state.ncaps)

let emit_envacc state k =
  if k < 2
  then
    failwith
      (Printf.sprintf
         "java_of_ocaml: ENVACC %d (field <2) not supported — closure \
          info fields aren't modelled"
         k);
  let cap_index = k - 2 in
  let kind = capture_kind_at state cap_index in
  let fname = Printf.sprintf "cap%d" cap_index in
  let desc = jvm_type_of_kind kind in
  let class_ =
    match state.enclosing_function_name with
    | Some n -> n
    | None -> failwith "java_of_ocaml: ENVACC outside a function"
  in
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.aload state.code 0;
  Jvm.Code.getfield state.code ~class_ ~field:fname ~descriptor:desc;
  state.acc_live <- true;
  state.acc_kind <- kind

let emit_pushenvacc state k =
  let was_live = state.acc_live in
  Emit_stack.emit_push state;
  if k < 2
  then
    failwith
      (Printf.sprintf "java_of_ocaml: PUSHENVACC %d (field <2) not supported" k);
  let cap_index = k - 2 in
  let kind = capture_kind_at state cap_index in
  let fname = Printf.sprintf "cap%d" cap_index in
  let desc = jvm_type_of_kind kind in
  let class_ =
    match state.enclosing_function_name with
    | Some n -> n
    | None -> failwith "java_of_ocaml: PUSHENVACC outside a function"
  in
  if was_live then Jvm.Code.pop_top state.code;
  Jvm.Code.aload state.code 0;
  Jvm.Code.getfield state.code ~class_ ~field:fname ~descriptor:desc;
  state.acc_live <- true;
  state.acc_kind <- kind

let ctor_descriptor_for_captures cap_kinds =
  let buf = Buffer.create 16 in
  Buffer.add_char buf '(';
  List.iter (fun k -> Buffer.add_string buf (jvm_type_of_kind k)) cap_kinds;
  Buffer.add_string buf ")V";
  Buffer.contents buf

let kinds_compatible a b =
  match a, b with
  | K_int, K_int -> true
  | K_string, K_string -> true
  | K_block _, K_block _ -> true
  | K_closure _, K_closure _ -> true
  | _ -> false

let emit_closure_creation state (fn_info : function_info) ~nvars ~is_rec =
  let captures =
    if nvars = 0
    then []
    else (
      if not state.acc_live
      then
        failwith
          "java_of_ocaml: CLOSURE/CLOSUREREC with nvars>0 requires a live acc";
      Emit_stack.emit_push state;
      let rec loop k acc =
        if k >= nvars
        then List.rev acc
        else (
          let slot = List.nth state.slots k in
          loop (k + 1) ((slot.local, slot.kind) :: acc))
      in
      let caps = loop 0 [] in
      pop_slots state nvars;
      caps)
  in
  let collected_kinds = List.map snd captures in
  (match !(fn_info.capture_kinds) with
   | [] -> fn_info.capture_kinds := collected_kinds
   | existing
     when List.length existing = List.length collected_kinds
          && List.for_all2 kinds_compatible existing collected_kinds -> ()
   | _ ->
     failwith
       (Printf.sprintf
          "java_of_ocaml: inconsistent capture kinds for function %s"
          fn_info.name));
  let cref = { name = fn_info.name; captures } in
  if state.acc_live then Jvm.Code.pop_top state.code;
  Jvm.Code.new_ state.code fn_info.name;
  Jvm.Code.dup state.code;
  List.iter
    (fun (local, kind) -> emit_load_for_kind state.code local kind)
    captures;
  Jvm.Code.invokespecial
    state.code
    ~class_:fn_info.name
    ~method_:"<init>"
    ~descriptor:(ctor_descriptor_for_captures collected_kinds);
  state.acc_live <- true;
  state.acc_kind <- K_closure cref;
  if is_rec
  then (
    let local = allocate_local state in
    Jvm.Code.dup state.code;
    Jvm.Code.astore state.code local;
    push_slot state state.acc_kind local)

let emit_closure state (ins : Instr.instr) =
  let fn_info =
    try Hashtbl.find state.functions ins.pc with
    | Not_found ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: CLOSURE at pc %d not registered"
           ins.pc)
  in
  let nvars = ins.args.(0) in
  emit_closure_creation state fn_info ~nvars ~is_rec:false

let emit_closurerec state (ins : Instr.instr) =
  let nfuncs = ins.args.(0) in
  let nvars = ins.args.(1) in
  let head_fi =
    try Hashtbl.find state.functions ins.pc with
    | Not_found ->
      failwith
        (Printf.sprintf
           "java_of_ocaml: CLOSUREREC at pc %d not registered"
           ins.pc)
  in
  if nfuncs = 1
  then emit_closure_creation state head_fi ~nvars ~is_rec:true
  else (
    let group = head_fi.group in
    let n = Array.length group in
    let captures =
      if nvars = 0
      then []
      else (
        if not state.acc_live
        then
          failwith
            "java_of_ocaml: CLOSUREREC with nvars>0 requires a live acc";
        Emit_stack.emit_push state;
        let rec loop k acc =
          if k >= nvars
          then List.rev acc
          else (
            let slot = List.nth state.slots k in
            loop (k + 1) ((slot.local, slot.kind) :: acc))
        in
        let caps = loop 0 [] in
        pop_slots state nvars;
        caps)
    in
    let cap_kinds = List.map snd captures in
    Array.iter
      (fun (fi : function_info) ->
        (match !(fi.capture_kinds) with
         | [] -> fi.capture_kinds := cap_kinds
         | existing
           when List.length existing = List.length cap_kinds
                && List.for_all2 kinds_compatible existing cap_kinds -> ()
         | _ ->
           failwith
             (Printf.sprintf
                "java_of_ocaml: inconsistent capture kinds for function %s"
                fi.name)))
      group;
    if state.acc_live then Jvm.Code.pop_top state.code;
    let instance_locals = Array.make n 0 in
    for k = 0 to n - 1 do
      let fi = group.(k) in
      Jvm.Code.new_ state.code fi.name;
      Jvm.Code.dup state.code;
      List.iter
        (fun (local, kind) -> emit_load_for_kind state.code local kind)
        captures;
      Jvm.Code.invokespecial
        state.code
        ~class_:fi.name
        ~method_:"<init>"
        ~descriptor:(ctor_descriptor_for_captures cap_kinds);
      let l = allocate_local state in
      Jvm.Code.astore state.code l;
      instance_locals.(k) <- l
    done;
    for i = 0 to n - 1 do
      for j = 0 to n - 1 do
        Jvm.Code.aload state.code instance_locals.(i);
        Jvm.Code.aload state.code instance_locals.(j);
        Jvm.Code.putfield
          state.code
          ~class_:group.(i).name
          ~field:(Printf.sprintf "sibling_%d" j)
          ~descriptor:"LClosure;"
      done
    done;
    (* OCaml's CLOSUREREC leaves its N functions on the OCaml stack with
       the LAST-defined function at the top: stack layout from top =
       [f_{n-1}; f_{n-2}; ...; f_0]. acc also holds f_{n-1}. *)
    let last = n - 1 in
    Jvm.Code.aload state.code instance_locals.(last);
    state.acc_live <- true;
    state.acc_kind <- K_closure { name = group.(last).name; captures = [] };
    for k = 0 to n - 1 do
      let local = instance_locals.(k) in
      push_slot state
        (K_closure { name = group.(k).name; captures = [] })
        local
    done;
    ignore ins)
