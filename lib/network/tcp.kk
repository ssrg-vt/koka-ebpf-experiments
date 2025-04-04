// Based on https://docs.rs/network-types/latest/network_types/tcp/struct.TcpHdr.html
module lib/network/tcp

import ext/bits
import ext/option

import lib/network/ip

pub struct header
  source: bits16
  dest: bits16
  seq: bits32
  ack_seq: bits32
  // _bitfield_align_1: [bits8; 0]
  // _bitfield_1: BitfieldUnit<[bits8; 2]>
  window: bits16
  check: bits16
  urg_ptr: bits16


pub fun parse(data: bits): option<(header, bits)>
  with (header, rest) <- ip/parse(data).try
  match header.proto
    Tcp -> match rest
      // <<source::16, dest::16, seq::32, ack_seq::32, _::16, window::16, check::16, urg_ptr::16, rest::_>> ->
      //   Some((Header(source, dest, seq, ack_seq, window, check, urg_ptr), rest))
      _ -> None
    _ -> None
