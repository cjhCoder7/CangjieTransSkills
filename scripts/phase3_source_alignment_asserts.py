#!/usr/bin/env python3
"""Phase 3C：RealMessageService Source Alignment public surface 断言。"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Dict, List

ALLOWED_PUBLIC_TYPES = {
    "PeerId",
    "DomainMessage",
    "SendMessageParams",
    "MessageSignal",
    "RealMessageService",
}

ALLOWED_PUBLIC_MEMBERS = {
    "MessageSignal": (
        "public init(",
        "public func currentSnapshot(",
    ),
    "RealMessageService": (
        "public init(",
        "public func getMessages(",
        "public func sendMessage(",
    ),
}

TYPE_PATTERN = re.compile(
    r"^(?P<indent>\s*)(?P<keyword>public class|public interface|open class)\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)\b"
)


def extract_type_blocks(text: str) -> List[Dict[str, object]]:
    lines = text.splitlines()
    results: List[Dict[str, object]] = []
    current: Dict[str, object] | None = None
    brace_depth = 0

    for lineno, raw_line in enumerate(lines, start=1):
        stripped = raw_line.strip()
        match = TYPE_PATTERN.match(raw_line)
        if current is None and match:
            current = {
                "name": match.group("name"),
                "declaration": stripped,
                "line": lineno,
                "public_lines": [],
            }
            brace_depth = raw_line.count("{") - raw_line.count("}")
            if brace_depth <= 0:
                results.append(current)
                current = None
            continue

        if current is not None:
            brace_depth += raw_line.count("{")
            brace_depth -= raw_line.count("}")
            if stripped.startswith("public "):
                current["public_lines"].append({"line": lineno, "text": stripped})
            if brace_depth <= 0:
                results.append(current)
                current = None

    return results


def scan_target(path: Path) -> Dict[str, object]:
    text = path.read_text(encoding="utf-8")
    blocks = extract_type_blocks(text)
    violations: List[Dict[str, object]] = []

    for block in blocks:
        name = str(block["name"])
        declaration = str(block["declaration"])
        if name not in ALLOWED_PUBLIC_TYPES:
            violations.append(
                {
                    "type": "public-type",
                    "name": name,
                    "line": block["line"],
                    "declaration": declaration,
                    "reason": "type not in source-aligned public whitelist",
                }
            )
            continue

        allowed_prefixes = ALLOWED_PUBLIC_MEMBERS.get(name)
        if not allowed_prefixes:
            continue

        for item in block["public_lines"]:
            line = str(item["text"])
            if not any(line.startswith(prefix) for prefix in allowed_prefixes):
                violations.append(
                    {
                        "type": "public-member",
                        "owner": name,
                        "line": item["line"],
                        "member": line,
                        "reason": "member not in source-aligned public whitelist",
                    }
                )

    return {
        "target": str(path.resolve()),
        "allowed_public_types": sorted(ALLOWED_PUBLIC_TYPES),
        "allowed_public_members": {key: list(value) for key, value in ALLOWED_PUBLIC_MEMBERS.items()},
        "public_blocks": blocks,
        "passed": not violations,
        "violations": violations,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Assert source-aligned public surface for RealMessageService harness")
    parser.add_argument("--target-file", action="append", required=True, help="Target .cj file to scan")
    parser.add_argument("--output", type=str, help="Optional JSON output path")
    args = parser.parse_args()

    results = [scan_target(Path(item)) for item in args.target_file]
    passed = all(item["passed"] for item in results)
    payload = {
        "status": "passed" if passed else "failed",
        "rule_set": {
            "allowed_public_types": sorted(ALLOWED_PUBLIC_TYPES),
            "allowed_public_members": {key: list(value) for key, value in ALLOWED_PUBLIC_MEMBERS.items()},
        },
        "results": results,
    }

    rendered = json.dumps(payload, ensure_ascii=False, indent=2)
    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered + "\n", encoding="utf-8")
    print(rendered)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
