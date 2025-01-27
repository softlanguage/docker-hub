
- point-in-time recovery
```sh
# take backup to target-dir
xtrabackup --backup --target-dir=/path/to/backup
# prepare a backup for starting mysql server on the backup.
xtrabackup --prepare --target-dir=/path/to/backup
mysql -e 'SHOW BINARY LOGS' -S /var/lib/mysql/mysqld.sock
mysql -e 'SHOW MASTER STATUS;' -S /var/lib/mysql/mysqld.sock

cat /path/to/backup/xtrabackup_binlog_info
# --copy-back, Copy all the files in a previously made backup from the backup directory to their original locations.
xtrabackup --copy-back --target-dir=/path/to/backup

# extracting the queries from the binary log with mysqlbinlog starting from the position of the snapshot and redirecting the results to a file
mysqlbinlog /path/to/datadir/mysql-bin.000003 /path/to/datadir/mysql-bin.000004 \
--start-position=57 > mybinlog.sql
# if the point is 11-12-25 01:00:00, the command moves the the database forward to that point-in-time
mysqlbinlog /path/to/datadir/mysql-bin.000003 /path/to/datadir/mysql-bin.000004 \
--start-position=57 --stop-datetime="11-12-25 01:00:00" | mysql -u root -p
```

- mysql.cnf
```conf
# for mysql -S/var/lib/mysql/mysqld.sock
[client]
socket=/var/lib/mysql/mysqld.sock
# Only for mysql 8.0
# docker_path: /etc/mysql/conf.d/mysqld.cnf)
[mysqld]
socket = /var/lib/mysql/mysqld.sock
```

- run by docker

```sh
# mysql5.7: docker pull percona/percona-xtrabackup:2.4
# mysql8.0: docker pull percona/percona-xtrabackup:8.0
# mysql8.4: docker pull percona/percona-xtrabackup:8.4

# run mysql
docker run -d --name mysql80 -v ./backup:/backup -v ./data:/var/lib/mysql mysql:8.0
# percona/percona-xtrabackup:8.0 default user is mysql
docker run -i --rm -uroot percona/percona-xtrabackup:8.0 xtrabackup --help
# run xtrabackup, and tee log to /tmp/xtrabackup.log
podmysql=mysql8.0
docker run -i --rm -uroot --volumes-from $podmysql percona/percona-xtrabackup:8.0 \
xtrabackup --backup --datadir=/var/lib/mysql/ --target-dir=/backup -S /var/lib/mysql/mysqld.sock 2>&1 | tee /tmp/xtrabackup.log

# or run with 2 steps: 1. create container, 2. run by start -i
docker create -uroot --name xtrabackup --volumes-from mysql8.0 percona/percona-xtrabackup:8.0 xtrabackup --backup --datadir=/var/lib/mysql/ -S /var/lib/mysql/mysqld.sock --target-dir=/backup/zip
# 2. start xtrabackup 
docker start -i xtrabackup 2>&1 | tee /tmp/debug01.log
```

- install xtrabackup

```sh

# mysql 8.0, https://docs.percona.com/percona-xtrabackup/8.0/apt-download-deb.html
wget -c https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.40/binary/tarball/percona-xtrabackup-8.0.35-31-Linux-x86_64.glibc2.34.tar.gz

tar -C ./backup -xf percona-xtrabackup-8.0.35-31-Linux-x86_64.glibc2.34.tar.gz

# mysql 8.4, https://docs.percona.com/percona-xtrabackup/8.4/
wget -c https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.4.3/binary/tarball/percona-xtrabackup-8.4.0-1-Linux-x86_64.glibc2.34.tar.gz

tar -C ./backup -xf percona-xtrabackup-8.4.0-1-Linux-x86_64.glibc2.34.tar.gz
```

```sh
xtrabackup --help
--copy-back, Copy all the files in a previously made backup from the backup directory to their original locations.

--move-back,Move all the files in a previously made backup from the backup directory to the actual datadir location. Use with caution, as it removes backup files.
--slave-info        This option is useful when backing up a replication slave
                      server. It prints the binary log position and name of the
                      master server. It also writes this information to the
                      "xtrabackup_slave_info" file as a "CHANGE MASTER"
                      command. A new slave for this master can be set up by
                      starting a slave server on this backup and issuing a
                      "CHANGE MASTER" command with the binary log position
                      saved in the "xtrabackup_slave_info" file.
```