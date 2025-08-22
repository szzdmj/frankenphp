FROM dunglas/frankenphp

COPY public /app/public

# 复制Caddy配置
COPY Caddyfile /etc/frankenphp/Caddyfile

EXPOSE 80
