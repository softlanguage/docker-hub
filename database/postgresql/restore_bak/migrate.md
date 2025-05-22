#### migrate GP / PG to New-PG

- Create new instance with zhCN locate
```sh
# localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
export LC_COLLATE=zh_CN.utf8
export LC_CTYPE=zh_CN.utf8
/usr/lib/postgresql/16/bin/initdb -D ./pgdata --wal-segsize=64
/usr/lib/postgresql/16/bin/postgres -D ./pgdata

# compare settings
diff postgresql.conf ../data/postgresql.conf 

# To list all available configuration parameters from your postgresql.conf using grep
grep -E '^[a-zA-Z_\.]+[[:space:]]*=' postgresql.conf
# list all settings
psql -U postgres -c "SHOW ALL"

# postgres clusters
pg_lsclusters
# pg_dropcluster 16 main
```

- migrate 
```sh
# migrate roles
pg_dumpall -r > roles.dump
# GRANT pg_read_all_data TO etl;
# GRANT pg_write_all_data TO etl;
# migrate db
createdb -p5333 new_db
pg_dump -O -x -d my_db -h 127.0.0.1 -p5677 -U postgres | psql -p5333 -d new_db
```

- backup
```sh
# pg_basebackup with --wal-method=fetch ( -Xf )
sh -c 'pg_basebackup -v -c fast -Xf -U postgres -Ft -D- | zstd -c' > ./bak1.tar.zst

# pg_basebackup with --wal-method=none ( -Xn )
sh -c 'pg_basebackup -v -c fast -Xn -U postgres -Ft -D- | zstd -c' > ./bak1.tar.zst
# fix: PANIC:  could not locate a valid checkpoint record 
/usr/lib/postgresql/16/bin/pg_resetwal -f .
/usr/lib/postgresql/16/bin/postgres -p5032 -D .
```