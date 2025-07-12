#!/bin/bash
# 🚀 VPS Toolkit 安装脚本 | 自动拉取所有模块文件

INSTALL_DIR="/opt/vps_toolkit"
MODULE_DIR="$INSTALL_DIR/modules"
LOG_DIR="$INSTALL_DIR/logs"
REPO="zeyu8023/vps_toolkit"

echo "📦 正在安装 VPS Toolkit 到 $INSTALL_DIR..."
mkdir -p "$MODULE_DIR" "$LOG_DIR"

# ✅ 下载主脚本
curl -sSL "https://raw.githubusercontent.com/$REPO/main/vps_master.sh" -o "$INSTALL_DIR/vps_master.sh"

# ✅ 自动获取 modules/ 下所有文件名
echo "🔍 正在获取模块列表..."
module_files=$(curl -sSL "https://api.github.com/repos/$REPO/contents/modules" | grep '"name":' | cut -d '"' -f4)

# ✅ 下载所有模块文件
for file in $module_files; do
  echo "📄 下载模块：$file"
  curl -sSL "https://raw.githubusercontent.com/$REPO/main/modules/$file" -o "$MODULE_DIR/$file"
done

# ✅ 设置权限
chmod +x "$INSTALL_DIR/vps_master.sh"
chmod +x "$MODULE_DIR"/*.sh
touch "$LOG_DIR/vps_toolkit.log"

# ✅ 创建快速启动命令
rm -f /usr/local/bin/tool
ln -s "$INSTALL_DIR/vps_master.sh" /usr/local/bin/tool
chmod +x /usr/local/bin/tool

echo "✅ 安装完成！你可以使用以下命令启动面板："
echo ""
echo "tool"
echo ""
