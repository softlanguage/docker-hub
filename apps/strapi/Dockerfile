# https://docs.strapi.io/dev-docs/installation/docker
# https://docs.docker.com/build/building/context/#git-repositories
# https://github.com/strapi/strapi.git#v4.20.5
# docker build --build-arg JWT_SECRET=$(openssl rand --base64 32) -t softlang/strapi:4.20 -f-<<'__dockerfile__' .
FROM node:18-alpine as builder
ARG JWT_SECRET
ARG appdir=/home/node/app
ENV NODE_ENV=production
WORKDIR $appdir
USER root
RUN chown -R node:node $appdir
# JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('base64'));")
USER node
RUN npx create-strapi-app@4.20.5 . --quickstart --no-run
# runtime
FROM node:18-alpine
ARG appdir
ARG JWT_SECRET
USER root
COPY --from=builder $appdir $appdir
RUN chown -R node:node $appdir
WORKDIR $appdir
ENV NODE_ENV=production
ENV JWT_SECRET=${JWT_SECRET}
USER node
EXPOSE 1337
CMD ["npm", "run", "start"]
#__dockerfile__

# how to run?
# docker run -d --name strapi --network host -e JWT_SECRET=$(openssl rand --base64 32) softlang/strapi:4.20
