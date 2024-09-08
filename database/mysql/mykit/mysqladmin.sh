
set -e
# restart_mysql_safely.sh
function restart_mysql_safely() {
# shutdown mysql, container will stop and auto restart
docker exec -i mysql57-s3.zyb sh -e <<EOF
mysqladmin shutdown
EOF
}

function essential_tools(){
# tools:
mysqlshow # show database
mysqldumpslow # Parse and summarize the MySQL slow query log.
mysqldump #supports single-threaded processing. 
mysqlpump #supports parallel processing of databases and objects within databases, to speed up the dump process.
}

function mysqladmin(){
mysqladmin --help
<<'///'
create databasename Create a new database
debug   Instruct server to write debug information to log
drop databasename Delete a database and all its tables
extended-status       Gives an extended status message from the server
flush-hosts           Flush all cached hosts
flush-logs            Flush all logs
flush-status  Clear status variables
flush-tables          Flush all tables
flush-threads         Flush the thread cache
flush-privileges      Reload grant tables (same as reload)
kill id,id,... Kill mysql threads
password [new-password] Change old password to new-password in current format
ping   Check if mysqld is alive
processlist  Show list of active threads in server
reload  Reload grant tables
refresh  Flush all tables and close and open logfiles
shutdown  Take server down
status  Gives a short status message from the server
start-slave  Start slave
stop-slave  Stop slave
variables             Prints variables available
version  Get version info from server
///
}
