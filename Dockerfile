# ----------------------------
# Stage 1: Build FrankenPHP
# ----------------------------
FROM golang:1.22 AS builder

ENV PHP_VERSION=8.3

# Install PHP and build tools
RUN apt-get update && apt-get install -y \
  php${PHP_VERSION}-dev \
  libbrotli-dev \
  build-essential \
  git \
  pkg-config \
  libcap2-bin \
  php-cli \
  php-curl \
  php-mbstring \
  unzip \
  && rm -rf /var/lib/apt/lists/*

# Clone FrankenPHP
WORKDIR /src
RUN git clone --recursive https://github.com/dunglas/frankenphp.git .

# Build
WORKDIR /src/caddy/frankenphp
RUN ./go.sh install \
  -ldflags "-w -s -X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP dev PHP ${PHP_VERSION} Caddy'" \
  -buildvcs=true

# ----------------------------
# Stage 2: Final image
# ----------------------------
FROM debian:bookworm-slim

# Copy built binary
COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
COPY --from=builder /src/Caddyfile /etc/frankenphp/Caddyfile

EXPOSE 80
CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]
