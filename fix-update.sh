#!/bin/sh
# Open-Box 一键修复更新脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/georgezhou2024/Open-box-/main/fix-update.sh | sh
# 功能: 绕过组件更新模式(node段错误时的死循环),强制完整包更新到最新版

set -e

echo "===== Open-Box 一键修复更新 ====="
echo ""

# 1. 杀掉卡住的更新进程
echo "[1/4] 清理卡住的更新进程..."
killall update.sh 2>/dev/null && echo "  已杀掉旧更新进程" || echo "  没有卡住的进程"
killall -9 node 2>/dev/null || true

sleep 1

# 2. 绕过组件更新模式(关键: node 坏了就别让它拼包)
echo "[2/4] 绕过组件更新模式,强制完整包下载..."
COMPONENT_SCRIPT="/opt/open-box/panel/server/system/update-components.sh"
if [ -f "$COMPONENT_SCRIPT" ]; then
  mv "$COMPONENT_SCRIPT" "${COMPONENT_SCRIPT}.bak"
  echo "  已改名 $COMPONENT_SCRIPT -> .bak"
else
  echo "  组件脚本不存在,已经是完整包模式"
fi

# 3. 选择通道: 先试直连,失败换镜像
echo "[3/4] 检测下载通道..."
CHANNEL=""

# 测试直连
if curl -fsSL --connect-timeout 8 https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/update.sh -o /dev/null 2>/dev/null; then
  CHANNEL="direct"
  echo "  GitHub 直连可用"
else
  echo "  直连不通,尝试镜像..."
  if curl -fsSL --connect-timeout 8 https://ghfast.top/https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/update.sh -o /dev/null 2>/dev/null; then
    CHANNEL="mirror"
    echo "  ghfast.top 镜像可用"
  else
    echo "  错误: 两个通道都连不上,请检查网络"
    exit 1
  fi
fi

# 4. 执行更新
echo "[4/4] 开始更新..."
echo ""

if [ "$CHANNEL" = "direct" ]; then
  curl -fsSL https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/update.sh | sh
else
  curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/update.sh | sh -s -- --mirror
fi

echo ""
echo "===== 更新完成 ====="
echo "面板地址: http://$(ip addr show br-lan | grep 'inet ' | awk '{print $2}' | cut -d/ -f1):2026"
echo "查看密码: open-box password"
