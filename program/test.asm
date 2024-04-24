def label_start() {
  a = 1
  for (b=2; c<0; d=e+1) {
    a = 2
    if (f == 0) {
      a = 3
      call(label_func)
    }
    a = 4
    if (g > 0) {
      a = 5
    }
    a = 6
  }
  a = 7
}

def label_func() {
  push(a,b,c)
  pop(a,b,c)
}
