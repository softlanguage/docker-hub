#### readme for mysqlrouter

```txt
https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community-8.2.0-1.el8.x86_64.rpm
https://dev.mysql.com/get/mysql80-community-release-el8-9.noarch.rpm"
```

```shell
# mysqlrouter read/write split
# https://dev.mysql.com/doc/mysql-router/8.2/en/mysql-router-deploying-bootstrapping.html
mysqlrouter --bootstrap root@localhost:3306 --directory /tmp/myrouter --conf-use-sockets --user=root
mysqlrouter --config /tmp/myrouter/mysqlrouter.conf

mysqlsh # \sql SELECT @@hostname, @@port
```

```shell
# 1. pre-checking
# https://dev.mysql.com/doc/mysql-shell/8.2/en/check-instance-configuration.html
dba.checkInstanceConfiguration('icadmin@ic-1:3306')
dba.configureInstance('icadmin@ic-1:3306')

# https://dev.mysql.com/doc/mysql-shell/8.2/en/create-cluster.html
dba.createCluster()
dba.createReplicaSet() 
Cluster.addInstance()
Cluster.removeInstance()
Cluster.rejoinInstance()
# 3. create cluster
# --- Creating a session to 'root@p1mysql' first.--
\connect p1mysql
nanmu = dba.createCluster('zyb')
nanmu.addInstance('s2mysql')
nanmu.addInstance('s3mysql')
nanmu.status();
nanmu.rescan(); 

# 4. reset replica
STOP GROUP_REPLICATION
RESET REPLICA all
show replica status
```

