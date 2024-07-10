import re
import sys
from common import *

def create_symbol_table(filename):
  symbol_table = {}
  addr = 0
  with open(filename) as f:
    for line_raw in f:
      line_strip = line_raw.strip()
      line = line_strip.replace(" ","").split("//")[0]

      if line:
        m = re.fullmatch(f"(?P<label>{LABEL}):", line)
        if m:
          symbol_table[m.group("label")] = f"0x{hex_format(addr, 4)}"
          continue
        addr += 1
  return symbol_table

def main():
  filename = sys.argv[1]
  symbol_table = create_symbol_table(filename)
  addr = 0
  with open(filename) as f:
    for line_raw in f:
      line_strip = line_raw.strip()
      line = line_strip.replace(" ","").split("//")[0]

      if line:
        if m := re.fullmatch(f"(?P<label>{LABEL}):", line):
          label = m.group("label")
          print(f"// {label}: {symbol_table[label]}")
          continue

        if m := re.search(f"(?P<label>{LABEL})", line):
          label = m.group("label")
          label_addr = symbol_table[label]
          print(line.replace(label, label_addr, 1), end="")
        else:
          print(line, end="")
        print(f" // addr:{hex_format(addr, 4)}")
        addr += 1

main()
