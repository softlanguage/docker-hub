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

- mysql_fdw

```sql
CREATE SERVER foreign_server
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (host '192.83.123.89', port '5432', dbname 'foreign_db');
ALTER SERVER foreign_server_mysqlprd OPTIONS (SET fetch_size '1000');
ALTER SERVER foreign_server_mysqlprd OPTIONS (SET reconnect 'true');

/*https://github.com/EnterpriseDB/mysql_fdw
** MySQL Foreign Data Wrapper for PostgreSQL
host=xxx as string, optional, default 127.0.0.1
port=xxx as integer, optional, default 3306

init_command=xxx as string, optional, no default, SQL statement to execute when connecting to the MySQL server.

reconnect=xx as boolean, optional, default false, Enable or disable automatic reconnection to the MySQL server if the existing connection is found to have been lost.

fetch_size=1000 as integer, optional, default 100, This option specifies the number of rows mysql_fdw should get in each fetch operation. It can be specified for a foreign table or a foreign server. The option specified on a table overrides an option specified for the server.
*/
```