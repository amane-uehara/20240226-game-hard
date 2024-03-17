a = 57
d = e + 3
zero = zero + 3

a = b + c
a = b

h = mem[i]
mem[f] = g

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

label_hoge:
a = label_fuga
label_piyo:
b = label_moge
label_fuga:
c = label_piyo
label_moge:

a = keyboard()
monitor(b)
c = monitor_busy()

ien()
idis()
iack()
iret()
halt()
