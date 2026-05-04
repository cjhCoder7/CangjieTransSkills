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

import phase06_ui_expansion_audit as audit  # noqa: E402


class Phase06UiExpansionAuditTests(unittest.TestCase):
    def make_sample_manifest(self, sample_ids: list[str]) -> dict:
        return {
            "manifest_name": "phase06-ui-sample-manifest",
            "ordered_samples": [
                {
                    "sample_id": sample_id,
                    "priority": "P0",
                    "adoption_decision": "primary",
                    "source_type": "external_repo",
                    "source": {"url": f"https://example.test/{sample_id}", "commit": f"commit-{sample_id}"},
                    "source_paths": [f"{sample_id}.cj"],
                }
                for sample_id in sample_ids
            ],
        }

    def make_source_corpus(self, sample_ids: list[str], manifest_name: str = "phase06-ui-source-corpus-p0") -> dict:
        return {
            "manifest_name": manifest_name,
            "selection_policy": {
                "sample_buckets": ["ordered_samples"],
                "priority": "P0",
                "adoption_decision": "primary",
                "source_type": "external_repo",
            },
            "sample_count": len(sample_ids),
            "file_count": len(sample_ids),
            "entries": [{"entry_id": sample_id, "sample_id": sample_id} for sample_id in sample_ids],
        }

    def make_file_manifest(
        self,
        sample_ids: list[str],
        *,
        manifest_name: str = "phase06-ui-p0-file-manifest",
        source_corpus_manifest: str = "phase06_ui_source_corpus_p0.json",
    ) -> dict:
        return {
            "manifest_name": manifest_name,
            "source_corpus_manifest": source_corpus_manifest,
            "entries": [
                {
                    "slice_id": f"slice-{sample_id}",
                    "sample_id": sample_id,
                }
                for sample_id in sample_ids
            ],
        }

    def make_workset_audit(
        self,
        *,
        manifest_name: str,
        manifest_path: str,
        expected_slice_count: int,
        covered_slice_count: int,
        missing_slice_count: int,
        exhausted_workset: bool,
        next_action_hint: str | None = None,
    ) -> dict:
        if next_action_hint is None:
            next_action_hint = audit.DECISION_HOLD if exhausted_workset else audit.DECISION_CONTINUE_WORKSET
        return {
            "file_manifest": {
                "manifest_name": manifest_name,
                "manifest_path": manifest_path,
                "expected_slice_count": expected_slice_count,
            },
            "summary": {
                "covered_slice_count": covered_slice_count,
                "missing_slice_count": missing_slice_count,
                "coverage_ratio": covered_slice_count / expected_slice_count if expected_slice_count else 1.0,
                "exhausted_workset": exhausted_workset,
            },
            "next_action_hint": next_action_hint,
        }

    def test_reports_hold_when_all_regular_samples_are_frozen_and_all_worksets_are_exhausted(self) -> None:
        report = audit.build_report(
            sample_manifest_path=PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json",
            sample_manifest_payload=self.make_sample_manifest(["sample-a", "sample-b"]),
            source_corpus_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p0.json",
                    "payload": self.make_source_corpus(["sample-a", "sample-b"]),
                }
            ],
            file_manifest_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json",
                    "payload": self.make_file_manifest(["sample-a", "sample-b"]),
                }
            ],
            workset_audit_payloads=[
                {
                    "path": PROJECT_ROOT / "artifacts" / "ui_pilots" / "phase06-ui-p0-workset-audit.json",
                    "payload": self.make_workset_audit(
                        manifest_name="phase06-ui-p0-file-manifest",
                        manifest_path=str(PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json"),
                        expected_slice_count=2,
                        covered_slice_count=2,
                        missing_slice_count=0,
                        exhausted_workset=True,
                    ),
                }
            ],
        )
        self.assertEqual(audit.DECISION_SCOPE_REGULAR_EXPANSION, report["decision_scope"])
        self.assertEqual(audit.DECISION_HOLD, report["final_decision"])
        self.assertEqual(audit.DECISION_HOLD, report["next_action_hint"])
        self.assertEqual([], report["unfrozen_regular_samples"])
        self.assertEqual([], report["missing_workset_audits"])
        self.assertEqual([], report["non_exhausted_worksets"])

    def test_reports_freeze_new_corpus_when_regular_samples_are_not_yet_frozen(self) -> None:
        report = audit.build_report(
            sample_manifest_path=PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json",
            sample_manifest_payload=self.make_sample_manifest(["sample-a", "sample-b", "sample-c"]),
            source_corpus_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p0.json",
                    "payload": self.make_source_corpus(["sample-a", "sample-b"]),
                }
            ],
            file_manifest_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json",
                    "payload": self.make_file_manifest(["sample-a", "sample-b"]),
                }
            ],
            workset_audit_payloads=[
                {
                    "path": PROJECT_ROOT / "artifacts" / "ui_pilots" / "phase06-ui-p0-workset-audit.json",
                    "payload": self.make_workset_audit(
                        manifest_name="phase06-ui-p0-file-manifest",
                        manifest_path=str(PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json"),
                        expected_slice_count=2,
                        covered_slice_count=2,
                        missing_slice_count=0,
                        exhausted_workset=True,
                    ),
                }
            ],
        )
        self.assertEqual(audit.DECISION_FREEZE_NEW_CORPUS, report["final_decision"])
        self.assertEqual(audit.DECISION_FREEZE_NEW_CORPUS, report["next_action_hint"])
        self.assertEqual(["sample-c"], [item["sample_id"] for item in report["unfrozen_regular_samples"]])

    def test_reports_continue_when_current_workset_is_not_yet_exhausted(self) -> None:
        report = audit.build_report(
            sample_manifest_path=PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json",
            sample_manifest_payload=self.make_sample_manifest(["sample-a", "sample-b"]),
            source_corpus_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p0.json",
                    "payload": self.make_source_corpus(["sample-a", "sample-b"]),
                }
            ],
            file_manifest_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json",
                    "payload": self.make_file_manifest(["sample-a", "sample-b"]),
                }
            ],
            workset_audit_payloads=[
                {
                    "path": PROJECT_ROOT / "artifacts" / "ui_pilots" / "phase06-ui-p0-workset-audit.json",
                    "payload": self.make_workset_audit(
                        manifest_name="phase06-ui-p0-file-manifest",
                        manifest_path=str(PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json"),
                        expected_slice_count=2,
                        covered_slice_count=1,
                        missing_slice_count=1,
                        exhausted_workset=False,
                    ),
                }
            ],
        )
        self.assertEqual(audit.DECISION_CONTINUE_WORKSET, report["final_decision"])
        self.assertEqual(audit.DECISION_CONTINUE_WORKSET, report["next_action_hint"])
        self.assertEqual(1, report["workset_summary"]["non_exhausted_workset_count"])
        self.assertEqual(1, report["non_exhausted_worksets"][0]["missing_slice_count"])

    def test_report_exposes_scoped_workset_hint_without_overriding_final_decision(self) -> None:
        workset_hint = "current-file-workset-exhausted-prepare-new-source-corpus"
        report = audit.build_report(
            sample_manifest_path=PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json",
            sample_manifest_payload=self.make_sample_manifest(["sample-a", "sample-b"]),
            source_corpus_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p0.json",
                    "payload": self.make_source_corpus(["sample-a", "sample-b"]),
                }
            ],
            file_manifest_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json",
                    "payload": self.make_file_manifest(["sample-a", "sample-b"]),
                }
            ],
            workset_audit_payloads=[
                {
                    "path": PROJECT_ROOT / "artifacts" / "ui_pilots" / "phase06-ui-p0-workset-audit.json",
                    "payload": self.make_workset_audit(
                        manifest_name="phase06-ui-p0-file-manifest",
                        manifest_path=str(PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json"),
                        expected_slice_count=2,
                        covered_slice_count=2,
                        missing_slice_count=0,
                        exhausted_workset=True,
                        next_action_hint=workset_hint,
                    ),
                }
            ],
        )
        self.assertEqual(audit.DECISION_HOLD, report["final_decision"])
        self.assertEqual(audit.DECISION_HOLD, report["next_action_hint"])
        self.assertEqual(audit.DECISION_SCOPE_WORKSET, report["workset_audit_reports"][0]["decision_scope"])
        self.assertEqual(workset_hint, report["workset_audit_reports"][0]["workset_next_action_hint"])
        self.assertNotEqual(report["final_decision"], report["workset_audit_reports"][0]["workset_next_action_hint"])

    def test_ignores_draft_manifests_and_audits_from_regular_aggregate_counts(self) -> None:
        regular_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p4_file_manifest.json"
        draft_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p4_draft_file_manifest.json"
        report = audit.build_report(
            sample_manifest_path=PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json",
            sample_manifest_payload=self.make_sample_manifest(["sample-a"]),
            source_corpus_payloads=[
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p4.json",
                    "payload": self.make_source_corpus(["sample-a"], manifest_name="phase06-ui-source-corpus-p4"),
                },
                {
                    "path": PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p4_draft.json",
                    "payload": self.make_source_corpus(["sample-a"], manifest_name="phase06-ui-source-corpus-p4-draft"),
                },
            ],
            file_manifest_payloads=[
                {
                    "path": regular_manifest_path,
                    "payload": self.make_file_manifest(
                        ["sample-a"],
                        manifest_name="phase06-ui-p4-file-manifest",
                        source_corpus_manifest="phase06_ui_source_corpus_p4.json",
                    ),
                },
                {
                    "path": draft_manifest_path,
                    "payload": self.make_file_manifest(
                        ["sample-a"],
                        manifest_name="phase06-ui-p4-draft-file-manifest",
                        source_corpus_manifest="phase06_ui_source_corpus_p4_draft.json",
                    ),
                },
            ],
            workset_audit_payloads=[
                {
                    "path": PROJECT_ROOT / "artifacts" / "ui_pilots" / "20260411-phase06-ui-p4-workset-audit.json",
                    "payload": self.make_workset_audit(
                        manifest_name="phase06-ui-p4-file-manifest",
                        manifest_path=str(regular_manifest_path),
                        expected_slice_count=1,
                        covered_slice_count=1,
                        missing_slice_count=0,
                        exhausted_workset=True,
                    ),
                },
                {
                    "path": PROJECT_ROOT / "artifacts" / "ui_pilots" / "20260411-phase06-ui-p4-draft-workset-audit.json",
                    "payload": self.make_workset_audit(
                        manifest_name="phase06-ui-p4-draft-file-manifest",
                        manifest_path=str(draft_manifest_path),
                        expected_slice_count=1,
                        covered_slice_count=1,
                        missing_slice_count=0,
                        exhausted_workset=True,
                    ),
                },
            ],
        )
        self.assertEqual(audit.DECISION_HOLD, report["final_decision"])
        self.assertEqual(1, report["source_corpus_summary"]["manifest_count"])
        self.assertEqual(1, report["source_corpus_summary"]["ignored_manifest_count"])
        self.assertEqual(1, report["file_manifest_summary"]["manifest_count"])
        self.assertEqual(1, report["file_manifest_summary"]["ignored_manifest_count"])
        self.assertEqual(1, report["workset_summary"]["audit_count"])
        self.assertEqual(1, report["workset_summary"]["ignored_audit_count"])
        self.assertEqual(
            [regular_manifest_path.resolve().as_posix()],
            [item["manifest_path"] for item in report["file_manifest_reports"]],
        )

    def test_main_returns_nonzero_when_decision_does_not_match_requirement(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            sample_manifest_path = tmp / "sample.json"
            source_corpus_path = tmp / "phase06_ui_source_corpus_p0.json"
            file_manifest_path = tmp / "phase06_ui_p0_file_manifest.json"
            workset_audit_path = tmp / "workset_audit.json"
            output_path = tmp / "audit.json"

            sample_manifest_path.write_text(
                json.dumps(self.make_sample_manifest(["sample-a", "sample-b", "sample-c"]), ensure_ascii=False, indent=2)
                + "\n",
                encoding="utf-8",
            )
            source_corpus_path.write_text(
                json.dumps(self.make_source_corpus(["sample-a", "sample-b"]), ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            file_manifest_path.write_text(
                json.dumps(self.make_file_manifest(["sample-a", "sample-b"]), ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            workset_audit_path.write_text(
                json.dumps(
                    self.make_workset_audit(
                        manifest_name="phase06-ui-p0-file-manifest",
                        manifest_path=str(file_manifest_path),
                        expected_slice_count=2,
                        covered_slice_count=2,
                        missing_slice_count=0,
                        exhausted_workset=True,
                    ),
                    ensure_ascii=False,
                    indent=2,
                )
                + "\n",
                encoding="utf-8",
            )

            exit_code = audit.main(
                [
                    "--sample-manifest",
                    str(sample_manifest_path),
                    "--source-corpus-manifest",
                    str(source_corpus_path),
                    "--file-manifest",
                    str(file_manifest_path),
                    "--workset-audit",
                    str(workset_audit_path),
                    "--output",
                    str(output_path),
                    "--require-decision",
                    audit.DECISION_HOLD,
                ]
            )
            self.assertEqual(2, exit_code)
            report = json.loads(output_path.read_text(encoding="utf-8"))
            self.assertEqual(audit.DECISION_SCOPE_REGULAR_EXPANSION, report["decision_scope"])
            self.assertEqual(audit.DECISION_FREEZE_NEW_CORPUS, report["final_decision"])
            self.assertEqual(audit.DECISION_FREEZE_NEW_CORPUS, report["next_action_hint"])


if __name__ == "__main__":
    unittest.main()