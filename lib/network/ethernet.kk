/// Based on https://docs.rs/network-types/latest/network_types/eth/index.html
module lib/network/ethernet

import ext/bits
import ext/option


// @repr(Value)
pub struct header
  destination: bits //<6*8>
  source: bits //<6*8>
  kind: kind

// @repr(bits16)
pub type kind
  Loop // = 24_576
  Ipv4 // = 8
  Arp // = 1_544
  Ipv6 // = 56_710
  FibreChannel // = 1_673
  Infiniband // = 5_513
  LoopbackIeee8023 // = 144

/// Parses some bits and on success
/// returns a header and the remaining bits
pub fun parse(data: bits): option<(header, bits)>
  match data
    // <<dst::6*8, src::6*8, kind::2*8, rest::_>> -> Some(Header(dst, src, kind), rest)
    _ -> None
