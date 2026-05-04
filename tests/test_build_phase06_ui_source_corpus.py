from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import build_phase06_ui_source_corpus as builder  # noqa: E402


class Phase06UiSourceCorpusBuilderTests(unittest.TestCase):
    def test_builder_reproduces_existing_p0_sample_and_file_counts(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            output_path = Path(tmpdir) / "phase06_ui_source_corpus_p0.json"
            payload = builder.build_source_corpus_payload(
                sample_manifest_payload=builder.read_json(builder.DEFAULT_SAMPLE_MANIFEST_PATH),
                sample_manifest_path=builder.DEFAULT_SAMPLE_MANIFEST_PATH,
                corpus_root=builder.DEFAULT_CORPUS_ROOT,
                manifest_name="phase06-ui-source-corpus-p0",
                priority="P0",
                adoption_decision="primary",
                source_type="external_repo",
                sample_buckets=("ordered_samples",),
                output_path=output_path,
                repo_root=PROJECT_ROOT,
            )
        self.assertEqual("phase06-ui-source-corpus-p0", payload["manifest_name"])
        self.assertEqual(6, payload["sample_count"])
        self.assertEqual(12, payload["file_count"])
        self.assertEqual("../../raw_docs/phase06-ui-p0", payload["corpus_root"])
        self.assertEqual(
            [
                "raw_docs/phase06-ui-p0/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/badgeSample.cj"
            ],
            payload["entries"][0]["repo_local_paths"],
        )
        self.assertEqual("HarmonyOS-Examples", payload["entries"][0]["repo_name"])

    def test_builder_can_materialize_local_repo_control_entries(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            output_path = Path(tmpdir) / "phase06_ui_source_corpus_local.json"
            payload = builder.build_source_corpus_payload(
                sample_manifest_payload=builder.read_json(builder.DEFAULT_SAMPLE_MANIFEST_PATH),
                sample_manifest_path=builder.DEFAULT_SAMPLE_MANIFEST_PATH,
                corpus_root=builder.DEFAULT_CORPUS_ROOT,
                manifest_name="phase06-ui-source-corpus-local-control",
                priority="P0",
                adoption_decision="control",
                source_type="local_repo",
                sample_buckets=("control_samples",),
                output_path=output_path,
                repo_root=PROJECT_ROOT,
            )
        self.assertEqual(2, payload["sample_count"])
        sample_ids = [entry["sample_id"] for entry in payload["entries"]]
        self.assertEqual(
            ["local-ui-routing-defining-page-layout", "local-data-persistence-001"],
            sample_ids,
        )
        self.assertEqual("Cangjie", payload["entries"][0]["repo_name"])
        self.assertEqual(
            [
                "samples/ui-routing-defining-page-layout/entry/src/main/cangjie/pages/FoodCategoryListPage.cj",
                "samples/ui-routing-defining-page-layout/entry/src/main/cangjie/pages/FoodDetailPage.cj",
            ],
            payload["entries"][0]["repo_local_paths"],
        )

    def test_builder_can_materialize_exception_reference_entries(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            output_path = Path(tmpdir) / "phase06_ui_source_corpus_exception.json"
            payload = builder.build_source_corpus_payload(
                sample_manifest_payload=builder.read_json(builder.DEFAULT_SAMPLE_MANIFEST_PATH),
                sample_manifest_path=builder.DEFAULT_SAMPLE_MANIFEST_PATH,
                corpus_root=PROJECT_ROOT / "raw_docs" / "phase06-ui-exception",
                manifest_name="phase06-ui-source-corpus-exception",
                priority="any",
                adoption_decision="any",
                source_type="external_repo",
                sample_buckets=("exception_references",),
                output_path=output_path,
                repo_root=PROJECT_ROOT,
                role="exception",
            )
        self.assertEqual("phase06-ui-source-corpus-exception", payload["manifest_name"])
        self.assertEqual(2, payload["sample_count"])
        self.assertEqual(4, payload["file_count"])
        self.assertEqual("../../raw_docs/phase06-ui-exception", payload["corpus_root"])
        self.assertEqual("exception", payload["selection_policy"]["role"])
        self.assertEqual(
            ["avif-ffi-native-boundary", "svga-cj-hybrid-boundary"],
            [entry["entry_id"] for entry in payload["entries"]],
        )
        self.assertEqual("avif-ffi-native-boundary", payload["entries"][0]["sample_id"])
        self.assertEqual(["ffi-exception"], payload["entries"][0]["exception_tags"])
        self.assertEqual(
            "raw_docs/phase06-ui-exception/avif-ffi/avif4cj/src/main/cangjie/avif_decoder.cj",
            payload["entries"][0]["repo_local_paths"][0],
        )

    def test_builder_raises_when_selected_frozen_files_are_missing(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            output_path = Path(tmpdir) / "phase06_ui_source_corpus_p1.json"
            with self.assertRaisesRegex(ValueError, "missing frozen corpus files"):
                builder.build_source_corpus_payload(
                    sample_manifest_payload=builder.read_json(builder.DEFAULT_SAMPLE_MANIFEST_PATH),
                    sample_manifest_path=builder.DEFAULT_SAMPLE_MANIFEST_PATH,
                    corpus_root=PROJECT_ROOT / "raw_docs" / "phase06-ui-missing-p1",
                    manifest_name="phase06-ui-source-corpus-p1",
                    priority="P1",
                    adoption_decision="primary",
                    source_type="external_repo",
                    sample_buckets=("ordered_samples",),
                    output_path=output_path,
                    repo_root=PROJECT_ROOT,
                )


if __name__ == "__main__":
    unittest.main()

