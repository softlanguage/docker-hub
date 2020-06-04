FROM alpine:latest

MAINTAINER softlang.net

ENV P_USER=yong

EXPOSE 80 22

COPY ./shell/alpine-apk-init.sh /
RUN sh /alpine-apk-init.sh
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

ENTRYPOINT ["/usr/sbin/sshd", "-D"]

