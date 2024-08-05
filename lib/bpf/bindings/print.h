#include <bpf/bpf_helpers.h>

// NOTE: format macros from https://en.cppreference.com/w/cpp/types/integer

//// Unsigned integers ////

kk_unit_t kk_bpf_print_nat8(uint8_t x) {
  bpf_printk("%" PRIu8 "\n", x);
  return kk_Unit;
}

kk_unit_t kk_bpf_print_nat16(uint16_t x) {
  bpf_printk("%" PRIu16 "\n", x);
  return kk_Unit;
}

kk_unit_t kk_bpf_print_nat32(uint32_t x) {
  bpf_printk("%" PRIu32 "\n", x);
  return kk_Unit;
}

kk_unit_t kk_bpf_print_nat64(uint64_t x) {
  bpf_printk("%" PRIu64 "\n", x);
  return kk_Unit;
}

//// Signed integers ////

kk_unit_t kk_bpf_print_int8(int8_t x) {
  bpf_printk("%" PRIi8 "\n", x);
  return kk_Unit;
}

kk_unit_t kk_bpf_print_int16(int16_t x) {
  bpf_printk("%" PRIi16 "\n", x);
  return kk_Unit;
}

kk_unit_t kk_bpf_print_int32(int32_t x) {
  bpf_printk("%" PRIi32 "\n", x);
  return kk_Unit;
}

kk_unit_t kk_bpf_print_int64(int64_t x) {
  bpf_printk("%" PRIi64 "\n", x);
  return kk_Unit;
}

//// Strings ////

// Like `kk_print` in string.c.
kk_unit_t kk_bpf_print_string(kk_string_t s, kk_context_t* ctx) {
  // `kk_string_cbuf_borrow` borrows the string.
  // The size of the string will be written _as an output_ to the second parameter.
  // If the second parameter is NULL, it won't do this.
  bpf_printk("%s\n", kk_string_cbuf_borrow(s, NULL, ctx));
  kk_string_drop(s, ctx);
  return kk_Unit;
}