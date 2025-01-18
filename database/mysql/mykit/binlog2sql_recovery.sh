# yyy_mysql recovery by python3 with https://github.com/danfengcao/binlog2sql
mysqlbinlog -v --base64-output=DECODE-ROWS --start-datetime="2025-01-08 15:29:00" --stop-datetime="2025-01-08 15:30:00" ../mysql-bin.000639 |more

# https://github.com/danfengcao/binlog2sql
python3 ./binlog2sql.py --flashback -udba -p'password' -dinnox -tph_project_budget --start-datetime="2025-01-08 15:29:00" --stop-datetime="2025-01-08 15:30:00" --start-file=mysql-bin.000639 > sql1.sql


# another mysql recovery by binlog
# https://github.com/bugfyi/mysql-binlog_MyUndelete
# https://thecamels.org/en/recovery-of-deleted-data-from-mysql-using-binlogs/
