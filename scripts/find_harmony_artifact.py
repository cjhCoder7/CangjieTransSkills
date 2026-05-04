#!/usr/bin/env python3
"""定位 DevEco / Harmony 工程中的可安装产物与基础元数据。"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
from pathlib import Path, PurePosixPath
from typing import Any, Dict, List, Optional


SKIP_DIR_NAMES = {".git", ".hg", ".svn", "node_modules", ".hvigor", ".idea"}
APP_BUNDLE_RE = re.compile(r'["\']bundleName["\']\s*:\s*["\'](?P<value>[^"\']+)["\']')
MAIN_ELEMENT_RE = re.compile(r'["\']mainElement["\']\s*:\s*["\'](?P<value>[^"\']+)["\']')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="定位 DevEco 工程中的 .hap 产物与 Full Pass 基础环境变量")
    parser.add_argument("--project-root", required=True, help="DevEco 工程根目录")
    parser.add_argument(
        "--host-probe-json",
        help="可选；full-pass-host-probe 产物路径。提供后，env 输出会补齐宿主/target/toolchain 事实值。",
    )
    parser.add_argument(
        "--target-id",
        help="可选；显式覆盖 host probe 中发现的 target ID。未提供时优先取 hdc_targets[0]。",
    )
    parser.add_argument(
        "--target-name",
        help="可选；补齐 .env.full-pass.local 所需的 target 显示名。",
    )
    parser.add_argument(
        "--target-type",
        choices=("emulator", "device"),
        help="可选；显式指定 target 类型。未提供时会基于 target ID 做最小推断。",
    )
    parser.add_argument(
        "--format",
        choices=("json", "env"),
        default="json",
        help="输出格式：json 或 env",
    )
    return parser.parse_args()


def utc_iso(timestamp: float) -> str:
    return dt.datetime.utcfromtimestamp(timestamp).replace(microsecond=0).isoformat() + "Z"


def should_skip(path: Path) -> bool:
    return any(part in SKIP_DIR_NAMES for part in path.parts)


def resolve_metadata_file(project_root: Path, relative_path: str, filename: str) -> Optional[Path]:
    candidate = project_root / relative_path
    if candidate.is_file():
        return candidate.resolve()
    matches = [
        path.resolve()
        for path in project_root.rglob(filename)
        if path.is_file() and not should_skip(path.relative_to(project_root))
    ]
    return sorted(matches, key=lambda item: len(item.parts))[0] if matches else None


def extract_first_match(path: Optional[Path], pattern: re.Pattern[str]) -> str:
    if path is None or not path.is_file():
        return ""
    text = path.read_text(encoding="utf-8", errors="replace")
    match = pattern.search(text)
    return str(match.group("value")).strip() if match else ""


def load_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def normalize_env_path(raw: str) -> str:
    return raw.replace("\\", "/").strip()


def normalize_host_os(raw: str) -> str:
    text = raw.strip()
    lowered = text.lower()
    if "windows" in lowered:
        return "windows"
    if "darwin" in lowered or "mac" in lowered:
        return "macos"
    if "linux" in lowered:
        return "linux"
    return re.sub(r"[^a-z0-9]+", "-", lowered).strip("-")


def first_nonempty(items: List[Any]) -> str:
    for item in items:
        text = str(item).strip()
        if text:
            return text
    return ""


def derive_harmony_sdk_home(hdc_path: str) -> str:
    normalized = normalize_env_path(hdc_path)
    if not normalized:
        return ""
    path = PurePosixPath(normalized)
    if len(path.parts) < 3:
        return ""
    return str(path.parent.parent)


def infer_target_type(target_id: str, target_type: str) -> str:
    explicit = target_type.strip()
    if explicit:
        return explicit
    lowered = target_id.strip().lower()
    if not lowered:
        return ""
    if lowered.startswith(("127.0.0.1:", "localhost:")) or "emulator" in lowered or "simulator" in lowered:
        return "emulator"
    return "device"


def build_host_probe_payload(
    host_probe_path: Path,
    emitted_host_probe_path: str,
    target_id_override: str,
    target_name: str,
    target_type: str,
) -> Dict[str, Any]:
    payload = load_json(host_probe_path)
    host = payload.get("host") if isinstance(payload.get("host"), dict) else {}
    paths = payload.get("paths") if isinstance(payload.get("paths"), dict) else {}
    device = payload.get("device_connectivity") if isinstance(payload.get("device_connectivity"), dict) else {}
    assessment = payload.get("assessment") if isinstance(payload.get("assessment"), dict) else {}
    probe_targets = device.get("hdc_targets") if isinstance(device.get("hdc_targets"), list) else []
    target_id = first_nonempty([target_id_override, *probe_targets])
    hdc_path = normalize_env_path(str(paths.get("hdc", "")))
    return {
        "host_probe_input_path": normalize_env_path(emitted_host_probe_path),
        "host_probe_resolved_path": str(host_probe_path.resolve().as_posix()),
        "host_os": normalize_host_os(str(host.get("os", ""))),
        "deveco_studio_home": normalize_env_path(str(paths.get("deveco_studio_home", ""))),
        "harmony_sdk_home": derive_harmony_sdk_home(hdc_path),
        "hdc_path": hdc_path,
        "target_id": target_id,
        "target_name": target_name.strip(),
        "target_type": infer_target_type(target_id, target_type),
        "target_channel_ready": bool(device.get("target_channel_ready")),
        "staging_full_ready": bool(assessment.get("staging_full_ready")),
    }


def collect_hap_candidates(project_root: Path) -> List[Dict[str, Any]]:
    candidates: List[Dict[str, Any]] = []
    for path in project_root.rglob("*.hap"):
        if not path.is_file():
            continue
        relative = path.relative_to(project_root)
        if should_skip(relative):
            continue
        stat = path.stat()
        candidates.append(
            {
                "path": str(path.resolve().as_posix()),
                "relative_path": str(relative.as_posix()),
                "size_bytes": stat.st_size,
                "modified_at_utc": utc_iso(stat.st_mtime),
                "modified_ts": stat.st_mtime,
            }
        )
    candidates.sort(key=lambda item: (float(item["modified_ts"]), int(item["size_bytes"])), reverse=True)
    for item in candidates:
        item.pop("modified_ts", None)
    return candidates


def build_payload(project_root: Path, host_probe: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    app_json = resolve_metadata_file(project_root, "AppScope/app.json5", "app.json5")
    module_json = resolve_metadata_file(project_root, "entry/src/main/module.json5", "module.json5")
    hap_candidates = collect_hap_candidates(project_root)
    latest_hap_path = str(hap_candidates[0]["path"]) if hap_candidates else ""
    bundle_name = extract_first_match(app_json, APP_BUNDLE_RE)
    ability_name = extract_first_match(module_json, MAIN_ELEMENT_RE)
    payload = {
        "project_root": str(project_root.resolve()),
        "app_json_path": str(app_json) if app_json else "",
        "module_json_path": str(module_json) if module_json else "",
        "bundle_name": bundle_name,
        "ability_name": ability_name,
        "latest_hap_path": latest_hap_path,
        "hap_candidates": hap_candidates,
        "artifact_found": bool(latest_hap_path),
    }
    if host_probe:
        payload["host_probe"] = host_probe
    return payload


def render_env(payload: Dict[str, Any]) -> str:
    lines = []
    host_probe = payload.get("host_probe") if isinstance(payload.get("host_probe"), dict) else {}
    host_os = str(host_probe.get("host_os", "")).strip()
    deveco_studio_home = str(host_probe.get("deveco_studio_home", "")).strip()
    harmony_sdk_home = str(host_probe.get("harmony_sdk_home", "")).strip()
    hdc_path = str(host_probe.get("hdc_path", "")).strip()
    host_probe_input_path = str(host_probe.get("host_probe_input_path", "")).strip()
    target_type = str(host_probe.get("target_type", "")).strip()
    target_id = str(host_probe.get("target_id", "")).strip()
    target_name = str(host_probe.get("target_name", "")).strip()
    bundle_name = str(payload.get("bundle_name", "")).strip()
    ability_name = str(payload.get("ability_name", "")).strip()
    hap_path = str(payload.get("latest_hap_path", "")).strip()
    if host_os:
        lines.append(f'FULL_PASS_HOST_OS="{host_os}"')
    if deveco_studio_home:
        lines.append(f'FULL_PASS_DEVECO_STUDIO_HOME="{deveco_studio_home}"')
    if harmony_sdk_home:
        lines.append(f'FULL_PASS_HARMONY_SDK_HOME="{harmony_sdk_home}"')
    if hdc_path:
        lines.append(f'FULL_PASS_HDC_PATH="{hdc_path}"')
    if host_probe_input_path:
        lines.append(f'FULL_PASS_HOST_PROBE_JSON="{host_probe_input_path}"')
    if target_type:
        lines.append(f'FULL_PASS_TARGET_TYPE="{target_type}"')
    if target_id:
        lines.append(f'FULL_PASS_HDC_SERIAL="{target_id}"')
        lines.append('FULL_PASS_TARGET_ID="$FULL_PASS_HDC_SERIAL"')
    elif host_probe:
        lines.append('# FULL_PASS_HDC_SERIAL="<missing: target not found in host probe; pass --target-id>"')
    if target_name:
        lines.append(f'FULL_PASS_TARGET_NAME="{target_name}"')
    elif host_probe:
        lines.append('# FULL_PASS_TARGET_NAME="<missing: pass --target-name to label the emulator/device>"')
    if bundle_name:
        lines.append(f'FULL_PASS_PKG_NAME="{bundle_name}"')
        lines.append(f'FULL_PASS_BUNDLE_NAME="{bundle_name}"')
    if ability_name:
        lines.append(f'FULL_PASS_ABILITY_NAME="{ability_name}"')
    if hap_path:
        lines.append(f'FULL_PASS_HAP_PATH="{hap_path}"')
        lines.append(f'FULL_PASS_ARTIFACT_PATH="{hap_path}"')
    else:
        lines.append('# FULL_PASS_HAP_PATH="<missing: build the project to produce a .hap artifact>"')
    if host_probe and hdc_path and target_id and bundle_name:
        lines.append('FULL_PASS_EXERCISE_CMD="\\"$FULL_PASS_HDC_PATH\\" -t \\"$FULL_PASS_HDC_SERIAL\\" shell uitest dumpLayout -b \\"$FULL_PASS_PKG_NAME\\""')
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).expanduser()
    if not project_root.exists():
        print(f"project root does not exist: {project_root}", file=sys.stderr)
        return 1
    if not project_root.is_dir():
        print(f"project root is not a directory: {project_root}", file=sys.stderr)
        return 1
    host_probe: Optional[Dict[str, Any]] = None
    if args.host_probe_json:
        host_probe_path = Path(args.host_probe_json).expanduser()
        if not host_probe_path.exists():
            print(f"host probe json does not exist: {host_probe_path}", file=sys.stderr)
            return 1
        if not host_probe_path.is_file():
            print(f"host probe json is not a file: {host_probe_path}", file=sys.stderr)
            return 1
        host_probe = build_host_probe_payload(
            host_probe_path=host_probe_path,
            emitted_host_probe_path=args.host_probe_json,
            target_id_override=args.target_id or "",
            target_name=args.target_name or "",
            target_type=args.target_type or "",
        )

    payload = build_payload(project_root.resolve(), host_probe=host_probe)
    if args.format == "env":
        sys.stdout.write(render_env(payload))
    else:
        sys.stdout.write(json.dumps(payload, ensure_ascii=False, indent=2) + "\n")
    return 0 if payload["artifact_found"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
