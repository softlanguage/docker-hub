# docker build --network host --force-rm -f ng.Dockerfile -t softlang/nginx:v1.20 .
FROM nginx:1.20-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
