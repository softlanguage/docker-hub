# su -cpwd - postgres
set -e
echo "start -- $(date +%F\ %T)"
su postgres -c 'pg_basebackup -v -c fast -Xs -P -U replica_only -h pg-m1.local -p 5333 -R -D /mpp/pgdb/data'
echo "finish -- $(date +%F\ %T)"
cp -fa /mpp/pgdb/conf.d/postgresql.conf /mpp/pgdb/data/postgresql.conf
cp -fa /mpp/pgdb/conf.d/postgresql.auto.conf /mpp/pgdb/data/postgresql.auto.conf
# start postgresql
systemctl restart postgresql.service
echo "journalctl -f -xeu postgresql.service"

# for docker container
cat <<EOF
pg_image=postgres:16
docker run -i --name gig-pg -v ./data:/pgdata $pg_image sh -ec '
pg_basebackup -v -c fast -Xs -P -U replica_only -h pg-m1.local -p 5333 -R -D /pgdata
'

# use prepared config files
cp -fa /mpp/pgdb/conf.d/postgresql.conf /mpp/pgdb/data/postgresql.conf
cp -fa /mpp/pgdb/conf.d/postgresql.auto.conf /mpp/pgdb/data/postgresql.auto.conf

# start pg container
docker compose -p v16postgresql -f compose.yaml up -d
EOF
