label_putchar:
  label_do_while_1_bgn:
    b = monitor_busy()
    c = label_do_while_1_bgn
    if (b == 0) pc = c
  monitor(a)
  pc=ra

a = 72
b = label_putchar
ra=pc+4, pc=b

a = 69
b = label_putchar
ra=pc+4, pc=b
