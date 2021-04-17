FROM ubuntu:bionic

RUN apt-get update -y && \
    apt-get -y install openssh-server passwd && \
    apt-get clean

RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key

RUN dpkg-reconfigure openssh-server

RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN echo 'root:softlan9' | chpasswd

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
