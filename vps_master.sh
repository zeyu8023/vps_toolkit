#!/bin/bash
# 🚀 VPS 管理工具面板 | By XIAOYU

# ✅ 固定路径，确保模块加载成功
SCRIPT_DIR="/opt/vps_toolkit"
MODULE_DIR="$SCRIPT_DIR/modules"
LOG_FILE="$SCRIPT_DIR/logs/vps_toolkit.log"

# ✅ 通用日志函数
log() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $*" >> "$LOG_FILE"
}
export -f log

# ✅ 模块函数映射表
declare -A modules=(
  [1]="system_info.sh:system_info"
  [2]="network_tools.sh:network_tools"
  [3]="docker_tools.sh:docker_management_center"
  [4]="memory_tools.sh:memory_management_center"
  [5]="swap_tools.sh:swap_management_center"
  [6]="install_tools.sh:install_tools"
  [7]="log_tools.sh:log_tools"
)

# ✅ 加载所有模块并验证函数
for key in "${!modules[@]}"; do
  IFS=":" read -r file func <<< "${modules[$key]}"
  path="$MODULE_DIR/$file"
  if [[ -f "$path" ]]; then
    source "$path"
    if ! declare -F "$func" >/dev/null; then
      echo "❌ 模块 $file 加载失败：未定义函数 $func"
      exit 1
    fi
  else
    echo "❌ 模块文件缺失：$file"
    exit 1
  fi
done

# ✅ 主菜单循环
while true; do
  clear
  echo "╔════════════════════════════════════════════════════╗"
  echo "║         🚀 VPS 管理工具面板  |  By XIAOYU           ║"
  echo "╚════════════════════════════════════════════════════╝"

  mem_used=$(free -m | awk '/Mem:/ {print $3}')
  mem_total=$(free -m | awk '/Mem:/ {print $2}')
  disk_used=$(df -h / | awk 'NR==2 {print $5}')
  disk_total=$(df -h / | awk 'NR==2 {print $2}')
  load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')

  echo "📊 内存使用：已用: ${mem_used}Mi / 总: ${mem_total}Mi"
  echo "💽 磁盘使用：${disk_used} 已用 / 总: ${disk_total}"
  echo "⚙️ 系统负载：${load_avg}"
  echo "────────────────────────────────────────────────────"
  echo " 1. 查看系统信息 🖥️"
  echo " 2. 网络设置中心 🌐"
  echo " 3. Docker 管理中心 🐳"
  echo " 4. 内存管理中心 🧠"
  echo " 5. Swap 管理中心 💾"
  echo " 6. 一键安装常用环境 🧰"
  echo " 7. 查看操作日志 📜"
  echo " 0. 退出程序"
  echo "────────────────────────────────────────────────────"
  read -p "👉 请输入选项编号: " choice

  if [[ "$choice" == "0" ]]; then
    echo "👋 再见！" && exit 0
  elif [[ -n "${modules[$choice]}" ]]; then
    IFS=":" read -r _ func <<< "${modules[$choice]}"
    "$func"
  else
    echo "❌ 无效选项，请重新输入。" && sleep 1
  fi
done
