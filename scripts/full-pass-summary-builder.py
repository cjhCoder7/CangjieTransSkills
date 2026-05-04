#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

PROJECT_ROOT = Path(__file__).resolve().parent.parent
ASSERTION_ID_PATTERN = re.compile(r"\b(?:BCM|SMOKE)-[A-Z]+-\d{3}\b")
DEFAULT_SMOKE_ASSERTION_ID = "SMOKE-LAUNCH-001"
LINE_PREFIX_PATTERN = re.compile(r"^(?P<origin>\d+):(?!//)(?P<body>.*)$")
HILOG_PATTERN = re.compile(
    r"^(?P<date>\d{2}-\d{2})\s+"
    r"(?P<clock>\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?)\s+"
    r"(?P<pid>\S+)\s+"
    r"(?P<tid>\S+)\s+"
    r"(?P<level>[A-Z])\s+"
    r"(?P<tag>[^\s:]+)\s+"
    r"(?P<event>[^\s:]+)\s*"
    r"(?P<message>.*)$"
)
ISO_PATTERN = re.compile(
    r"^(?P<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?Z?)\s+"
    r"(?P<tid>\S+)\s+"
    r"(?P<level>[A-Z]+)\s+"
    r"(?P<tag>[^\s:]+)\s+"
    r"(?P<event>[^\s:]+)\s*"
    r"(?P<message>.*)$"
)
DEFAULT_ASSERTION_DESCRIPTIONS = {
    "BCM-CONC-001": "worker fetch/send 全程不阻塞主线程",
    "BCM-STATE-001": "缓存写入后状态一致",
    "BCM-ASYNC-003": "刷新通知回到主线程交付",
    DEFAULT_SMOKE_ASSERTION_ID: "install/launch 最小部署链路闭环",
}


@dataclass
class ParsedEvent:
    timestamp: str
    thread_id: str
    thread_name: str | None
    log_level: str
    tag: str
    event_name: str
    message: str
    thread_context: str
    assertion_refs: list[str]
    raw_log_ref: str


@dataclass
class AssertionBuildResult:
    assertion_id: str
    description: str
    status: str
    evidence: dict[str, list[str]]
    failure_reason: str | None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="将过滤后的 Hilog/运行时日志归一化为 Full Pass summary.json")
    parser.add_argument("--log-input", required=True, help="用于解析结构化事件的过滤后日志路径")
    parser.add_argument("--raw-log-path", required=True, help="写入 summary.runtime_log_capture.raw_log_path 的原始日志路径")
    parser.add_argument("--summary-output", required=True, help="输出 summary.json 路径")
    parser.add_argument("--label", required=True)
    parser.add_argument("--captured-at-utc", help="UTC 时间戳，默认当前时间")
    parser.add_argument("--phase-major", default="Phase 3C")
    parser.add_argument("--phase-substage", default="Full Pass")
    parser.add_argument("--promotion-candidate", default="staging-full")
    parser.add_argument("--schema-version", default="1.0.0")
    parser.add_argument("--module-name", required=True)
    parser.add_argument("--source-file", required=True)
    parser.add_argument("--candidate-file", required=True)
    parser.add_argument("--ui-route")
    parser.add_argument("--peer-scope")
    parser.add_argument("--host-os", required=True)
    parser.add_argument("--host-arch", required=True)
    parser.add_argument("--node-mode", required=True, choices=["gui-host", "headless-host", "remote-runner"])
    parser.add_argument("--deveco-studio-home", required=True)
    parser.add_argument("--harmony-sdk-home", required=True)
    parser.add_argument("--hdc-path", required=True)
    parser.add_argument("--host-probe-json")
    parser.add_argument("--target-type", required=True, choices=["emulator", "device"])
    parser.add_argument("--target-id", required=True)
    parser.add_argument("--target-name", required=True)
    parser.add_argument("--target-os-version")
    parser.add_argument("--target-serial-redacted", default="true")
    parser.add_argument("--build-id", required=True)
    parser.add_argument("--bundle-name", required=True)
    parser.add_argument("--artifact-path")
    parser.add_argument("--install-status", required=True, choices=["passed", "failed", "blocked", "partial", "skipped"])
    parser.add_argument("--launch-status", required=True, choices=["passed", "failed", "blocked", "partial", "skipped"])
    parser.add_argument("--log-source", required=True, choices=["hilog", "logcat", "file", "unknown"])
    parser.add_argument("--log-capture-command", required=True)
    parser.add_argument("--redaction-applied", default="true")
    parser.add_argument("--scenario-mode", default="bcm", choices=["bcm", "smoke"])
    parser.add_argument("--expected-assertions", required=True, help="逗号分隔的 assertion 列表")
    parser.add_argument("--note", action="append", default=[])
    return parser.parse_args()


def parse_bool(raw: str) -> bool:
    value = raw.strip().lower()
    if value in {"1", "true", "yes", "y", "on"}:
        return True
    if value in {"0", "false", "no", "n", "off"}:
        return False
    raise ValueError(f"无法解析布尔值：{raw}")


def normalize_level(level: str) -> str:
    mapping = {
        "D": "DEBUG",
        "DEBUG": "DEBUG",
        "I": "INFO",
        "INFO": "INFO",
        "W": "WARN",
        "WARN": "WARN",
        "E": "ERROR",
        "ERROR": "ERROR",
        "F": "FATAL",
        "FATAL": "FATAL",
    }
    return mapping.get(level.upper(), "INFO")


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_capture_time(raw: str | None) -> datetime:
    if not raw:
        return datetime.now(timezone.utc)
    normalized = raw[:-1] + "+00:00" if raw.endswith("Z") else raw
    parsed = datetime.fromisoformat(normalized)
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def normalize_partial_timestamp(date_token: str, clock_token: str, capture_time: datetime) -> str:
    raw = f"{capture_time.year}-{date_token}T{clock_token}"
    try:
        parsed = datetime.fromisoformat(raw)
        parsed = parsed.replace(tzinfo=timezone.utc)
        return parsed.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
    except ValueError:
        return f"{capture_time.year}-{date_token}T{clock_token}Z"


def normalize_iso_timestamp(raw: str) -> str:
    normalized = raw[:-1] + "+00:00" if raw.endswith("Z") else raw
    try:
        parsed = datetime.fromisoformat(normalized)
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        return parsed.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"
    except ValueError:
        return raw if raw.endswith("Z") else f"{raw}Z"


def extract_assertion_ids(text: str) -> list[str]:
    return ASSERTION_ID_PATTERN.findall(text)


def unique_in_order(items: Iterable[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


def infer_thread_context(event_name: str, message: str) -> str:
    event_upper = event_name.upper()
    message_lower = message.lower()
    if "main" in message_lower or "ui" in message_lower and ("refresh" in message_lower or "dataset" in message_lower):
        return "main"
    if "REFRESH" in event_upper and "DELIVER" in event_upper and "worker" not in message_lower:
        return "main"
    if "worker" in message_lower or "background" in message_lower or "spawn" in message_lower:
        return "worker"
    if "FETCH" in event_upper or "SEND" in event_upper:
        return "worker"
    return "unknown"


def infer_thread_name(thread_id: str, thread_context: str) -> str | None:
    if thread_context == "main":
        return "main"
    if thread_context == "worker":
        return f"worker-{thread_id}"
    return None


def parse_log_line(raw_line: str, fallback_line_number: int, capture_time: datetime) -> ParsedEvent | None:
    text = raw_line.rstrip("\n")
    if not text.strip():
        return None

    raw_ref_number = fallback_line_number
    prefix_match = LINE_PREFIX_PATTERN.match(text)
    if prefix_match:
        raw_ref_number = int(prefix_match.group("origin"))
        text = prefix_match.group("body").lstrip()

    iso_match = ISO_PATTERN.match(text)
    if iso_match:
        event_name = iso_match.group("event")
        message = iso_match.group("message")
        thread_context = infer_thread_context(event_name, message)
        thread_id = iso_match.group("tid")
        return ParsedEvent(
            timestamp=normalize_iso_timestamp(iso_match.group("timestamp")),
            thread_id=thread_id,
            thread_name=infer_thread_name(thread_id, thread_context),
            log_level=normalize_level(iso_match.group("level")),
            tag=iso_match.group("tag"),
            event_name=event_name,
            message=message,
            thread_context=thread_context,
            assertion_refs=unique_in_order(extract_assertion_ids(text)),
            raw_log_ref=f"raw_log:{raw_ref_number}",
        )

    hilog_match = HILOG_PATTERN.match(text)
    if hilog_match:
        event_name = hilog_match.group("event")
        message = hilog_match.group("message")
        thread_context = infer_thread_context(event_name, message)
        thread_id = hilog_match.group("tid")
        return ParsedEvent(
            timestamp=normalize_partial_timestamp(hilog_match.group("date"), hilog_match.group("clock"), capture_time),
            thread_id=thread_id,
            thread_name=infer_thread_name(thread_id, thread_context),
            log_level=normalize_level(hilog_match.group("level")),
            tag=hilog_match.group("tag"),
            event_name=event_name,
            message=message,
            thread_context=thread_context,
            assertion_refs=unique_in_order(extract_assertion_ids(text)),
            raw_log_ref=f"raw_log:{raw_ref_number}",
        )

    generic_ids = extract_assertion_ids(text)
    if not generic_ids:
        return None

    event_name = "RUNTIME_OBSERVED"
    thread_context = infer_thread_context(event_name, text)
    thread_id = str(raw_ref_number)
    return ParsedEvent(
        timestamp=normalize_iso_timestamp(capture_time.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"),
        thread_id=thread_id,
        thread_name=infer_thread_name(thread_id, thread_context),
        log_level="INFO",
        tag="FULLPASS",
        event_name=event_name,
        message=text,
        thread_context=thread_context,
        assertion_refs=unique_in_order(generic_ids),
        raw_log_ref=f"raw_log:{raw_ref_number}",
    )


def enrich_events_for_scenario(
    events: list[ParsedEvent],
    capture_time: datetime,
    scenario_mode: str,
    install_status: str,
    launch_status: str,
) -> list[ParsedEvent]:
    if scenario_mode != "smoke":
        return events
    if install_status != "passed" or launch_status != "passed":
        return events
    if any(DEFAULT_SMOKE_ASSERTION_ID in item.assertion_refs for item in events):
        return events
    synthetic_timestamp = normalize_iso_timestamp(capture_time.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z")
    synthetic_event = ParsedEvent(
        timestamp=synthetic_timestamp,
        thread_id="build",
        thread_name="harness",
        log_level="INFO",
        tag="FULLPASS",
        event_name="SMOKE_CHAIN_PASSED",
        message=f"{DEFAULT_SMOKE_ASSERTION_ID} derived-from install_status=passed launch_status=passed",
        thread_context="unknown",
        assertion_refs=[DEFAULT_SMOKE_ASSERTION_ID],
        raw_log_ref="derived:build",
    )
    return [*events, synthetic_event]


def load_events(log_input_path: Path, capture_time: datetime) -> list[ParsedEvent]:
    events: list[ParsedEvent] = []
    for line_number, line in enumerate(log_input_path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
        event = parse_log_line(line, line_number, capture_time)
        if event is None:
            continue
        events.append(event)
    return events


def default_description(assertion_id: str) -> str:
    if assertion_id in DEFAULT_ASSERTION_DESCRIPTIONS:
        return DEFAULT_ASSERTION_DESCRIPTIONS[assertion_id]
    if assertion_id.startswith("BCM-CONC-"):
        return f"{assertion_id} 并发线程边界断言"
    if assertion_id.startswith("BCM-STATE-"):
        return f"{assertion_id} 状态一致性断言"
    if assertion_id.startswith("BCM-ASYNC-"):
        return f"{assertion_id} 异步刷新线程断言"
    if assertion_id.startswith("SMOKE-"):
        return f"{assertion_id} 最小部署链路 smoke 断言"
    return f"{assertion_id} 自动提取断言"


def build_assertion_result(
    assertion_id: str,
    events: list[ParsedEvent],
    scenario_mode: str,
    install_status: str,
    launch_status: str,
) -> AssertionBuildResult:
    matched_events = [item for item in events if assertion_id in item.assertion_refs]
    matched_event_names = unique_in_order(item.event_name for item in matched_events)
    matched_thread_ids = unique_in_order(item.thread_id for item in matched_events)
    raw_log_refs = unique_in_order(item.raw_log_ref for item in matched_events)

    if not matched_events:
        failure_reason = f"未在过滤后的运行时日志中观察到 {assertion_id} 对应事件"
        if assertion_id.startswith("BCM-ASYNC-"):
            failure_reason = "未观察到 main 主线程 refresh 交付事件"
        elif assertion_id.startswith("BCM-CONC-"):
            failure_reason = "未观察到 worker 线程内的 fetch/send 事件"
        elif scenario_mode == "smoke" and assertion_id.startswith("SMOKE-"):
            failure_reason = (
                f"未观察到 {assertion_id} 对应的 smoke 部署链路证据；"
                f"install_status={install_status}, launch_status={launch_status}"
            )
        return AssertionBuildResult(
            assertion_id=assertion_id,
            description=default_description(assertion_id),
            status="failed",
            evidence={
                "matched_event_names": [],
                "matched_thread_ids": [],
                "raw_log_refs": [],
            },
            failure_reason=failure_reason,
        )

    if assertion_id.startswith("BCM-ASYNC-"):
        refresh_events = [item for item in matched_events if any(token in item.event_name.upper() for token in ["REFRESH", "DATASET", "DELIVER", "NOTIFY"])]
        if not refresh_events:
            status = "failed"
            failure_reason = "观察到了断言 ID，但未解析到 refresh/dataset/deliver 语义事件"
        elif any(item.thread_context == "main" for item in refresh_events):
            status = "passed"
            failure_reason = None
        else:
            status = "failed"
            failure_reason = "UI refresh 事件未在 main 线程交付"
    elif assertion_id.startswith("BCM-CONC-"):
        worker_events = [item for item in matched_events if item.thread_context == "worker"]
        main_fetch_send = [item for item in matched_events if item.thread_context == "main" and any(token in item.event_name.upper() for token in ["FETCH", "SEND"])]
        if not worker_events:
            status = "failed"
            failure_reason = "未观察到 worker 线程内的 fetch/send 事件"
        elif main_fetch_send:
            status = "failed"
            failure_reason = "观察到了主线程上的 fetch/send 事件，违反并发边界"
        else:
            status = "passed"
            failure_reason = None
    elif assertion_id.startswith("BCM-STATE-"):
        state_events = [item for item in matched_events if any(token in item.event_name.upper() for token in ["SEND", "FETCH", "CACHE", "STATE", "UPDATE", "APPLY", "HISTORY"])]
        if state_events:
            status = "passed"
            failure_reason = None
        else:
            status = "failed"
            failure_reason = "仅看到了 assertion ID，但没有状态/缓存相关事件"
    else:
        status = "passed"
        failure_reason = None

    return AssertionBuildResult(
        assertion_id=assertion_id,
        description=default_description(assertion_id),
        status=status,
        evidence={
            "matched_event_names": matched_event_names,
            "matched_thread_ids": matched_thread_ids,
            "raw_log_refs": raw_log_refs,
        },
        failure_reason=failure_reason,
    )


def compute_runtime_flags(events: list[ParsedEvent]) -> dict[str, Any]:
    refresh_events = [item for item in events if any(token in item.event_name.upper() for token in ["REFRESH", "DATASET", "DELIVER", "NOTIFY"])]
    main_thread_refresh_seen = any(item.thread_context == "main" for item in refresh_events)
    worker_fetch_seen = any(item.thread_context == "worker" and "FETCH" in item.event_name.upper() for item in events)
    worker_send_seen = any(item.thread_context == "worker" and "SEND" in item.event_name.upper() for item in events)
    refresh_delivery_context = "unknown"
    if refresh_events:
        if any(item.thread_context == "main" for item in refresh_events):
            refresh_delivery_context = "main"
        elif any(item.thread_context == "worker" for item in refresh_events):
            refresh_delivery_context = "worker"
    return {
        "main_thread_refresh_seen": main_thread_refresh_seen,
        "worker_fetch_seen": worker_fetch_seen,
        "worker_send_seen": worker_send_seen,
        "refresh_delivery_context": refresh_delivery_context,
    }


def resolve_overall_status(install_status: str, launch_status: str, assertions: list[AssertionBuildResult]) -> str:
    for status in (install_status, launch_status):
        if status != "passed":
            return status
    assertion_statuses = [item.status for item in assertions]
    if all(status == "passed" for status in assertion_statuses):
        return "passed"
    if any(status == "blocked" for status in assertion_statuses):
        return "blocked"
    if any(status == "failed" for status in assertion_statuses):
        return "failed"
    if any(status == "partial" for status in assertion_statuses):
        return "partial"
    if all(status == "skipped" for status in assertion_statuses):
        return "skipped"
    return "partial"


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    log_input_path = Path(args.log_input).resolve()
    raw_log_path = Path(args.raw_log_path).resolve()
    summary_output_path = Path(args.summary_output).resolve()
    if not log_input_path.exists():
        raise SystemExit(f"[full-pass-summary-builder] 找不到 log-input：{log_input_path}")
    if not raw_log_path.exists():
        raise SystemExit(f"[full-pass-summary-builder] 找不到 raw-log-path：{raw_log_path}")

    capture_time = parse_capture_time(args.captured_at_utc)
    events = load_events(log_input_path, capture_time)
    events = enrich_events_for_scenario(
        events,
        capture_time,
        args.scenario_mode,
        args.install_status,
        args.launch_status,
    )
    assertion_ids = unique_in_order(item.strip() for item in args.expected_assertions.split(",") if item.strip())
    assertion_results = [
        build_assertion_result(
            assertion_id,
            events,
            args.scenario_mode,
            args.install_status,
            args.launch_status,
        )
        for assertion_id in assertion_ids
    ]
    runtime_flags = compute_runtime_flags(events)
    notes = [*args.note, f"scenario_mode={args.scenario_mode}"]
    if args.scenario_mode == "smoke" and args.install_status == "passed" and args.launch_status == "passed":
        notes.append("SMOKE-LAUNCH-001 is builder-derived from successful install/launch status.")
    notes.extend(
        [
            f"generated by {Path(__file__).name}",
            f"log_input={log_input_path}",
        ]
    )

    summary = {
        "schema_version": args.schema_version,
        "label": args.label,
        "phase_major": args.phase_major,
        "phase_substage": args.phase_substage,
        "scenario_mode": args.scenario_mode,
        "promotion_candidate": args.promotion_candidate,
        "overall_status": resolve_overall_status(args.install_status, args.launch_status, assertion_results),
        "captured_at_utc": capture_time.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "module": {
            "name": args.module_name,
            "source_file": args.source_file,
            "candidate_file": args.candidate_file,
            "ui_route": args.ui_route,
            "peer_scope": args.peer_scope,
        },
        "environment": {
            "host_os": args.host_os,
            "host_arch": args.host_arch,
            "node_mode": args.node_mode,
            "deveco_studio_home": args.deveco_studio_home,
            "harmony_sdk_home": args.harmony_sdk_home,
            "hdc_path": args.hdc_path,
            "host_probe_json": args.host_probe_json,
        },
        "target": {
            "target_type": args.target_type,
            "target_id": args.target_id,
            "target_name": args.target_name,
            "target_os_version": args.target_os_version,
            "target_serial_redacted": parse_bool(args.target_serial_redacted),
        },
        "build": {
            "build_id": args.build_id,
            "bundle_name": args.bundle_name,
            "artifact_path": args.artifact_path,
            "install_status": args.install_status,
            "launch_status": args.launch_status,
        },
        "runtime_log_capture": {
            "log_source": args.log_source,
            "log_capture_command": args.log_capture_command,
            "raw_log_path": str(raw_log_path),
            "redaction_applied": parse_bool(args.redaction_applied),
            "main_thread_refresh_seen": runtime_flags["main_thread_refresh_seen"],
            "worker_fetch_seen": runtime_flags["worker_fetch_seen"],
            "worker_send_seen": runtime_flags["worker_send_seen"],
            "refresh_delivery_context": runtime_flags["refresh_delivery_context"],
            "parsed_events": [
                {
                    "timestamp": item.timestamp,
                    "thread_id": item.thread_id,
                    "thread_name": item.thread_name,
                    "log_level": item.log_level,
                    "tag": item.tag,
                    "event_name": item.event_name,
                    "message": item.message,
                    "thread_context": item.thread_context,
                    "assertion_refs": item.assertion_refs,
                }
                for item in events
            ],
        },
        "assertions": [
            {
                "assertion_id": item.assertion_id,
                "description": item.description,
                "status": item.status,
                "evidence": item.evidence,
                "failure_reason": item.failure_reason,
            }
            for item in assertion_results
        ],
        "notes": notes,
    }
    write_json(summary_output_path, summary)
    print(json.dumps({
        "summary_output": str(summary_output_path),
        "overall_status": summary["overall_status"],
        "parsed_events": len(events),
        "assertions": len(assertion_results),
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
