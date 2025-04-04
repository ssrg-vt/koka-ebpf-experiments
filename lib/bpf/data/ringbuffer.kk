module lib/bpf/data/ringbuffer

import ext/num/nat
import ext/todo

pub type ringbuffer<h::H,a>
pub type space<h::H,a>

pub fun new(size: nat): ringbuffer<global,a>
  todo("implement")

pub fun reserve(buffer: ringbuffer<h,a>, size: nat): option<space<h,a>>
  todo("implement")

pub fun submit(buffer: ringbuffer<h,a>, space: space<h,a>): ()
  todo("implement")
