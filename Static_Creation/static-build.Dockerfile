FROM dunglas/frankenphp

# 复制静态资源到 /app (或 /app/public 视你的 Caddyfile 决定)
COPY public /app/public

# 复制Caddy配置
COPY Caddyfile /etc/frankenphp/Caddyfile

EXPOSE 80
