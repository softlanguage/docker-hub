set -e

workdir=$(realpath $(dirname $0))
echo "workdir = $workdir"

mkdir -p $workdir/{data,backup}
chown -R 999:999 $workdir/{data,backup}

mybox=pgdb13zyb
img_tag=docker.io/softlang/citus-cn:11.3-pg13fdw

podman rm -i -t 15 -f $mybox

podman run -itd --name $mybox -h $mybox --cpuset-cpus '7' -m 15G \
    --tz Asia/Shanghai --network host --restart always --init \
	-e POSTGRES_PASSWORD=123654 -e PGPORT=5430 \
    --tmpfs /dev/shm --no-healthcheck \
	-v $workdir/data:/var/lib/postgresql/data \
	-v $workdir/backup:/var/lib/postgresql/backup \
	$img_tag bash

podman ps -l
# podman run -itd --name oraclelinux -h oraclelinux -m 2G --init oraclelinux:9