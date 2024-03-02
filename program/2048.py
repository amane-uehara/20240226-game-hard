mem = [0]*16
R = 0x92D68CA2

def main():
  init_game()
  print_board()
  while (True):
    trap_handler()

def init_game():
  print("push [w,s,a,d] and enter")
  for i in range(16):
    mem[i] = 0
  add_new()

def trap_handler():
  x = input("")
  if   (x == 'w') : move_up()
  elif (x == 's') : move_down()
  elif (x == 'a') : move_left()
  elif (x == 'd') : move_right()
  init_if_game_over()
  add_new()
  print_board()

def print_board():
  for i in range(4):
    print(mem[i*4:4*(i+1)])

def add_new():
  r = rand_16()
  while (mem[r] != 0):
    r = rand_16()
  mem[r] = 2

def init_if_game_over():
  is_game_over = 1
  for i in range(16):
    if mem[i] == 0:
      is_game_over = 0
  if (is_game_over == 1):
    print("game over")
    init_game()

def rand_16():
  global R
  R = (R ^ (R << 13)) & 0xFFFFFFFF
  R = (R ^ (R >> 17)) & 0xFFFFFFFF
  R = (R ^ (R <<  5)) & 0xFFFFFFFF
  return (R & 0x0000000F)

# a = row
# b = a*4
# c = clm
# d = [row,clm]
# e = mem[d]
# f = [row',clm']
# g = mem[f]

def compress():
  for a in range(4):
    b = a << 2
    h = 0
    for c in range(4):
      d = b + c
      e = mem[d]
      if (e != 0):
        f = b + h
        mem[f] = e
        if (h != c):
          mem[d] = 0
        h = h + 1

def merge():
  for a in range(4):
    b = a << 2
    for c in range(3):
      d = b + c
      e = mem[d]
      if (e != 0):
        f = d + 1
        g = mem[f]
        if (e == g):
          mem[d] = e + e
          mem[f] = 0

def reverse():
  for a in range(4):
    b = a << 2
    for c in range(2):
      d = b + c
      e = mem[d]
      f = b - c
      f = f + 3
      g = mem[f]
      mem[d] = g
      mem[f] = e

def transpose():
  for a in range(4):
    b = a << 2
    for c in range(4):
      if (a < c):
        d = b + c
        e = mem[d]
        f = c << 2
        f = f + a
        g = mem[f]
        mem[d] = g
        mem[f] = e

def move_left():
  compress()
  merge()
  compress()

def move_right():
  reverse()
  move_left()
  reverse()

def move_up():
  transpose()
  move_left()
  transpose()

def move_down():
  transpose()
  move_right()
  transpose()

if __name__ == '__main__':
  main()
