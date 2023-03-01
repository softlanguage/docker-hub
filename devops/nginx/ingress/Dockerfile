# docker build --network host --force-rm -f Dockerfile -t softlang/nginx:v1.20 .
# build image
FROM nginx:1.20-alpine
COPY default.conf /etc/nginx/conf.d/default.conf
COPY vhost.cfg /etc/nginx/conf.d/vhost.cfg
COPY nginx.conf /etc/nginx/nginx.conf

ENV sd_curl="wget -qS --spider -O - localhost"
LABEL sd_demo="docker run -itd --rm --name ngvts -m=64M softlang/nginx:v1.20"
LABEL sd_notice="/etc/docker/daemon.json {'default-ulimits': {'nofile': {'Name': 'nofile','Hard': 65536,'Soft': 65536}}}"
LABEL sd_ports="80=nginx, 8080=vts, 10080-10088=entry"
# docker run -itd --rm --name ngvts -m=64M softlang/nginx:v1.20