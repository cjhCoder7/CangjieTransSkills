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

import phase06_ui_expansion_audit as expansion_audit  # noqa: E402
import phase06_ui_expansion_audit_validate as validator  # noqa: E402


class Phase06UiExpansionAuditValidateTests(unittest.TestCase):
    def make_valid_report(self) -> dict:
        return {
            "audit_name": "phase06-ui-expansion-audit",
            "audit_version": 2,
            "decision_scope": expansion_audit.DECISION_SCOPE_REGULAR_EXPANSION,
            "final_decision": expansion_audit.DECISION_HOLD,
            "next_action_hint": expansion_audit.DECISION_HOLD,
            "sample_manifest": {
                "manifest_path": "/tmp/sample.json",
                "regular_sample_count": 2,
                "regular_sample_ids": ["sample-a", "sample-b"],
            },
            "source_corpus_summary": {
                "frozen_sample_count": 2,
                "frozen_sample_ids": ["sample-a", "sample-b"],
                "unfrozen_sample_count": 0,
            },
            "file_manifest_summary": {
                "covered_sample_count": 2,
                "covered_sample_ids": ["sample-a", "sample-b"],
            },
            "workset_summary": {
                "audit_count": 1,
                "missing_workset_audit_count": 0,
                "non_exhausted_workset_count": 0,
            },
            "unfrozen_regular_samples": [],
            "missing_workset_audits": [],
            "non_exhausted_worksets": [],
            "workset_audit_reports": [
                {
                    "decision_scope": expansion_audit.DECISION_SCOPE_WORKSET,
                    "exhausted_workset": True,
                    "missing_slice_count": 0,
                    "workset_next_action_hint": "current-file-workset-exhausted-prepare-new-source-corpus",
                    "next_action_hint": "current-file-workset-exhausted-prepare-new-source-corpus",
                }
            ],
        }

    def test_validate_accepts_scoped_report_with_matching_compatibility_hints(self) -> None:
        report = validator.validate_audit(
            self.make_valid_report(),
            require_audit_version=2,
            require_final_decision=expansion_audit.DECISION_HOLD,
        )
        self.assertEqual(validator.EXIT_OK, report["exit_code"])
        self.assertEqual("valid-expansion-audit", report["validation_class"])
        self.assertEqual([], report["issues"])

    def test_validate_rejects_top_level_hint_mismatch(self) -> None:
        payload = self.make_valid_report()
        payload["next_action_hint"] = expansion_audit.DECISION_CONTINUE_WORKSET
        report = validator.validate_audit(payload, require_audit_version=2)
        self.assertEqual(validator.EXIT_VALIDATION_FAILED, report["exit_code"])
        self.assertTrue(any(item["code"] == "compatibility-hint-mismatch" for item in report["issues"]))

    def test_validate_rejects_workset_scope_mismatch(self) -> None:
        payload = self.make_valid_report()
        payload["workset_audit_reports"][0]["decision_scope"] = "wrong-scope"
        report = validator.validate_audit(payload, require_audit_version=2)
        self.assertEqual(validator.EXIT_VALIDATION_FAILED, report["exit_code"])
        self.assertTrue(any(item["code"] == "unexpected-workset-scope" for item in report["issues"]))

    def test_main_writes_report_and_returns_nonzero_for_bad_decision(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            audit_path = tmp / "audit.json"
            report_path = tmp / "report.json"
            payload = self.make_valid_report()
            audit_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

            exit_code = validator.main(
                [
                    "--audit",
                    str(audit_path),
                    "--report",
                    str(report_path),
                    "--require-audit-version",
                    "2",
                    "--require-final-decision",
                    expansion_audit.DECISION_FREEZE_NEW_CORPUS,
                ]
            )
            self.assertEqual(validator.EXIT_VALIDATION_FAILED, exit_code)
            report = json.loads(report_path.read_text(encoding="utf-8"))
            self.assertEqual("invalid-expansion-audit", report["validation_class"])
            self.assertTrue(any(item["code"] == "unexpected-final-decision" for item in report["issues"]))


if __name__ == "__main__":
    unittest.main()
