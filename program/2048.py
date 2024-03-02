mem = [0]*16
R = 0x92D68CA2

def main():
  init_game()
  while (True):
    trap_handler()

def init_game():
  print("push [w,s,a,d] and enter")
  for i in range(16):
    mem[i] = 0
  add_new()
  print_board()

def trap_handler():
  x = input("")
  if   (x == 'w') : move_up()
  elif (x == 's') : move_down()
  elif (x == 'a') : move_left()
  elif (x == 'd') : move_right()
  add_new()
  print_board()

def print_board():
  for i in range(4):
    print(mem[i*4:4*(i+1)])

def add_new():
  init_if_game_over()
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

def compress():
  for i in range(4):
    pos = 0
    for j in range(4):
      if (mem[i*4 + j] != 0):
        mem[i*4 + pos] = mem[i*4 + j]
        if (pos != j):
          mem[i*4 + j] = 0
        pos += 1

def merge():
  for i in range(4):
    for j in range(3):
      if (mem[i*4 + j] == mem[i*4 + (j+1)] and mem[i*4 + j] != 0):
        mem[i*4 + j] = mem[i*4 + j]*2
        mem[i*4 + (j+1)] = 0

def reverse():
  for i in range(4):
    for j in range(2):
      a = mem[i*4 + j]
      mem[i*4 + j] = mem[i*4 + (3-j)]
      mem[i*4 + (3-j)] = a

def transpose():
  for i in range(4):
    for j in range(i+1, 4):
      a = mem[i*4 + j]
      mem[i*4 + j] = mem[j*4 + i]
      mem[j*4 + i] = a

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
