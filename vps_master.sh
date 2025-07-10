#!/bin/bash

LOG_FILE="/var/log/vps_toolkit.log"

# 自动创建快捷命令
if [[ $EUID -ne 0 ]]; then
  echo "⚠️ 请使用 sudo 运行此脚本"
  exit 1
fi

cp "$0" /usr/local/bin/tool || echo "⚠️ 无法创建快捷命令"
chmod +x /usr/local/bin/tool 2>/dev/null

log() {
  echo -e "\033[36m[$(date '+%F %T')]\033[0m $1" | tee -a "$LOG_FILE"
}

get_memory_brief() { free -h | awk '/Mem:/ {print "已用："$3" / 总："$2}'; }
get_disk_usage() { df -h --output=source,pcent,target | grep -vE '^Filesystem|tmpfs|udev' | head -n 1; }
get_load_average() { uptime | awk -F'load average:' '{print $2}' | sed 's/^ //'; }

show_menu() {
  clear
  echo -e "\033[1;36m╔════════════════════════════════════════════════════╗"
  echo -e "║         🚀 VPS 管理工具面板  |  By XIAOYU           ║"
  echo -e "╚════════════════════════════════════════════════════╝\033[0m"

  echo -e "\033[1;37m📊 内存使用：\033[0m$(get_memory_brief)"
  echo -e "\033[1;37m💽 磁盘使用：\033[0m$(get_disk_usage)"
  echo -e "\033[1;37m⚙️ 系统负载：\033[0m$(get_load_average)"
  echo -e "\033[90m────────────────────────────────────────────────────\033[0m"

  echo -e "\033[1;34m 1.\033[0m 查看详细内存信息"
  echo -e "\033[1;34m 2.\033[0m 查看并终止进程（按内存排序）"
  echo -e "\033[1;34m 3.\033[0m 释放缓存内存"
  echo -e "\033[1;34m 4.\033[0m 卸载指定程序（选择序号）"
  echo -e "\033[1;34m 5.\033[0m 设置自动缓存清理任务"
  echo -e "\033[1;34m 6.\033[0m 查看操作日志"
  echo -e "\033[1;34m 7.\033[0m 启用 Swap（自定义大小）"
  echo -e "\033[1;34m 8.\033[0m 删除 Swap（关闭并清理）"
  echo -e "\033[1;34m 9.\033[0m 内存分析助手 🧠"
  echo -e "\033[1;34m10.\033[0m 程序/服务搜索助手 🔍"
  echo -e "\033[1;34m11.\033[0m 查看系统信息 🖥️"
  echo -e "\033[1;34m 0.\033[0m 退出程序"

  echo -e "\033[90m────────────────────────────────────────────────────\033[0m"
}

check_memory() {
  log "查看详细内存信息"
  free -h
}

kill_process() {
  echo -e "\n🧠 高内存进程列表（单位 MB）："
  ps -eo pid,comm,rss --sort=-rss | head -n 21 | tail -n +2 | awk '{printf "%s %s %d\n", $1, $2, $3/1024}' > /tmp/proc_list.txt
  printf "%-5s %-40s %-10s %-10s\n" "编号" "进程名称" "PID" "内存(MB)"
  echo "---------------------------------------------------------------"
  i=1
  while read pid comm mem; do
    printf "%-5s %-40s %-10s %-10s\n" "$i" "$comm" "$pid" "$mem"
    i=$((i+1))
  done < /tmp/proc_list.txt
  read -p "🔍 输入要终止的进程编号（或直接回车取消）： " index
  [[ -z "$index" ]] && echo "🚫 未输入编号，操作已取消" && return
  [[ ! "$index" =~ ^[0-9]+$ ]] && echo "⚠️ 输入无效，请输入数字编号" && return
  pid_to_kill=$(sed -n "${index}p" /tmp/proc_list.txt | awk '{print $1}')
  [[ -z "$pid_to_kill" ]] && echo "🚫 无效编号，操作取消" && return
  kill -9 "$pid_to_kill" && log "终止进程 $pid_to_kill" && echo "✅ 成功终止进程 $pid_to_kill"
}

release_cache() {
  sync; echo 3 > /proc/sys/vm/drop_caches
  log "释放内存缓存"
  echo "✅ 系统缓存已释放"
}

uninstall_program() {
  echo "📦 正在列出已安装程序..."
  if command -v apt >/dev/null; then
    dpkg --get-selections | grep -v deinstall | awk '{print $1}' > /tmp/pkg_list.txt
  elif command -v yum >/dev/null; then
    yum list installed | awk 'NR>1 {print $1}' > /tmp/pkg_list.txt
  else
    echo "⚠️ 未识别的包管理器"
    return
  fi
  mapfile -t packages < /tmp/pkg_list.txt
  for i in "${!packages[@]}"; do
    printf "%-5s %s\n" "$((i+1))" "${packages[$i]}"
  done | head -n 30
  read -p "🔍 输入要卸载的程序编号（或直接回车取消）： " pkg_index
  [[ -z "$pkg_index" ]] && echo "🚫 未输入编号，操作已取消" && return
  [[ ! "$pkg_index" =~ ^[0-9]+$ ]] && echo "⚠️ 输入无效，请输入数字编号" && return
  pkg_name="${packages[$((pkg_index-1))]}"
  [[ -z "$pkg_name" ]] && echo "🚫 无效编号，操作取消" && return
  read -p "⚠️ 确认卸载 $pkg_name？(y/N): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "❎ 已取消卸载操作"; return; }
  if command -v apt >/dev/null; then
    sudo apt remove --purge "$pkg_name" -y && log "卸载程序 $pkg_name (APT)"
  elif command -v yum >/dev/null; then
    sudo yum remove "$pkg_name" -y && log "卸载程序 $pkg_name (YUM)"
  fi
}

setup_cron_cleaner() {
  cron_cmd="sync; echo 3 > /proc/sys/vm/drop_caches # VPS自动清理缓存"
  (crontab -l 2>/dev/null; echo "0 * * * * $cron_cmd") | crontab -
  log "配置每小时自动清理缓存任务"
  echo "⏰ 已设置每小时清理任务（cron）"
}

view_logs() {
  echo -e "\n📄 最近的操作日志："
  tail -n 30 "$LOG_FILE"
}

enable_swap() {
  echo -e "\n🧪 正在检测当前 Swap 状态..."
  if swapon --show | grep -q '/swapfile'; then
    echo "✅ 已启用 Swap：$(swapon --show | awk 'NR==2 {print $1, $3}')"
    log "检测到已有 Swap，无需重复创建"
    return
  fi
  read -p "💾 请输入要创建的 Swap 大小（如 512M、1G、2G）： " swap_size
  [[ -z "$swap_size" ]] && echo "🚫 未输入大小，操作已取消" && return
  [[ ! "$swap_size" =~ ^[0-9]+[MG]$ ]] && echo "⚠️ 输入格式无效，请使用如 512M 或 1G 的格式" && return
  sudo swapoff -a 2>/dev/null
  sudo rm -f /swapfile
  sudo fallocate -l "$swap_size" /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=${swap_size%[MG]}
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
  swapon --show | grep -q '/swapfile' && echo "✅ 成功启用 Swap（大小：$swap_size）" && log "启用 Swap：$swap_size"
}

delete_swap() {
  echo -e "\n🧽 正在检测是否存在 Swap..."
  if swapon --show | grep -q '/swapfile'; then
    read -p "⚠️ 确认要关闭并删除 Swap 吗？(y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo swapoff /swapfile
      sudo rm -f /swapfile
      sudo sed -i '/\/swapfile/d' /etc/fstab
      echo "✅ Swap 已关闭并删除"
      log "删除 Swap 成功"
    else
      echo "❎ 已取消删除 Swap"
    fi
  else
    echo "ℹ️ 当前未启用 Swap，无需删除"
    log "尝试删除 Swap，但未检测到"
  fi
}

analyze_memory() {
  echo -e "\n🧠 内存分析助手：当前内存占用前 10 的进程（单位 MB）"
  echo "-------------------------------------------------------------"
  printf "%-3s %-30s %-8s %-8s %-8s\n" "序号" "进程名" "PID" "%MEM" "RSS(MB)"
  echo "-------------------------------------------------------------"
  ps aux --sort=-%mem | awk 'NR==1 || NR<=11' | awk 'NR>1 {printf "%-3s %-30s %-8s %-8s %-8.1f\n", NR-1, $11, $2, $4, $6/1024}'
  echo -e "\n📌 优化建议："
  echo "🔹 如果你不使用 Docker，可考虑关闭 dockerd/containerd"
  echo "🔹 如果你不使用 nginx 缓存，可关闭 nginx: cache manager process"
  echo "🔹 如果某些 Node.js 或面板服务不常用，可考虑关闭或限制内存"
  echo "🔹 启用 Swap 可缓解内存压力（已集成在主菜单）"
  log "执行内存分析助手"
}

search_program() {
  read -p "🔍 请输入要搜索的程序或服务名称关键词： " keyword
  if [[ -z "$keyword" ]]; then
    echo "🚫 未输入关键词，操作已取消"
    return
  fi
  echo -e "\n📦 APT 包匹配结果："
  dpkg -l | grep -i "$keyword" || echo "❌ 未找到相关 APT 包"
  echo -e "\n🛠️ 正在运行的服务匹配结果："
  systemctl list-units --type=service | grep -i "$keyword" || echo "❌ 未找到相关服务"
  echo -e "\n📂 可执行命令路径："
  which "$keyword" 2>/dev/null || echo "❌ 未找到可执行命令"
  log "搜索程序/服务：$keyword"
}

show_system_info() {
  echo -e "\n🖥️ 系统信息概览："
  echo "--------------------------------------------"
  echo "操作系统版本：$(lsb_release -ds 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
  echo "内核版本：$(uname -r)"
  echo "架构：$(uname -m)"
  echo "CPU 型号：$(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^ *//')"
  echo "CPU 核心数：$(nproc)"
  echo "CPU 使用率：$(top -bn2 | grep "Cpu(s)" | tail -n1 | awk '{print 100 - $8"%"}')"
  echo "内存使用：$(free -m | awk '/Mem:/ {printf "%.2f / %.2f MB (%.1f%%)", $3, $2, $3/$2*100}')"
  echo "Swap 使用：$(free -m | awk '/Swap:/ {printf "%.2f / %.2f MB (%.1f%%)", $3, $2, ($2==0)?0:$3/$2*100}')"
  echo "磁盘使用：$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
  echo "网络接收：$(cat /proc/net/dev | awk '/eth|ens|eno/ {rx+=$2} END {printf "%.2f MB", rx/1024/1024}')"
  echo "网络发送：$(cat /proc/net/dev | awk '/eth|ens|eno/ {tx+=$10} END {printf "%.2f MB", tx/1024/1024}')"
  echo "拥塞控制算法：$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')"
  echo "公网 IP：$(curl -s ifconfig.me || curl -s ipinfo.io/ip)"
  log "查看系统信息"
}

# 主循环
while true; do
  clear
  show_menu
  read -p "👉 请选择操作（0-11）： " choice
  if [[ -z "$choice" ]]; then
    echo "🚫 未输入选项，操作已取消"
    continue
  fi

  case $choice in
    1) check_memory ;;
    2) kill_process ;;
    3) release_cache ;;
    4) uninstall_program ;;
    5) setup_cron_cleaner ;;
    6) view_logs ;;
    7) enable_swap ;;
    8) delete_swap ;;
    9) analyze_memory ;;
    10) search_program ;;
    11) show_system_info ;;
    0) log "退出脚本"; echo "👋 再见，xiaoyu！"; break ;;
    *) echo "⚠️ 无效输入，请选 0~11" ;;
  esac

  echo -e "\n🔁 按 Enter 返回主菜单..."
  read
done
