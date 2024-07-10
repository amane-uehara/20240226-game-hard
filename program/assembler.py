import re
import sys
from common import *

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

RS1  = f"(?P<rs1>{REG})"
RS2  = f"(?P<rs2>{REG})"
RD   = f"(?P<rd>{REG})"
IMM  = f"(?P<imm>{VAL})"
CALC = f"(?P<opt>{OP_CALC})"
COMP = f"(?P<opt>{OP_COMP})"

template_table = [
  {"opcode": 0, "regex":f"{RD}={RS1}{CALC}{IMM}"},
  {"opcode": 1, "regex":f"{RD}={RS1}{CALC}{RS2}"},
  {"opcode": 2, "regex":f"\(pc,{RD}\)=\({RS1},pc\+1\)"},
  {"opcode": 3, "regex":f"pc=\({RS2}{COMP}0\)\?{RS1}:pc\+1"},
  {"opcode": 4, "regex":f"{RD}=mem\[{RS1}\]"},
  {"opcode": 5, "regex":f"mem\[{RS1}\]={RS2}"},
  {"opcode": 6, "regex":f"{RD}=io\[{IMM}\]"},
  {"opcode": 7, "regex":f"io\[{IMM}\]={RS1}"},
  {"opcode": 8, "regex":f"intr\[{IMM}\]={RS1}"},
  {"opcode": 9, "regex":f"iret\(\)"},
  {"opcode":10, "regex":f"halt\(\)"},
  {"opcode": 0, "regex":f"{RD}={IMM}"},
  {"opcode": 1, "regex":f"{RD}={RS1}"},
  {"opcode": 3, "regex":f"pc={RS1}"},
]

def main():
  filename = sys.argv[1]
  with open(filename) as f:
    for line_raw in f:
      line_strip = line_raw.strip()
      line = line_strip.replace(" ","").split("//")[0]

      for template in template_table:
        if match := re.fullmatch(template['regex'], line):
          parse = {
            "rs1": "zero",
            "rs2": "zero",
            "rd": "zero",
            "imm": "0",
            "opt": "null",
            **match.groupdict()
          }

          opcode = hex_format(template["opcode"], 1)
          opt    = hex_format(NUM_OPT[parse["opt"]], 1)
          rd     = hex_format(NUM_REG[parse["rd"]], 1)
          rs1    = hex_format(NUM_REG[parse["rs1"]], 1)
          rs2    = hex_format(NUM_REG[parse["rs2"]], 1)
          imm    = hex_format(int(parse["imm"], 0), 3)
          print(f"{imm}{rs2}{rs1}{rd}{opt}{opcode} ", end="")
          break

      print(f"// {line_strip}", end="\n")

main()
