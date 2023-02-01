#!/bin/bash
set -e
TZ=UTC-8
rm -rf /app/*

echo "----- start restore $(date) ----"
tar -I zstd -xf /gig/clone/${backup_filename} -C /app --strip-components 1
echo "1. finish restore from backup-file: $(date)"
