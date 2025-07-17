# Version: 2.3.3
#!/bin/bash
echo "✅ 已加载 system_tools.sh"
# 模块：系统工具中心

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"

log() {
  local message="$1"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [system_tools] $message" >> "$LOG_FILE"
}

ensure_command() {
  local cmd="$1"
  local pkg="$2"
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ 缺少命令：$cmd（建议安装 $pkg）"
    read -p "📥 是否安装 $pkg？(y/n): " confirm
    [[ "$confirm" == "y" ]] && sudo apt update && sudo apt install "$pkg" -y
  fi
}

clean_system() {
  echo -e "\n🧹 系统垃圾清理工具"
  echo "────────────────────────────────────────────"
  echo "📊 清理前磁盘使用情况："
  df -h /

  echo -e "\n🧼 正在清理系统缓存与日志..."
  sudo apt autoremove -y
  sudo apt clean
  sudo journalctl --vacuum-time=7d
  sudo find /var/log -type f -name "*.log" -delete
  sudo find /tmp -type f -mtime +3 -delete

  echo -e "\n🐳 Docker 清理提示："
  read -p "是否清理未使用的 Docker 镜像和容器？(y/n): " confirm
  if [[ "$confirm" == "y" ]]; then
    docker system prune -f
    echo "✅ Docker 清理完成"
    log "清理 Docker 镜像与容器"
  else
    echo "❌ 已跳过 Docker 清理"
  fi

  echo -e "\n📊 清理后磁盘使用情况："
  df -h /
  echo "✅ 系统垃圾清理完成"
  log "执行系统垃圾清理"
}

system_tools() {
  while true; do
    echo -e "\n🛠️ 系统工具中心"
    echo "────────────────────────────────────────────"
    echo " 1) 查询端口占用（支持杀进程）"
    echo " 2) 查看所有监听端口（可筛选协议）"
    echo " 3) 查看高资源进程"
    echo " 4) 查看公网 IP 与地理位置"
    echo " 5) 清理系统垃圾"
    echo " 6) 查看磁盘占用排行"
    echo " 7) 查看网络连接数（按 IP）"
    echo " 8) 查看系统运行时间"
    echo " 9) 查看登录记录与 SSH 安全"
    echo "10) 查看系统版本与内核信息"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1)
        ensure_command lsof lsof
        read -p "🔍 输入端口号: " port
        echo -e "\n📡 正在查询端口 $port 的占用情况..."
        result=$(sudo lsof -i :"$port" | grep LISTEN)
        if [[ -z "$result" ]]; then
          echo "❌ 未发现该端口被监听"
          log "查询端口占用：$port 未被监听"
        else
          echo "$result"
          pid=$(echo "$result" | awk '{print $2}' | head -n 1)
          read -p "⚠️ 是否终止该进程？(y/n): " confirm
          if [[ "$confirm" == "y" ]]; then
            sudo kill -9 "$pid" && echo "✅ 已终止进程 PID: $pid"
            log "终止端口 $port 占用进程 PID: $pid"
          fi
        fi
        ;;
      2)
        ensure_command netstat net-tools
        ensure_command column bsdmainutils
        read -p "🔍 筛选协议（tcp/udp/all）: " proto
        echo -e "\n📡 当前监听端口列表"
        case "$proto" in
          tcp) sudo netstat -tnlp | grep LISTEN | column -t ;;
          udp) sudo netstat -unlp | column -t ;;
          all) sudo netstat -tulnp | grep LISTEN | column -t ;;
          *) echo "❌ 无效协议，请输入 tcp / udp / all" ;;
        esac
        log "查看监听端口（协议筛选：$proto）"
        ;;
      3)
        echo -e "\n🔥 高资源占用进程（按 CPU 排序）"
        ps aux --sort=-%cpu | head -n 10 | column -t
        log "查看高资源占用进程"
        ;;
      4)
        ensure_command curl curl
        ensure_command jq jq
        echo -e "\n🌍 公网 IP 与地理位置"
        curl -s ipinfo.io | jq '.ip, .city, .region, .country, .org'
        log "查看公网 IP 与地理位置"
        ;;
      5)
        clean_system
        ;;
      6)
        echo -e "\n💽 磁盘占用排行（按目录）"
        echo "────────────────────────────────────────────"
        exclude_dirs=(/proc /sys /run /dev /tmp /var/lib/docker)
        exclude_args=()
        for d in "${exclude_dirs[@]}"; do
          exclude_args+=(--exclude="$d")
        done

        echo "📁 根目录占用排行："
        sudo du -h --max-depth=1 / "${exclude_args[@]}" 2>/dev/null | sort -hr | head -n 10

        echo -e "\n📂 每个目录下占用最多的子目录："
        for dir in /home /var /usr /opt; do
          [[ -d "$dir" ]] || continue
          echo -e "\n📁 $dir 下占用最多的子目录："
          sudo du -h --max-depth=1 "$dir" 2>/dev/null | sort -hr | head -n 3
        done

        log "查看磁盘占用排行与子目录分析"
        ;;
      7)
        ensure_command netstat net-tools
        echo -e "\n🌐 网络连接数（按 IP）"
        netstat -an | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
        log "查看网络连接数（按 IP）"
        ;;
      8)
        echo -e "\n⏱️ 系统运行时间与启动时间"
        uptime -p
        who -b
        log "查看系统运行时间与启动时间"
        ;;
      9)
        echo -e "\n🔐 登录记录与 SSH 安全"
        echo "最近登录记录："
        last -a | head -n 10
        echo -e "\nSSH 登录失败记录："
        grep "Failed password" /var/log/auth.log | tail -n 10
        log "查看登录记录与 SSH 安全"
        ;;
      10)
        echo -e "\n🧬 系统版本与内核信息"
        lsb_release -a 2>/dev/null || cat /etc/os-release
        uname -r
        log "查看系统版本与内核信息"
        ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}