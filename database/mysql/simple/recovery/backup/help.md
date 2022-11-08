

```shell
# xtrabackup successful run on `softlang/mysql:v57kit`
#!/bin/bash
set -e

echo "----- backup  $(date) ----"
cmd='xtrabackup --backup --no-timestamp --parallel=2 --stream=xbstream -t=/tmp/xtrabackup '
echo "start at: $(date)" >> /tmp/debug.log
ssh -i /backup/id_rsa root@10.8.8.220 "docker exec -i recovery-zyb-mysql-m1 bash -c '$cmd'" | xbstream -x -C /app
echo "finish at: $(date)" >> /tmp/debug.log

# innobackupex --apply-log /app
# xtrabackup --prepare --target-dir=/data/backups/mysql/
xtrabackup --prepare --target-dir=/app
echo "apply-log done: $(date)" >> /tmp/debug.log

tail /tmp/debug.log
```

#### docker service's container-id

```shell
# get the docker container from sswarm-service-name
# better format
my_containerid=`docker ps -f "label=com.docker.swarm.service.name=gitlab_gitlab" --format "{{.ID}}"`
docker exec -it $my_containerid bash
# You could use the following command to print the container id:
docker container ls  | grep 'container-name' | awk '{print $1}'
# As a bonus point, if you want to login to the container with a container name:
docker exec -it $(docker container ls  | grep 'container-name' | awk '{print $1}') /bin/bash
```
