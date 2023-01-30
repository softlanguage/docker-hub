
- tar zstd compress & decompress & list only

```shell
# compress
date && tar -I zstd -cf bak_20230129-192500.zstd.tar -C /work/path ./data  && date

# decompress to /mysql/data , strip 1-path in tar
date && tar -I zstd -xf bak_20230129-192500.zstd.tar -C /mysql/data/ --strip-components 1  && date

# list files
date && tar -I zstd -tf bak_20230129-192500.zstd.tar && date
```

- remote server shell content for xtrabackup and output to the console

```shell
#!/bin/bash
# bash /opt/mysql/_conf.d/clone4gig.zsh
# run at mysql-prd (docker-container for mysql)
set -e
#TZ=UTC-8
#cmd='pwd && ls'
#cmd='xtrabackup --backup --no-timestamp --parallel=4 --stream=xbstream /tmp/xtrabackup'
cmd='innobackupex --no-timestamp --parallel=4 --stream=xbstream /tmp/xtrabackup'
container_id=$(docker ps -f "label=com.docker.swarm.service.name=zyb-mysql-master_zyb-mysql-m1" -q)
docker exec -i $container_id bash -c "$cmd"

```