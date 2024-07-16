import re
import sys
from common import *

def substitute_for(line, label):
  bgn = []
  end = []
  if m := re.fullmatch("for\((?P<expressions>(.*))\)\{", line):
    expressions = m.group("expressions").split(";")
    initialization = expressions[0]
    condition      = expressions[1]
    advancement    = expressions[2]

    bgn.append(initialization)
    bgn.append(f"{label}_for_bgn:")
    bgn.append(f"tptr = {label}_for_loop")
    bgn.append(f"pc = ({condition}) ? tptr : pc + 1")
    bgn.append(f"tptr = {label}_for_end")
    bgn.append(f"pc = tptr")
    bgn.append(f"{label}_for_loop:")

    end.append(advancement)
    end.append(f"tptr = {label}_for_bgn")
    end.append(f"pc = tptr")
    end.append(f"{label}_for_end:")

  return (bgn, end)

def substitute_if(line, label):
  bgn = []
  end = []
  if m := re.fullmatch("if\((?P<condition>(.*))\)\{", line):
    condition = m.group("condition")

    bgn.append(f"tptr = {label}_if_bgn")
    bgn.append(f"pc = ({condition}) ? tptr : pc + 1")
    bgn.append(f"tptr = {label}_if_end")
    bgn.append(f"pc = tptr")
    bgn.append(f"{label}_if_bgn:")

    end.append(f"{label}_if_end:")

  return (bgn, end)

def main():
  code = []
  stack = []
  label_count = 0

  filename = sys.argv[1]
  with open(filename) as f:
    for line_raw in f:
      line_delete_comment = re.split("//", line_raw)[0].strip()
      line = line_delete_comment.replace(" ", "")

      (bgn_for, end_for) = substitute_for(line, f"label_{label_count}")
      (bgn_if, end_if) = substitute_if(line, f"label_{label_count}")

      if re.fullmatch("\}", line):
        code += stack.pop()
      elif bgn_for:
        code += bgn_for
        stack.append(end_for)
        label_count += 1
      elif bgn_if:
        code += bgn_if
        stack.append(end_if)
        label_count += 1
      else:
        code.append(line_delete_comment)

  print('\n'.join(code))

main()
