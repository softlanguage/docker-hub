set -e
# cleanup mysql binlog, at 55mins very 2hours [55 */2 * * *]
# flock -n /tmp/mybinlog_archive_cron.lock -c "bash /opt/vdc1/archive_binlog.sh 2>&1 | tee -a /tmp/mybinlog_archive_cron.log"

printf "\n\n>> $(date) # start archive...\n"

# backup binlog to NAS
backup_binlog() {
binlog_dir=/opt/vdc1/binlog4mysql
dest_nas_dir=/mnt/wal_bin_log/mysql01-prd-binlog/
# copy files that were modified more than 60 minutes ago to the destination
# find $binlog_dir -maxdepth 1 -name '*' -type f -mmin +60 -exec rsync -aP {} $dest_nas_dir \;
rsync -av --files-from=<(find $binlog_dir -maxdepth 1 -name '*' \
    -type f -mmin +60 -exec basename {} \;) $binlog_dir $dest_nas_dir

# cleanup old binlog files on NAS
find $dest_nas_dir/ -maxdepth 1 -name '*' -type f -mtime +5 -print -exec rm -rf {} \;
}
backup_binlog;

printf "\n>> $(date) # archive binlogs info NAS: /mnt/wal_bin_log/mysql01-prd-binlog/ \n"

# check diskusage & cleanup older binlog files
cleanup_older_binlog(){
disk_of_binlog=/dev/vdc1

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
printf "\n>> $(date) # archive vacuum older binlogs \n"
