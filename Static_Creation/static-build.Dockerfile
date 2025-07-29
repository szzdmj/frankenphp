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

# ✅ 在静态资源目录中创建唯一标识文件
RUN echo "# Build ID: $(date -u +%Y%m%d%H%M%S) UTC" >> /app/public/robots.txt

EXPOSE 8080

CMD ["/usr/bin/frankenphp", "run", "--config", "Caddyfile"]

