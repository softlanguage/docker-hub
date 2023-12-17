# docker build --network host --force-rm -f Dockerfile -t softlang/mysql:v8.2-router .
# https://github.com/docker-library/mysql/blob/master/innovation/Dockerfile.oracle
# FROM oraclelinux:9-slim
FROM oraclelinux:9

# https://dev.mysql.com/downloads
# https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community-8.2.0-1.el9.x86_64.rpm
ARG RPM=https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-community-8.2.0-1.el9.x86_64.rpm
RUN echo " ---> install $RPM" && dnf install -y $RPM && dnf clean all

#RUN dnf install -y $RPM && dnf clean all
# https://hub.docker.com/_/oraclelinux
# https://www.oracle.com/linux/
