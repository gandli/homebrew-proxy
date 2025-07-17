#!/bin/bash

# 测试 Casks 目录下所有应用的智能回退匹配策略
echo "🧪 测试 Casks 目录下所有应用的智能回退匹配..."
echo "================================================"

# 获取当前架构
current_arch="aarch64"  # 默认为 arm64
if [[ "$(uname -m)" == "x86_64" ]]; then
  current_arch="x64"
fi
echo "🏗️ 当前架构: $current_arch"
echo ""

# 模拟 GitHub API 响应数据的函数
generate_mock_release() {
  local app_name="$1"
  local version="1.0.0"
  
  # 根据应用名称生成不同的文件命名模式
  case "$app_name" in
    "clash-nyanpasu")
      echo '{
        "tag_name": "v1.6.1",
        "assets": [
          {
            "name": "Clash.Nyanpasu_1.6.1_aarch64.dmg",
            "browser_download_url": "https://example.com/Clash.Nyanpasu_1.6.1_aarch64.dmg"
          },
          {
            "name": "Clash.Nyanpasu_1.6.1_x64.dmg",
            "browser_download_url": "https://example.com/Clash.Nyanpasu_1.6.1_x64.dmg"
          }
        ]
      }'
      ;;
    "clash-verge-rev")
      echo '{
        "tag_name": "v2.3.1",
        "assets": [
          {
            "name": "Clash.Verge_2.3.1_aarch64.dmg",
            "browser_download_url": "https://example.com/Clash.Verge_2.3.1_aarch64.dmg"
          },
          {
            "name": "Clash.Verge_2.3.1_x64.dmg",
            "browser_download_url": "https://example.com/Clash.Verge_2.3.1_x64.dmg"
          }
        ]
      }'
      ;;
    "mihomo-party")
      echo '{
        "tag_name": "v1.0.0",
        "assets": [
          {
            "name": "mihomo-party-macos-1.0.0-arm64.dmg",
            "browser_download_url": "https://example.com/mihomo-party-macos-1.0.0-arm64.dmg"
          },
          {
            "name": "mihomo-party-macos-1.0.0-x64.dmg",
            "browser_download_url": "https://example.com/mihomo-party-macos-1.0.0-x64.dmg"
          }
        ]
      }'
      ;;
    "clashx-meta")
      echo '{
        "tag_name": "v1.3.8",
        "assets": [
          {
            "name": "ClashX.Meta.dmg",
            "browser_download_url": "https://example.com/ClashX.Meta.dmg"
          }
        ]
      }'
      ;;
    "flclash")
      echo '{
        "tag_name": "v0.8.58",
        "assets": [
          {
            "name": "FlClash-0.8.58-macos-universal.dmg",
            "browser_download_url": "https://example.com/FlClash-0.8.58-macos-universal.dmg"
          }
        ]
      }'
      ;;
    "hiddify")
      echo '{
        "tag_name": "v2.0.5",
        "assets": [
          {
            "name": "Hiddify-MacOS-Universal.dmg",
            "browser_download_url": "https://example.com/Hiddify-MacOS-Universal.dmg"
          }
        ]
      }'
      ;;
    "qv2ray")
      echo '{
        "tag_name": "v2.7.0",
        "assets": [
          {
            "name": "Qv2ray.v2.7.0.macOS-x64.dmg",
            "browser_download_url": "https://example.com/Qv2ray.v2.7.0.macOS-x64.dmg"
          }
        ]
      }'
      ;;
    "sfm")
      echo '{
        "tag_name": "v1.4.2",
        "assets": [
          {
            "name": "SFM_1.4.2_aarch64.dmg",
            "browser_download_url": "https://example.com/SFM_1.4.2_aarch64.dmg"
          },
          {
            "name": "SFM_1.4.2_x64.dmg",
            "browser_download_url": "https://example.com/SFM_1.4.2_x64.dmg"
          }
        ]
      }'
      ;;
    "v2rayn")
      echo '{
        "tag_name": "v6.23",
        "assets": [
          {
            "name": "v2rayN-With-Core.zip",
            "browser_download_url": "https://example.com/v2rayN-With-Core.zip"
          },
          {
            "name": "v2rayN-macOS-arm64.dmg",
            "browser_download_url": "https://example.com/v2rayN-macOS-arm64.dmg"
          },
          {
            "name": "v2rayN-macOS-x64.dmg",
            "browser_download_url": "https://example.com/v2rayN-macOS-x64.dmg"
          }
        ]
      }'
      ;;
    "v2rayu")
      echo '{
        "tag_name": "v3.2.0",
        "assets": [
          {
            "name": "V2rayU.dmg",
            "browser_download_url": "https://example.com/V2rayU.dmg"
          }
        ]
      }'
      ;;
    *)
      # 通用模式：基于应用名称生成标准格式的文件
      app_title=$(echo "$app_name" | sed 's/-/ /g' | sed 's/\b\w/\U&/g' | tr ' ' '.')
      echo '{
        "tag_name": "v1.0.0",
        "assets": [
          {
            "name": "'$app_title'_1.0.0_aarch64.dmg",
            "browser_download_url": "https://example.com/'$app_title'_1.0.0_aarch64.dmg"
          },
          {
            "name": "'$app_title'_1.0.0_x64.dmg",
            "browser_download_url": "https://example.com/'$app_title'_1.0.0_x64.dmg"
          }
        ]
      }'
      ;;
  esac
}

# 智能匹配测试函数
test_smart_matching() {
  local cask_name="$1"
  local latest_release="$2"
  local cask_file="Casks/${cask_name}.rb"
  
  echo "📦 测试 $cask_name"
  
  # 检查 cask 文件是否存在
  if [[ ! -f "$cask_file" ]]; then
    echo "   ❌ Cask 文件不存在: $cask_file"
    return 1
  fi
  
  # 提取基础名称
  base_name="$cask_name"
  
  # 第一步：提取应用名称
  app_line=$(grep -E '^\s*app\s+' "$cask_file" | head -1)
  app_name=""
  if [[ "$app_line" =~ [[:space:]]*app[[:space:]]+\"([^\"]+)\"\.app ]]; then
    app_name="${BASH_REMATCH[1]}"
    echo "   📱 应用名称: '$app_name'"
  fi
  
  # 第二步：构建智能搜索模式
  declare -a search_strategies
  
  # 策略1：基于应用名称的精确匹配
  if [[ -n "$app_name" ]]; then
    app_base=$(echo "$app_name" | tr ' ' '.' | tr '[:upper:]' '[:lower:]')
    search_strategies+=(
      "exact_app:$app_base"
      "exact_app_arch:$app_base.*$current_arch"
    )
  fi
  
  # 策略2：基于 cask 名称的变体匹配
  cask_base=$(echo "$base_name" | tr '[:upper:]' '[:lower:]')
  search_strategies+=(
    "cask_original:$cask_base"
    "cask_dots:$(echo "$cask_base" | tr '-' '.')"
    "cask_underscores:$(echo "$cask_base" | tr '-' '_')"
    "cask_arch:$cask_base.*$current_arch"
    "cask_dots_arch:$(echo "$cask_base" | tr '-' '.').*$current_arch"
  )
  
  # 策略3：部分匹配（去除常见后缀）
  if [[ "$cask_base" =~ (.+)-(rev|nightly|beta|alpha|dev|party|meta)$ ]]; then
    partial_name="${BASH_REMATCH[1]}"
    search_strategies+=(
      "partial:$partial_name"
      "partial_dots:$(echo "$partial_name" | tr '-' '.')"
      "partial_arch:$partial_name.*$current_arch"
    )
  fi
  
  # 第三步：多轮匹配执行
  fallback_url=""
  matched_strategy=""
  
  for strategy in "${search_strategies[@]}"; do
    strategy_name="${strategy%%:*}"
    pattern="${strategy#*:}"
    
    # 优先匹配当前架构的文件
    fallback_url=$(echo "$latest_release" | \
      jq -r --arg pattern "$pattern" --arg arch "$current_arch" '
        .assets[] | 
        select(.name | ascii_downcase | test($pattern; "i")) |
        select(.name | endswith(".dmg")) |
        select(.name | contains($arch)) |
        .browser_download_url
      ' | head -1)
    
    # 如果没找到架构特定的，尝试通用匹配
    if [[ -z "$fallback_url" || "$fallback_url" == "null" ]]; then
      fallback_url=$(echo "$latest_release" | \
        jq -r --arg pattern "$pattern" '
          .assets[] | 
          select(.name | ascii_downcase | test($pattern; "i")) |
          select(.name | endswith(".dmg")) |
          .browser_download_url
        ' | head -1)
    fi
    
    if [[ -n "$fallback_url" && "$fallback_url" != "null" ]]; then
      matched_strategy="$strategy_name"
      matched_asset=$(echo "$latest_release" | \
        jq -r --arg url "$fallback_url" '.assets[] | select(.browser_download_url == $url) | .name')
      echo "   ✅ 匹配成功！策略: [$strategy_name], 模式: '$pattern'"
      echo "   📄 匹配文件: $matched_asset"
      return 0
    fi
  done
  
  echo "   ❌ 匹配失败"
  echo "   📦 可用的 dmg 文件:"
  echo "$latest_release" | jq -r '.assets[] | select(.name | endswith(".dmg")) | .name' | sed 's/^/      - /'
  return 1
}

# 获取所有 cask 文件
cask_files=($(find Casks -name "*.rb" -type f | sort))
echo "🔍 发现 ${#cask_files[@]} 个 cask 文件"
echo ""

# 运行测试
success_count=0
total_count=0
failed_casks=()

for cask_file in "${cask_files[@]}"; do
  cask_name=$(basename "$cask_file" .rb)
  echo "----------------------------------------"
  
  # 生成模拟数据
  test_data=$(generate_mock_release "$cask_name")
  
  if [[ -n "$test_data" ]]; then
    test_smart_matching "$cask_name" "$test_data"
    if [[ $? -eq 0 ]]; then
      ((success_count++))
    else
      failed_casks+=("$cask_name")
    fi
    ((total_count++))
  else
    echo "📦 跳过 $cask_name (无法生成测试数据)"
    failed_casks+=("$cask_name")
  fi
done

echo ""
echo "========================================"
echo "🏁 测试完成"
echo "📊 成功率: $success_count/$total_count ($(( success_count * 100 / total_count ))%)"

if [[ ${#failed_casks[@]} -gt 0 ]]; then
  echo "❌ 失败的应用:"
  for failed in "${failed_casks[@]}"; do
    echo "   - $failed"
  done
fi

if [[ $success_count -eq $total_count ]]; then
  echo "🎉 所有测试通过！"
  exit 0
else
  echo "⚠️  部分测试失败，建议检查失败的应用"
  exit 1
fi