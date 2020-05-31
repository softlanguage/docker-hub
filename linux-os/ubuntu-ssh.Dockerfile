FROM ubuntu:bionic

MAINTAINER Softlang [softlang.net]

RUN apt-get update -y && apt-get -y upgrade;
RUN apt-get -y install openssh-server passwd;
RUN mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key

RUN dpkg-reconfigure openssh-server

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
