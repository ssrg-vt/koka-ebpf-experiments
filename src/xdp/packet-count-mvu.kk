// @license("GPL")
module packet-count-mvu

import lib/bpf
import lib/bpf/xdp

type state
  State(count: nat)

fun init(): state
  State(count = 0)

// @section("xdp")
fun run(packet: xdp/packet, state: state): (xdp/result, state)
  bpf/print("current count: " ++ state.count.show)
  ( xdp/Pass, state(count = state.count + 1) )