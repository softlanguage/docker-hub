#!/bin/bash
set -e
# https://github.com/prosenjitjoy/Grafana-Loki-and-Promtail-with-docker?tab=readme-ov-file

workdir=$(realpath $(dirname $0))
echo "workdir = $workdir"
pushd $workdir
echo PWD=$PWD

mkdir -p ./{data,grafana}
chown -R 10001:10001 data/
chown -R 472:472 grafana/

img_loki='grafana/loki:2.9.3'
#img_promtail='grafana/promtail:2.9.3'
img_grafana='grafana/grafana:10.1.6'
#img_loki='grafana/loki:2.8.8'
#img_promtail='grafana/promtail:2.8.8'

docker rm -f loki

docker run -d --name loki --cpus 2 -m 2048m --log-driver="journald"\
    --network app -p 3100:3100 -e TZ=Asia/Shanghai \
    -v ./conf.d/loki-config.yaml:/etc/loki/local-config.yaml \
    -v ./data/:/data  $img_loki

docker rm -f grafana
# admin:123654, --log-opt mode=blocking
docker run -d --name grafana --cpus 2 -m 1024m \
    -v ./grafana:/var/lib/grafana -e TZ=Asia/Shanghai  \
    --log-driver=loki --log-opt max-size=20m --log-opt max-file=2 \
    --log-opt loki-url=http://10.16.1.252:3100/loki/api/v1/push \
    --log-opt mode=blocking --log-opt loki-retries=2 --log-opt loki-timeout=5s \
    --network app -p 3000:3000 $img_grafana