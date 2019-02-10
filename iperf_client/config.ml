open Mirage

let port =
  let doc = Key.Arg.info ~doc:"Port to connect to." ["port"] in
  Key.(create "port" Arg.(opt int 5001 doc))

let ip =
  let doc = Key.Arg.info ~doc:"IP to connect to." ["ip"] in
  Key.(create "ip" Arg.(opt ipv4_address Ipaddr.V4.localhost doc))

let size =
  let doc = Key.Arg.info ~doc:"Number of bytes to transfer." ["size"] in
  Key.(create "size" Arg.(opt int 1_000_000_000 doc))

let sv4 = generic_stackv4 default_network

let main =
  let keys = [ Key.abstract port ; Key.abstract ip ; Key.abstract size ] in
  foreign ~keys "Unikernel.Main" (stackv4 @-> time @-> job)

let () =
  (* register "iperf_client" ~tracing [ *)
  register "iperf_client" [
    main $ sv4 $ default_time
  ]

