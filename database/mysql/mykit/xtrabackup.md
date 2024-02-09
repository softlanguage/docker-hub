#### mysql backup by xtrabackup

```shell
#!/bin/bash
# bash /opt/mysql/_conf.d/clone4gig.zsh
set -e
time_start=$(date)
tar_file="bak_$(date +%Y%m%d-%H%M%S).zstd.tar" 
#cmd='innobackupex --no-timestamp --parallel=3 --stream=xbstream /tmp/xtrabackup'
cmd='innobackupex --no-timestamp --stream=tar /tmp/xtrabackup'
container_id=$(docker ps -f "label=com.docker.swarm.service.name=zyb-mysql-master_zyb-mysql-m1" -q)
docker exec -i $container_id bash -c "$cmd" | zstd > /mnt/prd-nas/bak4zyb/mysql-m1-clone/$tar_file

echo "done. $time_start  ~  $(date)"

# clearnup , retention 100 days
find /mnt/prd-nas/bak4zyb/mysql-m1-clone/ -name '*.zstd.tar' -type f -mtime +100 -print -exec rm -rf {} \; 

```

```shell
# zyb-uat-recovery shell
#!/bin/bash
set -e

echo "----- backup  $(date) ----"
cmd='xtrabackup --backup --no-timestamp --parallel=2 --stream=xbstream -t=/tmp/xtrabackup '
echo "start at: $(date)" >> /tmp/debug.log
ssh -i /backup/id_rsa root@10.8.8.220 "docker exec -i recovery-zyb-mysql-m1 bash -c '$cmd'" | xbstream -x -C /app
echo "finish at: $(date)" >> /tmp/debug.log

innobackupex --apply-log /app
echo "apply-log done: $(date)" >> /tmp/debug.log

tail /tmp/debug.log

```

#### docker exec on swarm service

```shell
# better format
my_containerid=`docker ps -f "label=com.docker.swarm.service.name=gitlab_gitlab" --format "{{.ID}}"`
docker exec -it $my_containerid bash

# You could use the following command to print the container id:
docker container ls  | grep 'container-name' | awk '{print $1}'

# As a bonus point, if you want to login to the container with a container name:
docker exec -it $(docker container ls  | grep 'container-name' | awk '{print $1}') /bin/bash
```

#### 

```shell
#!/bin/bash
cmd='innobackupex --no-timestamp --databases="mysql sys information hlzyb" --parallel=2 --stream=xbstream -t /tmp/xtrabackup '
#ssh etl04.prd "docker exec -i mysql-m1 bash -c '$cmd'" > zzz/abc.bak
ssh root@10.8.8.220 "docker exec -i mysql-m1 bash -c '$cmd'" | xbstream -x -C /opt/bak1

# xbstream -x -C /data/temp/"
ssh -i ~/.ssh/id_rsa root@10.8.8.220 "docker exec -i mysql-m1 bash -c '$cmd'" | xbstream -x -C /opt/bak1

# success
cmd='innobackupex --parallel=2 --stream=xbstream /tmp/xtrabackup '
ssh -i ~/.ssh/id_rsa root@10.8.8.220 "docker exec -i mysql-m1 bash -c '$cmd'" | xbstream -x -C /opt/bak1
cmd='xtrabackup --backup --no-timestamp --databases="mysql information_schema performance_schema sys hlzyb wbmeet" --parallel=2 --stream=xbstream -t=/tmp/xtrabackup '

ssh -i ~/.ssh/id_rsa root@remote "docker exec -i mysql-m1 bash -c '$cmd'" | xbstream -x -C /opt/bak1
innobackupex --apply-log /backups/2018-07-30_11-04-55/


# testing
cmd='xtrabackup --backup --no-timestamp --databases="mysql information_schema performance_schema sys hlzyb wbmeet" --parallel=2 
--stream=xbstream -t=/tmp/xtrabackup '
```