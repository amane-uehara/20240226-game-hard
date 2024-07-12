#!/bin/sh
FILEROOT=$(echo $1 |sed -e 's/.myc//')
cat stdio.myc ${FILEROOT}.myc > ./tmp/${FILEROOT}_1.txt
python3 control.py ./tmp/${FILEROOT}_1.txt > ./tmp/${FILEROOT}_2.txt
python3 substitute.py ./tmp/${FILEROOT}_2.txt > ./tmp/${FILEROOT}_3.txt
python3 linker.py ./tmp/${FILEROOT}_3.txt > ./tmp/${FILEROOT}_4.txt
python3 assembler.py ./tmp/${FILEROOT}_4.txt > ./tmp/${FILEROOT}_5.txt
cp ./tmp/${FILEROOT}_5.txt ../mem/rom.mem
#diff 2048.txt d.txt | head -n 10
