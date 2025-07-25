# Set working directory before build
WORKDIR /go/src/app/caddy/frankenphp

# Install required build dependencies
RUN apt-get update && apt-get install -y \
    php-dev \
    libbrotli-dev \
    build-essential \
    git \
    pkg-config \
    libcap2-bin \
    && rm -rf /var/lib/apt/lists/*

# Ensure git submodules are initialized (for wtr/watcher-c.h)
RUN git submodule update --init --recursive

# Run the custom build script
RUN set -eux && \
    ls -l ./go.sh && \
    head -n 5 ./go.sh && \
    GOBIN=/usr/local/bin \
    ./go.sh install \
      -ldflags "-w -s -X 'github.com/caddyserver/caddy/v2.CustomVersion=FrankenPHP dev PHP ${PHP_VERSION:-8._
