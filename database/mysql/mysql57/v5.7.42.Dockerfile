# docker build -t softlang/mysql:v5.7.42-xtrabackup -f v5.7.42.Dockerfile .
FROM mysql:5.7.42-debian

ARG XTRABACKUP_URL=https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.28/binary/debian/buster/x86_64/percona-xtrabackup-24_2.4.28-1.buster_amd64.deb

ADD ${XTRABACKUP_URL} /tmp/percona-xtrabackup.deb

RUN set -eux; \
    sed -i \
      -e 's|http://deb.debian.org|http://mirrors.cloud.aliyuncs.com/debian-archive|g' \
      -e 's|http://security.debian.org|http://mirrors.cloud.aliyuncs.com/debian-archive|g' \
      /etc/apt/sources.list || true; \
    rm -f /etc/apt/sources.list.d/mysql.list; \
    apt-get update -qq; \
    apt-get install -y -qq --no-install-recommends \
        /tmp/percona-xtrabackup.deb \
        gettext \
        nano \
        openssh-client \
        zstd; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    rm -f /tmp/percona-xtrabackup.deb
