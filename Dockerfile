FROM node:14-alpine as build

WORKDIR /usr/src/app/
ENV NODE_ENV=production

# By doing this separate we allow Docker to cache this
COPY package.json yarn.lock /usr/src/app/
RUN yarn --production=false

COPY . /usr/src/app/
RUN yarn build
RUN yarn --production=true

FROM node:14-alpine

WORKDIR /usr/src/app/
ENV NODE_ENV=production
USER node
EXPOSE 3001

COPY --from=build /usr/src/app/build/ /usr/src/app/
COPY --from=build /usr/src/app/node_modules/ /usr/src/app/node_modules/
COPY --from=build /usr/src/app/migrations/ /usr/src/app/migrations/
COPY --from=build /usr/src/app/scripts/ /usr/src/app/scripts/
COPY --from=build /usr/src/app/src/modules/spa/CharacterJourney.mp4 /usr/src/app/modules/spa/
COPY --from=build /usr/src/app/src/modules/spa/503.html /usr/src/app/modules/spa/
COPY package.json /usr/src/app/

CMD node --harmony node_modules/sequelize-cli/lib/sequelize db:migrate --config config/database.js && node --harmony index.js
