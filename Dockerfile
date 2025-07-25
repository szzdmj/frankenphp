# Stage 1: Base PHP Layer
FROM php:8.3-cli AS base

WORKDIR /app

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        curl ca-certificates libcap2-bin git unzip \
        libargon2-dev libbrotli-dev libcurl4-openssl-dev \
        libonig-dev libreadline-dev libsodium-dev \
        libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/public /config/caddy /data/caddy /etc/caddy /etc/frankenphp
COPY --link caddy/frankenphp/Caddyfile /etc/caddy/Caddyfile
RUN ln -s /etc/caddy/Caddyfile /etc/frankenphp/Caddyfile
ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data
EXPOSE 8085 2019

#############################
# Stage 2: Build FrankenPHP (Debug Version)
#############################
FROM golang:1.24-alpine AS builder

WORKDIR /go/src/app

# Copy only go mod files first for caching
COPY go.mod go.sum ./
RUN go mod download

WORKDIR /go/src/app/caddy
COPY caddy/go.mod caddy/go.sum ./
RUN go mod download

# Copy full source
WORKDIR /go/src/app
COPY . .

# ✅ Confirm go.sh exists and is executable
RUN set -eux && \
    ls -l ./caddy/frankenphp/go.sh && \
    head -n 10 ./caddy/frankenphp/go.sh && \
    chmod +x ./caddy/frankenphp/go.sh

# ✅ Set environment variables safely
ENV PHP_VERSION=8.3 \
    CGO_CFLAGS="-DFRANKENPHP_VERSION=dev $PHP_CFLAGS" \
    CGO_CPPFLAGS=$PHP_CPPFLAGS \
    CGO_LDFLAGS="-L/usr/local/lib -lssl -lcrypto -lreadline -largon2 -lcurl -lonig -lz $PHP_LDFLAGS"

# ✅ Run build script separately to expose errors
WORKDIR /go/src/app/caddy/frankenphp

RUN set -eux && \
    GOBIN=/usr/local/bin \
    ../../caddy/frankenphp/go.sh install \
      -ldflags "-w -s -X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP dev PHP ${PHP_VERSION} Caddy'" \
      -buildvcs=true

# ✅ Run extra steps separately
RUN setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp

RUN cp Caddyfile /etc/frankenphp/Caddyfile

RUN frankenphp version && frankenphp build-info

# Stage 3: Final
FROM base AS final

COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
COPY --from=builder /usr/local/lib/libwatcher* /usr/local/lib/

RUN setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp && \
    frankenphp version && \
    frankenphp build-info

CMD ["--config", "/etc/frankenphp/Caddyfile",]()
