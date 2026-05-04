#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_NAME="$(basename "$0")"
PYTHON_BIN="${PYTHON_BIN:-$(command -v python3 || command -v python || true)}"
BUILDER_PATH="$ROOT_DIR/scripts/full-pass-summary-builder.py"

CYCLE=""
SUMMARY_PATH=""
RUN_ROOT=""
TARGET_FILE=""
ORCHESTRATION_OUTPUT_PATH=""
FINAL_OUTPUT_PATH=""
REPORT_PATH=""

usage() {
  cat <<'USAGE'
Usage:
  scripts/full-pass-harmony-refresh.sh \
    --cycle N \
    --summary PATH \
    --run-root PATH \
    --target-file PATH \
    --orchestration-output PATH \
    --final-output PATH \
    --report PATH

Environment variables:
  FULL_PASS_HDC_PATH               必填，hdc 可执行路径
  FULL_PASS_HDC_SERIAL             Alias，优先用于指定唯一设备序列号；缺省时回落 FULL_PASS_TARGET_ID
  FULL_PASS_TARGET_ID              Alias，目标 emulator / 真机 ID
  FULL_PASS_TARGET_NAME            必填，目标名称
  FULL_PASS_TARGET_TYPE            可选，默认 emulator
  FULL_PASS_TARGET_OS_VERSION      可选，目标系统版本
  FULL_PASS_PKG_NAME               Alias，优先用于指定应用包名；缺省时回落 FULL_PASS_BUNDLE_NAME
  FULL_PASS_BUNDLE_NAME            Alias，应用 bundle 名称
  FULL_PASS_ABILITY_NAME           Alias，可用于自动派生 launch 命令
  FULL_PASS_SCENARIO_MODE          可选，默认 bcm；可设为 smoke
  FULL_PASS_EXPECTED_ASSERTIONS    bcm 模式必填；smoke 模式缺省时自动回填 SMOKE-LAUNCH-001
  FULL_PASS_DEVECO_STUDIO_HOME     必填，DevEco Studio 安装根目录
  FULL_PASS_HARMONY_SDK_HOME       必填，Harmony SDK 根目录
  FULL_PASS_TIMEOUT_SECONDS        可选，默认 180
  FULL_PASS_HILOG_FILTER           Alias，优先用于定义 Hilog 过滤标签
  FULL_PASS_LOG_FILTER_REGEX       Alias，默认提取 BCM/RMS/UI/FETCH/SEND 相关日志
  FULL_PASS_CLEAN_DIR              Alias，用于自动派生状态沙箱清理命令
  FULL_PASS_STATE_RESET_CMD        可选，轮次开始前先执行的状态清理命令
  FULL_PASS_LOG_CAPTURE_CMD        可选，默认使用 hdc shell hilog 持续抓取
  FULL_PASS_INSTALL_CMD            可选，安装命令；若缺失则需 FULL_PASS_ASSUME_PREINSTALLED=1
  FULL_PASS_LAUNCH_CMD             可选，启动命令；若缺失则需 FULL_PASS_ASSUME_PRELAUNCHED=1
  FULL_PASS_EXERCISE_CMD           必填，触发 Full Pass 场景的命令
  FULL_PASS_HOST_PROBE_JSON        可选，host probe 结果路径
  FULL_PASS_UI_ROUTE               可选，UI 路由
  FULL_PASS_PEER_SCOPE             可选，业务 peer scope
  FULL_PASS_ARTIFACT_PATH          可选，HAP/HSP 产物路径
  FULL_PASS_BUILD_ID               可选，默认按 cycle 生成
  FULL_PASS_CAPTURE_WARMUP_SECONDS 可选，默认 2
  FULL_PASS_POST_EXERCISE_GRACE_SECONDS 可选，默认 3

The install/launch/exercise/state-reset commands run under `bash -lc` and inherit all
FULL_PASS_* variables plus:
  FULL_PASS_CYCLE
  FULL_PASS_SUMMARY_PATH
  FULL_PASS_RUN_ROOT
  FULL_PASS_TARGET_FILE
  FULL_PASS_ORCHESTRATION_OUTPUT_PATH
  FULL_PASS_FINAL_OUTPUT_PATH
  FULL_PASS_REPORT_PATH
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cycle)
      CYCLE="$2"
      shift 2
      ;;
    --summary)
      SUMMARY_PATH="$2"
      shift 2
      ;;
    --run-root)
      RUN_ROOT="$2"
      shift 2
      ;;
    --target-file)
      TARGET_FILE="$2"
      shift 2
      ;;
    --orchestration-output)
      ORCHESTRATION_OUTPUT_PATH="$2"
      shift 2
      ;;
    --final-output)
      FINAL_OUTPUT_PATH="$2"
      shift 2
      ;;
    --report)
      REPORT_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[$SCRIPT_NAME] unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$PYTHON_BIN" ]]; then
  echo "[$SCRIPT_NAME] python3/python is required" >&2
  exit 1
fi
if [[ -z "$CYCLE" || -z "$SUMMARY_PATH" || -z "$RUN_ROOT" || -z "$TARGET_FILE" || -z "$ORCHESTRATION_OUTPUT_PATH" || -z "$FINAL_OUTPUT_PATH" || -z "$REPORT_PATH" ]]; then
  echo "[$SCRIPT_NAME] missing required CLI arguments" >&2
  usage >&2
  exit 1
fi
if [[ ! -x "$BUILDER_PATH" ]]; then
  echo "[$SCRIPT_NAME] builder not executable: $BUILDER_PATH" >&2
  exit 1
fi

pick_first_nonempty() {
  local candidate=""
  for candidate in "$@"; do
    if [[ -n "$candidate" ]]; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  return 1
}

normalize_shell_path() {
  local raw="${1:-}"
  if [[ -z "$raw" ]]; then
    return 0
  fi
  printf '%s' "${raw//\\//}"
}

fail_unset_env() {
  local label="$1"
  local hint="${2:-}"
  if [[ -n "$hint" ]]; then
    fail "Error: ${label} is not set. ${hint}" 2
  fi
  fail "Error: ${label} is not set" 2
}

FULL_PASS_HDC_PATH_RAW="${FULL_PASS_HDC_PATH:-$(command -v hdc || true)}"
FULL_PASS_HDC_PATH="$(normalize_shell_path "$FULL_PASS_HDC_PATH_RAW")"
FULL_PASS_HDC_SERIAL="${FULL_PASS_HDC_SERIAL:-}"
FULL_PASS_TARGET_ID="$(pick_first_nonempty "${FULL_PASS_TARGET_ID:-}" "$FULL_PASS_HDC_SERIAL" || true)"
FULL_PASS_TARGET_NAME="${FULL_PASS_TARGET_NAME:-}"
FULL_PASS_TARGET_TYPE="${FULL_PASS_TARGET_TYPE:-emulator}"
FULL_PASS_TARGET_OS_VERSION="${FULL_PASS_TARGET_OS_VERSION:-}"
FULL_PASS_TARGET_SERIAL_REDACTED="${FULL_PASS_TARGET_SERIAL_REDACTED:-true}"
FULL_PASS_PKG_NAME="${FULL_PASS_PKG_NAME:-}"
FULL_PASS_BUNDLE_NAME="$(pick_first_nonempty "${FULL_PASS_BUNDLE_NAME:-}" "$FULL_PASS_PKG_NAME" || true)"
FULL_PASS_ABILITY_NAME="${FULL_PASS_ABILITY_NAME:-}"
FULL_PASS_SCENARIO_MODE="${FULL_PASS_SCENARIO_MODE:-bcm}"
FULL_PASS_EXPECTED_ASSERTIONS="${FULL_PASS_EXPECTED_ASSERTIONS:-}"
FULL_PASS_DEVECO_STUDIO_HOME="$(normalize_shell_path "${FULL_PASS_DEVECO_STUDIO_HOME:-}")"
FULL_PASS_HARMONY_SDK_HOME="$(normalize_shell_path "${FULL_PASS_HARMONY_SDK_HOME:-}")"
FULL_PASS_HOST_PROBE_JSON="${FULL_PASS_HOST_PROBE_JSON:-}"
FULL_PASS_UI_ROUTE="${FULL_PASS_UI_ROUTE:-}"
FULL_PASS_PEER_SCOPE="${FULL_PASS_PEER_SCOPE:-}"
FULL_PASS_MODULE_NAME="${FULL_PASS_MODULE_NAME:-$(basename "$TARGET_FILE" .ets)}"
FULL_PASS_HAP_PATH="$(normalize_shell_path "${FULL_PASS_HAP_PATH:-}")"
FULL_PASS_ARTIFACT_PATH="$(normalize_shell_path "$(pick_first_nonempty "${FULL_PASS_ARTIFACT_PATH:-}" "$FULL_PASS_HAP_PATH" || true)")"
FULL_PASS_BUILD_ID="${FULL_PASS_BUILD_ID:-full-pass-build-cycle-${CYCLE}}"
FULL_PASS_TIMEOUT_SECONDS="${FULL_PASS_TIMEOUT_SECONDS:-180}"
FULL_PASS_CAPTURE_WARMUP_SECONDS="${FULL_PASS_CAPTURE_WARMUP_SECONDS:-2}"
FULL_PASS_POST_EXERCISE_GRACE_SECONDS="${FULL_PASS_POST_EXERCISE_GRACE_SECONDS:-3}"
FULL_PASS_HILOG_FILTER="${FULL_PASS_HILOG_FILTER:-}"
FULL_PASS_LOG_FILTER_REGEX="$(pick_first_nonempty "${FULL_PASS_LOG_FILTER_REGEX:-}" "$FULL_PASS_HILOG_FILTER" "BCM-|SMOKE-|RMS_|RMS|REFRESH|DATASET|FETCH|SEND|THREAD_CONTEXT")"
FULL_PASS_CLEAN_DIR="$(normalize_shell_path "${FULL_PASS_CLEAN_DIR:-}")"
FULL_PASS_STATE_RESET_CMD="${FULL_PASS_STATE_RESET_CMD:-}"
FULL_PASS_INSTALL_CMD="${FULL_PASS_INSTALL_CMD:-}"
FULL_PASS_LAUNCH_CMD="${FULL_PASS_LAUNCH_CMD:-}"
FULL_PASS_EXERCISE_CMD="${FULL_PASS_EXERCISE_CMD:-}"
FULL_PASS_LOG_CAPTURE_CMD="${FULL_PASS_LOG_CAPTURE_CMD:-}"
FULL_PASS_ASSUME_PREINSTALLED="${FULL_PASS_ASSUME_PREINSTALLED:-0}"
FULL_PASS_ASSUME_PRELAUNCHED="${FULL_PASS_ASSUME_PRELAUNCHED:-0}"
FULL_PASS_REDACTION_APPLIED="${FULL_PASS_REDACTION_APPLIED:-true}"

RUN_ROOT="$(cd "$RUN_ROOT" && pwd)"
SUMMARY_PATH_ABS="$(mkdir -p "$(dirname "$SUMMARY_PATH")" && cd "$(dirname "$SUMMARY_PATH")" && pwd)/$(basename "$SUMMARY_PATH")"
REPORT_PATH_ABS="$(mkdir -p "$(dirname "$REPORT_PATH")" && cd "$(dirname "$REPORT_PATH")" && pwd)/$(basename "$REPORT_PATH")"
CYCLE_DIR="$RUN_ROOT/full-pass-cycle-$(printf '%02d' "$CYCLE")"
LOG_DIR="$CYCLE_DIR/logs"
mkdir -p "$LOG_DIR"
RAW_LOG_PATH="$LOG_DIR/runtime.raw.log"
FILTERED_LOG_PATH="$LOG_DIR/runtime.filtered.log"
HARNESS_LOG_PATH="$LOG_DIR/harness.log"
: > "$HARNESS_LOG_PATH"

log() {
  printf '%s\n' "$*" | tee -a "$HARNESS_LOG_PATH"
}

fail() {
  log "[$SCRIPT_NAME] ERROR: $1"
  exit "${2:-1}"
}

require_nonempty() {
  local value="$1"
  local label="$2"
  local hint="${3:-}"
  if [[ -z "$value" ]]; then
    fail_unset_env "$label" "$hint"
  fi
}

run_timed_command() {
  local label="$1"
  local command_text="$2"
  local allow_failure="${3:-0}"
  log "[$SCRIPT_NAME] run[$label]: $command_text"
  set +e
  if command -v timeout >/dev/null 2>&1; then
    timeout --foreground "${FULL_PASS_TIMEOUT_SECONDS}s" bash -lc "$command_text" >> "$HARNESS_LOG_PATH" 2>&1
  else
    bash -lc "$command_text" >> "$HARNESS_LOG_PATH" 2>&1
  fi
  local exit_code=$?
  set -e
  if [[ "$exit_code" -ne 0 && "$allow_failure" != "1" ]]; then
    fail "command failed for $label, exit=$exit_code" 3
  fi
  return 0
}

require_nonempty "$FULL_PASS_TARGET_ID" "FULL_PASS_HDC_SERIAL" "Set FULL_PASS_HDC_SERIAL or FULL_PASS_TARGET_ID before running refresh harness."
require_nonempty "$FULL_PASS_HDC_PATH" "FULL_PASS_HDC_PATH" "Set FULL_PASS_HDC_PATH to an executable hdc binary."
require_nonempty "$FULL_PASS_TARGET_NAME" "FULL_PASS_TARGET_NAME"
require_nonempty "$FULL_PASS_BUNDLE_NAME" "FULL_PASS_PKG_NAME" "Set FULL_PASS_PKG_NAME or FULL_PASS_BUNDLE_NAME before running refresh harness."
case "$FULL_PASS_SCENARIO_MODE" in
  bcm|smoke)
    ;;
  *)
    fail "FULL_PASS_SCENARIO_MODE must be bcm or smoke: $FULL_PASS_SCENARIO_MODE" 2
    ;;
esac
if [[ "$FULL_PASS_SCENARIO_MODE" == "smoke" && -z "$FULL_PASS_EXPECTED_ASSERTIONS" ]]; then
  FULL_PASS_EXPECTED_ASSERTIONS="SMOKE-LAUNCH-001"
fi
require_nonempty "$FULL_PASS_EXPECTED_ASSERTIONS" "FULL_PASS_EXPECTED_ASSERTIONS"
require_nonempty "$FULL_PASS_DEVECO_STUDIO_HOME" "FULL_PASS_DEVECO_STUDIO_HOME"
require_nonempty "$FULL_PASS_HARMONY_SDK_HOME" "FULL_PASS_HARMONY_SDK_HOME"
require_nonempty "$FULL_PASS_EXERCISE_CMD" "FULL_PASS_EXERCISE_CMD"

if [[ -z "$FULL_PASS_STATE_RESET_CMD" && -n "$FULL_PASS_CLEAN_DIR" ]]; then
  FULL_PASS_STATE_RESET_CMD=""$FULL_PASS_HDC_PATH" -t "$FULL_PASS_TARGET_ID" shell rm -rf "$FULL_PASS_CLEAN_DIR""
fi
if [[ -z "$FULL_PASS_INSTALL_CMD" && -n "$FULL_PASS_ARTIFACT_PATH" ]]; then
  FULL_PASS_INSTALL_CMD=""$FULL_PASS_HDC_PATH" -t "$FULL_PASS_TARGET_ID" install -r "$FULL_PASS_ARTIFACT_PATH""
fi
if [[ -z "$FULL_PASS_LAUNCH_CMD" && -n "$FULL_PASS_ABILITY_NAME" && -n "$FULL_PASS_BUNDLE_NAME" ]]; then
  FULL_PASS_LAUNCH_CMD=""$FULL_PASS_HDC_PATH" -t "$FULL_PASS_TARGET_ID" shell aa start -a "$FULL_PASS_ABILITY_NAME" -b "$FULL_PASS_BUNDLE_NAME""
fi

if [[ ! -x "$FULL_PASS_HDC_PATH" ]]; then
  fail "FULL_PASS_HDC_PATH 不可执行: $FULL_PASS_HDC_PATH" 2
fi
if [[ ! -d "$FULL_PASS_DEVECO_STUDIO_HOME" ]]; then
  fail "FULL_PASS_DEVECO_STUDIO_HOME 不存在: $FULL_PASS_DEVECO_STUDIO_HOME" 2
fi
if [[ ! -d "$FULL_PASS_HARMONY_SDK_HOME" ]]; then
  fail "FULL_PASS_HARMONY_SDK_HOME 不存在: $FULL_PASS_HARMONY_SDK_HOME" 2
fi
if [[ -z "$FULL_PASS_INSTALL_CMD" && "$FULL_PASS_ASSUME_PREINSTALLED" != "1" ]]; then
  fail "未提供 FULL_PASS_INSTALL_CMD；若目标已预装，请显式设置 FULL_PASS_ASSUME_PREINSTALLED=1" 2
fi
if [[ -z "$FULL_PASS_LAUNCH_CMD" && "$FULL_PASS_ASSUME_PRELAUNCHED" != "1" ]]; then
  fail "未提供 FULL_PASS_LAUNCH_CMD；若目标已预启动，请显式设置 FULL_PASS_ASSUME_PRELAUNCHED=1" 2
fi

export FULL_PASS_CYCLE="$CYCLE"
export FULL_PASS_SUMMARY_PATH="$SUMMARY_PATH_ABS"
export FULL_PASS_RUN_ROOT="$RUN_ROOT"
export FULL_PASS_TARGET_FILE="$TARGET_FILE"
export FULL_PASS_ORCHESTRATION_OUTPUT_PATH="$ORCHESTRATION_OUTPUT_PATH"
export FULL_PASS_FINAL_OUTPUT_PATH="$FINAL_OUTPUT_PATH"
export FULL_PASS_REPORT_PATH="$REPORT_PATH_ABS"
export FULL_PASS_HDC_PATH
export FULL_PASS_HDC_SERIAL
export FULL_PASS_TARGET_ID
export FULL_PASS_TARGET_NAME
export FULL_PASS_TARGET_TYPE
export FULL_PASS_TARGET_OS_VERSION
export FULL_PASS_TARGET_SERIAL_REDACTED
export FULL_PASS_PKG_NAME
export FULL_PASS_BUNDLE_NAME
export FULL_PASS_ABILITY_NAME
export FULL_PASS_SCENARIO_MODE
export FULL_PASS_EXPECTED_ASSERTIONS
export FULL_PASS_DEVECO_STUDIO_HOME
export FULL_PASS_HARMONY_SDK_HOME
export FULL_PASS_HOST_PROBE_JSON
export FULL_PASS_UI_ROUTE
export FULL_PASS_PEER_SCOPE
export FULL_PASS_MODULE_NAME
export FULL_PASS_ARTIFACT_PATH
export FULL_PASS_BUILD_ID
export FULL_PASS_TIMEOUT_SECONDS
export FULL_PASS_HILOG_FILTER
export FULL_PASS_LOG_FILTER_REGEX
export FULL_PASS_CLEAN_DIR

log "[$SCRIPT_NAME] cycle=$CYCLE"
log "[$SCRIPT_NAME] summary=$SUMMARY_PATH_ABS"
log "[$SCRIPT_NAME] run_root=$RUN_ROOT"
log "[$SCRIPT_NAME] target=$FULL_PASS_TARGET_ID/$FULL_PASS_TARGET_NAME"
log "[$SCRIPT_NAME] target_file=$TARGET_FILE"
log "[$SCRIPT_NAME] final_output=$FINAL_OUTPUT_PATH"
log "[$SCRIPT_NAME] scenario_mode=$FULL_PASS_SCENARIO_MODE"
log "[$SCRIPT_NAME] log_filter=$FULL_PASS_LOG_FILTER_REGEX"
if [[ -n "$FULL_PASS_CLEAN_DIR" ]]; then
  log "[$SCRIPT_NAME] normalized_clean_dir=$FULL_PASS_CLEAN_DIR"
fi

TARGET_LIST_OUTPUT="$($FULL_PASS_HDC_PATH list targets 2>&1 || true)"
log "[$SCRIPT_NAME] hdc list targets => ${TARGET_LIST_OUTPUT//$'\n'/ ; }"
if ! printf '%s\n' "$TARGET_LIST_OUTPUT" | grep -Fq "$FULL_PASS_TARGET_ID"; then
  fail "未在 hdc list targets 中探测到目标: $FULL_PASS_TARGET_ID" 4
fi

if [[ -z "$FULL_PASS_LOG_CAPTURE_CMD" ]]; then
  FULL_PASS_LOG_CAPTURE_CMD=""$FULL_PASS_HDC_PATH" -t "$FULL_PASS_TARGET_ID" shell hilog"
fi

LOG_CAPTURE_PID=""
cleanup() {
  if [[ -n "$LOG_CAPTURE_PID" ]] && kill -0 "$LOG_CAPTURE_PID" 2>/dev/null; then
    kill "$LOG_CAPTURE_PID" 2>/dev/null || true
    wait "$LOG_CAPTURE_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if [[ -n "$FULL_PASS_STATE_RESET_CMD" ]]; then
  run_timed_command "state-reset" "$FULL_PASS_STATE_RESET_CMD" 0
else
  log "[$SCRIPT_NAME] state-reset skipped: FULL_PASS_STATE_RESET_CMD not configured"
fi

rm -f "$SUMMARY_PATH_ABS" "$RAW_LOG_PATH" "$FILTERED_LOG_PATH"
: > "$RAW_LOG_PATH"

log "[$SCRIPT_NAME] start log capture: $FULL_PASS_LOG_CAPTURE_CMD"
set +e
if command -v timeout >/dev/null 2>&1; then
  timeout --foreground "${FULL_PASS_TIMEOUT_SECONDS}s" bash -lc "$FULL_PASS_LOG_CAPTURE_CMD" > "$RAW_LOG_PATH" 2>> "$HARNESS_LOG_PATH" &
else
  bash -lc "$FULL_PASS_LOG_CAPTURE_CMD" > "$RAW_LOG_PATH" 2>> "$HARNESS_LOG_PATH" &
fi
LOG_CAPTURE_PID=$!
set -e
sleep "$FULL_PASS_CAPTURE_WARMUP_SECONDS"

INSTALL_STATUS="passed"
if [[ -n "$FULL_PASS_INSTALL_CMD" ]]; then
  run_timed_command "install" "$FULL_PASS_INSTALL_CMD" 0
else
  log "[$SCRIPT_NAME] install skipped by FULL_PASS_ASSUME_PREINSTALLED=1"
fi

LAUNCH_STATUS="passed"
if [[ -n "$FULL_PASS_LAUNCH_CMD" ]]; then
  run_timed_command "launch" "$FULL_PASS_LAUNCH_CMD" 0
else
  log "[$SCRIPT_NAME] launch skipped by FULL_PASS_ASSUME_PRELAUNCHED=1"
fi

run_timed_command "exercise" "$FULL_PASS_EXERCISE_CMD" 0
sleep "$FULL_PASS_POST_EXERCISE_GRACE_SECONDS"
cleanup
LOG_CAPTURE_PID=""

if [[ ! -s "$RAW_LOG_PATH" ]]; then
  fail "raw log capture 为空：$RAW_LOG_PATH" 5
fi

FILTERED_LOG_TMP="$FILTERED_LOG_PATH.tmp"
rm -f "$FILTERED_LOG_TMP"
grep -nE -- "$FULL_PASS_LOG_FILTER_REGEX" "$RAW_LOG_PATH" > "$FILTERED_LOG_TMP" || true
if [[ ! -s "$FILTERED_LOG_TMP" ]]; then
  cp "$RAW_LOG_PATH" "$FILTERED_LOG_TMP"
  log "[$SCRIPT_NAME] filter produced no lines; fallback to raw log"
fi
mv "$FILTERED_LOG_TMP" "$FILTERED_LOG_PATH"
log "[$SCRIPT_NAME] log capture committed atomically: raw=$RAW_LOG_PATH filtered=$FILTERED_LOG_PATH"

BUILD_ARGS=(
  "$PYTHON_BIN" "$BUILDER_PATH"
  --log-input "$FILTERED_LOG_PATH"
  --raw-log-path "$RAW_LOG_PATH"
  --summary-output "$SUMMARY_PATH_ABS"
  --label "full-pass-cycle-$(printf '%02d' "$CYCLE")"
  --module-name "$FULL_PASS_MODULE_NAME"
  --source-file "$TARGET_FILE"
  --candidate-file "$FINAL_OUTPUT_PATH"
  --host-os "$(uname -s)"
  --host-arch "$(uname -m)"
  --node-mode "$([[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]] && printf 'gui-host' || printf 'headless-host')"
  --deveco-studio-home "$FULL_PASS_DEVECO_STUDIO_HOME"
  --harmony-sdk-home "$FULL_PASS_HARMONY_SDK_HOME"
  --hdc-path "$FULL_PASS_HDC_PATH"
  --target-type "$FULL_PASS_TARGET_TYPE"
  --target-id "$FULL_PASS_TARGET_ID"
  --target-name "$FULL_PASS_TARGET_NAME"
  --target-serial-redacted "$FULL_PASS_TARGET_SERIAL_REDACTED"
  --build-id "$FULL_PASS_BUILD_ID"
  --bundle-name "$FULL_PASS_BUNDLE_NAME"
  --install-status "$INSTALL_STATUS"
  --launch-status "$LAUNCH_STATUS"
  --log-source "hilog"
  --log-capture-command "$FULL_PASS_LOG_CAPTURE_CMD"
  --redaction-applied "$FULL_PASS_REDACTION_APPLIED"
  --scenario-mode "$FULL_PASS_SCENARIO_MODE"
  --expected-assertions "$FULL_PASS_EXPECTED_ASSERTIONS"
  --note "$SCRIPT_NAME"
  --note "report_path=$REPORT_PATH_ABS"
)

if [[ -n "$FULL_PASS_UI_ROUTE" ]]; then
  BUILD_ARGS+=(--ui-route "$FULL_PASS_UI_ROUTE")
fi
if [[ -n "$FULL_PASS_PEER_SCOPE" ]]; then
  BUILD_ARGS+=(--peer-scope "$FULL_PASS_PEER_SCOPE")
fi
if [[ -n "$FULL_PASS_HOST_PROBE_JSON" ]]; then
  BUILD_ARGS+=(--host-probe-json "$FULL_PASS_HOST_PROBE_JSON")
fi
if [[ -n "$FULL_PASS_TARGET_OS_VERSION" ]]; then
  BUILD_ARGS+=(--target-os-version "$FULL_PASS_TARGET_OS_VERSION")
fi
if [[ -n "$FULL_PASS_ARTIFACT_PATH" ]]; then
  BUILD_ARGS+=(--artifact-path "$FULL_PASS_ARTIFACT_PATH")
fi

log "[$SCRIPT_NAME] builder => ${BUILD_ARGS[*]}"
"${BUILD_ARGS[@]}" >> "$HARNESS_LOG_PATH" 2>&1 || fail "summary builder 执行失败" 6

if [[ ! -f "$SUMMARY_PATH_ABS" ]]; then
  fail "builder 未生成 summary.json: $SUMMARY_PATH_ABS" 6
fi

log "[$SCRIPT_NAME] summary generated: $SUMMARY_PATH_ABS"
log "[$SCRIPT_NAME] raw log: $RAW_LOG_PATH"
log "[$SCRIPT_NAME] filtered log: $FILTERED_LOG_PATH"
exit 0
