REG = "(zero|sp|ra|rv|tptr|tcmp|[a-j])"
VAL = "[+-]?(0x[0-9a-f]+|\d+)"
LABEL = "(label_[0-9a-z_]+)"
LVAL = f"({LABEL}|{VAL})"
REG_LVAL = f"({REG}|{LABEL}|{VAL})"
FN_NAME = "(fn_[0-9a-z_]+)"

RS1 = f"(?P<rs1>{REG})"
RS2 = f"(?P<rs2>{REG})"
RD  = f"(?P<rd>{REG})"
IMM = f"(?P<imm>{VAL})"
CALC = "(?P<opt>(\+|-|<<|<<<|>>|>>>|&|\||\^))"
COMP = "(?P<opt>(==|!=|>|>=|<|<=))"
COMMENT = "(//.*)"

def hex_format(a, width):
  return format(2**32+a, '08x')[-width:]
