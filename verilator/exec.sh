#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)
ROOD_DIR=${SCRIPT_DIR}/../
VERILOG_FILE=$(basename $1)
VERILOG_WITHOUT_EXT=${VERILOG_FILE%.*}

cd ${SCRIPT_DIR}/tb \
  && pwd \
  && verilator \
      --timing \
      --binary -j 0 \
      -y ${ROOTDIR}/src/ \
      ${VERILOG_FILE} \
  && ./obj_dir/V${VERILOG_WITHOUT_EXT} \
  && cd ${SCRIPT_DIR}

