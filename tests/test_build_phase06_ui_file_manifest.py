from __future__ import annotations

import sys
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import build_phase06_ui_file_manifest as builder  # noqa: E402


class Phase06UiFileManifestBuilderTests(unittest.TestCase):
    def build_manifest(self, source_corpus_path: Path | None = None) -> dict:
        return builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path or builder.DEFAULT_SOURCE_CORPUS_PATH),
            sample_manifest_payload=builder.read_json(builder.DEFAULT_SAMPLE_MANIFEST_PATH),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )

    def test_manifest_covers_all_frozen_p0_files_once(self) -> None:
        manifest = self.build_manifest()
        entries = manifest["entries"]
        self.assertEqual(12, manifest["summary"]["slice_count"])
        self.assertEqual(12, len(entries))

        expected_paths = set()
        source_corpus = builder.read_json(builder.DEFAULT_SOURCE_CORPUS_PATH)
        for sample in source_corpus["entries"]:
            expected_paths.update(sample["repo_local_paths"])

        actual_paths = {entry["repo_local_path"] for entry in entries}
        self.assertEqual(expected_paths, actual_paths)
        self.assertEqual(len(entries), len(actual_paths))

        for entry in entries:
            self.assertTrue((PROJECT_ROOT / entry["repo_local_path"]).exists(), entry["repo_local_path"])

    def test_manifest_refines_multifile_samples_to_file_level_roles_and_tags(self) -> None:
        manifest = self.build_manifest()
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        top_bar = entries[
            "raw_docs/phase06-ui-p0/HarmonyOS-Examples/15-Ledger/entry/src/main/cangjie/ui/top_bar.cj"
        ]
        self.assertEqual("component", top_bar["target_role"])
        self.assertEqual("rich-component", top_bar["structure_tag"])
        self.assertEqual("view-model-renderer", top_bar["ownership_tag"])

        markdown_index = entries[
            "raw_docs/phase06-ui-p0/markdown4cj/entry/src/main/cangjie/src/index_page.cj"
        ]
        self.assertEqual("page", markdown_index["target_role"])
        self.assertEqual("page-shell", markdown_index["structure_tag"])
        self.assertEqual("controller-owned-state", markdown_index["ownership_tag"])

        photo_view_model = entries[
            "raw_docs/phase06-ui-p0/photoview4cj/photoView/src/main/cangjie/photo_view_model.cj"
        ]
        self.assertEqual("viewmodel", photo_view_model["target_role"])
        self.assertEqual("support-model", photo_view_model["slice_kind"])
        self.assertEqual(["gesture-component"], photo_view_model["interaction_tags"])

    def test_manifest_builds_recommended_few_shot_ids_and_summary_counts(self) -> None:
        manifest = self.build_manifest()
        self.assertEqual(
            {"page": 6, "component": 5, "viewmodel": 1},
            manifest["summary"]["role_counts"],
        )
        self.assertEqual(
            {"page-shell": 6, "rich-component": 6},
            manifest["summary"]["structure_counts"],
        )

        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}
        badge_page = entries[
            "raw_docs/phase06-ui-p0/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/badgeSample.cj"
        ]
        self.assertEqual(
            [
                "local-ui-routing-page-shell-view-model-renderer",
                "harmonyos-examples-badgeview-page-shell-view-model-renderer",
            ],
            badge_page["recommended_few_shot_entry_ids"],
        )

        photo_view = entries[
            "raw_docs/phase06-ui-p0/photoview4cj/photoView/src/main/cangjie/photo_view.cj"
        ]
        self.assertEqual(
            [
                "photoview4cj-gesture-rich-component-controller-owned-state",
                "markdown4cj-rich-component-controller-owned-state",
            ],
            photo_view["recommended_few_shot_entry_ids"],
        )

    def test_manifest_can_expand_p1_source_corpus_with_expected_roles_and_tags(self) -> None:
        manifest = self.build_manifest(
            source_corpus_path=PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p1.json"
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(9, manifest["summary"]["slice_count"])
        self.assertEqual(
            {"page": 5, "component": 3, "viewmodel": 1},
            manifest["summary"]["role_counts"],
        )
        self.assertEqual(
            {"page-shell": 6, "rich-component": 3},
            manifest["summary"]["structure_counts"],
        )

        expected_paths = set()
        source_corpus = builder.read_json(PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p1.json")
        for sample in source_corpus["entries"]:
            expected_paths.update(sample["repo_local_paths"])
        self.assertEqual(expected_paths, set(entries))

        svg_component = entries[
            "raw_docs/phase06-ui-p1/svg4cj/svg/src/main/cangjie/src/svg_image_view.cj"
        ]
        self.assertEqual("component", svg_component["target_role"])
        self.assertEqual("primary-component", svg_component["slice_kind"])
        self.assertEqual("view-model-renderer", svg_component["ownership_tag"])
        self.assertEqual(
            ["svg4cj-rich-component-view-model-renderer"],
            svg_component["recommended_few_shot_entry_ids"],
        )

        editor_component = entries[
            "raw_docs/phase06-ui-p1/editor4cj/entry/src/main/cangjie/src/editor_kit/editorText.cj"
        ]
        self.assertEqual("component", editor_component["target_role"])
        self.assertEqual("primary-component", editor_component["slice_kind"])
        self.assertEqual("rich-component", editor_component["structure_tag"])

        news_model = entries[
            "raw_docs/phase06-ui-p1/HttpNewsApp-Cangjie/entry/src/main/cangjie/src/news.cj"
        ]
        self.assertEqual("viewmodel", news_model["target_role"])
        self.assertEqual("support-model", news_model["slice_kind"])
        self.assertEqual("page-shell", news_model["structure_tag"])
        self.assertEqual(["mixed-app-pattern"], news_model["sample_scope_tags"])
        self.assertEqual(
            [
                "local-data-persistence-page-shell-controller-owned-state",
                "harmonyos-cangjie-cases-customtabbar-page-shell-controller-owned-state",
            ],
            news_model["recommended_few_shot_entry_ids"],
        )

        titlebar_page = entries[
            "raw_docs/phase06-ui-p1/titlebar4cj/entry/src/main/cangjie/index_page.cj"
        ]
        self.assertEqual("page", titlebar_page["target_role"])
        self.assertEqual("entry-page", titlebar_page["slice_kind"])
        self.assertEqual("view-model-renderer", titlebar_page["ownership_tag"])

    def test_manifest_can_expand_exception_source_corpus_with_exception_tags(self) -> None:
        manifest = self.build_manifest(
            source_corpus_path=PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_exception.json"
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(4, manifest["summary"]["slice_count"])
        self.assertEqual(2, manifest["summary"]["sample_count"])
        self.assertEqual(
            {"page": 2, "viewmodel": 1, "component": 1},
            manifest["summary"]["role_counts"],
        )
        self.assertEqual(
            {"page-shell": 2, "rich-component": 2},
            manifest["summary"]["structure_counts"],
        )
        self.assertEqual("exception", manifest["selection_policy"]["role"])

        avif_page = entries[
            "raw_docs/phase06-ui-exception/avif-ffi/entry/src/main/cangjie/example2.cj"
        ]
        self.assertEqual("page", avif_page["target_role"])
        self.assertEqual(["ffi-exception"], avif_page["exception_tags"])
        self.assertEqual("view-model-renderer", avif_page["ownership_tag"])

        avif_decoder = entries[
            "raw_docs/phase06-ui-exception/avif-ffi/avif4cj/src/main/cangjie/avif_decoder.cj"
        ]
        self.assertEqual("viewmodel", avif_decoder["target_role"])
        self.assertEqual("support-model", avif_decoder["slice_kind"])
        self.assertEqual(["ffi-exception"], avif_decoder["exception_tags"])
        self.assertEqual([], avif_decoder["recommended_few_shot_entry_ids"])

        svga_component = entries[
            "raw_docs/phase06-ui-exception/svga-cj/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("component", svga_component["target_role"])
        self.assertEqual(["hybrid-exception"], svga_component["exception_tags"])

        svga_host = entries[
            "raw_docs/phase06-ui-exception/svga-cj/entry/src/main/ets/pages/index.ets"
        ]
        self.assertEqual("page", svga_host["target_role"])
        self.assertEqual(["hybrid-exception"], svga_host["exception_tags"])
        self.assertEqual([], svga_host["recommended_few_shot_entry_ids"])

    def test_manifest_metadata_tracks_selected_source_corpus_name(self) -> None:
        source_corpus = builder.read_json(builder.DEFAULT_SOURCE_CORPUS_PATH)
        source_corpus["manifest_name"] = "phase06-ui-source-corpus-p1"
        source_corpus["source_manifest"] = "phase06_ui_sample_manifest.json"
        manifest = builder.build_file_manifest(
            source_corpus_payload=source_corpus,
            sample_manifest_payload=builder.read_json(builder.DEFAULT_SAMPLE_MANIFEST_PATH),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        self.assertEqual("phase06-ui-p1-file-manifest", manifest["manifest_name"])
        self.assertEqual("phase06_ui_source_corpus_p1.json", manifest["source_corpus_manifest"])
        self.assertEqual("phase06_ui_sample_manifest.json", manifest["source_manifest"])


    def test_manifest_can_expand_p4_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p4_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p4_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p4 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        prototype_page = entries[
            "raw_docs/phase06-ui-p4-draft/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/PrototypePage.cj"
        ]
        self.assertEqual("phase06-ui-p4-aiatom-prototype-page", prototype_page["slice_id"])
        self.assertEqual("page", prototype_page["target_role"])
        self.assertEqual("controller-owned-state", prototype_page["ownership_tag"])

        meeting_list_page = entries[
            "raw_docs/phase06-ui-p4-draft/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/meeting_list_page.cj"
        ]
        self.assertEqual("phase06-ui-p4-secmeet-meeting-list-page", meeting_list_page["slice_id"])
        self.assertEqual("entry-page", meeting_list_page["slice_kind"])

        audit_log_page = entries[
            "raw_docs/phase06-ui-p4-draft/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/audit_log_page.cj"
        ]
        self.assertEqual("phase06-ui-p4-secmeet-audit-log-page", audit_log_page["slice_id"])
        self.assertEqual("controller-owned-state", audit_log_page["ownership_tag"])



    def test_manifest_can_expand_promoted_p4_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p4.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p4 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        prototype_page = entries[
            "raw_docs/phase06-ui-p4/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/PrototypePage.cj"
        ]
        self.assertEqual("phase06-ui-p4-aiatom-prototype-page", prototype_page["slice_id"])
        self.assertEqual("page", prototype_page["target_role"])
        self.assertEqual("controller-owned-state", prototype_page["ownership_tag"])

        meeting_list_page = entries[
            "raw_docs/phase06-ui-p4/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/meeting_list_page.cj"
        ]
        self.assertEqual("phase06-ui-p4-secmeet-meeting-list-page", meeting_list_page["slice_id"])
        self.assertEqual("entry-page", meeting_list_page["slice_kind"])

        audit_log_page = entries[
            "raw_docs/phase06-ui-p4/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/audit_log_page.cj"
        ]
        self.assertEqual("phase06-ui-p4-secmeet-audit-log-page", audit_log_page["slice_id"])
        self.assertEqual("controller-owned-state", audit_log_page["ownership_tag"])


    def test_manifest_can_expand_p5_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p5_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p5_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p5 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(2, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 2}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 2}, manifest["summary"]["structure_counts"])

        history_page = entries[
            "raw_docs/phase06-ui-p5-draft/6a27783ce2bf2047bab996b3994d601d/MeetingAssistant/entry/src/main/cangjie/history.cj"
        ]
        self.assertEqual("phase06-ui-p5-makerizon-history-page", history_page["slice_id"])
        self.assertEqual("page", history_page["target_role"])
        self.assertEqual("controller-owned-state", history_page["ownership_tag"])
        self.assertFalse(history_page["source_scan"]["has_entry_decorator"])
        self.assertTrue(history_page["source_scan"]["has_component_decorator"])

        mine_page = entries[
            "raw_docs/phase06-ui-p5-draft/6a27783ce2bf2047bab996b3994d601d/MeetingAssistant/entry/src/main/cangjie/mine.cj"
        ]
        self.assertEqual("phase06-ui-p5-makerizon-mine-page", mine_page["slice_id"])
        self.assertEqual("entry-page", mine_page["slice_kind"])
        self.assertEqual("controller-owned-state", mine_page["ownership_tag"])
        self.assertTrue(mine_page["source_scan"]["has_component_decorator"])


    def test_manifest_can_expand_promoted_p5_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p5.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p5 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(2, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 2}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 2}, manifest["summary"]["structure_counts"])

        history_page = entries[
            "raw_docs/phase06-ui-p5/6a27783ce2bf2047bab996b3994d601d/MeetingAssistant/entry/src/main/cangjie/history.cj"
        ]
        self.assertEqual("phase06-ui-p5-makerizon-history-page", history_page["slice_id"])
        self.assertEqual("page", history_page["target_role"])
        self.assertEqual("controller-owned-state", history_page["ownership_tag"])
        self.assertFalse(history_page["source_scan"]["has_entry_decorator"])
        self.assertTrue(history_page["source_scan"]["has_component_decorator"])

        mine_page = entries[
            "raw_docs/phase06-ui-p5/6a27783ce2bf2047bab996b3994d601d/MeetingAssistant/entry/src/main/cangjie/mine.cj"
        ]
        self.assertEqual("phase06-ui-p5-makerizon-mine-page", mine_page["slice_id"])
        self.assertEqual("entry-page", mine_page["slice_kind"])
        self.assertEqual("controller-owned-state", mine_page["ownership_tag"])
        self.assertTrue(mine_page["source_scan"]["has_component_decorator"])


    def test_manifest_can_expand_p6_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p6_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p6_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p6 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        speak_page = entries[
            "raw_docs/phase06-ui-p6-draft/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/SpeakPage.cj"
        ]
        self.assertEqual("phase06-ui-p6-aiatom-speak-page", speak_page["slice_id"])
        self.assertEqual("page", speak_page["target_role"])
        self.assertEqual("controller-owned-state", speak_page["ownership_tag"])
        self.assertTrue(speak_page["source_scan"]["has_component_decorator"])
        self.assertIn("class SpeakPage {", speak_page["source_scan"]["declared_types_head"])

        entry_page = entries[
            "raw_docs/phase06-ui-p6-draft/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("phase06-ui-p6-aiatom-entry-page", entry_page["slice_id"])
        self.assertEqual("entry-page", entry_page["slice_kind"])
        self.assertTrue(entry_page["source_scan"]["has_component_decorator"])

        secmeet_index = entries[
            "raw_docs/phase06-ui-p6-draft/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("phase06-ui-p6-secmeet-app-shell-page", secmeet_index["slice_id"])
        self.assertEqual(["mixed-app-pattern"], secmeet_index["sample_scope_tags"])
        self.assertTrue(secmeet_index["source_scan"]["has_entry_decorator"])


    def test_manifest_can_expand_promoted_p6_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p6.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p6 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        speak_page = entries[
            "raw_docs/phase06-ui-p6/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/SpeakPage.cj"
        ]
        self.assertEqual("phase06-ui-p6-aiatom-speak-page", speak_page["slice_id"])
        self.assertEqual("page", speak_page["target_role"])
        self.assertEqual("controller-owned-state", speak_page["ownership_tag"])
        self.assertTrue(speak_page["source_scan"]["has_component_decorator"])
        self.assertIn("class SpeakPage {", speak_page["source_scan"]["declared_types_head"])

        entry_page = entries[
            "raw_docs/phase06-ui-p6/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("phase06-ui-p6-aiatom-entry-page", entry_page["slice_id"])
        self.assertEqual("entry-page", entry_page["slice_kind"])
        self.assertTrue(entry_page["source_scan"]["has_component_decorator"])

        secmeet_index = entries[
            "raw_docs/phase06-ui-p6/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("phase06-ui-p6-secmeet-app-shell-page", secmeet_index["slice_id"])
        self.assertEqual(["mixed-app-pattern"], secmeet_index["sample_scope_tags"])
        self.assertTrue(secmeet_index["source_scan"]["has_entry_decorator"])


    def test_manifest_can_expand_p7_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p7_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p7_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p7 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        text_page = entries[
            "raw_docs/phase06-ui-p7-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/textSample.cj"
        ]
        self.assertEqual("phase06-ui-p7-commonui-text-page", text_page["slice_id"])
        self.assertEqual("view-model-renderer", text_page["ownership_tag"])
        self.assertTrue(text_page["source_scan"]["has_entry_decorator"])

        slider_page = entries[
            "raw_docs/phase06-ui-p7-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/sliderSample.cj"
        ]
        self.assertEqual("phase06-ui-p7-commonui-slider-page", slider_page["slice_id"])
        self.assertEqual("entry-page", slider_page["slice_kind"])
        self.assertIn("class SliderView", "\n".join(slider_page["source_scan"]["declared_types_head"]))

        tabs_page = entries[
            "raw_docs/phase06-ui-p7-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/tabsSample.cj"
        ]
        self.assertEqual("phase06-ui-p7-commonui-tabs-page", tabs_page["slice_id"])
        self.assertEqual("controller-owned-state", tabs_page["ownership_tag"])
        self.assertTrue(tabs_page["source_scan"]["has_component_decorator"])


    def test_manifest_can_expand_promoted_p7_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p7.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p7 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        text_page = entries[
            "raw_docs/phase06-ui-p7/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/textSample.cj"
        ]
        self.assertEqual("phase06-ui-p7-commonui-text-page", text_page["slice_id"])
        self.assertEqual("view-model-renderer", text_page["ownership_tag"])

        slider_page = entries[
            "raw_docs/phase06-ui-p7/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/sliderSample.cj"
        ]
        self.assertEqual("phase06-ui-p7-commonui-slider-page", slider_page["slice_id"])
        self.assertEqual("entry-page", slider_page["slice_kind"])

        tabs_page = entries[
            "raw_docs/phase06-ui-p7/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/tabsSample.cj"
        ]
        self.assertEqual("phase06-ui-p7-commonui-tabs-page", tabs_page["slice_id"])
        self.assertEqual("controller-owned-state", tabs_page["ownership_tag"])

    def test_manifest_can_expand_p8_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p8_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p8_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p8 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        button_page = entries[
            "raw_docs/phase06-ui-p8-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/buttonSample.cj"
        ]
        self.assertEqual("phase06-ui-p8-commonui-button-page", button_page["slice_id"])
        self.assertEqual("view-model-renderer", button_page["ownership_tag"])
        self.assertTrue(button_page["source_scan"]["has_builder_decorator"])
        self.assertIn("class ButtonView {", "\n".join(button_page["source_scan"]["declared_types_head"]))

        checkbox_page = entries[
            "raw_docs/phase06-ui-p8-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/checkBoxSample.cj"
        ]
        self.assertEqual("phase06-ui-p8-commonui-checkbox-page", checkbox_page["slice_id"])
        self.assertEqual("entry-page", checkbox_page["slice_kind"])
        self.assertTrue(checkbox_page["source_scan"]["has_component_decorator"])
        self.assertIn("class CheckBoxView {", "\n".join(checkbox_page["source_scan"]["declared_types_head"]))

        address_exchange_page = entries[
            "raw_docs/phase06-ui-p8-draft/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/addressexchange/src/main/cangjie/src/view/AddressExchangeView.cj"
        ]
        self.assertEqual("phase06-ui-p8-address-exchange-page", address_exchange_page["slice_id"])
        self.assertEqual("view-model-renderer", address_exchange_page["ownership_tag"])
        self.assertTrue(address_exchange_page["source_scan"]["has_component_decorator"])
        self.assertIn(
            "public class AddressExchangeView {",
            "\n".join(address_exchange_page["source_scan"]["declared_types_head"]),
        )


    def test_manifest_can_expand_promoted_p8_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p8.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p8 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        button_page = entries[
            "raw_docs/phase06-ui-p8/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/buttonSample.cj"
        ]
        self.assertEqual("phase06-ui-p8-commonui-button-page", button_page["slice_id"])
        self.assertEqual("view-model-renderer", button_page["ownership_tag"])
        self.assertTrue(button_page["source_scan"]["has_builder_decorator"])

        checkbox_page = entries[
            "raw_docs/phase06-ui-p8/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/checkBoxSample.cj"
        ]
        self.assertEqual("phase06-ui-p8-commonui-checkbox-page", checkbox_page["slice_id"])
        self.assertEqual("entry-page", checkbox_page["slice_kind"])
        self.assertTrue(checkbox_page["source_scan"]["has_component_decorator"])

        address_exchange_page = entries[
            "raw_docs/phase06-ui-p8/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/addressexchange/src/main/cangjie/src/view/AddressExchangeView.cj"
        ]
        self.assertEqual("phase06-ui-p8-address-exchange-page", address_exchange_page["slice_id"])
        self.assertEqual("view-model-renderer", address_exchange_page["ownership_tag"])
        self.assertTrue(address_exchange_page["source_scan"]["has_component_decorator"])


    def test_manifest_can_expand_p9_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p9_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p9_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p9 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        swiper_page = entries[
            "raw_docs/phase06-ui-p9-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/swiperSample.cj"
        ]
        self.assertEqual("phase06-ui-p9-commonui-swiper-page", swiper_page["slice_id"])
        self.assertEqual("controller-owned-state", swiper_page["ownership_tag"])
        self.assertTrue(swiper_page["source_scan"]["has_entry_decorator"])
        self.assertIn("class SwiperView {", "\n".join(swiper_page["source_scan"]["declared_types_head"]))

        text_input_page = entries[
            "raw_docs/phase06-ui-p9-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/textInputSample.cj"
        ]
        self.assertEqual("phase06-ui-p9-commonui-text-input-page", text_input_page["slice_id"])
        self.assertEqual("view-model-renderer", text_input_page["ownership_tag"])
        self.assertTrue(text_input_page["source_scan"]["has_component_decorator"])
        self.assertIn("class TextInputView {", "\n".join(text_input_page["source_scan"]["declared_types_head"]))

        helloword_page = entries[
            "raw_docs/phase06-ui-p9-draft/HarmonyOS-Examples/01-HelloWord/entry/src/main/cangjie/src/index.cj"
        ]
        self.assertEqual("phase06-ui-p9-helloword-entry-page", helloword_page["slice_id"])
        self.assertEqual("entry-page", helloword_page["slice_kind"])
        self.assertTrue(helloword_page["source_scan"]["has_component_decorator"])
        self.assertIn("class EntryView {", "\n".join(helloword_page["source_scan"]["declared_types_head"]))


    def test_manifest_can_expand_promoted_p9_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p9.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p9 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        swiper_page = entries[
            "raw_docs/phase06-ui-p9/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/swiperSample.cj"
        ]
        self.assertEqual("phase06-ui-p9-commonui-swiper-page", swiper_page["slice_id"])
        self.assertEqual("controller-owned-state", swiper_page["ownership_tag"])
        self.assertTrue(swiper_page["source_scan"]["has_entry_decorator"])

        text_input_page = entries[
            "raw_docs/phase06-ui-p9/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/textInputSample.cj"
        ]
        self.assertEqual("phase06-ui-p9-commonui-text-input-page", text_input_page["slice_id"])
        self.assertEqual("view-model-renderer", text_input_page["ownership_tag"])
        self.assertTrue(text_input_page["source_scan"]["has_component_decorator"])

        helloword_page = entries[
            "raw_docs/phase06-ui-p9/HarmonyOS-Examples/01-HelloWord/entry/src/main/cangjie/src/index.cj"
        ]
        self.assertEqual("phase06-ui-p9-helloword-entry-page", helloword_page["slice_id"])
        self.assertEqual("entry-page", helloword_page["slice_kind"])
        self.assertTrue(helloword_page["source_scan"]["has_component_decorator"])


    def test_manifest_can_expand_p10_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p10_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p10_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p10 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        about_page = entries[
            "raw_docs/phase06-ui-p10-draft/HarmonyOS-Examples/Browser/entry/src/main/cangjie/src/about.cj"
        ]
        self.assertEqual("phase06-ui-p10-browser-about-page", about_page["slice_id"])
        self.assertEqual("view-model-renderer", about_page["ownership_tag"])
        self.assertTrue(about_page["source_scan"]["has_entry_decorator"])
        self.assertIn("class About {", "\n".join(about_page["source_scan"]["declared_types_head"]))

        browser_main_page = entries[
            "raw_docs/phase06-ui-p10-draft/HarmonyOS-Examples/Browser/entry/src/main/cangjie/src/index.cj"
        ]
        self.assertEqual("phase06-ui-p10-browser-main-page", browser_main_page["slice_id"])
        self.assertEqual("controller-owned-state", browser_main_page["ownership_tag"])
        self.assertTrue(browser_main_page["source_scan"]["has_builder_decorator"])
        self.assertIn("class MainView {", "\n".join(browser_main_page["source_scan"]["declared_types_head"]))

        snake_page = entries[
            "raw_docs/phase06-ui-p10-draft/HarmonyOS-Examples/18-WebViewGame/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("phase06-ui-p10-webviewgame-snake-page", snake_page["slice_id"])
        self.assertEqual("controller-owned-state", snake_page["ownership_tag"])
        self.assertTrue(snake_page["source_scan"]["has_builder_decorator"])
        self.assertIn("class SnakeGame {", "\n".join(snake_page["source_scan"]["declared_types_head"]))


    def test_manifest_can_expand_promoted_p10_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p10.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p10 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        about_page = entries[
            "raw_docs/phase06-ui-p10/HarmonyOS-Examples/Browser/entry/src/main/cangjie/src/about.cj"
        ]
        self.assertEqual("phase06-ui-p10-browser-about-page", about_page["slice_id"])
        self.assertEqual("view-model-renderer", about_page["ownership_tag"])
        self.assertTrue(about_page["source_scan"]["has_entry_decorator"])

        browser_main_page = entries[
            "raw_docs/phase06-ui-p10/HarmonyOS-Examples/Browser/entry/src/main/cangjie/src/index.cj"
        ]
        self.assertEqual("phase06-ui-p10-browser-main-page", browser_main_page["slice_id"])
        self.assertEqual("controller-owned-state", browser_main_page["ownership_tag"])
        self.assertTrue(browser_main_page["source_scan"]["has_builder_decorator"])

        snake_page = entries[
            "raw_docs/phase06-ui-p10/HarmonyOS-Examples/18-WebViewGame/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("phase06-ui-p10-webviewgame-snake-page", snake_page["slice_id"])
        self.assertEqual("controller-owned-state", snake_page["ownership_tag"])
        self.assertTrue(snake_page["source_scan"]["has_builder_decorator"])


    def test_manifest_can_expand_p11_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p11_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p11_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p11 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        opds_page = entries[
            "raw_docs/phase06-ui-p11-draft/HarmonyOS-Examples/OPDSClient/entry/src/main/cangjie/src/index.cj"
        ]
        self.assertEqual("phase06-ui-p11-opdsclient-entry-page", opds_page["slice_id"])
        self.assertEqual("controller-owned-state", opds_page["ownership_tag"])
        self.assertTrue(opds_page["source_scan"]["has_component_decorator"])
        self.assertIn("class MyView {", "\n".join(opds_page["source_scan"]["declared_types_head"]))

        particle_page = entries[
            "raw_docs/phase06-ui-p11-draft/HarmonyOS-Examples/ParticleEmission/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("phase06-ui-p11-particle-emission-page", particle_page["slice_id"])
        self.assertEqual("controller-owned-state", particle_page["ownership_tag"])
        self.assertTrue(particle_page["source_scan"]["has_entry_decorator"])
        self.assertIn("class EntryView {", "\n".join(particle_page["source_scan"]["declared_types_head"]))

        date_page = entries[
            "raw_docs/phase06-ui-p11-draft/HarmonyOS-Examples/14-DateSelection/entry/src/main/cangjie/pages/MainPage.cj"
        ]
        self.assertEqual("phase06-ui-p11-date-selection-main-page", date_page["slice_id"])
        self.assertEqual("controller-owned-state", date_page["ownership_tag"])
        self.assertTrue(date_page["source_scan"]["has_builder_decorator"])
        self.assertIn("class MainPage {", "\n".join(date_page["source_scan"]["declared_types_head"]))


    def test_manifest_can_expand_promoted_p11_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p11.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p11 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(3, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3}, manifest["summary"]["structure_counts"])

        opds_page = entries[
            "raw_docs/phase06-ui-p11/HarmonyOS-Examples/OPDSClient/entry/src/main/cangjie/src/index.cj"
        ]
        self.assertEqual("phase06-ui-p11-opdsclient-entry-page", opds_page["slice_id"])
        self.assertEqual("controller-owned-state", opds_page["ownership_tag"])
        self.assertTrue(opds_page["source_scan"]["has_component_decorator"])

        particle_page = entries[
            "raw_docs/phase06-ui-p11/HarmonyOS-Examples/ParticleEmission/entry/src/main/cangjie/index.cj"
        ]
        self.assertEqual("phase06-ui-p11-particle-emission-page", particle_page["slice_id"])
        self.assertEqual("controller-owned-state", particle_page["ownership_tag"])
        self.assertTrue(particle_page["source_scan"]["has_entry_decorator"])

        date_page = entries[
            "raw_docs/phase06-ui-p11/HarmonyOS-Examples/14-DateSelection/entry/src/main/cangjie/pages/MainPage.cj"
        ]
        self.assertEqual("phase06-ui-p11-date-selection-main-page", date_page["slice_id"])
        self.assertEqual("controller-owned-state", date_page["ownership_tag"])
        self.assertTrue(date_page["source_scan"]["has_builder_decorator"])


    def test_manifest_can_expand_p12_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p12_draft.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest_p12_draft.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("p12 draft manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(4, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3, "component": 1}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3, "rich-component": 1}, manifest["summary"]["structure_counts"])

        calendar_page = entries[
            "raw_docs/phase06-ui-p12-draft/HarmonyOS-Examples/Silkui/entry/src/main/cangjie/src/pages/calendar.cj"
        ]
        self.assertEqual("phase06-ui-p12-silkui-calendar-page", calendar_page["slice_id"])
        self.assertEqual("view-model-renderer", calendar_page["ownership_tag"])
        self.assertTrue(calendar_page["source_scan"]["has_entry_decorator"])
        self.assertTrue(any("CalendarPage" in line for line in calendar_page["source_scan"]["declared_types_head"]))

        about_page = entries[
            "raw_docs/phase06-ui-p12-draft/HarmonyOS-Examples/07-DeepSeek/entry/src/main/cangjie/src/pages/about_view.cj"
        ]
        self.assertEqual("phase06-ui-p12-deepseek-about-view-page", about_page["slice_id"])
        self.assertEqual("view-model-renderer", about_page["ownership_tag"])
        self.assertTrue(about_page["source_scan"]["has_entry_decorator"])
        self.assertTrue(any("aboutView" in line for line in about_page["source_scan"]["declared_types_head"]))

        charging_page = entries[
            "raw_docs/phase06-ui-p12-draft/HarmonyOS-Examples/ChargingUI/entry/src/main/cangjie/src/index.cj"
        ]
        self.assertEqual("phase06-ui-p12-chargingui-entry-page", charging_page["slice_id"])
        self.assertEqual("controller-owned-state", charging_page["ownership_tag"])
        self.assertTrue(charging_page["source_scan"]["has_entry_decorator"])
        self.assertTrue(any("EntryView" in line for line in charging_page["source_scan"]["declared_types_head"]))

        electric_component = entries[
            "raw_docs/phase06-ui-p12-draft/HarmonyOS-Examples/ChargingUI/entry/src/main/cangjie/src/electric_quantity.cj"
        ]
        self.assertEqual("phase06-ui-p12-chargingui-electric-quantity-component", electric_component["slice_id"])
        self.assertEqual("component", electric_component["target_role"])
        self.assertEqual("rich-component", electric_component["structure_tag"])
        self.assertTrue(electric_component["source_scan"]["has_component_decorator"])
        self.assertTrue(any("ElectricQuantity" in line for line in electric_component["source_scan"]["declared_types_head"]))


    def test_manifest_can_expand_promoted_p12_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p12.json"
        sample_manifest_path = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest("promoted p12 manifest chain not present in workspace")

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry["repo_local_path"]: entry for entry in manifest["entries"]}

        self.assertEqual(4, manifest["summary"]["slice_count"])
        self.assertEqual({"page": 3, "component": 1}, manifest["summary"]["role_counts"])
        self.assertEqual({"page-shell": 3, "rich-component": 1}, manifest["summary"]["structure_counts"])

        calendar_page = entries[
            "raw_docs/phase06-ui-p12/HarmonyOS-Examples/Silkui/entry/src/main/cangjie/src/pages/calendar.cj"
        ]
        self.assertEqual("phase06-ui-p12-silkui-calendar-page", calendar_page["slice_id"])
        self.assertEqual("view-model-renderer", calendar_page["ownership_tag"])
        self.assertTrue(calendar_page["source_scan"]["has_entry_decorator"])

        about_page = entries[
            "raw_docs/phase06-ui-p12/HarmonyOS-Examples/07-DeepSeek/entry/src/main/cangjie/src/pages/about_view.cj"
        ]
        self.assertEqual("phase06-ui-p12-deepseek-about-view-page", about_page["slice_id"])
        self.assertEqual("view-model-renderer", about_page["ownership_tag"])
        self.assertTrue(about_page["source_scan"]["has_entry_decorator"])

        charging_page = entries[
            "raw_docs/phase06-ui-p12/HarmonyOS-Examples/ChargingUI/entry/src/main/cangjie/src/index.cj"
        ]
        self.assertEqual("phase06-ui-p12-chargingui-entry-page", charging_page["slice_id"])
        self.assertEqual("controller-owned-state", charging_page["ownership_tag"])
        self.assertTrue(charging_page["source_scan"]["has_entry_decorator"])

        electric_component = entries[
            "raw_docs/phase06-ui-p12/HarmonyOS-Examples/ChargingUI/entry/src/main/cangjie/src/electric_quantity.cj"
        ]
        self.assertEqual("phase06-ui-p12-chargingui-electric-quantity-component", electric_component["slice_id"])
        self.assertEqual("component", electric_component["target_role"])
        self.assertEqual("rich-component", electric_component["structure_tag"])
        self.assertTrue(electric_component["source_scan"]["has_component_decorator"])




    def test_manifest_can_expand_p13_draft_source_corpus_with_new_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p13_draft.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest_p13_draft.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('p13 draft manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(6, manifest['summary']['slice_count'])
        self.assertEqual({'page': 3, 'viewmodel': 3}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 3, 'rich-component': 3}, manifest['summary']['structure_counts'])

        commonui_entry = entries[
            'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p13-commonui-entry-page', commonui_entry['slice_id'])
        self.assertEqual('view-model-renderer', commonui_entry['ownership_tag'])
        self.assertTrue(commonui_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('EntryView' in line for line in commonui_entry['source_scan']['declared_types_head']))

        clock_page = entries[
            'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/11-Clock/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p13-clock-entry-page', clock_page['slice_id'])
        self.assertEqual('page', clock_page['target_role'])
        self.assertEqual('controller-owned-state', clock_page['ownership_tag'])
        self.assertTrue(clock_page['source_scan']['has_entry_decorator'])

        clock_helper = entries[
            'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/11-Clock/entry/src/main/cangjie/src/utils/clock.cj'
        ]
        self.assertEqual('phase06-ui-p13-clock-renderer-helper', clock_helper['slice_id'])
        self.assertEqual('viewmodel', clock_helper['target_role'])
        self.assertEqual('rich-component', clock_helper['structure_tag'])
        self.assertFalse(clock_helper['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class Clock' in line for line in clock_helper['source_scan']['declared_types_head']))

        simpledraw_page = entries[
            'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p13-simpledraw-entry-page', simpledraw_page['slice_id'])
        self.assertEqual('controller-owned-state', simpledraw_page['ownership_tag'])
        self.assertTrue(simpledraw_page['source_scan']['has_entry_decorator'])

        dgeometry_model = entries[
            'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/DGeometry.cj'
        ]
        self.assertEqual('phase06-ui-p13-simpledraw-dgeometry-model', dgeometry_model['slice_id'])
        self.assertEqual('viewmodel', dgeometry_model['target_role'])
        self.assertEqual('controller-owned-state', dgeometry_model['ownership_tag'])
        self.assertTrue(any('public class DPoint' in line for line in dgeometry_model['source_scan']['declared_types_head']))

        geometry_model = entries[
            'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/Geometry.cj'
        ]
        self.assertEqual('phase06-ui-p13-simpledraw-geometry-math-model', geometry_model['slice_id'])
        self.assertEqual('viewmodel', geometry_model['target_role'])
        self.assertEqual('view-model-renderer', geometry_model['ownership_tag'])
        self.assertTrue(any('public class 点' in line for line in geometry_model['source_scan']['declared_types_head']))


    def test_manifest_can_expand_promoted_p13_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p13.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('promoted p13 manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(6, manifest['summary']['slice_count'])
        self.assertEqual({'page': 3, 'viewmodel': 3}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 3, 'rich-component': 3}, manifest['summary']['structure_counts'])

        commonui_entry = entries[
            'raw_docs/phase06-ui-p13/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p13-commonui-entry-page', commonui_entry['slice_id'])
        self.assertEqual('view-model-renderer', commonui_entry['ownership_tag'])
        self.assertTrue(commonui_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('EntryView' in line for line in commonui_entry['source_scan']['declared_types_head']))

        clock_page = entries[
            'raw_docs/phase06-ui-p13/HarmonyOS-Examples/11-Clock/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p13-clock-entry-page', clock_page['slice_id'])
        self.assertEqual('page', clock_page['target_role'])
        self.assertEqual('controller-owned-state', clock_page['ownership_tag'])
        self.assertTrue(clock_page['source_scan']['has_entry_decorator'])

        clock_helper = entries[
            'raw_docs/phase06-ui-p13/HarmonyOS-Examples/11-Clock/entry/src/main/cangjie/src/utils/clock.cj'
        ]
        self.assertEqual('phase06-ui-p13-clock-renderer-helper', clock_helper['slice_id'])
        self.assertEqual('viewmodel', clock_helper['target_role'])
        self.assertEqual('rich-component', clock_helper['structure_tag'])
        self.assertFalse(clock_helper['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class Clock' in line for line in clock_helper['source_scan']['declared_types_head']))

        simpledraw_page = entries[
            'raw_docs/phase06-ui-p13/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p13-simpledraw-entry-page', simpledraw_page['slice_id'])
        self.assertEqual('controller-owned-state', simpledraw_page['ownership_tag'])
        self.assertTrue(simpledraw_page['source_scan']['has_entry_decorator'])

        dgeometry_model = entries[
            'raw_docs/phase06-ui-p13/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/DGeometry.cj'
        ]
        self.assertEqual('phase06-ui-p13-simpledraw-dgeometry-model', dgeometry_model['slice_id'])
        self.assertEqual('viewmodel', dgeometry_model['target_role'])
        self.assertEqual('controller-owned-state', dgeometry_model['ownership_tag'])
        self.assertTrue(any('public class DPoint' in line for line in dgeometry_model['source_scan']['declared_types_head']))

        geometry_model = entries[
            'raw_docs/phase06-ui-p13/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/Geometry.cj'
        ]
        self.assertEqual('phase06-ui-p13-simpledraw-geometry-math-model', geometry_model['slice_id'])
        self.assertEqual('viewmodel', geometry_model['target_role'])
        self.assertEqual('view-model-renderer', geometry_model['ownership_tag'])
        self.assertTrue(any('public class 点' in line for line in geometry_model['source_scan']['declared_types_head']))


    def test_manifest_can_expand_promoted_p14_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p14.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('promoted p14 manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(9, manifest['summary']['slice_count'])
        self.assertEqual({'page': 3, 'component': 2, 'viewmodel': 4}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 3, 'rich-component': 6}, manifest['summary']['structure_counts'])

        calendar_page = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Examples/19-CangjiexArkTS/CalendarManager/entry/src/main/cangjie/views/EntryView.cj'
        ]
        self.assertEqual('phase06-ui-p14-calendar-manager-entry-page', calendar_page['slice_id'])
        self.assertEqual('view-model-renderer', calendar_page['ownership_tag'])
        self.assertTrue(calendar_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in calendar_page['source_scan']['declared_types_head']))

        applog_helper = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Examples/19-CangjiexArkTS/CalendarManager/entry/src/main/cangjie/applog/Applog.cj'
        ]
        self.assertEqual('phase06-ui-p14-calendar-manager-applog-helper', applog_helper['slice_id'])
        self.assertEqual('viewmodel', applog_helper['target_role'])
        self.assertEqual('view-model-renderer', applog_helper['ownership_tag'])
        self.assertFalse(applog_helper['source_scan']['has_component_decorator'])

        linkage_page = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/secondarylinkage/src/main/cangjie/src/SecondaryLinkageExample.cj'
        ]
        self.assertEqual('phase06-ui-p14-secondary-linkage-page', linkage_page['slice_id'])
        self.assertEqual('controller-owned-state', linkage_page['ownership_tag'])
        self.assertEqual(['mixed-app-pattern'], linkage_page['sample_scope_tags'])
        self.assertTrue(linkage_page['source_scan']['has_entry_decorator'])

        linkage_model = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/secondarylinkage/src/main/cangjie/src/DataType.cj'
        ]
        self.assertEqual('phase06-ui-p14-secondary-linkage-data-model', linkage_model['slice_id'])
        self.assertEqual('viewmodel', linkage_model['target_role'])
        self.assertEqual('controller-owned-state', linkage_model['ownership_tag'])
        self.assertTrue(any('public class MyDataSource' in line for line in linkage_model['source_scan']['declared_types_head']))

        function_description = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/common/utils/src/main/cangjie/src/component/FunctionDescription.cj'
        ]
        self.assertEqual('phase06-ui-p14-secondary-linkage-function-description-component', function_description['slice_id'])
        self.assertEqual('component', function_description['target_role'])
        self.assertEqual('rich-component', function_description['structure_tag'])
        self.assertTrue(function_description['source_scan']['has_component_decorator'])

        todo_page = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/pages/ToDoList.cj'
        ]
        self.assertEqual('phase06-ui-p14-pending-items-todo-list-page', todo_page['slice_id'])
        self.assertEqual(['gesture-component'], todo_page['interaction_tags'])
        self.assertTrue(todo_page['source_scan']['has_entry_decorator'])

        todo_item = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/pages/ToDoListItem.cj'
        ]
        self.assertEqual('phase06-ui-p14-pending-items-list-item-component', todo_item['slice_id'])
        self.assertEqual('component', todo_item['target_role'])
        self.assertTrue(todo_item['source_scan']['has_component_decorator'])

        style_config = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/model/ConstData.cj'
        ]
        self.assertEqual('phase06-ui-p14-pending-items-style-config-model', style_config['slice_id'])
        self.assertEqual('viewmodel', style_config['target_role'])
        self.assertEqual('view-model-renderer', style_config['ownership_tag'])
        self.assertTrue(any('public class StyleConfig' in line for line in style_config['source_scan']['declared_types_head']))

        todo_model = entries[
            'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/model/ToDo.cj'
        ]
        self.assertEqual('phase06-ui-p14-pending-items-todo-model', todo_model['slice_id'])
        self.assertEqual('viewmodel', todo_model['target_role'])
        self.assertEqual('controller-owned-state', todo_model['ownership_tag'])
        self.assertTrue(any('public class ToDo' in line for line in todo_model['source_scan']['declared_types_head']))



    def test_manifest_can_expand_promoted_p15_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p15.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('promoted p15 manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(8, manifest['summary']['slice_count'])
        self.assertEqual({'page': 1, 'component': 3, 'viewmodel': 4}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 1, 'rich-component': 7}, manifest['summary']['structure_counts'])

        pinwheel_page = entries[
            'raw_docs/phase06-ui-p15/HarmonyOS-Examples/12-Pinwheel/entry/src/main/cangjie/index.cj'
        ]
        self.assertEqual('phase06-ui-p15-pinwheel-entry-page', pinwheel_page['slice_id'])
        self.assertEqual('controller-owned-state', pinwheel_page['ownership_tag'])
        self.assertTrue(pinwheel_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in pinwheel_page['source_scan']['declared_types_head']))

        pinwheel_constants = entries[
            'raw_docs/phase06-ui-p15/HarmonyOS-Examples/12-Pinwheel/entry/src/main/cangjie/common/Constants.cj'
        ]
        self.assertEqual('phase06-ui-p15-pinwheel-constants-model', pinwheel_constants['slice_id'])
        self.assertEqual('viewmodel', pinwheel_constants['target_role'])
        self.assertEqual('view-model-renderer', pinwheel_constants['ownership_tag'])
        self.assertTrue(any('public class Constants' in line for line in pinwheel_constants['source_scan']['declared_types_head']))

        panel_component = entries[
            'raw_docs/phase06-ui-p15/HarmonyOS-Examples/12-Pinwheel/entry/src/main/cangjie/view/PanelComponent.cj'
        ]
        self.assertEqual('phase06-ui-p15-pinwheel-panel-component', panel_component['slice_id'])
        self.assertEqual('component', panel_component['target_role'])
        self.assertEqual('controller-owned-state', panel_component['ownership_tag'])
        self.assertTrue(panel_component['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class PanelComponent' in line for line in panel_component['source_scan']['declared_types_head']))

        search_component = entries[
            'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/searchcomponent/src/main/cangjie/src/SearchComponent.cj'
        ]
        self.assertEqual('phase06-ui-p15-search-component', search_component['slice_id'])
        self.assertEqual('component', search_component['target_role'])
        self.assertEqual('controller-owned-state', search_component['ownership_tag'])
        self.assertTrue(search_component['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class SearchComponent' in line for line in search_component['source_scan']['declared_types_head']))

        functional_scenes = entries[
            'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/functionalscenes/src/main/cangjie/src/FunctionalScenes.cj'
        ]
        self.assertEqual('phase06-ui-p15-functional-scenes-component', functional_scenes['slice_id'])
        self.assertEqual('component', functional_scenes['target_role'])
        self.assertEqual('controller-owned-state', functional_scenes['ownership_tag'])
        self.assertTrue(functional_scenes['source_scan']['has_component_decorator'])
        self.assertTrue(functional_scenes['source_scan']['has_builder_decorator'])
        self.assertTrue(any('public class FunctionalScenes' in line for line in functional_scenes['source_scan']['declared_types_head']))

        list_data_source = entries[
            'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/functionalscenes/src/main/cangjie/src/model/ListDataSource.cj'
        ]
        self.assertEqual('phase06-ui-p15-functional-scenes-data-source-model', list_data_source['slice_id'])
        self.assertEqual('viewmodel', list_data_source['target_role'])
        self.assertEqual('controller-owned-state', list_data_source['ownership_tag'])
        self.assertTrue(any('public class ListDataSource' in line for line in list_data_source['source_scan']['declared_types_head']))

        scene_module_info = entries[
            'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/functionalscenes/src/main/cangjie/src/model/SceneModuleInfo.cj'
        ]
        self.assertEqual('phase06-ui-p15-functional-scenes-scene-module-model', scene_module_info['slice_id'])
        self.assertEqual('viewmodel', scene_module_info['target_role'])
        self.assertEqual('view-model-renderer', scene_module_info['ownership_tag'])
        self.assertTrue(any('public class SceneModuleInfo' in line for line in scene_module_info['source_scan']['declared_types_head']))

        tabs_data = entries[
            'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/functionalscenes/src/main/cangjie/src/model/TabsData.cj'
        ]
        self.assertEqual('phase06-ui-p15-functional-scenes-tabs-model', tabs_data['slice_id'])
        self.assertEqual('viewmodel', tabs_data['target_role'])
        self.assertEqual('view-model-renderer', tabs_data['ownership_tag'])
        self.assertTrue(any('public class TabDataModel' in line for line in tabs_data['source_scan']['declared_types_head']))

    def test_manifest_can_expand_promoted_p16_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p16.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('promoted p16 manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(13, manifest['summary']['slice_count'])
        self.assertEqual({'page': 3, 'component': 6, 'viewmodel': 4}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 3, 'rich-component': 10}, manifest['summary']['structure_counts'])

        bank_page = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/BankUI/entry/src/main/cangjie/src/Page/search.cj'
        ]
        self.assertEqual('phase06-ui-p16-bankui-search-page', bank_page['slice_id'])
        self.assertEqual('page', bank_page['target_role'])
        self.assertEqual('controller-owned-state', bank_page['ownership_tag'])
        self.assertTrue(bank_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('public class Search' in line for line in bank_page['source_scan']['declared_types_head']))

        search_input = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/BankUI/entry/src/main/cangjie/src/Component/searchInput.cj'
        ]
        self.assertEqual('phase06-ui-p16-bankui-search-input-component', search_input['slice_id'])
        self.assertEqual('component', search_input['target_role'])
        self.assertEqual('controller-owned-state', search_input['ownership_tag'])
        self.assertTrue(search_input['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class SearchInput' in line for line in search_input['source_scan']['declared_types_head']))

        canvas_page = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/CanvasPoker/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p16-canvas-poker-entry-page', canvas_page['slice_id'])
        self.assertEqual('page', canvas_page['target_role'])
        self.assertEqual('controller-owned-state', canvas_page['ownership_tag'])
        self.assertTrue(canvas_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in canvas_page['source_scan']['declared_types_head']))

        canvas_renderer = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/CanvasPoker/entry/src/main/cangjie/src/card/cards.cj'
        ]
        self.assertEqual('phase06-ui-p16-canvas-poker-card-renderer-model', canvas_renderer['slice_id'])
        self.assertEqual('viewmodel', canvas_renderer['target_role'])
        self.assertEqual('view-model-renderer', canvas_renderer['ownership_tag'])
        self.assertEqual([], canvas_renderer['source_scan']['declared_types_head'])

        canvas_constants = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/CanvasPoker/entry/src/main/cangjie/src/card/const.cj'
        ]
        self.assertEqual('phase06-ui-p16-canvas-poker-card-const-model', canvas_constants['slice_id'])
        self.assertEqual('viewmodel', canvas_constants['target_role'])
        self.assertEqual('view-model-renderer', canvas_constants['ownership_tag'])
        self.assertEqual([], canvas_constants['source_scan']['declared_types_head'])

        color_page = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/index.cj'
        ]
        self.assertEqual('phase06-ui-p16-color-picker-entry-page', color_page['slice_id'])
        self.assertEqual('page', color_page['target_role'])
        self.assertEqual('controller-owned-state', color_page['ownership_tag'])
        self.assertTrue(color_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in color_page['source_scan']['declared_types_head']))

        color_picker = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/color_picker.cj'
        ]
        self.assertEqual('phase06-ui-p16-color-picker-component', color_picker['slice_id'])
        self.assertEqual('component', color_picker['target_role'])
        self.assertEqual('controller-owned-state', color_picker['ownership_tag'])
        self.assertTrue(color_picker['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class ColorPicker' in line for line in color_picker['source_scan']['declared_types_head']))

        color_slider = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/color_slider.cj'
        ]
        self.assertEqual('phase06-ui-p16-color-slider-component', color_slider['slice_id'])
        self.assertEqual('component', color_slider['target_role'])
        self.assertEqual('controller-owned-state', color_slider['ownership_tag'])
        self.assertTrue(color_slider['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class ColorSlider' in line for line in color_slider['source_scan']['declared_types_head']))

        color_palette = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/color_palette.cj'
        ]
        self.assertEqual('phase06-ui-p16-color-palette-component', color_palette['slice_id'])
        self.assertEqual('component', color_palette['target_role'])
        self.assertEqual('controller-owned-state', color_palette['ownership_tag'])
        self.assertTrue(color_palette['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class ColorPalette' in line for line in color_palette['source_scan']['declared_types_head']))

        color_utils = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/color_utils.cj'
        ]
        self.assertEqual('phase06-ui-p16-color-utils-model', color_utils['slice_id'])
        self.assertEqual('viewmodel', color_utils['target_role'])
        self.assertEqual('view-model-renderer', color_utils['ownership_tag'])
        self.assertTrue(any('public class ColorUtils' in line for line in color_utils['source_scan']['declared_types_head']))

        hsv_model = entries[
            'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/hsv.cj'
        ]
        self.assertEqual('phase06-ui-p16-hsv-model', hsv_model['slice_id'])
        self.assertEqual('viewmodel', hsv_model['target_role'])
        self.assertEqual('controller-owned-state', hsv_model['ownership_tag'])
        self.assertTrue(any('public class HSV' in line for line in hsv_model['source_scan']['declared_types_head']))


    def test_manifest_can_expand_promoted_p17_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p17.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('promoted p17 manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(13, manifest['summary']['slice_count'])
        self.assertEqual({'page': 3, 'component': 4, 'viewmodel': 6}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 3, 'rich-component': 10}, manifest['summary']['structure_counts'])

        game_page = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/Game2048/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p17-game2048-entry-page', game_page['slice_id'])
        self.assertEqual('page', game_page['target_role'])
        self.assertEqual('controller-owned-state', game_page['ownership_tag'])
        self.assertTrue(game_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class MyView' in line for line in game_page['source_scan']['declared_types_head']))

        puzzle_model = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/Game2048/entry/src/main/cangjie/src/core/puzzle.cj'
        ]
        self.assertEqual('phase06-ui-p17-game2048-puzzle-model', puzzle_model['slice_id'])
        self.assertEqual('viewmodel', puzzle_model['target_role'])
        self.assertEqual('controller-owned-state', puzzle_model['ownership_tag'])
        self.assertTrue(any('public class Puzzle' in line for line in puzzle_model['source_scan']['declared_types_head']))

        score_component = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/Game2048/entry/src/main/cangjie/src/widget/common.cj'
        ]
        self.assertEqual('phase06-ui-p17-game2048-score-component', score_component['slice_id'])
        self.assertEqual('component', score_component['target_role'])
        self.assertEqual('view-model-renderer', score_component['ownership_tag'])
        self.assertTrue(score_component['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class Score' in line for line in score_component['source_scan']['declared_types_head']))

        calculator_page = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p17-pretty-calculator-entry-page', calculator_page['slice_id'])
        self.assertEqual('page', calculator_page['target_role'])
        self.assertEqual('controller-owned-state', calculator_page['ownership_tag'])
        self.assertTrue(calculator_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class HomeView' in line for line in calculator_page['source_scan']['declared_types_head']))

        keyboard_component = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/components/keyboard.cj'
        ]
        self.assertEqual('phase06-ui-p17-pretty-calculator-keyboard-component', keyboard_component['slice_id'])
        self.assertEqual('component', keyboard_component['target_role'])
        self.assertEqual('controller-owned-state', keyboard_component['ownership_tag'])
        self.assertTrue(keyboard_component['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class Keyboard' in line for line in keyboard_component['source_scan']['declared_types_head']))

        theme_model = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/components/theme.cj'
        ]
        self.assertEqual('phase06-ui-p17-pretty-calculator-theme-model', theme_model['slice_id'])
        self.assertEqual('viewmodel', theme_model['target_role'])
        self.assertEqual('view-model-renderer', theme_model['ownership_tag'])
        self.assertTrue(any('public class Theme' in line for line in theme_model['source_scan']['declared_types_head']))

        cube_page = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p17-cube-entry-page', cube_page['slice_id'])
        self.assertEqual('page', cube_page['target_role'])
        self.assertEqual('controller-owned-state', cube_page['ownership_tag'])
        self.assertTrue(cube_page['source_scan']['has_entry_decorator'])
        self.assertTrue(cube_page['source_scan']['has_builder_decorator'])
        self.assertTrue(any('class EntryView' in line for line in cube_page['source_scan']['declared_types_head']))

        cube_model = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/cube/cube.cj'
        ]
        self.assertEqual('phase06-ui-p17-cube-model', cube_model['slice_id'])
        self.assertEqual('viewmodel', cube_model['target_role'])
        self.assertEqual('controller-owned-state', cube_model['ownership_tag'])
        self.assertTrue(any('public class Cube' in line for line in cube_model['source_scan']['declared_types_head']))

        matrix_model = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/cube/matrix.cj'
        ]
        self.assertEqual('phase06-ui-p17-cube-matrix-model', matrix_model['slice_id'])
        self.assertEqual('viewmodel', matrix_model['target_role'])
        self.assertEqual('view-model-renderer', matrix_model['ownership_tag'])
        self.assertEqual([], matrix_model['source_scan']['declared_types_head'])

        rotation_model = entries[
            'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/cube/rotation.cj'
        ]
        self.assertEqual('phase06-ui-p17-cube-rotation-model', rotation_model['slice_id'])
        self.assertEqual('viewmodel', rotation_model['target_role'])
        self.assertEqual('view-model-renderer', rotation_model['ownership_tag'])
        self.assertEqual([], rotation_model['source_scan']['declared_types_head'])


    # P19 regular mechanical-readiness test begin
    def test_manifest_can_expand_promoted_p19_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p19.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('promoted p19 manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(51, manifest['summary']['slice_count'])
        self.assertEqual({'page': 4, 'component': 28, 'viewmodel': 19}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 4, 'rich-component': 47}, manifest['summary']['structure_counts'])

        slide_page = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/index.cj'
        ]
        self.assertEqual('phase06-ui-p19-slide-ui-entry-page', slide_page['slice_id'])
        self.assertEqual('page', slide_page['target_role'])
        self.assertEqual('controller-owned-state', slide_page['ownership_tag'])
        self.assertTrue(slide_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in slide_page['source_scan']['declared_types_head']))

        slide_ability = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/main_ability.cj'
        ]
        self.assertEqual('phase06-ui-p19-slide-ui-main-ability-model', slide_ability['slice_id'])
        self.assertEqual('viewmodel', slide_ability['target_role'])
        self.assertEqual('controller-owned-state', slide_ability['ownership_tag'])
        self.assertTrue(any('class MainAbility' in line for line in slide_ability['source_scan']['declared_types_head']))

        seat_page = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/index.cj'
        ]
        self.assertEqual('phase06-ui-p19-seat-selection-entry-page', seat_page['slice_id'])
        self.assertEqual('page', seat_page['target_role'])
        self.assertEqual('controller-owned-state', seat_page['ownership_tag'])
        self.assertTrue(seat_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in seat_page['source_scan']['declared_types_head']))

        seat_map = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/SeatMap.cj'
        ]
        self.assertEqual('phase06-ui-p19-seat-selection-seat-map-component', seat_map['slice_id'])
        self.assertEqual('component', seat_map['target_role'])
        self.assertEqual('controller-owned-state', seat_map['ownership_tag'])
        self.assertTrue(any('class SeatMap' in line for line in seat_map['source_scan']['declared_types_head']))

        seat_model = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/view_model/SeatSelection.cj'
        ]
        self.assertEqual('phase06-ui-p19-seat-selection-view-model', seat_model['slice_id'])
        self.assertEqual('viewmodel', seat_model['target_role'])
        self.assertEqual('controller-owned-state', seat_model['ownership_tag'])
        self.assertTrue(any('class SeatSelection' in line for line in seat_model['source_scan']['declared_types_head']))

        chat_page = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p19-chat-ui-entry-page', chat_page['slice_id'])
        self.assertEqual('page', chat_page['target_role'])
        self.assertEqual('controller-owned-state', chat_page['ownership_tag'])
        self.assertTrue(chat_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class IndexView' in line for line in chat_page['source_scan']['declared_types_head']))

        chat_view_page = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/pages/ChatView.cj'
        ]
        self.assertEqual('phase06-ui-p19-chat-ui-chat-view-page', chat_view_page['slice_id'])
        self.assertEqual('page', chat_view_page['target_role'])
        self.assertEqual('controller-owned-state', chat_view_page['ownership_tag'])
        self.assertTrue(chat_view_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class ChatView' in line for line in chat_view_page['source_scan']['declared_types_head']))

        chat_list = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/chat/ChatList.cj'
        ]
        self.assertEqual('phase06-ui-p19-chat-ui-chat-list-component', chat_list['slice_id'])
        self.assertEqual('component', chat_list['target_role'])
        self.assertEqual('controller-owned-state', chat_list['ownership_tag'])
        self.assertTrue(any('public class ChatList' in line for line in chat_list['source_scan']['declared_types_head']))

        store_model = entries[
            'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/global/store.cj'
        ]
        self.assertEqual('phase06-ui-p19-chat-ui-store-model', store_model['slice_id'])
        self.assertEqual('viewmodel', store_model['target_role'])
        self.assertEqual('controller-owned-state', store_model['ownership_tag'])
        self.assertTrue(any('public class DataStore' in line for line in store_model['source_scan']['declared_types_head']))
    # P19 regular mechanical-readiness test end

    # P20 regular mechanical-readiness test begin
    def test_manifest_can_expand_promoted_p20_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p20.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('promoted p20 manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(39, manifest['summary']['slice_count'])
        self.assertEqual({'page': 6, 'component': 14, 'viewmodel': 19}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 6, 'rich-component': 33}, manifest['summary']['structure_counts'])

        slowfeet_entry = entries[
            'raw_docs/phase06-ui-p20/HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p20-slowfeet-entry-page', slowfeet_entry['slice_id'])
        self.assertEqual('page', slowfeet_entry['target_role'])
        self.assertEqual('view-model-renderer', slowfeet_entry['ownership_tag'])
        self.assertTrue(slowfeet_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class MyView' in line for line in slowfeet_entry['source_scan']['declared_types_head']))

        slowfeet_chat = entries[
            'raw_docs/phase06-ui-p20/HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/Pages/chat.cj'
        ]
        self.assertEqual('phase06-ui-p20-slowfeet-chat-route-page', slowfeet_chat['slice_id'])
        self.assertEqual('page', slowfeet_chat['target_role'])
        self.assertEqual('controller-owned-state', slowfeet_chat['ownership_tag'])
        self.assertTrue(slowfeet_chat['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class ChatView' in line for line in slowfeet_chat['source_scan']['declared_types_head']))

        adaptive_entry = entries[
            'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p20-adaptive-ui-entry-page', adaptive_entry['slice_id'])
        self.assertEqual('controller-owned-state', adaptive_entry['ownership_tag'])
        self.assertTrue(adaptive_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in adaptive_entry['source_scan']['declared_types_head']))

        adaptive_panel = entries[
            'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/component/pannel.cj'
        ]
        self.assertEqual('phase06-ui-p20-adaptive-ui-panel-component', adaptive_panel['slice_id'])
        self.assertEqual('component', adaptive_panel['target_role'])
        self.assertEqual('controller-owned-state', adaptive_panel['ownership_tag'])
        self.assertTrue(adaptive_panel['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class Pannel' in line for line in adaptive_panel['source_scan']['declared_types_head']))

        order_entry = entries[
            'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p20-order-ui-entry-page', order_entry['slice_id'])
        self.assertEqual('page', order_entry['target_role'])
        self.assertEqual('controller-owned-state', order_entry['ownership_tag'])
        self.assertTrue(order_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class MyView' in line for line in order_entry['source_scan']['declared_types_head']))

        order_home = entries[
            'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/home.cj'
        ]
        self.assertEqual('phase06-ui-p20-order-ui-home-tabs-component', order_home['slice_id'])
        self.assertEqual('component', order_home['target_role'])
        self.assertEqual('controller-owned-state', order_home['ownership_tag'])
        self.assertTrue(order_home['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class Home' in line for line in order_home['source_scan']['declared_types_head']))

        order_message = entries[
            'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/message/message.cj'
        ]
        self.assertEqual('phase06-ui-p20-order-ui-message-tab-component', order_message['slice_id'])
        self.assertEqual('component', order_message['target_role'])
        self.assertEqual('view-model-renderer', order_message['ownership_tag'])
        self.assertTrue(order_message['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class Message' in line for line in order_message['source_scan']['declared_types_head']))

        order_window_util = entries[
            'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/utils/WindowUtil.cj'
        ]
        self.assertEqual('phase06-ui-p20-order-ui-window-util-helper', order_window_util['slice_id'])
        self.assertEqual('viewmodel', order_window_util['target_role'])
        self.assertEqual('controller-owned-state', order_window_util['ownership_tag'])
        self.assertTrue(any('public class WindowUtil' in line for line in order_window_util['source_scan']['declared_types_head']))
    # P20 regular mechanical-readiness test end

    # P21 regular mechanical-readiness test begin
    def test_manifest_can_expand_promoted_p21_source_corpus_with_regular_overrides(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p21.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('promoted p21 manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(56, manifest['summary']['slice_count'])
        self.assertEqual({'page': 7, 'component': 25, 'viewmodel': 24}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 7, 'rich-component': 49}, manifest['summary']['structure_counts'])

        ui_layout_entry = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/index.cj'
        ]
        self.assertEqual('phase06-ui-p21-ui-layout-entry-page', ui_layout_entry['slice_id'])
        self.assertEqual('page', ui_layout_entry['target_role'])
        self.assertEqual('controller-owned-state', ui_layout_entry['ownership_tag'])
        self.assertTrue(ui_layout_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in ui_layout_entry['source_scan']['declared_types_head']))

        list_bands = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/List/ListBands.cj'
        ]
        self.assertEqual('phase06-ui-p21-ui-layout-list-bands-component', list_bands['slice_id'])
        self.assertEqual('component', list_bands['target_role'])
        self.assertEqual('controller-owned-state', list_bands['ownership_tag'])
        self.assertTrue(list_bands['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class SimpleList' in line for line in list_bands['source_scan']['declared_types_head']))

        user_model = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/List/User.cj'
        ]
        self.assertEqual('phase06-ui-p21-ui-layout-user-model', user_model['slice_id'])
        self.assertEqual('viewmodel', user_model['target_role'])
        self.assertEqual('view-model-renderer', user_model['ownership_tag'])
        self.assertTrue(any('public class UserEntity' in line for line in user_model['source_scan']['declared_types_head']))

        stock_entry = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/index.cj'
        ]
        self.assertEqual('phase06-ui-p21-stock-chart-entry-page', stock_entry['slice_id'])
        self.assertEqual('page', stock_entry['target_role'])
        self.assertEqual('controller-owned-state', stock_entry['ownership_tag'])
        self.assertTrue(stock_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class EntryView' in line for line in stock_entry['source_scan']['declared_types_head']))

        timeline_view_model = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/viewmodels/TimeLineViewModel.cj'
        ]
        self.assertEqual('phase06-ui-p21-stock-chart-timeline-view-model', timeline_view_model['slice_id'])
        self.assertEqual('viewmodel', timeline_view_model['target_role'])
        self.assertEqual('controller-owned-state', timeline_view_model['ownership_tag'])
        self.assertTrue(any('public class TimeLineViewModel' in line for line in timeline_view_model['source_scan']['declared_types_head']))

        stock_content = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/Content.cj'
        ]
        self.assertEqual('phase06-ui-p21-stock-chart-content-component', stock_content['slice_id'])
        self.assertEqual('component', stock_content['target_role'])
        self.assertEqual('controller-owned-state', stock_content['ownership_tag'])
        self.assertTrue(stock_content['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class Content' in line for line in stock_content['source_scan']['declared_types_head']))

        waterfall_entry = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p21-waterfall-entry-page', waterfall_entry['slice_id'])
        self.assertEqual('page', waterfall_entry['target_role'])
        self.assertEqual('controller-owned-state', waterfall_entry['ownership_tag'])
        self.assertTrue(waterfall_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class IndexView' in line for line in waterfall_entry['source_scan']['declared_types_head']))

        cover_card = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/component/card/CoverCard.cj'
        ]
        self.assertEqual('phase06-ui-p21-waterfall-cover-card-component', cover_card['slice_id'])
        self.assertEqual('component', cover_card['target_role'])
        self.assertEqual('controller-owned-state', cover_card['ownership_tag'])
        self.assertTrue(cover_card['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class CoverCard' in line for line in cover_card['source_scan']['declared_types_head']))

        event_bus = entries[
            'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/event/EventBus.cj'
        ]
        self.assertEqual('phase06-ui-p21-waterfall-event-bus-model', event_bus['slice_id'])
        self.assertEqual('viewmodel', event_bus['target_role'])
        self.assertEqual('controller-owned-state', event_bus['ownership_tag'])
        self.assertTrue(any('public class EventBus' in line for line in event_bus['source_scan']['declared_types_head']))
    # P21 regular mechanical-readiness test end

    def test_manifest_can_expand_p22_source_corpus_with_post_p21_reserve_closures(self) -> None:
        source_corpus_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_source_corpus_p22.json'
        sample_manifest_path = PROJECT_ROOT / 'docs' / 'manifests' / 'phase06_ui_sample_manifest.json'
        if not source_corpus_path.exists() or not sample_manifest_path.exists():
            self.skipTest('p22 mechanical-ready manifest chain not present in workspace')

        manifest = builder.build_file_manifest(
            source_corpus_payload=builder.read_json(source_corpus_path),
            sample_manifest_payload=builder.read_json(sample_manifest_path),
            few_shot_pack_payload=builder.read_json(builder.DEFAULT_FEW_SHOT_PACK_PATH),
            repo_root=PROJECT_ROOT,
        )
        entries = {entry['repo_local_path']: entry for entry in manifest['entries']}

        self.assertEqual(35, manifest['summary']['slice_count'])
        self.assertEqual({'page': 3, 'component': 23, 'viewmodel': 9}, manifest['summary']['role_counts'])
        self.assertEqual({'page-shell': 3, 'rich-component': 32}, manifest['summary']['structure_counts'])

        ui_component_entry = entries[
            'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/index.cj'
        ]
        self.assertEqual('phase06-ui-p22-ui-component-gallery-entry-page', ui_component_entry['slice_id'])
        self.assertEqual('page', ui_component_entry['target_role'])
        self.assertEqual('view-model-renderer', ui_component_entry['ownership_tag'])
        self.assertTrue(ui_component_entry['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class IndexView' in line for line in ui_component_entry['source_scan']['declared_types_head']))

        music_player = entries[
            'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indexMusicPlayer.cj'
        ]
        self.assertEqual('phase06-ui-p22-ui-component-music-player-card-component', music_player['slice_id'])
        self.assertEqual('component', music_player['target_role'])
        self.assertEqual('controller-owned-state', music_player['ownership_tag'])
        self.assertTrue(music_player['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class IndexMusicPlayer' in line for line in music_player['source_scan']['declared_types_head']))

        data_source = entries[
            'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/utils/dataSource.cj'
        ]
        self.assertEqual('phase06-ui-p22-ui-component-data-source-helper', data_source['slice_id'])
        self.assertEqual('viewmodel', data_source['target_role'])
        self.assertEqual('view-model-renderer', data_source['ownership_tag'])
        self.assertTrue(any('public class MyDataSource' in line for line in data_source['source_scan']['declared_types_head']))

        text_page = entries[
            'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/pages/textSample.cj'
        ]
        self.assertEqual('phase06-ui-p22-ui-component-text-playground-page', text_page['slice_id'])
        self.assertEqual('page', text_page['target_role'])
        self.assertEqual('controller-owned-state', text_page['ownership_tag'])
        self.assertTrue(text_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class TextView' in line for line in text_page['source_scan']['declared_types_head']))

        text_page_global = entries[
            'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/pages/global.cj'
        ]
        self.assertEqual('phase06-ui-p22-ui-component-text-page-global-helper', text_page_global['slice_id'])
        self.assertEqual('viewmodel', text_page_global['target_role'])
        self.assertEqual('view-model-renderer', text_page_global['ownership_tag'])
        self.assertFalse(text_page_global['source_scan']['has_component_decorator'])
        self.assertFalse(text_page_global['source_scan']['declared_types_head'])

        font_style = entries[
            'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/font/fontStyle.cj'
        ]
        self.assertEqual('phase06-ui-p22-ui-component-font-style-bar-component', font_style['slice_id'])
        self.assertEqual('component', font_style['target_role'])
        self.assertEqual('controller-owned-state', font_style['ownership_tag'])
        self.assertTrue(font_style['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class FontStyleBar' in line for line in font_style['source_scan']['declared_types_head']))

        public_page = entries[
            'raw_docs/phase06-ui-p22/HarmonyOS-Examples/RouletteUI/entry/src/main/cangjie/src/public_page.cj'
        ]
        self.assertEqual('phase06-ui-p22-roulette-ui-public-page', public_page['slice_id'])
        self.assertEqual('page', public_page['target_role'])
        self.assertEqual('controller-owned-state', public_page['ownership_tag'])
        self.assertTrue(public_page['source_scan']['has_entry_decorator'])
        self.assertTrue(any('class PublicPage' in line for line in public_page['source_scan']['declared_types_head']))

        turntable_list = entries[
            'raw_docs/phase06-ui-p22/HarmonyOS-Examples/RouletteUI/entry/src/main/cangjie/src/common/component/turntable_list.cj'
        ]
        self.assertEqual('phase06-ui-p22-roulette-ui-turntable-list-component', turntable_list['slice_id'])
        self.assertEqual('component', turntable_list['target_role'])
        self.assertEqual('controller-owned-state', turntable_list['ownership_tag'])
        self.assertTrue(turntable_list['source_scan']['has_component_decorator'])
        self.assertTrue(any('public class TurnTableList' in line for line in turntable_list['source_scan']['declared_types_head']))
    # P22 regular mechanical-readiness test end

if __name__ == "__main__":
    unittest.main()
