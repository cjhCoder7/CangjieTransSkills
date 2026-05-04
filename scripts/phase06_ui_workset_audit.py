#!/usr/bin/env python3
"""Audit Phase06 UI file-workset coverage across prompt-pilot manifests."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, List, Sequence


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_FILE_MANIFEST_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json"
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "artifacts" / "ui_pilots" / "phase06_ui_p0_workset_audit.json"


def read_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def normalize_slice_ids(value: Any) -> List[str]:
    if not isinstance(value, list):
        return []
    slice_ids: List[str] = []
    seen = set()
    for item in value:
        slice_id = str(item).strip()
        if not slice_id or slice_id in seen:
            continue
        seen.add(slice_id)
        slice_ids.append(slice_id)
    return slice_ids


def extract_file_slice_ids(payload: Dict[str, Any]) -> tuple[List[str], List[str]]:
    entries = payload.get("entries", []) if isinstance(payload.get("entries"), list) else []
    slice_ids: List[str] = []
    duplicates: List[str] = []
    seen = set()
    for item in entries:
        if not isinstance(item, dict):
            continue
        slice_id = str(item.get("slice_id", "")).strip()
        if not slice_id:
            continue
        if slice_id in seen:
            duplicates.append(slice_id)
            continue
        seen.add(slice_id)
        slice_ids.append(slice_id)
    return slice_ids, duplicates


def extract_manifest_slice_ids(payload: Dict[str, Any]) -> List[str]:
    slice_ids: List[str] = []
    seen = set()

    summary = payload.get("summary", {}) if isinstance(payload.get("summary"), dict) else {}
    for slice_id in normalize_slice_ids(summary.get("selected_slice_ids", [])):
        if slice_id in seen:
            continue
        seen.add(slice_id)
        slice_ids.append(slice_id)

    for key in ("entries", "pilots"):
        raw_entries = payload.get(key, [])
        if not isinstance(raw_entries, list):
            continue
        for item in raw_entries:
            if not isinstance(item, dict):
                continue
            slice_id = str(item.get("slice_id", "")).strip()
            if not slice_id or slice_id in seen:
                continue
            seen.add(slice_id)
            slice_ids.append(slice_id)

    return slice_ids


def resolve_manifest_label(path: Path, payload: Dict[str, Any]) -> str:
    manifest_name = str(payload.get("manifest_name", "")).strip()
    if manifest_name:
        return manifest_name
    return path.stem


def audit_workset(
    *,
    file_manifest_payload: Dict[str, Any],
    pilot_manifests: List[Dict[str, Any]],
) -> Dict[str, Any]:
    expected_slice_ids, file_manifest_duplicate_slice_ids = extract_file_slice_ids(file_manifest_payload)
    expected_slice_set = set(expected_slice_ids)
    coverage_by_slice: Dict[str, List[str]] = {slice_id: [] for slice_id in expected_slice_ids}

    covered_slice_ids: List[str] = []
    covered_seen = set()
    unknown_slice_ids: List[str] = []
    unknown_seen = set()
    unknown_details: List[Dict[str, Any]] = []
    manifest_reports: List[Dict[str, Any]] = []

    for item in pilot_manifests:
        manifest_path = Path(str(item["manifest_path"]))
        payload = item["payload"]
        manifest_label = str(item.get("manifest_label", "")).strip() or resolve_manifest_label(manifest_path, payload)
        slice_ids = extract_manifest_slice_ids(payload)

        known_slice_ids: List[str] = []
        overlap_slice_ids: List[str] = []
        manifest_unknown_slice_ids: List[str] = []

        for slice_id in slice_ids:
            if slice_id not in expected_slice_set:
                manifest_unknown_slice_ids.append(slice_id)
                if slice_id not in unknown_seen:
                    unknown_seen.add(slice_id)
                    unknown_slice_ids.append(slice_id)
                unknown_details.append(
                    {
                        "slice_id": slice_id,
                        "manifest_label": manifest_label,
                        "manifest_path": manifest_path.as_posix(),
                    }
                )
                continue

            if coverage_by_slice[slice_id]:
                overlap_slice_ids.append(slice_id)
            coverage_by_slice[slice_id].append(manifest_label)
            known_slice_ids.append(slice_id)
            if slice_id not in covered_seen:
                covered_seen.add(slice_id)
                covered_slice_ids.append(slice_id)

        manifest_reports.append(
            {
                "manifest_label": manifest_label,
                "manifest_path": manifest_path.as_posix(),
                "slice_count": len(slice_ids),
                "known_slice_count": len(known_slice_ids),
                "overlap_slice_count": len(overlap_slice_ids),
                "unknown_slice_count": len(manifest_unknown_slice_ids),
                "slice_ids": slice_ids,
                "known_slice_ids": known_slice_ids,
                "overlap_slice_ids": overlap_slice_ids,
                "unknown_slice_ids": manifest_unknown_slice_ids,
            }
        )

    missing_slice_ids = [slice_id for slice_id in expected_slice_ids if not coverage_by_slice[slice_id]]
    overlap_details = [
        {
            "slice_id": slice_id,
            "manifest_labels": coverage_by_slice[slice_id],
            "manifest_count": len(coverage_by_slice[slice_id]),
        }
        for slice_id in expected_slice_ids
        if len(coverage_by_slice[slice_id]) > 1
    ]
    overlap_slice_ids = [item["slice_id"] for item in overlap_details]

    exhausted_workset = not missing_slice_ids
    coverage_ratio = (len(covered_slice_ids) / len(expected_slice_ids)) if expected_slice_ids else 1.0
    if file_manifest_duplicate_slice_ids or overlap_slice_ids or unknown_slice_ids:
        next_action_hint = "fix-manifest-drift-before-expansion"
    elif exhausted_workset:
        next_action_hint = "current-file-workset-exhausted-prepare-new-source-corpus"
    else:
        next_action_hint = "continue-curating-residual-workset"

    return {
        "audit_name": "phase06-ui-workset-audit",
        "audit_version": 1,
        "file_manifest": {
            "manifest_name": str(file_manifest_payload.get("manifest_name", "")).strip(),
            "expected_slice_count": len(expected_slice_ids),
            "expected_slice_ids": expected_slice_ids,
            "duplicate_slice_count": len(file_manifest_duplicate_slice_ids),
            "duplicate_slice_ids": file_manifest_duplicate_slice_ids,
        },
        "summary": {
            "pilot_manifest_count": len(manifest_reports),
            "covered_slice_count": len(covered_slice_ids),
            "missing_slice_count": len(missing_slice_ids),
            "overlap_slice_count": len(overlap_slice_ids),
            "unknown_slice_count": len(unknown_slice_ids),
            "coverage_ratio": round(coverage_ratio, 4),
            "exhausted_workset": exhausted_workset,
        },
        "covered_slice_ids": covered_slice_ids,
        "missing_slice_ids": missing_slice_ids,
        "overlap_slice_ids": overlap_slice_ids,
        "overlap_details": overlap_details,
        "unknown_slice_ids": unknown_slice_ids,
        "unknown_details": unknown_details,
        "manifest_reports": manifest_reports,
        "next_action_hint": next_action_hint,
    }


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit Phase06 UI prompt-pilot coverage against a file-level workset.")
    parser.add_argument("--file-manifest", default=str(DEFAULT_FILE_MANIFEST_PATH))
    parser.add_argument("--pilot-manifest", action="append", dest="pilot_manifests", required=True)
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT_PATH))
    parser.add_argument("--require-exhausted", action="store_true")
    parser.add_argument("--fail-on-overlap", action="store_true")
    parser.add_argument("--fail-on-unknown", action="store_true")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    file_manifest_path = Path(args.file_manifest).resolve()
    output_path = Path(args.output).resolve()
    pilot_manifest_paths = [Path(item).resolve() for item in args.pilot_manifests]

    report = audit_workset(
        file_manifest_payload=read_json(file_manifest_path),
        pilot_manifests=[
            {
                "manifest_path": path.as_posix(),
                "payload": read_json(path),
            }
            for path in pilot_manifest_paths
        ],
    )
    report["file_manifest"]["manifest_path"] = file_manifest_path.as_posix()
    write_json(output_path, report)
    print(output_path.as_posix())

    if args.require_exhausted and report["summary"]["missing_slice_count"]:
        return 2
    if args.fail_on_overlap and (
        report["summary"]["overlap_slice_count"] or report["file_manifest"]["duplicate_slice_count"]
    ):
        return 3
    if args.fail_on_unknown and report["summary"]["unknown_slice_count"]:
        return 4
    return 0


if __name__ == "__main__":
    raise SystemExit(main())