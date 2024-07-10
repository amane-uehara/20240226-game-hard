import re
import sys
from common import *

def substitute_comp(line):
  ret = []
  SRC1 = f"(?P<src1>{REG})"
  SRC2 = f"(?P<src2>({REG_LVAL}))"
  SRC3 = f"(?P<src3>({REG}))"
  COMP = f"(?P<comp>({OP_COMP}))"
  if m := re.fullmatch(f"pc=\({SRC1}{COMP}{SRC2}\)\?{SRC3}:pc\+1", line):
    src1 = m.group("src1")
    src2 = m.group("src2")
    src3 = m.group("src3")
    comp = m.group("comp")

    if src2 != "0":
      ret.append(f"tcmp = {src1} - {src2}")
      ret.append(f"pc = (tcmp {comp} 0) ? {src3} : pc + 1")
  return ret

def substitute_push(line):
  ret = []
  REGS = f"(?P<regs>{REG}(,{REG})*)"
  if m := re.fullmatch(f"push\({REGS}\)", line):
    for reg in m.group("regs").split(","):
      ret.append("sp = sp - 1")
      ret.append(f"mem[sp] = {reg}")
  return ret

def substitute_pop(line):
  ret = []
  REGS = f"(?P<regs>{REG}(,{REG})*)"
  if m := re.fullmatch(f"pop\({REGS}\)", line):
    for reg in m.group("regs").split(","):
      ret.append(f"{reg} = mem[sp]")
      ret.append("sp = sp + 1")
  return ret

def substitute_call(line):
  ret = []
  DST = f"(?P<dst>{REG})"
  FN_NAME = f"(?P<fn_name>{FUNCTION})"
  ARGS = f"(?P<args>({REG_LVAL}?(,{REG_LVAL})*))"

  if m := re.fullmatch(f"({DST}=)?{FN_NAME}\({ARGS}?\)", line):
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

  with open(filename) as f:
    for line_raw in f:
      line_strip = line_raw.strip()
      line = line_strip.replace(" ","").split("//")[0]

      substitute = []
      substitute += substitute_call(line)
      substitute += substitute_comp(line)
      substitute += substitute_push(line)
      substitute += substitute_pop(line)

      if substitute:
        print('\n'.join(substitute))
      else:
        print(line)

main()
