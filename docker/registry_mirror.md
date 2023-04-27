# container registry mirrors

```conf
# /etc/containers/registries.conf.d/100-registry-mirror.conf
[[registry]]
prefix = "docker.io"
location = "docker.mirrors.ustc.edu.cn"
insecure = true
[[registry]]
location = "registry.k8s.io"
location = "registry.aliyuncs.com/google_containers"
insecure = false
[[registry]]
location = "quay.io"
location = "quay.mirrors.ustc.edu.cn"
insecure = false
[[registry]]
location = "gcr.io"
location = "gcr.mirrors.ustc.edu.cn"
insecure = false
```