FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-mysql \
    php-sqlite3 \
    php-pdo \
    php-gd \
    php-opcache \
    && rm -rf /var/lib/apt/lists/*

COPY ./frankenphp /usr/bin/frankenphp
WORKDIR /app/public

CMD ["frankenphp", "--config", "Caddyfile"]
