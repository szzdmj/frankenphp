FROM dunglas/frankenphp

# Copy your app
COPY /public /app
COPY Caddyfile /etc/frankenphp/Caddyfile

# Copy xcaddy modules
RUN XCADDY_ARGS="--with github.com/caddyserver/cache-handler --with github.com/caddy-dns/cloudflare"

EXPOSE 80 
