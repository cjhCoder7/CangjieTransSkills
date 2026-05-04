#!/usr/bin/env python3
"""TelegramHarmony 小批量自动翻译 batch wrapper。"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PIPELINE_SCRIPT = PROJECT_ROOT / "scripts" / "pipeline_runner.py"
DEFAULT_BATCH_RUNS_ROOT = PROJECT_ROOT / "artifacts" / "batch_runs"
DEFAULT_MANIFEST_SRC_ROOT = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02"
MAX_FAILURE_STDERR_CHARS = 4096
TOOLCHAIN_ENV_KEYS = ("CANGJIE_HOME", "PATH", "LD_LIBRARY_PATH", "DYLD_LIBRARY_PATH")
BATCH_SUMMARY_FILENAMES = ("batch-summary.json", "batch_summary.json")


BOOL_FLAG_MAP = {
    "mock_mode": ("--mock-mode", "--no-mock-mode"),
    "verify_dry_run": ("--verify-dry-run", "--verify-no-dry-run"),
    "verify_mock_compiler": ("--verify-mock-compiler", "--verify-real-compile"),
    "verify_mock_unit_test": ("--verify-mock-unit-test", "--verify-real-unit-test"),
    "verify_mock_behavior": ("--verify-mock-behavior", "--verify-real-behavior"),
    "prefer_tree_sitter": ("--prefer-tree-sitter", "--no-prefer-tree-sitter"),
    "reset_db": ("--reset-db", "--no-reset-db"),
    "verify_inject_compat_cangjie_home": (
        "--verify-enable-compat-cangjie-home",
        "--verify-disable-compat-cangjie-home",
    ),
}

REPEATABLE_FLAG_MAP = {
    "architecture_skills": "--architecture-skill",
    "verify_extra_env": "--verify-extra-env",
}

VALUE_FLAG_MAP = {
    "schema_path": "--schema-path",
    "pattern_memory_path": "--pattern-memory-path",
    "workspace_root": "--workspace-root",
    "snapshot_label": "--snapshot-label",
    "llm_model": "--llm-model",
    "timeout_seconds": "--timeout-seconds",
    "llm_max_retries": "--llm-max-retries",
    "max_rounds": "--max-rounds",
    "pattern_limit": "--pattern-limit",
    "parser_mode": "--parser-mode",
    "diff_report_path": "--diff-report-path",
    "repo_map_max_symbols": "--repo-map-max-symbols",
    "repo_map_max_imports": "--repo-map-max-imports",
    "repo_map_max_calls": "--repo-map-max-calls",
    "tu_max_depth": "--tu-max-depth",
    "tu_max_dependency_files": "--tu-max-dependency-files",
    "tu_max_signatures_per_file": "--tu-max-signatures-per-file",
    "compile_cmd": "--compile-cmd",
    "unit_test_cmd": "--unit-test-cmd",
    "behavior_cmd": "--behavior-cmd",
    "verify_working_directory": "--verify-working-directory",
    "verify_compiler_executable": "--verify-compiler-executable",
    "verify_package_manager_executable": "--verify-package-manager-executable",
    "verify_compiler_home": "--verify-compiler-home",
    "verify_stdlib_path": "--verify-stdlib-path",
    "verify_runtime_lib_path": "--verify-runtime-lib-path",
    "verify_tool_bin_path": "--verify-tool-bin-path",
    "repair_anchor_file": "--repair-anchor-file",
    "repair_anchor_label": "--repair-anchor-label",
    "frozen_candidate_file": "--frozen-candidate-file",
    "frozen_candidate_label": "--frozen-candidate-label",
    "full_pass_summary_path": "--full-pass-summary-path",
    "full_pass_validation_schema_path": "--full-pass-validation-schema-path",
    "full_pass_validation_report_path": "--full-pass-validation-report-path",
    "full_pass_status_path": "--full-pass-status-path",
    "full_pass_refresh_cmd": "--full-pass-refresh-cmd",
    "full_pass_max_cycles": "--full-pass-max-cycles",
    "prompt_dump_path": "--prompt-dump-path",
}

PATH_LIKE_KEYS = {
    "schema_path",
    "pattern_memory_path",
    "workspace_root",
    "diff_report_path",
    "verify_working_directory",
    "verify_compiler_executable",
    "verify_package_manager_executable",
    "verify_compiler_home",
    "verify_stdlib_path",
    "verify_runtime_lib_path",
    "verify_tool_bin_path",
    "repair_anchor_file",
    "frozen_candidate_file",
    "full_pass_summary_path",
    "full_pass_validation_schema_path",
    "full_pass_validation_report_path",
    "full_pass_status_path",
    "prompt_dump_path",
}


@dataclass(frozen=True)
class BatchEntry:
    target_file: str
    risk_level: str = "unknown"
    verification_mode: str = "inherit"
    count_toward_kpi: bool = True
    notes: str = ""
    depends_on: List[str] | None = None
    timeout_seconds: Optional[int] = None
    llm_max_retries: Optional[int] = None
    pipeline_overrides: Dict[str, Any] | None = None


@dataclass(frozen=True)
class BatchManifest:
    manifest_path: Path
    batch_name: str
    src_root: Path
    pipeline_defaults: Dict[str, Any]
    entries: List[BatchEntry]


class BatchManifestError(RuntimeError):
    pass


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def read_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def resolve_manifest_relative_path(value: str, base_dir: Path) -> str:
    path = Path(value).expanduser()
    if not path.is_absolute():
        path = (base_dir / path).resolve()
    else:
        path = path.resolve()
    return str(path)


def normalize_pipeline_defaults(raw: Dict[str, Any], base_dir: Path) -> Dict[str, Any]:
    normalized: Dict[str, Any] = {}
    for key, value in raw.items():
        if key in PATH_LIKE_KEYS and isinstance(value, str):
            normalized[key] = resolve_manifest_relative_path(value, base_dir)
        elif key in REPEATABLE_FLAG_MAP and isinstance(value, list):
            normalized[key] = [
                resolve_manifest_relative_path(item, base_dir) if key == "architecture_skills" else str(item)
                for item in value
            ]
        else:
            normalized[key] = value
    return normalized


def parse_optional_int(
    raw_value: Any,
    *,
    field_name: str,
    entry_label: str,
) -> Optional[int]:
    if raw_value in (None, ""):
        return None
    if isinstance(raw_value, bool):
        raise BatchManifestError(f"entry `{entry_label}` 的 {field_name} 必须是整数")
    try:
        value = int(raw_value)
    except (TypeError, ValueError) as exc:
        raise BatchManifestError(f"entry `{entry_label}` 的 {field_name} 必须是整数") from exc
    if value < 0:
        raise BatchManifestError(f"entry `{entry_label}` 的 {field_name} 不能小于 0")
    return value


def validate_manifest_dependencies(entries: List[BatchEntry]) -> None:
    seen: set[str] = set()
    all_targets = [entry.target_file for entry in entries]
    duplicate_targets = {target for target in all_targets if all_targets.count(target) > 1}
    if duplicate_targets:
        raise BatchManifestError(f"manifest target_file 重复：{sorted(duplicate_targets)}")

    for entry in entries:
        depends_on = entry.depends_on or []
        for dependency in depends_on:
            if dependency not in all_targets:
                raise BatchManifestError(f"target `{entry.target_file}` 依赖未知文件 `{dependency}`")
            if dependency not in seen:
                raise BatchManifestError(
                    f"target `{entry.target_file}` 依赖 `{dependency}`，但 manifest 顺序未满足拓扑要求"
                )
        seen.add(entry.target_file)


def parse_depends_on(raw_value: Any, *, target_file: str) -> List[str]:
    depends_on_raw = raw_value if raw_value is not None else []
    if not isinstance(depends_on_raw, list):
        raise BatchManifestError(f"entry `{target_file}` 的 depends_on 必须是数组")
    return [str(value) for value in depends_on_raw]


def parse_pipeline_overrides(raw_value: Any, *, base_dir: Path, target_file: str) -> Dict[str, Any]:
    if raw_value in (None, {}):
        return {}
    if not isinstance(raw_value, dict):
        raise BatchManifestError(f"entry `{target_file}` 的 pipeline_overrides 必须是对象")
    return normalize_pipeline_defaults(raw_value, base_dir)


def load_manifest(manifest_path: Path) -> BatchManifest:
    resolved_path = manifest_path.expanduser().resolve()
    raw = read_json(resolved_path)
    base_dir = resolved_path.parent

    batch_name = str(raw.get("batch_name", "")).strip()
    if not batch_name:
        raise BatchManifestError("manifest 缺少 batch_name")

    src_root_raw = str(raw.get("src_root", "")).strip()
    if src_root_raw:
        src_root = Path(resolve_manifest_relative_path(src_root_raw, base_dir))
    else:
        src_root = DEFAULT_MANIFEST_SRC_ROOT.resolve()

    raw_defaults = raw.get("pipeline_defaults", {})
    if not isinstance(raw_defaults, dict):
        raise BatchManifestError("pipeline_defaults 必须是对象")
    pipeline_defaults = normalize_pipeline_defaults(raw_defaults, base_dir)

    entries: List[BatchEntry] = []
    raw_ordered_targets = raw.get("ordered_targets")
    if raw_ordered_targets is not None:
        if not isinstance(raw_ordered_targets, list) or not raw_ordered_targets:
            raise BatchManifestError("ordered_targets 必须是非空数组")
        for item in raw_ordered_targets:
            if not isinstance(item, dict):
                raise BatchManifestError("ordered_targets entry 必须是对象")
            target_file = str(item.get("file", "")).strip()
            if not target_file:
                raise BatchManifestError("ordered_targets entry 缺少 file")
            entries.append(
                BatchEntry(
                    target_file=target_file,
                    risk_level=str(item.get("risk_level", "ordered")),
                    verification_mode=str(item.get("verification_mode", "ordered")),
                    count_toward_kpi=bool(item.get("count_toward_kpi", True)),
                    notes=str(item.get("notes", "")),
                    depends_on=parse_depends_on(item.get("depends_on", []), target_file=target_file),
                    timeout_seconds=parse_optional_int(
                        item.get("timeout"),
                        field_name="timeout",
                        entry_label=target_file,
                    ),
                    llm_max_retries=parse_optional_int(
                        item.get("retries"),
                        field_name="retries",
                        entry_label=target_file,
                    ),
                    pipeline_overrides=parse_pipeline_overrides(
                        item.get("pipeline_overrides"),
                        base_dir=base_dir,
                        target_file=target_file,
                    ),
                )
            )
    else:
        raw_entries = raw.get("entries", [])
        if not isinstance(raw_entries, list) or not raw_entries:
            raise BatchManifestError("manifest 必须包含非空 entries 或 ordered_targets")
        for item in raw_entries:
            if not isinstance(item, dict):
                raise BatchManifestError("entry 必须是对象")
            target_file = str(item.get("target_file", "")).strip()
            if not target_file:
                raise BatchManifestError("entry 缺少 target_file")
            entries.append(
                BatchEntry(
                    target_file=target_file,
                    risk_level=str(item.get("risk_level", "unknown")),
                    verification_mode=str(item.get("verification_mode", "dry-run")),
                    count_toward_kpi=bool(item.get("count_toward_kpi", True)),
                    notes=str(item.get("notes", "")),
                    depends_on=parse_depends_on(item.get("depends_on", []), target_file=target_file),
                    timeout_seconds=parse_optional_int(
                        item.get("timeout"),
                        field_name="timeout",
                        entry_label=target_file,
                    ),
                    llm_max_retries=parse_optional_int(
                        item.get("retries"),
                        field_name="retries",
                        entry_label=target_file,
                    ),
                    pipeline_overrides=parse_pipeline_overrides(
                        item.get("pipeline_overrides"),
                        base_dir=base_dir,
                        target_file=target_file,
                    ),
                )
            )

    validate_manifest_dependencies(entries)
    return BatchManifest(
        manifest_path=resolved_path,
        batch_name=batch_name,
        src_root=src_root,
        pipeline_defaults=pipeline_defaults,
        entries=entries,
    )


def sanitize_entry_label(target_file: str) -> str:
    return re.sub(r"[^A-Za-z0-9._-]+", "-", target_file).strip("-")


def build_pipeline_command(
    manifest: BatchManifest,
    entry: BatchEntry,
    run_root: Path,
    python_executable: str,
    pipeline_script: Path,
) -> List[str]:
    command = [
        python_executable,
        str(pipeline_script),
        "--src-root",
        str(manifest.src_root),
        "--target-file",
        entry.target_file,
        "--run-root",
        str(run_root),
        "--summary-path",
        str(run_root / "summary.json"),
        "--failure-path",
        str(run_root / "failure.json"),
    ]

    effective_defaults = dict(manifest.pipeline_defaults)
    effective_defaults.update(entry.pipeline_overrides or {})
    if entry.timeout_seconds is not None:
        effective_defaults["timeout_seconds"] = entry.timeout_seconds
    if entry.llm_max_retries is not None:
        effective_defaults["llm_max_retries"] = entry.llm_max_retries

    for key, value in effective_defaults.items():
        if value is None:
            continue
        if key in BOOL_FLAG_MAP:
            positive_flag, negative_flag = BOOL_FLAG_MAP[key]
            command.append(positive_flag if bool(value) else negative_flag)
            continue
        if key in REPEATABLE_FLAG_MAP:
            flag = REPEATABLE_FLAG_MAP[key]
            for item in value:
                command.extend([flag, str(item)])
            continue
        if key in VALUE_FLAG_MAP:
            command.extend([VALUE_FLAG_MAP[key], str(value)])
            continue
        raise BatchManifestError(f"manifest 含未知 pipeline_defaults 键：{key}")

    return command


def normalize_status_token(raw_value: Any) -> str:
    return str(raw_value or "").strip().lower().replace("_", "-")


def classify_entry_status(exit_code: int, summary_payload: Dict[str, Any], failure_payload: Dict[str, Any]) -> str:
    summary_status = normalize_status_token(summary_payload.get("status", ""))
    orchestration_status = normalize_status_token(
        ((summary_payload.get("orchestration") or {}) if isinstance(summary_payload.get("orchestration"), dict) else {}).get("final_status", "")
    )
    effective_status = orchestration_status or summary_status
    failure_class = normalize_status_token(
        summary_payload.get("failure_class")
        or failure_payload.get("failure_class")
        or ""
    )
    if effective_status == "repair-required":
        return "repair-required"
    if effective_status == "failed":
        return "failed"
    if failure_class.endswith("repair-required") or exit_code == 10:
        return "repair-required"
    if exit_code == 0 and effective_status in {"", "passed"}:
        return "passed"
    if effective_status == "passed":
        return "passed"
    if effective_status:
        return effective_status
    if exit_code == 0:
        return "passed"
    return "pipeline-error"


def summarize_statistics(entries: List[Dict[str, Any]]) -> Dict[str, int]:
    total_entries = len(entries)
    counted_entries = sum(1 for item in entries if item["count_toward_kpi"])
    passed_entries = sum(1 for item in entries if item["status"] == "passed")
    failed_entries = sum(1 for item in entries if item["status"] not in {"passed", "skipped"})
    skipped_entries = sum(1 for item in entries if item["status"] == "skipped")
    repair_required_entries = sum(1 for item in entries if item["status"] == "repair-required")
    counted_passed_entries = sum(1 for item in entries if item["count_toward_kpi"] and item["status"] == "passed")
    counted_failed_entries = sum(
        1 for item in entries if item["count_toward_kpi"] and item["status"] not in {"passed", "skipped"}
    )
    counted_skipped_entries = sum(1 for item in entries if item["count_toward_kpi"] and item["status"] == "skipped")
    return {
        "total_entries": total_entries,
        "counted_entries": counted_entries,
        "passed_entries": passed_entries,
        "failed_entries": failed_entries,
        "skipped_entries": skipped_entries,
        "repair_required_entries": repair_required_entries,
        "counted_passed_entries": counted_passed_entries,
        "counted_failed_entries": counted_failed_entries,
        "counted_skipped_entries": counted_skipped_entries,
    }


def build_batch_status(statistics: Dict[str, int]) -> str:
    if statistics["failed_entries"] == 0 and statistics.get("skipped_entries", 0) == 0:
        return "passed"
    if statistics["failed_entries"] == 0 and statistics.get("skipped_entries", 0) > 0:
        return "partial"
    if statistics["counted_passed_entries"] > 0:
        return "partial"
    return "failed"


def load_optional_json(path: Path) -> Dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return read_json(path)
    except json.JSONDecodeError:
        return {}


def copy_manifest_to_run_root(manifest: BatchManifest, batch_run_root: Path) -> Path:
    target = batch_run_root / "manifest.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(manifest.manifest_path, target)
    return target


def capture_toolchain_env_snapshot() -> Dict[str, str]:
    return {key: os.environ.get(key, "") for key in TOOLCHAIN_ENV_KEYS if os.environ.get(key, "")}


def build_child_process_env() -> Dict[str, str]:
    env = os.environ.copy()
    for key in TOOLCHAIN_ENV_KEYS:
        if key in os.environ:
            env[key] = os.environ[key]
    return env


def truncate_stderr(stderr_text: str) -> str:
    return stderr_text[:MAX_FAILURE_STDERR_CHARS]


def materialize_failure_artifacts(
    output_root: Path,
    entry_record: Dict[str, Any],
    stderr_text: str,
) -> Dict[str, str]:
    failure_root = output_root / "failure"
    failure_root.mkdir(parents=True, exist_ok=True)
    label = str(entry_record["label"])
    stderr_path = failure_root / f"{label}.stderr.log"
    payload_path = failure_root / f"{label}.failure.json"
    stderr_excerpt = truncate_stderr(stderr_text)
    stderr_path.write_text(stderr_excerpt, encoding="utf-8")
    payload = {
        "target_file": entry_record["target_file"],
        "label": label,
        "status": entry_record["status"],
        "failure_class": entry_record["failure_class"],
        "exit_code": entry_record["exit_code"],
        "summary_path": entry_record["summary_path"],
        "failure_path": entry_record["failure_path"],
        "stderr_excerpt_path": str(stderr_path),
        "stderr_excerpt_chars": len(stderr_excerpt),
    }
    write_json(payload_path, payload)
    return {
        "failure_artifact_json": str(payload_path),
        "failure_stderr_excerpt_path": str(stderr_path),
    }


def build_skipped_entry_record(
    output_root: Path,
    entry: BatchEntry,
    *,
    skip_reason: str,
) -> Dict[str, Any]:
    label = sanitize_entry_label(entry.target_file)
    run_root = output_root / "runs" / label
    return {
        "target_file": entry.target_file,
        "label": label,
        "risk_level": entry.risk_level,
        "verification_mode": entry.verification_mode,
        "count_toward_kpi": entry.count_toward_kpi,
        "notes": entry.notes,
        "depends_on": list(entry.depends_on or []),
        "run_root": str(run_root),
        "summary_path": str(run_root / "summary.json"),
        "failure_path": str(run_root / "failure.json"),
        "exit_code": None,
        "status": "skipped",
        "failure_class": "skipped-by-batch",
        "skip_reason": skip_reason,
        "stdout_path": str(run_root / "stdout.log"),
        "stderr_path": str(run_root / "stderr.log"),
    }


def run_batch(
    manifest_path: Path,
    batch_run_root: Optional[Path] = None,
    python_executable: str = sys.executable,
    pipeline_script: Path = DEFAULT_PIPELINE_SCRIPT,
    continue_on_error: bool = False,
) -> int:
    manifest = load_manifest(manifest_path)
    output_root = (batch_run_root or (DEFAULT_BATCH_RUNS_ROOT / manifest.batch_name)).expanduser().resolve()
    output_root.mkdir(parents=True, exist_ok=True)
    failure_output_root = output_root / "failure"
    if failure_output_root.exists():
        shutil.rmtree(failure_output_root)
    copied_manifest_path = copy_manifest_to_run_root(manifest, output_root)

    entry_records: List[Dict[str, Any]] = []
    started_at = utc_now()
    child_env = build_child_process_env()
    blocking_targets: set[str] = set()

    for index, entry in enumerate(manifest.entries):
        blocking_dependency = next((dependency for dependency in entry.depends_on or [] if dependency in blocking_targets), None)
        if blocking_dependency is not None:
            entry_records.append(
                build_skipped_entry_record(
                    output_root,
                    entry,
                    skip_reason=f"dependency-blocked:{blocking_dependency}",
                )
            )
            continue

        label = sanitize_entry_label(entry.target_file)
        run_root = output_root / "runs" / label
        run_root.mkdir(parents=True, exist_ok=True)
        command = build_pipeline_command(manifest, entry, run_root, python_executable, pipeline_script)
        completed = subprocess.run(
            command,
            cwd=PROJECT_ROOT,
            check=False,
            capture_output=True,
            text=True,
            env=child_env,
        )

        summary_path = run_root / "summary.json"
        failure_path = run_root / "failure.json"
        summary_payload = load_optional_json(summary_path)
        failure_payload = load_optional_json(failure_path)
        status = classify_entry_status(completed.returncode, summary_payload, failure_payload)
        failure_class = str(
            summary_payload.get("failure_class")
            or failure_payload.get("failure_class")
            or ""
        )

        entry_record = {
            "target_file": entry.target_file,
            "label": label,
            "risk_level": entry.risk_level,
            "verification_mode": entry.verification_mode,
            "count_toward_kpi": entry.count_toward_kpi,
            "notes": entry.notes,
            "depends_on": list(entry.depends_on or []),
            "run_root": str(run_root),
            "summary_path": str(summary_path),
            "failure_path": str(failure_path),
            "exit_code": completed.returncode,
            "status": status,
            "failure_class": failure_class,
            "stdout_path": str(run_root / "stdout.log"),
            "stderr_path": str(run_root / "stderr.log"),
        }
        (run_root / "stdout.log").write_text(completed.stdout, encoding="utf-8")
        (run_root / "stderr.log").write_text(completed.stderr, encoding="utf-8")
        if status not in {"passed", "skipped"}:
            entry_record.update(materialize_failure_artifacts(output_root, entry_record, completed.stderr))
        entry_records.append(entry_record)
        if status != "passed":
            blocking_targets.add(entry.target_file)
            if not continue_on_error:
                for remaining_entry in manifest.entries[index + 1 :]:
                    entry_records.append(
                        build_skipped_entry_record(
                            output_root,
                            remaining_entry,
                            skip_reason=f"halted-after-failure:{entry.target_file}",
                        )
                    )
                break

    statistics = summarize_statistics(entry_records)
    batch_status = build_batch_status(statistics)
    success_targets = [item["target_file"] for item in entry_records if item["status"] == "passed"]
    failure_targets = [item["target_file"] for item in entry_records if item["status"] not in {"passed", "skipped"}]
    pattern_candidates = [
        {
            "target_file": item["target_file"],
            "risk_level": item["risk_level"],
            "summary_path": item["summary_path"],
        }
        for item in entry_records
        if item["count_toward_kpi"] and item["status"] == "passed"
    ]

    batch_summary = {
        "batch_name": manifest.batch_name,
        "manifest_path": str(copied_manifest_path),
        "source_manifest_path": str(manifest.manifest_path),
        "src_root": str(manifest.src_root),
        "batch_run_root": str(output_root),
        "pipeline_script": str(pipeline_script),
        "python_executable": python_executable,
        "environment_snapshot": capture_toolchain_env_snapshot(),
        "started_at": started_at,
        "finished_at": utc_now(),
        "continue_on_error": continue_on_error,
        "status": batch_status,
        "statistics": statistics,
        "entries": entry_records,
    }
    for filename in BATCH_SUMMARY_FILENAMES:
        write_json(output_root / filename, batch_summary)
    write_json(output_root / "success-list.json", {"targets": success_targets})
    write_json(output_root / "failure-list.json", {"targets": failure_targets})
    write_json(output_root / "pattern-candidates.json", {"candidates": pattern_candidates})

    if statistics["failed_entries"] == 0:
        return 0
    return 10


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="顺序调度多个 pipeline_runner target-file，并汇总批次结果")
    parser.add_argument("--manifest", required=True, help="Batch manifest JSON 路径")
    parser.add_argument("--batch-run-root", help="批次运行目录，默认 artifacts/batch_runs/<batch_name>")
    parser.add_argument("--python-executable", default=sys.executable, help="用于调用 pipeline_runner.py 的 Python 可执行文件")
    parser.add_argument("--pipeline-script", default=str(DEFAULT_PIPELINE_SCRIPT), help="pipeline_runner.py 路径")
    parser.add_argument("--continue-on-error", action="store_true", help="单文件失败后继续处理后续独立 target")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        return run_batch(
            manifest_path=Path(args.manifest),
            batch_run_root=Path(args.batch_run_root).expanduser().resolve() if args.batch_run_root else None,
            python_executable=args.python_executable,
            pipeline_script=Path(args.pipeline_script).expanduser().resolve(),
            continue_on_error=args.continue_on_error,
        )
    except BatchManifestError as exc:
        print(f"[pipeline-batch] manifest-error: {exc}", file=sys.stderr)
        return 20


if __name__ == "__main__":
    raise SystemExit(main())
