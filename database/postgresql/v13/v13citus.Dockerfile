# docker build --network host --force-rm -f Dockerfile -t softlang/postgres-cn:13citus11.2 . 
# docker run -itd --rm --name pgdb -e POSTGRES_PASSWORD=123654 softlang/postgres-cn:13citus11.2
# https://github.com/citusdata/docker
#FROM postgres:13.10
FROM citusdata/citus:11.2-pg13

# install extensions
ARG apt_mirror="mirrors.cloud.tencent.com"
RUN sed -i -E "s/(deb|security).debian.org/${apt_mirror}/g" /etc/apt/sources.list \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 \
    && apt-get update \
	&& apt-get install -y iputils-ping wget htop nano procps net-tools \
    postgresql-13-mysql-fdw postgresql-13-cron postgresql-13-repack \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG zh_CN.utf8
LABEL softlang_tag="pg-v13, postgresql-13-mysql-fdw postgresql-13-cron postgresql-13-repack citus-11.2"

# citus
#RUN curl -s https://install.citusdata.com/community/deb.sh | bash && apt-get -y install postgresql-13-citus-11.2

# add citus to default PostgreSQL config
#RUN echo "shared_preload_libraries='citus'" >> /usr/share/postgresql/postgresql.conf.sample

#HEALTHCHECK --interval=10s --retries=3 --start-period=6s CMD /pg_healthcheck
# entry point unsets PGPASSWORD, but we need it to connect to workers
# https://github.com/docker-library/postgres/blob/33bccfcaddd0679f55ee1028c012d26cd196537d/12/docker-entrypoint.sh#L303
# 需要修改 pg_hba.conf trust connect to workers
# RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh

# HEALTHCHECK --interval=4s --start-period=6s CMD pg_isready --timeout=5 --quiet || exit 1
# docker inspect --format "{{json .State.Health }}" <container name>
