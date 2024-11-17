#### Run this image as a job container

- demo

```shell
# 1. create volume for python env folder
docker volume create job_demo1
# 2. run container 
docker run -itd --name py -v job_demo1:/app softlang/python:3.7-cx122oracle

# download code from api by project-id
wget -O code http://ci2.zyb.wb:11155/api/v4/projects/1/repository/archive.tar?sha=dev
tar -xf  code --strip-components=1 -C ./my_work_dir


wget -O code http://ci2.zyb.wb:11155/api/v4/projects/zyb%2Fdemo-deploy/repository/archive.tar?sha=dev

```

```shell
podman-cli system connection add etl11-prd ssh://dev@etl11.prd.zyb.wb --identity ~/.ssh/id_rsa.pub

podman-cli system connection ls
podman-cli context ls

# run on podman server
podman system service  unix:///run/user/1000/podman/podman.sock --time 0
```
