# 支持中文的postgresql13.2
FROM postgres:13.2
RUN localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8

RUN apt-get update \
	&& apt-get install -y postgresql-13-mysql-fdw

RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean

ENV LANG zh_CN.utf8
