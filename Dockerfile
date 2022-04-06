# TODO: Use an .envfile and make everyone use it instead
ARG BYOND_BASE_IMAGE=i386/ubuntu:bionic
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
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y make man curl unzip libssl-dev:i386
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
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*

# Stage actually building with juke if needed
FROM cm-builder AS cm-build-standalone
RUN mkdir /build
WORKDIR /build
COPY . .
RUN ./tools/build/build

# Helper Stage just packaging locally provided resources
FROM ${UTILITY_BASE_IMAGE} AS cm-build-deploy
RUN mkdir /build
WORKDIR /build
COPY tgui/public tgui/public
COPY ${PROJECT_NAME}.dmb ${PROJECT_NAME}.dmb
COPY ${PROJECT_NAME}.rsc ${PROJECT_NAME}.rsc

# Deployment stage, piecing a workable game image
FROM byond AS deploy
ENV DREAMDAEMON_PORT=1400
RUN mkdir -p /cm/data
COPY tools/runner-entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
RUN useradd -u ${BYOND_UID} -ms /bin/bash byond
WORKDIR /cm
COPY librust_g.so .
COPY config config
COPY map_config map_config
COPY strings strings
COPY nano nano
COPY maps maps
COPY --from=cm-build-${BUILD_TYPE} /build/tgui/public tgui/public/
COPY --from=cm-build-${BUILD_TYPE} /build/ColonialMarinesALPHA.dmb application.dmb
COPY --from=cm-build-${BUILD_TYPE} /build/ColonialMarinesALPHA.rsc application.rsc
RUN chown -R byond:byond /byond /cm /entrypoint.sh
USER ${BYOND_UID}
ENTRYPOINT [ "/entrypoint.sh" ]
