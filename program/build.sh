#!/bin/sh
cat stdio.myc 2048.myc > a.txt
python3 control.py a.txt > b.txt
python3 substitute.py b.txt > c.txt
python3 assembler.py c.txt > d.txt
cp d.txt ../mem/rom.mem
diff 2048.txt d.txt | head -n 10
