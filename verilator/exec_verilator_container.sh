#!/bin/sh

CONTAINER_NAME="my_verilator"
VERILOG_FILE=$(basename $1)
VERILOG_WITHOUT_EXT=${VERILOG_FILE%.*}
TEMP_FILE=$(mktemp)

docker start ${CONTAINER_NAME}

docker exec -i ${CONTAINER_NAME} /bin/sh -c "\
  cd /root/tb && \
  verilator \
    --binary \
    -j 0 \
    -I/root/src \
    -I/root/mem \
    -Wall \
    -Wno-UNUSEDSIGNAL \
    ${VERILOG_FILE} \
  && ./obj_dir/V${VERILOG_WITHOUT_EXT} \
"\
> $TEMP_FILE

cat $TEMP_FILE

EXIT_STATUS=1
if cat $TEMP_FILE | egrep -q "ALL TESTS PASSED"; then
  EXIT_STATUS=0
fi

rm $TEMP_FILE
exit $EXIT_STATUS
