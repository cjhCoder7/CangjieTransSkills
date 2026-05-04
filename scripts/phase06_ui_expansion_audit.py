#!/usr/bin/env python3
"""Audit whether Phase06 UI should hold, continue, or expand the regular workset."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Sequence


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SAMPLE_MANIFEST_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "artifacts" / "ui_pilots" / "phase06_ui_regular_expansion_audit.json"
DEFAULT_SOURCE_CORPUS_GLOB = "docs/manifests/phase06_ui_source_corpus_*.json"
DEFAULT_FILE_MANIFEST_GLOB = "docs/manifests/phase06_ui_*_file_manifest.json"
DEFAULT_WORKSET_AUDIT_GLOB = "artifacts/ui_pilots/*phase06-ui-*workset-audit.json"

DECISION_REPAIR_CHAIN = "repair-manifest-chain-before-expansion"
DECISION_EXPAND_FROZEN = "expand-frozen-corpus-into-file-manifest"
DECISION_CONTINUE_WORKSET = "continue-current-workset"
DECISION_FREEZE_NEW_CORPUS = "freeze-new-regular-source-corpus"
DECISION_HOLD = "hold-current-checkpoint-await-sample-curation"
DECISION_CHOICES = (
    DECISION_REPAIR_CHAIN,
    DECISION_EXPAND_FROZEN,
    DECISION_CONTINUE_WORKSET,
    DECISION_FREEZE_NEW_CORPUS,
    DECISION_HOLD,
)

DECISION_SCOPE_REGULAR_EXPANSION = "phase06-regular-expansion"
DECISION_SCOPE_WORKSET = "phase06-file-workset"


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def read_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def normalize_string_list(value: Any) -> List[str]:
    if not isinstance(value, list):
        return []
    result: List[str] = []
    seen = set()
    for item in value:
        normalized = str(item).strip()
        if not normalized or normalized in seen:
            continue
        seen.add(normalized)
        result.append(normalized)
    return result


def discover_paths(glob_pattern: str) -> List[Path]:
    return sorted(PROJECT_ROOT.glob(glob_pattern))


def has_draft_marker(*values: Any) -> bool:
    for value in values:
        text = str(value).strip().lower()
        if text and "draft" in text:
            return True
    return False


def is_regular_sample(sample: Dict[str, Any]) -> bool:
    if str(sample.get("adoption_decision", "")).strip() != "primary":
        return False
    if str(sample.get("source_type", "")).strip() != "external_repo":
        return False
    if str(sample.get("role", "")).strip():
        return False
    return bool(str(sample.get("sample_id", "")).strip())


def collect_regular_samples(sample_manifest_payload: Dict[str, Any]) -> List[Dict[str, Any]]:
    ordered_samples = sample_manifest_payload.get("ordered_samples", [])
    if not isinstance(ordered_samples, list):
        return []
    samples: List[Dict[str, Any]] = []
    for item in ordered_samples:
        if isinstance(item, dict) and is_regular_sample(item):
            samples.append(item)
    return samples


def is_regular_source_corpus(path: Path, payload: Dict[str, Any]) -> bool:
    selection_policy = payload.get("selection_policy", {}) if isinstance(payload.get("selection_policy"), dict) else {}
    sample_buckets = normalize_string_list(selection_policy.get("sample_buckets"))
    manifest_name = str(payload.get("manifest_name", "")).strip().lower()
    source_manifest = str(payload.get("source_manifest", "")).strip().lower()
    role = str(selection_policy.get("role", "")).strip().lower()
    adoption_decision = str(selection_policy.get("adoption_decision", "")).strip().lower()
    source_type = str(selection_policy.get("source_type", "")).strip().lower()
    if has_draft_marker(path, manifest_name, source_manifest):
        return False
    if role and role not in {"any", "*"}:
        return False
    if sample_buckets:
        return "ordered_samples" in sample_buckets
    return adoption_decision == "primary" and source_type == "external_repo"


def is_regular_file_manifest(path: Path, payload: Dict[str, Any]) -> bool:
    manifest_name = str(payload.get("manifest_name", "")).strip().lower()
    source_corpus_manifest = str(payload.get("source_corpus_manifest", "")).strip().lower()
    if has_draft_marker(path, manifest_name, source_corpus_manifest):
        return False
    if "exception" in manifest_name or "exception" in source_corpus_manifest:
        return False
    entries = payload.get("entries", [])
    return isinstance(entries, list) and bool(entries)


def is_regular_workset_audit(path: Path, payload: Dict[str, Any]) -> bool:
    file_manifest = payload.get("file_manifest", {}) if isinstance(payload.get("file_manifest"), dict) else {}
    manifest_name = str(file_manifest.get("manifest_name", "")).strip().lower()
    manifest_path = str(file_manifest.get("manifest_path", "")).strip().lower()
    if has_draft_marker(path, manifest_name, manifest_path):
        return False
    if "exception" in manifest_name or "exception" in manifest_path:
        return False
    return bool(manifest_name or manifest_path)


def normalize_path_label(path: Path) -> str:
    return path.resolve().as_posix()


def build_report(
    *,
    sample_manifest_path: Path,
    sample_manifest_payload: Dict[str, Any],
    source_corpus_payloads: List[Dict[str, Any]],
    file_manifest_payloads: List[Dict[str, Any]],
    workset_audit_payloads: List[Dict[str, Any]],
) -> Dict[str, Any]:
    regular_samples = collect_regular_samples(sample_manifest_payload)
    regular_sample_details: List[Dict[str, Any]] = []
    for sample in regular_samples:
        sample_id = str(sample.get("sample_id", "")).strip()
        regular_sample_details.append(
            {
                "sample_id": sample_id,
                "priority": str(sample.get("priority", "")).strip(),
                "source_url": str((sample.get("source") or {}).get("url", "")).strip(),
                "source_commit": str((sample.get("source") or {}).get("commit", "")).strip(),
                "source_paths": normalize_string_list(sample.get("source_paths")),
            }
        )
    regular_sample_ids = [item["sample_id"] for item in regular_sample_details]
    regular_sample_id_set = set(regular_sample_ids)
    regular_sample_by_id = {item["sample_id"]: item for item in regular_sample_details}
    priority_counts = dict(sorted(Counter(item["priority"] for item in regular_sample_details).items()))

    source_corpus_reports: List[Dict[str, Any]] = []
    frozen_sample_ids: List[str] = []
    frozen_sample_seen = set()
    source_corpus_file_names: List[str] = []
    ignored_source_corpus_paths: List[str] = []
    for item in source_corpus_payloads:
        path = Path(str(item["path"]))
        payload = item["payload"]
        if not is_regular_source_corpus(path, payload):
            ignored_source_corpus_paths.append(normalize_path_label(path))
            continue
        sample_ids: List[str] = []
        for entry in payload.get("entries", []):
            if not isinstance(entry, dict):
                continue
            sample_id = str(entry.get("sample_id", "")).strip() or str(entry.get("entry_id", "")).strip()
            if not sample_id:
                continue
            sample_ids.append(sample_id)
            if sample_id in regular_sample_id_set and sample_id not in frozen_sample_seen:
                frozen_sample_seen.add(sample_id)
                frozen_sample_ids.append(sample_id)
        source_corpus_file_names.append(path.name)
        source_corpus_reports.append(
            {
                "manifest_name": str(payload.get("manifest_name", "")).strip(),
                "manifest_path": normalize_path_label(path),
                "manifest_file_name": path.name,
                "sample_count": int(payload.get("sample_count", 0) or 0),
                "file_count": int(payload.get("file_count", 0) or 0),
                "selection_priority": str((payload.get("selection_policy") or {}).get("priority", "")).strip(),
                "sample_ids": sample_ids,
                "source_manifest": str(payload.get("source_manifest", "")).strip(),
            }
        )

    file_manifest_reports: List[Dict[str, Any]] = []
    file_manifest_sample_ids: List[str] = []
    file_manifest_sample_seen = set()
    ignored_file_manifest_paths: List[str] = []
    source_corpus_covered_by_file_manifest = set()
    for item in file_manifest_payloads:
        path = Path(str(item["path"]))
        payload = item["payload"]
        if not is_regular_file_manifest(path, payload):
            ignored_file_manifest_paths.append(normalize_path_label(path))
            continue
        sample_ids: List[str] = []
        sample_seen = set()
        slice_ids: List[str] = []
        for entry in payload.get("entries", []):
            if not isinstance(entry, dict):
                continue
            sample_id = str(entry.get("sample_id", "")).strip()
            if sample_id and sample_id not in sample_seen:
                sample_seen.add(sample_id)
                sample_ids.append(sample_id)
                if sample_id in regular_sample_id_set and sample_id not in file_manifest_sample_seen:
                    file_manifest_sample_seen.add(sample_id)
                    file_manifest_sample_ids.append(sample_id)
            slice_id = str(entry.get("slice_id", "")).strip()
            if slice_id:
                slice_ids.append(slice_id)
        source_corpus_manifest = str(payload.get("source_corpus_manifest", "")).strip()
        if source_corpus_manifest:
            source_corpus_covered_by_file_manifest.add(source_corpus_manifest)
        file_manifest_reports.append(
            {
                "manifest_name": str(payload.get("manifest_name", "")).strip(),
                "manifest_path": normalize_path_label(path),
                "manifest_file_name": path.name,
                "source_corpus_manifest": source_corpus_manifest,
                "sample_count": len(sample_ids),
                "slice_count": len(slice_ids),
                "sample_ids": sample_ids,
                "slice_ids": slice_ids,
            }
        )

    source_corpus_without_file_manifest = [
        file_name for file_name in source_corpus_file_names if file_name not in source_corpus_covered_by_file_manifest
    ]

    workset_audit_reports: List[Dict[str, Any]] = []
    workset_audit_by_path: Dict[str, Dict[str, Any]] = {}
    workset_audit_by_name: Dict[str, Dict[str, Any]] = {}
    ignored_workset_audit_paths: List[str] = []
    for item in workset_audit_payloads:
        path = Path(str(item["path"]))
        payload = item["payload"]
        if not is_regular_workset_audit(path, payload):
            ignored_workset_audit_paths.append(normalize_path_label(path))
            continue
        file_manifest = payload.get("file_manifest", {}) if isinstance(payload.get("file_manifest"), dict) else {}
        summary = payload.get("summary", {}) if isinstance(payload.get("summary"), dict) else {}
        workset_next_action_hint = str(payload.get("next_action_hint", "")).strip()
        report = {
            "audit_path": normalize_path_label(path),
            "decision_scope": DECISION_SCOPE_WORKSET,
            "file_manifest_name": str(file_manifest.get("manifest_name", "")).strip(),
            "file_manifest_path": str(file_manifest.get("manifest_path", "")).strip(),
            "expected_slice_count": int(file_manifest.get("expected_slice_count", 0) or 0),
            "covered_slice_count": int(summary.get("covered_slice_count", 0) or 0),
            "missing_slice_count": int(summary.get("missing_slice_count", 0) or 0),
            "coverage_ratio": float(summary.get("coverage_ratio", 0.0) or 0.0),
            "exhausted_workset": bool(summary.get("exhausted_workset", False)),
            "workset_next_action_hint": workset_next_action_hint,
            "next_action_hint": workset_next_action_hint,
        }
        workset_audit_reports.append(report)
        if report["file_manifest_path"]:
            workset_audit_by_path[report["file_manifest_path"]] = report
        if report["file_manifest_name"]:
            workset_audit_by_name[report["file_manifest_name"]] = report

    missing_workset_audits: List[Dict[str, Any]] = []
    non_exhausted_worksets: List[Dict[str, Any]] = []
    for report in file_manifest_reports:
        matched_audit = workset_audit_by_path.get(report["manifest_path"]) or workset_audit_by_name.get(report["manifest_name"])
        if not matched_audit:
            missing_workset_audits.append(
                {
                    "manifest_name": report["manifest_name"],
                    "manifest_path": report["manifest_path"],
                }
            )
            continue
        report["workset_audit_path"] = matched_audit["audit_path"]
        report["workset_exhausted"] = matched_audit["exhausted_workset"]
        report["workset_missing_slice_count"] = matched_audit["missing_slice_count"]
        if not matched_audit["exhausted_workset"]:
            non_exhausted_worksets.append(
                {
                    "manifest_name": report["manifest_name"],
                    "manifest_path": report["manifest_path"],
                    "audit_path": matched_audit["audit_path"],
                    "missing_slice_count": matched_audit["missing_slice_count"],
                    "coverage_ratio": matched_audit["coverage_ratio"],
                }
            )

    frozen_without_file_manifest = [sample_id for sample_id in frozen_sample_ids if sample_id not in file_manifest_sample_seen]
    unfrozen_regular_samples = [regular_sample_by_id[sample_id] for sample_id in regular_sample_ids if sample_id not in frozen_sample_seen]

    if source_corpus_without_file_manifest or missing_workset_audits:
        next_action_hint = DECISION_REPAIR_CHAIN
    elif frozen_without_file_manifest:
        next_action_hint = DECISION_EXPAND_FROZEN
    elif non_exhausted_worksets:
        next_action_hint = DECISION_CONTINUE_WORKSET
    elif unfrozen_regular_samples:
        next_action_hint = DECISION_FREEZE_NEW_CORPUS
    else:
        next_action_hint = DECISION_HOLD

    return {
        "audit_name": "phase06-ui-expansion-audit",
        "audit_version": 2,
        "created_at": utc_now(),
        "decision_scope": DECISION_SCOPE_REGULAR_EXPANSION,
        "final_decision": next_action_hint,
        "sample_manifest": {
            "manifest_path": normalize_path_label(sample_manifest_path),
            "regular_sample_count": len(regular_sample_ids),
            "regular_sample_ids": regular_sample_ids,
            "priority_counts": priority_counts,
        },
        "source_corpus_summary": {
            "manifest_count": len(source_corpus_reports),
            "ignored_manifest_count": len(ignored_source_corpus_paths),
            "frozen_sample_count": len(frozen_sample_ids),
            "frozen_sample_ids": frozen_sample_ids,
            "unfrozen_sample_count": len(unfrozen_regular_samples),
            "ignored_manifest_paths": ignored_source_corpus_paths,
            "source_corpus_without_file_manifest": source_corpus_without_file_manifest,
        },
        "file_manifest_summary": {
            "manifest_count": len(file_manifest_reports),
            "ignored_manifest_count": len(ignored_file_manifest_paths),
            "covered_sample_count": len(file_manifest_sample_ids),
            "covered_sample_ids": file_manifest_sample_ids,
            "frozen_without_file_manifest_count": len(frozen_without_file_manifest),
            "frozen_without_file_manifest": frozen_without_file_manifest,
            "ignored_manifest_paths": ignored_file_manifest_paths,
        },
        "workset_summary": {
            "audit_count": len(workset_audit_reports),
            "ignored_audit_count": len(ignored_workset_audit_paths),
            "missing_workset_audit_count": len(missing_workset_audits),
            "non_exhausted_workset_count": len(non_exhausted_worksets),
            "ignored_audit_paths": ignored_workset_audit_paths,
        },
        "source_corpus_reports": source_corpus_reports,
        "file_manifest_reports": file_manifest_reports,
        "workset_audit_reports": workset_audit_reports,
        "unfrozen_regular_samples": unfrozen_regular_samples,
        "missing_workset_audits": missing_workset_audits,
        "non_exhausted_worksets": non_exhausted_worksets,
        "next_action_hint": next_action_hint,
    }


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit Phase06 UI regular expansion readiness.")
    parser.add_argument("--sample-manifest", default=str(DEFAULT_SAMPLE_MANIFEST_PATH))
    parser.add_argument("--source-corpus-manifest", action="append", dest="source_corpus_manifests")
    parser.add_argument("--file-manifest", action="append", dest="file_manifests")
    parser.add_argument("--workset-audit", action="append", dest="workset_audits")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT_PATH))
    parser.add_argument("--require-decision", choices=list(DECISION_CHOICES))
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    sample_manifest_path = Path(args.sample_manifest).resolve()
    source_corpus_paths = [Path(item).resolve() for item in (args.source_corpus_manifests or discover_paths(DEFAULT_SOURCE_CORPUS_GLOB))]
    file_manifest_paths = [Path(item).resolve() for item in (args.file_manifests or discover_paths(DEFAULT_FILE_MANIFEST_GLOB))]
    workset_audit_paths = [Path(item).resolve() for item in (args.workset_audits or discover_paths(DEFAULT_WORKSET_AUDIT_GLOB))]
    output_path = Path(args.output).resolve()

    report = build_report(
        sample_manifest_path=sample_manifest_path,
        sample_manifest_payload=read_json(sample_manifest_path),
        source_corpus_payloads=[{"path": path, "payload": read_json(path)} for path in source_corpus_paths],
        file_manifest_payloads=[{"path": path, "payload": read_json(path)} for path in file_manifest_paths],
        workset_audit_payloads=[{"path": path, "payload": read_json(path)} for path in workset_audit_paths],
    )
    write_json(output_path, report)
    print(output_path.as_posix())

    if args.require_decision and report["final_decision"] != args.require_decision:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())