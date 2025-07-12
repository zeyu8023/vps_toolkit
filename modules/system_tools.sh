#!/bin/bash
echo "✅ 已加载 system_tools.sh"
# 模块：系统工具中心

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
        read -p "🔍 输入端口号: " port
        echo -e "\n📡 正在查询端口 $port 的占用情况..."
        result=$(sudo lsof -i :"$port" | grep LISTEN)
        if [[ -z "$result" ]]; then
          echo "❌ 未发现该端口被监听"
        else
          echo "$result"
          pid=$(echo "$result" | awk '{print $2}' | head -n 1)
          read -p "⚠️ 是否终止该进程？(y/n): " confirm
          if [[ "$confirm" == "y" ]]; then
            sudo kill -9 "$pid" && echo "✅ 已终止进程 PID: $pid" && log "终止端口 $port 占用进程 PID: $pid"
          fi
        fi
        ;;
      2)
        read -p "🔍 筛选协议（tcp/udp/all）: " proto
        echo -e "\n📡 当前监听端口列表"
        case "$proto" in
          tcp) sudo netstat -tnlp | grep LISTEN | column -t ;;
          udp) sudo netstat -unlp | column -t ;;
          all) sudo netstat -tulnp | grep LISTEN | column -t ;;
          *) echo "❌ 无效协议，请输入 tcp / udp / all" ;;
        esac
        ;;
      3)
        echo -e "\n🔥 高资源占用进程（按 CPU 排序）"
        ps aux --sort=-%cpu | head -n 10 | column -t
        ;;
      4)
        echo -e "\n🌍 公网 IP 与地理位置"
        curl -s ipinfo.io | jq '.ip, .city, .region, .country, .org'
        ;;
      5)
        echo -e "\n🧹 正在清理系统垃圾..."
        sudo apt autoremove -y && sudo apt clean
        sudo rm -rf /var/log/*.log /tmp/*
        docker system prune -a -f
        echo "✅ 清理完成"
        ;;
      6)
        echo -e "\n💽 磁盘占用排行（按目录）"
        sudo du -h --max-depth=1 / | sort -hr | head -n 10
        ;;
      7)
        echo -e "\n🌐 网络连接数（按 IP）"
        netstat -an | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
        ;;
      8)
        echo -e "\n⏱️ 系统运行时间与启动时间"
        uptime -p
        who -b
        ;;
      9)
        echo -e "\n🔐 登录记录与 SSH 安全"
        echo "最近登录记录："
        last -a | head -n 10
        echo -e "\nSSH 登录失败记录："
        grep "Failed password" /var/log/auth.log | tail -n 10
        ;;
      10)
        echo -e "\n🧬 系统版本与内核信息"
        lsb_release -a 2>/dev/null || cat /etc/os-release
        uname -r
        ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
