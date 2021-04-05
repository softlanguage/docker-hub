## Dockerfile

### step
1. docker stack deploy ...
2. docker exec -it mpp-gtm-m01 su postgres
3. ssh-keygen && sh-copy-id (execute on gtm-master1)
4. ssh-keyscan -t rsa,dsa hostname 2>&1 >> ~/.ssh/known_hosts 
5. config .bashrc  && source .bashrc (所有节点)
6. pgxc_ctl

### ~/.bashrc

```bash
export PGUSER=postgres
export PGHOME=/usr/local/pgsql
export PGXC_CTL_HOME=$HOME/pgxc_ctl
export LD_LIBRARY_PATH=$PGHOME/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib
export PATH=$PGHOME/bin:$PATH:$HOME/.local/bin:$HOME/bin
```

### docker swarm 下解决 客户端认证问题（已验证）

```conf
# 1. 每个 CN节点 配置 固定IP使用 md5 认证（pg_hba.conf按顺序匹配、所以需要放在前面），如： 10.0.1.254/32   md5
# TYPE, DATABASE, USER, ADDRESS, METHOD
host        all        all        10.0.1.254/32   md5
host        all        all        10.0.0.0/8      trust
host        all        all        0.0.0.0/0       md5
```

- docker-compose.yaml

```yaml
# 2. docker-compose 部署haproxy容器（docker service不支持固定IP），如：
# docker-compose -p mpp-stack -f mpp-ingress.yaml --compatibility up -d
# docker pull haproxy:2.2-alpine  (LTS)
# https://github.com/haproxy/haproxy/tree/v2.2.0/examples

version: "3"

networks:
  default:
    external:
      name: mpp

services:
  mpp-haproxy:
    image: haproxy:2.2-alpine
    hostname: mpp-haproxy
    environment:
      TZ: Asia/Shanghai
    networks:
      default:
        ipv4_address: 10.0.1.254
    ports:
      - 9032:5432
      - 9031:81
    volumes:
      - "./conf/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 256M
```

### pgbouncer

```conf
# pgbouncer只适合coding执行ACID，不支持 pgAdmin4等客户端
yum install pgbouncer

# pgbouncer.ini
[databases]
db1 = host=localhost port=25432 user=usr1 password=1234654
#demo = host=mpp-ingresss port=5432

[pgbouncer]
logfile = /var/log/pgbouncer/pgbouncer.log
pidfile = /var/run/pgbouncer/pgbouncer.pid
listen_addr = *
listen_port = 6432
# auth_type 认证方式, plain、md5
auth_type = md5
# auth_file: "username" "password"
auth_file = /etc/pgbouncer/pgbouncer.usr
admin_users = postgres
stats_users = stats, postgres
pool_mode = session
server_reset_query = DISCARD ALL
max_client_conn = 500
# 默认池大小，表示建立多少个pgbouncer到数据库的连接
default_pool_size = 5

# pgbouncer.usr, { select usename, passwd from pg_shadow order by 1; }
"user1" "md5baa6c789c3728a1a449b82005eb54a19"
"user2" "md5baa6c789c3728a1a449b82005eb54a19"
```

### docker-compose.yaml

```yaml
# docker stack deploy --prune -c docker-compose.yaml pgxl01
# docker pull softlang/postgres-xl-10r1:1.1
# docker pull haproxy:2.2-alpine  (LTS)
# https://github.com/haproxy/haproxy/tree/v2.2.0/examples

version: "3"

networks:
  default:
    external:
      name: mpp

services:
  mpp-ingress:
    image: haproxy:2.2-alpine
    hostname: mpp-ingress
    environment:
      TZ: Asia/Shanghai
    ports:
      - 25433:5433
      - 25432:5432
      - 25431:81
    volumes:
      - "./conf/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
    depends_on:
      - mppcn01
      - mppcn02
      - mppcn03
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-m1.wb]
      resources:
        limits:
          cpus: '0.25'
          memory: 256M
  mppgtmm01:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-gtm-m01
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-gtm-m01:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-m1.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppgtmproxy01:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-gtm-proxy01
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-gtm-proxy01:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s1.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppgtmproxy02:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-gtm-proxy02
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-gtm-proxy02:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s2.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppcn01:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-cn01
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-cn01:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-m1.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppcn02:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-cn02
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-cn02:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s1.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppcn03:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-cn03
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-cn03:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s2.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppdn01:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-dn01
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-dn01:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s1.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppdn02:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-dn02
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-dn02:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s1.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppdn03:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-dn03
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-dn03:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s1.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppdn04:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-dn04
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-dn04:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s1.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppdn05:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-dn05
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-dn05:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s2.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppdn06:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-dn06
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-dn06:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s2.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppdn07:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-dn07
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-dn07:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s2.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
  mppdn08:
    image: softlang/postgres-xl-10r1:1.1
    hostname: mpp-dn08
    environment:
      TZ: Asia/Shanghai
    volumes:
      - mpp-dn08:/app
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.hostname == pgmpp-s2.wb]
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
volumes:
  mpp-gtm-m01:
  mpp-gtm-proxy01:
  mpp-gtm-proxy02:
  # coordinator node
  mpp-cn01:
  mpp-cn02:
  mpp-cn03:
  # data node
  mpp-dn01:
  mpp-dn02:
  mpp-dn03:
  mpp-dn04:
  mpp-dn05:
  mpp-dn06:
  mpp-dn07:
  mpp-dn08:

```

### pgxc_ctl.cfg

```conf
#!/usr/bin/env bash
# pgxcInstallDir variable is needed if you invoke "deploy" command from pgxc_ctl utility.
# If don't you don't need this variable.
pgxcInstallDir=$HOME/pgxc
#---- OVERALL -----------------------------------------------------------------------------
#
pgxcOwner=$USER		# owner of the Postgres-XC databaseo cluster.  Here, we use this
						# both as linus user and database user.  This must be
						# the super user of each coordinator and datanode.
pgxcUser=$pgxcOwner		# OS user of Postgres-XC owner

tmpDir=/tmp					# temporary dir used in XC servers
localTmpDir=$tmpDir			# temporary dir used here locally

configBackup=n					# If you want config file backup, specify y to this value.
configBackupHost=pgxc-linker	# host to backup config file
configBackupDir=$HOME/pgxc		# Backup directory
configBackupFile=pgxc_ctl.bak	# Backup file name --> Need to synchronize when original changed.

dataDirRoot=$HOME/nodes

#---- GTM ------------------------------------------------------------------------------------

# GTM is mandatory.  You must have at least (and only) one GTM master in your Postgres-XC cluster.
# If GTM crashes and you need to reconfigure it, you can do it by pgxc_update_gtm command to update
# GTM master with others.   Of course, we provide pgxc_remove_gtm command to remove it.  This command
# will not stop the current GTM.  It is up to the operator.

#---- Overall -------
gtmName=gtm

#---- GTM Master -----------------------------------------------

#---- Overall ----
gtmMasterServer=mppgtmm01
gtmMasterPort=5432
gtmMasterDir=$dataDirRoot/gtm

#---- Configuration ---
gtmExtraConfig=none			# Will be added gtm.conf for both Master and Slave (done at initilization only)
gtmMasterSpecificExtraConfig=none	# Will be added to Master's gtm.conf (done at initialization only)

#---- GTM Slave -----------------------------------------------
# Because GTM is a key component to maintain database consistency, you may want to configure GTM slave
# for backup.

#---- Overall ------
gtmSlave=n					# Specify y if you configure GTM Slave.   Otherwise, GTM slave will not be configured and
#---- Shortcuts ------
gtmProxyDir=$dataDirRoot/gtm_pxy

#---- Overall -------
gtmProxy=y				# Specify y if you conifugre at least one GTM proxy.   You may not configure gtm proxies
						# only when you dont' configure GTM slaves.
						# If you specify this value not to y, the following parameters will be set to default empty values.
						# If we find there're no valid Proxy server names (means, every servers are specified
						# as none), then gtmProxy value will be set to "n" and all the entries will be set to
						# empty values.
gtmProxyNames=(gtm_pxy1 gtm_pxy2)	# No used if it is not configured
gtmProxyServers=(mppgtmproxy01 mppgtmproxy02)			# Specify none if you dont' configure it.
gtmProxyPorts=(5432 5432)				# Not used if it is not configured.
gtmProxyDirs=($gtmProxyDir.1 $gtmProxyDir.2)	# Not used if it is not configured.

#---- Configuration ----
gtmPxyExtraConfig=none		# Extra configuration parameter for gtm_proxy.  Coordinator section has an example.

#---- Coordinators ----------------------------------------------------------------------------------------------------

#---- shortcuts ----------
coordMasterDir=$dataDirRoot/coord_master
coordSlaveDir=$HOME/coord_slave
coordArchLogDir=$HOME/coord_archlog

#---- Overall ------------
coordNames=(coord1 coord2 coord3)		# Master and slave use the same name
coordPorts=(5432 5432 5432)				# Master server listening ports
poolerPorts=(30011 30012 30013)			# Master pooler ports
coordPgHbaEntries=(10.0.0.0/8)	# Assumes that all the coordinator (master/slave) accepts
												# the same connection
												# This entry allows only $pgxcOwner to connect.
												# If you'd like to setup another connection, you should
												# supply these entries through files specified below.
#coordPgHbaEntries=(127.0.0.1/32)	# Same as above but for IPv4 connections

#---- Master -------------
coordMasterServers=(mppcn01 mppcn02 mppcn03)		# none means this master is not available
coordMasterDirs=($coordMasterDir.1 $coordMasterDir.2 $coordMasterDir.3)
coordMaxWALsender=5	# max_wal_senders: needed to configure slave. If zero value is specified,
						# it is expected to supply this parameter explicitly by external files
						# specified in the following.	If you don't configure slaves, leave this value to zero.
coordMaxWALSenders=($coordMaxWALsender $coordMaxWALsender $coordMaxWALsender)
						# max_wal_senders configuration for each coordinator.

#---- Slave -------------
coordSlave=n			# Specify y if you configure at least one coordiantor slave.  Otherwise, the following
#---- Configuration files---
# Need these when you'd like setup specific non-default configuration 
# These files will go to corresponding files for the master.
# You may supply your bash script to setup extra config lines and extra pg_hba.conf entries 
# Or you may supply these files manually.
coordExtraConfig=coordExtraConfig	# Extra configuration file for coordinators.  
						# This file will be added to all the coordinators'
						# postgresql.conf
# Pleae note that the following sets up minimum parameters which you may want to change.
# You can put your postgresql.conf lines here.
cat > $coordExtraConfig <<EOF
#================================================
# Added to all the coordinator postgresql.conf
# Original: $coordExtraConfig
log_destination = 'stderr'
logging_collector = on
log_directory = 'pg_log'
listen_addresses = '*'
max_connections = 500
max_pool_size = 512
hot_standby = off
EOF

# Additional Configuration file for specific coordinator master.
# You can define each setting by similar means as above.
coordSpecificExtraConfig=(none none none)
coordExtraPgHba=coordExtraPgHba
cat > $coordExtraPgHba <<EOF

# TYPE, DATABASE, USER, ADDRESS, METHOD
host        all        all        10.0.0.0/8        trust
host        all        all        0.0.0.0/0        md5

EOF

coordSpecificExtraPgHba=(none none none)

#---- Datanodes -------------------------------------------------------------------------------------------------------

#---- Shortcuts --------------
datanodeMasterDir=$dataDirRoot/dn_master
datanodeSlaveDir=$dataDirRoot/dn_slave
datanodeArchLogDir=$dataDirRoot/datanode_archlog

#---- Overall ---------------
primaryDatanode=mppdn01				# Primary Node.
datanodeNames=(mppdn01 mppdn02 mppdn03 mppdn04 mppdn05 mppdn06 mppdn07 mppdn08)
datanodePorts=(5432 5432 5432 5432 5432 5432 5432 5432)	# Master and slave use the same port!
datanodePoolerPorts=(40011 40012 40013 40014 40015 40016 40017 40018)	# Master and slave use the same port!
datanodePgHbaEntries=(10.0.0.0/8)	# Assumes that all the coordinator (master/slave) accepts
										# the same connection
										# This list sets up pg_hba.conf for $pgxcOwner user.
										# If you'd like to setup other entries, supply them
										# through extra configuration files specified below.
#datanodePgHbaEntries=(127.0.0.1/32)	# Same as above but for IPv4 connections

#---- Master ----------------
datanodeMasterServers=(mppdn01 mppdn02 mppdn03 mppdn04 mppdn05 mppdn06 mppdn07 mppdn08)	# none means this master is not available.
													# This means that there should be the master but is down.
													# The cluster is not operational until the master is
													# recovered and ready to run.	
datanodeMasterDirs=($datanodeMasterDir.1 $datanodeMasterDir.2 $datanodeMasterDir.3 $datanodeMasterDir.4 $datanodeMasterDir.5 $datanodeMasterDir.6 $datanodeMasterDir.7 $datanodeMasterDir.8)
datanodeMaxWalSender=5								# max_wal_senders: needed to configure slave. If zero value is 
													# specified, it is expected this parameter is explicitly supplied
													# by external configuration files.
													# If you don't configure slaves, leave this value zero.
datanodeMaxWALSenders=($datanodeMaxWalSender $datanodeMaxWalSender $datanodeMaxWalSender $datanodeMaxWalSender $datanodeMaxWalSender $datanodeMaxWalSender $datanodeMaxWalSender $datanodeMaxWalSender)
						# max_wal_senders configuration for each datanode

#---- Slave -----------------
datanodeSlave=n			# Specify y if you configure at least one coordiantor slave.  Otherwise, the following

# ---- Configuration files ---
# You may supply your bash script to setup extra config lines and extra pg_hba.conf entries here.
# These files will go to corresponding files for the master.
# Or you may supply these files manually.
datanodeExtraConfig=datanodeExtraConfig	
cat > $datanodeExtraConfig <<EOF
#================================================
# Added to all the datanode postgresql.conf
# Original: $datanodeExtraConfig
log_destination = 'stderr'
logging_collector = on
log_directory = 'pg_log'
listen_addresses = '*'
max_connections = 500
max_pool_size = 512
hot_standby = off
EOF
# Additional Configuration file for specific datanode master.
# You can define each setting by similar means as above.
datanodeSpecificExtraConfig=(none none none none none none none none)

datanodeExtraPgHba=datanodeExtraPgHba
cat > $datanodeExtraPgHba <<EOF

# TYPE, DATABASE, USER, ADDRESS, METHOD
host        all        all        10.0.0.0/8        trust

EOF

datanodeSpecificExtraPgHba=(none none none none none none none none)


```

### ./conf/haproxy.cfg

```conf
global
        maxconn         10000
        stats socket    /var/run/haproxy.stat mode 600 level admin
        log             127.0.0.1 local0
        uid             200
        gid             200
        chroot          /var/empty
        daemon

# HAProxy web ui
listen stats
	bind 0.0.0.0:81
	mode http
	log global
	maxconn 10
	timeout client 100s
	timeout server 100s
	timeout connect 100s
	timeout queue 100s

	stats enable
	stats uri /stats
	stats realm HAProxy\ Statistics
        stats auth ci2:ci1289  #用这个账号登录，可以自己设置
	stats admin if TRUE
	stats show-node

listen MPP-5432
	bind 0.0.0.0:5432
	mode tcp
	balance leastconn
	#balance roundrobin (percona)
	option tcplog
	maxconn 2000
	option tcp-check
	server mpp-cn01 mpp-cn01:5432 check port 5432 inter 12000 rise 3 fall 3
	server mpp-cn02 mpp-cn02:5432 check port 5432 inter 12000 rise 3 fall 3
```

### Dockerfile.deb9 构建镜像
> docker hub is  https://hub.docker.com/r/softlang/postgres-xl-10r1

```Dockerfile
# docker build --force-rm -t mpp/pg-xl:v2.2 -f Dockerfile.deb9 .
# service ssh stop/start
FROM debian:9-slim as build

ARG PGXL_SOURCE=postgres-xl-10r1.1

RUN echo '' > /etc/apt/sources.list
RUN echo "\
deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib \n\
deb http://mirrors.aliyun.com/debian-security stretch/updates main \n\
deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib \n\
deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib \n\
" > /etc/apt/sources.list

RUN cat /etc/apt/sources.list

RUN apt-get update \
	&& apt-get install -y \
		vim \
		git \
		curl \
		make \
		build-essential \
		libreadline-dev \
		zlib1g-dev \
		bison \
		flex \
	&& ln -s /usr/bin/make /usr/bin/gmake \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN cd /app
# ADD with auto tar -xzf
ADD ${PGXL_SOURCE}.tar.gz /app
#ADD https://www.postgres-xl.org/downloads/postgres-xl-10r1.1.tar.gz /app
#RUN tar -xzf postgres-xl-10r1.1.tar.gz

RUN pwd	\
	&& ls -lh
	#&& tar -xzf ./${PGXL_SOURCE}.tar.gz

#cd $(ls -la | grep -E '^d.*postgres-xl' | awk '{ print $NF }'); \
RUN echo "[INFO] Install Postgres-XL, $PGXL_SOURCE"; 
RUN cd $PGXL_SOURCE && pwd && ls && ./configure && make && make install
RUN pwd && ls && cd $PGXL_SOURCE/contrib && make && make install

#-------- build complate -------
FROM debian:9-slim
ENV POSTGRES_HOME=/usr/local/pgsql
COPY --from=build $POSTGRES_HOME $POSTGRES_HOME

ENV POSTGRES_HOSTNAME=pg-xl-db \
	POSTGRES_USER=postgres \
	POSTGRES_HOME=/usr/local/pgsql \
	POSTGRES_PORT=5432 \
	POSTGRES_MAX_CONNECTIONS=1024 \
	POSTGRES_SHARED_QUEUES_SIZE=64kB \
	DEBUG="false"

#ENV POSTGRES_DATA=$POSTGRES_HOME/data \
ENV POSTGRES_DATA=/app \
	MAX_POOL_SIZE=$POSTGRES_MAX_CONNECTIONS \
	PATH=/usr/local/pgsql/bin:$PATH \
	LD_LIBRARY_PATH=/usr/local/pgsql/lib

RUN echo '' > /etc/apt/sources.list
RUN echo "\
deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib \n\
deb http://mirrors.aliyun.com/debian-security stretch/updates main \n\
deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib \n\
deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib \n\
" > /etc/apt/sources.list

RUN apt-get update \
	&& apt-get install -y procps nano \
	&& apt install -y openssh-server \
	&& apt-get install -y \
		libreadline-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd $POSTGRES_USER -u 26 -d $POSTGRES_DATA -s /bin/bash \
	&& mkdir -p $POSTGRES_DATA \
	&& chown -R $POSTGRES_USER $POSTGRES_HOME \
	&& chown -R $POSTGRES_USER $POSTGRES_DATA \
	&& rm -f /etc/ssh/ssh_host_*key

RUN dpkg-reconfigure openssh-server
RUN mkdir /run/sshd
RUN echo 'postgres:softlan9' | chpasswd
#RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

#USER $POSTGRES_USER
WORKDIR $POSTGRES_DATA

EXPOSE 5432 22
VOLUME [$POSTGRES_DATA]
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
#ENTRYPOINT service ssh restart && su postgres
# can't run sshd without root user, so USER=root
```