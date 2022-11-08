#!/bin/bash
# run at mysql-uat___container
# bash /backup/2__mysql_init.zsh

set -e
# mysql -D sys -e "sql....;sql;"
# reset slave all
mysql -D sys -e "stop slave; RESET SLAVE;"

mysql -D sys < /backup/3__mysql_init.sql

#sql_lock_user="ALTER USER 'dev'@'%' ACCOUNT LOCK;"
#sql_unlock_user="ALTER USER 'dev'@'%' ACCOUNT UNLOCK;"