# syntax=docker/dockerfile:1

FROM golang:1.24-alpine AS build

ENV GOTOOLCHAIN=local
ENV CFLAGS="-ggdb3"
ENV PHPIZE_DEPS="\
	autoconf \
	dpkg-dev \
	file \
	g++ \
	gcc \
	libc-dev \
	make \
	pkgconfig \
	re2c"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache \
	$PHPIZE_DEPS \
	argon2-dev \
	brotli-dev \
	curl-dev \
	oniguruma-dev \
	readline-dev \
	libsodium-dev \
	sqlite-dev \
	openssl-dev \
	libxml2-dev \
	zlib-dev \
	bison \
	nss-tools \
	# file watcher
	libstdc++ \
	linux-headers \
	# Dev tools \
	git \
	clang \
	cmake \
	llvm \
	gdb \
	valgrind \
	neovim \
	zsh \
	libtool && \
	echo 'set auto-load safe-path /' > /root/.gdbinit
WORKDIR /usr/local/src/php
RUN git clone --branch=PHP-8.4 https://github.com/php/php-src.git . && \
	# --enable-embed is only necessary to generate libphp.so, we don't use this SAPI directly
	./buildconf --force && \
	EXTENSION_DIR=/usr/lib/frankenphp/modules ./configure \
		--enable-embed \
		--enable-zts \
		--disable-zend-signals \
		--enable-zend-max-execution-timers \
		--with-config-file-path=/etc/frankenphp/php.ini \
		--with-config-file-scan-dir=/etc/frankenphp/php.d \
		--enable-debug && \
	make -j"$(nproc)" && \
	make install && \
	ldconfig /etc/ld.so.conf.d && \
		mkdir -p /etc/frankenphp/php.d && \
			cp php.ini-development /etc/frankenphp/php.ini && \
			echo "zend_extension=opcache.so" >> /etc/frankenphp/php.ini && \
			echo "opcache.enable=1" >> /etc/frankenphp/php.ini && \
	php --version

# Install e-dant/watcher (necessary for file watching)
WORKDIR /usr/local/src/watcher
RUN git clone https://github.com/e-dant/watcher . && \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
	cmake --build build/ && \
	cmake --install build

# Set destination for COPY
WORKDIR /go/src/app/frankenphp
RUN git clone https://github.com/szzdmj/frankenphp .
WORKDIR /go/src/app/frankenphp/caddy/frankenphp
RUN ../../go.sh build -buildvcs=false

# Download any Go modules
# WORKDIR /go/src/app
# COPY container_src/go.mod ./
# RUN go mod download

# Copy container source code
COPY container_src/ ./
COPY Caddyfile /etc/frankenphp/Caddyfile

# Build
# RUN CGO_ENABLED=0 GOOS=linux go build -o /server
# Copy xcaddy modules
RUN XCADDY_ARGS="--with github.com/caddyserver/cache-handler --with github.com/caddy-dns/cloudflare"


FROM scratch
# COPY --from=build /server /server
EXPOSE 80

# Run
WORKDIR /go/src/app
# CMD ["/server"]&& \
CMD [ "zsh" ]
