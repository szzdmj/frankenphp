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

# ✅ 复制 frankenphp 二进制到指定位置
COPY ./ /usr/bin/frankenphp

# ✅ 设置工作目录
WORKDIR /app/public

# ✅ 复制静态资源和 Caddyfile
COPY ./public /app/public
COPY ./public/Caddyfile /app/public/Caddyfile

# ✅ 添加调试脚本作为启动入口
RUN echo '#!/bin/sh\n\
echo "=== STARTING CONTAINER ==="\n\
date -u\n\
echo "--- /usr/bin/frankenphp ---"\n\
ls -l /usr/bin/frankenphp\n\
echo "--- php -v ---"\n\
php -v\n\
exec /usr/bin/frankenphp' > /entrypoint.sh \
  && chmod +x /entrypoint.sh

EXPOSE 8080

# ✅ 强制执行调试脚本，确保命令不会被 Cloudflare 忽略
ENTRYPOINT ["/start.sh"]
