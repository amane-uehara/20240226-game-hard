#!/bin/sh
python3 control.py 2048.myc > a.txt
python3 substitute.py a.txt > b.txt
python3 assembler.py b.txt > c.txt
cp c.txt ../mem/rom.mem
diff 2048.txt c.txt | head -n 10
