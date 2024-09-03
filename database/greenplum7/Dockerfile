from docker.io/oraclelinux:8

WORKDIR /mpp
ADD ./mpp/greenplum*.rpm /tmp
RUN dnf install hostname wget lsof telnet &&\
    dnf install -y glibc-locale-source &&\
    localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 &&\
    dnf install -y /tmp/greenplum*.rpm &&\
    python3.11 -m ensurepip &&\
    dnf clean all &&\
    ssh-keygen -A

ENV PGPORT=5677
VOLUME /mpp/dist

RUN mkdir -p /mpp/dist/{master,node1,node2} && \
    groupadd -g 5432 gpadmin && \
    useradd -d /mpp/gpadmin -m -u 5432 -g 5432 -s /bin/bash gpadmin && \
    chown -R gpadmin:gpadmin /mpp && \
    echo 'source /usr/local/greenplum-db/greenplum_path.sh' >> /mpp/gpadmin/.bashrc

CMD /usr/sbin/sshd -D -p 22
