#!/bin/bash 
set -e;
# psql --set ON_ERROR_STOP=on -d wbbi
export DOCKER_CONTEXT=zyb-uat-db1
pycmd=docker
pod_pgdb=pg-m1-uat

#if ! command -v docker > /dev/null
if [ 'I-zyb-prd-pg-mon1' = $(hostname) ]; then
  pycmd=podman
  pod_pgdb=v13citus113
  DOCKER_CONTEXT=I-zyb-prd-pg-mon1
fi

# prints "xxxx"
function prints(){
  local log=$@
  printf "$(date "+%Y-%m-%d %H:%M:%S") --> $log\n"
}

prints $DOCKER_CONTEXT '/' $pycmd '/' $pod_pgdb 
#exit 0

function pyarn(){
  $pycmd $@
}

prints "stop UAT postgresql"
# podman run img sh -c 'exec $(command -v /zyb_start.zsh || echo "tail -f /dev/null")'
pyarn exec -i -u root $pod_pgdb bash <<'EOF'
rm -f /zyb_start.zsh
EOF

pyarn restart -t 15 $pod_pgdb

prints "Recovering ...." && sleep 3

pyarn exec -i -u postgres $pod_pgdb bash <<'EOF'
set -e

# restore
rm -rf /var/lib/postgresql/data/*
pg_basebackup -v -c fast -X stream -U replica_only -h 10.8.8.204 -p 5432 -D $HOME/data # & disown %-

# timeout 5 sh -c 'while ! pgrep pg_basebackup; do sleep 2; done;'

# ALTER SYSTEM SET archive_mode = off;
# postgres -p12345, PGPORT=12345, trun archive_mode=off
postgres -h 127.0.0.1 --archive_mode=off & disown %-
pg_wait=0
while ! pg_isready -d postgres -p 5432 && [ $pg_wait -lt 15 ]; do
  sleep 2;
  pg_wait=$((count + 1))
done

psql --set ON_ERROR_STOP=on -d wbbi <<'PSQL'
--set statement_timeout=3600000;
--ALTER USER MAPPING FOR public SERVER foreign_server_mysqlprd OPTIONS (SET password 'xxx');
ALTER SERVER foreign_server_mysqlprd OPTIONS (SET host '10.8.8.234');
ALTER USER MAPPING FOR dba SERVER foreign_server_mysqlprd OPTIONS (SET password 'xxx');
ALTER USER MAPPING FOR zyb SERVER foreign_server_mysqlprd OPTIONS (SET password 'xxx');
ALTER USER MAPPING FOR postgres SERVER foreign_server_mysqlprd OPTIONS (SET password 'xxx');
-- users
-- ALTER ROLE reader RENAME TO readonly;
ALTER ROLE readonly WITH PASSWORD 'xxx' LOGIN;
ALTER ROLE postgres WITH PASSWORD 'xxx';
ALTER ROLE dba WITH PASSWORD 'xxx';
ALTER ROLE zyb WITH PASSWORD 'xxx';
-- ALTER ROLE dev RENAME TO zyb;
-- ALTER SYSTEM SET archive_mode = off;
PSQL
EOF

# finish, restart...
prints "finish, begin to restart..."
pyarn exec -i -u root $pod_pgdb bash <<'EOF'
echo "exec postgres" > /zyb_start.zsh
chmod +x /zyb_start.zsh
EOF

pyarn restart -t 15 $pod_pgdb && sleep 3

prints "success"