a = b + c
a = b

a = 57
d = e + 3
zero = zero + 3

mem[f] = g
h = mem[i]

a = pc + 4, pc = b
pc = c

if (e == 0) pc = d
if (f != 0) pc = d
if (g >= 0) pc = d
if (h <  0) pc = d

halt()
ien()
idis()
iack()
iret()

label_hoge:
a = label_fuga
label_piyo:
b = label_piyo
label_fuga:
c = label_hoge
