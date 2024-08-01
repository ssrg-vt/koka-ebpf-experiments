module lib/bpf

pub import ext/num/int
pub import ext/num/nat

extern import
  c file "bpf/internal.h"

pub extern print(x: string): log ()
  // Note no `inline` here, to add a kk_context_t parameter
  c "kk_bpf_print_string"

effect log {}
