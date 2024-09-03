#!/bin/bash
# crontab -l
# 25 23 * * * sh -e ~/pyops/cleanup.sh 2>&1 | tee -a /tmp/gp_cronJob_cleanup.log
set -e
keep_mlog=10
keep_slog=10
mpp_dist=/mpp/dist
# init
. /usr/local/greenplum-db/greenplum_path.sh
printf "\n--- $(date) ---\n"

# master
echo ">>[master] clean pg_log files"
# remove old files (keep 10 files)
ls -lh $mpp_dist/gpsne-*/log/*.csv
rm -f `ls -t $mpp_dist/gpsne-*/log/*.csv | tail -n +${keep_mlog}` || echo 'no log files'

# segs
echo ">>[segments] clean pg_log files"
# remove old files (keep 10 files)
gpssh -f /mpp/gpadmin/conf.d/hostlist <<EOF
rm -f \`ls -t $mpp_dist/gpsne*/log/*.csv  | tail -n +${keep_slog}\` || echo 'no log files'
EOF

#find $pg_log -name '*.csv' -type f -mtime +7 -print -exec rm -rf {} \;
echo '--done--'
