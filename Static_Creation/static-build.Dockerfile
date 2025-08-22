FROM dunglas/frankenphp

# 复制静态资源到容器
COPY public /app
COPY Caddyfile /etc/frankenphp/Caddyfile

# 可选：xcaddy modules（如不需可省略）
RUN XCADDY_ARGS="--with github.com/caddyserver/cache-handler --with github.com/caddy-dns/cloudflare"

EXPOSE 80
