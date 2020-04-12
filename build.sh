#!/usr/bin/env bash

set -o nounset -o errexit -o pipefail -o errtrace -o xtrace

trap 'echo EXITED: "${BASH_SOURCE}" "${LINENO}"' ERR

container=$(basename $PWD)
echo CONTAINER: $container

docker-compose build

docker tag ${container}_${container}:latest reg.mydomain.org/${container}:latest
docker push reg.mydomain.org/${container}:latest

today=$(date "+%Y.%m.%d")
docker tag ${container}_${container}:latest reg.mydomain.org/${container}:$today
docker push reg.mydomain.org/${container}:$today

