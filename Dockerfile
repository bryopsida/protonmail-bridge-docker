ARG UBUNTU_TAG=latest
ARG BUILD_BASE=ubuntu
ARG RUNTIME_BASE=ubuntu

FROM ${BUILD_BASE}:${UBUNTU_TAG} AS build

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        golang \
        ca-certificates \
        curl \
        libc6 \
        git \
        build-essential \
        libsecret-1-dev

# Build
WORKDIR /build/
COPY build.sh /build/
RUN bash build.sh

FROM ${RUNTIME_BASE}:${UBUNTU_TAG}

EXPOSE 25/tcp
EXPOSE 143/tcp

# Install dependencies and protonmail bridge
RUN apt-get update \
    && apt-get install -y --no-install-recommends socat pass libsecret-1-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 10001 proton \
    && useradd --uid 10001 --gid proton --shell /bin/bash --create-home proton

USER proton

# Copy bash scripts
COPY gpgparams entrypoint.sh /protonmail/

# Copy protonmail
COPY --from=build /build/proton-bridge/bridge /protonmail/
COPY --from=build /build/proton-bridge/proton-bridge /protonmail/

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]
