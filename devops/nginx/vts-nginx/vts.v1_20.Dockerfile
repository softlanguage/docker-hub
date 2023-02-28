# docker build --network host --force-rm -f ng.Dockerfile -t softlang/nginx:v1.20-vts .
# build image
FROM nginx:1.20-alpine

LABEL nginx_modules="nginx-mod-http-vts,nginx-mod-http-js"
LABEL nginx_vts_port="8080"
LABEL demo="docker run -itd --rm --name ngvts -m=64M softlang/nginx:v1.20-vts"

# install build tools
RUN apk update \
    && apk add --no-cache nginx-mod-http-vts nginx-mod-http-js \
    && rm /var/cache/apk/* -rf

# docker run -itd --rm --name ngvts -m=64M -p 8080:80 softlang/nginx:v1.20-vts
