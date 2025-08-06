FROM dunglas/frankenphp

# Copy your app
COPY Static_Creation/public /app
COPY /app/Caddyfile /etc/frankenphp/Caddyfile

# Copy xcaddy modules
RUN XCADDY_ARGS="--with github.com/caddyserver/cache-handler --with github.com/caddy-dns/cloudflare"

EXPOSE 80 
