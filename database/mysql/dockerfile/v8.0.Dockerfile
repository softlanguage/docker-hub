# docker build --network host --force-rm -f Dockerfile -t softlang/mysql:v8.0.38 .
# https://github.com/docker-library/mysql/blob/master/innovation/Dockerfile.oracle
FROM mysql:8.0.38
# microdnf repoquery mysql-router-community
# microdnf install -y mysql-router-community
RUN  microdnf install -y mysql-router-community && microdnf clean all
LABEL os_linux="Oracle Linux Server 8.9"
# https://hub.docker.com/_/oraclelinux
# https://www.oracle.com/linux/
