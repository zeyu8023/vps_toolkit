# Version: 2.3.1
#!/bin/bash
echo "✅ 已加载 app_manager.sh"

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"

# ✅ 日志函数
log() {
  local message="$1"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [app_manager] $message" >> "$LOG_FILE"
}

# 分类定义
declare -A categories=(
  ["系统工具"]="htop curl wget nano vim ufw unzip"
  ["网络工具"]="net-tools nmap iperf3 tcpdump traceroute"
  ["开发环境"]="git gcc make python3 nodejs docker"
  ["Web服务"]="nginx apache2 mysql-server php php-fpm"
)

# 应用操作子菜单
app_actions() {
  local pkg="$1"
  while true; do
    echo -e "\n📦 应用：$pkg"
    echo "────────────────────────────────────────────"
    echo " 1) 更新该应用"
    echo " 2) 卸载该应用"
    echo " 3) 查看应用日志"
    echo " 0) 返回上级菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " sub

    case "$sub" in
      1)
        sudo apt update && sudo apt upgrade "$pkg" -y \
          && echo "✅ 已更新：$pkg" \
          && log "✅ 更新应用：$pkg"
        ;;
      2)
        sudo apt remove "$pkg" -y \
          && echo "✅ 已卸载：$pkg" \
          && log "✅ 卸载应用：$pkg"
        ;;
      3)
        journalctl -u "$pkg" --no-pager | tail -n 30
        ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}

# 主模块入口
app_manager() {
  while true; do
    echo -e "\n📦 应用管理中心"
    echo "────────────────────────────────────────────"
    echo " 1) 已安装应用（分类展示）"
    echo " 2) 更新所有应用"
    echo " 3) 安装常用应用"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1)
        index=1
        declare -A pkg_map
        for category in "${!categories[@]}"; do
          echo -e "\n🔹 ${category}"
          for pkg in ${categories[$category]}; do
            info=$(dpkg-query -W -f='${Package}\t${Version}\n' 2>/dev/null | grep "^$pkg")
            if [[ -n "$info" ]]; then
              echo "$index) $info"
              pkg_map["$index"]="$pkg"
              ((index++))
            fi
          done
        done
        read -p "📦 输入应用编号进入操作菜单: " selected
        [[ -n "${pkg_map[$selected]}" ]] && app_actions "${pkg_map[$selected]}"
        ;;
      2)
        echo "🔄 正在更新所有应用..."
        sudo apt update && sudo apt upgrade -y \
          && echo "✅ 所有应用已更新" \
          && log "✅ 更新全部应用"
        ;;
      3)
        echo -e "\n📦 常用应用安装（状态检测 + 中文描述）"

        common_apps=(
          "unzip|解压 zip 文件"
          "curl|发送网络请求"
          "wget|下载文件"
          "git|版本控制工具"
          "vim|高级文本编辑器"
          "nano|简洁文本编辑器"
          "htop|进程监控工具"
          "net-tools|经典网络命令集"
          "iproute2|现代网络命令集"
          "nmap|端口扫描工具"
          "tcpdump|抓包分析工具"
          "traceroute|路由追踪工具"
          "iperf3|网络带宽测试"
          "ufw|防火墙管理工具"
          "screen|后台任务保持工具"
          "tmux|终端多窗口管理"
          "python3|Python 运行环境"
          "gcc|C语言编译器"
          "make|构建工具"
        )

        for i in "${!common_apps[@]}"; do
          entry="${common_apps[$i]}"
          pkg="${entry%%|*}"
          desc="${entry##*|}"
          if dpkg -s "$pkg" &>/dev/null; then
            status="✅ 已安装"
          else
            status="❌ 未安装"
          fi
          printf "%2d) %-12s %-20s [%s]\n" "$((i+1))" "$pkg" "$desc" "$status"
        done
        echo " 0) 返回上级菜单"

        read -p "📥 输入编号安装应用: " num

        if [[ "$num" == "0" ]]; then
          echo "↩️ 返回上级菜单"
          break
        fi

        entry="${common_apps[$((num-1))]}"
        app="${entry%%|*}"

        if [[ -z "$app" ]]; then
          echo "❌ 无效编号，请重新输入。"
        elif dpkg -s "$app" &>/dev/null; then
          echo "ℹ️ $app 已安装，无需重复安装。"
          log "ℹ️ 跳过安装（已存在）：$app"
        else
          sudo apt install "$app" -y \
            && echo "✅ 已安装：$app" \
            && log "✅ 安装常用应用：$app"
        fi
        ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
