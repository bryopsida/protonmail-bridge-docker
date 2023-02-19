ARG GO_BUILD_TAG=latest
ARG UBUNTU_TAG=latest
# Use carlosedp/golang for riscv64 support
FROM carlosedp/golang:${GO_BUILD_TAG} AS build

# Install dependencies
RUN apt-get update && apt-get install -y git build-essential libsecret-1-dev

# Build
WORKDIR /build/
COPY build.sh VERSION /build/
RUN bash build.sh

FROM ubuntu:${UBUNTU_TAG}

EXPOSE 25/tcp
EXPOSE 143/tcp

# Install dependencies and protonmail bridge
RUN apt-get update \
    && apt-get install -y --no-install-recommends socat pass libsecret-1-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy bash scripts
COPY gpgparams entrypoint.sh /protonmail/

# Copy protonmail
COPY --from=build /build/proton-bridge/bridge /protonmail/
COPY --from=build /build/proton-bridge/proton-bridge /protonmail/

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]
