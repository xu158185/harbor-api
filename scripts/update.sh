#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

SERVICE="${1:-}"

if [[ -z "$SERVICE" ]]; then
    echo "用法: $0 <new-api|sub2api|all>"
    echo ""
    echo "示例:"
    echo "  $0 new-api      # 只更新 new-api"
    echo "  $0 sub2api      # 只更新 sub2api"
    echo "  $0 all          # 更新所有服务"
    exit 1
fi

COMPOSE_CMD="docker compose"
docker-compose version >/dev/null 2>&1 && COMPOSE_CMD="docker-compose"

update_service() {
    local svc=$1
    local container="harbor-${svc}"

    echo "========================================="
    echo "  更新 $svc"
    echo "========================================="

    # 拉取最新镜像
    echo "📥 拉取最新镜像..."
    $COMPOSE_CMD pull "$svc"

    # 健康检查前的状态
    echo "🔍 检查当前状态..."
    if ! $COMPOSE_CMD ps "$svc" | grep -q "Up"; then
        echo "⚠️  服务当前未运行，直接启动新版本"
        $COMPOSE_CMD up -d "$svc"
        return 0
    fi

    # 重启服务
    echo "🔄 重启服务..."
    $COMPOSE_CMD up -d --force-recreate --no-deps "$svc"

    # 等待健康检查
    echo "⏳ 等待健康检查..."
    sleep 5

    MAX_WAIT=30
    ELAPSED=0
    while [[ $ELAPSED -lt $MAX_WAIT ]]; do
        if $COMPOSE_CMD ps "$svc" | grep -q "healthy\|Up"; then
            echo "✅ $svc 更新成功"
            $COMPOSE_CMD logs --tail=20 "$svc"
            return 0
        fi

        if $COMPOSE_CMD ps "$svc" | grep -qE "Restarting|Exited"; then
            echo "❌ $svc 启动失败，尝试回滚"
            $COMPOSE_CMD logs --tail=50 "$svc"
            echo ""
            echo "请检查日志并修复问题后重试"
            return 1
        fi

        sleep 2
        ELAPSED=$((ELAPSED + 2))
    done

    echo "⚠️  健康检查超时，请手动检查日志"
    $COMPOSE_CMD logs --tail=50 "$svc"
    return 1
}

case "$SERVICE" in
    new-api)
        update_service "new-api"
        ;;
    sub2api)
        update_service "sub2api"
        ;;
    all)
        update_service "sub2api"
        echo ""
        update_service "new-api"
        ;;
    *)
        echo "❌ 未知服务: $SERVICE"
        echo "   支持的服务: new-api, sub2api, all"
        exit 1
        ;;
esac

echo ""
echo "🎉 更新完成"
