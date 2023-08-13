#### pg extensions

- pgcopydb `apt install pgcopydb`
> https://github.com/dimitri/pgcopydb

- pg_squeeze


```shell
# LC for Chinese
# https://github.com/docker-library/postgres/blob/master/16/bookworm/Dockerfile
localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
# https://www.postgresql.org/docs/current/locale.html
ENV LC_COLLATE zh_CN.utf8
ENV LC_CTYPE zh_CN.utf8

# install extension
apt-get update \
	&& apt-get install -y iputils-ping wget htop nano procps net-tools \
    postgresql-15-mysql-fdw postgresql-15-cron postgresql-15-repack pgcopydb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

```
