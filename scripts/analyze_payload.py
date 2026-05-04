#!/usr/bin/env python3
"""诊断 LLM request payload 的大小组成。"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any, Dict, List, Optional

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PIPELINE_RUNS_ROOT = PROJECT_ROOT / "artifacts" / "pipeline_runs"
DEFAULT_SAFE_THRESHOLD_TOKENS = 8000.0
PROMPT_SECTION_RE = re.compile(r"(?ms)^\[(?P<title>[^\n]+)\]\n(?P<body>.*?)(?=^\[[^\n]+\]\n|\Z)")
PROMPT_DUMP_SECTION_TITLES = ["Metadata", "System Prompt", "User Prompt"]

CONSTRAINT_SECTION_TITLES = [
    "必达约束维度",
    "Repair Guidance",
    "Source Alignment 铁律",
    "Dynamic Repair Directives",
    "Target-Specific Guardrails",
    "SKILL_SCHEMA_V2 摘要",
    "Architecture Skill 摘要",
    "输出要求",
]


def estimate_tokens(char_count: int) -> float:
    return round(char_count / 4.0, 2)


def extract_prompt_sections(prompt_text: str) -> Dict[str, str]:
    sections: Dict[str, str] = {}
    for match in PROMPT_SECTION_RE.finditer(prompt_text):
        title = match.group("title").strip()
        body = match.group("body").strip()
        sections[title] = body
    return sections


def extract_prompt_dump_section(prompt_dump_text: str, title: str) -> str:
    header_pattern = re.compile(rf"(?m)^\[{re.escape(title)}\]\n")
    match = header_pattern.search(prompt_dump_text)
    if match is None:
        return ""
    end = len(prompt_dump_text)
    for candidate in PROMPT_DUMP_SECTION_TITLES:
        if candidate == title:
            continue
        next_match = re.compile(rf"(?m)^\[{re.escape(candidate)}\]\n").search(prompt_dump_text, match.end())
        if next_match is not None:
            end = min(end, next_match.start())
    return prompt_dump_text[match.end() : end].strip()


def summarize_request_payload(
    request_payload: Dict[str, Any],
    *,
    safe_threshold_tokens: float,
) -> Dict[str, Any]:
    messages = request_payload.get("messages", []) if isinstance(request_payload.get("messages"), list) else []
    message_breakdown: List[Dict[str, Any]] = []
    system_parts: List[str] = []
    user_parts: List[str] = []
    for index, message in enumerate(messages):
        if not isinstance(message, dict):
            continue
        role = str(message.get("role", ""))
        content = str(message.get("content", ""))
        message_breakdown.append(
            {
                "index": index,
                "role": role,
                "char_count": len(content),
                "estimated_tokens": estimate_tokens(len(content)),
            }
        )
        if role == "system":
            system_parts.append(content)
        elif role == "user":
            user_parts.append(content)
    system_text = "\n".join(system_parts)
    user_text = "\n".join(user_parts)
    sections = extract_prompt_sections(user_text)
    source_code_text = sections.get("Target Source", "")
    constraints_text = "\n\n".join(sections.get(title, "") for title in CONSTRAINT_SECTION_TITLES if sections.get(title, ""))
    total_chars = sum(item["char_count"] for item in message_breakdown)
    total_tokens = estimate_tokens(total_chars)
    return {
        "message_count": len(message_breakdown),
        "message_breakdown": message_breakdown,
        "system_prompt": {
            "char_count": len(system_text),
            "estimated_tokens": estimate_tokens(len(system_text)),
        },
        "source_code": {
            "char_count": len(source_code_text),
            "estimated_tokens": estimate_tokens(len(source_code_text)),
        },
        "constraints": {
            "char_count": len(constraints_text),
            "estimated_tokens": estimate_tokens(len(constraints_text)),
        },
        "total_input": {
            "char_count": total_chars,
            "estimated_tokens": total_tokens,
        },
        "safe_threshold_tokens": safe_threshold_tokens,
        "compression_required": total_tokens > safe_threshold_tokens,
    }


def find_latest_infrastructure_failure(root: Path) -> Path:
    candidates = sorted(root.rglob("infrastructure_failure.json"), key=lambda item: item.stat().st_mtime, reverse=True)
    if not candidates:
        raise SystemExit(f"未找到 infrastructure_failure.json：{root}")
    return candidates[0]


def analyze_failure_payload(path: Path, *, safe_threshold_tokens: float) -> Dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    request_payload = payload.get("request_payload")
    if not isinstance(request_payload, dict):
        raise SystemExit(f"request_payload 缺失或格式非法：{path}")
    summary = summarize_request_payload(request_payload, safe_threshold_tokens=safe_threshold_tokens)
    return {
        "path": str(path),
        "input_kind": "infrastructure_failure",
        "failure_class": str(payload.get("failure_class", "")),
        "error_type": str(payload.get("error_type", "")),
        "timeout_seconds": payload.get("timeout_seconds"),
        "summary": summary,
    }


def analyze_prompt_dump(path: Path, *, safe_threshold_tokens: float) -> Dict[str, Any]:
    dump_text = path.read_text(encoding="utf-8")
    request_payload = {
        "messages": [
            {"role": "system", "content": extract_prompt_dump_section(dump_text, "System Prompt")},
            {"role": "user", "content": extract_prompt_dump_section(dump_text, "User Prompt")},
        ]
    }
    return {
        "path": str(path),
        "input_kind": "prompt_dump",
        "summary": summarize_request_payload(request_payload, safe_threshold_tokens=safe_threshold_tokens),
    }


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="分析最新 infrastructure_failure.json 中的 LLM request payload 大小")
    parser.add_argument("--failure-json", type=str, help="明确指定 infrastructure_failure.json 路径；若省略则自动取最新一个")
    parser.add_argument("--prompt-dump", type=str, help="改为分析 prompt_dump.txt")
    parser.add_argument("--pipeline-runs-root", type=str, default=str(DEFAULT_PIPELINE_RUNS_ROOT), help="自动发现最新 failure 时使用的根目录")
    parser.add_argument("--safe-threshold-tokens", type=float, default=DEFAULT_SAFE_THRESHOLD_TOKENS, help="安全阈值，默认 8000 tokens")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    if args.prompt_dump:
        report = analyze_prompt_dump(Path(args.prompt_dump).expanduser().resolve(), safe_threshold_tokens=float(args.safe_threshold_tokens))
    elif args.failure_json:
        failure_json_path = Path(args.failure_json).expanduser().resolve()
        report = analyze_failure_payload(failure_json_path, safe_threshold_tokens=float(args.safe_threshold_tokens))
    else:
        failure_json_path = find_latest_infrastructure_failure(Path(args.pipeline_runs_root).expanduser().resolve())
        report = analyze_failure_payload(failure_json_path, safe_threshold_tokens=float(args.safe_threshold_tokens))
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
