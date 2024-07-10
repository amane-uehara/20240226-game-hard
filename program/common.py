REG = "(zero|sp|ra|rv|tptr|tcmp|[a-j])"
VAL = "[+-]?(0x[0-9a-f]+|\d+)"
OP_CALC = "(\+|-|<<|<<<|>>|>>>|&|\||\^)"
OP_COMP = "(==|!=|>|>=|<|<=)"

LABEL = "(label_[0-9a-z_]+)"
LVAL = f"({LABEL}|{VAL})"
REG_LVAL = f"({REG}|{LABEL}|{VAL})"
FUNCTION = "(fn_[0-9a-z_]+)"

def hex_format(a, width):
  return format(2**32+a, '08x')[-width:]
