module ext/external/ref

// @external(C, "*a")
// @maximize(1)
pub value type ref<h::H,a>
  Ref(address: addr)

// @external(C, "intptr_t")
// pub type addr
pub alias addr = intptr_t
