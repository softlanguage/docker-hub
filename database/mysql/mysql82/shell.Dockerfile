# docker build --network host --force-rm -f Dockerfile -t softlang/mysql:v8.2-shell .
# https://github.com/docker-library/mysql/blob/master/innovation/Dockerfile.oracle
# FROM oraclelinux:9-slim
FROM oraclelinux:9

# https://dev.mysql.com/downloads
# https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell-8.2.1-1.el9.x86_64.rpm
ARG RPM1=https://dev.mysql.com/get/Downloads/MySQL-Shell/mysql-shell-8.2.1-1.el9.x86_64.rpm
RUN printf " ---> install\n\t$RPM1\n" && dnf install -y $RPM1 && dnf clean all

#RUN dnf install -y $RPM && dnf clean all
# https://hub.docker.com/_/oraclelinux
# https://www.oracle.com/linux/
