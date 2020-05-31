FROM ubuntu:bionic

MAINTAINER Softlang [softlang.net]

# default pwd
ARG my_pwd=softlan9

RUN apt-get update -y && apt-get -y upgrade;
RUN apt-get -y install openssh-server passwd;
RUN mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key

RUN dpkg-reconfigure openssh-server

# RUN echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config

RUN echo 'root:{my_pwd}' | chpasswd

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
