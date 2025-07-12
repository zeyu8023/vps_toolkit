#!/bin/bash
# 🚀 VPS Toolkit 安装脚本 | By XIAOYU

INSTALL_DIR="/opt/vps_toolkit"
MODULE_DIR="$INSTALL_DIR/modules"
LOG_DIR="$INSTALL_DIR/logs"

echo "📦 正在安装 VPS Toolkit 到 $INSTALL_DIR..."
mkdir -p "$MODULE_DIR" "$LOG_DIR"

# ✅ 下载主脚本
curl -sSL https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/vps_master.sh -o "$INSTALL_DIR/vps_master.sh"

# ✅ 下载所有模块
for file in system_info.sh network_tools.sh docker_tools.sh memory_tools.sh swap_tools.sh install_tools.sh log_tools.sh; do
  curl -sSL "https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/modules/$file" -o "$MODULE_DIR/$file"
done

# ✅ 设置权限
chmod +x "$INSTALL_DIR/vps_master.sh"
chmod +x "$MODULE_DIR"/*.sh

# ✅ 初始化日志文件
touch "$LOG_DIR/vps_toolkit.log"

# ✅ 创建快速启动命令
rm -f /usr/local/bin/tool
ln -s "$INSTALL_DIR/vps_master.sh" /usr/local/bin/tool
chmod +x /usr/local/bin/tool

echo "✅ 安装完成！你可以使用以下命令启动面板："
echo ""
echo "tool"
echo ""
