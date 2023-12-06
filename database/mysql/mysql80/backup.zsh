#!/bin/bash
set -e



rm -rf /backup/data \
    && mysql -e 'CLONE LOCAL DATA DIRECTORY="/backup/data"' \
    && tar -zcf /backup/zip/bak_$(date +%Y%m%d-%H%M%S).tar -C /backup ./data --remove-files

find /backup/zip/ -name '*.tar' -type f -mtime +16 -print -exec rm -rf {} \;
