import re
import sys
import textwrap
from common import *

def sub_identity(line, label):
  return (line, "")

def sub_for(line, label):
  bgn = ""
  end = ""
  if m := re.fullmatch("for\((?P<expressions>(.*))\)\{", line):
    expressions = m.group("expressions").split(";")
    initialization = expressions[0]
    condition      = expressions[1]
    advancement    = expressions[2]

    bgn = f"""
      {initialization}
      {label}_for_bgn:
      tptr = {label}_for_loop
      pc = ({condition}) ? tptr : pc + 1
      tptr = {label}_for_end
      pc = tptr
      {label}_for_loop:
    """

    end = f"""
      {advancement}
      tptr = {label}_for_bgn
      pc = tptr
      {label}_for_end:
    """

  return (bgn, end)

def sub_if(line, label):
  bgn = ""
  end = ""
  if m := re.fullmatch("if\((?P<condition>(.*))\)\{", line):
    condition = m.group("condition")

    bgn = f"""
      tptr = {label}_if_bgn
      pc = ({condition}) ? tptr : pc + 1
      tptr = {label}_if_end
      pc = tptr
      {label}_if_bgn:
    """

    end = f"{label}_if_end:"
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
        mnemonic = stack.pop()
        print(textwrap.dedent(mnemonic))
        continue

      for f in [sub_for, sub_if, sub_identity]:
        (bgn, end) = f(line, f"label_{label_count}")
        if bgn:
          print(textwrap.dedent(bgn))
        if end:
          stack.append(end)
          label_count += 1
        if bgn or end:
          break

main()
