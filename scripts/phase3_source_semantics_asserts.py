#!/usr/bin/env python3
"""Phase 3C：RealMessageService V9 source semantics 断言。"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Dict, List

GET_HISTORY_DECL = re.compile(r"^\s*class\s+GetHistoryParams\s*\{")
PUBLIC_GET_HISTORY_DECL = re.compile(r"^\s*public\s+class\s+GetHistoryParams\s*\{")
PRIVATE_FETCH_DECL = re.compile(r"^\s*private\s+func\s+fetchMessages\(params:\s*GetHistoryParams\)\s*:\s*Array<DomainMessage>\s*\{")
LEGACY_FETCH_DECL = re.compile(r"^\s*private\s+func\s+fetchMessages\(peerId:\s*PeerId,\s*limit:\s*Int32\)\s*:\s*Array<DomainMessage>\s*\{")


def scan_target(path: Path) -> Dict[str, object]:
    lines = path.read_text(encoding="utf-8").splitlines()
    violations: List[Dict[str, object]] = []
    facts = {
        "has_get_history_params": False,
        "get_history_params_public": False,
        "has_private_fetch_params_bag": False,
        "has_legacy_private_fetch": False,
    }

    for lineno, raw in enumerate(lines, start=1):
        if GET_HISTORY_DECL.search(raw):
            facts["has_get_history_params"] = True
        if PUBLIC_GET_HISTORY_DECL.search(raw):
            facts["get_history_params_public"] = True
            violations.append({
                "type": "public-type",
                "line": lineno,
                "line_text": raw.strip(),
                "reason": "GetHistoryParams must stay package-local / internal",
            })
        if PRIVATE_FETCH_DECL.search(raw):
            facts["has_private_fetch_params_bag"] = True
        if LEGACY_FETCH_DECL.search(raw):
            facts["has_legacy_private_fetch"] = True
            violations.append({
                "type": "legacy-fetch-signature",
                "line": lineno,
                "line_text": raw.strip(),
                "reason": "fetchMessages should use internal params bag instead of peerId+limit",
            })

    if not facts["has_get_history_params"]:
        violations.append({
            "type": "missing-type",
            "reason": "GetHistoryParams class is missing",
        })
    if not facts["has_private_fetch_params_bag"]:
        violations.append({
            "type": "missing-fetch-signature",
            "reason": "private fetchMessages(params: GetHistoryParams) is missing",
        })

    return {
        "target": str(path.resolve()),
        "passed": not violations,
        "facts": facts,
        "violations": violations,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Assert V9 source semantics for RealMessageService fetchMessages shape")
    parser.add_argument("--target-file", action="append", required=True, help="Target .cj file to scan")
    parser.add_argument("--output", type=str, help="Optional JSON output path")
    args = parser.parse_args()

    results = [scan_target(Path(item)) for item in args.target_file]
    passed = all(item["passed"] for item in results)
    payload = {
        "status": "passed" if passed else "failed",
        "rule_set": {
            "required_type": "GetHistoryParams",
            "required_fetch_signature": "private func fetchMessages(params: GetHistoryParams): Array<DomainMessage>",
            "banned_fetch_signature": "private func fetchMessages(peerId: PeerId, limit: Int32): Array<DomainMessage>",
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
