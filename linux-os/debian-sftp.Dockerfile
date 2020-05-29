# https://github.com/softlang-net
FROM debian:stretch
MAINTAINER Softlang [softlang.net]

RUN apt-get update

RUN apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*


EXPOSE 22

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
