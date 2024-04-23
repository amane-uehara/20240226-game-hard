label_start:
  intr_en(zero)
  a = label_trap
  intr_trap(a)
  a = 1
  intr_en(a)

label_halt:
  halt()
  a = label_halt
  pc = a

label_trap:
  a = keyboard()
  b = 1
  intr_ack(b)
  a = a + 2
  monitor(a)
  iret()
