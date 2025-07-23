# syntax=docker/dockerfile:1

#############################
# Stage 1: PHP base setup
#############################
FROM php:8.3-zts-bookworm AS php-base

# Install common PHP dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        libcap2-bin \
        mailcap && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN mkdir -p \
        /app/public \
        /config/caddy \
        /data/caddy \
        /etc/caddy \
        /etc/frankenphp && \
    echo '<?php phpinfo();' > /app/public/index.php && \
    ([ -f /usr/local/bin/docker-php-entrypoint ] && \
        sed -i 's/php/frankenphp run/g' /usr/local/bin/docker-php-entrypoint || true)

COPY --link caddy/frankenphp/Caddyfile /etc/caddy/Caddyfile
RUN ln -s /etc/caddy/Caddyfile /etc/frankenphp/Caddyfile && \
    curl -sSLf -o /usr/local/bin/install-php-extensions \
    https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions

CMD ["--config", "/etc/frankenphp/Caddyfile", "--adapter", "caddyfile"]
HEALTHCHECK CMD curl -f http://localhost:2019/metrics || exit 1

EXPOSE 8085
EXPOSE 2019

ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data


#############################
# Stage 2: Go toolchain base
#############################
FROM golang:1.24 AS golang-base


#############################
# Stage 3: Builder (FrankenPHP binary + watcher)
#############################
FROM php-base AS franken-builder

ARG FRANKENPHP_VERSION='dev'
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy Go toolchain
COPY --from=golang-base /usr/local/go /usr/local/go
ENV PATH=/usr/local/go/bin:$PATH
ENV GOTOOLCHAIN=local

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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

# Install e-dant/watcher (shared library)
WORKDIR /usr/local/src/watcher
RUN curl -s https://api.github.com/repos/e-dant/watcher/releases/latest | \
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

# Copy application source code
WORKDIR /go/src/app
COPY --link . ./

# Build FrankenPHP binary
ENV CGO_CFLAGS="-DFRANKENPHP_VERSION=$FRANKENPHP_VERSION $PHP_CFLAGS"
ENV CGO_CPPFLAGS=$PHP_CPPFLAGS
ENV CGO_LDFLAGS="-L/usr/local/lib -lssl -lcrypto -lreadline -largon2 -lcurl -lonig -lz $PHP_LDFLAGS"

WORKDIR /go/src/app/caddy/frankenphp
RUN GOBIN=/usr/local/bin \
    ../../go.sh install -ldflags "-w -s -X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP $FRANKENPHP_VERSION PHP $PHP_VERSION Caddy'" -buildvcs=true && \
    setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp && \
    cp Caddyfile /etc/frankenphp/Caddyfile && \
    frankenphp version && \
    frankenphp build-info


#############################
# Stage 4: Runtime
#############################
FROM php-base AS php-runner

ENV GODEBUG=cgocheck=0

# Copy watcher shared library
COPY --from=franken-builder /usr/local/lib/libwatcher* /usr/local/lib/
RUN apt-get install -y --no-install-recommends libstdc++6 && \
    apt-get clean && \
    ldconfig

# Copy the FrankenPHP binary
COPY --from=franken-builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
RUN setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp && \
    frankenphp version && \
    frankenphp build-info
