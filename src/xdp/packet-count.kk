// @license("GPL")
module packet-count

import lib/bpf
import lib/bpf/xdp

// NOTE: not possible to have a global variable!
val count = ref(0)

// @section("xdp")
fun run(p: xdp/packet)
  bpf/print("current count: " ++ count.show)
  count.map(inc)

  xdp/Pass