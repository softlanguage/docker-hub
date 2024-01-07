#!/bin/bash 
set -e;
# psql --set ON_ERROR_STOP=on -d wbbi
#export DOCKER_CONTEXT=zyb-uat-db1
pod_pgdb=v13citus113

# prints "xxxx"
function prints(){
  local log=$@
  printf "$(date "+%Y-%m-%d %H:%M:%S") --> $log\n"
}

function pyarn(){
  podman $@
}

prints "stop UAT postgresql"
# podman run img sh -c 'exec $(command -v /zyb_start.zsh || echo "bash --norc")'
pyarn exec -i -u root $pod_pgdb bash <<'EOF'
rm -f /zyb_start.zsh
EOF

pyarn restart -t 15 $pod_pgdb

prints "Recovering ...." && sleep 5

pyarn exec -i -u postgres $pod_pgdb bash <<'EOF'
set -e

# restore
rm -rf /var/lib/postgresql/data/*
pg_basebackup -v -c fast -X stream -U replica_only -h 10.8.8.204 -p 5432 -D $HOME/data # & disown %-

# postgres -p12345, PGPORT=12345
postgres -h 127.0.0.1 & disown %-
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
ALTER ROLE readonly WITH PASSWORD 'xx' LOGIN;
ALTER ROLE postgres WITH PASSWORD 'xx';
ALTER ROLE dba WITH PASSWORD 'xxx';
-- ALTER ROLE dev RENAME TO zyb;
PSQL
EOF

# finish, restart...
prints "finish, begin to restart..."
pyarn exec -i -u root $pod_pgdb bash <<'EOF'
echo "exec postgres" > /zyb_start.zsh
chmod +x /zyb_start.zsh
EOF

pyarn restart -t 15 $pod_pgdb && sleep 5

prints "success"
