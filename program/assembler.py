import re
import sys

LABEL = "(?P<label>(label[_0-9a-z]*))"
RS1 = "(?P<rs1>([a-z]|zero|ra|sp|tptr|tcmp))"
RS2 = "(?P<rs2>([a-z]|zero|ra|sp|tptr|tcmp))"
RD  = "(?P<rd>([a-z]|zero|ra|sp|tptr|tcmp))"
IMM = "(?P<imm>[+-]?\d+)"
CALC = "(?P<opt>(\+|-))"
COMP = "(?P<opt>(==|!=|>=|<))"
PRIV = "(?P<opt>(halt|ien|idis|iack|iret))"

nop = {
  "rs1":"zero",
  "rs2":"zero",
  "rd":"zero",
  "imm":"0",
  "opt":"null"
}

parse_table = [
  {"opcode": 0, **nop, "regex":f"{RD}={RS1}{CALC}{IMM}"},
  {"opcode": 1, **nop, "regex":f"{RD}={RS1}{CALC}{RS2}"},
  {"opcode": 2, **nop, "regex":f"\(pc,{RD}\)=\({RS1},pc\+1\)"},
  {"opcode": 3, **nop, "regex":f"if\({RS2}{COMP}0\)pc={RS1}"},
  {"opcode": 4, **nop, "regex":f"{RD}=mem\[{RS1}\]"},
  {"opcode": 5, **nop, "regex":f"mem\[{RS1}\]={RS2}"},
  {"opcode": 9, **nop, "regex":f"iret\(\)"},
  {"opcode":10, **nop, "regex":f"halt\(\)"},
  {"opcode": 0, **nop, "regex":f"{RD}={IMM}"},
  {"opcode": 0, **nop, "regex":f"{RD}={LABEL}"},
  {"opcode": 1, **nop, "regex":f"{RD}={RS1}"},
  {"opcode": 3, **nop, "regex":f"pc={RS1}"},
  {"opcode": 6, **nop, "imm": "0", "regex":f"{RD}=monitor_busy\(\)"},
  {"opcode": 6, **nop, "imm": "1", "regex":f"{RD}=keyboard\(\)"},
  {"opcode": 7, **nop, "imm": "0", "regex":f"monitor\({RS1}\)"},
  {"opcode": 8, **nop, "imm": "0", "regex":f"intr_ack\({RS1}\)"},
  {"opcode": 8, **nop, "imm": "1", "regex":f"intr_en\({RS1}\)"},
  {"opcode": 8, **nop, "imm": "2", "regex":f"intr_trap\({RS1}\)"},
]

num_reg = {
  "zero" : 0,
  "ra"   : 1,
  "sp"   : 2,
  "tptr" : 3,
  "tcmp" : 4,
  "a"    : 5,
  "b"    : 6,
  "c"    : 7,
  "d"    : 8,
  "e"    : 9,
  "f"    : 10,
  "g"    : 11,
  "h"    : 12,
  "i"    : 13,
  "j"    : 14,
  "k"    : 15
}

num_opt = {
  "null": 0,
  "+":    0,
  "-":    1,
  "<<":   2,
  ">>":   3,
  "&":    4,
  "|":    5,
  "^":    6,
  "==":   0,
  "!=":   1,
  ">=":   2,
  "<":    3
}

def hex_format(a, width):
  return format(2**32+a, '08x')[-width:]

def to_hex(parsed_list, label_table):
  ret = []
  addr = 0
  for parsed in parsed_list:
    opcode = hex_format(parsed["opcode"], 1)
    opt    = hex_format(num_opt[parsed["opt"]], 1)
    rd     = hex_format(num_reg[parsed["rd"]], 1)
    rs1    = hex_format(num_reg[parsed["rs1"]], 1)
    rs2    = hex_format(num_reg[parsed["rs2"]], 1)

    if "label" in parsed:
      imm = hex_format(label_table[parsed["label"]], 3)
    else:
      imm = hex_format(int(parsed["imm"]), 3)

    ret.append(f"{imm}{rs2}{rs1}{rd}{opt}{opcode} // 0x{addr:04x} | {parsed['line_num']:4d} | {parsed['line_raw']}")
    addr += 1
  return ret

def create_parsed_list(filename):
  parsed_list = []
  with open(filename) as f:
    line_num = -1
    for line_raw in f:
      line_num += 1
      line = line_raw.replace(" ","")

      line_dict = {}
      line_dict["line_num"] = line_num
      line_dict["line_raw"] = line_raw.strip()

      for parse in parse_table:
        m = re.match(f"^{parse['regex']}$", line)
        if m:
          parsed = {**line_dict, **parse, **m.groupdict()}
          parsed_list.append(parsed)
          break
  return parsed_list

def create_label_table(filename):
  label_table = {}
  with open(filename) as f:
    addr = 0
    for line_raw in f:
      line = line_raw.replace(" ","")

      m = re.match(f'^{LABEL}:$', line)
      if m:
        label = m.groupdict()["label"]
        label_table[label] = addr
      else:
        for parse in parse_table:
          if re.match(f"^{parse['regex']}$", line):
            addr += 1
            break
  return label_table

def main():
  parsed_list = create_parsed_list(sys.argv[1])
  # print(*parsed_list, sep="\n")

  label_table = create_label_table(sys.argv[1])
  print(label_table, sep="\n")

  print(*to_hex(parsed_list, label_table), sep="\n")

main()
