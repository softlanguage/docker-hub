#!/bin/bash
set -e
# restore steps
# 1. create new database `demo`
# 2. create schema `crm`
# 3. pg_restore -O -x from dump
# 4. pg_restore -v -d uat_sell -n wbsell -t crm_hospital dbw01_bak_20230302-223502.dump
# 4. pg_restore -v -d uat_sell -n wbsell dbw01_bak_20230302-223502.dump

printf "\n--- $(date) ---\n"
# load greenplum env
. /usr/local/greenplum-db/greenplum_path.sh

# begin backup
bk_time=$(date +%Y%m%d-%H%M%S)
bk_root=/mpp/backup

function do_backup() {
    local db=$1
    bk_dir=${bk_root}/${db}
    bk_dump=${bk_dir}/bak_${bk_time}_${db}.dump
    mkdir -p $bk_dir
    echo ">>backup ${db} to ${bk_dump}"
    echo ">>clean old bakup files"
    # remove old backup (keep 3 backup files)
    rm -f `ls -t ${bk_dir}/bak*.dump  | tail -n +15` || echo 'no enouth bak files'

    export PGHOST=127.0.0.1
    export PGPORT=5677
    export PGUSER=gpadmin
    export PGDATABASE=$db
    pg_dump -O -Fc -d ${db} > ${bk_dump} || (rm ${bk_dump} -rf && echo "error, backup failed." && exit 1)

    echo ">>done: " $(date "+%Y-%m-%d %H:%M:%S")
    psql -d ${db} <<< 'set statement_timeout=7200000; vacuum(analyse);'
    echo ">>finish vacuum(analyse): " $(date "+%Y-%m-%d %H:%M:%S")
}

db_list=(
'postgres'
'gpadmin'
'dw01'
)

for i in "${db_list[@]}"
do
    do_backup $i
done

echo "backup success"

