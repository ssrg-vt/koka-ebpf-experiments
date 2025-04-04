/// Based on https://docs.rs/network-types/latest/network-types/ip/index.html
module lib/network/ip

import ext/bits
import ext/option

import lib/network/ethernet

// @repr(Value)
pub value type header
    V4(data: v4data)
    V6(data: v6data)

pub struct v4data
  // -bitfield-align-1: [bits8; 0]
  // -bitfield-1: BitfieldUnit<[bits8; 1]>
  tos: bits8
  tot-len: bits16
  id: bits16
  frag-off: bits16
  ttl: bits8
  proto: proto // bits8
  check: bits16
  src-addr: bits32
  dst-addr: bits32

pub struct v6data
  // -bitfield-align-1: [bits8; 0]
  // -bitfield-1: BitfieldUnit<[bits8; 1]>
  flow-label: bits //<3*8>
  payload-len: bits16
  next-hdr: proto
  hop-limit: bits8
  // src-addr: in6-addr
  // dst-addr: in6-addr

// @repr(bits8)
pub type proto
    HopOpt // = 0
    Icmp // = 1
    Igmp // = 2
    Ggp // = 3
    Ipv4 // = 4
    Stream // = 5
    Tcp // = 6
    Cbt // = 7
    Egp // = 8
    Igp // = 9
    BbnRccMon // = 10
    NvpII // = 11
    Pup // = 12
    Argus // = 13
    Emcon // = 14
    Xnet // = 15
    Chaos // = 16
    Udp // = 17
    Mux // = 18
    DcnMeas // = 19
    Hmp // = 20
    Prm // = 21
    Idp // = 22
    Trunk1 // = 23
    Trunk2 // = 24
    Leaf1 // = 25
    Leaf2 // = 26
    Rdp // = 27
    Irtp // = 28
    Tp4 // = 29
    Netblt // = 30
    MfeNsp // = 31
    MeritInp // = 32
    Dccp // = 33
    ThirdPartyConnect // = 34
    Idpr // = 35
    Xtp // = 36
    Ddp // = 37
    IdprCmtp // = 38
    TpPlusPlus // = 39
    Il // = 40
    Ipv6 // = 41
    Sdrp // = 42
    Ipv6Route // = 43
    Ipv6Frag // = 44
    Idrp // = 45
    Rsvp // = 46
    Gre // = 47
    Dsr // = 48
    Bna // = 49
    Esp // = 50
    Ah // = 51
    Inlsp // = 52
    Swipe // = 53
    Narp // = 54
    Mobile // = 55
    Tlsp // = 56
    Skip // = 57
    Ipv6Icmp // = 58
    Ipv6NoNxt // = 59
    Ipv6Opts // = 60
    AnyHostInternal // = 61
    Cftp // = 62
    AnyLocalNetwork // = 63
    SatExpak // = 64
    Kryptolan // = 65
    Rvd // = 66
    Ippc // = 67
    AnyDistributedFileSystem // = 68
    SatMon // = 69
    Visa // = 70
    Ipcv // = 71
    Cpnx // = 72
    Cphb // = 73
    Wsn // = 74
    Pvp // = 75
    BrSatMon // = 76
    SunNd // = 77
    WbMon // = 78
    WbExpak // = 79
    IsoIp // = 80
    Vmtp // = 81
    SecureVmtp // = 82
    Vines // = 83
    Ttp // = 84
    NsfnetIgp // = 85
    Dgp // = 86
    Tcf // = 87
    Eigrp // = 88
    Ospfigp // = 89
    SpriteRpc // = 90
    Larp // = 91
    Mtp // = 92
    Ax25 // = 93
    Ipip // = 94
    Micp // = 95
    SccSp // = 96
    Etherip // = 97
    Encap // = 98
    AnyPrivateEncryptionScheme // = 99
    Gmtp // = 100
    Ifmp // = 101
    Pnni // = 102
    Pim // = 103
    Aris // = 104
    Scps // = 105
    Qnx // = 106
    ActiveNetworks // = 107
    IpComp // = 108
    Snp // = 109
    CompaqPeer // = 110
    IpxInIp // = 111
    Vrrp // = 112
    Pgm // = 113
    AnyZeroHopProtocol // = 114
    L2tp // = 115
    Ddx // = 116
    Iatp // = 117
    Stp // = 118
    Srp // = 119
    Uti // = 120
    Smp // = 121
    Sm // = 122
    Ptp // = 123
    IsisOverIpv4 // = 124
    Fire // = 125
    Crtp // = 126
    Crudp // = 127
    Sscopmce // = 128
    Iplt // = 129
    Sps // = 130
    Pipe // = 131
    Sctp // = 132
    Fc // = 133
    RsvpE2eIgnore // = 134
    MobilityHeader // = 135
    UdpLite // = 136
    Mpls // = 137
    Manet // = 138
    Hip // = 139
    Shim6 // = 140
    Wesp // = 141
    Rohc // = 142
    EthernetInIpv4 // = 143
    Aggfrag // = 144
    Test1 // = 253
    Test2 // = 254
    Reserved // = 255

pub fun parse(data: bits): option<(header, bits)>
  if val Some(header, rest) = ethernet/parse(data) else None
  match header.kind
    // Ipv4 -> match rest
    //   <<_::8, tos:: 8, tot-len:: 16, id:: 16, frag-off:: 16, ttl:: 8, proto:: 8, check:: 16, src-addr:: 32, dst-addr:: 32, rest::_>> ->
    //     Some((V4(tos, tot-len, id, frag-off, ttl, proto, check, src-addr, dst-addr), rest)
    // Ipv6 -> match rest
    //   <<>>
    _ -> None
