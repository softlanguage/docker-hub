# mariadb with rocksdb engine
FROM mariadb:10.5-bionic
#http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu/
RUN apt-get update && apt-get install software-properties-common -y
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 F1656F24C74CD1D8
RUN add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu bionic main'
RUN apt-get -y install mariadb-plugins-rocksdb && rm -rf /var/cache/apt/lists/*
