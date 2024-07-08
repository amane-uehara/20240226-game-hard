import re
import sys
from common import *

def substitute_comp(line):
  ret = []
  SRC1 = f"(?P<src1>{REG})"
  SRC2 = f"(?P<src2>({REG_LVAL}))"
  SRC3 = f"(?P<src3>({REG_LVAL}))"
  if m := re.match(f"if\({SRC1}{COMP}{SRC2}\)pc={SRC3}", line):
    src1 = m.group("src1")
    src2 = m.group("src2")
    src3 = m.group("src3")
    opt  = m.group("opt")

    ret.append(f"tcmp = {src1} - {src2}")
    ret.append(f"if (tcmp {opt} 0) pc = {src3}")
  return ret

def substitute_push(line):
  ret = []
  if m := re.match(f"^push\((?P<regs>{REG}(,{REG})*)\)$", line):
    for reg in m.group("regs").split(","):
      ret.append("sp = sp - 1")
      ret.append(f"mem[sp] = {reg}")
  return ret

def substitute_pop(line):
  ret = []
  if m := re.match(f"^pop\((?P<regs>{REG}(,{REG})*)\)$", line):
    for reg in m.group("regs").split(","):
      ret.append(f"{reg} = mem[sp]")
      ret.append("sp = sp + 1")
  return ret

def substitute_call(line):
  ret = []
  fn_name = ""
  DST = f"(?P<dst>{REG})"
  FN = f"(?P<fn_name>{FN_NAME})"
  ARGS = f"(?P<args>({REG_LVAL}?(,{REG_LVAL})*))"

  if m := re.match(f"^({DST}=)?{FN}\({ARGS}?\)$", line):
    push_list = ["ra"]
    if m.group("args"):
      push_list += m.group("args").split(",")

    for reg_or_imm in reversed(push_list):
      ret.append("sp = sp - 1")
      ret.append(f"tcmp = {reg_or_imm}")
      ret.append("mem[sp] = tcmp")

    fn_name = m.group("fn_name")
    ret.append(f"ra = label_{fn_name}")
    ret.append("(pc, ra) = (ra, pc + 1)")
    ret.append("ra = mem[sp]")
    ret.append(f"sp = sp + {len(push_list)}")

    if m.group("dst"):
      dst = m.group("dst")
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
