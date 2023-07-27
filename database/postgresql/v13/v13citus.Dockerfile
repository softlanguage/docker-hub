# docker build --network host --force-rm -f Dockerfile -t softlang/postgres-cn:13citus11.3 . 
# docker run -itd --rm --name pg13 -e POSTGRES_PASSWORD=123654 softlang/postgres-cn:13citus11.3
# postgresql-13.8, support chinese
FROM postgres:13.11-bullseye

# for psql & pg_healthcheck.sh
ENV PGPORT=5432
HEALTHCHECK --interval=10s --retries=3 --start-period=15s CMD /pg_healthcheck
COPY <<EOF /pg_healthcheck
host="/var/run/postgresql"
user="\${POSTGRES_USER:-postgres}"
db="\${POSTGRES_DB:-\$user}"
port="\${PGPORT:-5432}"
pg_isready -h \${host} -p \${port} -d \${db} -U \${user} --timeout=5 --quiet || exit 1
EOF

ARG apt_mirror="mirrors.cloud.tencent.com"
RUN sed -i -E "s/(deb|security).debian.org/${apt_mirror}/g" /etc/apt/sources.list \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -s https://install.citusdata.com/community/deb.sh | bash \
	&& apt-get install -y --no-install-recommends iputils-ping wget htop nano procps net-tools \
    postgresql-13-mysql-fdw postgresql-13-repack postgresql-13-citus-11.3 postgresql-13-cron \
    && apt-get purge -y --auto-remove curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && chmod +x /pg_healthcheck

ENV LANG zh_CN.utf8
LABEL softlang_tag="pg-v13.11, postgresql-13-mysql-fdw postgresql-13-repack citus-11.3 postgresql-13-cron"
USER postgres