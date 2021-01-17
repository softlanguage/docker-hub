# mariadb with rocksdb engine
FROM mariadb:10.5-bionic

RUN curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
RUN apt-get update && apt-get -y install mariadb-plugins-rocksdb && rm -rf /var/cache/apt/lists/*
