// @license("GPL")
module tcp-info

import lib/bpf
import lib/bpf/xdp
import lib/bpf/data/size
import lib/bpf/data/ringbuffer

import lib/network/tcp

// @section(".maps")
val buffer: ringbuffer<global,byte> = ringbuffer/new(16.mb)

// @section("xdp")
fun run(packet: xdp/packet): xdp/action
  with (header, rest) <- tcp/parse(packet.data).or-else(xdp/Pass)
  val length = 32.bytes
  with space <- buffer.reserve(length).or-else(xdp/Pass)
  match rest
    <<chunk::length, rest::_>> ->
      space.put(chunk)
      buffer.submit(space)
      bpf/print("Captured TCP header (\{length.bytes} bytes)")
      xdp/Pass
    _ -> xdp/Pass
