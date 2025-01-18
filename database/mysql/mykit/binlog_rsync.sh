set -e
# cleanup mysql binlog, at 55mins very 2hours
# flock -n /tmp/cron_vacuum_mybinlog.lock -c "bash /xxx.sh 2>&1 | tee -a /tmp/xxx.log"
# 55 */2 * * *	bash /opt/vdc1/_vacuum_bin_log.sh 2>&1 | tee -a /tmp/cron_vacuum_mysql_binlog.log

# backup binlog to NAS
function backup_binlog() {
    binlog_dir=/opt/vdc1/binlog4mysql
    dest_nas_dir=/mnt/wal_bin_log/mysql01-prd-binlog/
    # copy files that were modified more than 60 minutes ago to the destination
    # find $binlog_dir -maxdepth 1 -name '*' -type f -mmin +60 -exec rsync -aP {} $dest_nas_dir \;
    find_ops="$binlog_dir -maxdepth 1 -name '*' -type f -mmin +60 -exec basename {}"
    rsync -av --files-from=<(find $find_ops \;) $binlog_dir $dest_nas_dir
}
backup_binlog;

# check diskusage & cleanup older binlog files
function cleanup_older_binlog(){
disk_of_binlog=/dev/vdc1

echo "---- $(date) ----"
percent_usage=$(df -hP  $disk_of_binlog | awk '{print $5}' |tail -1|sed 's/%$//g')
percent_max=70
echo $percent_usage
echo $percent_max

if [ $percent_usage -gt $percent_max ];
then
echo "usage is greater than $percent_max";
cmd="mysql -bse 'show binary logs'"
container_id=$(docker ps -f "label=com.docker.swarm.service.name=zyb-mysql-master_zyb-mysql-m1" -q)
vacuum_log_to=$(docker exec -i $container_id bash -c "$cmd" | tail -n50 | head -n1 | awk '{print $1}')
sql1="PURGE BINARY LOGS TO '$vacuum_log_to'"
echo $sql1
docker exec -i $container_id bash -e <<EOF
mysql -bse "$sql1"
EOF

else
echo "usage is lesser than $percent_max";
fi;
}
cleanup_older_binlog;
