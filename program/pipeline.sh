#!/bin/sh
FILEROOT="${1%.myc}"
python3 control.py $1 > tmp_${FILEROOT}_1.asm
python3 substitute.py tmp_${FILEROOT}_1.asm > tmp_${FILEROOT}_2.asm
python3 assembler.py tmp_${FILEROOT}_2.asm > ${FILEROOT}.asm
