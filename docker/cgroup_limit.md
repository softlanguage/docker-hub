#### docker resource limit totally
> memory test

```shell
# docker pull polinux/stress
docker run -ti --rm --name stress polinux/stress stress --cpu 1 --vm 1 --vm-bytes 3024M  --verbose
```

> for `Cgroup Driver = systemd`, solution 1

I have a VM with 1 CPU and 2GB RAM (swap disabled).
Therefore I created the slice with next parameters:

```conf
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

> for ` Cgroup Driver: systemd` , solution 2, only memory limit

``` conf
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
