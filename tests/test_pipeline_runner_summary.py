from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import pipeline_runner  # noqa: E402


class PipelineRunnerSummaryStatusTests(unittest.TestCase):
    def test_derive_pipeline_status_prefers_orchestration_final_status(self) -> None:
        status = pipeline_runner.derive_pipeline_status(
            "passed",
            {"final_status": "failed"},
        )

        self.assertEqual(status, "failed")

    def test_derive_pipeline_status_falls_back_when_orchestration_status_missing(self) -> None:
        status = pipeline_runner.derive_pipeline_status(
            "passed",
            {},
        )

        self.assertEqual(status, "passed")


class PipelineRunnerCurrentPhaseSyncTests(unittest.TestCase):
    def test_sync_current_phase_promotes_only_bcm_pass(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            status_path = temp_path / "current-phase.md"
            status_path.write_text(
                "# Current Phase\n\n"
                "phase: `Phase 3B passed / Phase 3C Conditional Pass achieved / Phase 05 initialization active`\n"
                "status: `active`\n"
                "blocked_by:\n"
                "- `placeholder`\n",
                encoding="utf-8",
            )

            result = pipeline_runner.sync_current_phase_file(
                status_path=status_path,
                validation_report={
                    "exit_code": 0,
                    "validation_class": "valid-evidence-pass",
                    "extracted_assertion_ids": ["BCM-ASYNC-003"],
                    "nonpassed_assertions": [],
                },
                summary_payload={
                    "label": "full-pass-cycle-01",
                    "overall_status": "passed",
                    "scenario_mode": "bcm",
                    "module": {
                        "name": "RealMessageService",
                        "source_file": "src/services/RealMessageService.ets",
                    },
                },
                report_path=temp_path / "report.json",
                summary_path=temp_path / "summary.json",
                target_file="src/services/RealMessageService.ets",
            )

            updated = status_path.read_text(encoding="utf-8")
            self.assertTrue(result["synced"])
            self.assertEqual("full-pass-achieved", result["promotion_assessment"])
            self.assertIn("phase: `Phase 3C Full Pass achieved`", updated)
            self.assertIn("- scenario_mode: `bcm`", updated)
            self.assertIn("- promotion_assessment: `full-pass-achieved`", updated)

    def test_sync_current_phase_keeps_conditional_phase_for_smoke_pass(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            status_path = temp_path / "current-phase.md"
            original_phase = "phase: `Phase 3B passed / Phase 3C Conditional Pass achieved / Phase 05 initialization active`"
            status_path.write_text(
                "# Current Phase\n\n"
                f"{original_phase}\n"
                "status: `active`\n"
                "blocked_by:\n"
                "- `placeholder`\n",
                encoding="utf-8",
            )

            result = pipeline_runner.sync_current_phase_file(
                status_path=status_path,
                validation_report={
                    "exit_code": 0,
                    "validation_class": "valid-evidence-pass",
                    "extracted_assertion_ids": ["SMOKE-LAUNCH-001"],
                    "nonpassed_assertions": [],
                },
                summary_payload={
                    "label": "full-pass-cycle-01",
                    "overall_status": "passed",
                    "scenario_mode": "smoke",
                    "module": {
                        "name": "entry",
                        "source_file": "E:/deveco_cangjie_control_project",
                    },
                },
                report_path=temp_path / "report.json",
                summary_path=temp_path / "summary.json",
                target_file="E:/deveco_cangjie_control_project",
            )

            updated = status_path.read_text(encoding="utf-8")
            self.assertTrue(result["synced"])
            self.assertEqual("smoke-only-pass", result["promotion_assessment"])
            self.assertIn(original_phase, updated)
            self.assertNotIn("phase: `Phase 3C Full Pass achieved`", updated)
            self.assertIn("- scenario_mode: `smoke`", updated)
            self.assertIn("- promotion_assessment: `smoke-only-pass`", updated)


class PipelineRunnerConfigDefaultsTests(unittest.TestCase):
    def test_build_config_defaults_timeout_to_300_seconds(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            with mock.patch.object(
                sys,
                "argv",
                [
                    "pipeline_runner.py",
                    "--src-root",
                    temp_dir,
                    "--target-file",
                    "src/core/mtproto/MTProtoClient.ets",
                ],
            ):
                args = pipeline_runner.parse_args()

            config = pipeline_runner.build_config(args)

        self.assertEqual(300, config.timeout_seconds)

    def test_build_config_accepts_frozen_candidate_paths(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            frozen_candidate = temp_path / "frozen.cj"
            frozen_candidate.write_text("class Frozen {}\n", encoding="utf-8")
            with mock.patch.object(
                sys,
                "argv",
                [
                    "pipeline_runner.py",
                    "--src-root",
                    temp_dir,
                    "--target-file",
                    "src/services/FrozenService.ets",
                    "--frozen-candidate-file",
                    str(frozen_candidate),
                    "--frozen-candidate-label",
                    "phase05-frozen-baseline",
                ],
            ):
                args = pipeline_runner.parse_args()

            config = pipeline_runner.build_config(args)

        self.assertEqual(frozen_candidate.resolve(), config.frozen_candidate_file)
        self.assertEqual("phase05-frozen-baseline", config.frozen_candidate_label)


class PipelineRunnerFrozenCandidateTests(unittest.TestCase):
    def test_run_uses_frozen_candidate_without_live_orchestrator(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            src_root = temp_path / "raw_docs"
            run_root = temp_path / "run"
            frozen_candidate = temp_path / "anchors" / "FrozenService.cj"
            frozen_candidate.parent.mkdir(parents=True, exist_ok=True)
            frozen_candidate.write_text("public class FrozenService {}\n", encoding="utf-8")

            with mock.patch.object(
                sys,
                "argv",
                [
                    "pipeline_runner.py",
                    "--src-root",
                    str(src_root),
                    "--target-file",
                    "src/services/FrozenService.ets",
                    "--run-root",
                    str(run_root),
                    "--frozen-candidate-file",
                    str(frozen_candidate),
                    "--frozen-candidate-label",
                    "phase05-frozen-baseline",
                ],
            ):
                args = pipeline_runner.parse_args()

            config = pipeline_runner.build_config(args)
            runner = pipeline_runner.PipelineRunner(config)
            tu_payload = {
                "tu_id": "tu-pipeline-frozen-src-services-frozenservice.ets",
                "target": {
                    "path": "src/services/FrozenService.ets",
                    "role": "service",
                    "risk_tags": [],
                },
                "dependency_closure": [],
            }

            with mock.patch.object(runner, "_run_index_stage", return_value={"file_count": 1, "symbol_count": 1, "edge_count": 0}), \
                mock.patch.object(runner, "_run_repo_map_stage", return_value={"symbol_count": 1, "call_hotspots": 0}), \
                mock.patch.object(runner, "_run_tu_stage", return_value=tu_payload), \
                mock.patch.object(pipeline_runner, "Orchestrator", side_effect=AssertionError("live orchestrator should be skipped")):
                exit_code = runner.run()

            self.assertEqual(0, exit_code)
            summary = json.loads(config.summary_path.read_text(encoding="utf-8"))
            orchestration = json.loads(config.orchestration_output_path.read_text(encoding="utf-8"))

            self.assertEqual("passed", summary["status"])
            self.assertEqual("passed", summary["orchestration"]["final_status"])
            self.assertEqual("frozen-candidate", orchestration["execution_mode"])
            self.assertEqual("phase05-frozen-baseline", orchestration["frozen_candidate"]["label"])
            self.assertTrue(Path(summary["artifacts"]["final_output_path"]).exists())
            self.assertTrue(Path(orchestration["final_artifact"]["metadata"]["candidate_file_path"]).exists())


if __name__ == "__main__":
    unittest.main()
