# 支持中文的postgresql13.2
# https://github.com/citusdata/docker
FROM postgres:13.2
RUN localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.utf8

# fdw + curl
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       postgresql-13-mysql-fdw \
       curl

# citus
RUN curl -s https://install.citusdata.com/community/deb.sh | bash \
    && apt-get -y install postgresql-13-citus-10.0

# clean + rm curl
RUN apt-get purge -y --auto-remove curl \
    && rm -rf /var/lib/apt/lists/*

# add citus to default PostgreSQL config
RUN echo "shared_preload_libraries='citus'" >> /usr/share/postgresql/postgresql.conf.sample
# add health check script
# COPY pg_healthcheck wait-for-manager.sh /
# RUN chmod +x /wait-for-manager.sh && chmod +x /pg_healthcheck

# entry point unsets PGPASSWORD, but we need it to connect to workers
# https://github.com/docker-library/postgres/blob/33bccfcaddd0679f55ee1028c012d26cd196537d/12/docker-entrypoint.sh#L303
# 需要修改 pg_hba.conf trust connect to workers
# RUN sed "/unset PGPASSWORD/d" -i /usr/local/bin/docker-entrypoint.sh

# HEALTHCHECK --interval=4s --start-period=6s CMD /pg_healthcheck
HEALTHCHECK --interval=4s --start-period=6s CMD pg_isready --timeout=5 --quiet || exit 1
# docker inspect --format "{{json .State.Health }}" <container name>