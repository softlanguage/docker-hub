# docker -c=pod01.dev build -t frontend:v1 -f Dockerfile PATH | - | URL
# useradd -m -s /bin/sh -N siri

# remove Hash.# to enable http_proxy
# ARG http_proxy=http://tinyproxy:8888
# ARG https_proxy=http://tinyproxy:8888
FROM docker.io/node:18-slim as builder_mp
ARG uhome=/siri
WORKDIR $uhome/app
RUN useradd -d $uhome -s /bin/sh -u 5001 siri && chown -R siri:siri $uhome
USER siri
RUN npm config set registry https://registry.npmmirror.com
ARG http_proxy
ARG https_proxy
# prepare for install
COPY --chown=siri:siri uimp/package*.json .
RUN npm install --quiet

COPY --chown=siri:siri uimp/ .
# Production: npm run build-prod
RUN ls -lh && npm run build --quiet

# for ui_pc
FROM docker.io/node:18-slim as builder_pc
ARG uhome=/siri
WORKDIR $uhome/app
RUN useradd -d $uhome -s /bin/sh -u 5001 siri && chown -R siri:siri $uhome
USER siri
RUN npm config set registry https://registry.npmmirror.com
ARG http_proxy
ARG https_proxy

# prepare for install
COPY --chown=siri:siri uimp/package*.json .
RUN npm install --quiet

COPY --chown=siri:siri uipc/ .
# Production: npm run build-prod
RUN ls -lh && npm run build --quiet

# runtime
FROM docker.io/nginx:1.14-alpine
ARG uhome=/siri
WORKDIR $uhome/app
ARG ui_mp=ui-mp
ARG ui_pc=ui-pc
COPY --from=builder_mp --chown=root:root $uhome/app/dist/ ./$ui_mp/
COPY --from=builder_pc --chown=root:root $uhome/app/dist/ ./$ui_pc/
ARG try_files='$uri $uri/index.html $uri.html'

# Test COPY, xx/ and ./xx both are the akin
#COPY ./uimp ./src/uimp
#COPY ./uipc/ ./src/uipc

RUN printf "server {listen 5000; server_name  _; \n\
location /$ui_mp { alias $uhome/app/$ui_mp/; try_files $try_files /$ui_mp/index.html; } \n\
location /$ui_pc { alias $uhome/app/$ui_pc/; try_files $try_files /$ui_pc/index.html; } \n\
}" > /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
