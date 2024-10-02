set -e
#export DOCKER_CONTEXT=pod01.dev
docker rm -f frontend
docker pull docker.io/node:18-slim
docker pull docker.io/nginx:1.14-alpine

docker build -t frontend:v1 -f vue.Dockerfile .
NET_PORT="-p9000:5000 --network bridge"
printf "docker run -d --rm --name frontend -h frontend.lan ${NET_PORT} frontend:v1" \
    |xargs -t -r -I{} sh -ec {}

# tar czf java17vue.tar.gz --exclude='crmls-ai/.git/*' crmls-ai/
# tar tvf java17vue.tar.gz
