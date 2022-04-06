# TODO: Use an .envfile and make everyone use it instead
ARG BYOND_BASE_IMAGE=ubuntu:bionic
ARG UTILITY_BASE_IMAGE=alpine:3
ARG PROJECT_NAME=ColonialMarinesALPHA
ARG BYOND_MAJOR=514
ARG BYOND_MINOR=1583
ARG NODE_VERSION=16
ARG PYTHON_VERSION=3.10
ARG BYOND_UID=1000

# BUILD_TYPE=standalone to build with juke in docker
# BUILD_TYPE=deploy to directly use already built local files
ARG BUILD_TYPE=deploy

# Base BYOND image
FROM ${BYOND_BASE_IMAGE} AS byond
SHELL ["/bin/bash", "-c"]
RUN dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y make man curl unzip libssl-dev libssl-dev:i386
ARG BYOND_MAJOR
ARG BYOND_MINOR
ARG BYOND_DOWNLOAD_URL=https://secure.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip
RUN curl ${BYOND_DOWNLOAD_URL} -o byond.zip \
    && unzip byond.zip \
	&& rm -rf byond.zip
WORKDIR /byond
RUN make here

# DM Build Env to be used in particular with juke if not running it locally
FROM byond AS cm-builder
COPY tools/docker/nodesource.gpg /usr/share/keyrings/nodesource.gpg
COPY tools/docker/nodesource.list /etc/apt/sources.list.d/
COPY tools/docker/apt-node-prefs /etc/apt/preferences/
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs yarn g++-multilib
RUN DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/*

# TGUI deps pre-caching, thin out files to serve as basis for layer caching
FROM node:${NODE_VERSION}-buster AS tgui-thin
COPY tgui /tgui
RUN rm -rf docs public
RUN find packages \! -name "package.json" -mindepth 2 -maxdepth 2 -print | xargs rm -rf

# TGUI deps cache layer, actually gets the deps
FROM node:${NODE_VERSION}-buster AS tgui-deps
COPY --from=tgui-thin tgui /tgui
WORKDIR /tgui
RUN yarn install --immutable

# Stage actually building with juke if needed
FROM cm-builder AS cm-build-standalone
RUN mkdir /build
WORKDIR /build
COPY . .
COPY --from=tgui-deps /tgui/.yarn/cache tgui/.yarn/cache
RUN ./tools/docker/juke-build.sh

# Helper Stage just packaging locally provided resources
FROM ${UTILITY_BASE_IMAGE} AS cm-build-deploy
ARG PROJECT_NAME
RUN mkdir /build
WORKDIR /build
COPY tgui/public tgui/public
COPY ${PROJECT_NAME}.dmb ${PROJECT_NAME}.dmb
COPY ${PROJECT_NAME}.rsc ${PROJECT_NAME}.rsc

# Alias for using either of the above
FROM cm-build-${BUILD_TYPE} AS build-results

# Deployment stage, piecing a workable game image
FROM byond AS deploy
ARG PROJECT_NAME
ARG BYOND_UID
ENV DREAMDAEMON_PORT=1400
RUN mkdir -p /cm/data
COPY tools/docker/runner-entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
RUN useradd -u ${BYOND_UID} -ms /bin/bash byond
WORKDIR /cm
COPY librust_g.so .
COPY config config
COPY map_config map_config
COPY strings strings
COPY nano nano
COPY maps maps
COPY --from=build-results /build/tgui/public tgui/public/
COPY --from=build-results /build/${PROJECT_NAME}.dmb application.dmb
COPY --from=build-results /build/${PROJECT_NAME}.rsc application.rsc
RUN chown -R byond:byond /byond /cm /entrypoint.sh
USER ${BYOND_UID}
ENTRYPOINT [ "/entrypoint.sh" ]
