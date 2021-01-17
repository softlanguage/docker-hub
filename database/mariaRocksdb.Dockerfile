# mariadb with rocksdb engine
FROM mariadb:10.5-bionic
RUN apt-get update && apt-get -y install mariadb-plugins-rocksdb && rm -rf /var/cache/apt/lists/*
