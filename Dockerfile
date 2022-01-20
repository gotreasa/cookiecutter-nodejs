FROM node:16 as BUILD

WORKDIR /usr/src/app

# Add pruning packages for use later.
RUN curl -sfL https://install.goreleaser.com/github.com/tj/node-prune.sh | bash -s -- -b /usr/local/bin

COPY package*.json ./

# Locally we will run it using
RUN npm ci

# Prune the source code.
RUN npm prune
RUN /usr/local/bin/node-prune

COPY . .

# Build final image using small base image.
FROM node:16-alpine

WORKDIR /usr/src/app

COPY --from=BUILD /usr/src/app /usr/src/app

# Set permissions for node app folder after copy.
RUN chown -R node:root /usr/src/app/
RUN chmod -R 775 /usr/src/app/

# Switch to node user.
USER node

# Image start commands.
EXPOSE 9080
ENTRYPOINT [ "npm" ]
CMD [ "run", "start:app" ]
