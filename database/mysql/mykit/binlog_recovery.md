- MySQL :: MySQL 8.0 Reference Manual :: 9.5 Point-in-Time (Incremental) Recovery 

```txt
MySQL :: MySQL 8.0 Reference Manual :: 9.5 Point-in-Time (Incremental) Recovery
https://dev.mysql.com/doc/refman/5.7/en/point-in-time-recovery.html
https://dev.mysql.com/doc/refman/8.0/en/point-in-time-recovery.html
https://dev.mysql.com/doc/refman/8.0/en/point-in-time-recovery-binlog.html
https://dev.mysql.com/doc/refman/8.0/en/point-in-time-recovery-positions.html

Work with binary logs - Percona XtraBackup 
https://docs.percona.com/percona-xtrabackup/8.0/point-in-time-recovery.html
https://docs.percona.com/percona-xtrabackup/8.0/working-with-binary-logs.html
```

- Point-in-time recovery by xtrabackup

```sh
# Recovering up to particular moment in database’s history can be done with xtrabackup and the binary logs of the server.
#Note that the binary log contains the operations that modified the database from a point in the past. You must have full data directory as a base. Apply a series of operations from the binary log to make the data match the point in time data.
$ xtrabackup --backup --target-dir=/path/to/backup
$ xtrabackup --prepare --target-dir=/path/to/backup
#For more details on these procedures, see Create a full backup and Prepare a full backup.
#Now, suppose that some time has passed, and you want to restore the database to a certain point in the past, having in mind that there is the constraint of the point where the snapshot was taken.
#To find out what is the situation of binary logging in the server, execute the following queries:

mysql> SHOW BINARY LOGS;
#This query returns the binary log names and file size.

mysql> SHOW MASTER STATUS;
#The query returns which file is currently being used to record changes, and the current position within it. Typically,the files are stored in the datadir, unless, when starting the server, another location is specified with the --log-bin= option).
#To find out the position of the snapshot taken, see the xtrabackup_binlog_info at the backup’s directory:
$ cat /path/to/backup/xtrabackup_binlog_info
#This result tells you which file was used at the moment of the backup for the binary log and its position. That position will be the effective one when you restore the backup:

$ xtrabackup --copy-back --target-dir=/path/to/backup
#As the restoration will not affect the binary log files (you may need to adjust file permissions, see Restore a backup), the next step is extracting the queries from the binary log with mysqlbinlog starting from the position of the snapshot and redirecting the results to a file.
#If you have multiple files for the binary log, as in the example, you must extract the queries with one process.

$ mysqlbinlog /path/to/datadir/mysql-bin.000003 /path/to/datadir/mysql-bin.000004 --start-position=57 > mybinlog.sql
#Inspect the file with the queries to determine which position or date corresponds to the wanted point-in-time. Once determined, pipe it to the server. For example, if the point is 11-12-25 01:00:00, the command moves the the database forward to that point-in-time.

$ mysqlbinlog /path/to/datadir/mysql-bin.000003 /path/to/datadir/mysql-bin.000004 \
    --start-position=57 --stop-datetime="11-12-25 01:00:00" | mysql -u root -p
```
