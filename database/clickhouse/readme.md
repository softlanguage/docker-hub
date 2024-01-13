#### clickhouse

```shell zyb-dev notice: create temp ck, podman cp ck1:/etc/clickhouse-xxx ./ck1/xxx
#!/bin/bash
set -e
podman run -d --init --name ck1 --pod zyb --cpus=2 -m=2048M  \
    - ./data:/var/lib/clickhouse \
    - ./server-cfg/config.d:/etc/clickhouse-server/config.d \
    - ./server-cfg/users.d:/etc/clickhouse-server/users.d \
    clickhouse/clickhouse-server:21.8 bash -c '
if ! command -v psql > /dev/null; then
echo "Installing postgresql-client.."
apt update -qq && apt install -y postgresql-client -qq
fi                              
psql -V
exec /usr/bin/clickhouse su "clickhouse:clickhouse" /usr/bin/clickhouse-server --config-file=$CLICKHOUSE_CONFIG'

```


```sql
-- https://clickhouse.com/docs/en/operations/backup
-- https://clickhouse.com/docs/en/operations/backup

BACKUP database default TO S3('https://oss-cn-hangzhou-internal.aliyuncs.com/clickhouse')
BACKUP database prd_zyb_xlog TO S3('https://oss-cn-hangzhou-internal.aliyuncs.com/clickhouse/bak20240101')
-- s3 could config auto delete policy
RESTORE database prd_zyb_xlog AS new_prd_zyb_xlog FROM S3('https://oss-cn-hangzhou-internal.aliyuncs.com/clickhouse/bak20240101')
RESTORE database prd_zyb_xlog AS new_prd_zyb_xlog FROM S3('https://oss-cn-hangzhou-internal.aliyuncs.com/clickhouse/bak20240101')


-- import tables from postgres
CREATE DATABASE pg_xlog
ENGINE = PostgreSQL('10.8.8.8:5432', 'postgres', 'reader', 'xxx', 'log',1);

-- create new table in clickhouse
-- 1. wblog
CREATE TABLE demo.wblog AS gp_xlog.wblog ENGINE = MergeTree ORDER BY id;
-- 2. app_logs
CREATE TABLE demo.app_logs AS pg_xlog.app_logs  ENGINE = MergeTree 
PARTITION BY today ORDER BY (today, id);
-- 3. config TTL for the table, keep 1year
ALTER TABLE demo.app_logs MODIFY TTL toDate(toString(today)) + toIntervalDay(366)

SHOW CREATE TABLE system.query_log;
describe table system.query_log

-- migrate month by month by month
INSERT INTO demo.app_logs SELECT * FROM pg_xlog.app_logs
where today between 20230801 and 20230831;

-- 
ALTER TABLE system.query_log MODIFY TTL event_date + toIntervalDay(45);
alter table system.metric_log modify ttl event_date + toIntervalDay(15);
OPTIMIZE TABLE system.asynchronous_metric_log FINAL
OPTIMIZE TABLE system.metric_log FINAL


-- Fully delete data from Clickhouse DB to save disk space
DROP TABLE mydb.mytable no delay
DROP DATABASE mydb no delay

-- show setttings for your clickchouse instance
SELECT * FROM system.settings WHERE name LIKE '%log%'
show tables in system where name like '%log%'
describe table system.query_log

-- mysql engine
CREATE DATABASE dw01_demo ENGINE = MySQL('10.8.8.208:23306', 'demo', 'readonly', 'xxx') SETTINGS read_write_timeout=10000, connect_timeout=1000;

CREATE DATABASE gp_xlog
ENGINE = PostgreSQL('10.8.8.8:5677', 'zlog', 'mpp', '111', 'log',1);

-- TTL
ALTER TABLE system.query_log MODIFY TTL event_date + toIntervalDay(45);
alter table system.metric_log modify ttl event_date + toIntervalDay(15);
-- cleanup right now.
OPTIMIZE TABLE system.asynchronous_metric_log FINAL
OPTIMIZE TABLE system.metric_log FINAL

ALTER TABLE system.asynchronous_metric_log MODIFY TTL event_date + toIntervalDay(90);

select * from system.asynchronous_metric_log 
order by event_date
limit 20;

select * from system.metric_log 
order by event_date
limit 20;

-- show storages orader by size desc
select
database,
	table,
	formatReadableSize(size) as size,
	formatReadableSize(bytes_on_disk) as bytes_on_disk,
	formatReadableSize(data_uncompressed_bytes) as data_uncompressed_bytes,
	formatReadableSize(data_compressed_bytes) as data_compressed_bytes,
    compress_rate,
	rows,
	days,
	formatReadableSize(avgDaySize) as avgDaySize
from
    (
	    select
			database,
			table,
			sum(bytes) as size,
			sum(rows) as rows,
			min(min_date) as min_date,
			max(max_date) as max_date,
			sum(bytes_on_disk) as bytes_on_disk,
			sum(data_uncompressed_bytes) as data_uncompressed_bytes,
			sum(data_compressed_bytes) as data_compressed_bytes,
			(data_compressed_bytes / data_uncompressed_bytes) * 100 as compress_rate,
			max_date - min_date as days,
			size / (max_date - min_date) as avgDaySize
		from system.parts
		where active
		group by
			database,
			table
		order by data_compressed_bytes desc
);
```