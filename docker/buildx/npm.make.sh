set -e
#export DOCKER_CONTEXT=pod01.dev
docker rm -f frontend
docker pull docker.io/node:18-slim
docker pull docker.io/nginx:1.14-alpine

build_options="--cpuset-cpus=0 -m 4g --force-rm"
docker build $build_options -t frontend:v1 -f vue.Dockerfile .
NET_PORT="-p9000:5000 --network bridge --rm -d"
printf "docker run --name frontend.lan -h frontend.lan ${NET_PORT} frontend:v1" \
    |xargs -t -r -I{} sh -ec {}
