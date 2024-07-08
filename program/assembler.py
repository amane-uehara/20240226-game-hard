import re
import sys

NUM_REG = {
  "zero" : 0,
  "sp"   : 1,
  "ra"   : 2,
  "rv"   : 3,
  "tptr" : 4,
  "tcmp" : 5,
  "a"    : 6,
  "b"    : 7,
  "c"    : 8,
  "d"    : 9,
  "e"    : 10,
  "f"    : 11,
  "g"    : 12,
  "h"    : 13,
  "i"    : 14,
  "j"    : 15
}

NUM_OPT = {
  "null": 0,
  "+":    0,
  "-":    1,
  "<<":   2, # sll = sla
  "<<<":  2, # sla = sll
  ">>":   3, # srl
  ">>>":  4, # sra
  "&":    5,
  "|":    6,
  "^":    7,
  "==":   0,
  "!=":   1,
  ">=":   2,
  "<":    3,
  ">":    4,
  "<=":   5
}

NOP = {
  "rs1":"zero",
  "rs2":"zero",
  "rd":"zero",
  "imm":"0",
  "opt":"null"
}

RS1 = "(?P<rs1>(zero|sp|ra|rv|tptr|tcmp|[a-j]))"
RS2 = "(?P<rs2>(zero|sp|ra|rv|tptr|tcmp|[a-j]))"
RD  = "(?P<rd>(zero|sp|ra|rv|tptr|tcmp|[a-j]))"
IMM = "(?P<imm>[+-]?(0x[0-9a-f]+|\d+))"
CALC = "(?P<opt>(\+|-|<<|<<<|>>|>>>|&|\||\^))"
COMP = "(?P<opt>(==|!=|>|>=|<|<=))"
PRIV = "(?P<opt>(halt|ien|idis|iack|iret))"
COMMENT = "(//.*)"

template_table = [
  {"opcode": 0, **NOP, "regex":f"{RD}={RS1}{CALC}{IMM}"},
  {"opcode": 1, **NOP, "regex":f"{RD}={RS1}{CALC}{RS2}"},
  {"opcode": 2, **NOP, "regex":f"\(pc,{RD}\)=\({RS1},pc\+1\)"},
  {"opcode": 3, **NOP, "regex":f"if\({RS2}{COMP}0\)pc={RS1}"},
  {"opcode": 4, **NOP, "regex":f"{RD}=mem\[{RS1}\]"},
  {"opcode": 5, **NOP, "regex":f"mem\[{RS1}\]={RS2}"},
  {"opcode": 9, **NOP, "regex":f"iret\(\)"},
  {"opcode":10, **NOP, "regex":f"halt\(\)"},
  {"opcode": 0, **NOP, "regex":f"{RD}={IMM}"},
  {"opcode": 1, **NOP, "regex":f"{RD}={RS1}"},
  {"opcode": 3, **NOP, "regex":f"pc={RS1}"},
  {"opcode": 6, **NOP, "imm": "0", "regex":f"{RD}=monitor_busy\(\)"},
  {"opcode": 6, **NOP, "imm": "1", "regex":f"{RD}=keyboard\(\)"},
  {"opcode": 7, **NOP, "imm": "0", "regex":f"monitor\({RS1}\)"},
  {"opcode": 8, **NOP, "imm": "0", "regex":f"intr_ack\({RS1}\)"},
  {"opcode": 8, **NOP, "imm": "1", "regex":f"intr_en\({RS1}\)"},
  {"opcode": 8, **NOP, "imm": "2", "regex":f"intr_trap\({RS1}\)"},
]

def hex_format(a, width):
  return format(2**32+a, '08x')[-width:]

def main():
  filename = sys.argv[1]
  with open(filename) as f:
    for line_raw in f:
      line = line_raw.replace(" ","")

      for template in template_table:
        template_match = f"^{template['regex']}{COMMENT}?$"
        if match := re.search(template_match, line):
          parse = {**template, **match.groupdict()}

          opcode = hex_format(parse["opcode"], 1)
          opt    = hex_format(NUM_OPT[parse["opt"]], 1)
          rd     = hex_format(NUM_REG[parse["rd"]], 1)
          rs1    = hex_format(NUM_REG[parse["rs1"]], 1)
          rs2    = hex_format(NUM_REG[parse["rs2"]], 1)
          imm    = hex_format(int(parse["imm"],0), 3)
          print(f"{imm}{rs2}{rs1}{rd}{opt}{opcode} ", end="")
          break

      print(f"// {line_raw.strip()}")

main()
