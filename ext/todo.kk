module ext/todo

import ext/unsafe

pub effect todo {}

pub fun todo(m = "Needs to be done"): todo a
  unsafe/cast(())