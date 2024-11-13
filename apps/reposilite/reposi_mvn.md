#### maven reposilite
> https://reposilite.com/guide/jar
- reposilite cli for config
> https://reposilite.com/
> https://v2.reposilite.com/docs/authorization

```sh
# ---- https://reposilite.com/guide/jar -----
# 1. download
wget -c https://repo.panda-lang.org/releases/org/panda-lang/reposilite/2.9.26/reposilite-2.9.26.jar

# 2. run 
java -Xmx32M -jar reposilite.jar
# https://v2.reposilite.com/docs/authorization
# see the parameters
java -jar reposilite.jar --help

# use the not userd port=8089 
java -Xmx32M -Dreposilite.port=8089 -jar reposilite.jar --working-directory=/app/data
# workdir=/app, use -wd=data, write log to console
java -Xmx32M -Dtinylog.writerFile.file=/dev/stdout -jar reposilite.jar -wd=data 

# cli in reposilite
help keygen # see the keygen parameters
keygen / root m # admin, manager
keygen / devops wr # write and read
keygen / developer r # readonly
keygen / developer r # to renew token for user-dev

stop

# upstream public repository
grep -i ./reposilite.cdn 
<<...reposilite.cdn
proxied [
  https://maven.aliyun.com/repository/public
]
...reposilite.cdn

# to test
mvn dependency:go-offline -s ~/mvn_setttings.xml -f pom.xml
```

#### run by systemd
> https://reposilite.com/guide/systemd

```conf
# systemctl edit --full --force maven-reposilite.service
# touch /etc/systemd/system/maven-reposilite.service
[Unit]
Description=maven-reposilite
Documentation=https://reposilite.com/

[Service]
WorkingDirectory=/opt/pods.n/reposilite
ExecStart=/usr/bin/java -Xmx32M -Dtinylog.writerFile.file=/dev/stdout -Dreposilite.port=5081 -jar reposilite-2.9.26.jar --working-directory=./data
SuccessExitStatus=0
TimeoutStopSec=10
Restart=on-failure
RestartSec=15
User=zyb
MemoryMax=511M
AllowedCPUs=0
# Centos7
# MemoryLimit=511M 
# LimitCPU=1000000

[Install]
WantedBy=multi-user.target

```


#### test for maven

- ~/.m2/settings.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <mirrors>
        <mirror>
            <id>mirror</id>
            <mirrorOf>*</mirrorOf>
            <name>mirror</name>
            <url>http://10.8.8.198:5081</url>
        </mirror>
    </mirrors>
</settings>
```
- Nginx config
```conf
# devops, maven-private-repository
server {
    listen 9081;
    server_name _;
    default_type text/html;
    client_max_body_size 50m;

    location / {
        proxy_pass http://127.0.0.1:5081/;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection $connection_upgrade;
        proxy_http_version 1.1;
    }
}
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
```

- run by docker

```yaml
# docker-compose -p host-mvn -f compose.yaml up -d
# docker-compose -p host-mvn down
version: "3.8"
services:
  maven-reposilite:
    image: softlang/maven:reposilite-2.9.26
    hostname: maven-reposilite.dev
    container_name: maven-reposilite.dev
    environment:
      - TZ=Asia/Shanghai
      - JAVA_OPTS=-Xmx128M -Dreposilite.port=9083
      #- REPOSILITE_OPTS=${REPOSILITE_COMPOSE_OPTS}
    healthcheck:
      test: ["CMD", "wget", "--spider", "127.0.0.1:9083/health"]
      interval: 15s
      retries: 3
    network_mode: host
    volumes:
      - ./data:/app/data
    network_mode: host
    restart: always
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 256M

#PORT=8080
#MEMORY=128M
#JAVA_COMPOSE_OPTS=
#REPOSILITE_COMPOSE_OPTS=
```

```log
20:38:58.961 INFO | Stored tokens: 2
20:38:58.963 INFO | Generated new access token for admin (/) with 'w' permissions
20:38:58.964 INFO | 7KIuOni8J0YPlFBLb8bMvDR/SdO1hUe5zvMiFMgmz+CDEp8sDjiutjpnos1Hu/Yr
Reposilite 2.9.26 Commands:
11:00:30.135 INFO |   chalias <alias> <new alias> - Change token alias
11:00:30.136 INFO |   chmod <alias> <permissions> - Change token permissions
11:00:30.136 INFO |   failures  - Display all recorded exceptions
11:00:30.136 INFO |   help [<command>] - List of available commands
11:00:30.136 INFO |   keygen <path> <alias> [<permissions>] - Generate a new access token for the given path
11:00:30.136 INFO |   purge  - Clear cache
11:00:30.136 INFO |   revoke <alias> - Revoke token
11:00:30.136 INFO |   stats [<filter>] - Display collected metrics
11:00:30.137 INFO |   status  - Display summary status of app health
11:00:30.137 INFO |   stop  - Shutdown server
11:00:30.137 INFO |   tokens  - List all generated tokens
11:00:30.137 INFO |   version  - Display current version of Reposilite
```

#### test for maven

- ~/.m2/settings.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <mirrors>
        <mirror>
            <id>zyb-repository</id>
            <mirrorOf>*</mirrorOf>
            <name>mirror</name>
            <url>http://10.16.1.247:9081</url>
        </mirror>
    </mirrors>
    <servers>
      <server>
          <!-- Id has to match the id provided in pom.xml -->
          <id>zyb-repository</id>
          <username>devops</username>
          <!-- gen-token: keygen / devops wr -->
          <password>token-xxxxx</password>
      </server>
    </servers>
</settings>
```

- ~/shell

```shell
# https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started.html
mvn dependency:tree
```

- ~/demo/pom.xml (https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started.html)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>myproject</artifactId>
    <version>0.0.1-SNAPSHOT</version>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.6.7</version>
    </parent>

    <!-- Additional lines to be added here... -->

</project>
```
