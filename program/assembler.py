import re

assembly_code = [
  "a = b + c",
  "a = b",
  "a = 57",
  "d = e + 3",
  "zero = zero + 3",
  "mem[f-4] = g",
  "mem[f-0] = g",
  "mem[f+0] = g",
  "mem[f+4] = g",
  "h = mem[i+8]",
  "a = pc + 4, pc = b",
  "pc = c",
  "if (e == 0) pc = d",
  "if (f != 0) pc = d",
  "if (g >= 0) pc = d",
  "if (h <  0) pc = d"
]

RS1 = "(?P<rs1>([a-z]|zero))"
RS2 = "(?P<rs2>([a-z]|zero))"
RD  = "(?P<rd>([a-z]|zero))"
IMM = "(?P<imm>[+-]?\d+)"
CALC = "(?P<opt>(\+|-))"
COMP = "(?P<opt>(==|!=|>=|<))"

parse_table = {
  "calcr": f"{RD}={RS1}{CALC}{RS2}",
  "movr":  f"{RD}={RS1}",
  "calci": f"{RD}={RS1}{CALC}{IMM}",
  "movi":  f"{RD}={IMM}",
  "load":  f"{RD}=mem\[{RS1}{IMM}?\]",
  "store": f"mem\[{RS1}{IMM}?\]={RS2}",
  "jalr":  f"{RD}=pc\+4,pc={RS1}",
  "jmp":   f"pc={RS1}",
  "jcc":   f"if\({RS2}{COMP}0\)pc={RS1}"
}

num_opcode = {
  "calcr": 1, "movr": 1, "calci": 2, "movi": 2,
  "load": 3, "store": 4,
  "jalr": 5, "jmp": 6, "jcc": 7
}

num_reg = {
  "zero": 0,
  "a": 1, "b": 2, "c": 3, "d": 4,
  "e": 5, "f": 6, "g": 7, "h": 8,
  "i": 9
}

num_opt = {
  "null": 0,
  "+": 0, "-": 1,
  "==": 0, "!=": 1, ">=": 2, "<": 3
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

def main():
  ret = []
  for line in assembly_code:
    line = line.replace(" ","")
    print(line)

    for k, v in parse_table.items():
      m = re.match(f"^{v}$", line)
      if m:
        parsed = {**nop_parsed, **m.groupdict()}
        parsed["opcode"] = k
        print(parsed)

        hex_list = []
        hex_list.append(hex_format(int(parsed["imm"]), 3))
        hex_list.append(hex_format(num_reg[parsed["rs2"]], 1))
        hex_list.append(hex_format(num_reg[parsed["rs1"]], 1))
        hex_list.append(hex_format(num_reg[parsed["rd"]], 1))
        hex_list.append(hex_format(num_opt[parsed["opt"]], 1))
        hex_list.append(hex_format(num_opcode[parsed["opcode"]], 1))
        print("".join(hex_list))
        break

  print(*ret, sep="\n")

main()
