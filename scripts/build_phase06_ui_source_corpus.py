#!/usr/bin/env python3
"""Build a Phase06 UI source corpus manifest from the curated sample manifest."""

from __future__ import annotations

import argparse
import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Sequence


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SAMPLE_MANIFEST_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
DEFAULT_CORPUS_ROOT = PROJECT_ROOT / "raw_docs" / "phase06-ui-p0"
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p0.json"
DEFAULT_MANIFEST_NAME = "phase06-ui-source-corpus-p0"
DEFAULT_SAMPLE_BUCKETS = ("ordered_samples",)
SUPPORTED_SAMPLE_BUCKETS = ("ordered_samples", "control_samples", "exception_references")


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def read_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def normalize_tag_list(value: Any) -> List[str]:
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if str(item).strip()]


def normalize_entry_id(sample: Dict[str, Any]) -> str:
    for key in ("sample_id", "reference_id"):
        value = str(sample.get(key, "")).strip()
        if value:
            return value
    raise ValueError("manifest entry missing sample_id/reference_id")


def normalize_filter_value(value: Any) -> str:
    raw = str(value or "").strip()
    if raw.lower() in {"", "any", "*"}:
        return ""
    return raw


def infer_repo_name(sample: Dict[str, Any]) -> str:
    entry_id = normalize_entry_id(sample)
    source_type = str(sample.get("source_type", "")).strip()
    source = sample.get("source", {}) if isinstance(sample.get("source"), dict) else {}
    if source_type == "external_repo":
        url = str(source.get("url", "")).rstrip("/")
        if not url:
            raise ValueError(f"sample `{entry_id}` missing source.url")
        repo_name = url.rsplit("/", 1)[-1]
        return repo_name[:-4] if repo_name.endswith(".git") else repo_name
    if source_type == "local_repo":
        repo_root = str(source.get("repo_root", "")).strip()
        if repo_root:
            return Path(repo_root).name
        if entry_id:
            return entry_id
    raise ValueError(f"unsupported or incomplete source_type for sample `{entry_id}`")


def build_repo_local_paths(sample: Dict[str, Any], corpus_root: Path) -> List[str]:
    source_type = str(sample.get("source_type", "")).strip()
    source_paths = normalize_tag_list(sample.get("source_paths"))
    if source_type == "external_repo":
        repo_name = infer_repo_name(sample)
        return [(corpus_root / repo_name / source_path).as_posix() for source_path in source_paths]
    if source_type == "local_repo":
        return source_paths
    raise ValueError(f"unsupported source_type `{source_type}` for sample `{normalize_entry_id(sample)}`")


def collect_samples(sample_manifest_payload: Dict[str, Any], sample_buckets: Sequence[str]) -> List[Dict[str, Any]]:
    entries: List[Dict[str, Any]] = []
    for bucket in sample_buckets:
        raw_entries = sample_manifest_payload.get(bucket, [])
        if not isinstance(raw_entries, list):
            raise ValueError(f"sample bucket `{bucket}` is not a list")
        for item in raw_entries:
            if isinstance(item, dict):
                entries.append(item)
    return entries


def matches_optional_filter(sample: Dict[str, Any], field: str, expected: str) -> bool:
    if not expected:
        return True
    return str(sample.get(field, "")).strip() == expected


def build_source_corpus_payload(
    *,
    sample_manifest_payload: Dict[str, Any],
    sample_manifest_path: Path,
    corpus_root: Path,
    manifest_name: str,
    priority: str,
    adoption_decision: str,
    source_type: str,
    sample_buckets: Sequence[str],
    output_path: Path,
    repo_root: Path,
    role: str = "",
    require_existing_files: bool = True,
) -> Dict[str, Any]:
    priority = normalize_filter_value(priority)
    adoption_decision = normalize_filter_value(adoption_decision)
    source_type = normalize_filter_value(source_type)
    role = normalize_filter_value(role)
    filtered_entries: List[Dict[str, Any]] = []
    missing_repo_local_paths: List[str] = []
    file_count = 0
    try:
        corpus_root_for_manifest = corpus_root.resolve().relative_to(repo_root.resolve())
    except ValueError:
        corpus_root_for_manifest = corpus_root

    for sample in collect_samples(sample_manifest_payload, sample_buckets):
        if not matches_optional_filter(sample, "priority", priority):
            continue
        if not matches_optional_filter(sample, "adoption_decision", adoption_decision):
            continue
        if not matches_optional_filter(sample, "source_type", source_type):
            continue
        if not matches_optional_filter(sample, "role", role):
            continue

        entry_id = normalize_entry_id(sample)
        repo_name = infer_repo_name(sample)
        repo_local_paths = build_repo_local_paths(sample, corpus_root_for_manifest)
        file_count += len(repo_local_paths)
        if require_existing_files:
            for repo_local_path in repo_local_paths:
                if not (repo_root / repo_local_path).exists():
                    missing_repo_local_paths.append(repo_local_path)

        filtered_entries.append(
            {
                "entry_id": entry_id,
                "sample_id": str(sample.get("sample_id", "")).strip() or entry_id,
                "reference_id": str(sample.get("reference_id", "")).strip(),
                "priority": str(sample.get("priority", "")).strip(),
                "source_type": str(sample.get("source_type", "")).strip(),
                "adoption_decision": str(sample.get("adoption_decision", "")).strip(),
                "role": str(sample.get("role", "")).strip(),
                "structure_tag": str(sample.get("structure_tag", "")).strip(),
                "ownership_tag": str(sample.get("ownership_tag", "")).strip(),
                "interaction_tags": normalize_tag_list(sample.get("interaction_tags")),
                "exception_tags": normalize_tag_list(sample.get("exception_tags")),
                "sample_scope_tags": normalize_tag_list(sample.get("sample_scope_tags")),
                "source": sample.get("source", {}),
                "source_paths": normalize_tag_list(sample.get("source_paths")),
                "repo_name": repo_name,
                "repo_local_paths": repo_local_paths,
                "staging_target": str(sample.get("staging_target", "")).strip(),
                "verification_mode": str(sample.get("verification_mode", "")).strip(),
                "usage_goal": str(sample.get("usage_goal", "")).strip(),
                "blocking_constraints": normalize_tag_list(sample.get("blocking_constraints")),
                "reason": str(sample.get("reason", "")).strip(),
            }
        )

    if require_existing_files and missing_repo_local_paths:
        raise ValueError("missing frozen corpus files: " + ", ".join(missing_repo_local_paths))

    corpus_root_relative = Path(os.path.relpath(corpus_root, sample_manifest_path.parent)).as_posix()
    selection_policy: Dict[str, Any] = {
        "priority": priority or "any",
        "adoption_decision": adoption_decision or "any",
        "source_type": source_type or "any",
        "sample_buckets": list(sample_buckets),
    }
    if role:
        selection_policy["role"] = role
    return {
        "manifest_name": manifest_name,
        "manifest_version": 1,
        "created_at": utc_now(),
        "corpus_root": corpus_root_relative,
        "source_manifest": sample_manifest_path.name,
        "selection_policy": selection_policy,
        "sample_count": len(filtered_entries),
        "file_count": file_count,
        "entries": filtered_entries,
    }


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build a Phase06 UI source corpus manifest.")
    parser.add_argument("--sample-manifest", default=str(DEFAULT_SAMPLE_MANIFEST_PATH))
    parser.add_argument("--corpus-root", default=str(DEFAULT_CORPUS_ROOT))
    parser.add_argument("--manifest-name", default=DEFAULT_MANIFEST_NAME)
    parser.add_argument("--priority", default="P0")
    parser.add_argument("--adoption-decision", default="primary")
    parser.add_argument("--source-type", default="external_repo")
    parser.add_argument(
        "--sample-bucket",
        action="append",
        dest="sample_buckets",
        choices=list(SUPPORTED_SAMPLE_BUCKETS),
        help="Sample bucket(s) to draw from. Defaults to ordered_samples.",
    )
    parser.add_argument("--role", default="")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT_PATH))
    parser.add_argument("--allow-missing-files", action="store_true")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    sample_manifest_path = Path(args.sample_manifest).resolve()
    corpus_root = Path(args.corpus_root).resolve()
    output_path = Path(args.output).resolve()
    sample_buckets = tuple(args.sample_buckets or DEFAULT_SAMPLE_BUCKETS)
    payload = build_source_corpus_payload(
        sample_manifest_payload=read_json(sample_manifest_path),
        sample_manifest_path=sample_manifest_path,
        corpus_root=corpus_root,
        manifest_name=str(args.manifest_name).strip() or DEFAULT_MANIFEST_NAME,
        priority=str(args.priority).strip() or "P0",
        adoption_decision=str(args.adoption_decision).strip() or "primary",
        source_type=str(args.source_type).strip() or "external_repo",
        sample_buckets=sample_buckets,
        output_path=output_path,
        repo_root=PROJECT_ROOT,
        role=str(args.role).strip(),
        require_existing_files=not args.allow_missing_files,
    )
    write_json(output_path, payload)
    print(output_path.as_posix())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

