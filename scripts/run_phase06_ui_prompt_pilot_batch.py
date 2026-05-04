#!/usr/bin/env python3
"""Run selected Phase06 prompt pilots through the live orchestrator lane."""

from __future__ import annotations

import argparse
import json
import os
import shlex
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Sequence

from orchestrator import (
    DEFAULT_SCHEMA_PATH,
    SchemaPolicy,
    load_architecture_skill_texts,
    should_use_phase06_large_source_backed_native_cangjie_special_lane,
)
from pattern_memory import DEFAULT_MEMORY_PATH, PatternMemoryEngine
from pipeline_runner import render_prompt_dump
from prompt_assembler import PromptAssembler

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_prompt_pilot_batch1.json"
DEFAULT_ARCHITECTURE_SKILL_PATH = (
    PROJECT_ROOT / "docs" / "strategy" / "phase-06-ui-sample-taxonomy-and-prompt-constraints.md"
)
DEFAULT_BATCH_ROOT = PROJECT_ROOT / "artifacts" / "ui_pilots" / "20260408-phase06-ui-pilot-batch1" / "live_curator"


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def default_run_label() -> str:
    return "live-curator-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def read_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def resolve_batch_root(manifest: Dict[str, Any]) -> Path:
    selection_policy = manifest.get("selection_policy", {})
    if isinstance(selection_policy, dict):
        artifact_root_value = str(selection_policy.get("artifact_root", "")).strip()
        if artifact_root_value:
            return PROJECT_ROOT / artifact_root_value / "live_curator"
    return DEFAULT_BATCH_ROOT


def select_entries(
    manifest_entries: Sequence[Dict[str, Any]],
    *,
    pilot_ids: Sequence[str],
    slice_ids: Sequence[str],
) -> List[Dict[str, Any]]:
    if not pilot_ids and not slice_ids:
        return [dict(entry) for entry in manifest_entries if isinstance(entry, dict)]

    selected: List[Dict[str, Any]] = []
    wanted_pilot_ids = set(pilot_ids)
    wanted_slice_ids = set(slice_ids)
    for entry in manifest_entries:
        if not isinstance(entry, dict):
            continue
        if entry.get("pilot_id") in wanted_pilot_ids or entry.get("slice_id") in wanted_slice_ids:
            selected.append(dict(entry))

    missing = wanted_pilot_ids.difference({entry.get("pilot_id") for entry in selected})
    missing.update(wanted_slice_ids.difference({entry.get("slice_id") for entry in selected}))
    if missing:
        raise SystemExit(f"pilot manifest missing requested ids: {', '.join(sorted(missing))}")
    return selected


def ensure_explicit_tu(entry: Dict[str, Any]) -> Path:
    explicit_tu_path = PROJECT_ROOT / str(entry["explicit_tu_json_path"])
    if explicit_tu_path.exists():
        return explicit_tu_path

    base_tu_path = ensure_base_tu(entry)

    payload = read_json(base_tu_path)
    target = payload.setdefault("target", {})
    metadata = payload.setdefault("metadata", {})
    ui_prompt_tags = dict(entry.get("ui_prompt_tags", {}))
    target["ui_prompt_tags"] = ui_prompt_tags
    target["phase06_ui_tags"] = ui_prompt_tags
    target["role"] = entry.get("target_role", target.get("role", ""))
    metadata["ui_prompt_tags"] = ui_prompt_tags
    metadata["phase06_ui_tags"] = ui_prompt_tags
    metadata["phase06_prompt_pilot"] = {
        "pilot_id": entry.get("pilot_id", ""),
        "track_id": entry.get("track_id", ""),
        "selection_reason": entry.get("selection_reason", ""),
    }
    write_json(explicit_tu_path, payload)
    return explicit_tu_path


def ensure_explicit_prompt_dump(entry: Dict[str, Any], *, model: str, pattern_limit: int) -> Path:
    explicit_prompt_path = PROJECT_ROOT / str(entry["explicit_prompt_dump_path"])
    if explicit_prompt_path.exists():
        return explicit_prompt_path

    explicit_tu_path = ensure_explicit_tu(entry)
    tu = read_json(explicit_tu_path)
    schema_policy = SchemaPolicy(DEFAULT_SCHEMA_PATH)
    architecture_skill_paths = [DEFAULT_ARCHITECTURE_SKILL_PATH]
    prompt_assembler = PromptAssembler(
        schema_text=schema_policy.schema_text,
        architecture_skill_texts=load_architecture_skill_texts(architecture_skill_paths),
    )
    pattern_memory = PatternMemoryEngine(DEFAULT_MEMORY_PATH)
    pattern_examples = pattern_memory.query_for_tu(tu, limit=pattern_limit)
    required_dimensions = schema_policy.required_dimensions(tu)
    prompt = prompt_assembler.build_translator_prompt(
        tu=tu,
        required_dimensions=required_dimensions,
        attempt=1,
        repair_guidance=[],
        pattern_examples=pattern_examples,
        repair_anchor=None,
    )
    explicit_prompt_path.parent.mkdir(parents=True, exist_ok=True)
    dump_text = render_prompt_dump(
        prompt=prompt,
        tu=tu,
        model=model,
        schema_path=DEFAULT_SCHEMA_PATH,
        architecture_skill_paths=architecture_skill_paths,
        required_dimensions=required_dimensions,
        pattern_examples=pattern_examples,
    )
    explicit_prompt_path.write_text(dump_text, encoding="utf-8")
    return explicit_prompt_path


def has_real_llm_credentials(env: Mapping[str, str] | None = None) -> bool:
    env_map = env if env is not None else os.environ
    return bool(str(env_map.get("SILICONFLOW_API_KEY", "")).strip() or str(env_map.get("OPENAI_API_KEY", "")).strip())


def resolve_effective_mock_mode(
    *,
    requested_mock_mode: bool,
    tu: Dict[str, Any],
    env: Mapping[str, str] | None = None,
) -> bool:
    if requested_mock_mode:
        return True
    if should_use_phase06_large_source_backed_native_cangjie_special_lane(tu) and not has_real_llm_credentials(env):
        return True
    return False


def ensure_base_tu(entry: Dict[str, Any]) -> Path:
    base_tu_path = PROJECT_ROOT / str(entry["base_tu_json_path"])
    if base_tu_path.exists():
        return base_tu_path

    pipeline_command = str(entry.get("pipeline_command", "")).strip()
    if not pipeline_command:
        raise SystemExit(f"missing base TU JSON for pilot {entry['pilot_id']}: {base_tu_path}")

    log_path_value = str(entry.get("pipeline_log_path", "")).strip()
    log_path = PROJECT_ROOT / log_path_value if log_path_value else None
    if log_path is not None:
        log_path.parent.mkdir(parents=True, exist_ok=True)

    command = shlex.split(pipeline_command)
    env = os.environ.copy()
    if log_path is None:
        completed = subprocess.run(
            command,
            cwd=PROJECT_ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.STDOUT,
            text=True,
            env=env,
        )
    else:
        with log_path.open("a", encoding="utf-8") as handle:
            handle.write(f"[run_phase06_ui_prompt_pilot_batch][bootstrap] {pipeline_command}\n")
            completed = subprocess.run(
                command,
                cwd=PROJECT_ROOT,
                stdout=handle,
                stderr=subprocess.STDOUT,
                text=True,
                env=env,
            )

    if completed.returncode != 0:
        raise SystemExit(
            f"failed to bootstrap base TU JSON for pilot {entry['pilot_id']}: exit={completed.returncode}"
        )
    if not base_tu_path.exists():
        raise SystemExit(f"bootstrap pipeline did not create base TU JSON for pilot {entry['pilot_id']}: {base_tu_path}")
    return base_tu_path


def build_orchestrator_command(
    *,
    tu_json_path: Path,
    workspace_root: Path,
    output_path: Path,
    model: str,
    timeout_seconds: int,
    llm_max_retries: int,
    max_rounds: int,
    pattern_limit: int,
    use_mock_mode: bool,
    verify_no_dry_run: bool,
    verify_real_compile: bool,
    verify_real_unit_test: bool,
    verify_real_behavior: bool,
) -> List[str]:
    argv = [
        "python3",
        "scripts/orchestrator.py",
        "--tu-json",
        str(tu_json_path),
        "--architecture-skill",
        "docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md",
        "--pattern-limit",
        str(pattern_limit),
        "--workspace-root",
        str(workspace_root),
        "--model",
        model,
        "--timeout-seconds",
        str(timeout_seconds),
        "--llm-max-retries",
        str(llm_max_retries),
        "--max-rounds",
        str(max_rounds),
        "--output",
        str(output_path),
    ]
    if use_mock_mode:
        argv.append("--mock-mode")
    if verify_no_dry_run:
        argv.append("--verify-no-dry-run")
    if verify_real_compile:
        argv.append("--verify-real-compile")
    if verify_real_unit_test:
        argv.append("--verify-real-unit-test")
    if verify_real_behavior:
        argv.append("--verify-real-behavior")
    return argv


def run_selected_pilots(
    *,
    manifest_path: Path,
    run_label: str,
    pilot_ids: Sequence[str],
    slice_ids: Sequence[str],
    model: str,
    timeout_seconds: int,
    llm_max_retries: int,
    max_rounds: int,
    pattern_limit: int,
    use_mock_mode: bool,
    verify_no_dry_run: bool,
    verify_real_compile: bool,
    verify_real_unit_test: bool,
    verify_real_behavior: bool,
    fail_fast: bool,
) -> Dict[str, Any]:
    manifest = read_json(manifest_path)
    entries = manifest.get("entries", [])
    if not isinstance(entries, list) or not entries:
        raise SystemExit(f"pilot manifest has no entries: {manifest_path}")

    selected_entries = select_entries(
        [entry for entry in entries if isinstance(entry, dict)],
        pilot_ids=pilot_ids,
        slice_ids=slice_ids,
    )

    batch_root = resolve_batch_root(manifest) / run_label
    batch_root.mkdir(parents=True, exist_ok=True)

    results: List[Dict[str, Any]] = []
    for entry in selected_entries:
        pilot_root = batch_root / str(entry["slice_id"])
        workspace_root = pilot_root / "temp_workspace"
        output_path = pilot_root / "orchestration.json"
        log_path = pilot_root / "run.log"
        summary_path = pilot_root / "summary.json"
        tu_json_path = ensure_explicit_tu(entry)
        ensure_explicit_prompt_dump(entry, model=model, pattern_limit=pattern_limit)
        tu_payload = read_json(tu_json_path)
        effective_mock_mode = resolve_effective_mock_mode(
            requested_mock_mode=use_mock_mode,
            tu=tu_payload,
            env=os.environ,
        )
        command = build_orchestrator_command(
            tu_json_path=tu_json_path,
            workspace_root=workspace_root,
            output_path=output_path,
            model=model,
            timeout_seconds=timeout_seconds,
            llm_max_retries=llm_max_retries,
            max_rounds=max_rounds,
            pattern_limit=pattern_limit,
            use_mock_mode=effective_mock_mode,
            verify_no_dry_run=verify_no_dry_run,
            verify_real_compile=verify_real_compile,
            verify_real_unit_test=verify_real_unit_test,
            verify_real_behavior=verify_real_behavior,
        )
        pilot_root.mkdir(parents=True, exist_ok=True)
        with log_path.open("w", encoding="utf-8") as handle:
            completed = subprocess.run(
                command,
                cwd=PROJECT_ROOT,
                stdout=handle,
                stderr=subprocess.STDOUT,
                text=True,
                env=os.environ.copy(),
            )

        orchestration: Dict[str, Any] = {}
        if output_path.exists():
            orchestration = read_json(output_path)

        final_verify = orchestration.get("final_verify", {}) if isinstance(orchestration, dict) else {}
        result = {
            "pilot_id": entry.get("pilot_id", ""),
            "slice_id": entry.get("slice_id", ""),
            "track_id": entry.get("track_id", ""),
            "status": "completed" if completed.returncode == 0 else "failed",
            "exit_code": completed.returncode,
            "final_status": orchestration.get("final_status", ""),
            "verify_status": final_verify.get("status", ""),
            "verify_passed": bool(final_verify.get("passed", False)),
            "round_count": len(orchestration.get("rounds", [])) if isinstance(orchestration.get("rounds", []), list) else 0,
            "orchestration_path": str(output_path.relative_to(PROJECT_ROOT)),
            "log_path": str(log_path.relative_to(PROJECT_ROOT)),
            "workspace_root": str(workspace_root.relative_to(PROJECT_ROOT)),
            "tu_json_path": str(tu_json_path.relative_to(PROJECT_ROOT)),
            "command": shlex.join(command),
            "mock_mode_used": effective_mock_mode,
        }
        write_json(summary_path, result)
        result["summary_path"] = str(summary_path.relative_to(PROJECT_ROOT))
        results.append(result)

        if fail_fast and completed.returncode != 0:
            break

    passed = sum(1 for item in results if item["status"] == "completed" and item["final_status"] == "passed")
    batch_report = {
        "manifest_path": str(manifest_path.relative_to(PROJECT_ROOT)),
        "run_label": run_label,
        "created_at": utc_now(),
        "model": model,
        "selected_pilot_ids": [item["pilot_id"] for item in results],
        "selected_slice_ids": [item["slice_id"] for item in results],
        "status": "passed" if passed == len(results) else ("partial" if passed else "failed"),
        "pilot_count": len(results),
        "passed_count": passed,
        "entries": results,
    }
    report_path = batch_root / "batch-report.json"
    write_json(report_path, batch_report)
    batch_report["report_path"] = str(report_path.relative_to(PROJECT_ROOT))
    return batch_report


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run selected Phase06 prompt pilots through the live orchestrator lane.")
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST_PATH), help="Prompt pilot manifest path")
    parser.add_argument("--run-label", default=default_run_label(), help="Artifact run label")
    parser.add_argument("--pilot-id", action="append", default=[], help="Specific pilot_id to run; repeatable")
    parser.add_argument("--slice-id", action="append", default=[], help="Specific slice_id to run; repeatable")
    parser.add_argument("--model", default=os.getenv("OPENAI_MODEL", "Pro/zai-org/GLM-5"), help="LLM model name")
    parser.add_argument("--timeout-seconds", type=int, default=300, help="Single LLM timeout seconds")
    parser.add_argument("--llm-max-retries", type=int, default=2, help="LLM network retry count")
    parser.add_argument("--max-rounds", type=int, default=1, help="Maximum live repair rounds")
    parser.add_argument("--pattern-limit", type=int, default=0, help="Injected pattern memory examples")
    parser.add_argument("--mock-mode", action="store_true", help="Use mock LLM instead of real adapter")
    parser.add_argument("--verify-no-dry-run", action="store_true", help="Use real subprocess verification")
    parser.add_argument("--verify-real-compile", action="store_true", help="Use real compile verification")
    parser.add_argument("--verify-real-unit-test", action="store_true", help="Use real unit test verification")
    parser.add_argument("--verify-real-behavior", action="store_true", help="Use real behavior verification")
    parser.add_argument("--fail-fast", action="store_true", help="Stop after the first failed pilot")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    report = run_selected_pilots(
        manifest_path=Path(args.manifest).resolve(),
        run_label=args.run_label,
        pilot_ids=args.pilot_id,
        slice_ids=args.slice_id,
        model=args.model,
        timeout_seconds=args.timeout_seconds,
        llm_max_retries=args.llm_max_retries,
        max_rounds=args.max_rounds,
        pattern_limit=args.pattern_limit,
        use_mock_mode=bool(args.mock_mode),
        verify_no_dry_run=bool(args.verify_no_dry_run),
        verify_real_compile=bool(args.verify_real_compile),
        verify_real_unit_test=bool(args.verify_real_unit_test),
        verify_real_behavior=bool(args.verify_real_behavior),
        fail_fast=bool(args.fail_fast),
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report["passed_count"] == report["pilot_count"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
