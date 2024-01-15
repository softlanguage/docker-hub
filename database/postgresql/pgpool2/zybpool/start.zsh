set -e

workdir=$(realpath $(dirname $0))
echo "workdir = $workdir"
# workdir for postgres
mkdir -p $workdir/workdir/socks
chown -R 26:26 $workdir/workdir

docker compose -p pgpool2 -f $workdir/compose.yaml up -d --remove-orphans
docker ps -l

echo 'well done.'
exit 0

#mkdir -p $workdir/{data,backup}
#chown -R 999:999 $workdir/{data,backup}
#mybox=pgdb13zyb
#img_tag=docker.io/softlang/citus-cn:11.3-pg13fdw
#podman rm -i -t 15 -f $mybox
#podman run -itd --name $mybox -h $mybox --cpus '2' -m 2g \
#	--tz Asia/Shanghai --network host --restart always --init \
#	-e POSTGRES_PASSWORD=123654 -e PGPORT=5430 \
#	--tmpfs /dev/shm --no-healthcheck \
#	-v $workdir/data:/var/lib/postgresql/data \
#	$img_tag bash
# pg_basebackup --progress -X stream -U postgres  -h 10.8.8.204 -p 5432 -R -D ./ & disown %-
podman ps -l
# podman run -itd --name oraclelinux -h oraclelinux -m 2G --init oraclelinux:9
