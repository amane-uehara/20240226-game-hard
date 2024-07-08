import re
import sys

LABEL = "(?P<label>(label[_0-9a-z]+))"

def hex_format(a, width):
  return format(2**32+a, '08x')[-width:]

def create_symbol_table(filename):
  symbol_table = {}
  with open(filename) as f:
    addr = 0
    for line_raw in f:
      line_strip = line_raw.strip()

      m = re.search(f"^ *(//.*)?$", line_strip)
      if m:
        continue

      m = re.search(f"^ *deflabel {LABEL}", line_strip)
      if m:
        symbol_table[m.group("label")] = f"0x{hex_format(addr, 4)}"
        continue
      addr += 1
  return symbol_table

def main():
  filename = sys.argv[1]
  symbol_table = create_symbol_table(filename)

  with open(filename) as f:
    addr = 0
    for line_raw in f:
      line_strip = line_raw.strip()

      m = re.search(f"^ *(//.*)?$", line_strip)
      if m:
        print(line_strip)
        continue

      m = re.search(f"^ *deflabel {LABEL}", line_strip)
      if m:
        label = m.group("label")
        print(f"// {label}: {symbol_table[label]}")
        continue

      m = re.search(f"{LABEL}", line_strip)
      if m:
        label = m.group("label")
        label_addr = symbol_table[label]
        print(line_strip.replace(label, label_addr, 1), end="")
      else:
        print(line_strip, end="")
      print(f" // addr:{hex_format(addr, 4)}")
      addr += 1

main()
