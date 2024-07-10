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
        if m := re.fullmatch(f"(?P<label>{LABEL}):", line):
          symbol_table[m.group("label")] = f"0x{hex_format(addr, 4)}"
        else:
          addr += 1
  return symbol_table

def link_address(filename, symbol_table):
  addr = 0
  with open(filename) as f:
    for line_raw in f:
      line_strip = line_raw.strip()
      line = line_strip.replace(" ","").split("//")[0]

      if line:
        if m := re.search(f"(?P<label>{LABEL})", line):
          label = m.group("label")
          label_addr = symbol_table[label]
          if re.search(":$", line):
            mnemonic = f"// {label}: {label_addr}"
          else:
            mnemonic = line.replace(label, label_addr, 1)
        else:
          mnemonic = line

        print(f"{mnemonic.ljust(22)} // addr:{hex_format(addr, 4)}")
        if mnemonic[0:2] != "//":
          addr += 1

def main():
  filename = sys.argv[1]
  symbol_table = create_symbol_table(filename)
  link_address(filename, symbol_table)

main()
