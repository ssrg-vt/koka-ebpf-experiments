#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

typedef union {
   uint64_t w64;
   uint32_t w32[2];
   uint16_t w16[4];
   uint8_t  w8 [8];
} bits64_t;

int main() {
  uint64_t n = ((uint64_t)1 << 35) | ((uint64_t)1 << 3);
  printf(">> %" PRIu64 "\n", n);

  bits64_t m = (bits64_t)n;
  printf(">> %" PRIu32 ", %" PRIu32 "\n", m.w32[0], m.w32[1]);

  // uint32_t k[2] = (uint32_t[2])n;
  // printf(">> %" PRIu32 ", %" PRIu32 "\n", k[0], k[1]);

  return 0;
}