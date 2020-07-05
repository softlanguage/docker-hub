# build image
FROM golang:1.12-alpine3.9 AS build-env

# install build tools
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

# get resources
RUN go get -u github.com/cnlh/nps...

EXPOSE 8080
EXPOSE 8024

# start
CMD ["nps", "start"]




FROM alpine:3.8
MAINTAINER hanxi <hanxi.info@gmail.com>

ENV NPS_VERSION 0.23.3

RUN set -x && \
	wget --no-check-certificate https://github.com/hanxi/nps/releases/download/v${NPS_VERSION}/linux_amd64_server.tar.gz && \ 
    mkdir /nps && \
	tar xzf linux_amd64_server.tar.gz -C /nps && \
	cd /nps && \
	cd .. && \
	rm -rf *.tar.gz

WORKDIR /nps
VOLUME /nps/conf

ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
