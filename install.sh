#!/bin/bash

set -e

echo "🚀 正在安装 VPS Toolkit..."

INSTALL_DIR="/opt/vps_toolkit"
BIN_PATH="/usr/local/bin/tool"
REPO_URL="https://github.com/zeyu8023/vps_toolkit.git"

# 清理旧版本
rm -rf "$INSTALL_DIR"

# 克隆完整仓库
echo "📥 正在克隆仓库到 $INSTALL_DIR..."
git clone "$REPO_URL" "$INSTALL_DIR"

# 设置权限
chmod +x "$INSTALL_DIR/vps_master.sh"
find "$INSTALL_DIR/modules" -type f -name "*.sh" -exec chmod +x {} \;

# 创建日志目录
mkdir -p "$INSTALL_DIR/logs"
touch "$INSTALL_DIR/logs/vps_toolkit.log"

# 创建快捷命令
echo "🔗 正在创建快捷命令：tool"
ln -sf "$INSTALL_DIR/vps_master.sh" "$BIN_PATH"
chmod +x "$BIN_PATH"

echo ""
echo "✅ 安装完成！你现在可以直接输入以下命令启动工具："
echo ""
echo "   tool"
echo ""
echo "📂 脚本路径：$INSTALL_DIR/vps_master.sh"
echo "📎 快捷命令：$BIN_PATH"
