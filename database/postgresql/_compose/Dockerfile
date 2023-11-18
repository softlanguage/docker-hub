# docker build --network host --force-rm -f Dockerfile -t softlang/postgres-cn:16 . 
# postgresql-16, support Chinese, base on bookworm
FROM postgres:16-bookworm

# https://github.com/docker-library/postgres/blob/master/16/bookworm/Dockerfile
RUN localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
# the followed link list all supported LC_xxx
# https://www.postgresql.org/docs/current/locale.html
# LC_COLLATE and LC_CTYPE 
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
    && apt update && apt install -y postgresql-plpython3-16 \
        iputils-ping wget htop nano procps net-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LC_COLLATE zh_CN.utf8
ENV LC_CTYPE zh_CN.utf8
LABEL softlang_tag="softlang postgre-v16, postgresql-plpython3-16, defualt LANG=zh_CN.utf8"
USER postgres
# docker run -itd --rm --name pgdb -e POSTGRES_PASSWORD=123654 softlang/postgres-cn:16
