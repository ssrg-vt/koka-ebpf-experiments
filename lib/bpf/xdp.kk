module lib/bpf/xdp

pub import ext/bits
pub import ext/num/nat

/* https://elixir.bootlin.com/linux/v6.9-rc7/source/include/uapi/linux/bpf.h */

/* User return codes for XDP prog type.
 * A valid XDP program must return one of these defined values. All other
 * return codes are reserved for future use. Unknown return codes will
 * result in packet drops and a warning via bpf_warn_invalid_xdp_action().
 */
pub enum action
  Aborted // = 0
  Drop
  Pass
  Tx
  Redirect

pub fun action/show(a: action): string
  match a
    Aborted -> "XDP_ABORTED"
    Drop -> "XDP_DROP"
    Pass -> "XDP_PASS"
    Tx -> "XDP_TX"
    Redirect -> "XDP_REDIRECT"

/* user accessible metadata for XDP packet hook
 * new fields must be added to the end of this structure
 */
pub ref struct packet
  data: bits
  metadata: bits
