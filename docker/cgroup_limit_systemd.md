#### docker resource limit totally

> try limit memory without restart docker, `no persistent`.

```shell
# docker with  `Cgroup Driver: cgroupfs`
# https://docs.docker.com/engine/reference/commandline/dockerd/
# set docker memory limits
echo 2048M > /sys/fs/cgroup/memory/docker/memory.limit_in_bytes
# docker pull polinux/stress
docker run -ti --rm --name stress polinux/stress stress --cpu 1 --vm 1 --vm-bytes 3024M  --verbose
```

> config systemctl editor: `update-alternatives --config editor`
> for `Cgroup Driver = systemd`, solution 1

```conf
# systemctl edit --full docker_limit.slice
# cat /etc/systemd/system/docker_limit.slice
[Unit]
Description=Slice that limits docker resources
Before=slices.target

[Slice]
CPUAccounting=true
CPUQuota=90%
MemoryAccounting=true
MemoryHigh=1G
MemoryMax=1.2G
```

And I made literally the same things as you, except native cgroupdriver in daemon:

```json
// cat /etc/docker/daemon.json 
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "cgroup-parent": "docker_limit.slice"
}
```

> demo.2 ` Cgroup Driver: systemd` , solution 2, only memory limit

``` conf
# systemctl edit --full limit-docker-memory.slice
# /etc/systemd/system/limit-docker-memory.slice
[Unit]
Description=Slice with MemoryLimit=8G for docker
Before=slices.target

[Slice]
MemoryAccounting=true
MemoryLimit=8G
```

```json
// /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "cgroup-parent": "limit-docker-memory.slice"
}
```
