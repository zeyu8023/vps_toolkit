#!/bin/bash
# 模块：内存工具

show_memory_info() {
  echo -e "\n📊 当前内存信息："
  free -h
}

manage_memory_processes() {
  echo -e "\n📋 高内存占用进程（前 15 个）："
  echo "--------------------------------------------"
  ps -eo pid,comm,rss --sort=-rss | awk 'NR==1{printf "%-4s %-8s %-25s %-10s\n", "No.", "PID", "COMMAND", "MEM(MiB)"; next}
  {printf "%-4d %-8d %-25s %-10.2f\n", NR-1, $1, $2, $3/1024}' | head -n 16
  echo "--------------------------------------------"
  read -p "👉 输入要终止的 PID（留空跳过）: " pid
  if [[ -n "$pid" ]]; then
    kill -9 "$pid" && echo "✅ 已终止进程 $pid" || echo "❌ 无法终止进程 $pid"
    log "终止进程：PID $pid"
  else
    echo "🚫 未输入 PID，未执行终止操作"
  fi
}

clear_memory_cache() {
  sync; echo 3 > /proc/sys/vm/drop_caches
  echo "✅ 缓存已释放"
}

setup_auto_cache_clear() {
  echo "0 * * * * root sync; echo 3 > /proc/sys/vm/drop_caches" > /etc/cron.d/clear_cache
  echo "✅ 已设置每小时自动清理缓存"
}

memory_analysis() {
  echo -e "\n🧠 内存分析助手："
  ps aux --sort=-%mem | awk 'NR<=10{print $0}'
}
