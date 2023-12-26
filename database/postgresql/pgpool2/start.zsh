# to start a container
set -e

env_dir=$(realpath $(dirname $0))
echo "env_dir = $env_dir"

pod_name=pgpoolII
# rm if exist
docker rm -f $pod_name || echo "---> no $pod_name"

#quay.io/buildah/stable
img_tag='docker.io/oraclelinux:8'

# sshd need --cap-add AUDIT_WRITE
# create buildah container,4.5G=4608M, --network host
docker run -itd --name $pod_name -h $pod_name --init \
    --cpuset-cpus '0,1' -m 2G -e TZ=Asia/Shanghai \
    --network app -p '8986-8989:8986-8989' \
    -v $env_dir/workdir:/workdir -w=/workdir \
	$img_tag

docker ps -l

# https://www.pgpool.net/mediawiki/index.php/Downloads
# https://www.pgpool.net/yum/rpms/
# https://www.pgpool.net/yum/rpms/4.4/redhat/rhel-8-x86_64/pgpool-II-pg13-4.4.5-1pgdg.rhel8.x86_64.rpm
# wget -c https://www.pgpool.net/yum/rpms/4.4/redhat/rhel-8-x86_64/pgpool-II-pg13-4.4.5-1pgdg.rhel8.x86_64.rpm

# alias mxs='runuser -u pgpoolII -- pgpoolII -C /workdir'
# https://dlm.mariadb.com/3680961/pgpoolII/22.08.11/yum/centos/8/x86_64/pgpoolII-22.08.11-1.rhel.8.x86_64.rpm
# podman run -itd --name oraclelinux -h oraclelinux -m 2G --init oraclelinux:9

