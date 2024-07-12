label_start:
  b = 69
  a = 72
  push(a,b)

  pop(a)
  call(label_putchar)

  pop(a)
  call(label_putchar)

label_putchar:
  label_do_while_1_bgn:
    b = monitor_busy()
    c = label_do_while_1_bgn
    if (b == 0) pc = c
  monitor(a)
  pc = ra
