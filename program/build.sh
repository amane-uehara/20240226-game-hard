#!/bin/sh
FILEROOT=$(echo $1 |sed -e 's/.myc//')
cat stdio.myc ${FILEROOT}.myc > tmp_${FILEROOT}_1.txt
python3 control.py tmp_${FILEROOT}_1.txt > tmp_${FILEROOT}_2.txt
python3 substitute.py tmp_${FILEROOT}_2.txt > tmp_${FILEROOT}_3.txt
python3 assembler.py tmp_${FILEROOT}_3.txt > tmp_${FILEROOT}_4.txt
cp tmp_${FILEROOT}_4.txt ../mem/rom.mem
#diff 2048.txt d.txt | head -n 10
