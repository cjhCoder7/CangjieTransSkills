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

import phase06_ui_workset_audit as audit  # noqa: E402


class Phase06UiWorksetAuditTests(unittest.TestCase):
    def test_repo_manifests_show_p0_workset_exhausted_without_overlap(self) -> None:
        report = audit.audit_workset(
            file_manifest_payload=audit.read_json(
                PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json"
            ),
            pilot_manifests=[
                {
                    "manifest_path": str(PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_prompt_pilot_batch1.json"),
                    "payload": audit.read_json(
                        PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_prompt_pilot_batch1.json"
                    ),
                },
                {
                    "manifest_path": str(PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_prompt_pilot_next_stage.json"),
                    "payload": audit.read_json(
                        PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_prompt_pilot_next_stage.json"
                    ),
                },
            ],
        )
        self.assertEqual(12, report["file_manifest"]["expected_slice_count"])
        self.assertEqual(12, report["summary"]["covered_slice_count"])
        self.assertTrue(report["summary"]["exhausted_workset"])
        self.assertEqual([], report["missing_slice_ids"])
        self.assertEqual([], report["overlap_slice_ids"])
        self.assertEqual([], report["unknown_slice_ids"])
        self.assertEqual(
            "current-file-workset-exhausted-prepare-new-source-corpus",
            report["next_action_hint"],
        )

    def test_audit_reports_missing_overlap_and_unknown_slices(self) -> None:
        file_manifest_payload = {
            "manifest_name": "phase06-ui-test-file-manifest",
            "entries": [
                {"slice_id": "slice-a"},
                {"slice_id": "slice-b"},
                {"slice_id": "slice-c"},
            ],
        }
        report = audit.audit_workset(
            file_manifest_payload=file_manifest_payload,
            pilot_manifests=[
                {
                    "manifest_path": "/tmp/pilot-a.json",
                    "manifest_label": "pilot-a",
                    "payload": {"summary": {"selected_slice_ids": ["slice-a", "slice-b"]}},
                },
                {
                    "manifest_path": "/tmp/pilot-b.json",
                    "manifest_label": "pilot-b",
                    "payload": {"entries": [{"slice_id": "slice-b"}, {"slice_id": "slice-d"}]},
                },
            ],
        )
        self.assertEqual(["slice-c"], report["missing_slice_ids"])
        self.assertEqual(["slice-b"], report["overlap_slice_ids"])
        self.assertEqual(["slice-d"], report["unknown_slice_ids"])
        self.assertEqual(
            {
                "manifest_label": "pilot-b",
                "manifest_path": "/tmp/pilot-b.json",
                "slice_count": 2,
                "known_slice_count": 1,
                "overlap_slice_count": 1,
                "unknown_slice_count": 1,
                "slice_ids": ["slice-b", "slice-d"],
                "known_slice_ids": ["slice-b"],
                "overlap_slice_ids": ["slice-b"],
                "unknown_slice_ids": ["slice-d"],
            },
            report["manifest_reports"][1],
        )
        self.assertEqual("fix-manifest-drift-before-expansion", report["next_action_hint"])

    def test_main_returns_nonzero_when_workset_is_not_exhausted(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            file_manifest_path = tmp / "file.json"
            pilot_manifest_path = tmp / "pilot.json"
            output_path = tmp / "audit.json"

            file_manifest_path.write_text(
                json.dumps(
                    {
                        "manifest_name": "phase06-ui-test-file-manifest",
                        "entries": [{"slice_id": "slice-a"}, {"slice_id": "slice-b"}],
                    },
                    ensure_ascii=False,
                    indent=2,
                )
                + "\n",
                encoding="utf-8",
            )
            pilot_manifest_path.write_text(
                json.dumps({"summary": {"selected_slice_ids": ["slice-a"]}}, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )

            exit_code = audit.main(
                [
                    "--file-manifest",
                    str(file_manifest_path),
                    "--pilot-manifest",
                    str(pilot_manifest_path),
                    "--output",
                    str(output_path),
                    "--require-exhausted",
                ]
            )
            self.assertEqual(2, exit_code)
            report = json.loads(output_path.read_text(encoding="utf-8"))
            self.assertEqual(["slice-b"], report["missing_slice_ids"])


if __name__ == "__main__":
    unittest.main()