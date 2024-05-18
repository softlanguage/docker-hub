# https://docs.strapi.io/dev-docs/installation/docker
# https://docs.docker.com/build/building/context/#git-repositories
# https://github.com/strapi/strapi.git#v4.20.5
# docker build -t softlang/strapi:4.20 -f-<<'__dockerfile__' .
FROM node:18-slim
ENV NODE_ENV=production
ARG appdir=/opt/app
WORKDIR $appdir
RUN chown -R node:node $appdir
USER node
RUN npx create-strapi-app@4.20.5 . --quickstart
RUN rm -rf ~/{.npm,.cache} && du -sh ~/
RUN jwt_secret=$(node -e "console.log(require('crypto').randomBytes(16).toString('base64'));")
ENV JWT_SECRET=$jwt_secret
EXPOSE 1337
CMD ["npm", "run", "start"]
#__dockerfile__

# how to run?
# docker run -d --name strapi --network host -e JWT_SECRET=$(openssl rand --base64 32) softlang/strapi:4.20
