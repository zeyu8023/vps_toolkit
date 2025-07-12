# Version: 2.3.1
#!/bin/bash
echo "✅ 已加载 swap_tools.sh"
# 模块：Swap 管理中心 💾

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"

log() {
  local message="$1"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [swap_tools] $message" >> "$LOG_FILE"
}

swap_management_center() {
  while true; do
    clear
    echo "💾 Swap 管理中心"
    echo "────────────────────────────────────────────"
    echo " 当前 Swap 使用：$(free -m | awk '/Swap:/ {print $3 "MiB / " $2 "MiB"}')"
    echo "────────────────────────────────────────────"
    echo " 1. 启用 Swap（自定义大小）"
    echo " 2. 删除 Swap"
    echo " 0. 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入操作编号: " swap_choice

    case "$swap_choice" in
      1)
        read -p "📏 输入要创建的 Swap 大小（单位 MiB，例如 1024）: " size
        if [[ "$size" =~ ^[0-9]+$ ]]; then
          swapfile="/swapfile"
          echo "🛠️ 正在创建 $size MiB Swap 文件..."
          sudo fallocate -l "${size}M" "$swapfile" || sudo dd if=/dev/zero of="$swapfile" bs=1M count="$size"
          sudo chmod 600 "$swapfile"
          sudo mkswap "$swapfile"
          sudo swapon "$swapfile"
          echo "✅ Swap 已启用：$(free -m | awk '/Swap:/ {print $3 "MiB / " $2 "MiB"}')"
          log "启用 Swap：${size}MiB"
        else
          echo "❌ 输入无效，请输入数字大小"
        fi
        read -p "🔙 回车返回菜单..." ;;
      2)
        swapfile="/swapfile"
        if swapon --show | grep -q "$swapfile"; then
          echo "🧹 正在关闭并删除 Swap..."
          sudo swapoff "$swapfile"
          sudo rm -f "$swapfile"
          echo "✅ Swap 已删除"
          log "删除 Swap 文件：$swapfile"
        else
          echo "🚫 未检测到 /swapfile，无需删除"
          log "尝试删除 Swap，但未检测到 /swapfile"
        fi
        read -p "🔙 回车返回菜单..." ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
    esac
  done
}
