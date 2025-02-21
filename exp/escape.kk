import exp/cextern

pub fun main()
  val s = "Hello world"
  val r = s.with-c-string fn(c){
    // c.data // <== unsound, reveals pointer, so needs to be opaque
    c
  }
  r.println

/*
inferred type: forall<s1> (c: borrow<s1,int8>) -> borrow<s1,int8>
expected type: forall<s1> (c: borrow<s1,int8>) -> borrow<$s,int8>
hint         : a local variable or reference escapes its scope?

inferred type: forall<b> (c: borrow<b,int8>) -> borrow<b,int8>
expected type: forall<b> (c: borrow<b,int8>) -> borrow<$a,int8>
hint         : an higher-rank type escapes its scope?
*/