import os
import sys
import re

file_label    = "LABEL_" + os.path.splitext(os.path.basename(__file__))[0] + "_"
match_reg     = "[a-k]|zero|ra|sp|tptr|tcmp"
match_rs1     = "(?P<rs1>" + match_reg + ")"
match_rs2     = "(?P<rs2>" + match_reg + ")"
match_rd      = "(?P<rd>" + match_reg + ")"
match_imm     = "(?P<imm>0x[0-9A-F]+|\d+)"
match_mem     = "mem\[ *" + match_rs2 + " *]"
match_mem_imm = "mem\[ *" + match_rs2 + " *(?P<pm>[+-]) *" + match_imm + " *]"
match_calc    = "(?P<calc>\+|-|>>|<<|&|\||\^)"
match_cmp     = "(?P<cmp>==|!=|>|<|>=|<=)"
match_label   = "(?P<label>[a-z][a-z0-9_]+)"

ope_dict = {'+':"add", '-':"sub", '>>':"sra", '<<':"sla", '&':"and", '|':"or", '^':"xor"}
neg_cmp_dict = {'==':"jneq", '!=':"jeq", '>':"jle", '<':"jge", '>=':"jlt", '<=':"jgt"}

def imm_parse(s):
  if "0x" in s: return int(s, 16)
  else:         return int(s)

def main():
  mpy_file = sys.argv[1]
  asm_file = mpy_file.replace(".mpy", ".asm")
  mpy_lines = []

  with open(mpy_file, mode='r') as f:
    line_number = 0
    for raw_line in f.read().splitlines():
      line_number += 1

      line = raw_line.split("#")[0].strip()
      if not line: continue

      if (line[0:3] == "if "):
        asm_init, asm_last = asm_if(line, line_number)
      elif (line[0:6] == "while "):
        asm_init, asm_last = asm_while(line, line_number)
      else:
        asm_init = asm_other(line)
        asm_last = []

      item = {}
      item["init"]  = add_comment(asm_init, line_number, raw_line)
      item["last"]  = add_comment(asm_last, line_number, raw_line)
      item["depth"] = len(re.search("^( *)", raw_line).groups()[0])

      mpy_lines.append(item)

  asm_lines = concat(mpy_lines)
  print(*asm_lines, sep='\n')

  with open(asm_file, mode='w') as f:
    for asm in asm_lines:
      if (asm[0:9] == "LABEL_FN_"):
        f.write("\n")
      f.write(asm)
      f.write("\n")

def parse_paren(line, label):
  asm_init = []
  asm_init.append("li tptr " + label)

  if m := re.search('\({} {} {}\):$'.format(match_rs1, match_cmp, match_rs2), line):
    asm_init.append("sub tcmp {} {}".format(m.group("rs1"), m.group("rs2")))
    jcc = neg_cmp_dict[m.group("cmp")]
    asm_init.append("{} tcmp tptr".format(jcc))

  elif m := re.search('\({} {} {}\):$'.format(match_rs1, match_cmp, match_imm), line):
    asm_init.append("li tcmp {}".format(m.group("imm")))
    asm_init.append("sub tcmp {} tcmp".format(m.group("rs1")))
    jcc = neg_cmp_dict[m.group("cmp")]
    asm_init.append("{} tcmp tptr".format(jcc))

  return asm_init

def asm_if(line, label_index):
  label = file_label + str(label_index) + "_IF"
  asm_init = parse_paren(line, label)
  asm_last = []
  asm_last.append(label+":")
  return asm_init, asm_last

def asm_while(line, label_index):
  label_bgn = file_label + str(label_index) + "_WHILE_BGN"
  label_end = file_label + str(label_index) + "_WHILE_END"

  asm_init = []
  asm_init.append(label_bgn+":")
  asm_init += parse_paren(line, label_end)

  asm_last = []
  asm_last.append("li tptr " + label_bgn)
  asm_last.append("jeq zero zero tptr")
  asm_last.append(label_end+":")
  return asm_init, asm_last

def asm_other(line):
  asm_init = []

  if m := re.search('^def {}\(\):$'.format(match_label), line):
    asm_init.append("LABEL_FN_{}:".format(m.group("label")))

  elif m := re.search("^return$", line):
    asm_init.append("jalr zero ra")

  elif m := re.search("^push\((?P<regs>.*)\)$", line):
    asm_init += asm_push(m.group("regs").split(','))

  elif m := re.search("^pop\((?P<regs>.*)\)$", line):
    asm_init += asm_pop(m.group("regs").split(','))

  elif m := re.search('^a = {}\(\)$'.format(match_label), line):
    asm_init.append("li tptr LABEL_FN_{}".format(m.group("label")))
    asm_init.append("jalr ra tptr")

  elif m := re.search('^a = {}\((?P<regs>.*)\)$'.format(match_label), line):
    regs = m.group("regs").split(',')
    asm_init += asm_push(regs)
    asm_init.append("li tptr LABEL_FN_{}".format(m.group("label")))
    asm_init.append("jalr ra tptr")
    asm_init += asm_pop(reversed(regs))

  elif m := re.search('^{} = {}$'.format(match_mem, match_rs1), line):
    asm_init.append("sw {} ({} {:+})".format(m.group("rs1"), m.group("rs2"), 0))

  elif m := re.search('^{} = {}$'.format(match_mem_imm, match_rs1), line):
    imm = imm_parse(m.group("pm") + m.group("imm"))
    asm_init.append("sw {} ({} {:+})".format(m.group("rs1"), m.group("rs2"), imm))

  elif m := re.search('^{} = {}$'.format(match_rd, match_mem), line):
    asm_init.append("lw {} ({} {:+})".format(m.group("rd"), m.group("rs2"), 0))

  elif m := re.search('^{} = {}$'.format(match_rd, match_mem_imm), line):
    imm = imm_parse(m.group("pm") + m.group("imm"))
    asm_init.append("lw {} ({} {:+})".format(m.group("rd"), m.group("rs2"), imm))

  elif m := re.search('^{} = {}$'.format(match_rd, match_rs1), line):
    asm_init.append("add {} {} zero".format(m.group("rd"), m.group("rs1")))

  elif m := re.search('^{} = {} {} {}$'.format(match_rd, match_rs1, match_calc, match_rs2), line):
    asm_init.append("{} {} {} {}".format(ope_dict[m.group("calc")], m.group("rd"), m.group("rs1"), m.group("rs2")))

  elif m := re.search('^{} = {} {} {}$'.format(match_rd, match_rs1, match_calc, match_imm), line):
    imm  = imm_parse(m.group("imm"))
    asm_init.append("{}i {} {} {}".format(ope_dict[m.group("calc")], m.group("rd"), m.group("rs1"), imm))

  elif m := re.search('^{} = {}$'.format(match_rd, match_imm), line):
    imm = imm_parse(m.group("imm"))
    asm_init.append("li {} {}".format(m.group("rd"), imm))

  elif m := re.search('^{} = {}$'.format(match_rd, match_imm), line):
    imm = imm_parse(m.group("imm"))
    asm_init.append("li {} {}".format(m.group("rd"), imm))

  elif m := re.search('^halt\(\)$', line):
    asm_init.append("halt")

  elif m := re.search('^ie\(\)$', line):
    asm_init.append("ie")

  elif m := re.search('^ide\(\)$', line):
    asm_init.append("ide")

  elif m := re.search('^ivec\({}\)$'.format(match_rs1), line):
    asm_init.append("ivec {}".format(m.group("rs1")))

  elif m := re.search('^iret\(\)$', line):
    asm_init.append("iret")

  else:
    print("parse error in " + str(line))
    sys.exit(1)

  return asm_init

def asm_push(reg_list):
  asm_init = []
  shift = 0
  for rs1 in reg_list:
    asm_init.append("sw {} (sp -{})".format(rs1.strip(), shift))
    shift += 4
  asm_init.append("subi sp sp {}".format(shift))
  return asm_init

def asm_pop(reg_list):
  asm_init = []
  shift = 4
  for rd in reg_list:
    asm_init.append("lw {} (sp +{})".format(rd.strip(), shift))
    shift += 4
  asm_init.append("addi sp sp {}".format(shift-4))
  return asm_init

def add_comment(asm_list, line_number, raw_line):
  ret = []
  for asm in asm_list:
    ret.append("{:30} # {:4d} | {}".format(asm, line_number, raw_line))
  return ret

def concat(lines):
  ret = []
  tmp = []
  last = []
  root_depth = lines[0]["depth"]
  lines.append({"init":[], "last":[], "depth":root_depth})

  for i in range(len(lines)-1):
    item = lines[i]
    if item["depth"] == root_depth:
      ret += item["init"]
      last = item["last"]
    else:
      tmp.append(item)
      if lines[i+1]["depth"] == root_depth:
        ret += concat(tmp)
        tmp = []
        ret += last

  return ret

if __name__ == "__main__":
  main()
