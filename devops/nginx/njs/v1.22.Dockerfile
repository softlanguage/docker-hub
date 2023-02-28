# docker build --network host --force-rm -f ng.Dockerfile -t softlang/nginx:v1.22-njs .
FROM nginx:1.22
WORKDIR /etc/nginx/njs
COPY nginx.conf /etc/nginx/nginx.conf
COPY njs/utils.js /etc/nginx/njs/utils.js
COPY njs/hello.js /etc/nginx/njs/hello.js
LABEL nginx_modules="njs"