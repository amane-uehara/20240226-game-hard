label_main:
a = label_trap
intr_trap(a)
b = 1
intr_en(b)
halt()

label_trap:
a = keyboard()
b = 1
intr_ack(b)
a = a + 2
monitor(a)
iret()
