# Version: 2.3.2
#!/bin/bash
echo "✅ 已加载 test_tools.sh"
# 模块：常用测试脚本功能 🧪

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"
SCRIPT_LIST="/opt/vps_toolkit/config/test_scripts.list"

mkdir -p /opt/vps_toolkit/config
touch "$SCRIPT_LIST"

log() {
  local message="$1"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [test_tools] $message" >> "$LOG_FILE"
}

add_custom_script() {
  echo -e "\n📝 添加自定义测试脚本"
  read -p "📛 输入脚本名称: " name
  read -p "🔗 输入执行命令（如 bash <(curl -sL ...)）: " cmd

  if [[ -n "$name" && -n "$cmd" ]]; then
    echo "$name|$cmd" >> "$SCRIPT_LIST"
    echo "✅ 已添加脚本：$name"
    log "添加自定义测试脚本：$name"
  else
    echo "❌ 名称或命令不能为空"
  fi
}

run_custom_scripts() {
  echo -e "\n📂 脚本收藏夹列表："
  mapfile -t lines < "$SCRIPT_LIST"

  if [[ ${#lines[@]} -eq 0 ]]; then
    echo "⚠️ 当前没有收藏的脚本"
    return
  fi

  for i in "${!lines[@]}"; do
    name="${lines[$i]%%|*}"
    echo " $((i+1))) $name"
  done

  read -p "👉 请输入要运行的脚本编号: " num
  index=$((num-1))
  cmd="${lines[$index]#*|}"

  if [[ -n "$cmd" ]]; then
    echo "🚀 正在运行：${lines[$index]%%|*}"
    eval "$cmd"
    log "运行收藏夹脚本：${lines[$index]%%|*}"
  else
    echo "❌ 无效编号或命令为空"
  fi
}

test_tools() {
  while true; do
    echo -e "\n🧪 常用测试脚本功能"
    echo "────────────────────────────────────────────"
    echo " 1) IP质量测试"
    echo " 2) 网络质量检测"
    echo " 3) NodeQuality完整测试"
    echo " 4) 添加自定义测试脚本"
    echo " 5) 运行收藏夹脚本"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    echo "🙏 鸣谢脚本作者：@xykt"
    echo "📎 GitHub主页：https://github.com/xykt"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1)
        echo "🚀 正在运行 IP质量测试..."
        bash <(curl -sL Check.Place) -I
        log "运行 IP质量测试脚本"
        ;;
      2)
        echo "🚀 正在运行 网络质量检测..."
        bash <(curl -sL Check.Place) -N
        log "运行 网络质量检测脚本"
        ;;
      3)
        echo "🚀 正在运行 NodeQuality验证测试..."
        bash <(curl -sL https://run.NodeQuality.com)
        log "运行 NodeQuality验证测试脚本"
        ;;
      4) add_custom_script ;;
      5) run_custom_scripts ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
