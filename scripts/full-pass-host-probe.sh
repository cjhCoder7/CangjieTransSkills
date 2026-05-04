#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="$ROOT_DIR/artifacts/environment/full-pass-host-profile.json"
LOG_PATH="$ROOT_DIR/artifacts/environment/full-pass-connectivity-check.log"
FAIL_IF_BLOCKED=0

usage() {
  cat <<'USAGE'
Usage:
  scripts/full-pass-host-probe.sh [--output PATH] [--log PATH] [--fail-if-blocked]

Options:
  --output PATH           JSON 输出路径，默认 artifacts/environment/full-pass-host-profile.json
  --log PATH              文本日志路径，默认 artifacts/environment/full-pass-connectivity-check.log
  --fail-if-blocked       若环境未满足 Staging-Full 条件，则以退出码 2 结束
  -h, --help              显示帮助
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    --log)
      LOG_PATH="$2"
      shift 2
      ;;
    --fail-if-blocked)
      FAIL_IF_BLOCKED=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[full-pass-host-probe] unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

mkdir -p "$(dirname "$OUTPUT_PATH")" "$(dirname "$LOG_PATH")"
: > "$LOG_PATH"

log() {
  printf '%s\n' "$*" | tee -a "$LOG_PATH"
}

command_path() {
  command -v "$1" 2>/dev/null || true
}

join_by() {
  local delimiter="$1"
  shift || true
  local result=""
  local item=""
  for item in "$@"; do
    if [[ -z "$result" ]]; then
      result="$item"
    else
      result="$result$delimiter$item"
    fi
  done
  printf '%s' "$result"
}

PYTHON_BIN="$(command_path python3)"
if [[ -z "$PYTHON_BIN" ]]; then
  PYTHON_BIN="$(command_path python)"
fi
if [[ -z "$PYTHON_BIN" ]]; then
  echo "[full-pass-host-probe] python3/python is required to emit JSON" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

write_lines() {
  local target="$1"
  shift || true
  : > "$target"
  local item=""
  for item in "$@"; do
    printf '%s\n' "$item" >> "$target"
  done
}

NOW_UTC="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
HOST_OS="$(uname -s)"
HOST_KERNEL="$(uname -r)"
HOST_ARCH="$(uname -m)"
HOSTNAME_VALUE="$(hostname 2>/dev/null || true)"
DISPLAY_VALUE="${DISPLAY:-}"
WAYLAND_VALUE="${WAYLAND_DISPLAY:-}"
SESSION_TYPE_VALUE="${XDG_SESSION_TYPE:-}"

CJC_PATH=""
CJPM_PATH=""
if [[ -x "$ROOT_DIR/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc" ]]; then
  CJC_PATH="$ROOT_DIR/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc"
else
  CJC_PATH="$(command_path cjc)"
fi
if [[ -x "$ROOT_DIR/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm" ]]; then
  CJPM_PATH="$ROOT_DIR/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm"
else
  CJPM_PATH="$(command_path cjpm)"
fi

DEVECO_CMD="$(command_path deveco-studio)"
if [[ -z "$DEVECO_CMD" ]]; then
  DEVECO_CMD="$(command_path devecostudio)"
fi
HDC_PATH="$(command_path hdc)"
ADB_PATH="$(command_path adb)"

mapfile -t DEVECO_DIR_CANDIDATES < <(
  {
    [[ -n "${DEVECO_STUDIO_HOME:-}" ]] && printf '%s\n' "${DEVECO_STUDIO_HOME}"
    printf '%s\n' \
      "/opt/DevEco-Studio" \
      "/opt/devecostudio" \
      "$HOME/DevEco-Studio" \
      "$HOME/.local/share/DevEco-Studio" \
      "$HOME/.DevEcoStudio"
  } | awk 'NF' | while read -r candidate; do
    [[ -e "$candidate" ]] && printf '%s\n' "$candidate"
  done | awk '!seen[$0]++'
)

DEVECO_HOME=""
if [[ -n "$DEVECO_CMD" ]]; then
  DEVECO_HOME="$(cd "$(dirname "$DEVECO_CMD")/.." 2>/dev/null && pwd || true)"
elif [[ ${#DEVECO_DIR_CANDIDATES[@]} -gt 0 ]]; then
  DEVECO_HOME="${DEVECO_DIR_CANDIDATES[0]}"
fi

mapfile -t PLUGIN_ARCHIVES < <(find "$ROOT_DIR/资源" -maxdepth 1 -type f -iname 'devecostudio-cangjie-plugin*' 2>/dev/null | sort)
mapfile -t PLUGIN_INSTALL_CANDIDATES < <(
  {
    [[ -n "${CANGJIE_PLUGIN_HOME:-}" ]] && printf '%s\n' "${CANGJIE_PLUGIN_HOME}"
    if [[ -n "$DEVECO_HOME" && -d "$DEVECO_HOME/plugins" ]]; then
      find "$DEVECO_HOME/plugins" -maxdepth 2 \( -iname '*cangjie*' -o -iname '*仓颉*' \) 2>/dev/null
    fi
  } | awk 'NF' | awk '!seen[$0]++'
)

CURRENT_PID="$$"
CURRENT_PPID="${PPID:-}"
ps -eo pid=,ppid=,args= > "$TMP_DIR/ps_all.txt" || true
awk -v self_pid="$CURRENT_PID" -v parent_pid="$CURRENT_PPID" '
  BEGIN { IGNORECASE = 1 }
  {
    pid = $1
    ppid = $2
    $1 = ""
    $2 = ""
    sub(/^[[:space:]]+/, "", $0)
    if (pid == self_pid || ppid == self_pid || pid == parent_pid) next
    if ($0 ~ /(full-pass-host-probe\.sh|ps -eo pid=,ppid=,args=|rg -i|grep -i)/) next
    if ($0 ~ /qemu-system|qemu-kvm|openharmony[^[:space:]]*emulator|harmony[^[:space:]]*emulator|(^|[[:space:]\/])(emulator|simulator)([[:space:]-]|$)/) print
  }
' "$TMP_DIR/ps_all.txt" > "$TMP_DIR/processes.txt" || true
mapfile -t GUI_PROCESSES < "$TMP_DIR/processes.txt"

KVM_AVAILABLE=false
[[ -e /dev/kvm ]] && KVM_AVAILABLE=true
find /dev -maxdepth 1 \( -name 'dri' -o -name 'dri*' \) 2>/dev/null | sort > "$TMP_DIR/dri_devices.txt" || true
mapfile -t DRI_DEVICES < "$TMP_DIR/dri_devices.txt"

HDC_TARGET_COUNT=0
ADB_DEVICE_COUNT=0
: > "$TMP_DIR/hdc_targets.txt"
: > "$TMP_DIR/adb_devices.txt"
: > "$TMP_DIR/hdc_raw.txt"
: > "$TMP_DIR/adb_raw.txt"

if [[ -n "$HDC_PATH" ]]; then
  "$HDC_PATH" list targets > "$TMP_DIR/hdc_raw.txt" 2>&1 || true
  awk 'NF' "$TMP_DIR/hdc_raw.txt" | awk '!/Empty/ && !/target/ {print}' > "$TMP_DIR/hdc_targets.txt" || true
fi
if [[ -n "$ADB_PATH" ]]; then
  "$ADB_PATH" devices > "$TMP_DIR/adb_raw.txt" 2>&1 || true
  awk 'NF && $1 != "List" {print $1}' "$TMP_DIR/adb_raw.txt" > "$TMP_DIR/adb_devices.txt" || true
fi

mapfile -t HDC_TARGETS < "$TMP_DIR/hdc_targets.txt"
mapfile -t ADB_DEVICES < "$TMP_DIR/adb_devices.txt"
HDC_TARGET_COUNT="${#HDC_TARGETS[@]}"
ADB_DEVICE_COUNT="${#ADB_DEVICES[@]}"

LOCAL_CANGJIE_CLI=false
[[ -n "$CJC_PATH" && -n "$CJPM_PATH" ]] && LOCAL_CANGJIE_CLI=true
DEVECO_INSTALLED=false
[[ -n "$DEVECO_HOME" ]] && DEVECO_INSTALLED=true
CANGJIE_PLUGIN_INSTALLED=false
[[ ${#PLUGIN_INSTALL_CANDIDATES[@]} -gt 0 ]] && CANGJIE_PLUGIN_INSTALLED=true
HDC_INSTALLED=false
[[ -n "$HDC_PATH" ]] && HDC_INSTALLED=true
ADB_INSTALLED=false
[[ -n "$ADB_PATH" ]] && ADB_INSTALLED=true
DISPLAY_SESSION_AVAILABLE=false
[[ -n "$DISPLAY_VALUE" || -n "$WAYLAND_VALUE" || -n "$SESSION_TYPE_VALUE" ]] && DISPLAY_SESSION_AVAILABLE=true
GUI_EMULATOR_DETECTED=false
[[ ${#GUI_PROCESSES[@]} -gt 0 ]] && GUI_EMULATOR_DETECTED=true
TARGET_CHANNEL_READY=false
if [[ "$HDC_TARGET_COUNT" -gt 0 || "$ADB_DEVICE_COUNT" -gt 0 ]]; then
  TARGET_CHANNEL_READY=true
fi

RECOMMENDATION=""
BLOCKERS=()
if [[ "$DEVECO_INSTALLED" != true ]]; then
  BLOCKERS+=("未发现 DevEco Studio 可执行安装")
fi
if [[ "$CANGJIE_PLUGIN_INSTALLED" != true ]]; then
  BLOCKERS+=("未发现已安装的仓颉插件，仅发现本地插件压缩包或无安装证据")
fi
if [[ "$HDC_INSTALLED" != true && "$ADB_INSTALLED" != true ]]; then
  BLOCKERS+=("未发现 hdc/adb，设备或模拟器联调通道缺失")
fi
if [[ "$TARGET_CHANNEL_READY" != true ]]; then
  BLOCKERS+=("未检测到 emulator/真机 target，无法执行 Full Pass 部署与日志回采")
fi
if [[ "$DISPLAY_SESSION_AVAILABLE" != true && "$GUI_EMULATOR_DETECTED" != true && "$TARGET_CHANNEL_READY" != true ]]; then
  BLOCKERS+=("当前宿主无 GUI session、无 emulator 进程、无已连接 target，属于 Headless CLI 节点")
fi

STAGING_FULL_READY=false
if [[ "$DEVECO_INSTALLED" == true && "$CANGJIE_PLUGIN_INSTALLED" == true && ( "$HDC_INSTALLED" == true || "$ADB_INSTALLED" == true ) && "$TARGET_CHANNEL_READY" == true ]]; then
  STAGING_FULL_READY=true
fi

ASSESSMENT_PATH="B"
if [[ "$STAGING_FULL_READY" == true ]]; then
  ASSESSMENT_PATH="A"
  RECOMMENDATION="当前宿主已具备继续验证真实 Harmony UI / 主线程物理证据的基础条件，可进入 Full Pass 计划细化。"
else
  RECOMMENDATION="优先锁定 Staging-Full 宿主拓扑；若 Linux 无头模拟器没有官方稳定证据，则默认迁移到 macOS/Windows 实体机或接入真机。"
fi

write_lines "$TMP_DIR/blockers.txt" "${BLOCKERS[@]}"
write_lines "$TMP_DIR/plugin_archives.txt" "${PLUGIN_ARCHIVES[@]}"
write_lines "$TMP_DIR/plugin_installs.txt" "${PLUGIN_INSTALL_CANDIDATES[@]}"
write_lines "$TMP_DIR/deveco_dirs.txt" "${DEVECO_DIR_CANDIDATES[@]}"
write_lines "$TMP_DIR/gui_processes.txt" "${GUI_PROCESSES[@]}"
write_lines "$TMP_DIR/dri_devices_lines.txt" "${DRI_DEVICES[@]}"

log "[full-pass-host-probe] captured_at_utc=$NOW_UTC"
log "[full-pass-host-probe] host=$HOST_OS/$HOST_ARCH kernel=$HOST_KERNEL hostname=$HOSTNAME_VALUE"
log "[full-pass-host-probe] display DISPLAY=${DISPLAY_VALUE:-<empty>} WAYLAND_DISPLAY=${WAYLAND_VALUE:-<empty>} XDG_SESSION_TYPE=${SESSION_TYPE_VALUE:-<empty>}"
log "[full-pass-host-probe] local_cangjie_cli=$LOCAL_CANGJIE_CLI cjc=${CJC_PATH:-<missing>} cjpm=${CJPM_PATH:-<missing>}"
log "[full-pass-host-probe] deveco_installed=$DEVECO_INSTALLED deveco_home=${DEVECO_HOME:-<missing>} plugin_installed=$CANGJIE_PLUGIN_INSTALLED"
log "[full-pass-host-probe] hdc_installed=$HDC_INSTALLED adb_installed=$ADB_INSTALLED hdc_targets=$HDC_TARGET_COUNT adb_devices=$ADB_DEVICE_COUNT"
log "[full-pass-host-probe] gui_emulator_detected=$GUI_EMULATOR_DETECTED kvm_available=$KVM_AVAILABLE dri_devices=$(join_by ',' "${DRI_DEVICES[@]}")"
log "[full-pass-host-probe] staging_full_ready=$STAGING_FULL_READY assessment_path=$ASSESSMENT_PATH"
if [[ ${#BLOCKERS[@]} -gt 0 ]]; then
  for blocker in "${BLOCKERS[@]}"; do
    log "[full-pass-host-probe] blocker=$blocker"
  done
fi

export NOW_UTC HOST_OS HOST_KERNEL HOST_ARCH HOSTNAME_VALUE
export DISPLAY_VALUE WAYLAND_VALUE SESSION_TYPE_VALUE
export CJC_PATH CJPM_PATH DEVECO_CMD DEVECO_HOME HDC_PATH ADB_PATH
export LOCAL_CANGJIE_CLI DEVECO_INSTALLED CANGJIE_PLUGIN_INSTALLED HDC_INSTALLED ADB_INSTALLED
export DISPLAY_SESSION_AVAILABLE GUI_EMULATOR_DETECTED TARGET_CHANNEL_READY STAGING_FULL_READY KVM_AVAILABLE
export ASSESSMENT_PATH OUTPUT_PATH LOG_PATH RECOMMENDATION
export HDC_TARGET_COUNT ADB_DEVICE_COUNT
export TMP_DIR
"$PYTHON_BIN" - <<'PY'
import json
import os
from pathlib import Path

def read_lines(name: str):
    path = Path(os.environ['TMP_DIR']) / name
    if not path.exists():
        return []
    return [line.strip() for line in path.read_text().splitlines() if line.strip()]

def read_text(name: str):
    path = Path(os.environ['TMP_DIR']) / name
    if not path.exists():
        return ""
    return path.read_text()

def to_bool(value: str) -> bool:
    return value.lower() == 'true'

payload = {
    'label': 'phase03-full-pass-host-profile',
    'captured_at_utc': os.environ['NOW_UTC'],
    'host': {
        'os': os.environ['HOST_OS'],
        'kernel': os.environ['HOST_KERNEL'],
        'arch': os.environ['HOST_ARCH'],
        'hostname': os.environ.get('HOSTNAME_VALUE', ''),
    },
    'display': {
        'DISPLAY': os.environ.get('DISPLAY_VALUE', ''),
        'WAYLAND_DISPLAY': os.environ.get('WAYLAND_VALUE', ''),
        'XDG_SESSION_TYPE': os.environ.get('SESSION_TYPE_VALUE', ''),
        'display_session_available': to_bool(os.environ['DISPLAY_SESSION_AVAILABLE']),
    },
    'paths': {
        'cjc': os.environ.get('CJC_PATH', ''),
        'cjpm': os.environ.get('CJPM_PATH', ''),
        'deveco_studio_command': os.environ.get('DEVECO_CMD', ''),
        'deveco_studio_home': os.environ.get('DEVECO_HOME', ''),
        'hdc': os.environ.get('HDC_PATH', ''),
        'adb': os.environ.get('ADB_PATH', ''),
    },
    'toolchain': {
        'local_cangjie_cli': to_bool(os.environ['LOCAL_CANGJIE_CLI']),
        'deveco_studio_installed': to_bool(os.environ['DEVECO_INSTALLED']),
        'cangjie_plugin_installed': to_bool(os.environ['CANGJIE_PLUGIN_INSTALLED']),
        'hdc_installed': to_bool(os.environ['HDC_INSTALLED']),
        'adb_installed': to_bool(os.environ['ADB_INSTALLED']),
    },
    'virtualization': {
        'kvm_available': to_bool(os.environ['KVM_AVAILABLE']),
        'dri_devices': read_lines('dri_devices_lines.txt'),
        'gui_emulator_detected': to_bool(os.environ['GUI_EMULATOR_DETECTED']),
        'matching_processes': read_lines('gui_processes.txt'),
    },
    'device_connectivity': {
        'target_channel_ready': to_bool(os.environ['TARGET_CHANNEL_READY']),
        'hdc_target_count': int(os.environ['HDC_TARGET_COUNT']),
        'hdc_targets': read_lines('hdc_targets.txt'),
        'hdc_raw_output': read_text('hdc_raw.txt'),
        'adb_device_count': int(os.environ['ADB_DEVICE_COUNT']),
        'adb_devices': read_lines('adb_devices.txt'),
        'adb_raw_output': read_text('adb_raw.txt'),
    },
    'local_assets': {
        'deveco_dir_candidates': read_lines('deveco_dirs.txt'),
        'plugin_archives': read_lines('plugin_archives.txt'),
        'plugin_install_candidates': read_lines('plugin_installs.txt'),
    },
    'assessment': {
        'path': os.environ['ASSESSMENT_PATH'],
        'staging_full_ready': to_bool(os.environ['STAGING_FULL_READY']),
        'blockers': read_lines('blockers.txt'),
        'recommendation': os.environ.get('RECOMMENDATION', ''),
        'log_path': os.environ['LOG_PATH'],
    },
}
Path(os.environ['OUTPUT_PATH']).write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n')
PY

if [[ "$FAIL_IF_BLOCKED" -eq 1 && "$STAGING_FULL_READY" != true ]]; then
  exit 2
fi
