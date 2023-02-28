# docker build --network host --force-rm -f Dockerfile -t softlang/nginx:v1.22-vts .
# build image
FROM fedora:35
# install build tools
RUN dnf makecache && dnf install nginx nginx-mod-stream nginx-mod-vts -y && dnf clean all \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
    
COPY default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

LABEL demo="docker run -itd --rm --name ngvts -m=64M softlang/nginx:v1.22-vts"
LABEL notice="/etc/docker/daemon.json {'default-ulimits': {'nofile': {'Name': 'nofile','Hard': 65536,'Soft': 65536}}}"

CMD ["nginx", "-g", "daemon off;"]
# docker run -itd --rm --name ngvts -m=64M softlang/nginx:v1.22-vts