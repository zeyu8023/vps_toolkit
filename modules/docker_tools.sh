#!/bin/bash
# 模块：Docker 容器管理中心

docker_management_center() {
  while true; do
    echo -e "\n🐳 Docker 容器管理中心："
    echo "--------------------------------------------"

    containers=()
    while IFS='|' read -r cid name image status; do
      [[ -z "$name" ]] && name="unnamed-$cid"
      [[ -n "$image" ]] && containers+=("$cid|$name|$image|$status")
    done < <(docker ps -a --format "{{.ID}}|{{.Names}}|{{.Image}}|{{.Status}}")

    if [[ ${#containers[@]} -eq 0 ]]; then
      echo "⚠️ 当前没有有效容器"
      echo "--------------------------------------------"
      echo " 1) 清理无效容器"
      echo " 0) 返回主菜单"
      read -p "👉 请输入编号: " empty_choice
      case $empty_choice in
        1) docker container prune -f && echo "✅ 已清理无效容器" ;;
        0) break ;;
        *) echo "❌ 无效选择" ;;
      esac
      continue
    fi

    for i in "${!containers[@]}"; do
      IFS='|' read -r cid name image status <<< "${containers[$i]}"
      compose_flag=""
      compose_project=$(docker inspect "$cid" --format '{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null)
      [[ -n "$compose_project" ]] && compose_flag="🧩 Compose"
      ports=$(docker port "$cid" 2>/dev/null | awk '{print $1 " → " $3}' | paste -sd ", " -)
      echo "$i) $name  —  $image  —  $status $compose_flag  —  🔌 $ports"
    done

    echo "--------------------------------------------"
    echo " a) 清理无效容器"
    echo " 0) 返回主菜单"
    read -p "👉 请输入容器编号或操作选项（直接回车退出）: " index
    [[ -z "$index" ]] && echo "🚪 已退出 Docker 管理中心" && break
    [[ "$index" == "a" ]] && docker container prune -f && echo "✅ 已清理无效容器" && continue

    selected="${containers[$index]}"
    IFS='|' read -r cid name image status <<< "$selected"

    echo -e "\n🛠️ 选择操作：容器 [$name]"
    echo " 1) 启动容器"
    echo " 2) 停止容器"
    echo " 3) 卸载容器"
    echo " 4) 更新容器（自动识别 compose）"
    echo " 5) 查看容器日志"
    echo " 0) 返回容器列表"
    read -p "👉 请输入操作编号: " action

    case $action in
      1) docker start "$cid" && echo "✅ 容器 $name 已启动" || echo "❌ 启动失败" ;;
      2) docker stop "$cid" && echo "🚫 容器 $name 已停止" || echo "❌ 停止失败" ;;
      3)
        read -p "⚠️ 确认要删除容器 $name？(y/N): " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] && docker rm -f "$cid" && echo "✅ 容器 $name 已删除" && log "删除容器：$name" || echo "🚫 已取消删除"
        ;;
      4)
        echo "📦 正在拉取最新镜像：$image"
        docker pull "$image"

        compose_project=$(docker inspect "$cid" --format '{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null)

        if [[ -n "$compose_project" ]]; then
          echo "📦 检测到 docker-compose 管理容器 [$compose_project]"
          compose_dir=$(docker inspect "$cid" --format '{{ index .Config.Labels "com.docker.compose.project.working_dir" }}' 2>/dev/null)
          [[ -z "$compose_dir" ]] && compose_dir="/opt/compose/$compose_project"

          if [[ -f "$compose_dir/docker-compose.yml" ]]; then
            echo "📁 切换到 compose 目录：$compose_dir"
            cd "$compose_dir"
            docker-compose pull
            docker-compose up -d
            echo "✅ 已通过 docker-compose 更新容器 [$name]"
            log "更新容器（compose）：$name 使用镜像 $image"
          else
            echo "❌ 未找到 docker-compose.yml，请检查路径：$compose_dir"
          fi
        else
          echo "🔍 正在提取原容器配置..."
          envs=$(docker inspect "$cid" --format '{{range .Config.Env}}-e {{.}} {{end}}' 2>/dev/null)
          vols=$(docker inspect "$cid" --format '{{range .HostConfig.Binds}}-v {{.}} {{end}}' 2>/dev/null)
          ports=$(docker inspect "$cid" --format '{{range $p, $conf := .HostConfig.PortBindings}}-p {{$conf[0].HostPort}}:{{$p}} {{end}}' 2>/dev/null)

          echo "📝 配置预览："
          echo "环境变量：$envs"
          echo "挂载卷：$vols"
          echo "端口映射：$ports"
          log "更新容器前配置备份：$name | $envs $vols $ports"

          echo "🛑 停止并删除旧容器..."
          docker stop "$cid" && docker rm "$cid"

          echo "🚀 使用原配置重新启动容器..."
          docker run -d --name "$name" $envs $vols $ports "$image"
          echo "✅ 容器 $name 已更新并重启"
          log "更新容器：$name 使用镜像 $image（保留原配置）"
        fi
        ;;
      5) echo -e "\n📜 容器 $name 的最近日志：" && docker logs --tail 50 "$cid" ;;
      0) continue ;;
      *) echo "❌ 无效操作编号" ;;
    esac
  done
}
