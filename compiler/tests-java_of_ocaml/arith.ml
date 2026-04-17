let () =
  Printf.printf "%d\n" (6 * 7);
  Printf.printf "%f\n" (3.14 *. 2.0);
  Printf.printf "%b\n" (42 > 0);
  Printf.printf "%s\n" (String.concat " " [ "hello"; "world" ])
