# docker -c=pod01.dev build -t frontend:v1 -f Dockerfile PATH | - | URL
# useradd -m -s /bin/sh -N siri
FROM docker.io/node:18-slim as builder
ARG uhome=/siri
WORKDIR $uhome/app
RUN useradd -d $uhome -s /bin/sh -u 5001 siri && chown -R siri:siri $uhome
USER siri
# ARG http_proxy=http://tinyproxy:8888
# ARG https_proxy=http://tinyproxy:8888
RUN npm config set registry https://registry.npmmirror.com

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
ARG ui_mp=ui-mp
ARG ui_pc=ui-pc
COPY --from=builder --chown=root:root $uhome/app/uimp/dist/ ./$ui_mp/
COPY --from=builder --chown=root:root $uhome/app/uipc/dist/ ./$ui_pc/
ARG try_files='$uri $uri/index.html $uri.html'

RUN printf "server {listen 5000; server_name  _; \n\
location /$ui_mp { alias $uhome/app/$ui_mp/; try_files $try_files /$ui_mp/index.html; } \n\
location /$ui_pc { alias $uhome/app/$ui_pc/; try_files $try_files /$ui_pc/index.html; } \n\
}" > /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
