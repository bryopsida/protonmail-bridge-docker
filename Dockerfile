ARG UBUNTU_TAG=latest
FROM ubuntu:${UBUNTU_TAG} AS build

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

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN export PATH="/usr/local/go/bin:$PATH"; \
    /usr/local/go/bin/go version


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
