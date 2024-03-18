label_start:
  a = 2
  b = label_trap
  intr(a) = b

  a = 1
  b = 1
  intr(a) = b

label_halt:
  a = label_halt:
  halt()
  pc = a

label_trap:
  a = 1
  b = io(a)

  intr(zero) = a

  io(zero) = b
  iret()
