#### mysql backup by xtrabackup

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