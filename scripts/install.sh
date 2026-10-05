#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "========================================="
echo "  HarborAPI 一键部署脚本"
echo "========================================="
echo ""

# 检查依赖
command -v docker >/dev/null 2>&1 || { echo "❌ 需要 Docker，请先安装"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1 || { echo "❌ 需要 Docker Compose"; exit 1; }

COMPOSE_CMD="docker compose"
docker-compose version >/dev/null 2>&1 && COMPOSE_CMD="docker-compose"

# 检查 .env 文件
if [[ ! -f .env ]]; then
    echo "📝 未找到 .env 文件，正在生成..."
    ./scripts/generate-secrets.sh
    echo ""
    echo "⚠️  请编辑 .env 文件，至少设置 DOMAIN 变量"
    echo "   nano .env"
    echo ""
    echo "设置完成后，重新运行此脚本继续部署。"
    exit 0
fi

# 加载环境变量检查
source .env

if [[ -z "${POSTGRES_PASSWORD:-}" ]] || [[ -z "${REDIS_PASSWORD:-}" ]] || \
   [[ -z "${JWT_SECRET:-}" ]] || [[ -z "${SESSION_SECRET:-}" ]] || \
   [[ -z "${TOTP_ENCRYPTION_KEY:-}" ]]; then
    echo "❌ .env 中的密钥未设置完整"
    echo "   运行 ./scripts/generate-secrets.sh 自动生成"
    exit 1
fi

echo "✅ 环境配置检查通过"
echo ""

# 拉取镜像
echo "📥 拉取 Docker 镜像..."
$COMPOSE_CMD pull

# 启动服务
echo ""
echo "🚀 启动服务..."
$COMPOSE_CMD up -d

# 等待健康检查
echo ""
echo "⏳ 等待服务健康检查..."
sleep 5

MAX_WAIT=60
ELAPSED=0
while [[ $ELAPSED -lt $MAX_WAIT ]]; do
    if $COMPOSE_CMD ps | grep -q "healthy"; then
        ALL_HEALTHY=true
        for service in postgres redis sub2api new-api; do
            if ! $COMPOSE_CMD ps "$service" | grep -q "healthy"; then
                ALL_HEALTHY=false
                break
            fi
        done

        if [[ "$ALL_HEALTHY" == true ]]; then
            echo "✅ 所有服务已就绪"
            break
        fi
    fi

    sleep 3
    ELAPSED=$((ELAPSED + 3))
done

if [[ $ELAPSED -ge $MAX_WAIT ]]; then
    echo "⚠️  部分服务可能未就绪，请检查日志："
    echo "   $COMPOSE_CMD logs"
fi

echo ""
echo "========================================="
echo "  🎉 HarborAPI 部署完成！"
echo "========================================="
echo ""
echo "📍 访问地址："
echo "   • API 网关:   https://${DOMAIN:-localhost}"
echo "   • 管理后台:   https://${DOMAIN:-localhost}/admin"
echo ""
echo "📋 常用命令："
echo "   • 查看日志:   $COMPOSE_CMD logs -f [service]"
echo "   • 停止服务:   $COMPOSE_CMD stop"
echo "   • 重启服务:   $COMPOSE_CMD restart [service]"
echo "   • 更新服务:   ./scripts/update.sh [new-api|sub2api]"
echo ""
echo "💡 首次访问时，请在 Web UI 中完成初始化设置。"
echo ""
