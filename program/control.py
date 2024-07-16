import re
import sys
from common import *

def sub_identity(line, label):
  return ([line], [])

def sub_for(line, label):
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

def sub_if(line, label):
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

      if re.fullmatch("\}", line):
        mnemonic_list = stack.pop()
        print('\n'.join(mnemonic_list))
        continue

      for f in [sub_for, sub_if, sub_identity]:
        (bgn, end) = f(line, f"label_{label_count}")
        if bgn:
          print('\n'.join(bgn))
        if end:
          stack.append(end)
          label_count += 1
        if bgn or end:
          break

  print('\n'.join(code))

main()
