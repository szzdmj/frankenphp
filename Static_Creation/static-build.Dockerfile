FROM dunglas/frankenphp
COPY public /app
COPY Caddyfile /etc/frankenphp/Caddyfile
EXPOSE 80
