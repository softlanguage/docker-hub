## Docker driver client configuration

> https://grafana.com/docs/loki/latest/send-data/docker-driver/configuration/
> https://docs.docker.com/config/containers/logging/configure/

# for docker swarm, as a plugin

```shell
docker plugin install grafana/loki-docker-driver:2.9.4 --alias loki --grant-all-permissions

# https://sematext.com/guides/docker-logs/
# --log-opt mode=non-blocking --log-opt max-buffer-size=4m

docker service update --log-driver loki \
    --log-opt 'loki-url=http://debug.dev:3100/loki/api/v1/push' \
    --log-opt 'loki-external-labels=org=zyb,cluster=uat,container_name={{.Name}}' \
    --log-opt max-size=32m --log-opt max-file=2 --log-opt loki-retries=2 --log-opt loki-timeout=5s \
    test_zyb-whoami 

log_driver='--log-driver loki --log-opt loki-url=http://debug.dev:3100/loki/api/v1/push --log-opt loki-external-labels=org=zyb,cluster=uat,container_name={{.Name}} --log-opt max-size=20m --log-opt max-file=2 --log-opt loki-retries=2 --log-opt loki-timeout=5s'

# docker service update -d $log_driver
docker service ls --filter name=zyb-api- --format '{{.Name}}' | while read i; do docker service update $log_driver $i; done
# docker inspect -f '{{.Spec.TaskTemplate.LogDriver.Name}}' SERVICE
docker service ls --filter name=zyb-api- --format '{{.Name}}' | while read i; do docker inspect -f '{{.Spec.TaskTemplate.LogDriver.Name}}' $i; done
# docker inspect -f '{{.HostConfig.LogConfig.Type}}' CONTAINER
docker ps -f status=running -f name=zyb-api-  --format '{{.Names}}' | while read i; do echo $i && docker inspect -f '{{.HostConfig.LogConfig.Type}}' $i; done
```

# log-opts in the daemon.json

```json
{
    "debug" : true,
    "log-driver": "loki",
    "log-opts": {
        "loki-url": "http://10.16.1.252:3100/loki/api/v1/push",
        "max-size":"32m", "max-file":"2", "loki-retries":"2", "loki-timeout":"5s",
        "loki-external-labels": "cluster=docker_swarm,job=docker,container_name={{.Name}}",
        "mode": "non-blocking", "max-buffer-size": "4m"
    }
}
```

> --log-driver="journald"

```shell
img_loki='grafana/loki:2.9.3'
#img_promtail='grafana/promtail:2.9.3'
img_grafana='grafana/grafana:10.1.6'
# docker run --log-driver=journald --log-opt labels=location --log-opt env=TEST 
docker run -d --name loki --cpus 2 -m 2048m --log-driver="journald" \
    --network app -p 3100:3100 -e TZ=Asia/Shanghai \
    -v ./conf.d/loki-config.yaml:/etc/loki/local-config.yaml \
    -v ./data/:/data  $img_loki

docker run -d --name grafana --cpus 2 -m 1024m \
    -v ./grafana:/var/lib/grafana -e TZ=Asia/Shanghai  \
    --log-driver=loki --log-opt max-size=20m --log-opt max-file=2 \
    --log-opt loki-url=http://10.16.1.252:3100/loki/api/v1/push \
    --log-opt mode=blocking --log-opt loki-retries=2 --log-opt loki-timeout=5s \
    --network app -p 3000:3000 $img_grafana
```


```yaml
    logging:
      driver: loki
      options:
        loki-url: http://host.docker.internal:3100/loki/api/v1/push
        loki-external-labels: cluster=prod
        max-size: 20m
        max-file: 2
        loki-retries: 2
        loki-timeout: 5s
```

- upgade plugin log-driver

```shell
# https://grafana.com/docs/loki/latest/send-data/docker-driver/
docker plugin disable loki --force
docker plugin upgrade loki grafana/loki-docker-driver:2.8.8 --grant-all-permissions
docker plugin enable loki
systemctl restart docker
```