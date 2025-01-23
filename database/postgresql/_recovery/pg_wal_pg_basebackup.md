- how to increase wal_segments_size
```sh
# To check the size we can execute
psql -c 'show wal_segment_size'
# Parameter is set only at the cluster creation 
initdb --wal-segsize=X # or later with pg_resetwal --wal-segsize=X, pg_resetwal --help
pg_resetwal --wal-segsize=64 # set=64MB, this command should be run only if cluster is properly shut-down and should never be run on running server or crashed server.
psql -c 'ALTER SYSTEM SET wal_compression = on; SELECT pg_reload_conf();'
```

- config in postgresql.auto.conf
```conf
wal_compression = on
full_page_writes = on
# archive
archive_mode = 'on'
archive_command = 'test ! -f /backup/archive_wal/%f && cp %p /backup/archive_wal/%f'
#psql -c "ALTER SYSTEM SET restore_command = 'gunzip -c /path/to/archive/%f.gz > %p';"
#Use %% to embed an actual % character in the command.
#printf "d%04d" $((0x00000002000000420000001D % 100))
```

- pg_basebackup
```sh
# 25 23 * * * sh -ec 'cmd', base backup
docker exec -it -upostgres pg-m1.dev bash /backup/zstd_bak/pg_clone.sh 2>&1 | tee -a /tmp/pg_basebackup_cron.log
```

- recovery to a target_time
```sh
# extra to $PWD, cd ~/data
zstd -d -c /zstd_bak/pgbak_20250117-152141.tar.zst | tar xf -

# tell this cluster to start on recovery mode.
# touch recovery.signal
# append follow settings to postgresql.auto.conf
cat <<'EOF' >> postgresql.auto.conf
restore_command = 'cp /zstd_bak/archive_wal/pg_wal/%f %p'
recovery_target_time = '2025-01-17 07:23:00 UTC' #  in UTC TimeZone
#recovery_target_time = '2025-01-17 15:27:00+8' # in UTC+8 TimeZone
#restore_command = 'gunzip -c /path/to/archive/%f.gz > %p'
#restore_command = 'zstd -d /path/to/archive/%f.zst -o %p'
EOF

# docker restart pg14 # will print logs as follows
database system is ready to accept read-only connections
2025-01-17 16:07:34.093 CST [15] 日志:  恢复停止在事物 53186982 提交之前, 时间 2025-01-17 15:25:02.574454+08
2025-01-17 16:07:34.093 CST [15] 日志:  pausing at the end of recovery
2025-01-17 16:07:34.093 CST [15] 提示:  Execute pg_wal_replay_resume() to promote.

# psql <<< pg_wal_replay_resume()
```

- pg_clone.sh 

```sh
#!/bin/bash
set -e
# 25 12 * * * bash /mnt/nas1/pgdb-clone/sh_backup.sh >> /tmp/pg_basebackup_cron.log 2>&1
# extract: zstd -d -c ../base.tar.zst | tar xf - 
printf '\n\n---------------------\n'
workdir=$(realpath $(dirname $0))
pushd $workdir

bk_time=$(date +%Y%m%d-%H%M%S)
bk_zstd=pgbak_${bk_time}.tar.zst

echo "--> ${bk_time}, clean old backup files ---"
find . -maxdepth 2 -name '*.tar.zst' -type f -mtime +5 -print -exec rm -rf {} \;  && wait
echo "--> $(date '+%Y-%m-%d %H:%M:%S') starts pg_basebackup to $PWD/${bk_zstd}"

export PGPORT=5432
sh -c 'pg_basebackup -v -c fast -Xf -U postgres -Ft -D- | zstd -c' > $bk_zstd

echo "--> $(date '+%Y-%m-%d %H:%M:%S') finish pg_basebackup to $PWD/${bk_zstd}"
echo "--> zstd -d -c $PWD/${bk_zstd} | tar xf - #PWD‼️"
```

- cleanup arvhived WAL files by vacuum_wal.sh

```sh
# */20 * * * * flock -n /var/lock/cron_pg_vacuum_wal.lock -c 'sh -e /data/archived_wal/vacuum_wal.sh 2>&1 | tee -a /tmp/pg_archived_wal_prune.log'
set -e
# goto WAL DIR as work_dir
echo ""
cd /data/archived_wal/wal_pg
echo ">> archived start $(date) , WAL size: $(du -sh ./)"

#NAS_WAL=/mnt/prd-nas/bak4zyb/pgdb-prd-archived_wal
NAS_WAL=/mnt/wal_bin_log/prd-pg03-archived_wal
# printf "d%04d" $((0x00000002000000420000001D % 100))
# find -printf '%t{}' -exec xxx %t {} # make datetime as folder
# compress and store info NAS, before 120mins from NOW
find . -maxdepth 2 -name '*' -type f -mmin +30 -print -exec zstd -f -q --rm {} -o $NAS_WAL/{}.zst \; | wc -l #> /dev/null

# cleanup old zst files
echo ">> cleanup WALs in $NAS_WAL/*.zst"
find $NAS_WAL/ -maxdepth 2 -name '*.zst' -type f -mtime +3 -print -exec rm -rf {} \; | wc -l && wait

echo ">> archived finish $(date) , WAL size: $(du -sh ./)"
```
