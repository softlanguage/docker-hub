## restore to gig.NAS /mnt/gig/debug/prd-pg03-recovery/data
```sh
cd /mnt/gig/debug/prd-pg03-recovery/data
zstd -d -c /mnt/prd-nas/bak4zyb/pgdb-prd-clone/zyb_prod_pg_20250117-232501.tar.zst | tar xf -

# tell this cluster to start on recovery mode.
touch recovery.signal`
# append follow settings to postgresql.auto.conf
cat <<'EOF' >> postgresql.auto.conf
restore_command = 'zstd -d /mnt/wal_bin_log/prd-pg03-archived_wal/%f.zst -o %p'
recovery_target_time = '2025-01-18 15:00:00+8' # UTC+8 timezone
EOF

# postgresql-13.service #Environment=PGDATA=/mnt/gig/debug/prd-pg03-recovery/data/
vim /etc/systemd/system/postgresql-13.service
systemctl daemon-reload
systemctl restart postgresql-13.service 

# calculate the remainder
printf "d%04d" $((0x00000002000000420000001D % 100))
#Use %% to embed an actual % character in the command.

# To check the size we can execute `show wal_segment_size` 
# Parameter is set only at the cluster creation 
initdb --wal-segsize=X # or later with pg_resetwal --wal-segsize=X
pg_resetwal --wal-segsize=64 # set=64mb, this command should be run only if cluster is properly shut-down and should never be run on running server or crashed server.
```

- postgresql.auto.conf

```conf
# archive
archive_mode = 'on'
archive_command = 'test ! -f /backup/archive_wal/%f && cp %p /backup/archive_wal/%f'
#Use %% to embed an actual % character in the command.
archive_command = 'f_rem=$(printf "d%%04d" $((0x%f %% 100))) && mkdir -p /archive_wal/$f_rem && cp -fa %p /archive_wal/$f_rem/%f'
#psql -c "ALTER SYSTEM SET restore_command = 'gunzip -c /path/to/archive/%f.gz > %p';"
restore_command = 'zstd -d /mnt/wal_bin_log/prd-pg03-archived_wal/%f.zst -o %p'
recovery_target_time = '2025-01-18 03:00:00+8' # UTC+8 timezone
#recovery_target_time = '2025-01-18 07:00:00 UTC' #  in UTC TimeZone
#restore_command = 'zstd -d /path/to/archive/%f.zst -o %p'
#restore_command = 'gunzip -c /path/to/archive/%f.gz > %p'
#restore_command = 'cp /zstd_bak/archive_wal/pg_wal/%f %p'
#touch recovery.signal
```
