FROM alpine:latest

MAINTAINER softlang.net

ENV P_USER=yong

EXPOSE 80 22

COPY ./shell/alpine-apk-init.sh /
RUN sh /alpine-apk-init.sh
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'GatewayPorts yes' >> /etc/ssh/ssh_config
RUN sysctl -w net.ipv4.ip_forward=1

ENTRYPOINT ["/usr/sbin/sshd", "-D"]

