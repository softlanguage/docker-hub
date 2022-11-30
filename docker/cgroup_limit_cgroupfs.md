#### docker with  `Cgroup Driver: cgroupfs`

> 1. config systemctl editor: `update-alternatives --config editor`

```shell
# https://docs.docker.com/engine/reference/commandline/dockerd/
# for `Cgroup Driver: cgroupfs`
systemctl edit --full docker.slice
systemctl daemon-reload
systemctl show docker.slice
```
> 2. the `systemctl edit --full docker.slice` config

```conf
# systemctl edit --full docker.slice
# /etc/systemd/system/docker.slice
# systemctl enable docker.slice && systemctl restart docker.slice
# /etc/docker/daemon.json {"cgroup-parent": "/docker.slice"}
[Unit]
Description=Docker Slice
Before=slices.target

[Slice]
MemoryAccounting=true
MemoryLimit=2048M
CPUAccounting=true
CPUQuota=100%
#TasksMax=4096

# for docker service [not needed]
#[Service]
#ExecStartPost=echo 2G > /sys/fs/cgroup/memory/docker/memory.limit_in_bytes
#Slice=docker.slice
[Install]
WantedBy=multi-user.target
```

> 3. /etc/docker/daemon.json config

```json
// /etc/docker/daemon.json  [Cgroup Driver: cgroupfs]
{
    "exec-opts": ["native.cgroupdriver=cgroupfs"],
    "cgroup-parent": "/docker.slice"
}
```

> 4. try limit memory without restart docker, `no persistent`.

```shell
# docker with  `Cgroup Driver: cgroupfs`
# https://docs.docker.com/engine/reference/commandline/dockerd/
# set docker memory limits
echo 2048M > /sys/fs/cgroup/memory/docker/memory.limit_in_bytes
# docker pull polinux/stress
docker run -ti --rm --name stress polinux/stress stress --cpu 1 --vm 1 --vm-bytes 3024M  --verbose
```

###### the references

> config the cgroup-parent memory limit
> https://docs.docker.com/engine/reference/commandline/dockerd/
> https://www.suse.com/support/kb/doc/?id=000019590
