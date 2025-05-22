#!/bin/bash
# 51 */2 * * * bash /mnt/nasX/job.sh 2>&1 | tee -a /tmp/cron_pg_vacuum_bloats.log
set -e
workdir=$(realpath $(dirname $0))

. $workdir/.venv/bin/activate

python $workdir/bloat_doctor.py
