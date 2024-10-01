#!/bin/bash
# crontab -l
# 25 10 * * * bash /mnt/nas1/backup/pgdb-basebackup/sh_backup.sh 2>&1 | tee -a /tmp/pg_basebackup_cron.log
set -e
# pg_basebackup -v -c fast -Xf -U replica_only -Ft -D- | zstd -c > base.tar.zst
# extract: zstd -d -c ../base.tar.zst | tar xf - 
printf '\n\n---------------------\n'
workdir=$(realpath $(dirname $0))
pushd $workdir

bk_time=$(date +%Y%m%d-%H%M%S)
bk_zstd=zyb_prod_pg_${bk_time}.tar.zst

echo "--> ${bk_time}, clean old backup files ---"
find . -maxdepth 2 -name '*.tar.zst' -type f -mtime +101 -print -exec rm -rf {} \;  && wait
# cleanup empty folders
#find ${dir4bak}/ -maxdepth 1 -type d -empty -exec rm -rf {} \; wait;

echo "--> $(date '+%Y-%m-%d %H:%M:%S') starts pg_basebackup to $PWD/${bk_zstd}"

#docker exec -i pgdb13zyb sh -c 'pg_basebackup -v -c fast -Xf -U replica_only -Ft -D- | zstd -c' > $bk_zstd
#podman exec -i pgdb13zyb sh -c 'pg_basebackup -v -c fast -Xf -U replica_only -Ft -D- | zstd -c' > $bk_zstd
export PGPORT=5333
sh -c 'pg_basebackup -v -c fast -Xf -U replica_only -Ft -D- | zstd -c' > $bk_zstd

#pg_basebackup -v -c fast -Xf -U replica_only -Ft -D- | zstd > $bk_zstd
#pg_basebackup -v -c fast -Xf -U replica_only -Ft -D- | zstd -c
echo "--> $(date '+%Y-%m-%d %H:%M:%S') finish pg_basebackup to $PWD/${bk_zstd}"
echo "--> zstd -d -c $PWD/${bk_zstd} | tar xf - #PWD‼️"
