#ARG NODE_IMAGE=node:20.4.0
ARG NODE_IMAGE=node:21.6
FROM $NODE_IMAGE AS base

RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb
RUN dpkg -i --force-architecture dumb-init_*.deb
RUN mkdir -p /home/node/app && chown node:node /home/node/app

WORKDIR /home/node/app
USER node
RUN mkdir tmp

FROM base AS dependencies
COPY --chown=node:node package.json ./
RUN npm i
COPY --chown=node:node . .

FROM dependencies AS build
RUN node ace build --production --ignore-ts-errors

FROM base AS production
ENV NODE_ENV=production
ENV PORT=$PORT
ENV HOST=0.0.0.0
COPY --chown=node:node ./package*.json ./
RUN npm install --production
COPY --chown=node:node --from=build /home/node/app/build .
EXPOSE $PORT
CMD ["dumb-init", "node", "server.js"]
