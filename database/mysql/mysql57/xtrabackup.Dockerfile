# docker build --network host --force-rm -f mysql.Dockerfile -t softlang/mysql:v5.7.41 .
# mysql:5.7.36
FROM mysql:5.7.41-debian

# https://www.percona.com/downloads/Percona-XtraBackup-2.4/LATEST/
# https://www.percona.com/downloads/Percona-XtraBackup-8.0/LATEST/

# https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.26/binary/debian/focal/x86_64/percona-xtrabackup-24_2.4.26-1.focal_amd64.deb
ARG deb_url=https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.26/binary/debian/buster/x86_64/percona-xtrabackup-24_2.4.26-1.buster_amd64.deb
ADD $deb_url /tmp/percona-xtrabackup-24_2.4.26-1.buster_amd64.deb
RUN rm -rf /etc/apt/sources.list.d/mysql.list && apt update && apt install -y openssh-client nano \
     /tmp/percona-xtrabackup-24_2.4.26-1.buster_amd64.deb && rm -rf /var/lib/apt/lists/*
