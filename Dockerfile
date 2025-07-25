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

# Default values to prevent Docker warnings
ENV PHP_CFLAGS=""
ENV PHP_CPPFLAGS=""
ENV PHP_LDFLAGS=""

EXPOSE 8085
EXPOSE 2019

#############################
# Stage 2: Build FrankenPHP
#############################
FROM golang:1.24-alpine AS builder

WORKDIR /go/src/app

COPY go.mod go.sum ./
RUN go mod download

WORKDIR /go/src/app/caddy
COPY caddy/go.mod caddy/go.sum ./
RUN go mod download

WORKDIR /go/src/app
COPY . .

# Adjusted path for go.sh
COPY caddy/frankenphp/go.sh ./caddy/frankenphp/go.sh
RUN chmod +x ./caddy/frankenphp/go.sh

WORKDIR /go/src/app/caddy/frankenphp

ENV CGO_CFLAGS="-DFRANKENPHP_VERSION=dev $PHP_CFLAGS"
ENV CGO_CPPFLAGS=$PHP_CPPFLAGS
ENV CGO_LDFLAGS="-L/usr/local/lib -lssl -lcrypto -lreadline -largon2 -lcurl -lonig -lz $PHP_LDFLAGS"

RUN GOBIN=/usr/local/bin \
    ./go.sh install -ldflags "-w -s -X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP dev PHP $PHP_VERSION Caddy'" -buildvcs=true && \
    setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp && \
    cp Caddyfile /etc/frankenphp/Caddyfile && \
    frankenphp version && \
    frankenphp build-info

#############################
# Stage 3: Final image
##########
