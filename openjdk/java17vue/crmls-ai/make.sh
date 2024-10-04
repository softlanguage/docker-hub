set -e
#export DOCKER_CONTEXT=pod01.dev
app_name=frontend
docker rm -f $app_name
docker pull docker.io/node:18-slim
docker pull docker.io/nginx:1.14-alpine

docker build -t $app_name:v1 -f vue.Dockerfile .
NET_PORT="-p9000:5000 --network bridge"
printf "docker run -d --rm --name $app_name -h $app_name.lan ${NET_PORT} $app_name:v1" \
    |xargs -t -r -I{} sh -ec {}

# tar czf java17vue.tar.gz --exclude='crmls-ai/.git/*' crmls-ai/
# tar tvf java17vue.tar.gz

app_name=api-java17
docker rm -f $app_java
docker pull -q docker.io/eclipse-temurin:17-jre-focal
docker pull -q docker.io/maven:3.8.5-eclipse-temurin-17

docker build -t $app_java:v1 -f Dockerfile . #--progress=plain
NET_PORT="-p9001:5000 --network bridge"
printf "docker run -d --rm --name $app_java -h $app_java.lan ${NET_PORT} $app_java:v1" \
    |xargs -t -r -I{} sh -ec {}

# tar czf vue-java.tar.gz --exclude='crmls-ai/.git/*' crmls-ai/
# tar tvf vue-java.tar.gz
