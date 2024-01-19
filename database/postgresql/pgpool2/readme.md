- _run_pgpool.zsh

```sh
docker logs nginx 2>&1 | grep "127."
docker logs --details -n 2000 ii-pgpool2 2>&1 |grep 'Error'|wc -l
#this can happen if the container is logging to stderr, piping works only for stdout, so try:
# "2>&1" will tell the shell to redirect stderr to stdout
#"|" to give the "unified" output to grep using pipe
```

```shell
set -e
workdir=$(realpath $(dirname $0))
echo "workdir = $workdir"
pgpool -f $workdir/pgpool.conf -n -D & disown %- #-d
exit 0
# for root
chown -R postgres:postgres $workdir 
runuser -u postgres --  pgpool -f $workdir/pgpool.conf -n -D #-d
```

- test for read write split

```shell
CREATE ROLE sr_check_user WITH NOINHERIT LOGIN PASSWORD 'password';
# query the server ip
PGPASSWORD=xxx psql -h 10.8.8.220 -p 8986 -U pgadmin -d demo -c 'select inet_server_addr();'
PGPASSWORD=xxx psql -h 10.8.8.220 -p 8986 -U pgadmin -d demo -c 'select inet_server_addr() for update;'
```

- pool_passwd
> https://www.pgpool.net/docs/42/en/html/auth-methods.html

```conf
#username:plain_text_passwd
#username:AES_encrypted_passwd
readonly:Read123
pgadmin:xxx
```

- download pgpool
> https://www.pgpool.net/mediawiki/index.php/Downloads
> https://www.pgpool.net/yum/rpms/

```shell
wget -c https://www.pgpool.net/yum/rpms/4.4/redhat/rhel-8-x86_64/pgpool-II-pg13-4.4.5-1pgdg.rhel8.x86_64.rpm
```

