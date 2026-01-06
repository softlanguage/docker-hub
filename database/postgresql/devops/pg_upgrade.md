## migrate from postgresql v9.6 to v18.1

```sh
# dump all roles
pg_dumpall -r > roles.dump

# -o -X dump all databases without ownership and privileges
# --no-role-passwords 
pg_dumpall -O -x --no-role-passwords > all_database.dump

# -W Force Password Prompt
psql -U postgres -h 127.0.0.1 -p 5432 -W -f all_database.dump

# ---- dump and change locale from en_US.utf8 to zh_CN.utf8 ----
pg_dumpall -r > roles.dump
pg_dump -E UTF-8 -Cc -d dbname |sed "s/ENCODING = 'UTF8' LOCALE = 'en_US.utf8';/ENCODING = 'UTF8' LOCALE = 'zh_CN.utf8';/g" > dbname.dump

# without dump file
pg_dumpall -r | psql -U postgres -h 127.0.0.1 -p 5432
pg_dump -E UTF-8 -Cc -d dbname |sed "s/ENCODING = 'UTF8' LOCALE = 'en_US.utf8';/ENCODING = 'UTF8' LOCALE = 'zh_CN.utf8';/g" | psql -U postgres -h 127.0.0.1 -p 5432
```

