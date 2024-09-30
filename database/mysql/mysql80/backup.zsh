#!/bin/bash
# 25 10 * * * sh -c 'docker exec -i v8mysql.dev sh /backup/backup.sh'  2>&1 | tee -a /tmp/v8mysql_backup.log
set -e
printf "\n\n--- start $(date) ---\n"
rm -rf /backup/data
bak_zstd_file=/backup/zip/bak_$(date +%Y%m%d-%H%M%S).tar.zstd
mysql -e 'CLONE LOCAL DATA DIRECTORY="/backup/data"'
tar -I zstd -cf $bak_zstd_file -C /backup ./data --remove-files
find /backup/zip/ -name '*.tar.zstd' -type f -mtime +16 -print -exec rm -rf {} \;
printf ">> finish $(date)\n>> RestoreBy: tar -I zstd -xf $bak_zstd_file \n\n"
