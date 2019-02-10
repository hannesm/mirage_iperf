open Mirage

let port =
  let doc = Key.Arg.info ~doc:"Listening port." ["port"] in
  Key.(create "port" Arg.(opt int 5001 doc))

let sv4 = generic_stackv4 default_network

let main =
  let keys = [ Key.abstract port ] in
  foreign ~keys "Unikernel.Main" (stackv4 @-> job)

let () =
  register "iperf_server" [
    main $ sv4
  ]

