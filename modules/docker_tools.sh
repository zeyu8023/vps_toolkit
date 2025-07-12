#!/bin/bash
echo "✅ 已加载 docker_tools.sh"
# 模块：Docker 管理中心

docker_management_center() {
  while true; do
    echo -e "\n🐳 Docker 管理中心"
    echo "────────────────────────────────────────────"
    echo " 1) 镜像与容器管理"
    echo " 2) 新建 Docker Compose 项目"
    echo " 3) 编辑正在运行的 Compose 项目"
    echo " 0) 返回主菜单"
    echo "────────────────────────────────────────────"
    read -p "👉 请输入编号: " choice

    case "$choice" in
      1) docker_container_menu ;;
      2) create_compose_project ;;
      3) edit_compose_project ;;
      0) break ;;
      *) echo "❌ 无效选项，请重新输入。" ;;
    esac
  done
}

docker_container_menu() {
  while true; do
    echo -e "\n🐳 Docker 容器管理中心："
    echo "--------------------------------------------"

    containers=()
    while IFS='|' read -r cid name image status; do
      [[ -z "$name" ]] && name="unnamed-$cid"
      [[ -n "$image" ]] && containers+=("$cid|$name|$image|$status")
    done < <(docker ps -a --format "{{.ID}}|{{.Names}}|{{.Image}}|{{.Status}}")

    total=${#containers[@]}
    if [[ $total -eq 0 ]]; then
      echo "⚠️ 当前没有有效容器"
      echo "--------------------------------------------"
      echo " a) 清理无效容器"
      echo " r) 返回上一级"
      read -p "👉 请输入操作选项: " empty_choice
      case "$empty_choice" in
        a) docker container prune -f && echo "✅ 已清理无效容器" ;;
        r) break ;;
        *) echo "❌ 无效选择" ;;
      esac
      continue
    fi

    echo "📦 当前容器数量：$total"
    echo "操作菜单："
    echo " a) 清理无效容器"
    echo " r) 返回上一级"
    echo "--------------------------------------------"

    for ((i=1; i<=total; i++)); do
      IFS='|' read -r cid name image status <<< "${containers[$((i-1))]}"
      compose_flag=""
      compose_project=$(docker inspect "$cid" --format '{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null)
      [[ -n "$compose_project" ]] && compose_flag="🧩 Compose"

      ports=$(docker port "$cid" 2>/dev/null | awk '{print $1 " → " $3}' | paste -sd ", " -)

      if [[ "$status" == *"Up"* ]]; then
        status_display="\033[1;32m运行中\033[0m"
      else
        status_display="\033[1;31m已停止\033[0m"
      fi

      printf "%2d) %-20s %-20s %-10b %-10s 🔌 %s\n" "$i" "$name" "$image" "$status_display" "$compose_flag" "$ports"
    done

    echo "--------------------------------------------"
    read -p "👉 请输入容器编号或操作选项（直接回车退出）: " index
    [[ -z "$index" ]] && echo "🚪 已退出容器管理中心" && break

    if [[ "$index" == "a" ]]; then
      docker container prune -f && echo "✅ 已清理无效容器"
      continue
    elif [[ "$index" == "r" ]]; then
      break
    elif ! [[ "$index" =~ ^[0-9]+$ ]] || (( index < 1 || index > total )); then
      echo "❌ 无效编号"
      continue
    fi

    selected="${containers[$((index-1))]}"
    IFS='|' read -r cid name image status <<< "$selected"

    echo -e "\n🛠️ 选择操作：容器 [$name]"
    echo " 1) 启动容器"
    echo " 2) 停止容器"
    echo " 3) 卸载容器"
    echo " 4) 更新容器（自动识别 compose）"
    echo " 5) 查看容器日志"
    echo " 6) 实时日志跟踪"
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
          ports=$(docker inspect "$cid" --format '{{range $p, $conf := .HostConfig.PortBindings}}{{range $i, $v := $conf}}-p {{$v.HostIp}}:{{$v.HostPort}}:{{$p}} {{end}}{{end}}' 2>/dev/null)

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
      6) echo -e "\n📡 实时日志跟踪（按 Ctrl+C 退出）：" && docker logs -f "$cid" ;;
      0) continue ;;
      *) echo "❌ 无效操作编号" ;;
    esac
  done
}

create_compose_project() {
  echo -e "\n🧩 新建 Docker Compose 项目"
  read -p "请输入项目名称（如 myapp）: " project
  [[ -z "$project" ]] && echo "❌ 项目名称不能为空" && return

  dir="/opt/compose/$project"
  mkdir -p "$dir"
  yml="$dir/docker-compose.yml"

  touch "$yml"
  echo "📁 项目目录已创建：$dir"
  echo "📄 请编辑 docker-compose.yml 配置文件"
  nano "$yml"

  if [[ ! -s "$yml" ]]; then
    echo "⚠️ 配置文件为空，已取消启动"
    return
  fi

  read -p "是否立即启动该项目？(y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    cd "$dir" && docker-compose up -d
    echo "✅ 项目 [$project] 已启动"
    log "新建并启动 Compose 项目：$project"
  else
    echo "🚫 已创建但未启动项目 [$project]"
    log "新建 Compose 项目（未启动）：$project"
  fi
}

edit_compose_project() {
  echo -e "\n🛠️ 编辑 Docker Compose 项目"

  projects=($(docker ps --format '{{.ID}}' | xargs -n1 docker inspect --format '{{ index .Config.Labels "com.docker.compose.project" }}' 2>/dev/null | sort -u | grep -v '^$'))

  if [[ ${#projects[@]} -eq 0 ]]; then
    echo "⚠️ 当前没有运行中的 Compose 项目"
    return
  fi

  echo "📦 当前运行中的 Compose 项目："
  for i in "${!projects[@]}"; do
    echo " $((i+1))) ${projects[$i]}"
  done

  read -p "👉 请输入项目编号: " index
  (( index < 1 || index > ${#projects[@]} )) && echo "❌ 无效编号" && return

  project="${projects[$((index-1))]}"
  compose_dir="/opt/compose/$project"
  yml="$compose_dir/docker-compose.yml"

  if [[ ! -f "$yml" ]]; then
    echo "❌ 未找到配置文件：$yml"
    return
  fi

  echo "📄 当前配置文件路径：$yml"
  read -p "是否编辑该文件？(y/N): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || return

  cp "$yml" "$yml.bak"
  nano "$yml"

  echo "🔄 正在重载服务..."
  cd "$compose_dir" && docker-compose up -d
  echo "✅ 项目 [$project] 已更新"
  log "编辑并重载 Compose 项目：$project"
}
