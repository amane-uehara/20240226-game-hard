#!/bin/sh

GTKWAVE="/mnt/c/iverilog/gtkwave/bin/gtkwave.exe"
CONTAINER_NAME="my_verilator"
VERILOG_FILE=$(basename $1)
VERILOG_WITHOUT_EXT=${VERILOG_FILE%.*}
SCRIPT_DIR=$(cd $(dirname $0); pwd)
VCD_FILE="${SCRIPT_DIR}/tb/wave/${VERILOG_FILE}.vcd"
WAVE_FILE="${SCRIPT_DIR}/wave.gtkw"

rm -f ${VCD_FILE}

docker start ${CONTAINER_NAME}

docker exec -it ${CONTAINER_NAME} /bin/sh -c "\
  cd /root/tb && \
  verilator \
    --binary \
    -j 0 \
    -I/root/src \
    -I/root/mem \
    -Wall \
    -Wno-UNUSEDSIGNAL \
    -Wno-UNOPTFLAT \
    -Wno-UNUSEDPARAM \
    --trace --trace-params --trace-structs --trace-underscore \
    ${VERILOG_FILE} \
  && ./obj_dir/V${VERILOG_WITHOUT_EXT} \
"

${GTKWAVE} \
  $(echo "${VCD_FILE}"  |sed -e 's@/mnt/c/@C:\\\\@' |sed -e 's@/@\\\\@g') \
  $(echo "${WAVE_FILE}" |sed -e 's@/mnt/c/@C:\\\\@' |sed -e 's@/@\\\\@g') \

