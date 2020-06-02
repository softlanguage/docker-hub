FROM alpine:latest
MAINTAINER softlang.net
ENV P_USER=yong
EXPOSE 80 22
RUN ./
ENTRYPOINT /entrypoint.sh
