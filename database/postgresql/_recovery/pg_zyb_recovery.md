## restore to gig.NAS /mpp/pgdata
```sh
cd /mpp/pgdata
zstd -d -c /mnt/pgdb-clone/pg_20250117-232501.tar.zst | tar xf -

# tell this cluster to start on recovery mode.
touch recovery.signal`
# append follow settings to postgresql.auto.conf
cat <<'EOF' >> postgresql.auto.conf
restore_command = 'zstd -c -d /mnt/wal_bin_log/prd-pg03-archived_wal/%f.zst > %p'
recovery_target_time = '2025-01-18 15:00:00+8' # UTC+8 timezone
EOF

# postgresql-13.service #Environment=PGDATA=/mnt/gig/debug/prd-pg03-recovery/data/
vim /etc/systemd/system/postgresql-13.service
systemctl daemon-reload
systemctl restart postgresql-13.service 

# S3 as NAS, mount with AK in /mnt/pass_s3zyb-backup
s3fs mybucket /mpp/s3_zyb-backup -o passwd_file=/mnt/pass_s3zyb-backup -ourl=http://url.to.oss
# mount `mybucket` to `/mnt/mountpoint` in fstab (test in ZYB with `/etc/passwd-s3fs`)
mybucket /mnt/mountpoint fuse.s3fs _netdev,allow_other,url=https://url.to.s3/ 0 0

# To check the size we can execute `show wal_segment_size` 
# Parameter is set only at the cluster creation 
initdb --wal-segsize=X # or later with pg_resetwal --wal-segsize=X
pg_resetwal --wal-segsize=64 # set=64mb, this command should be run only if cluster is properly shut-down and should never be run on running server or crashed server.
```

- postgresql.auto.conf

```conf
# archive
archive_mode = 'on'
archive_command = 'cp -fa %p /backup/archive_wal/%f'
#psql -c "ALTER SYSTEM SET restore_command = 'gunzip -c /path/to/archive/%f.gz > %p';"
#Use %% to embed an actual % character in the command.
archive_command = 'zstd -c %p > /archivedWAL/%f.zst'
restore_command = 'zstd -c -d /archivedWAL/%f.zst > %p'
recovery_target_time = '2025-01-18 03:00:00+8' # UTC+8 timezone
# PostgreSQL will perform recovery until the end of the available WAL logs,
#   and auto Execute pg_wal_replay_resume() to promote.
#recovery_target_time = '2025-01-18 07:00:00 UTC' #  in UTC TimeZone
#restore_command = 'zstd -d /path/to/archive/%f.zst -o %p'
#restore_command = 'gunzip -c /path/to/archive/%f.gz > %p'
#restore_command = 'cp /zstd_bak/archive_wal/pg_wal/%f %p'
#touch recovery.signal
```
