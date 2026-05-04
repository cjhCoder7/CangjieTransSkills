#!/usr/bin/env python3
"""Validate the machine-readable invariants of a Phase06 UI expansion audit."""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Dict, List, Sequence

import phase06_ui_expansion_audit as expansion_audit


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REPORT_PATH = PROJECT_ROOT / "artifacts" / "ui_pilots" / "phase06_ui_regular_expansion_audit.validation.json"

EXIT_OK = 0
EXIT_VALIDATION_FAILED = 2
EXIT_TOOLING_ERROR = 22


@dataclass
class Issue:
    code: str
    severity: str
    message: str
    path: str | None = None


def read_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate Phase06 UI expansion audit invariants.")
    parser.add_argument("--audit", required=True, help="Path to a phase06_ui_expansion_audit JSON artifact")
    parser.add_argument("--report", help="Optional validation report output path")
    parser.add_argument("--require-audit-version", type=int)
    parser.add_argument("--require-final-decision", choices=list(expansion_audit.DECISION_CHOICES))
    parser.add_argument("--require-decision-scope", default=expansion_audit.DECISION_SCOPE_REGULAR_EXPANSION)
    parser.add_argument("--require-workset-scope", default=expansion_audit.DECISION_SCOPE_WORKSET)
    return parser.parse_args(argv)


def _expect_dict(value: Any, path: str, issues: List[Issue]) -> Dict[str, Any]:
    if isinstance(value, dict):
        return value
    issues.append(Issue("invalid-type", "error", f"expected object at {path}", path))
    return {}


def _expect_list(value: Any, path: str, issues: List[Issue]) -> List[Any]:
    if isinstance(value, list):
        return value
    issues.append(Issue("invalid-type", "error", f"expected list at {path}", path))
    return []


def _check_count(summary: Dict[str, Any], key: str, expected: int, path: str, issues: List[Issue]) -> None:
    actual = summary.get(key)
    if actual != expected:
        issues.append(
            Issue(
                "count-mismatch",
                "error",
                f"{path}.{key} expected {expected} but got {actual}",
                f"{path}.{key}",
            )
        )


def validate_audit(
    payload: Dict[str, Any],
    *,
    require_audit_version: int | None = None,
    require_final_decision: str | None = None,
    require_decision_scope: str = expansion_audit.DECISION_SCOPE_REGULAR_EXPANSION,
    require_workset_scope: str = expansion_audit.DECISION_SCOPE_WORKSET,
) -> Dict[str, Any]:
    issues: List[Issue] = []
    warnings: List[Issue] = []

    audit_name = str(payload.get("audit_name", "")).strip()
    audit_version = payload.get("audit_version")
    decision_scope = str(payload.get("decision_scope", "")).strip()
    final_decision = str(payload.get("final_decision", "")).strip()
    compatibility_hint = str(payload.get("next_action_hint", "")).strip()

    if audit_name != "phase06-ui-expansion-audit":
        issues.append(Issue("unexpected-audit-name", "error", f"unexpected audit_name: {audit_name}", "audit_name"))
    if require_audit_version is not None and audit_version != require_audit_version:
        issues.append(
            Issue(
                "unexpected-audit-version",
                "error",
                f"expected audit_version={require_audit_version} but got {audit_version}",
                "audit_version",
            )
        )
    if decision_scope != require_decision_scope:
        issues.append(
            Issue(
                "unexpected-decision-scope",
                "error",
                f"expected decision_scope={require_decision_scope} but got {decision_scope}",
                "decision_scope",
            )
        )
    if not final_decision:
        issues.append(Issue("missing-final-decision", "error", "final_decision must be non-empty", "final_decision"))
    if final_decision and final_decision not in expansion_audit.DECISION_CHOICES:
        issues.append(
            Issue(
                "unknown-final-decision",
                "error",
                f"final_decision is not a recognized decision: {final_decision}",
                "final_decision",
            )
        )
    if require_final_decision is not None and final_decision != require_final_decision:
        issues.append(
            Issue(
                "unexpected-final-decision",
                "error",
                f"expected final_decision={require_final_decision} but got {final_decision}",
                "final_decision",
            )
        )
    if compatibility_hint != final_decision:
        issues.append(
            Issue(
                "compatibility-hint-mismatch",
                "error",
                f"top-level next_action_hint must match final_decision (got {compatibility_hint} vs {final_decision})",
                "next_action_hint",
            )
        )

    sample_manifest = _expect_dict(payload.get("sample_manifest"), "sample_manifest", issues)
    source_corpus_summary = _expect_dict(payload.get("source_corpus_summary"), "source_corpus_summary", issues)
    file_manifest_summary = _expect_dict(payload.get("file_manifest_summary"), "file_manifest_summary", issues)
    workset_summary = _expect_dict(payload.get("workset_summary"), "workset_summary", issues)

    regular_sample_ids = _expect_list(sample_manifest.get("regular_sample_ids"), "sample_manifest.regular_sample_ids", issues)
    frozen_sample_ids = _expect_list(source_corpus_summary.get("frozen_sample_ids"), "source_corpus_summary.frozen_sample_ids", issues)
    covered_sample_ids = _expect_list(file_manifest_summary.get("covered_sample_ids"), "file_manifest_summary.covered_sample_ids", issues)
    unfrozen_regular_samples = _expect_list(payload.get("unfrozen_regular_samples"), "unfrozen_regular_samples", issues)
    missing_workset_audits = _expect_list(payload.get("missing_workset_audits"), "missing_workset_audits", issues)
    non_exhausted_worksets = _expect_list(payload.get("non_exhausted_worksets"), "non_exhausted_worksets", issues)
    workset_audit_reports = _expect_list(payload.get("workset_audit_reports"), "workset_audit_reports", issues)

    _check_count(sample_manifest, "regular_sample_count", len(regular_sample_ids), "sample_manifest", issues)
    _check_count(source_corpus_summary, "frozen_sample_count", len(frozen_sample_ids), "source_corpus_summary", issues)
    _check_count(source_corpus_summary, "unfrozen_sample_count", len(unfrozen_regular_samples), "source_corpus_summary", issues)
    _check_count(file_manifest_summary, "covered_sample_count", len(covered_sample_ids), "file_manifest_summary", issues)
    _check_count(workset_summary, "missing_workset_audit_count", len(missing_workset_audits), "workset_summary", issues)
    _check_count(workset_summary, "non_exhausted_workset_count", len(non_exhausted_worksets), "workset_summary", issues)
    _check_count(workset_summary, "audit_count", len(workset_audit_reports), "workset_summary", issues)

    for index, raw_report in enumerate(workset_audit_reports):
        path = f"workset_audit_reports[{index}]"
        report = _expect_dict(raw_report, path, issues)
        scope = str(report.get("decision_scope", "")).strip()
        workset_hint = str(report.get("workset_next_action_hint", "")).strip()
        compatibility_workset_hint = str(report.get("next_action_hint", "")).strip()
        if scope != require_workset_scope:
            issues.append(
                Issue(
                    "unexpected-workset-scope",
                    "error",
                    f"expected {path}.decision_scope={require_workset_scope} but got {scope}",
                    f"{path}.decision_scope",
                )
            )
        if not workset_hint:
            issues.append(
                Issue(
                    "missing-workset-next-action-hint",
                    "error",
                    f"{path}.workset_next_action_hint must be non-empty",
                    f"{path}.workset_next_action_hint",
                )
            )
        if compatibility_workset_hint != workset_hint:
            issues.append(
                Issue(
                    "workset-hint-mismatch",
                    "error",
                    f"{path}.next_action_hint must match workset_next_action_hint",
                    f"{path}.next_action_hint",
                )
            )
        exhausted_workset = report.get("exhausted_workset")
        missing_slice_count = report.get("missing_slice_count")
        if exhausted_workset is True and missing_slice_count not in (0, 0.0):
            issues.append(
                Issue(
                    "exhausted-workset-with-missing-slices",
                    "error",
                    f"{path} marked exhausted but missing_slice_count={missing_slice_count}",
                    f"{path}.missing_slice_count",
                )
            )
        if exhausted_workset is False and missing_slice_count in (0, 0.0):
            warnings.append(
                Issue(
                    "non-exhausted-workset-with-zero-missing-slices",
                    "warning",
                    f"{path} marked non-exhausted but missing_slice_count={missing_slice_count}",
                    f"{path}.missing_slice_count",
                )
            )

    exit_code = EXIT_OK if not issues else EXIT_VALIDATION_FAILED
    validation_class = "valid-expansion-audit" if not issues else "invalid-expansion-audit"
    return {
        "audit_name": audit_name,
        "audit_version": audit_version,
        "decision_scope": decision_scope,
        "final_decision": final_decision,
        "compatibility_next_action_hint": compatibility_hint,
        "issue_count": len(issues),
        "warning_count": len(warnings),
        "validation_class": validation_class,
        "exit_code": exit_code,
        "issues": [asdict(item) for item in issues],
        "warnings": [asdict(item) for item in warnings],
    }


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    audit_path = Path(args.audit).resolve()
    payload = read_json(audit_path)
    report = validate_audit(
        payload,
        require_audit_version=args.require_audit_version,
        require_final_decision=args.require_final_decision,
        require_decision_scope=args.require_decision_scope,
        require_workset_scope=args.require_workset_scope,
    )
    report["audit_path"] = audit_path.as_posix()

    report_path = Path(args.report).resolve() if args.report else None
    if report_path is not None:
        write_json(report_path, report)
        print(report_path.as_posix())
    else:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    return int(report["exit_code"])


if __name__ == "__main__":
    raise SystemExit(main())
