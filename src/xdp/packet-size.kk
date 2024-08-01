// @license("GPL")
module packet-size

import lib/bpf
import lib/bpf/xdp

// @section("xdp")
fun run(p: xdp/packet)
  val size = p.data.size

  bpf/print("packet size: " ++ size.show)

  xdp/Pass