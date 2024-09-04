#from docker.io/oraclelinux:8
from q3.x-b.ltd:85/library/oraclelinux:8
WORKDIR /mpp
ADD ./mpp/greenplum*.rpm /tmp

RUN dnf update && dnf install -y hostname wget lsof telnet glibc-locale-source &&\
    localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 &&\
    dnf install -y /tmp/greenplum*.rpm &&\
    python3.11 -m ensurepip &&\
    dnf clean all && rm -rf /tmp/greenplum*.rpm &&\
    ssh-keygen -A

ENV PGPORT=5677
ENV PGDATABASE=postgres
VOLUME /mpp/dist

RUN mkdir -p /mpp/dist &&\
    groupadd -g 5432 gpadmin &&\
    useradd -d /mpp/gpadmin -m -u 5432 -g 5432 -s /bin/bash gpadmin &&\
    chown -R gpadmin:gpadmin /mpp &&\
    echo 'source /usr/local/greenplum-db/greenplum_path.sh' >> /mpp/gpadmin/.bashrc


USER gpadmin
RUN ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N "" &&\
    cp -a ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys &&\
    chmod 0600 ~/.ssh/authorized_keys &&\
    printf 'Host *\nStrictHostKeyChecking no\nUserKnownHostsFile=/dev/null' > ~/.ssh/config

USER root
CMD /usr/sbin/sshd -D -p22
