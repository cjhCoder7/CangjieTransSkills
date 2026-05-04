#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_MANIFEST="$ROOT_DIR/docs/manifests/batch_manifest_phase05.json"
READ_KEY_FROM_STDIN=0
POSITIONAL_ARGS=()

print_usage() {
  cat <<EOF
Usage: $(basename "$0") [--read-key-from-stdin] [manifest] [pipeline_batch_runner args...]

Options:
  --read-key-from-stdin  Read SILICONFLOW_API_KEY from stdin when the environment variable is unset.
  -h, --help            Show this help message.
EOF
}

resolve_manifest_path() {
  local raw_path="$1"
  if [[ -z "$raw_path" ]]; then
    printf '%s\n' "$DEFAULT_MANIFEST"
    return 0
  fi
  if [[ "$raw_path" = /* ]]; then
    printf '%s\n' "$raw_path"
    return 0
  fi
  if [[ -f "$raw_path" ]]; then
    printf '%s\n' "$(cd "$(dirname "$raw_path")" && pwd)/$(basename "$raw_path")"
    return 0
  fi
  printf '%s\n' "$ROOT_DIR/$raw_path"
}

source_optional_env_file() {
  local env_path="$1"
  if [[ -f "$env_path" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$env_path"
    set +a
  fi
}

manifest_is_fully_frozen() {
  local manifest_path="$1"
  local probe_python="python"
  if command -v python3 >/dev/null 2>&1; then
    probe_python="python3"
  fi
  "$probe_python" - "$manifest_path" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
try:
    payload = json.loads(manifest_path.read_text(encoding="utf-8"))
except Exception:
    print("0")
    raise SystemExit(0)

defaults = payload.get("pipeline_defaults")
if not isinstance(defaults, dict):
    defaults = {}

entries = payload.get("ordered_targets")
if entries is None:
    entries = payload.get("entries")
if not isinstance(entries, list) or not entries:
    print("0")
    raise SystemExit(0)

default_frozen_candidate = bool(str(defaults.get("frozen_candidate_file", "")).strip())
for entry in entries:
    if not isinstance(entry, dict):
        print("0")
        raise SystemExit(0)
    overrides = entry.get("pipeline_overrides")
    if not isinstance(overrides, dict):
        overrides = {}
    entry_frozen_candidate = bool(str(overrides.get("frozen_candidate_file", "")).strip())
    if not (entry_frozen_candidate or default_frozen_candidate):
        print("0")
        raise SystemExit(0)

print("1")
PY
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --read-key-from-stdin)
      READ_KEY_FROM_STDIN=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        POSITIONAL_ARGS+=("$1")
        shift
      done
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

MANIFEST_PATH="$(resolve_manifest_path "${1:-}")"
if [[ $# -gt 0 ]]; then
  shift
fi

if [[ ! -f "$MANIFEST_PATH" ]]; then
  printf '[mass-translation] manifest not found: %s\n' "$MANIFEST_PATH" >&2
  exit 1
fi

MANIFEST_FULLY_FROZEN=0
if [[ "$(manifest_is_fully_frozen "$MANIFEST_PATH")" == "1" ]]; then
  MANIFEST_FULLY_FROZEN=1
fi

ORIGINAL_SILICONFLOW_API_KEY="${SILICONFLOW_API_KEY:-}"
source_optional_env_file "$ROOT_DIR/.env.local"
if [[ -n "$ORIGINAL_SILICONFLOW_API_KEY" ]]; then
  export SILICONFLOW_API_KEY="$ORIGINAL_SILICONFLOW_API_KEY"
fi

SILICONFLOW_API_KEY_VALUE="${SILICONFLOW_API_KEY:-}"
if [[ -z "$SILICONFLOW_API_KEY_VALUE" ]]; then
  if [[ "$READ_KEY_FROM_STDIN" -eq 1 ]]; then
    if ! IFS= read -r SILICONFLOW_API_KEY_VALUE; then
      if [[ -z "$SILICONFLOW_API_KEY_VALUE" ]]; then
        printf '[mass-translation] SILICONFLOW_API_KEY is missing; --read-key-from-stdin was set but no stdin payload was provided.\n' >&2
        exit 1
      fi
    fi
  elif [[ "$MANIFEST_FULLY_FROZEN" -eq 1 ]]; then
    SILICONFLOW_API_KEY_VALUE=""
  elif [[ -n "${OPENAI_API_KEY:-}" ]]; then
    SILICONFLOW_API_KEY_VALUE="$OPENAI_API_KEY"
  elif [[ -t 0 ]]; then
    read -r -s -p "SILICONFLOW_API_KEY: " SILICONFLOW_API_KEY_VALUE
    printf '\n'
  else
    printf '[mass-translation] SILICONFLOW_API_KEY is missing and no interactive terminal is available.\n' >&2
    exit 1
  fi
fi

export SILICONFLOW_API_KEY="$SILICONFLOW_API_KEY_VALUE"
export CANGJIE_HOME="$ROOT_DIR/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie"
export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:${PATH:-}"
export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}"
export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std"

exec python "$ROOT_DIR/scripts/pipeline_batch_runner.py" \
  --manifest "$MANIFEST_PATH" \
  --continue-on-error \
  "$@"