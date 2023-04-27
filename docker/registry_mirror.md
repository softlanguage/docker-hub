# container registry mirrors

```conf
# /etc/containers/registries.conf.d/100-registry-mirror.conf
[[registry]]
prefix = "*.io"
location = "rx1g5413.mirror.aliyuncs.com"
#https://cr.console.aliyun.com/cn-shanghai/instances/mirrors

[[registry]]
prefix = "docker.io"
location = "docker.mirrors.ustc.edu.cn"
insecure = false
[[registry]]
prefix = "registry.k8s.io"
location = "registry.aliyuncs.com/google_containers"
[[registry]]
prefix = "quay.io"
location = "quay.mirrors.ustc.edu.cn"
[[registry]]
prefix = "gcr.io"
location = "gcr.mirrors.ustc.edu.cn"
```