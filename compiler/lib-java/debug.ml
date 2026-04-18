let debugs : (string * bool ref) list ref = ref []

let env_flags =
  lazy
    (match Sys.getenv_opt "JAVA_OF_OCAML_DEBUG" with
     | None | Some "" -> []
     | Some s -> String.split_on_char ',' s |> List.map String.trim)

let register name =
  let state = ref (List.mem name (Lazy.force env_flags)) in
  debugs := (name, state) :: !debugs;
  state

let find name =
  let state =
    match List.assoc_opt name !debugs with
    | Some s -> s
    | None -> register name
  in
  fun () -> !state

let enable name =
  match List.assoc_opt name !debugs with
  | Some s -> s := true
  | None ->
      let s = register name in
      s := true

let disable name =
  match List.assoc_opt name !debugs with
  | Some s -> s := false
  | None -> ignore (register name)

let available () = List.map fst !debugs
