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

COPY ./ /usr/bin/frankenphp
WORKDIR /app/public

# ✅ 正确顺序：先复制 public，再修改
COPY ./public /app/public
COPY ./public/Caddyfile /etc/caddy/Caddyfile

# ✅ 修改 robots.txt（不能放在 COPY 之前）
RUN echo "# Build at $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> /app/public/robots.txt

EXPOSE 8080

CMD ["/usr/bin/frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
