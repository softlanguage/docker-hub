# mariadb with rocksdb engine
FROM mariadb:10.5-bionic

RUN sudo apt-get install software-properties-common
RUN sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main'

RUN apt-get update && apt-get -y install mariadb-plugins-rocksdb && rm -rf /var/cache/apt/lists/*
