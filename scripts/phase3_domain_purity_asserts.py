#!/usr/bin/env python3
"""Phase 3C 包 B：领域纯洁度断言。"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Dict, List

BANNED_SIGNATURE_TOKENS = (
    "TL",
    "InputPeer",
    "SignalPipe",
    "ValueSignal",
    "Signal<",
    "Array<UInt8>",
    "Vector<UInt8>",
    "@ohos",
    "ohos.",
    "sendRequest",
    "TLDeserializer",
    "TLSerializer",
)

ALLOWED_IMPORT_PREFIXES = (
    "std.",
)


def extract_real_message_service_public_lines(text: str) -> List[str]:
    lines = text.splitlines()
    in_service = False
    brace_depth = 0
    result: List[str] = []
    for raw_line in lines:
        line = raw_line.strip()
        if not in_service and re.search(r"\bclass\s+RealMessageService\b", raw_line):
            in_service = True
        if in_service:
            brace_depth += raw_line.count("{")
            brace_depth -= raw_line.count("}")
            if line.startswith("public "):
                result.append(line)
            if brace_depth <= 0:
                in_service = False
    return result


def scan_target(path: Path) -> Dict[str, object]:
    text = path.read_text(encoding="utf-8")
    imports = [line.strip() for line in text.splitlines() if line.strip().startswith("import ")]
    public_lines = extract_real_message_service_public_lines(text)
    violations: List[Dict[str, str]] = []

    for line in public_lines:
        for token in BANNED_SIGNATURE_TOKENS:
            if token in line:
                violations.append({
                    "type": "public-signature",
                    "token": token,
                    "line": line,
                })

    for line in imports:
        imported = line.removeprefix("import ").strip()
        if not imported.startswith(ALLOWED_IMPORT_PREFIXES):
            violations.append({
                "type": "import-whitelist",
                "token": imported,
                "line": line,
            })

    return {
        "target": str(path.resolve()),
        "imports": imports,
        "public_lines": public_lines,
        "passed": not violations,
        "violations": violations,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan RealMessageService public signatures and imports for domain purity leaks")
    parser.add_argument("--target-file", action="append", required=True, help="Target .cj file to scan")
    parser.add_argument("--output", type=str, help="Optional JSON output path")
    args = parser.parse_args()

    results = [scan_target(Path(item)) for item in args.target_file]
    passed = all(item["passed"] for item in results)
    payload = {
        "status": "passed" if passed else "failed",
        "rule_set": {
            "banned_signature_tokens": list(BANNED_SIGNATURE_TOKENS),
            "allowed_import_prefixes": list(ALLOWED_IMPORT_PREFIXES),
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
