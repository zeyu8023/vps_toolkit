#!/bin/bash

set -e

echo "🚀 正在安装 VPS Toolkit..."

# 安装路径
INSTALL_DIR="/opt/vps_toolkit"
BIN_PATH="/usr/local/bin/tool"
SCRIPT_URL="https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/vps_master.sh"

# 创建目录
mkdir -p "$INSTALL_DIR"

# 下载主脚本
echo "📥 正在下载脚本到 $INSTALL_DIR..."
curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/vps_master.sh"

# 设置权限
chmod +x "$INSTALL_DIR/vps_master.sh"

# 创建快捷命令
echo "🔗 正在创建快捷命令：tool"
ln -sf "$INSTALL_DIR/vps_master.sh" "$BIN_PATH"
chmod +x "$BIN_PATH"

# 完成提示
echo ""
echo "✅ 安装完成！你现在可以直接输入以下命令启动工具："
echo ""
echo "   tool"
echo ""
echo "📂 脚本路径：$INSTALL_DIR/vps_master.sh"
echo "📎 快捷命令：$BIN_PATH"
