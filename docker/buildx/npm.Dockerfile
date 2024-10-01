# docker -c=pod01.dev build -t frontend:v1 -f Dockerfile [OPTIONS] PATH | - | URL
# useradd -m -s /bin/sh -N siri
FROM docker.io/node:18-slim as builder
ARG uhome=/siri
WORKDIR $uhome/app
RUN useradd -d $uhome -s /bin/sh -u 5001 siri && chown -R siri:siri $uhome
USER siri
ARG http_proxy=http://172.31.240.97:8888
ARG https_proxy=http://172.31.240.97:8888
RUN npm config set registry https://registry.npmmirror.com
#RUN mkdir ./{uimp,uipc}

# prepare for install
COPY --chown=siri:siri uimp/package*.json ./uimp/
COPY --chown=siri:siri uipc/package*.json ./uipc/
RUN sh -e -c 'cd ./uimp; npm install --quiet' && \
    sh -e -c 'cd ./uipc; npm install --quiet'

COPY --chown=siri:siri . .
# Production: npm run build-prod
RUN sh -e -c 'cd ./uimp; npm run build --quiet' && \
    sh -e -c 'cd ./uipc; npm run build --quiet'

# runtime
FROM docker.io/nginx:1.14-alpine
ARG uhome=/siri
WORKDIR $uhome/app
COPY --from=builder --chown=root:root $uhome/app/uimp/dist/ ./ui-mp/
COPY --from=builder --chown=root:root $uhome/app/uipc/dist/ ./ui-pc/

RUN printf "\
server { \n\
    listen 5000; \n\
    server_name  _; \n\
    location / { \n\
        alias $uhome/app/; \n\
        index index.html index.htm; \n\
        try_files $uri $uri/index.html $uri.html /index.html; \n\
    } \n\
}" > /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
