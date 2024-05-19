# https://docs.strapi.io/dev-docs/installation/docker
# https://docs.docker.com/build/building/context/#git-repositories
# https://github.com/strapi/strapi.git#v4.20.5
# docker build --build-arg JWT_SECRET=$(openssl rand --base64 32) -t softlang/strapi:4.20 -f-<<'__dockerfile__' .
FROM node:18-alpine as builder
USER node
ARG JWT_SECRET
ENV NODE_ENV=production
WORKDIR /home/node/app
# JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('base64'));")
RUN npx create-strapi-app@4.20.5 . --quickstart --no-run
# runtime
FROM node:18-alpine
USER node
WORKDIR /home/node/app
# --chown=user:group will reduce volume of image layer
COPY --from=builder --chown=node:node /home/node/app /home/node/app
ARG JWT_SECRET
ENV JWT_SECRET=${JWT_SECRET}
ENV NODE_ENV=production
EXPOSE 1337
CMD ["npm", "run", "start"]
#__dockerfile__

# how to run?
# docker run -d --name strapi --network host -e JWT_SECRET=$(openssl rand --base64 32) softlang/strapi:4.20
