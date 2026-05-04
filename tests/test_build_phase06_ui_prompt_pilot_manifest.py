from __future__ import annotations

import sys
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import build_phase06_ui_prompt_pilot_manifest as builder  # noqa: E402


class Phase06UiPromptPilotManifestBuilderTests(unittest.TestCase):
    def build_manifest(self) -> dict:
        return builder.build_prompt_pilot_manifest(
            file_manifest_payload=builder.read_json(builder.DEFAULT_FILE_MANIFEST_PATH),
            artifacts_root=builder.DEFAULT_ARTIFACTS_ROOT,
        )

    def build_residual_manifest(self) -> dict:
        return builder.build_prompt_pilot_manifest(
            file_manifest_payload=builder.read_json(builder.DEFAULT_FILE_MANIFEST_PATH),
            artifacts_root=builder.PROJECT_ROOT / "artifacts" / "ui_pilots" / "20260409-phase06-ui-pilot-next-stage",
            manifest_name="phase06_ui_prompt_pilot_next_stage",
            selection_mode="residual-workset",
            exclude_manifest_payload=builder.read_json(builder.DEFAULT_OUTPUT_PATH),
        )

    def build_p1_manifest(self) -> dict:
        return builder.build_prompt_pilot_manifest(
            file_manifest_payload=builder.read_json(
                builder.PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p1_file_manifest.json"
            ),
            artifacts_root=builder.PROJECT_ROOT / "artifacts" / "ui_pilots" / "20260410-phase06-ui-p1-pilot-batch1",
            file_manifest_path=builder.PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p1_file_manifest.json",
            manifest_name="phase06_ui_prompt_pilot_p1_batch1",
            track_profile="p1-batch1",
        )

    def build_p1_residual_manifest(self) -> dict:
        return builder.build_prompt_pilot_manifest(
            file_manifest_payload=builder.read_json(
                builder.PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p1_file_manifest.json"
            ),
            artifacts_root=builder.PROJECT_ROOT / "artifacts" / "ui_pilots" / "20260410-phase06-ui-p1-pilot-next-stage",
            file_manifest_path=builder.PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p1_file_manifest.json",
            manifest_name="phase06_ui_prompt_pilot_p1_next_stage",
            selection_mode="residual-workset",
            exclude_manifest_payload=self.build_p1_manifest(),
        )

    def test_batch1_selects_expected_lane_anchors(self) -> None:
        manifest = self.build_manifest()
        self.assertEqual(
            [
                "phase06-ui-p0-badgeview-page",
                "phase06-ui-p0-ledger-top-bar-component",
                "phase06-ui-p0-markdown-index-page",
                "phase06-ui-p0-markdown-heading-component",
                "phase06-ui-p0-photo-view-component",
            ],
            manifest["summary"]["selected_slice_ids"],
        )
        self.assertEqual(5, manifest["summary"]["pilot_count"])
        self.assertEqual(
            {
                "page-shell-view-model-renderer": 1,
                "rich-component-view-model-renderer": 1,
                "page-shell-controller-owned-state": 1,
                "rich-component-controller-owned-state": 1,
                "gesture-rich-component-controller-owned-state": 1,
            },
            manifest["summary"]["track_counts"],
        )

    def test_builder_infers_src_root_and_target_file_for_supported_layouts(self) -> None:
        self.assertEqual(
            (
                "raw_docs/phase06-ui-p0/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src",
                "pages/badgeSample.cj",
            ),
            builder.infer_src_root_and_target_file(
                "raw_docs/phase06-ui-p0/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/badgeSample.cj"
            ),
        )
        self.assertEqual(
            (
                "raw_docs/phase06-ui-p0/HarmonyOS-Examples/15-Ledger/entry/src/main/cangjie",
                "ui/top_bar.cj",
            ),
            builder.infer_src_root_and_target_file(
                "raw_docs/phase06-ui-p0/HarmonyOS-Examples/15-Ledger/entry/src/main/cangjie/ui/top_bar.cj"
            ),
        )
        self.assertEqual(
            (
                "raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src",
                "components/markdown_heading_component.cj",
            ),
            builder.infer_src_root_and_target_file(
                "raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src/components/markdown_heading_component.cj"
            ),
        )
        self.assertEqual(
            (
                "raw_docs/phase06-ui-p1/titlebar4cj/titlebar/src",
                "titlebar.cj",
            ),
            builder.infer_src_root_and_target_file(
                "raw_docs/phase06-ui-p1/titlebar4cj/titlebar/src/titlebar.cj"
            ),
        )

    def test_manifest_precomputes_pipeline_paths_and_command(self) -> None:
        manifest = self.build_manifest()
        entries = {entry["slice_id"]: entry for entry in manifest["entries"]}

        badge = entries["phase06-ui-p0-badgeview-page"]
        self.assertEqual(
            "artifacts/ui_pilots/20260408-phase06-ui-pilot-batch1/phase06-ui-p0-badgeview-page/prompt_dump.explicit_ui_tags.txt",
            badge["explicit_prompt_dump_path"],
        )
        self.assertIn("--dump-prompt-only", badge["pipeline_command"])
        self.assertIn("--architecture-skill", badge["pipeline_command"])
        self.assertIn("docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md", badge["pipeline_command"])

        photo_view = entries["phase06-ui-p0-photo-view-component"]
        self.assertEqual(["gesture-component"], photo_view["interaction_tags"])
        self.assertEqual(
            [
                "photoview4cj-gesture-rich-component-controller-owned-state",
                "markdown4cj-rich-component-controller-owned-state",
            ],
            photo_view["recommended_few_shot_entry_ids"],
        )

    def test_residual_mode_excludes_batch1_slices_and_keeps_remaining_workset(self) -> None:
        manifest = self.build_residual_manifest()
        self.assertEqual(
            [
                "phase06-ui-p0-ledger-entry-page",
                "phase06-ui-p0-ledger-details-list-component",
                "phase06-ui-p0-modal-window-page",
                "phase06-ui-p0-custom-tab-bar-page",
                "phase06-ui-p0-markdown-table-block-component",
                "phase06-ui-p0-photo-view-model",
                "phase06-ui-p0-photoview-simple-sample-page",
            ],
            manifest["summary"]["selected_slice_ids"],
        )
        self.assertEqual(7, manifest["summary"]["pilot_count"])
        self.assertEqual(5, manifest["summary"]["excluded_slice_count"])
        self.assertEqual(
            [
                "phase06-ui-p0-badgeview-page",
                "phase06-ui-p0-ledger-top-bar-component",
                "phase06-ui-p0-markdown-index-page",
                "phase06-ui-p0-markdown-heading-component",
                "phase06-ui-p0-photo-view-component",
            ],
            manifest["selection_policy"]["excluded_slice_ids"],
        )
        self.assertEqual(
            "residual-workset-after-excluding-consumed-slices",
            manifest["selection_policy"]["selection_mode"],
        )
        entries = {entry["slice_id"]: entry for entry in manifest["entries"]}
        residual_photo_vm = entries["phase06-ui-p0-photo-view-model"]
        self.assertEqual("phase06-ui-pilot-next-stage-phase06-ui-p0-photo-view-model", residual_photo_vm["pilot_id"])
        self.assertEqual(
            "phase06-ui-next-stage-phase06-ui-p0-photo-view-model",
            residual_photo_vm["snapshot_label"],
        )
        self.assertTrue(residual_photo_vm["track_id"].startswith("residual-gesture-component-rich-component-controller-owned-state-viewmodel"))

    def test_p1_track_profile_selects_primary_renderer_editor_and_mixed_app_lanes(self) -> None:
        manifest = self.build_p1_manifest()
        self.assertEqual(
            [
                "phase06-ui-p1-svg-render-merman-page",
                "phase06-ui-p1-svg-image-view-component",
                "phase06-ui-p1-editor-kit-host-page",
                "phase06-ui-p1-editor-kit-component",
                "phase06-ui-p1-httpnews-index-page",
            ],
            manifest["summary"]["selected_slice_ids"],
        )
        self.assertEqual(5, manifest["summary"]["pilot_count"])
        self.assertEqual("p1-batch1", manifest["selection_policy"]["track_profile"])
        self.assertEqual(
            {
                "page-shell-view-model-renderer": 1,
                "rich-component-view-model-renderer": 1,
                "page-shell-controller-owned-state": 1,
                "rich-component-controller-owned-state": 1,
                "mixed-app-page-shell-controller-owned-state": 1,
            },
            manifest["summary"]["track_counts"],
        )
        entries = {entry["slice_id"]: entry for entry in manifest["entries"]}
        httpnews = entries["phase06-ui-p1-httpnews-index-page"]
        self.assertEqual("mixed-app-page-shell-controller-owned-state", httpnews["track_id"])
        self.assertEqual(["mixed-app-pattern"], httpnews["sample_scope_tags"])
        self.assertEqual(
            "phase06-ui-pilot-p1-batch1-phase06-ui-p1-httpnews-index-page",
            httpnews["pilot_id"],
        )
        self.assertEqual(
            "phase06-ui-p1-batch1-phase06-ui-p1-httpnews-index-page",
            httpnews["snapshot_label"],
        )

    def test_p1_residual_mode_keeps_titlebar_and_httpnews_tail(self) -> None:
        manifest = self.build_p1_residual_manifest()
        self.assertEqual(
            [
                "phase06-ui-p1-httpnews-news-model",
                "phase06-ui-p1-httpnews-detail-page",
                "phase06-ui-p1-title-bar-component",
                "phase06-ui-p1-title-bar-index-page",
            ],
            manifest["summary"]["selected_slice_ids"],
        )
        self.assertEqual(4, manifest["summary"]["pilot_count"])
        self.assertEqual(5, manifest["summary"]["excluded_slice_count"])
        entries = {entry["slice_id"]: entry for entry in manifest["entries"]}
        titlebar_component = entries["phase06-ui-p1-title-bar-component"]
        self.assertEqual(
            "raw_docs/phase06-ui-p1/titlebar4cj/titlebar/src",
            titlebar_component["src_root"],
        )
        self.assertEqual("titlebar.cj", titlebar_component["target_file"])
        self.assertTrue(
            titlebar_component["track_id"].startswith("residual-rich-component-view-model-renderer-component")
        )


if __name__ == "__main__":
    unittest.main()
