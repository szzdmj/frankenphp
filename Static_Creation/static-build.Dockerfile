FROM dunglas/frankenphp:static-builder-gnu

# Copy your app
WORKDIR /go/src/app/dist/app
COPY Static_Creation .

# Build the static binary
WORKDIR /go/src/app/
RUN EMBED=dist/app/ \
    XCADDY_ARGS="--with github.com/caddyserver/cache-handler --with github.com/caddy-dns/cloudflare" \
    ./build-static.sh
