set -e

workdir=$(realpath $(dirname $0))
echo "workdir = $workdir"
# workdir for postgres
mkdir -p $workdir/workdir/socks
chown -R 26:26 $workdir/workdir

name4pod=ii-pgpool2

if command -v docker > /dev/null; then
    docker compose -p $name4pod -f $workdir/compose.yaml up -d --remove-orphans
    docker ps -l
    echo 'well done by docker.'
else
    podman run -itd --name $name4pod -h $name4pod --cpus '1' -m 1g \
	    --tz Asia/Shanghai --network host --restart always --init \
	    -e PGHOST=/workdir/socks -e PGPORT=5678 \
	    --tmpfs /dev/shm --no-healthcheck \
	    -v $workdir/workdir/:/workdir \
	    docker.io/softlang/pgpool:v4.4.3 /bin/sh -c '
set -e
grep "postgres" /etc/passwd
if command -v /workdir/run.zsh > /dev/null; then
    exec /workdir/run.zsh
fi
echo "Error: no /workdir/run.zsh"
exec tail -f /dev/null'

    podman ps -l
    echo 'well done by podman.'
fi

# pg_basebackup --progress -X stream -U postgres  -h 10.8.8.204 -p 5432 -R -D ./ & disown %-
# podman run -itd --name oraclelinux -h oraclelinux -m 2G --init oraclelinux:9
