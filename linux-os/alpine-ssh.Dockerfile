FROM alpine:latest

MAINTAINER softlang.net

ENV P_USER=yong

EXPOSE 80 22

COPY ./shell/alpine-ssh-entrypoint.sh /
RUN sh /entrypoint.sh

ENTRYPOINT ["/usr/sbin/sshd", "-D"]

