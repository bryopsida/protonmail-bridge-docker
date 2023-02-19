ARG BUILD_TAG=latest
ARG RUNTIME_TAG=latest
ARG BUILD_BASE=alpine
ARG RUNTIME_BASE=alpine

FROM ${BUILD_BASE}:${BUILD_TAG} AS build
ENV BRIDGE_VERSION=2.4.8

RUN apk add --no-cache \
  make \ 
  musl-dev \
  libc-dev \
  git \
  go \
  gcc \
  g++ \
  pkgconfig \
  bash \
  libsecret \
  libc6-compat \
  gcompat \
  curl \
  libsecret-dev \
  protobuf \
  protobuf-dev \
  build-base

ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# Install dependencies
# RUN apt-get update && \
#     apt-get install -y \
#         golang \
#         ca-certificates \
#         curl \
#         libc6 \
#         git \
#         build-essential \
#         libsecret-1-dev

# Build
WORKDIR /build/

# Clone new code
RUN git clone https://github.com/ProtonMail/proton-bridge.git && \
    cd proton-bridge && \
    git checkout v$BRIDGE_VERSION && \
    make build-nogui

FROM ${RUNTIME_BASE}:${RUNTIME_TAG}

EXPOSE 2025/tcp
EXPOSE 20143/tcp

# Install dependencies and protonmail bridge
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends socat pass libsecret-1-0 ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

RUN apk add --no-cache bash socat libsecret gcompat libc6-compat

# RUN groupadd --gid 10001 proton \
#     && useradd --uid 10001 --gid proton --shell /bin/bash --create-home proton

RUN addgroup -g 10001 proton && \
  adduser -u 10001 -G proton -h /home/proton -D proton

USER proton
WORKDIR /home/proton

# Copy bash scripts
COPY gpgparams .
COPY entrypoint.sh .

# Copy protonmail
COPY --from=build /build/proton-bridge/bridge .
COPY --from=build /build/proton-bridge/proton-bridge .

CMD ["bash", "/home/proton/entrypoint.sh"]
