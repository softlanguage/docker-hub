# docker build --network host --force-rm -f ng.Dockerfile -t softlang/nginx:v1.20-vts .
# build image
FROM nginx:1.20-alpine

# install build tools
RUN apk update && apk upgrade && \
    apk add --no-cache nginx-mod-http-vts

# docker run -itd --rm --name ngvts -m=64M -p 8080:80 softlang/nginx:v1.20-vts
