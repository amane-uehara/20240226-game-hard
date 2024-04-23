label_start:
  a = 72
  sp = sp - 4
  mem[sp] = ra
  ra = label_putchar
  (pc, ra) = (ra, pc + 4)
  ra = mem[sp]
  sp = sp + 4

  a = 69
  sp = sp - 4
  mem[sp] = ra
  ra = label_putchar
  (pc, ra) = (ra, pc + 4)
  ra = mem[sp]
  sp = sp + 4

label_putchar:
  label_do_while_1_bgn:
    b = monitor_busy()
    c = label_do_while_1_bgn
    if (b == 0) pc = c
  monitor(a)
  pc = ra
