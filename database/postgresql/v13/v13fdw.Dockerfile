# 支持中文的postgresql13.3
FROM postgres:13.3
RUN localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.utf8

RUN apt-get update \
	&& apt-get install -y postgresql-13-mysql-fdw

# clean + rm curl
#RUN apt-get purge -y --auto-remove curl \
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# add health check script
COPY pg_healthcheck /
# COPY wait-for-manager.sh /
RUN chmod +x /pg_healthcheck
HEALTHCHECK --interval=10s --retries=3 --start-period=6s CMD /pg_healthcheck
