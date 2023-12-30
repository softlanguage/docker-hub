set -e

workdir=$(realpath $(dirname $0))
echo "workdir = $workdir"

#img_tag=docker.io/softlang/mysql:v8.2
#img_tag=docker.io/mysql:8.2-oracle
img_tag=docker.io/mysql:8.0.32-oracle

port=9035

ndbs=(
  'p1mysql'
  's2mysql'
  's3mysql'
  's4mysql'
)

for mybox in "${ndbs[@]}"; do
  ((port++))
  printf "\n---> mysql $mybox\t$port\n"

  podman rm -i -t 5 -f $mybox
  podman run -itd --name $mybox -h $mybox --cpuset-cpus '2' -m 2G \
  --tz Asia/Shanghai \
	-e MYSQL_ROOT_PASSWORD=123654 \
  --network apps -p "$port:3306" \
	-v $workdir/dist:/dist -w /dist \
	-v mycnf_${mybox}:/etc/mysql \
	-v myndb_${mybox}:/var/lib/mysql \
	$img_tag
done

# podman run -itd --name oraclelinux -h oraclelinux -m 2G --init oraclelinux:9
