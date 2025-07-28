#!/bin/bash
set -e

# 编译 linux 下可用的 FrankenPHP 二进制
echo "▶️ 构建 frankenphp..."

GOOS=linux CGO_ENABLED=1 xcaddy build --with github.com/dunglas/frankenphp

echo "✅ 构建完成: ./frankenphp"
