# docker build -t softlang/maven:reposilite2-java17 -f Dockerfile .
# docker run -d --name v2reposilite -m 1g -p 80:8080 softlang/maven:reposilite2-java17
# https://hub.docker.com/r/softlang/maven
FROM docker.io/maven:3.8.5-eclipse-temurin-17 AS builder
ARG uhome=/siri
WORKDIR $uhome/app
RUN useradd -d $uhome -s /bin/sh -u 1000 siri && mkdir -p $uhome/app/data && chown -R siri:siri $uhome
USER siri

ARG JAR01=https://repo.panda-lang.org/releases/org/panda-lang/reposilite/2.9.26/reposilite-2.9.26.jar
ADD --chown=siri:siri $JAR01 ./v2reposilite.jar
LABEL NEW_TOKEN="java -Xmx32M -Dreposilite.port=5001 -jar v2reposilite.jar -wd=data"
ENV REPO_PORT=8080
ENV REPO_PROXIED=https://maven.aliyun.com/repository/public
CMD exec java -Xmx64M -Dreposilite.port=${REPO_PORT} -Dreposilite.proxied=${REPO_PROXIED} \
    -Dtinylog.writerFile.file=/dev/stdout -jar ./v2reposilite.jar -wd=data
# java -Xmx64M -Dreposilite.proxied=https://maven.aliyun.com/repository/public 
#    -Dreposilite.port=8089  -jar reposilite-2.9.26.jar -wd=data
# 