set -e

cwd=$(realpath $(dirname $0))
#export DOCKER_CONTEXT=pod01.dev
app_name=xrdp-gnome.local
app_image=softlang/ubuntu:18.04-xrdp-xfce
#app_image=danielguerra/ubuntu-xrdp:18.04
#app_image=danielguerra/ubuntu-xrdp:20.04
pod_opts="-m=2g --memory-swap=-1 --ip=192.168.100.201 --network=apps"
# --privileged -w /app
docker run -d --name $app_name -h $app_name $pod_opts $app_image 
<<'///'
sh -ec '
if [ -f "/app/start.sh" ] && [ -x "/app/start.sh" ]; then
    exec /app/start.sh
else
    exec /usr/bin/tail -f /dev/null
fi
'
///
