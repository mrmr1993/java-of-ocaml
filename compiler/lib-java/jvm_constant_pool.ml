open Jvm_bin

type t =
  { mutable count : int
  ; buf : Buffer.t
  ; table : (string, int) Hashtbl.t
  }

let create () =
  { count = 1 (* entries are 1-based; [count] is the next index to assign *)
  ; buf = Buffer.create 256
  ; table = Hashtbl.create 32
  }

let intern t key emit =
  match Hashtbl.find_opt t.table key with
  | Some idx -> idx
  | None ->
    let idx = t.count in
    t.count <- t.count + 1;
    emit t.buf;
    Hashtbl.add t.table key idx;
    idx

let utf8 t s =
  intern t ("U:" ^ s) (fun buf ->
    add_u1 buf 1;
    add_u2 buf (String.length s);
    Buffer.add_string buf s)

let class_ t name =
  let utf_idx = utf8 t name in
  intern t ("C:" ^ name) (fun buf ->
    add_u1 buf 7;
    add_u2 buf utf_idx)

let string t s =
  let utf_idx = utf8 t s in
  intern t ("S:" ^ s) (fun buf ->
    add_u1 buf 8;
    add_u2 buf utf_idx)

let name_and_type t ~name ~descriptor =
  let n_idx = utf8 t name in
  let d_idx = utf8 t descriptor in
  intern t ("NT:" ^ name ^ ":" ^ descriptor) (fun buf ->
    add_u1 buf 12;
    add_u2 buf n_idx;
    add_u2 buf d_idx)

let class_ref = class_

let fieldref t ~class_ ~field ~descriptor =
  let cls_idx = class_ref t class_ in
  let nt_idx = name_and_type t ~name:field ~descriptor in
  intern t ("F:" ^ class_ ^ ":" ^ field ^ ":" ^ descriptor) (fun buf ->
    add_u1 buf 9;
    add_u2 buf cls_idx;
    add_u2 buf nt_idx)

let methodref t ~class_ ~method_ ~descriptor =
  let cls_idx = class_ref t class_ in
  let nt_idx = name_and_type t ~name:method_ ~descriptor in
  intern t ("M:" ^ class_ ^ ":" ^ method_ ^ ":" ^ descriptor) (fun buf ->
    add_u1 buf 10;
    add_u2 buf cls_idx;
    add_u2 buf nt_idx)

(* [CONSTANT_Double_info] occupies two consecutive constant-pool
   slots per the JVM spec, with index n+1 left unusable. *)
let double t d =
  let key = "D:" ^ Printf.sprintf "%h" d in
  match Hashtbl.find_opt t.table key with
  | Some idx -> idx
  | None ->
    let idx = t.count in
    t.count <- t.count + 2;
    let bits = Int64.bits_of_float d in
    let hi = Int64.to_int (Int64.shift_right_logical bits 32) land 0xFFFFFFFF in
    let lo = Int64.to_int bits land 0xFFFFFFFF in
    add_u1 t.buf 6;
    add_u4 t.buf hi;
    add_u4 t.buf lo;
    Hashtbl.add t.table key idx;
    idx

let long t n =
  let key = "J:" ^ Int64.to_string n in
  match Hashtbl.find_opt t.table key with
  | Some idx -> idx
  | None ->
    let idx = t.count in
    t.count <- t.count + 2;
    let hi = Int64.to_int (Int64.shift_right_logical n 32) land 0xFFFFFFFF in
    let lo = Int64.to_int n land 0xFFFFFFFF in
    add_u1 t.buf 5;
    add_u4 t.buf hi;
    add_u4 t.buf lo;
    Hashtbl.add t.table key idx;
    idx

let count t = t.count - 1

let contents t = Buffer.contents t.buf
