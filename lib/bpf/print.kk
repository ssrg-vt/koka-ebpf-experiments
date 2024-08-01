module lib/bpf/print

import ext/num/int
import ext/num/nat

extern import
  c file "internal.h"

//// Unsigned integers ////

pub extern nat8/print(x: nat8): io ()
  c inline "kk_bpf_print_nat8(#1)"

pub extern nat16/print(x: nat16): io ()
  c inline "kk_bpf_print_nat16(#1)"

pub extern nat32/print(x: nat32): io ()
  c inline "kk_bpf_print_nat32(#1)"

pub extern nat64/print(x: nat64): io ()
  c inline "kk_bpf_print_nat64(#1)"

//// Signed integers ////

pub extern int8/print(x: int8): io ()
  c inline "kk_bpf_print_int8(#1)"

pub extern int16/print(x: int16): io ()
  c inline "kk_bpf_print_int16(#1)"

pub extern int32/print(x: int32): io ()
  c inline "kk_bpf_print_int32(#1)"

pub extern int64/print(x: int64): io ()
  c inline "kk_bpf_print_int64(#1)"

//// Strings ////

pub extern string/print(x: string): io ()
  // Note no `inline` here, to add a kk_context_t parameter
  c "kk_bpf_print_string"

// fun main()
//   // val a-int32 = 888888.int32
//   val a-int64 = 999999999999999999.int64
//   // val a-string = "Hello world"
//   // printf(a-int32) // calls int32/printf
//   printf(a-int64) // calls int64/printf
//   // printf(a-string) // calls string/printf