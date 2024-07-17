#!/bin/sh
if echo $1 |egrep 'myc$' > /dev/null ;then :; else echo 'ERROR: NOT.myc FILE' ;fi
if [ ! -f $1 ]; then echo "ERROR: $1 NOT FOUND" ;fi

python3 control.py src/stdio.myc > ./tmp/stdio_1.txt
python3 substitute.py ./tmp/stdio_1.txt > ./tmp/stdio_2.txt

FILEROOT=$(basename $1 |sed -e 's/.myc//')
python3 control.py $1 > ./tmp/${FILEROOT}_1.txt
python3 substitute.py ./tmp/${FILEROOT}_1.txt > ./tmp/${FILEROOT}_2.txt

python3 linker.py ./tmp/stdio_2.txt ./tmp/${FILEROOT}_2.txt > ./tmp/${FILEROOT}_3.txt
python3 assembler.py ./tmp/${FILEROOT}_3.txt > ./tmp/${FILEROOT}_4.txt
cp ./tmp/${FILEROOT}_4.txt ../mem/rom.mem
ls -l ./tmp/stdio_*.txt ./tmp/${FILEROOT}_*.txt
wc -l ./tmp/stdio_*.txt ./tmp/${FILEROOT}_*.txt
#diff 2048.txt d.txt | head -n 10
