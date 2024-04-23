# docker build --network host --force-rm -f Dockerfile -t softlang/jenkins:2.414.3-lts-py .
# build image
FROM jenkins/jenkins:2.414.3-lts-alpine

USER root
# install build tools (podman-remote)
RUN sed -i s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g /etc/apk/repositories \
    && apk update && apk add --no-cache tzdata docker-cli python3 \
    && rm -rf /var/cache/apk/*

USER jenkins
RUN python -m ensurepip --upgrade
ENV TZ=Asia/Shanghai
ENV JAVA_OPTS=-Xmx128m 
WORKDIR /tmp
