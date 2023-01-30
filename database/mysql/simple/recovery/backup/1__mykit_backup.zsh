#!/bin/bash
# run at mykit__container
# bash /backup/1__mykit_backup.zsh
set -e
TZ=UTC-8

rm -rf /app/* 

echo "----- backup  $(date) ----" >> /tmp/debug.log
ssh mysql-prd "bash /opt/pods/mysql/_conf.d/bak2uat.zsh" | xbstream -x -C /app
echo "1. finish backup: $(date)" >> /tmp/debug.log

xtrabackup --prepare --target-dir=/app
echo "2. finish apply-log: $(date)" >> /tmp/debug.log

tail -n 3 /tmp/debug.log
