#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator, FormatChecker

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SCHEMA_PATH = PROJECT_ROOT / "docs/schemas/full-pass-summary-schema.json"
ASSERTION_ID_PATTERN = re.compile(r"\b(?:BCM|SMOKE)-[A-Z]+-\d{3}\b")

EXIT_OK = 0
EXIT_VALID_NONPASS = 10
EXIT_EVIDENCE_SCHEMA_INVALID = 20
EXIT_EVIDENCE_SEMANTIC_INVALID = 21
EXIT_TOOLING_ERROR = 22


@dataclass
class Issue:
    code: str
    severity: str
    message: str
    path: str | None = None


@dataclass
class ValidationReport:
    summary_path: str
    schema_path: str
    label: str | None
    overall_status: str | None
    schema_valid: bool
    semantic_valid: bool
    validation_class: str
    exit_code: int
    status_counts: dict[str, int]
    nonpassed_assertions: list[dict[str, Any]]
    declared_assertion_ids: list[str]
    extracted_assertion_ids: list[str]
    parsed_event_assertion_ids: list[str]
    raw_log_assertion_ids: list[str]
    raw_log_path: str | None
    raw_log_exists: bool
    semantic_extractors: dict[str, Any]
    issues: list[dict[str, Any]]
    warnings: list[dict[str, Any]]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="校验 Phase 3C Full Pass summary.json，并提取 BCM 断言语义。"
    )
    parser.add_argument("--summary", required=True, help="待校验的 Full Pass summary.json 路径")
    parser.add_argument(
        "--schema",
        default=str(DEFAULT_SCHEMA_PATH),
        help="JSON Schema 路径，默认 docs/schemas/full-pass-summary-schema.json",
    )
    parser.add_argument("--report", help="可选的校验报告输出路径")
    return parser.parse_args()


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def normalize_path(error_path: Any) -> str:
    parts = [str(item) for item in error_path]
    return ".".join(parts) if parts else "<root>"


def resolve_artifact_path(raw_path: str, summary_path: Path) -> Path:
    candidate = Path(raw_path)
    if candidate.is_absolute():
        return candidate

    summary_relative = (summary_path.parent / candidate).resolve()
    if summary_relative.exists():
        return summary_relative

    project_relative = (PROJECT_ROOT / candidate).resolve()
    return project_relative


def extract_assertion_ids(text: str) -> list[str]:
    return ASSERTION_ID_PATTERN.findall(text)


def summarize_statuses(assertions: list[dict[str, Any]]) -> dict[str, int]:
    counter = Counter(item.get("status", "<missing>") for item in assertions)
    return dict(sorted(counter.items()))


def collect_nonpassed_assertions(assertions: list[dict[str, Any]]) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for item in assertions:
        status = str(item.get("status", ""))
        if status == "passed":
            continue
        rows.append({
            "assertion_id": str(item.get("assertion_id", "")),
            "status": status,
            "failure_reason": item.get("failure_reason"),
        })
    return rows


def validate_against_schema(summary: Any, schema: Any) -> list[Issue]:
    validator = Draft202012Validator(schema, format_checker=FormatChecker())
    issues: list[Issue] = []
    for error in sorted(validator.iter_errors(summary), key=lambda item: list(item.path)):
        issues.append(
            Issue(
                code="schema-error",
                severity="error",
                message=error.message,
                path=normalize_path(error.path),
            )
        )
    return issues


def validate_semantics(summary: dict[str, Any], summary_path: Path) -> tuple[list[Issue], list[Issue], dict[str, Any]]:
    issues: list[Issue] = []
    warnings: list[Issue] = []

    assertions = summary.get("assertions", [])
    runtime = summary.get("runtime_log_capture", {})
    parsed_events = runtime.get("parsed_events", [])

    declared_ids = [item["assertion_id"] for item in assertions]
    duplicate_ids = sorted({item for item, count in Counter(declared_ids).items() if count > 1})
    for assertion_id in duplicate_ids:
        issues.append(
            Issue(
                code="duplicate-assertion-id",
                severity="error",
                message=f"assertions 中存在重复 assertion_id：{assertion_id}",
                path="assertions",
            )
        )

    declared_set = set(declared_ids)
    parsed_event_refs: set[str] = set()
    parsed_message_refs: set[str] = set()
    parsed_event_map: dict[str, list[str]] = defaultdict(list)
    raw_log_map: dict[str, list[str]] = defaultdict(list)

    refresh_events_on_main = 0
    worker_fetch_events = 0
    worker_send_events = 0

    for index, event in enumerate(parsed_events, start=1):
        event_name = str(event.get("event_name", ""))
        message = str(event.get("message", ""))
        thread_context = str(event.get("thread_context", "unknown"))
        event_ref = f"parsed_events[{index}]:{event_name or '<missing-event>'}"

        for assertion_id in event.get("assertion_refs", []):
            parsed_event_refs.add(assertion_id)
            parsed_event_map[assertion_id].append(event_ref)

        for assertion_id in extract_assertion_ids(message):
            parsed_message_refs.add(assertion_id)
            parsed_event_map[assertion_id].append(f"{event_ref}#message")

        event_name_upper = event_name.upper()
        if thread_context == "main" and "REFRESH" in event_name_upper:
            refresh_events_on_main += 1
        if thread_context == "worker" and "FETCH" in event_name_upper:
            worker_fetch_events += 1
        if thread_context == "worker" and "SEND" in event_name_upper:
            worker_send_events += 1

    raw_log_exists = False
    raw_log_path_value = runtime.get("raw_log_path")
    resolved_raw_log_path: Path | None = None
    if isinstance(raw_log_path_value, str) and raw_log_path_value:
        resolved_raw_log_path = resolve_artifact_path(raw_log_path_value, summary_path)
        raw_log_exists = resolved_raw_log_path.exists()
        if not raw_log_exists:
            issues.append(
                Issue(
                    code="missing-raw-log",
                    severity="error",
                    message=f"raw_log_path 指向的文件不存在：{raw_log_path_value}",
                    path="runtime_log_capture.raw_log_path",
                )
            )
        else:
            for line_number, line in enumerate(
                resolved_raw_log_path.read_text(encoding="utf-8", errors="replace").splitlines(),
                start=1,
            ):
                for assertion_id in extract_assertion_ids(line):
                    raw_log_map[assertion_id].append(f"raw_log:{line_number}")

    extracted_ids = set(parsed_event_refs) | set(parsed_message_refs) | set(raw_log_map)

    undeclared_event_refs = sorted(parsed_event_refs - declared_set)
    for assertion_id in undeclared_event_refs:
        issues.append(
            Issue(
                code="undeclared-event-assertion-ref",
                severity="error",
                message=f"parsed_events 中引用了未在 assertions 声明的 assertion_id：{assertion_id}",
                path="runtime_log_capture.parsed_events",
            )
        )

    undeclared_message_refs = sorted(parsed_message_refs - declared_set)
    for assertion_id in undeclared_message_refs:
        warnings.append(
            Issue(
                code="undeclared-message-assertion-ref",
                severity="warning",
                message=f"parsed_events.message 中提取到未声明 assertion_id：{assertion_id}",
                path="runtime_log_capture.parsed_events",
            )
        )

    undeclared_raw_log_refs = sorted(set(raw_log_map) - declared_set)
    for assertion_id in undeclared_raw_log_refs:
        warnings.append(
            Issue(
                code="undeclared-raw-log-assertion-ref",
                severity="warning",
                message=f"raw_log 中出现了未在 assertions 声明的 assertion_id：{assertion_id}",
                path="runtime_log_capture.raw_log_path",
            )
        )

    for index, assertion in enumerate(assertions, start=1):
        assertion_id = assertion["assertion_id"]
        status = assertion["status"]
        evidence = assertion["evidence"]
        failure_reason = assertion.get("failure_reason")
        issue_path = f"assertions[{index}]"

        matched_event_names = evidence.get("matched_event_names", [])
        matched_thread_ids = evidence.get("matched_thread_ids", [])
        raw_log_refs = evidence.get("raw_log_refs", [])
        has_evidence = bool(matched_event_names or matched_thread_ids or raw_log_refs)

        if status == "passed" and not has_evidence:
            issues.append(
                Issue(
                    code="passed-without-evidence",
                    severity="error",
                    message=f"通过态 assertion 缺少证据载荷：{assertion_id}",
                    path=issue_path,
                )
            )
        if status == "passed" and failure_reason not in (None, ""):
            issues.append(
                Issue(
                    code="passed-with-failure-reason",
                    severity="error",
                    message=f"通过态 assertion 不应携带 failure_reason：{assertion_id}",
                    path=issue_path,
                )
            )
        if status != "passed" and status != "skipped":
            if not isinstance(failure_reason, str) or not failure_reason.strip():
                issues.append(
                    Issue(
                        code="nonpassed-without-failure-reason",
                        severity="error",
                        message=f"非通过态 assertion 缺少可读 failure_reason：{assertion_id}",
                        path=issue_path,
                    )
                )
        if status == "passed" and assertion_id not in extracted_ids and not raw_log_refs:
            issues.append(
                Issue(
                    code="passed-assertion-not-extracted",
                    severity="error",
                    message=f"未从 parsed_events / raw_log 中提取到通过态 assertion：{assertion_id}",
                    path=issue_path,
                )
            )

    main_thread_refresh_seen = runtime.get("main_thread_refresh_seen")
    worker_fetch_seen = runtime.get("worker_fetch_seen")
    worker_send_seen = runtime.get("worker_send_seen")
    refresh_delivery_context = runtime.get("refresh_delivery_context")

    if main_thread_refresh_seen and refresh_delivery_context != "main":
        issues.append(
            Issue(
                code="refresh-context-mismatch",
                severity="error",
                message="main_thread_refresh_seen=true 时，refresh_delivery_context 必须为 main",
                path="runtime_log_capture.refresh_delivery_context",
            )
        )
    if main_thread_refresh_seen and refresh_events_on_main == 0:
        issues.append(
            Issue(
                code="missing-main-refresh-event",
                severity="error",
                message="summary 声称看到了主线程刷新，但 parsed_events 中没有 main + REFRESH 事件",
                path="runtime_log_capture.parsed_events",
            )
        )
    if worker_fetch_seen and worker_fetch_events == 0:
        issues.append(
            Issue(
                code="missing-worker-fetch-event",
                severity="error",
                message="summary 声称看到了 worker fetch，但 parsed_events 中没有 worker + FETCH 事件",
                path="runtime_log_capture.parsed_events",
            )
        )
    if worker_send_seen and worker_send_events == 0:
        issues.append(
            Issue(
                code="missing-worker-send-event",
                severity="error",
                message="summary 声称看到了 worker send，但 parsed_events 中没有 worker + SEND 事件",
                path="runtime_log_capture.parsed_events",
            )
        )

    semantics = {
        "declared_assertion_ids": sorted(declared_set),
        "parsed_event_assertion_ids": sorted(parsed_event_refs),
        "parsed_message_assertion_ids": sorted(parsed_message_refs),
        "raw_log_assertion_ids": sorted(raw_log_map),
        "extracted_assertion_ids": sorted(extracted_ids),
        "parsed_event_map": {key: value for key, value in sorted(parsed_event_map.items())},
        "raw_log_map": {key: value for key, value in sorted(raw_log_map.items())},
        "runtime_flag_checks": {
            "refresh_events_on_main": refresh_events_on_main,
            "worker_fetch_events": worker_fetch_events,
            "worker_send_events": worker_send_events,
        },
        "resolved_raw_log_path": str(resolved_raw_log_path) if resolved_raw_log_path else None,
        "raw_log_exists": raw_log_exists,
    }
    return issues, warnings, semantics


def classify_exit_code(schema_issues: list[Issue], semantic_issues: list[Issue], overall_status: str | None) -> tuple[int, str]:
    if schema_issues:
        return EXIT_EVIDENCE_SCHEMA_INVALID, "invalid-evidence-schema"
    if semantic_issues:
        return EXIT_EVIDENCE_SEMANTIC_INVALID, "invalid-evidence-semantics"
    if overall_status != "passed":
        return EXIT_VALID_NONPASS, "valid-evidence-nonpass"
    return EXIT_OK, "valid-evidence-pass"


def print_report(report: ValidationReport) -> None:
    header = {
        EXIT_OK: "PASS",
        EXIT_VALID_NONPASS: "NONPASS",
        EXIT_EVIDENCE_SCHEMA_INVALID: "INVALID-SCHEMA",
        EXIT_EVIDENCE_SEMANTIC_INVALID: "INVALID-SEMANTICS",
        EXIT_TOOLING_ERROR: "TOOLING-ERROR",
    }.get(report.exit_code, f"EXIT-{report.exit_code}")
    print(f"full-pass summary validation: {header}")
    print(f"- summary: {report.summary_path}")
    print(f"- schema: {report.schema_path}")
    print(f"- overall_status: {report.overall_status}")
    print(f"- validation_class: {report.validation_class}")
    print(f"- declared_assertions: {', '.join(report.declared_assertion_ids) or '<none>'}")
    print(f"- extracted_assertions: {', '.join(report.extracted_assertion_ids) or '<none>'}")
    print(f"- raw_log_path: {report.raw_log_path or '<missing>'}")
    print(f"- raw_log_exists: {report.raw_log_exists}")
    if report.nonpassed_assertions:
        print("- nonpassed_assertions:")
        for item in report.nonpassed_assertions:
            print(
                "  - {assertion_id}:{status}:{reason}".format(
                    assertion_id=item.get("assertion_id", ""),
                    status=item.get("status", ""),
                    reason=item.get("failure_reason") or "<missing>",
                )
            )
    if report.issues:
        print("- issues:")
        for item in report.issues:
            path_suffix = f" [{item['path']}]" if item.get("path") else ""
            print(f"  - ({item['code']}) {item['message']}{path_suffix}")
    if report.warnings:
        print("- warnings:")
        for item in report.warnings:
            path_suffix = f" [{item['path']}]" if item.get("path") else ""
            print(f"  - ({item['code']}) {item['message']}{path_suffix}")
    print(f"- exit_code: {report.exit_code}")


def main() -> int:
    args = parse_args()
    try:
        summary_path = Path(args.summary).resolve()
        schema_path = Path(args.schema).resolve()

        if not summary_path.exists():
            print(f"[full-pass-summary-validate] 找不到 summary.json：{summary_path}", file=sys.stderr)
            return EXIT_TOOLING_ERROR
        if not schema_path.exists():
            print(f"[full-pass-summary-validate] 找不到 schema：{schema_path}", file=sys.stderr)
            return EXIT_TOOLING_ERROR

        summary = load_json(summary_path)
        schema = load_json(schema_path)

        schema_issues = validate_against_schema(summary, schema)
        semantic_issues: list[Issue] = []
        warnings: list[Issue] = []
        semantics: dict[str, Any] = {
            "declared_assertion_ids": [],
            "parsed_event_assertion_ids": [],
            "raw_log_assertion_ids": [],
            "extracted_assertion_ids": [],
            "parsed_event_map": {},
            "raw_log_map": {},
            "runtime_flag_checks": {},
            "resolved_raw_log_path": None,
            "raw_log_exists": False,
        }

        if not schema_issues and isinstance(summary, dict):
            semantic_issues, warnings, semantics = validate_semantics(summary, summary_path)

        overall_status = summary.get("overall_status") if isinstance(summary, dict) else None
        exit_code, validation_class = classify_exit_code(schema_issues, semantic_issues, overall_status)

        report = ValidationReport(
            summary_path=str(summary_path),
            schema_path=str(schema_path),
            label=summary.get("label") if isinstance(summary, dict) else None,
            overall_status=overall_status,
            schema_valid=not schema_issues,
            semantic_valid=not semantic_issues,
            validation_class=validation_class,
            exit_code=exit_code,
            status_counts=summarize_statuses(summary.get("assertions", [])) if isinstance(summary, dict) else {},
            nonpassed_assertions=collect_nonpassed_assertions(summary.get("assertions", [])) if isinstance(summary, dict) else [],
            declared_assertion_ids=semantics["declared_assertion_ids"],
            extracted_assertion_ids=semantics["extracted_assertion_ids"],
            parsed_event_assertion_ids=semantics["parsed_event_assertion_ids"],
            raw_log_assertion_ids=semantics["raw_log_assertion_ids"],
            raw_log_path=semantics["resolved_raw_log_path"],
            raw_log_exists=semantics["raw_log_exists"],
            semantic_extractors={
                "parsed_event_map": semantics["parsed_event_map"],
                "raw_log_map": semantics["raw_log_map"],
                "runtime_flag_checks": semantics["runtime_flag_checks"],
            },
            issues=[asdict(item) for item in [*schema_issues, *semantic_issues]],
            warnings=[asdict(item) for item in warnings],
        )

        if args.report:
            write_json(Path(args.report).resolve(), asdict(report))

        print_report(report)
        return exit_code
    except json.JSONDecodeError as exc:
        print(f"[full-pass-summary-validate] JSON 解析失败：{exc}", file=sys.stderr)
        return EXIT_TOOLING_ERROR
    except Exception as exc:
        print(f"[full-pass-summary-validate] 未处理异常：{exc}", file=sys.stderr)
        return EXIT_TOOLING_ERROR


if __name__ == "__main__":
    raise SystemExit(main())
