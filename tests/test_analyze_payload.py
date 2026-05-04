from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import analyze_payload  # noqa: E402


class AnalyzePayloadTests(unittest.TestCase):
    def test_summarize_request_payload_breaks_out_system_source_and_constraints(self) -> None:
        request_payload = {
            "messages": [
                {"role": "system", "content": "system prompt"},
                {
                    "role": "user",
                    "content": (
                        "[必达约束维度]\n"
                        "[\"Translation Mapping\"]\n\n"
                        "[Source Alignment 铁律]\n"
                        "alignment rules\n\n"
                        "[Target Source]\n"
                        "export class Demo {}\n\n"
                        "[输出要求]\n"
                        "json only\n"
                    ),
                },
            ]
        }

        summary = analyze_payload.summarize_request_payload(request_payload, safe_threshold_tokens=8000.0)

        self.assertEqual(13, summary["system_prompt"]["char_count"])
        self.assertEqual(len("export class Demo {}"), summary["source_code"]["char_count"])
        self.assertGreater(summary["constraints"]["char_count"], 0)
        self.assertFalse(summary["compression_required"])

    def test_analyze_failure_payload_reads_request_payload_from_failure_json(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            failure_path = Path(temp_dir) / "infrastructure_failure.json"
            failure_path.write_text(
                json.dumps(
                    {
                        "failure_class": "infrastructure-error",
                        "error_type": "LLMNetworkException",
                        "timeout_seconds": 180,
                        "request_payload": {
                            "messages": [
                                {"role": "system", "content": "system"},
                                {"role": "user", "content": "[Target Source]\nexport class Demo {}"},
                            ]
                        },
                    },
                    ensure_ascii=False,
                ),
                encoding="utf-8",
            )

            report = analyze_payload.analyze_failure_payload(failure_path, safe_threshold_tokens=1.0)

        self.assertEqual(str(failure_path), report["path"])
        self.assertEqual("LLMNetworkException", report["error_type"])
        self.assertTrue(report["summary"]["compression_required"])

    def test_analyze_prompt_dump_reads_system_and_user_sections(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            prompt_dump_path = Path(temp_dir) / "prompt_dump.txt"
            prompt_dump_path.write_text(
                "# Phase-02 Final Prompt Dump\n\n"
                "[Metadata]\n"
                "{}\n\n"
                "[System Prompt]\n"
                "system prompt\n\n"
                "[User Prompt]\n"
                "[Target Source]\n"
                "export class Demo {}\n",
                encoding="utf-8",
            )

            report = analyze_payload.analyze_prompt_dump(prompt_dump_path, safe_threshold_tokens=8000.0)

        self.assertEqual("prompt_dump", report["input_kind"])
        self.assertEqual(13, report["summary"]["system_prompt"]["char_count"])
        self.assertEqual(len("export class Demo {}"), report["summary"]["source_code"]["char_count"])


if __name__ == "__main__":
    unittest.main()
