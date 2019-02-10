open Lwt.Infix

type stats = {
  mutable bytes: int64;
  mutable start_time: int64;
  mutable last_time: int64;
}

module Main (S: Mirage_types_lwt.STACKV4) = struct

  let print_stats prefix stat =
    Logs.info (fun m -> m "gc %s minor words %f promoted words %f major words %f@.minor collections %d major collections %d heap_words %d heap chunks %d@.compactions %d top heap words %d stack size %d"
                  prefix stat.Gc.minor_words stat.Gc.promoted_words stat.Gc.major_words
                  stat.Gc.minor_collections stat.Gc.major_collections stat.Gc.heap_words
                  stat.Gc.heap_chunks stat.Gc.compactions stat.Gc.top_heap_words
                  stat.Gc.stack_size)

  let print_cstruct_stats () =
    Logs.info (fun m -> m "cstruct stats %a" Cstruct.pp_stat (Cstruct.get_stat ()))

  let print_iopage_stats () =
    Logs.info (fun m -> m "iopage stats %a" Io_page.pp_stat (Io_page.get_stat ()))

  let print_data st ts_now =
    let duration = Int64.sub ts_now st.start_time in
    let rate = (Int64.float_of_bits st.bytes) /. (Int64.float_of_bits duration) *. 1000. *. 1000. *. 1000. in
    Logs.info (fun f -> f  "iperf server: Duration = %.0Lu [ns] (start_t = %.0Lu, end_t = %.0Lu),  Data received = %Ld [bytes], Throughput = %.2f [bytes/sec]" duration st.start_time ts_now st.bytes rate);
    Logs.info (fun f -> f  "iperf server: Throughput = %.2f [MBs/sec]"  (rate /. 1000000.));
    st.last_time <- ts_now;
    st.bytes <- 0L;
    let stat_before = Gc.quick_stat () in
    print_stats "before" stat_before ;
    Gc.full_major ();
    let stat_after = Gc.quick_stat () in
    print_stats "after" stat_after ;
    print_cstruct_stats () ;
    print_iopage_stats () ;
    Lwt.return_unit

  let iperf clock flow =
    (* debug is too much for us here *)
    Logs.set_level ~all:true (Some Logs.Info);
    Logs.info (fun f -> f  "iperf server: Received connection.");
    let t0 = Mclock.elapsed_ns clock in
    let st = {
      bytes=0L; start_time = t0; last_time = t0
    } in
    let rec iperf_h flow =
      S.TCPV4.read flow >|= Rresult.R.get_ok >>= function
      | `Eof ->
        let ts_now = Mclock.elapsed_ns clock in
        st.last_time <- st.start_time;
        print_data st ts_now >>= fun () ->
        S.TCPV4.close flow >>= fun () ->
        Logs.info (fun f -> f  "iperf server: Done - closed connection.");
        Lwt.return_unit
      | `Data data ->
        begin
          let l = Cstruct.len data in
          st.bytes <- (Int64.add st.bytes (Int64.of_int l));
          iperf_h flow
        end
    in
    iperf_h flow >>= fun () ->
    Lwt.return_unit

 let start s =
   let ips = List.map Ipaddr.V4.to_string (S.IPV4.get_ip (S.ipv4 s)) in
   let port = Key_gen.port () in
   Logs.info (fun f -> f "iperf server process started:");
   Logs.info (fun f -> f "IP address: %s" (String.concat "," ips));
   Logs.info (fun f -> f "Port number: %d" port);

   Mclock.connect () >>= fun clock ->
   S.listen_tcpv4 s ~port (iperf clock);
   S.listen s

end

