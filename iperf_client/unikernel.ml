open Lwt.Infix

type stats = {
  mutable bytes: int64;
  mutable start_time: int64;
  mutable last_time: int64;
}

module Main (S: Mirage_types_lwt.STACKV4) (Time : Mirage_types_lwt.TIME) = struct

  let blen = 2048

  let msg =
    Cstruct.of_string
      "01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789001234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890" 

  let mlen =
    if blen <= Cstruct.len msg then blen
    else Cstruct.len msg

  let print_cstruct_stats () =
    Logs.info (fun m -> m "cstruct stats %a" Cstruct.pp_stat (Cstruct.get_stat ()))

  let print_iopage_stats () =
    Logs.info (fun m -> m "iopage stats %a" Io_page.pp_stat (Io_page.get_stat ()))

  let print_data st ts_now =
    let duration = Int64.sub ts_now st.start_time in
    let rate = (Int64.float_of_bits st.bytes) /. (Int64.float_of_bits duration) *. 1000. *. 1000. *. 1000. in
    Logs.info (fun f -> f  "iperf client: Duration = %.0Lu [ns] (start_t = %.0Lu, end_t = %.0Lu),  Data received = %Ld [bytes], Throughput = %.2f [bytes/sec]" duration st.start_time ts_now st.bytes rate);
    Logs.info (fun f -> f  "iperf client: Throughput = %.2f [MBs/sec]"  (rate /. 1000000.));
    print_cstruct_stats () ;
    print_iopage_stats () ;
    Lwt.return_unit

  let err_connect ip port () =
    let ip  = Ipaddr.V4.to_string ip in
    Logs.info (fun f -> f "Unable to connect to %s:%d" ip port);
    Lwt.return_unit

  let write_and_check flow buf =
    S.TCPV4.write flow buf >|= Rresult.R.get_ok

  let tcp_connect t (ip, port) =
    S.TCPV4.create_connection t (ip, port) >|= Rresult.R.get_ok

  let iperfclient s amt dest_ip dport clock =
    let iperftx flow =
      Logs.info (fun f -> f  "iperf client: %.0d bytes data transfer initiated." amt);
      let rec loop = function
        | 0 -> Lwt.return_unit
        | n -> write_and_check flow msg >>= fun () -> loop (n-1)
      in
      let t0 = Mclock.elapsed_ns clock in
      let st = {
        bytes=0L; start_time = t0; last_time = t0
      } in
      loop (amt / mlen) >>= fun () ->
      let a = Cstruct.sub msg 0 (amt - (mlen * (amt/mlen))) in
      write_and_check flow a >>= fun () ->
      let tnow = Mclock.elapsed_ns clock in
      st.bytes <- Int64.of_int amt;
      print_data st tnow >>= fun () ->
      Logs.info (fun f -> f  "iperf client: Done.");
      S.TCPV4.close flow
    in
    Logs.info (fun f -> f  "Trying to connect to a server at %a:%d, buffer size = %d, protocol = tcp" Ipaddr.V4.pp dest_ip dport mlen);
    tcp_connect (S.tcpv4 s) (dest_ip, dport) >>= fun flow ->
    iperftx flow >>= fun () ->
    Lwt.return_unit

  let start s _time =
    Time.sleep_ns (Duration.of_sec 1) >>= fun () -> (* Give server 1.0 s to call listen *)
    Lwt.async (fun () -> S.listen s);
    Mclock.connect () >>= fun clock ->
    iperfclient s (Key_gen.size ()) (Key_gen.ip ()) (Key_gen.port ()) clock

end

