# docker build --force-rm -t mpp/pg-xl:v1.1 -f Dockerfile.deb9 .
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
#ADD ${PGXL_SOURCE}.tar.gz /app
ADD https://www.postgres-xl.org/downloads/postgres-xl-10r1.1.tar.gz /app
RUN tar -xzf postgres-xl-10r1.1.tar.gz

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

# 中文支持
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.utf8

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

# ~/.bashrc
RUN echo '' > /app/.bashrc
RUN echo "\
export PGUSER=postgres \n\
export PGHOME=/usr/local/pgsql \n\
export PGXC_CTL_HOME=/app/pgxc_ctl \n\
export LD_LIBRARY_PATH=$PGHOME/lib \n\
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib \n\
export PATH=$PGHOME/bin:$PATH:$HOME/.local/bin:$HOME/bin \n\
" > /app/.bashrc
RUN chown -R $POSTGRES_USER:$POSTGRES_USER $POSTGRES_DATA 

#USER $POSTGRES_USER
WORKDIR $POSTGRES_DATA

EXPOSE 5432 22
VOLUME [$POSTGRES_DATA]
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
#ENTRYPOINT service ssh restart && su postgres
# can't run sshd without root user, so USER=root