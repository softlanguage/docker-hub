#!/bin/bash
set -e
# err_code=$?; if [ ! $err_code = 0 ]; then echo $err_code; fi
# set the target docker
# docker context create ci-uat-db1 --docker "host=ssh://dev@mysql-prd" --description "xxx" 
export DOCKER_CONTEXT="ci-uat-db1" 

ctname_mysql="mysql8-uat"
ctname_mykit="v57-mykit"

# only connected by local: bind to 127.0.0.1 (for init sql)
cmd_local_only="sed -i 's/#bind-address/bind-address/g' /etc/mysql/conf.d/mysqld.cnf"
docker exec -i $ctname_mysql bash -c "$cmd_local_only"
err_code=$?; if [ ! $err_code = 0 ]; then echo $err_code; fi

# stop maysql first
docker stop -t 60 $ctname_mysql

# start backup
docker exec -i $ctname_mykit bash /backup/1__mykit_backup.zsh
err_code=$?; if [ ! $err_code = 0 ]; then echo $err_code; fi
echo "1 >> $(date) finish backup."
# start mysql
docker start $ctname_mysql
echo "waiting 60s mysql start success...."
sleep 60 # wait 60 seconds
echo "2 >> $(date) upgrade to mysql8 success."

# init sql: reset salve, init some config-table's data
docker exec -i $ctname_mysql bash /backup/2__mysql_init.zsh
err_code=$?; if [ ! $err_code = 0 ]; then echo $err_code; fi
echo "3 >> $(date) execute the init scripts for UAT success."

# allow remote connect,  bind to 0.0.0.0
cmd_open_connect="sed -i 's/bind-address/#bind-address/g' /etc/mysql/conf.d/mysqld.cnf"
docker exec -i $ctname_mysql bash -c "$cmd_open_connect"
err_code=$?; if [ ! $err_code = 0 ]; then echo $err_code; fi

# restart mysql, to enable bing *
docker restart $ctname_mysql
sleep 10 # wait 60 seconds
echo "4 >> $(date) mysql8-uat opening, you can connect now."
