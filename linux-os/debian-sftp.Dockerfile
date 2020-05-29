# https://github.com/softlang-net
FROM debian:stretch
MAINTAINER Softlang [softlang.net]

ARG my_usr=sftp
ARG my_pwd=softlan9

RUN apt-get update

RUN apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key

RUN dpkg-reconfigure openssh-server

RUN useradd -ms /bin/bash ${my_usr}
RUN echo "${my_usr}:${my_pwd}" | chpasswd

VOLUME ["/opt/sftp"]

RUN chown ${my_usr} /opt/sftp
RUN chmod 666 /opt/sftp

EXPOSE 22

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
