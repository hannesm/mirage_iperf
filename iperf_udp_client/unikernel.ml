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

open Lwt.Infix

type stats = {
  mutable bytes: int64;
  mutable start_time: int64;
  mutable last_time: int64;
}

module Main (S: Mirage_types_lwt.STACKV4) (Time : Mirage_types_lwt.TIME) = struct

  let blen = 1460

  let msg =
    Cstruct.of_string "01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789001234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890"

  let mlen =
    if blen <= Cstruct.len msg then blen
    else Cstruct.len msg

  let print_cstruct_stats () =
    Logs.info (fun m -> m "cstruct stats %a" Cstruct.pp_stat (Cstruct.get_stat ()))

  let print_iopage_stats () =
    Logs.info (fun m -> m "iopage stats %a" Io_page.pp_stat (Io_page.get_stat ()))

  let print_data st =
    let duration = Int64.sub st.last_time st.start_time in
    let rate = (Int64.float_of_bits st.bytes) /. (Int64.float_of_bits duration) *. 1000. *. 1000. *. 1000. in
    Logs.info (fun f -> f  "iperf client: Duration = %.0Lu [ns] (start_t = %.0Lu, end_t = %.0Lu),  Data sent = %Ld [bytes], Throughput = %.2f [bytes/sec]" duration st.start_time st.last_time st.bytes rate);
    Logs.info (fun f -> f  "iperf client: Throughput = %.2f [MBs/sec]"  (rate /. 1000000.));
    print_cstruct_stats ();
    print_iopage_stats ();
    Lwt.return_unit

  let write_and_check ip port udp buf =
    S.UDPV4.write ~dst:ip ~dst_port:port udp buf >|= Rresult.R.get_ok

  (* set a UDP diagram ID for the C-based iperf *)
  let set_id buf num =
    if Cstruct.len buf = 0 then ()
    else Cstruct.BE.set_uint32 buf 0 (Int32.of_int num)

  (* client function *)
  let iperfclient amt dest_ip dport udp clock =
    Logs.info (fun f -> f  "iperf client: Trying to connect to a server at %a:%d, buffer size = %d, protocol = udp" Ipaddr.V4.pp dest_ip dport mlen);
    Logs.info (fun f -> f  "iperf client: %.0d bytes data transfer initiated." amt);
    let body = amt / mlen in
    let reminder = amt - (mlen * body) in
    Cstruct.BE.set_uint64 msg 0 0L ;
    Cstruct.BE.set_uint64 msg 8 0L ;
    Cstruct.BE.set_uint64 msg 16 0L ;
    Cstruct.BE.set_uint64 msg 24 0L ;
    Cstruct.BE.set_uint64 msg 32 0L ;

    (* Loop function for packet sending *)
    let rec loop num body st =
      match num with
      (* Send the first packet to notify the start of a measurement *)
      | 0 ->
        set_id msg 0;
        write_and_check dest_ip dport udp msg >>= fun () ->
        st.start_time <- Mclock.elapsed_ns clock;
        loop (num + 1) body st
      (* Send a closing packet(s) to complete the measurement *)
      | -1 -> if reminder = 0 then
        begin
          set_id msg (-1 * body);
          write_and_check dest_ip dport udp msg >>= fun () ->
          st.last_time <- Mclock.elapsed_ns clock;
          st.bytes <- (Int64.add st.bytes (Int64.of_int (Cstruct.len msg)));
          Lwt.return_unit
        end
        else
        begin
          set_id msg body;
          write_and_check dest_ip dport udp msg >>= fun () ->
          st.bytes <- (Int64.add st.bytes (Int64.of_int (Cstruct.len msg)));
          let msg' = Cstruct.sub msg 0 reminder in
          set_id msg' (-1 * (body + 1));
          write_and_check dest_ip dport udp msg' >>= fun () ->
          st.last_time <- Mclock.elapsed_ns clock;
          st.bytes <- (Int64.add st.bytes (Int64.of_int (Cstruct.len msg')));
          Lwt.return_unit
        end
      (* Usual packet sending *)
      | n ->
        if num = body then
          loop (-1) body st
        else begin
          set_id msg n;
          write_and_check dest_ip dport udp msg >>= fun () ->
          st.bytes <- (Int64.add st.bytes (Int64.of_int (Cstruct.len msg)));
          loop (num + 1) body st
        end
    in

    (* Measurement *)
    let t0 = Mclock.elapsed_ns clock in
    let st = {
      bytes=0L; start_time = t0; last_time = t0
    } in
    loop 0 body st >>= fun () ->

    (* Print the obtained result *)
    print_data st >>= fun () ->
    Logs.info (fun f -> f  "iperf client: Done.");
    Time.sleep_ns (Duration.of_sec 3) >>= fun () ->
    Lwt.return_unit

  let start s _time =
    Time.sleep_ns (Duration.of_sec 1) >>= fun () -> (* Give server 1.0 s to call listen *)
    let port = Key_gen.port () in
    S.listen_udpv4 s ~port (fun ~src ~dst ~src_port buf ->
      Logs.info (fun f -> f "iperf client: %.0Lu bytes received on the server side." (Cstruct.BE.get_uint64 buf 16));
      Lwt.return_unit
    );
    Lwt.async (fun () -> S.listen s);
    let udp = S.udpv4 s in
    Mclock.connect () >>= fun clock ->
    iperfclient (Key_gen.size ()) (Key_gen.ip ()) port udp clock

end
