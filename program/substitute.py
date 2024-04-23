import re
import sys

LABEL = "(?P<label>(label[_0-9a-z]*))"

def substitute_call(line):
  ret = []
  m = re.match(f"^call\({LABEL}\)$", line)
  if m:
    label = m.groupdict()["label"]
    ret.append("sp = sp - 1")
    ret.append("mem[sp] = ra")
    ret.append(f"ra = {label}")
    ret.append("(pc, ra) = (ra, pc + 1)")
    ret.append("ra = mem[sp]")
    ret.append("sp = sp + 1")
  return ret

def substitute_push(line):
  ret = []
  m = re.match(f"^push\((?P<regs>.*)\)$", line)
  if m:
    for reg in m.groupdict()["regs"].split(","):
      ret.append("sp = sp - 1")
      ret.append(f"mem[sp] = {reg}")
  return ret

def substitute_pop(line):
  ret = []
  m = re.match(f"^pop\((?P<regs>.*)\)$", line)
  if m:
    for reg in m.groupdict()["regs"].split(","):
      ret.append(f"{reg} = mem[sp]")
      ret.append("sp = sp + 1")
  return ret

def main():
  filename = sys.argv[1]

  ret = []
  with open(filename) as f:
    for line_raw in f:
      line = line_raw.replace(" ","")
      substitute = []
      substitute += substitute_call(line)
      substitute += substitute_push(line)
      substitute += substitute_pop(line)

      if substitute:
        ret += substitute
      else:
        ret.append(line_raw.strip())

  print('\n'.join(ret))

main()
