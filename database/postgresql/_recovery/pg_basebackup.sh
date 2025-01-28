#!/bin/bash
set -e
# 25 12 * * * bash /mnt/nas1/pgdb-bak/clone.sh >> /tmp/pg_basebackup_cron.log 2>&1
# extract: zstd -d -c ../base.tar.zst | tar xf - 
printf "\n--> pg_basebackup $PWD/$0\n"
workdir=$(realpath $(dirname $0))
cd $workdir

bk_time=$(date +%Y%m%d-%H%M%S)
bk_zstd=bak_${bk_time}.tar.zst
echo "--> $(date +%F\ %T) start., save at $workdir/${bk_zstd}"
pg_basebackup -cfast -Xf -Upostgres -Ft --no-manifest -D- | zstd -c > $bk_zstd
# pg_basebackup --no-manifest, avoid warning: `tar: A lone zero block at xxx`
echo "--> $(date +%F\ %T) finish, save at $workdir/${bk_zstd}"

# cleanup older files
find . -maxdepth 2 -name '*.tar.zst' -type f -mtime +15 -print -exec rm -rf {} \;
echo "--> $(date +%F\ %T), has cleaned older backups ---"

# how to restore
echo "--> zstd -d -c $PWD/${bk_zstd} | tar -C ./target_dir -xf -"
