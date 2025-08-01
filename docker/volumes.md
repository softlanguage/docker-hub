- create volume by sh
```sh
docker volume create --driver local --opt type=none --opt o=bind --opt device=/opt/pgdata my-volume
```

- create volume by compose
```yaml
volumes:
  pgvecotr_data:
    name: pgvector_data
    driver: local
    driver_opts:
      type: none
      device: /data/moby/volumes/pgvector_data
      o: bind
services:
  pgvector-zyb:
    image: softlang/postgres-cn:16.8-pgvector
    #image: pgvector/pgvector:pg17
    hostname: pgvector17.local
    container_name: pgvector17.local
    environment:
      - "POSTGRES_PASSWORD=xxx"
      - "TZ=Asia/Shanghai"
    volumes:
      - pgvecotr_data:/var/lib/postgresql/data:rw"
    cpus: '2'
    #cpuset: '0'
    mem_limit: 8gb
    memswap_limit: -1
    shm_size: 2gb
```
