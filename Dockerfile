# syntax=docker/dockerfile:1
# checkov:skip=CKV_DOCKER_2
# checkov:skip=CKV_DOCKER_3
# checkov:skip=CKV_DOCKER_7

#############################
# Stage 1: Common base (PHP setup)
#############################
FROM php-base AS common
FROM php:8.3-cli AS common
#############################
# Stage 2: Golang toolchain for building (Debian-based)
#############################
FROM golang:1.24 AS golang-base
WORKDIR /app

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        mailcap \
        libcap2-bin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p \
        /app/public \
        /config/caddy \
        /data/caddy \
        /etc/caddy \
        /etc/frankenphp; \
    sed -i 's/php/frankenphp run/g' /usr/local/bin/docker-php-entrypoint; \
    echo '<?php phpinfo();' > /app/public/index.php

COPY --link caddy/frankenphp/Caddyfile /etc/caddy/Caddyfile
RUN ln /etc/caddy/Caddyfile /etc/frankenphp/Caddyfile && \
    curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions

CMD ["--config", "/etc/frankenphp/Caddyfile", "--adapter", "caddyfile"]
HEALTHCHECK CMD curl -f http://localhost:2019/metrics || exit 1

ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data

EXPOSE 8085
EXPOSE 2019

LABEL org.opencontainers.image.title=FrankenPHP
LABEL org.opencontainers.image.description="The modern PHP app server"
LABEL org.opencontainers.image.url=https://frankenphp.dev
LABEL org.opencontainers.image.source=https://github.com/php/frankenphp
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.vendor="Kévin Dunglas"

#############################
# Stage 3: Builder
#############################
FROM common AS builder

ARG FRANKENPHP_VERSION='dev'
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy Go toolchain from golang-base
COPY --from=golang-base /usr/local/go /usr/local/go

ENV PATH=/usr/local/go/bin:$PATH
ENV GOTOOLCHAIN=local

# Install build dependencies
RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        cmake \
        git \
        libargon2-dev \
        libbrotli-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libreadline-dev \
        libsodium-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        zlib1g-dev && \
    apt-get clean

# Install file watcher
WORKDIR /usr/local/src/watcher
RUN --mount=type=secret,id=github-token \
    if [ -f /run/secrets/github-token ] && [ -s /run/secrets/github-token ]; then \
        curl -s -H "Authorization: Bearer $(cat /run/secrets/github-token)" https://api.github.com/repos/e-dant/watcher/releases/latest; \
    else \
        curl -s https://api.github.com/repos/e-dant/watcher/releases/latest; \
    fi | \
    grep tarball_url | \
    awk '{ print $2 }' | \
    sed 's/,$//' | sed 's/"//g' | \
    xargs curl -L | \
    tar xz --strip-components 1 && \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build && \
    cmake --install build && \
    ldconfig

# Prepare Go modules
WORKDIR /go/src/app
COPY --link go.mod go.sum ./
RUN go mod download

WORKDIR /go/src/app/caddy
COPY --link caddy/go.mod caddy/go.sum ./
RUN go mod download

# Copy source code
WORKDIR /go/src/app
COPY --link . ./

ENV CGO_CFLAGS="-DFRANKENPHP_VERSION=$FRANKENPHP_VERSION $PHP_CFLAGS"
ENV CGO_CPPFLAGS=$PHP_CPPFLAGS
ENV CGO_LDFLAGS="-L/usr/local/lib -lssl -lcrypto -lreadline -largon2 -lcurl -lonig -lz $PHP_LDFLAGS"

# Build FrankenPHP binary
WORKDIR /go/src/app/caddy/frankenphp
RUN GOBIN=/usr/local/bin \
    ../../go.sh install -ldflags "-w -s -X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP $FRANKENPHP_VERSION PHP $PHP_VERSION Caddy'" -buildvcs=true && \
    setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp && \
    cp Caddyfile /etc/frankenphp/Caddyfile && \
    frankenphp version && \
    frankenphp build-info

#############################
# Stage 4: Final runtime
#############################
FROM common AS runner

ENV GODEBUG=cgocheck=0

# Copy shared libraries for watcher
COPY --from=builder /usr/local/lib/libwatcher* /usr/local/lib/
RUN apt-get install -y --no-install-recommends libstdc++6 && \
    apt-get clean && \
    ldconfig

# C
