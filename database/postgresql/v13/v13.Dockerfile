# docker build --network host --force-rm -f Dockerfile -t softlang/postgres-cn:13.10 . 
# 支持中文的postgresql13
FROM postgres:13.10

# install extensions
ARG apt_mirror="mirrors.cloud.tencent.com"
RUN sed -i -E "s/(deb|security).debian.org/${apt_mirror}/g" /etc/apt/sources.list \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 \
    && apt-get update \
	&& apt-get install -y  iputils-ping wget htop nano \
    postgresql-13-mysql-fdw postgresql-13-cron postgresql-13-repack \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG zh_CN.utf8
LABEL softlang_tag="pg-v13, postgresql-13-mysql-fdw postgresql-13-cron postgresql-13-repack"
# docker run -itd --rm --name pgdb -e POSTGRES_PASSWORD=123654 softlang/postgres-cn:13.10
