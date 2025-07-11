#!/bin/bash
# 模块：Docker 容器管理中心

docker_management_center() {
  while true; do
    echo -e "\n🐳 Docker 容器管理中心："
    echo "--------------------------------------------"
    containers=($(docker ps -a --format "{{.ID}}|{{.Names}}|{{.Image}}|{{.Status}}"))
    if [[ ${#containers[@]} -eq 0 ]]; then
      echo "⚠️ 当前没有任何容器"
      read -p "按回车键返回主菜单..." && break
    fi

    for i in "${!containers[@]}"; do
      IFS='|' read -r cid name image status <<< "${containers[$i]}"
      echo "$i) $name  —  $image  —  $status"
    done

    echo "--------------------------------------------"
    read -p "👉 请输入容器编号进行管理（直接回车退出）: " index
    [[ -z "$index" ]] && echo "🚪 已退出 Docker 管理中心" && break

    selected="${containers[$index]}"
    IFS='|' read -r cid name image status <<< "$selected"

    echo -e "\n🛠️ 选择操作：容器 [$name]"
    echo " 1) 启动容器"
    echo " 2) 停止容器"
    echo " 3) 卸载容器"
    echo " 4) 更新容器（拉取镜像 + 重启）"
    echo " 5) 查看容器日志"
    echo " 0) 返回容器列表"
    read -p "👉 请输入操作编号: " action

    case $action in
      1)
        docker start "$name" && echo "✅ 容器 $name 已启动" || echo "❌ 启动失败"
        ;;
      2)
        docker stop "$name" && echo "🚫 容器 $name 已停止" || echo "❌ 停止失败"
        ;;
      3)
        read -p "⚠️ 确认要删除容器 $name？(y/N): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
          docker rm -f "$name" && echo "✅ 容器 $name 已删除" || echo "❌ 删除失败"
          log "删除容器：$name"
        else
          echo "🚫 已取消删除"
        fi
        ;;
      4)
        echo "📦 正在拉取最新镜像：$image"
        docker pull "$image"
        echo "🛑 停止并删除旧容器..."
        docker stop "$name" && docker rm "$name"
        echo "🚀 使用原镜像重新启动容器..."
        docker run -d --name "$name" "$image"
        echo "✅ 容器 $name 已更新并重启"
        log "更新容器：$name 使用镜像 $image"
        ;;
      5)
        echo -e "\n📜 容器 $name 的最近日志："
        docker logs --tail 50 "$name"
        ;;
      0) continue ;;
      *) echo "❌ 无效操作编号" ;;
    esac
  done
}
