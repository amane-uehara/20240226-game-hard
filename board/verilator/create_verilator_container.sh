#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)
REPOSITORY_ROOT="${SCRIPT_DIR}/../.."
IMAGE_NAME="hdlc/verilator"
CONTAINER_NAME="my_verilator"

docker rm -f ${CONTAINER_NAME}

docker pull ${IMAGE_NAME}

docker create \
  --volume ${REPOSITORY_ROOT}/src:/root/src \
  --volume ${REPOSITORY_ROOT}/mem:/root/mem \
  --volume ${REPOSITORY_ROOT}/board/verilator/tb:/root/tb \
  --name ${CONTAINER_NAME} \
  -it ${IMAGE_NAME} /bin/sh

docker start ${CONTAINER_NAME}

docker exec -it ${CONTAINER_NAME} /bin/sh -c "\
  apt update 2>/dev/null; \
  apt remove -y clang; \
  apt install -y clang-9; \
  ln -s /usr/bin/clang++-9 /usr/bin/clang++ \
  apt install -y perl-doc; \
  verilator --help; \
"

