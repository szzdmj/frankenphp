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

# ⬇️ 自行构建的 frankenphp 可执行文件复制
COPY ./ /usr/bin/frankenphp

WORKDIR /app/public

# ⬇️ 添加调试辅助文件
RUN echo "📦 Build complete: $(date)" > /app/public/__build_time.txt && \
    echo "<?php echo '<pre>cwd: ' . getcwd() . '\n'; print_r(scandir('.'));" > /app/public/__debug.php

COPY ./public /app/public
COPY ./public/Caddyfile /etc/caddy/Caddyfile

EXPOSE 8080

# ✅ 保持原有启动命令不变
CMD ["/usr/bin/frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
