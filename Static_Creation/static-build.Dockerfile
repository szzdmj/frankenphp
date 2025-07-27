FROM --platform=linux/amd64 dunglas/frankenphp:static-builder

# 拷贝你的静态站点和示例 index.php, Caddyfile
COPY Static_Creation/public /go/src/app/dist/app

WORKDIR /go/src/app
# 嵌入 PHP 应用并构建 FrankenPHP 二进制
RUN FRANKENPHP_VERSION=1.1.2 EMBED=dist/app/ PHP_EXTENSIONS=ctype,pdo_sqlite ./build-static.sh

# 最终镜像只需拷贝二进制
FROM scratch
COPY --from=0 /go/src/app/dist/frankenphp-linux-x86_64 /usr/local/bin/frankenphp
CMD ["/usr/local/bin/frankenphp", "php-server"]
