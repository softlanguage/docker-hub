# softlang.net
# build a centos 7 os for test.
FROM centos:centos7

RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo;
RUN yum makecache;

RUN yum -y update; yum clean all
RUN yum -y install net-tools vim nano wget curl
RUN yum -y install openssh-server passwd
RUN yum clean all
RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

EXPOSE 22
EXPOSE 88
EXPOSE 80
EXPOSE 443
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
