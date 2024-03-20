#!/bin/sh

CONTAINER_NAME="my_verilator"
VERILOG_FILE=$(basename $1)
VERILOG_WITHOUT_EXT=${VERILOG_FILE%.*}

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
    --trace --trace-params --trace-structs --trace-underscore \
    ${VERILOG_FILE} \
  && ./obj_dir/V${VERILOG_WITHOUT_EXT} \
"
