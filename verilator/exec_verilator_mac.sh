#!/bin/sh
# /opt/homebrew/Cellar/verilator/5.024/share/verilator/include/verilated.mk
# /opt/homebrew/Cellar/verilator/5.024/share/verilator/verilator-config.cmake

VERILOG_FILE=$(basename $1)
VERILOG_WITHOUT_EXT=${VERILOG_FILE%.*}

cd tb

verilator \
  --binary \
  -j 0 \
  -I../../src \
  -I../../mem \
  -Wall \
  -Wno-UNUSEDSIGNAL \
  ${VERILOG_FILE} \
&& ./obj_dir/V${VERILOG_WITHOUT_EXT} \
