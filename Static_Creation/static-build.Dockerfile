# syntax=docker/dockerfile:1
FROM ghcr.io/dunglas/frankenphp:latest

WORKDIR /app

# Copy the public directory into the container
COPY ./public /app/public

# Optional: create a visible build-time marker file
RUN echo "📦 Build complete: $(date)" > /app/public/__build_time.txt

# Optional: create a basic debug PHP file to test PHP execution
RUN echo "<?php echo '<pre>cwd: ' . getcwd() . '\n'; print_r(scandir('.'));" > /app/public/__debug.php

# Use a shell-based CMD so we can log directory listing before starting frankenphp
CMD ["/bin/sh", "-c", "\
  echo '📅 Container started at: $(date)'; \
  echo '📁 Listing /app/public:'; \
  ls -al /app/public; \
  echo '🚀 Starting frankenphp...'; \
  frankenphp -c /app/public/Caddyfile \
"]
