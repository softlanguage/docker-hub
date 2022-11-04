# docker build --network host --force-rm -f mykit.Dockerfile -t softlang/mysql:v57kit .
# ubuntu:focal ,  ubuntu:20.04
FROM ubuntu:focal

# https://www.percona.com/downloads/Percona-XtraBackup-2.4/LATEST/
# https://www.percona.com/downloads/Percona-XtraBackup-8.0/LATEST/

# https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.26/binary/debian/focal/x86_64/percona-xtrabackup-24_2.4.26-1.focal_amd64.deb
ARG deb_url=https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.26/binary/debian/focal/x86_64/percona-xtrabackup-24_2.4.26-1.focal_amd64.deb
WORKDIR /app
ADD $deb_url /app/percona-xtrabackup-24_2.4.26-1.focal_amd64.deb
RUN apt update && apt install -y wget openssh-client netcat nano \
     /app/percona-xtrabackup-24_2.4.26-1.focal_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

CMD [ "nc", "-l", "-p", "8080" ]
