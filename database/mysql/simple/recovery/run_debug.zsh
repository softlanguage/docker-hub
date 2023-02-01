#!/bin/bash
# recovery from mysql-m1-prd, or restore from backup_filename
set -e
TZ=UAT-8

backup_filename=$backup_filename
cmd_kit_program1="1__mykit_backup.zsh"

function inspect_command()
{
    if [ -z "$backup_filename" ]; then
        echo "no backup_files, recovery from mysql-slaver"
        cmd_kit_program1="1__mykit_backup.zsh"
    fi

    if [ -n "$backup_filename" ]; then
        echo "recovery from $backup_filename"
        cmd_kit_program1="1__mykit_restore.zsh"
    fi
    echo ">>action=$cmd_kit_program1"
}
inspect_command
#exit 0;

ctname_mysql="mysql8-uat"
ctname_mykit="v57-mykit"

# only connected by local: bind to 127.0.0.1 (for init sql)
cmd_local_only="sed -i 's/#bind-address/bind-address/g' /etc/mysql/conf.d/mysqld.cnf"
docker exec -i $ctname_mykit bash -c "$cmd_local_only"
err_code=$?; if [ ! $err_code = 0 ]; then echo $err_code; fi

# stop maysql first
docker stop -t 60 $ctname_mysql

# start recovery (from backup or slave)
docker exec -i -e backup_filename="$backup_filename" $ctname_mykit bash /backup/${cmd_kit_program1}
err_code=$?; if [ ! $err_code = 0 ]; then echo $err_code; fi
echo "1 >> $(date) finish recovery."
# start mysql
docker start $ctname_mysql

echo "waiting mysql start success...."
docker exec -i $ctname_mysql /backup/2__mysql_check.zsh
sleep 3 # wait 3 seconds before connection
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
