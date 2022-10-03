#### pgbouncer - quick start
> https://www.pgbouncer.org/usage.html#quick-start


1. Create a pgbouncer.ini file. Details in pgbouncer(5). Simple example:

```conf
[databases]
template1 = host=localhost port=5432 dbname=template1
[pgbouncer]
listen_port = 6432
listen_addr = localhost
auth_type = md5
auth_file = userlist.txt
logfile = pgbouncer.log
pidfile = pgbouncer.pid
admin_users = someuser
```

2. Create a userlist.txt file that contains the users allowed in:
```txt
 "someuser" "same_password_as_in_server"
```

3. Launch pgbouncer:
```shell
pgbouncer -d pgbouncer.ini
```

4. Have your application (or the psql client) connect to pgbouncer instead of directly to the PostgreSQL server:
```shell
psql -p 6432 -U someuser template1
```

5. Manage pgbouncer by connecting to the special administration database `pgbouncer` and issuing `SHOW HELP;` to begin:

```shell
psql -p 6432 -U someuser pgbouncer
pgbouncer=# SHOW HELP;
NOTICE:  Console usage
DETAIL:
  SHOW [HELP|CONFIG|DATABASES|FDS|POOLS|CLIENTS|SERVERS|SOCKETS|LISTS|VERSION|...]
  SET key = arg
  RELOAD
  PAUSE
  SUSPEND
  RESUME
  SHUTDOWN
  [...]
```

6. If you made changes to the pgbouncer.ini file, you can reload it with:
```shell
pgbouncer=# RELOAD;
```