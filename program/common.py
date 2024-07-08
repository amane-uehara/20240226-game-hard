REG = "(zero|sp|ra|rv|tptr|tcmp|[a-j])"
RS1 = f"(?P<rs1>{REG})"
RS2 = f"(?P<rs2>{REG})"
RD  = f"(?P<rd>{REG})"
IMM = "(?P<imm>[+-]?(0x[0-9a-f]+|\d+))"
CALC = "(?P<opt>(\+|-|<<|<<<|>>|>>>|&|\||\^))"
COMP = "(?P<opt>(==|!=|>|>=|<|<=))"
COMMENT = "(//.*)"

def hex_format(a, width):
  return format(2**32+a, '08x')[-width:]
