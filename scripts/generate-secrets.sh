#!/usr/bin/env bash
set -euo pipefail

# 生成随机密钥的辅助函数
generate_secret() {
    local length=$1
    openssl rand -base64 48 | tr -d '/+=' | head -c "$length"
}

ENV_FILE="${1:-.env}"

if [[ -f "$ENV_FILE" ]]; then
    echo "⚠️  $ENV_FILE 已存在，将会更新空白的密钥字段（已有值不会被覆盖）"
    source "$ENV_FILE"
else
    echo "📝 创建新的 $ENV_FILE"
    cp .env.example "$ENV_FILE"
fi

# 生成缺失的密钥
MODIFIED=false

if [[ -z "${POSTGRES_PASSWORD:-}" ]]; then
    echo "🔐 生成 POSTGRES_PASSWORD"
    sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$(generate_secret 32)|" "$ENV_FILE"
    MODIFIED=true
fi

if [[ -z "${REDIS_PASSWORD:-}" ]]; then
    echo "🔐 生成 REDIS_PASSWORD"
    sed -i "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=$(generate_secret 32)|" "$ENV_FILE"
    MODIFIED=true
fi

if [[ -z "${JWT_SECRET:-}" ]]; then
    echo "🔐 生成 JWT_SECRET"
    sed -i "s|^JWT_SECRET=.*|JWT_SECRET=$(generate_secret 48)|" "$ENV_FILE"
    MODIFIED=true
fi

if [[ -z "${TOTP_ENCRYPTION_KEY:-}" ]]; then
    echo "🔐 生成 TOTP_ENCRYPTION_KEY（固定 32 字符）"
    sed -i "s|^TOTP_ENCRYPTION_KEY=.*|TOTP_ENCRYPTION_KEY=$(generate_secret 32)|" "$ENV_FILE"
    MODIFIED=true
fi

if [[ -z "${SESSION_SECRET:-}" ]]; then
    echo "🔐 生成 SESSION_SECRET"
    sed -i "s|^SESSION_SECRET=.*|SESSION_SECRET=$(generate_secret 64)|" "$ENV_FILE"
    MODIFIED=true
fi

if [[ "$MODIFIED" == true ]]; then
    echo ""
    echo "✅ 密钥已生成并保存到 $ENV_FILE"
    echo "⚠️  请妥善保管此文件，不要提交到 Git"
    echo ""
    echo "📋 下一步："
    echo "   1. 编辑 $ENV_FILE，设置 DOMAIN 为你的域名"
    echo "   2. （可选）设置 ADMIN_EMAIL 和 ADMIN_PASSWORD"
    echo "   3. 运行 ./scripts/install.sh 开始部署"
else
    echo "✅ 所有密钥已设置，无需生成"
fi
