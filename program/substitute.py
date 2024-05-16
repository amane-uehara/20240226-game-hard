import re
import sys

def substitute_comp(line):
  ret = []
  SRC1 = "(?P<src1>([^=!<>]*))"
  SRC2 = "(?P<src2>([^=!<>]*))"
  SRC3 = "(?P<src3>(.*))"
  COMP = "(?P<opt>(==|!=|>|>=|<|<=))"
  m = re.match(f"if\({SRC1}{COMP}{SRC2}\)pc={SRC3}", line)
  if m:
    src1 = m.groupdict()["src1"]
    src2 = m.groupdict()["src2"]
    src3 = m.groupdict()["src3"]
    opt  = m.groupdict()["opt"]

    ret.append(f"tcmp = {src1} - {src2}")
    ret.append(f"if (tcmp {opt} 0) pc = {src3}")
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

def substitute_call(line):
  ret = []
  fn_name = ""
  DST = "(?P<dst>([a-z]|zero|sp|ra|rv|tptr|tcmp))"
  FN_NAME = "(?P<fn_name>(fn_[a-z0-9_]*))"
  ARGUMENT  = "(?P<argument>(..*))"

  m = re.match(f"^({DST}=)?{FN_NAME}\({ARGUMENT}?\)$", line)

  if m:
    push_list = ["ra"]
    if m.groupdict()["argument"]:
      push_list += m.groupdict()["argument"].split(",")

    for reg_or_imm in reversed(push_list):
      ret.append("sp = sp - 1")
      ret.append(f"tcmp = {reg_or_imm}")
      ret.append("mem[sp] = tcmp")

    fn_name = m.groupdict()["fn_name"]
    ret.append(f"ra = label_{fn_name}")
    ret.append("(pc, ra) = (ra, pc + 1)")
    ret.append("ra = mem[sp]")
    ret.append(f"sp = sp + {len(push_list)}")

    if m.groupdict()["dst"]:
      dst = m.groupdict()["dst"]
      ret.append(f"{dst} = rv")

  return ret

def main():
  filename = sys.argv[1]

  ret = []
  with open(filename) as f:
    for line_raw in f:
      line = line_raw.replace(" ","")
      substitute = []
      substitute += substitute_call(line)
      substitute += substitute_comp(line)
      substitute += substitute_push(line)
      substitute += substitute_pop(line)

      if substitute:
        ret += substitute
      else:
        ret.append(line_raw.strip())

  print('\n'.join(ret))

main()
