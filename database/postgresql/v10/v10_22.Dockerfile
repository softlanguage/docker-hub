# docker build --network host --force-rm -f Dockerfile -t softlang/postgres-cn:10.22 .
# 支持中文的postgresql-10.22
FROM postgres:10.22-bullseye
RUN localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
RUN apt-get update \
	&& apt-get install -y postgresql-10-mysql-fdw postgresql-10-cron
# https://github.com/citusdata/pg_cron

RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean

ENV LANG zh_CN.utf8
LABEL softlang_pg_features="postgresql-10-mysql-fdw,postgresql-10-cron"
LABEL softlang_reference="https://github.com/citusdata/pg_cron"

# docker run -itd --rm --name pg14 -e POSTGRES_PASSWORD=123654 softlang/postgres-cn:10.22