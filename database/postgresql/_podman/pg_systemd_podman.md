#### podman systemd services

```shell
# generate systemd service file
podman generate systemd --name container-or-pod-name 
#  --conmon-pidfile /run/podman/pg-data-node01.pid \
systemctl edit --full -f container-or-pod-name
# podman-restart.service
systemctl status podman-restart.service
```

- podman run postgres daatabase node 01

```shell
#!/bin/bash
# bash run.zsh
# systemctl status pg-data-node.service
# chown 999:999 -R ./data
set -e
# --no-healthcheck
podman run -d --name pg-data-node -h pg-data-node-01 \
	--cpus 3 -m 6400M \
	--conmon-pidfile /run/podman/pg-data-node01.pid \
	--volume ./data:/var/lib/postgresql/data \
	--tmpfs /dev/shm \
	--network host \
	--volume ./data:/var/lib/postgresql/data \
	--env-file ./env.conf \
	docker.io/softlang/postgres-cn:14citus11.2
podman ps
```
- env.conf

```conf
POSTGRES_USER=postgres
POSTGRES_PASSWORD="123"
TZ="Asia/Shanghai"
```

#### pg-data-node.service for node 01

```conf
# /etc/systemd/system/pg-data-node.service
# systemctl edit --full -f pg-data-node.service
# podman generate systemd --name container-or-pod-name 
[Unit]
Description=Podman container-pg-data-node.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=/run/containers/storage

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70
ExecStart=/usr/bin/podman start pg-data-node
ExecStop=/usr/bin/podman stop -t 60 pg-data-node
ExecStopPost=/usr/bin/podman stop -t 60 pg-data-node
PIDFile=/run/podman/pg-data-node01.pid
Type=forking

[Install]
```

- podman run postgres database node 02

```shell
#!/bin/bash
# bash run.zsh
# podman-restart.service
# systemctl status pg-data-node.service
# chown 999:999 -R ./data
set -e
# --no-healthcheck
podman run -d --name pg-data-node -h pg-data-node-02 \
	--cpus 3 -m 6400M --restart always \
	--conmon-pidfile /run/podman/pg-data-node01.pid \
	--volume ./data:/var/lib/postgresql/data \
	--tmpfs /dev/shm \
	--network host \
	--volume ./data:/var/lib/postgresql/data \
	--env-file ./env.conf \
	docker.io/softlang/postgres-cn:14citus11.2

podman ps
# systemctl status pg-data-node.servic 
# /etc/systemd/system/pg-data-node.service
```