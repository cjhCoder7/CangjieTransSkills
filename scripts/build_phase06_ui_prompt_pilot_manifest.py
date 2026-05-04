#!/usr/bin/env python3
"""Build deterministic Phase06 UI prompt-pilot manifests from the file-level workset."""

from __future__ import annotations

import argparse
import json
import shlex
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Tuple


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_FILE_MANIFEST_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json"
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_prompt_pilot_batch1.json"
DEFAULT_ARTIFACTS_ROOT = PROJECT_ROOT / "artifacts" / "ui_pilots" / "20260408-phase06-ui-pilot-batch1"
DEFAULT_ARCHITECTURE_SKILL_PATH = (
    PROJECT_ROOT / "docs" / "strategy" / "phase-06-ui-sample-taxonomy-and-prompt-constraints.md"
)
DEFAULT_MANIFEST_NAME = "phase06_ui_prompt_pilot_batch1"
DEFAULT_SELECTION_MODE = "required-tracks"
DEFAULT_TRACK_PROFILE = "p0-batch1"


TRACK_PROFILES: Dict[str, List[Dict[str, Any]]] = {
    "p0-batch1": [
        {
            "track_id": "page-shell-view-model-renderer",
            "target_role": "page",
            "structure_tag": "page-shell",
            "ownership_tag": "view-model-renderer",
            "required_interaction_tags": [],
            "forbidden_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Direct page-shell seed for nested composition and @State/@Link propagation before branching into component-only lanes.",
            "pilot_goal": "Establish the first prompt-dump anchor for page-shell + view-model-renderer UI targets.",
        },
        {
            "track_id": "rich-component-view-model-renderer",
            "target_role": "component",
            "structure_tag": "rich-component",
            "ownership_tag": "view-model-renderer",
            "required_interaction_tags": [],
            "forbidden_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Pairs a reusable component slice with the page-shell lane without dragging in gesture or mixed-app variance.",
            "pilot_goal": "Cover reusable rich-component translation under the same ownership model as the first page-shell anchor.",
        },
        {
            "track_id": "page-shell-controller-owned-state",
            "target_role": "page",
            "structure_tag": "page-shell",
            "ownership_tag": "controller-owned-state",
            "required_interaction_tags": [],
            "forbidden_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Host-page anchor for controller-owned state is needed before we try mixed-app or gesture-heavy pages.",
            "pilot_goal": "Introduce page-shell + controller-owned-state coverage with the lowest extra variance.",
        },
        {
            "track_id": "rich-component-controller-owned-state",
            "target_role": "component",
            "structure_tag": "rich-component",
            "ownership_tag": "controller-owned-state",
            "required_interaction_tags": [],
            "forbidden_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Primary rich-component/controller-owned-state anchor should stay non-gesture for the first controlled comparison against the host-page lane.",
            "pilot_goal": "Cover the main controller-owned rich-component lane before adding gesture complexity.",
        },
        {
            "track_id": "gesture-rich-component-controller-owned-state",
            "target_role": "component",
            "structure_tag": "rich-component",
            "ownership_tag": "controller-owned-state",
            "required_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Gesture-heavy component is the most distinct Phase06 lane and needs a dedicated prompt-dump pilot instead of being inferred from non-gesture samples.",
            "pilot_goal": "Add gesture-component evidence on top of the base rich-component/controller-owned-state lane.",
        },
    ],
    "p1-batch1": [
        {
            "track_id": "page-shell-view-model-renderer",
            "target_role": "page",
            "structure_tag": "page-shell",
            "ownership_tag": "view-model-renderer",
            "required_interaction_tags": [],
            "forbidden_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Keep the first P1 page-shell anchor on a renderer-backed but still self-contained entry page before widening into mixed-app flows.",
            "pilot_goal": "Establish the first P1 page-shell + view-model-renderer prompt-dump anchor.",
        },
        {
            "track_id": "rich-component-view-model-renderer",
            "target_role": "component",
            "structure_tag": "rich-component",
            "ownership_tag": "view-model-renderer",
            "required_interaction_tags": [],
            "forbidden_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Use the primary renderer/component slice as the first reusable P1 component lane instead of starting with the narrower title-bar sample.",
            "pilot_goal": "Cover renderer-driven rich-component translation under a view-model-renderer ownership model.",
        },
        {
            "track_id": "page-shell-controller-owned-state",
            "target_role": "page",
            "structure_tag": "page-shell",
            "ownership_tag": "controller-owned-state",
            "required_interaction_tags": [],
            "forbidden_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Anchor controller-owned host-page behavior on the editor sample before adding integrated client variance.",
            "pilot_goal": "Introduce non-mixed controller-owned page-shell behavior for P1 prompt pilots.",
        },
        {
            "track_id": "rich-component-controller-owned-state",
            "target_role": "component",
            "structure_tag": "rich-component",
            "ownership_tag": "controller-owned-state",
            "required_interaction_tags": [],
            "forbidden_interaction_tags": ["gesture-component"],
            "forbidden_sample_scope_tags": ["mixed-app-pattern"],
            "selection_reason": "Use the large editor component as the main controller-owned rich-component anchor before batching secondary support files.",
            "pilot_goal": "Cover primary controller-owned rich-component behavior for P1.",
        },
        {
            "track_id": "mixed-app-page-shell-controller-owned-state",
            "target_role": "page",
            "structure_tag": "page-shell",
            "ownership_tag": "controller-owned-state",
            "required_interaction_tags": [],
            "required_sample_scope_tags": ["mixed-app-pattern"],
            "forbidden_interaction_tags": ["gesture-component"],
            "selection_reason": "P1 introduces integrated client variance, so batch1 needs a dedicated mixed-app page-shell lane instead of inheriting the P0 gesture slot.",
            "pilot_goal": "Add list/detail/router plus HTTP-backed page-shell evidence to the first P1 prompt-pilot batch.",
        },
    ],
}


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


def get_track_specs(track_profile: str) -> List[Dict[str, Any]]:
    profile = track_profile.strip() or DEFAULT_TRACK_PROFILE
    if profile not in TRACK_PROFILES:
        raise ValueError(f"Unsupported track_profile: {profile}")
    return TRACK_PROFILES[profile]


def path_to_repo_local(path: Path) -> str:
    return path.relative_to(PROJECT_ROOT).as_posix()


def infer_src_root_and_target_file(repo_local_path: str) -> Tuple[str, str]:
    normalized = repo_local_path.replace("\\", "/")
    markers = [
        "/src/main/cangjie/src/",
        "/src/main/cangjie/",
        "/src/",
    ]
    for marker in markers:
        if marker not in normalized:
            continue
        head, tail = normalized.split(marker, 1)
        src_root = f"{head}{marker.rstrip('/')}"
        target_file = tail.lstrip("/")
        if target_file:
            return src_root, target_file
    raise ValueError(f"Unable to infer src_root from repo_local_path: {repo_local_path}")


def entry_matches_track(entry: Dict[str, Any], track: Dict[str, Any]) -> bool:
    if str(entry.get("target_role", "")).strip() != str(track.get("target_role", "")).strip():
        return False
    if str(entry.get("structure_tag", "")).strip() != str(track.get("structure_tag", "")).strip():
        return False
    if str(entry.get("ownership_tag", "")).strip() != str(track.get("ownership_tag", "")).strip():
        return False

    interaction_tags = set(normalize_tag_list(entry.get("interaction_tags")))
    sample_scope_tags = set(normalize_tag_list(entry.get("sample_scope_tags")))
    required_interactions = set(normalize_tag_list(track.get("required_interaction_tags")))
    required_sample_scope = set(normalize_tag_list(track.get("required_sample_scope_tags")))
    forbidden_interactions = set(normalize_tag_list(track.get("forbidden_interaction_tags")))
    forbidden_sample_scope = set(normalize_tag_list(track.get("forbidden_sample_scope_tags")))

    if not required_interactions.issubset(interaction_tags):
        return False
    if not required_sample_scope.issubset(sample_scope_tags):
        return False
    if forbidden_interactions.intersection(interaction_tags):
        return False
    if forbidden_sample_scope.intersection(sample_scope_tags):
        return False
    return True


def sort_manifest_entries(entries: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    return sorted(
        entries,
        key=lambda item: (
            int(item.get("selection_rank", 10_000) or 10_000),
            int(item.get("sample_rank", 10_000) or 10_000),
            str(item.get("slice_id", "")),
        ),
    )


def choose_track_entry(entries: List[Dict[str, Any]], track: Dict[str, Any], used_slice_ids: set[str]) -> Dict[str, Any]:
    candidates = [entry for entry in entries if entry.get("slice_id") not in used_slice_ids and entry_matches_track(entry, track)]
    if not candidates:
        raise ValueError(f"No file-manifest candidate matched required track: {track['track_id']}")
    return sort_manifest_entries(candidates)[0]


def extract_slice_ids_from_manifest(payload: Dict[str, Any]) -> List[str]:
    slice_ids: List[str] = []
    seen = set()

    summary = payload.get("summary", {})
    if isinstance(summary, dict):
        raw_selected = summary.get("selected_slice_ids", [])
        if isinstance(raw_selected, list):
            for item in raw_selected:
                value = str(item).strip()
                if value and value not in seen:
                    seen.add(value)
                    slice_ids.append(value)

    for key in ("entries", "pilots"):
        raw_entries = payload.get(key, [])
        if not isinstance(raw_entries, list):
            continue
        for item in raw_entries:
            if not isinstance(item, dict):
                continue
            value = str(item.get("slice_id", "")).strip()
            if value and value not in seen:
                seen.add(value)
                slice_ids.append(value)

    return slice_ids


def normalize_manifest_name(manifest_name: str) -> str:
    value = manifest_name.strip() or DEFAULT_MANIFEST_NAME
    return value


def manifest_name_to_slug(manifest_name: str) -> str:
    return normalize_manifest_name(manifest_name).replace("_", "-")


def manifest_slug_to_pilot_id_prefix(manifest_slug: str) -> str:
    if manifest_slug.startswith("phase06-ui-prompt-pilot-"):
        return manifest_slug.replace("phase06-ui-prompt-pilot-", "phase06-ui-pilot-", 1)
    return manifest_slug


def manifest_slug_to_snapshot_prefix(manifest_slug: str) -> str:
    if manifest_slug.startswith("phase06-ui-prompt-pilot-"):
        return manifest_slug.replace("phase06-ui-prompt-pilot-", "phase06-ui-", 1)
    return manifest_slug


def build_residual_track_id(entry: Dict[str, Any]) -> str:
    parts: List[str] = ["residual"]
    parts.extend(normalize_tag_list(entry.get("sample_scope_tags")))
    parts.extend(normalize_tag_list(entry.get("interaction_tags")))
    for field in ("structure_tag", "ownership_tag", "target_role"):
        value = str(entry.get(field, "")).strip()
        if value:
            parts.append(value)
    return "-".join(part.replace("_", "-") for part in parts)


def build_pipeline_command(entry: Dict[str, Any]) -> str:
    argv = [
        "python3",
        "scripts/pipeline_runner.py",
        "--src-root",
        str(entry["src_root"]),
        "--target-file",
        str(entry["target_file"]),
        "--run-root",
        str(entry["pipeline_run_root"]),
        "--db-path",
        str(entry["db_path"]),
        "--repo-map-path",
        str(entry["repo_map_path"]),
        "--tu-json-path",
        str(entry["base_tu_json_path"]),
        "--orchestration-output-path",
        str(entry["orchestration_output_path"]),
        "--summary-path",
        str(entry["pipeline_summary_path"]),
        "--failure-path",
        str(entry["failure_path"]),
        "--prompt-dump-path",
        str(entry["base_prompt_dump_path"]),
        "--architecture-skill",
        "docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md",
        "--snapshot-label",
        str(entry["snapshot_label"]),
        "--dump-prompt-only",
        "--extensions",
        ".cj",
        "--pattern-limit",
        "0",
    ]
    return shlex.join(argv)


def build_pilot_entry(
    *,
    source_entry: Dict[str, Any],
    pilot_order: int,
    track_id: str,
    selection_reason: str,
    pilot_goal: str,
    artifacts_root: Path,
    manifest_slug: str,
) -> Dict[str, Any]:
    src_root, target_file = infer_src_root_and_target_file(str(source_entry["repo_local_path"]))
    artifact_root = artifacts_root / str(source_entry["slice_id"])
    pipeline_run_root = artifact_root / "pipeline_run"
    pilot_id_prefix = manifest_slug_to_pilot_id_prefix(manifest_slug)
    snapshot_prefix = manifest_slug_to_snapshot_prefix(manifest_slug)

    pilot_entry: Dict[str, Any] = {
        "pilot_id": f"{pilot_id_prefix}-{source_entry['slice_id']}",
        "pilot_order": pilot_order,
        "track_id": track_id,
        "slice_id": source_entry["slice_id"],
        "sample_id": source_entry["sample_id"],
        "repo_name": source_entry.get("repo_name", ""),
        "repo_local_path": source_entry["repo_local_path"],
        "source_path": source_entry.get("source_path", ""),
        "priority": source_entry.get("priority", ""),
        "selection_rank": source_entry.get("selection_rank", pilot_order),
        "sample_rank": source_entry.get("sample_rank", 1),
        "target_role": source_entry["target_role"],
        "slice_kind": source_entry["slice_kind"],
        "structure_tag": source_entry["structure_tag"],
        "ownership_tag": source_entry["ownership_tag"],
        "interaction_tags": normalize_tag_list(source_entry.get("interaction_tags")),
        "exception_tags": normalize_tag_list(source_entry.get("exception_tags")),
        "sample_scope_tags": normalize_tag_list(source_entry.get("sample_scope_tags")),
        "ui_prompt_tags": dict(source_entry.get("ui_prompt_tags", {})),
        "usage_goal": source_entry.get("usage_goal", ""),
        "selection_reason": selection_reason,
        "pilot_goal": pilot_goal,
        "recommended_few_shot_entry_ids": list(source_entry.get("recommended_few_shot_entry_ids", [])),
        "source_scan": dict(source_entry.get("source_scan", {})),
        "notes": list(source_entry.get("notes", [])),
        "src_root": src_root,
        "target_file": target_file,
        "artifact_root": path_to_repo_local(artifact_root),
        "pipeline_run_root": path_to_repo_local(pipeline_run_root),
        "db_path": path_to_repo_local(pipeline_run_root / "repo_index.sqlite"),
        "repo_map_path": path_to_repo_local(pipeline_run_root / "repo_map.txt"),
        "base_tu_json_path": path_to_repo_local(pipeline_run_root / "target.tu.json"),
        "explicit_tu_json_path": path_to_repo_local(artifact_root / "target.explicit_ui_tags.tu.json"),
        "orchestration_output_path": path_to_repo_local(pipeline_run_root / "target.orchestration.json"),
        "pipeline_summary_path": path_to_repo_local(pipeline_run_root / "summary.json"),
        "failure_path": path_to_repo_local(pipeline_run_root / "failure.json"),
        "pipeline_log_path": path_to_repo_local(artifact_root / "pipeline.log"),
        "base_prompt_dump_path": path_to_repo_local(artifact_root / "prompt_dump.txt"),
        "explicit_prompt_dump_path": path_to_repo_local(artifact_root / "prompt_dump.explicit_ui_tags.txt"),
        "prompt_dump_summary_path": path_to_repo_local(artifact_root / "pilot-summary.json"),
        "snapshot_label": f"{snapshot_prefix}-{source_entry['slice_id']}",
        "expected_prompt_signal": "resolution_source=explicit-target-ui-tags",
    }
    pilot_entry["pipeline_command"] = build_pipeline_command(pilot_entry)
    return pilot_entry


def build_prompt_pilot_manifest(
    *,
    file_manifest_payload: Dict[str, Any],
    artifacts_root: Path,
    file_manifest_path: Path = DEFAULT_FILE_MANIFEST_PATH,
    architecture_skill_path: Path = DEFAULT_ARCHITECTURE_SKILL_PATH,
    manifest_name: str = DEFAULT_MANIFEST_NAME,
    selection_mode: str = DEFAULT_SELECTION_MODE,
    track_profile: str = DEFAULT_TRACK_PROFILE,
    exclude_slice_ids: List[str] | None = None,
    exclude_manifest_payload: Dict[str, Any] | None = None,
) -> Dict[str, Any]:
    raw_entries = file_manifest_payload.get("entries", [])
    if not isinstance(raw_entries, list) or not raw_entries:
        raise ValueError("Phase06 UI file manifest does not contain usable entries[]")

    entries = [item for item in raw_entries if isinstance(item, dict)]
    normalized_manifest_name = normalize_manifest_name(manifest_name)
    manifest_slug = manifest_name_to_slug(normalized_manifest_name)
    normalized_track_profile = track_profile.strip() or DEFAULT_TRACK_PROFILE
    track_specs = get_track_specs(normalized_track_profile) if selection_mode == "required-tracks" else []
    excluded_slice_ids = []
    seen_excluded = set()
    for item in exclude_slice_ids or []:
        value = str(item).strip()
        if value and value not in seen_excluded:
            seen_excluded.add(value)
            excluded_slice_ids.append(value)
    if exclude_manifest_payload:
        for item in extract_slice_ids_from_manifest(exclude_manifest_payload):
            if item not in seen_excluded:
                seen_excluded.add(item)
                excluded_slice_ids.append(item)

    pilot_entries: List[Dict[str, Any]] = []
    selection_policy_mode = "one deterministic slice per required prompt lane"
    selection_policy_notes = [
        "Each selected slice carries repo-local pipeline paths so prompt dumps can be regenerated without hand assembly.",
        "Explicit ui_prompt_tags injection is still required for the final pilot prompt dump.",
    ]

    if selection_mode == "required-tracks":
        used_slice_ids: set[str] = set(excluded_slice_ids)
        selection_policy_notes.insert(0, "Batch1 is a prompt-pilot workset, not a full translation batch.")
        selection_policy_notes.insert(1, f"Track profile `{normalized_track_profile}` defines which required lanes must be covered.")
        for order, track in enumerate(track_specs, start=1):
            source_entry = choose_track_entry(entries, track, used_slice_ids)
            used_slice_ids.add(str(source_entry["slice_id"]))
            pilot_entries.append(
                build_pilot_entry(
                    source_entry=source_entry,
                    pilot_order=order,
                    track_id=track["track_id"],
                    selection_reason=track["selection_reason"],
                    pilot_goal=track["pilot_goal"],
                    artifacts_root=artifacts_root,
                    manifest_slug=manifest_slug,
                )
            )
    elif selection_mode == "residual-workset":
        selection_policy_mode = "residual-workset-after-excluding-consumed-slices"
        selection_policy_notes.insert(
            0,
            "Residual mode keeps every remaining slice after excluding an already-consumed pilot workset; it does not require full five-lane symmetry.",
        )
        residual_entries = [entry for entry in sort_manifest_entries(entries) if str(entry.get("slice_id", "")) not in seen_excluded]
        for order, source_entry in enumerate(residual_entries, start=1):
            pilot_entries.append(
                build_pilot_entry(
                    source_entry=source_entry,
                    pilot_order=order,
                    track_id=build_residual_track_id(source_entry),
                    selection_reason="Residual next-stage slice left after excluding already-curated prompt-pilot worksets.",
                    pilot_goal="Carry remaining Phase06 lane variance into the next prompt-pilot batch without hand-assembling repo-local pipeline paths.",
                    artifacts_root=artifacts_root,
                    manifest_slug=manifest_slug,
                )
            )
    else:
        raise ValueError(f"Unsupported selection_mode: {selection_mode}")

    role_counts = Counter(str(entry["target_role"]) for entry in pilot_entries)
    track_counts = Counter(str(entry["track_id"]) for entry in pilot_entries)
    unique_sample_ids = {str(entry["sample_id"]) for entry in pilot_entries}
    coverage = {
        "structure_tags": sorted({str(entry["structure_tag"]) for entry in pilot_entries}),
        "ownership_tags": sorted({str(entry["ownership_tag"]) for entry in pilot_entries}),
        "interaction_tags": sorted(
            {
                tag
                for entry in pilot_entries
                for tag in normalize_tag_list(entry.get("interaction_tags"))
            }
        ),
    }

    return {
        "manifest_name": normalized_manifest_name,
        "manifest_version": 1,
        "created_at": utc_now(),
        "phase": "phase06",
        "status": "active",
        "source_manifest": path_to_repo_local(file_manifest_path),
        "intended_consumer": "Phase06 prompt-pilot curator and prompt-dump runner",
        "selection_policy": {
            "batch_id": manifest_slug,
            "selection_mode": selection_policy_mode,
            "track_profile": normalized_track_profile,
            "required_tracks": [
                {
                    "track_id": track["track_id"],
                    "target_role": track["target_role"],
                    "structure_tag": track["structure_tag"],
                    "ownership_tag": track["ownership_tag"],
                    "required_interaction_tags": normalize_tag_list(track.get("required_interaction_tags")),
                    "required_sample_scope_tags": normalize_tag_list(track.get("required_sample_scope_tags")),
                    "forbidden_interaction_tags": normalize_tag_list(track.get("forbidden_interaction_tags")),
                    "forbidden_sample_scope_tags": normalize_tag_list(track.get("forbidden_sample_scope_tags")),
                }
                for track in track_specs
            ]
            if selection_mode == "required-tracks"
            else [],
            "artifact_root": path_to_repo_local(artifacts_root),
            "architecture_skill_path": path_to_repo_local(architecture_skill_path),
            "notes": selection_policy_notes,
            "excluded_slice_ids": excluded_slice_ids,
        },
        "summary": {
            "pilot_count": len(pilot_entries),
            "source_sample_count": len(unique_sample_ids),
            "role_counts": dict(role_counts),
            "track_counts": dict(track_counts),
            "coverage": coverage,
            "selected_slice_ids": [entry["slice_id"] for entry in pilot_entries],
            "excluded_slice_count": len(excluded_slice_ids),
        },
        "entries": pilot_entries,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build deterministic Phase06 UI prompt-pilot manifests.")
    parser.add_argument(
        "--file-manifest",
        default=str(DEFAULT_FILE_MANIFEST_PATH),
        help="Path to docs/manifests/phase06_ui_*_file_manifest.json",
    )
    parser.add_argument(
        "--artifacts-root",
        default=str(DEFAULT_ARTIFACTS_ROOT),
        help="Artifact root used to precompute pilot prompt-dump paths",
    )
    parser.add_argument(
        "--output",
        default=str(DEFAULT_OUTPUT_PATH),
        help="Output JSON path",
    )
    parser.add_argument(
        "--manifest-name",
        default=DEFAULT_MANIFEST_NAME,
        help="Manifest name written into the output payload",
    )
    parser.add_argument(
        "--selection-mode",
        choices=["required-tracks", "residual-workset"],
        default=DEFAULT_SELECTION_MODE,
        help="Whether to build the batch1 five-lane pilot set or a residual next-stage workset",
    )
    parser.add_argument(
        "--track-profile",
        choices=sorted(TRACK_PROFILES),
        default=DEFAULT_TRACK_PROFILE,
        help="Required-track profile used when selection-mode=required-tracks",
    )
    parser.add_argument(
        "--exclude-manifest",
        default="",
        help="Optional prior manifest whose slice_id entries should be excluded from selection",
    )
    parser.add_argument(
        "--exclude-slice-id",
        action="append",
        default=[],
        help="Repeatable slice_id exclusion applied before selection",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    file_manifest_path = Path(args.file_manifest).resolve()
    artifacts_root = Path(args.artifacts_root).resolve()
    output_path = Path(args.output).resolve()
    exclude_manifest_payload = None
    exclude_manifest_path = str(args.exclude_manifest).strip()
    if exclude_manifest_path:
        exclude_manifest_payload = read_json(Path(exclude_manifest_path).resolve())

    manifest = build_prompt_pilot_manifest(
        file_manifest_payload=read_json(file_manifest_path),
        artifacts_root=artifacts_root,
        file_manifest_path=file_manifest_path,
        manifest_name=str(args.manifest_name),
        selection_mode=str(args.selection_mode),
        track_profile=str(args.track_profile),
        exclude_slice_ids=[str(item) for item in args.exclude_slice_id],
        exclude_manifest_payload=exclude_manifest_payload,
    )
    write_json(output_path, manifest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
