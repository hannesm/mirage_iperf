(*
 * Copyright (c) 2011 Richard Mortier <mort@cantab.net>
 * Copyright (c) 2012 Balraj Singh <balraj.singh@cl.cam.ac.uk>
 * Copyright (c) 2015 Magnus Skjegstad <magnus@skjegstad.com>
 * Copyright (c) 2017 Takayuki Imada <takayuki.imada@gmail.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

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

let sv4 =
  generic_stackv4 default_network

let main =
  let keys = [ Key.abstract port ; Key.abstract ip ; Key.abstract size ] in
  foreign ~keys "Unikernel.Main" (stackv4 @-> time @-> job)

let () =
  register "iperf_udp_client" [
    main $ sv4 $ default_time
  ]

