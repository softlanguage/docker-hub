#!/bin/bash
# run at mysql-prd (docker-container for mysql)
# bash /opt/pods/mysql/_conf.d/bak2uat.zsh
set -e
#cmd='pwd && ls'
cmd='xtrabackup --backup --no-timestamp --parallel=4 --stream=xbstream /tmp/xtrabackup'
container_id=$(docker container ls  | grep 'zyb-mysql-s3' | awk '{print $1}')
docker exec -i $container_id bash -c "$cmd"
