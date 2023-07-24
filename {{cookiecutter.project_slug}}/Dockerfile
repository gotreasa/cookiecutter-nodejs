FROM node:18 AS BUILD

WORKDIR /usr/src/app

# Add pruning packages for use later.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sfL https://gobinaries.com/tj/node-prune | bash -s -- -b /usr/local/bin

COPY package*.json ./

# Locally we will run it using
RUN npm ci --omit=dev --ignore-scripts

# Prune the source code.
RUN npm prune --omit=dev && /usr/local/bin/node-prune 

COPY app.js ./
COPY openapi.json ./
COPY src src
COPY test/container/integration/goss.yaml goss.yaml
RUN date -u > timestamp

# Build final image using small base image.
FROM node:18-alpine

# Update any out of date packages
RUN apk update && apk upgrade

WORKDIR /usr/src/app

COPY --from=BUILD /usr/src/app /usr/src/app

# Set permissions for node app folder after copy.
RUN chown -R node:root /usr/src/app/ && chmod -R 775 /usr/src/app/

# Switch to node user.
USER node

# Image start commands.
EXPOSE 9080
ENTRYPOINT [ "npm" ]
CMD [ "run", "start:app" ]
