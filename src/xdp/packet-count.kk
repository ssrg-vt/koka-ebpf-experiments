// @license("GPL")
module packet-count

import lib/bpf
import lib/bpf/xdp

val count = ref(0)

// @section("xdp")
fun run(p: xdp/packet): <state<global>> xdp/Result
  bpf/print("current count: " ++ count.show)
  count.map(inc)

  xdp/Pass