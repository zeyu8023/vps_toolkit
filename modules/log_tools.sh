# Version: 2.3.0
#!/bin/bash
echo "✅ 已加载 log_tools.sh"

LOG_FILE="/opt/vps_toolkit/logs/vps_toolkit.log"

log_tools() {
  while true; do
    clear
    echo "📜 日志工具模块"
    echo "────────────────────────────────────────────"
    echo " 1. 查看完整日志"
    echo " 2. 搜索关键字"
    echo " 3. 清空日志文件"
    echo " 0. 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入操作编号: " log_choice

    case "$log_choice" in
      1)
        echo "📄 日志内容如下："
        if [[ -f "$LOG_FILE" ]]; then
          less "$LOG_FILE"
        else
          echo "🚫 日志文件不存在：$LOG_FILE"
        fi
        read -p "🔙 回车返回菜单..." ;;
      2)
        read -p "🔍 输入要搜索的关键字: " keyword
        if [[ -n "$keyword" ]]; then
          echo "📄 匹配结果："
          grep --color=always "$keyword" "$LOG_FILE" || echo "🚫 未找到匹配内容"
        else
          echo "🚫 未输入关键字"
        fi
        read -p "🔙 回车返回菜单..." ;;
      3)
        read -p "⚠️ 确认清空日志文件？(y/n): " confirm
        if [[ "$confirm" == "y" ]]; then
          > "$LOG_FILE"
          echo "✅ 日志已清空"
        else
          echo "🚫 操作取消"
        fi
        read -p "🔙 回车返回菜单..." ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
    esac
  done
}
