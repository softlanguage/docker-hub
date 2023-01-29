#### backup mysql & tar compress with zstd

- docker image mysql:8.0.29-debian already contains `tar + zstd`
> ex. `date && tar -I zstd -cf ./test11.tar ./registry.d && date`

```shell
# pull mysql8
docker pull mysql:8.0.29-debian
docker run -itd --name mysql8 -m 512M -e MYSQL_ROOT_PASSWORD=xxx mysql:8.0.29-debian

# attach to mysql8 shell
docker exec -it mysql8 bash

# tar compress with zstd `cd /opt`
tar -I zstd -cf ./log.zstd.tar -C /var ./log

# tar decompress with zstd
tar -I zstd -xf ./log.zstd.tar

```