# mysql 8 clone plugin

> https://dev.mysql.com/doc/refman/8.0/en/clone-plugin-remote.html

```conf
# mysqld.cnf, config @ master & slaver
[mysqld]
#plugin-load-add=mysql_clone.so
#clone=FORCE_PLUS_PERMANENT
```

```sql
-- install plugin by sql
INSTALL PLUGIN clone SONAME 'mysql_clone.so';

SELECT PLUGIN_NAME, PLUGIN_STATUS
       FROM INFORMATION_SCHEMA.PLUGINS
       WHERE PLUGIN_NAME = 'clone';

-- clone 
CLONE INSTANCE FROM 'user'@'host':port
IDENTIFIED BY 'password'
[DATA DIRECTORY [=] 'clone_dir']
[REQUIRE [NO] SSL];

-- local backup mode
CLONE LOCAL DATA DIRECTORY='/backup/mysql/d20230123';
```

- backup for test.bur.ink 

```shell
# crontab -e 
11 1 * * * docker exec -i mysql-m1.dev /backup/_backup.zsh >> /var/log/cron-stdout.log 2>&1
# docker exec -i `docker ps -f 'label=com.docker.swarm.service.name=mysql-dev' -q` /backup/_backup.zsh

#  ---- the /backup/_backup.zsh file ----
#!/bin/bash
set -e
rm -rf /backup/data \
    && mysql -e 'CLONE LOCAL DATA DIRECTORY="/backup/data"' \
    && tar -zcvf /backup/zip/bak_$(date +%Y%m%d-%H%M%S).tar -C /backup ./data --remove-files

find /backup/zip/ -name '*.tar' -type f -mtime +16 -print -exec rm -rf {} \;
```

- clone remote to local_dir or default data_dir
> https://dev.mysql.com/doc/refman/8.0/en/clone.html

```sql
-- mysql 8 clone remote data ---
INSTALL PLUGIN clone SONAME 'mysql_clone.so';
SET GLOBAL clone_valid_donor_list = 'mysql-m1.dev:3306';
-- local backup mode
CLONE LOCAL DATA DIRECTORY='/backup/mysql/d20230123';
-- if you do not want to remove existing data in the recipient data directory, specify the `DATA DIRECTORY`
CLONE INSTANCE FROM 'root'@'mysql-m1.dev':3306 IDENTIFIED BY 'xxx' DATA DIRECTORY = '/backup/data2';

-- When the optional DATA DIRECTORY [=] 'clone_dir' clause is not used, a cloning operation removes existing data in the recipient data directory, replaces it with the cloned data, and automatically restarts the server afterward.
CLONE INSTANCE FROM 'root'@'mysql-m1.dev':3306 IDENTIFIED BY 'xxx';

-- clone for replication
CHANGE MASTER TO 
	MASTER_HOST='mysql-m1.dev', 
	MASTER_PORT=3306, 
	MASTER_USER='root',
	MASTER_PASSWORD='xxx',
	-- MASTER_LOG_FILE='mzyb-dev-m1-bin-log',
	master_auto_position=1
	FOR CHANNEL 'default';
-- set the filter  
CHANGE REPLICATION 
	FILTER REPLICATE_DO_DB = ('teanant','wbbi')
	FOR CHANNEL "zyb_dev_m1_tenant";
-- start replication
START REPLICA;
SHOW REPLICA STATUS FOR CHANNEL 'default'
```