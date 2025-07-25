# syntax=docker/dockerfile:1

#############################
# Stage 1: Common base (PHP setup)
#############################
FROM php:8.3-cli AS base

WORKDIR /app

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        curl \
        ca-certificates \
        libcap2-bin \
        git \
        unzip \
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
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
        /app/public \
        /config/caddy \
        /data/caddy \
        /etc/caddy \
        /etc/frankenphp && \
    echo '<?php phpinfo();' > /app/public/index.php

COPY --link caddy/frankenphp/Caddyfile /etc/caddy/Caddyfile
RUN ln -s /etc/caddy/Caddyfile /etc/frankenphp/Caddyfile

ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data

EXPOSE 8085
EXPOSE 2019

#############################
# Stage 2: Build FrankenPHP (uses Go 1.24+)
#############################
FROM golang:1.24-bullseye AS builder

WORKDIR /go/src/app

# Pre-fetch module dependencies
COPY go.mod go.sum ./
RUN go mod download

# Caddy-specific Go modules
WORKDIR /go/src/app/caddy
COPY caddy/go.mod caddy/go.sum ./
RUN go mod download

# Copy entire project including go.sh
WORKDIR /go/src/app
COPY . .

# Ensure go.sh is executable
RUN chmod +x ./caddy/frankenphp/go.sh

# Set up environment and build
WORKDIR /go/src/app/caddy/frankenphp
RUN set -eux && \
    ls -l ./go.sh && \
    head -n 5 ./go.sh && \
    GOBIN=/usr/local/bin \
    ./go.sh install \
      -ldflags "-w -s -X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP dev PHP ${PHP_VERSION:-8.3} Caddy'" \
      -buildvcs=true && \
    setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp && \
    cp Caddyfile /etc/frankenphp/Caddyfile && \
    frankenphp version && \
    frankenphp build-info

#############################
# Stage 3: Final image
#############################
FROM base AS final

COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
COPY --from=builder /usr/local/lib/libwatcher* /usr/local/lib/

RUN setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp && \
    frankenphp version && \
    frankenphp build-info

CMD ["frankenphp", "--config", "/etc/frankenphp/Caddyfile", "--adapter", "caddyfile"]

HEALTHCHECK CMD curl -f http://localhost:2019/metrics || exit 1
