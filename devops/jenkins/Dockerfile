# docker build --network host --force-rm -f Dockerfile -t softlang/jenkins:v2.361-lts .
# build image
FROM jenkins/jenkins:2.361.4-lts-alpine

USER root
# install build tools
RUN sed -i s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g /etc/apk/repositories \
    && apk update && apk add --no-cache docker-cli nodejs \
    && rm -rf /var/cache/apk/*

USER jenkins
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS=-Xmx128m 
