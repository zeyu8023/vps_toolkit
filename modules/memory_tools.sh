# Version: 2.3.0
#!/bin/bash
echo "✅ 已加载 memory_tools.sh"
# 模块：内存管理中心 🧠

memory_management_center() {
  while true; do
    clear
    echo "🧠 内存管理中心"
    echo "────────────────────────────────────────────"
    echo " 1. 查看详细内存信息"
    echo " 2. 查看高内存进程并可选择终止"
    echo " 3. 释放缓存内存"
    echo " 4. 卸载指定程序"
    echo " 5. 设置自动缓存清理任务"
    echo " 6. 内存分析助手"
    echo " 0. 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入操作编号: " mem_choice

    case "$mem_choice" in
      1)
        echo "📊 当前内存详情："
        free -h
        echo ""
        read -p "🔙 回车返回菜单..." ;;
      2)
        echo "📋 高内存进程列表（前20）："
        ps aux --sort=-%mem | awk 'NR<=20{printf "%-10s %-6s %-6s %-6s %-s\n", $1, $2, $3, $4, $11}'
        read -p "⚠️ 输入要终止的 PID（或回车跳过）: " pid
        [[ -n "$pid" ]] && kill -9 "$pid" && echo "✅ 已终止进程 $pid" || echo "🚫 未执行终止"
        read -p "🔙 回车返回菜单..." ;;
      3)
        echo "🧹 正在释放缓存内存..."
        sync && echo 3 > /proc/sys/vm/drop_caches
        echo "✅ 缓存已释放"
        read -p "🔙 回车返回菜单..." ;;
      4)
        read -p "📦 输入要卸载的程序名称: " pkg
        if [[ -n "$pkg" ]]; then
          apt remove --purge -y "$pkg" && echo "✅ 已卸载 $pkg" || echo "❌ 卸载失败"
        else
          echo "🚫 未输入程序名称"
        fi
        read -p "🔙 回车返回菜单..." ;;
      5)
        echo "🕒 设置自动缓存清理任务（每小时执行）"
        cron_cmd="sync && echo 3 > /proc/sys/vm/drop_caches"
        (crontab -l 2>/dev/null; echo "0 * * * * $cron_cmd") | crontab -
        echo "✅ 已添加定时任务到 crontab"
        read -p "🔙 回车返回菜单..." ;;
      6)
        echo "🧠 内存分析助手："
        echo "🔍 总进程数：$(ps aux | wc -l)"
        echo "🔍 使用最多内存的进程："
        ps aux --sort=-%mem | head -n 2
        echo "🔍 当前 swap 使用：$(free -m | awk '/Swap:/ {print $3 "MiB"}')"
        echo "🔍 当前缓存大小：$(free -m | awk '/Mem:/ {print $6 "MiB"}')"
        read -p "🔙 回车返回菜单..." ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" && sleep 1 ;;
    esac
  done
}
