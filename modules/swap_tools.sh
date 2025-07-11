#!/bin/bash
# 模块：Swap 管理工具

enable_swap() {
  read -p "请输入 Swap 大小（MB）: " size
  fallocate -l ${size}M /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo "/swapfile none swap sw 0 0" >> /etc/fstab
  echo "✅ Swap 启用成功"
  log "启用 Swap：${size}MB"
}

disable_swap() {
  swapoff /swapfile && rm -f /swapfile
  sed -i '/swapfile/d' /etc/fstab
  echo "✅ Swap 已删除"
  log "删除 Swap"
}
