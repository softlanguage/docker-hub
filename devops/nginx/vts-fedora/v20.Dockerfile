# docker build --network host --force-rm -f v20.Dockerfile -t softlang/nginx:v1.20-vts .
# build image
FROM fedora:33
# install build tools
RUN dnf makecache && dnf install nginx nginx-mod-stream nginx-mod-vts lsof telnet procps htop -y \
    && dnf clean all && rm -rf /var/cache/dnf/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
    
COPY default.conf /etc/nginx/conf.d/default.conf
COPY vhost.cfg /etc/nginx/conf.d/vhost.cfg
COPY nginx.conf /etc/nginx/nginx.conf

LABEL demo="docker run -itd --rm --name ngvts -m=64M softlang/nginx:v1.20-vts"
LABEL sd_notice="/etc/docker/daemon.json {'default-ulimits': {'nofile': {'Name': 'nofile','Hard': 65536,'Soft': 65536}}}"
LABEL sd_ports="80=nginx, 8080=vts, 10080-10088=entry"
CMD ["nginx", "-g", "daemon off;"]
# docker run -itd --rm --name ngvts -m=64M softlang/nginx:v1.20-vts