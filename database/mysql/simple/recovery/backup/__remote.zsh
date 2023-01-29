#!/bin/bash
# bash /opt/mysql/_conf.d/clone4gig.zsh
# run at mysql-prd (docker-container for mysql)
set -e
#cmd='pwd && ls'
#cmd='xtrabackup --backup --no-timestamp --parallel=4 --stream=xbstream /tmp/xtrabackup'
cmd='innobackupex --no-timestamp --parallel=4 --stream=xbstream /tmp/xtrabackup'
container_id=$(docker ps -f "label=com.docker.swarm.service.name=zyb-mysql-master_zyb-mysql-m1" -q)
docker exec -i $container_id bash -c "$cmd"
