import re
import sys
import textwrap
from common import *

def sub_identity(line):
  return line

def sub_comp(line):
  ret = ""
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
      ret = f"""
        tcmp = {src1} - {src2}
        pc = (tcmp {comp} 0) ? {src3} : pc + 1
      """
  return ret

def sub_push(line):
  ret = ""
  ARGS = f"(?P<args>({REG_LVAL}?(,{REG_LVAL})*))"
  if m := re.fullmatch(f"push\({ARGS}\)", line):
    args = m.group("args").split(",")
    ret = push_args(args)
  return ret

def push_args(args):
  ret = ""
  for arg in args:
    if re.fullmatch(f"{REG}", arg):
      ret += f"""
        sp = sp - 1
        mem[sp] = {arg}
      """
    else:
      ret += f"""
        sp = sp - 1
        tcmp = {arg}
        mem[sp] = tcmp
      """
  return ret

def sub_pop(line):
  ret = ""
  REGS = f"(?P<regs>{REG}(,{REG})*)"
  if m := re.fullmatch(f"pop\({REGS}\)", line):
    for reg in m.group("regs").split(","):
      ret += f"""
        {reg} = mem[sp]
        sp = sp + 1
      """
  return ret

def sub_call(line):
  ret = ""
  DST = f"(?P<dst>{REG})"
  FUNC = f"(?P<func>{LABEL})"
  ARGS = f"(?P<args>({REG_LVAL}?(,{REG_LVAL})*))"

  if m := re.fullmatch(f"({DST}=)?{FUNC}\({ARGS}?\)", line):
    if m.group("args"):
      push_list = m.group("args").split(",")
      ret += push_args(reversed(push_list))

    ret += f"""
      sp = sp - 1
      mem[sp] = ra
      ra = {m.group('func')}
      (pc, ra) = (ra, pc + 1)
      ra = mem[sp]
      sp = sp + 1
    """

    if m.group("args"):
      ret += f"sp = sp + {len(push_list)}"

    if m.group("dst"):
      ret += f"{m.group('dst')} = rv"
  return ret

def main():
  filename = sys.argv[1]

  with open(filename) as f:
    for line_raw in f:
      line_strip = line_raw.strip()
      line = line_strip.replace(" ","").split("//")[0]

      print_line = line_raw
      for f in [sub_call, sub_comp, sub_push, sub_pop, sub_identity]:
        if substitute := f(line):
          print(textwrap.dedent(substitute))
          break

main()
