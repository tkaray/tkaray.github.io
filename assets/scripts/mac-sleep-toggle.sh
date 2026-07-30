#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
用法:
  $0 nosleep    # 合盖/空闲时尽量保持运行，适合跑 Codex
  $0 sleep      # 恢复允许睡眠
  $0 status     # 查看当前关键电源设置

兼容别名:
  $0 on         # 等同 nosleep
  $0 off        # 等同 sleep
EOF
}

check_env() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo "错误：这个脚本只适用于 macOS。"
    exit 1
  fi

  if ! command -v pmset >/dev/null 2>&1; then
    echo "错误：找不到 pmset。"
    exit 1
  fi
}

# macOS 将 `pmset ... disablesleep` 的当前系统级状态回显为
# `SleepDisabled`。少数旧版本可能只在 `pmset -g custom` 中显示
# `disablesleep`，所以同时保留兼容读取。
read_sleep_disabled() {
  local pmset_global="${1:-}"
  local pmset_custom="${2:-}"
  local value

  value="$(awk '$1 == "SleepDisabled" {print $2; exit}' <<< "${pmset_global}")"
  if [[ -z "${value}" ]]; then
    value="$(awk '$1 == "disablesleep" {print $2; exit}' <<< "${pmset_custom}")"
  fi

  printf '%s' "${value}"
}

read_custom_value() {
  local pmset_custom="${1:-}"
  local power_source="${2:-}"
  local key="${3:-}"

  awk -v power_source="${power_source}" -v key="${key}" '
    $0 == power_source ":" {
      in_requested_source = 1
      next
    }
    /^[^[:space:]].* Power:$/ {
      if (in_requested_source) {
        exit
      }
      in_requested_source = 0
    }
    in_requested_source && $1 == key {
      print $2
      exit
    }
  ' <<< "${pmset_custom}"
}

show_status() {
  local pmset_global
  local pmset_custom
  local power_source
  local displaysleep_value
  local sleep_value
  local disksleep_value
  local sleep_disabled_value

  pmset_global="$(pmset -g)"
  pmset_custom="$(pmset -g custom 2>/dev/null || true)"
  power_source="$(pmset -g ps 2>/dev/null | sed -n "s/^Now drawing from '\\(.*\\)'$/\\1/p")"

  displaysleep_value="$(read_custom_value "${pmset_custom}" "${power_source}" "displaysleep")"
  sleep_value="$(read_custom_value "${pmset_custom}" "${power_source}" "sleep")"
  disksleep_value="$(read_custom_value "${pmset_custom}" "${power_source}" "disksleep")"
  sleep_disabled_value="$(read_sleep_disabled "${pmset_global}" "${pmset_custom}")"

  echo "当前关键 pmset 设置（${power_source:-电源来源未知}）："
  echo "  displaysleep = ${displaysleep_value:-unknown}"
  echo "  sleep        = ${sleep_value:-unknown}"
  echo "  disksleep    = ${disksleep_value:-unknown}"

  if [[ -n "${sleep_disabled_value}" ]]; then
    echo "  disablesleep = ${sleep_disabled_value}（pmset 回显为 SleepDisabled）"
  else
    echo "  disablesleep = unknown（pmset 未回显）"
  fi

  echo

  if [[ "${sleep_disabled_value}" == "1" ]]; then
    echo "状态：当前为不能睡眠模式（SleepDisabled = 1）。"
  elif [[ "${sleep_disabled_value}" == "0" && "${sleep_value}" == "0" ]]; then
    echo "状态：系统允许睡眠，但空闲自动睡眠计时器已关闭。"
  elif [[ "${sleep_disabled_value}" == "0" ]]; then
    echo "状态：当前为允许睡眠模式。"
  elif [[ "${sleep_value}" == "0" ]]; then
    echo "状态：无法确认是否完全禁用睡眠；空闲自动睡眠计时器已关闭。"
  else
    echo "状态：无法确认当前是否禁用睡眠。"
  fi
}

verify_sleep_disabled() {
  local expected="$1"
  local pmset_global
  local pmset_custom
  local actual

  pmset_global="$(pmset -g)"
  pmset_custom="$(pmset -g custom 2>/dev/null || true)"
  actual="$(read_sleep_disabled "${pmset_global}" "${pmset_custom}")"

  if [[ "${actual}" != "${expected}" ]]; then
    echo "错误：pmset 命令已执行，但验证失败：期望 SleepDisabled=${expected}，实际为 ${actual:-unknown}。" >&2
    return 1
  fi
}

enable_nosleep() {
  echo "切换到不能睡眠模式，需要 sudo 权限。"
  sudo -v

  sudo pmset -a disablesleep 1 sleep 0 disksleep 0 displaysleep 10
  verify_sleep_disabled 1

  echo
  echo "已切换到不能睡眠模式，并通过 SleepDisabled 状态验证。"
  echo "显示器可在 10 分钟后关闭，但系统会尽量继续运行。"
  echo
  show_status
}

enable_sleep() {
  echo "切换到允许睡眠模式，需要 sudo 权限。"
  sudo -v

  sudo pmset -a disablesleep 0 sleep 10 disksleep 10 displaysleep 10
  verify_sleep_disabled 0

  echo
  echo "已切换到允许睡眠模式，并通过 SleepDisabled 状态验证。"
  echo
  show_status
}

check_env

case "${1:-}" in
  nosleep|no-sleep|awake|keep-awake|on)
    enable_nosleep
    ;;
  sleep|normal|restore|off)
    enable_sleep
    ;;
  status|s)
    show_status
    ;;
  -h|--help|help|"")
    usage
    ;;
  *)
    echo "未知参数：$1"
    echo
    usage
    exit 1
    ;;
esac
