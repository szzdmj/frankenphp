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
RUN echo '#!/bin/sh
echo "=== STARTING CONTAINER ==="
date -u
echo "--- /usr/bin/frankenphp ---"
ls -la /usr/bin/frankenphp
echo "--- /app/public/Caddyfile ---"
ls -la /app/public/Caddyfile
echo "--- checking if 8080 is listening ---"
netstat -tuln
echo "--- process list ---"
ps aux
echo "--- running frankenphp ---"
/usr/bin/frankenphp run --config /app/public/Caddyfile
' > /start.sh && chmod +x /start.sh

EXPOSE 8080

# ✅ 强制执行调试脚本，确保命令不会被 Cloudflare 忽略
ENTRYPOINT ["/start.sh"]
