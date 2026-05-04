from __future__ import annotations

import shlex
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest import mock


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import run_phase06_ui_prompt_pilot_batch as runner  # noqa: E402


class RunPhase06UiPromptPilotBatchTests(unittest.TestCase):
    def test_resolve_batch_root_prefers_manifest_artifact_root(self) -> None:
        manifest = {"selection_policy": {"artifact_root": "artifacts/ui_pilots/20260409-phase06-ui-pilot-next-stage"}}
        expected = runner.PROJECT_ROOT / "artifacts" / "ui_pilots" / "20260409-phase06-ui-pilot-next-stage" / "live_curator"
        self.assertEqual(expected, runner.resolve_batch_root(manifest))

    def test_select_entries_accepts_slice_ids_and_pilot_ids(self) -> None:
        entries = [
            {"pilot_id": "pilot-a", "slice_id": "slice-a"},
            {"pilot_id": "pilot-b", "slice_id": "slice-b"},
        ]
        selected = runner.select_entries(entries, pilot_ids=["pilot-b"], slice_ids=["slice-a"])
        self.assertEqual(["pilot-a", "pilot-b"], [item["pilot_id"] for item in selected])

    def test_ensure_explicit_tu_injects_ui_tags_when_missing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            base_path = root / "base.tu.json"
            explicit_path = root / "explicit.tu.json"
            original_project_root = runner.PROJECT_ROOT
            self.addCleanup(setattr, runner, "PROJECT_ROOT", original_project_root)
            runner.PROJECT_ROOT = root  # type: ignore[assignment]
            runner.write_json(
                base_path,
                {
                    "tu_id": "tu::demo",
                    "target": {"path": "pages/Demo.cj", "role": "page"},
                    "metadata": {},
                },
            )
            entry = {
                "pilot_id": "pilot-demo",
                "track_id": "page-shell-view-model-renderer",
                "target_role": "page",
                "selection_reason": "demo",
                "base_tu_json_path": "base.tu.json",
                "explicit_tu_json_path": "explicit.tu.json",
                "ui_prompt_tags": {
                    "structure_tag": "page-shell",
                    "ownership_tag": "view-model-renderer",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            }
            path = runner.ensure_explicit_tu(entry)
            payload = runner.read_json(path)
            self.assertEqual("page-shell", payload["target"]["ui_prompt_tags"]["structure_tag"])
            self.assertEqual("view-model-renderer", payload["metadata"]["phase06_ui_tags"]["ownership_tag"])
            self.assertFalse(explicit_path.samefile(base_path))

    def test_ensure_explicit_tu_bootstraps_base_tu_when_missing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            original_project_root = runner.PROJECT_ROOT
            self.addCleanup(setattr, runner, "PROJECT_ROOT", original_project_root)
            runner.PROJECT_ROOT = root  # type: ignore[assignment]
            bootstrap_code = (
                "from pathlib import Path; import json; "
                "Path('base.tu.json').write_text("
                "json.dumps({'tu_id': 'tu::bootstrap', 'target': {'path': 'pages/Demo.cj'}, 'metadata': {}}), "
                "encoding='utf-8')"
            )
            entry = {
                "pilot_id": "pilot-bootstrap",
                "track_id": "page-shell-view-model-renderer",
                "target_role": "page",
                "selection_reason": "bootstrap-demo",
                "base_tu_json_path": "base.tu.json",
                "explicit_tu_json_path": "explicit.tu.json",
                "pipeline_log_path": "pipeline.log",
                "pipeline_command": shlex.join([sys.executable, "-c", bootstrap_code]),
                "ui_prompt_tags": {
                    "structure_tag": "page-shell",
                    "ownership_tag": "view-model-renderer",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            }
            path = runner.ensure_explicit_tu(entry)
            self.assertTrue((root / "base.tu.json").exists())
            self.assertTrue((root / "pipeline.log").exists())
            payload = runner.read_json(path)
            self.assertEqual("page", payload["target"]["role"])
            self.assertEqual("page-shell", payload["metadata"]["ui_prompt_tags"]["structure_tag"])

    def test_ensure_explicit_prompt_dump_renders_and_writes_dump_when_missing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            root = Path(tmp_dir)
            explicit_path = root / "explicit.tu.json"
            runner.write_json(
                explicit_path,
                {
                    "tu_id": "tu::demo",
                    "target": {
                        "path": "pages/Demo.cj",
                        "role": "page",
                        "state_tags": [],
                        "thread_tags": [],
                        "interop_tags": [],
                    },
                    "dependency_closure": [],
                },
            )
            original_project_root = runner.PROJECT_ROOT
            self.addCleanup(setattr, runner, "PROJECT_ROOT", original_project_root)
            runner.PROJECT_ROOT = root  # type: ignore[assignment]
            entry = {
                "explicit_tu_json_path": "explicit.tu.json",
                "explicit_prompt_dump_path": "prompt.explicit.txt",
            }
            fake_prompt = SimpleNamespace(
                messages=[
                    SimpleNamespace(role="system", content="sys"),
                    SimpleNamespace(role="user", content="usr"),
                ]
            )
            with mock.patch.object(runner, "ensure_explicit_tu", return_value=explicit_path), \
                mock.patch.object(runner, "SchemaPolicy") as schema_policy_cls, \
                mock.patch.object(runner, "load_architecture_skill_texts", return_value=["arch skill"]), \
                mock.patch.object(runner, "PatternMemoryEngine") as pattern_memory_cls, \
                mock.patch.object(runner, "PromptAssembler") as prompt_assembler_cls, \
                mock.patch.object(runner, "render_prompt_dump", return_value="rendered prompt dump\n") as render_prompt_dump:
                schema_policy = schema_policy_cls.return_value
                schema_policy.schema_text = "# schema"
                schema_policy.required_dimensions.return_value = ["Translation Mapping", "Architecture Mapping"]
                pattern_memory_cls.return_value.query_for_tu.return_value = []
                prompt_assembler_cls.return_value.build_translator_prompt.return_value = fake_prompt

                path = runner.ensure_explicit_prompt_dump(entry, model="mock-model", pattern_limit=0)

            self.assertTrue((root / "prompt.explicit.txt").exists())
            self.assertEqual("rendered prompt dump\n", (root / "prompt.explicit.txt").read_text(encoding="utf-8"))
            self.assertEqual(root / "prompt.explicit.txt", path)
            render_prompt_dump.assert_called_once()

    def test_resolve_effective_mock_mode_forces_mock_for_large_source_backed_native_cj_without_keys(self) -> None:
        tu = {
            "target": {
                "path": "editor_kit/editorText.cj",
                "role": "component",
                "source": "x" * 6001,
                "ui_prompt_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            }
        }

        self.assertTrue(runner.resolve_effective_mock_mode(requested_mock_mode=False, tu=tu, env={}))

    def test_resolve_effective_mock_mode_keeps_real_mode_when_key_exists(self) -> None:
        tu = {
            "target": {
                "path": "editor_kit/editorText.cj",
                "role": "component",
                "source": "x" * 6001,
                "phase06_ui_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            }
        }

        self.assertFalse(
            runner.resolve_effective_mock_mode(
                requested_mock_mode=False,
                tu=tu,
                env={"OPENAI_API_KEY": "demo-key"},
            )
        )

    def test_build_orchestrator_command_includes_expected_flags(self) -> None:
        command = runner.build_orchestrator_command(
            tu_json_path=Path("/repo/tu.json"),
            workspace_root=Path("/repo/work"),
            output_path=Path("/repo/out.json"),
            model="Pro/zai-org/GLM-5",
            timeout_seconds=300,
            llm_max_retries=2,
            max_rounds=2,
            pattern_limit=0,
            use_mock_mode=False,
            verify_no_dry_run=False,
            verify_real_compile=False,
            verify_real_unit_test=False,
            verify_real_behavior=False,
        )
        self.assertIn("--tu-json", command)
        self.assertIn("/repo/tu.json", command)
        self.assertIn("--architecture-skill", command)
        self.assertIn("docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md", command)
        self.assertNotIn("--mock-mode", command)


if __name__ == "__main__":
    unittest.main()
