#!/bin/bash
# 🚀 VPS Toolkit 安装脚本 | 含 tool 快速启动

INSTALL_DIR="/opt/vps_toolkit"
MODULE_DIR="$INSTALL_DIR/modules"
LOG_DIR="$INSTALL_DIR/logs"

echo "📦 正在安装 VPS Toolkit 到 $INSTALL_DIR..."
mkdir -p "$MODULE_DIR" "$LOG_DIR"

# ✅ 下载主脚本
curl -sSL https://raw.githubusercontent.com/zeyu8023/vps_toolkit/main/vps_master.sh -o "$INSTALL_DIR/vps_master.sh"
chmod +x "$INSTALL_DIR/vps_master.sh"

# ✅ 修复模块结构
declare -A required_functions=(
  ["system_info.sh"]="system_info"
  ["network_tools.sh"]="network_tools"
  ["docker_tools.sh"]="docker_management_center"
  ["memory_tools.sh"]="memory_management_center"
  ["swap_tools.sh"]="swap_management_center"
  ["install_tools.sh"]="install_tools"
  ["log_tools.sh"]="log_tools"
)

echo "🔧 正在修复模块结构..."
for file in "${!required_functions[@]}"; do
  path="$MODULE_DIR/$file"
  func="${required_functions[$file]}"

  if [[ ! -f "$path" ]]; then
    echo "📄 创建缺失模块：$file"
    echo -e "#!/bin/bash\n\n$func() {\n  echo \"📦 模块 $file 已执行\"\n  read -p \"🔙 回车返回主菜单...\"\n}" > "$path"
    chmod +x "$path"
  else
    if ! grep -q "已加载 $file" "$path"; then
      sed -i "1i echo \"✅ 已加载 $file\"" "$path"
    fi
    if ! grep -Eq "^[[:space:]]*(function[[:space:]]+)?$func[[:space:]]*\(\)" "$path"; then
      echo "⚠️ 补全函数定义：$func in $file"
      echo -e "\n$func() {\n  echo \"📦 模块 $file 已执行\"\n  read -p \"🔙 回车返回主菜单...\"\n}" >> "$path"
    fi
  fi
done

# ✅ 创建快速启动命令：tool
echo "🚀 创建快速启动命令：tool"
ln -sf "$INSTALL_DIR/vps_master.sh" /usr/local/bin/tool
chmod +x /usr/local/bin/tool

echo "✅ 安装完成！你可以使用以下命令启动面板："
echo ""
echo "tool"
echo ""
