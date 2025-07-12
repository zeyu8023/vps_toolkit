# Version: 2.3.1
#!/bin/bash
echo "✅ 已加载 log_tools.sh"
# 模块：日志中心

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"

# ✅ 日志写入函数（供其他模块调用）
log() {
  local module="$1"
  local message="$2"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [$module] $message" >> "$LOG_FILE"
}

log_tools() {
  while true; do
    echo -e "\n📜 日志中心"
    echo "────────────────────────────────────────────"
    echo " 1) 查看最近日志（最新在上）"
    echo " 2) 按模块筛选日志"
    echo " 3) 清空日志文件"
    echo " 4) 导出日志副本"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1)
        echo -e "\n📋 最近日志记录（最多显示 30 条）："
        tac "$LOG_FILE" | head -n 30
        ;;
      2)
        read -p "🔍 输入模块名称（如 ssl_manager）: " module
        echo -e "\n📋 筛选模块 [$module] 的日志："
        grep "\[$module\]" "$LOG_FILE" | tail -n 30
        ;;
      3)
        read -p "⚠️ 是否确认清空日志文件？(y/n): " confirm
        if [[ "$confirm" == "y" ]]; then
          > "$LOG_FILE"
          echo "✅ 日志文件已清空"
          log "log_tools" "✅ 清空日志文件"
        else
          echo "❌ 已取消清空操作"
        fi
        ;;
      4)
        cp "$LOG_FILE" /opt/vps_toolkit/logs/exported.log
        echo "✅ 已导出日志副本到 /opt/vps_toolkit/logs/exported.log"
        log "log_tools" "✅ 导出日志副本"
        ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}
