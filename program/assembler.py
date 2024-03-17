import re
import sys

LABEL = "(?P<label>(label[_0-9a-z]*))"
RS1 = "(?P<rs1>([a-z]|zero))"
RS2 = "(?P<rs2>([a-z]|zero))"
RD  = "(?P<rd>([a-z]|zero))"
IMM = "(?P<imm>[+-]?\d+)"
CALC = "(?P<opt>(\+|-))"
COMP = "(?P<opt>(==|!=|>=|<))"
PRIV = "(?P<opt>(halt|ien|idis|iack|iret))"

parse_table = {
  "calcr": f"{RD}={RS1}{CALC}{RS2}",
  "movr":  f"{RD}={RS1}",
  "calci": f"{RD}={RS1}{CALC}{IMM}",
  "movi":  f"{RD}={IMM}",
  "movl":  f"{RD}={LABEL}",
  "load":  f"{RD}=mem\[{RS1}\]",
  "store": f"mem\[{RS1}\]={RS2}",
  "jalr":  f"{RD}=pc\+4,pc={RS1}",
  "jcc":   f"if\({RS2}{COMP}0\)pc={RS1}",
  "jmp":   f"pc={RS1}",
  "keyboard":     f"{RD}=keyboard\(\)",
  "monitor":      f"monitor={RS2}",
  "monitor_busy": f"{RD}=monitor_busy\(\)",
  "priv":  f"{PRIV}\(\)"
}

num_opcode = {
  "calcr" : 0,
  "movr"  : 0,
  "calci" : 1,
  "movi"  : 1,
  "movl"  : 1,
  "load"  : 2,
  "store" : 3,
  "jalr"  : 4,
  "jcc"   : 5,
  "jmp"   : 5,
  "keyboard"     : 6,
  "monitor"      : 7,
  "monitor_busy" : 8,
  "priv"  : 9
}

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
  "+": 0, "-": 1, "<<": 2, ">>": 3, "&": 4, "|": 5, "^": 6,
  "==": 0, "!=": 1, ">=": 2, "<": 3,
  "halt": 0, "ien": 1, "idis": 2, "iack": 3, "iret": 4
}

nop_parsed = {
  "opcode":"calcr",
  "rs1":"zero",
  "rs2":"zero",
  "rd":"zero",
  "imm":"0",
  "opt":"null"
}

def hex_format(a, width):
  return format(2**32+a, '08x')[-width:]

def to_hex(parsed_list, label_table):
  ret = []
  for parsed in parsed_list:
    if parsed["opcode"] == "movl":
      imm = hex_format(label_table[parsed["label"]], 3)
    else:
      imm = hex_format(int(parsed["imm"]), 3)

    rs2    = hex_format(num_reg[parsed["rs2"]], 1)
    rs1    = hex_format(num_reg[parsed["rs1"]], 1)
    rd     = hex_format(num_reg[parsed["rd"]], 1)
    opt    = hex_format(num_opt[parsed["opt"]], 1)
    opcode = hex_format(num_opcode[parsed["opcode"]], 1)
    ret.append(f"{imm}{rs2}{rs1}{rd}{opt}{opcode} # {parsed['addr']:4x} | {parsed['line_num']:4d} | {parsed['line_raw']}")
  return ret

def main():
  parsed_list = []
  label_table = {}

  with open(sys.argv[1]) as f:
    line_num = -1
    addr = 0
    for line_raw in f:
      line_num += 1
      line = line_raw.replace(" ","")

      line_dict = {}
      line_dict["addr"]     = addr
      line_dict["line_num"] = line_num
      line_dict["line_raw"] = line_raw.strip()

      for k, v in parse_table.items():
        m = re.match(f"^{v}$", line)
        if m:
          parsed = {**line_dict, **nop_parsed, "opcode":k, **m.groupdict()}
          parsed_list.append(parsed)
          addr += 1
          break

      m = re.match(f'^{LABEL}:$', line)
      if m:
        label = m.groupdict()["label"]
        label_table[label] = addr

  print(*parsed_list, sep="\n")
  print(label_table, sep="\n")
  print(*to_hex(parsed_list, label_table), sep="\n")

main()
