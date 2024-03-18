a = 57
d = e + 3
zero = zero + 3

a = b + c
a = b

b = label_1
a = pc + 4, pc = b
label_1:

c = label_2
pc = c
label_2:

d = label_3
if (e == 0) pc = d
label_3:

d = label_4
if (f != 0) pc = d
label_4:

d = label_5
if (g >= 0) pc = d
label_5:

d = label_6
if (h <  0) pc = d
label_6:

h = mem[i]
mem[f] = g

a = 0
b = io(a)

a = 1
b = io(a)

io(zero) = c

a = 0
b = 1
intr(a) = b

a = 1
intr(a) = b

a = 2
b = label_trap
intr(a) = b

a = 0
halt()

label_trap:
b = 0
c = 1
intr(b) = c
a = 1
iret()
a = 2

label_not_reach:
a = 3
halt()
