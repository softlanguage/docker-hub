#### demo, PostgreSQL WAL Archiving and Point-In-Time-Recovery

- Let’s combine all of the above in a practical demonstration and see how this all works.

```shell
# Start server
./pg_ctl -D $PGDATA start
 
# take a base backup
./pg_basebackup -D $BACKUP -Fp
 
# connect and put some data
./psql postgres
postgres=# create table foo(c1 int, c2 timestamp default current_timestamp);
CREATE TABLE
postgres=#  insert into foo select generate_series(1, 1000000), clock_timestamp();
INSERT 0 1000000
postgres=# select current_timestamp;
       current_timestamp       
-------------------------------
 2020-10-01 18:01:18.157764+05
(1 row)
postgres=# delete from foo;
DELETE 1000000
postgres=# select current_timestamp;
       current_timestamp       
-------------------------------
 2020-10-01 18:01:36.272033+05
(1 row)
```

- Let’s stop the server and create a recovery setup on the backup to stop before the deletion of data occurred.

```shell
./pg_ctl -D $PGDATA stop
 
# tell this cluster to start on recovery mode.
touch $BACKUP/recovery.signal
 

# edit configuration file to setup recovery options on the backup cluster.
vim  $BACKUP/postgresql.conf
# Recovery Options
restore_command = ‘cp  $HOME/wal_archive/%f %p’
recovery_target_time = ‘2020-10-01 18:01:18.157764+05’
recovery_target_inclusive = false

# let’s start the backup cluster and start the recovery process.
./pg_ctl -D $BACKUP start
 2020-10-01 18:03:17.365 PKT [71219] LOG:  listening on IPv4 address "127.0.0.1", port 5432
2020-10-01 18:03:17.366 PKT [71219] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5432"
2020-10-01 18:03:17.371 PKT [71220] LOG:  database system was interrupted; last known up at 2020-10-01 18:00:45 PKT
2020-10-01 18:03:17.413 PKT [71220] LOG:  starting point-in-time recovery to 2020-10-01 18:01:18.157764+05
2020-10-01 18:03:17.441 PKT [71220] LOG:  restored log file "000000010000000000000002" from archive
2020-10-01 18:03:17.463 PKT [71220] LOG:  redo starts at 0/2000028
2020-10-01 18:03:17.463 PKT [71220] LOG:  consistent recovery state reached at 0/2000100
2020-10-01 18:03:17.463 PKT [71219] LOG:  database system is ready to accept read only connections
2020-10-01 18:03:17.501 PKT [71220] LOG:  restored log file "000000010000000000000003" from archive
2020-10-01 18:03:18.182 PKT [71220] LOG:  restored log file "000000010000000000000004" from archive
2020-10-01 18:03:18.851 PKT [71220] LOG:  restored log file "000000010000000000000005" from archive
2020-10-01 18:03:19.539 PKT [71220] LOG:  restored log file "000000010000000000000006" from archive
2020-10-01 18:03:20.195 PKT [71220] LOG:  restored log file "000000010000000000000007" from archive
2020-10-01 18:03:20.901 PKT [71220] LOG:  restored log file "000000010000000000000008" from archive
2020-10-01 18:03:21.574 PKT [71220] LOG:  restored log file "000000010000000000000009" from archive
2020-10-01 18:03:22.286 PKT [71220] LOG:  restored log file "00000001000000000000000A" from archive
2020-10-01 18:03:22.697 PKT [71220] LOG:  recovery stopping before commit of transaction 508, time 2020-10-01 18:01:32.304189+05
2020-10-01 18:03:22.697 PKT [71220] LOG:  pausing at the end of recovery
2020-10-01 18:03:22.697 PKT [71220] HINT:  Execute pg_wal_replay_resume() to promote.
```