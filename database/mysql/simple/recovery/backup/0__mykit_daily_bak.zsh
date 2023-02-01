#!/bin/bash
set -e
TZ=UTC-8

bak_now=$(date +%Y%m%d-%H%M%S)
tar_gig="/gig/tmp/bak_${bak_now}.zstd.tar"
dir_clone="/gig/clone/"

rm -rf /app/* 

echo "----- backup  $(date) ----" >> /tmp/debug.log
ssh mysql-prd "bash /opt/mysql/_conf.d/clone4gig.zsh" | xbstream -x -C /app
echo "1. finish backup: $(date)" >> /tmp/debug.log

xtrabackup --prepare --target-dir=/app
echo "2. finish apply-log: $(date)" >> /tmp/debug.log

tar -I zstd -cf $tar_gig /app
echo "3. finish tar by zstd: $(date)" >> /tmp/debug.log

rm /app/* -rf 
echo "4. finish rm /app/*: $(date)" >> /tmp/debug.log

mv $tar_gig $dir_clone
echo "5. finish move to ${dir_clone}: $(date)" >> /tmp/debug.log

find $dir_clone -name '*.tar' -type f -mtime +100 -print -exec rm -rf {} \; \
	|| echo ">>${bak_now}, failed for prune old .tar files" >> /tmp/debug.log
echo "6. finish prune old files: $(date)" >> /tmp/debug.log

tail -n 15 /tmp/debug.log
