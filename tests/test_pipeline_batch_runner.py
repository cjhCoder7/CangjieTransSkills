from __future__ import annotations

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import pipeline_batch_runner  # noqa: E402


class PipelineBatchRunnerTests(unittest.TestCase):
    def test_phase05_manifest_exists_and_loads_as_mass_translation_batch(self) -> None:
        manifest_path = PROJECT_ROOT / "docs" / "manifests" / "batch_manifest_phase05.json"

        batch_manifest = pipeline_batch_runner.load_manifest(manifest_path)

        self.assertEqual(
            "telegramharmony-phase05-mass-translation-initialization",
            batch_manifest.batch_name,
        )
        self.assertEqual(
            PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02",
            batch_manifest.src_root,
        )
        self.assertEqual(
            [
                "src/core/mtproto/MTProtoConfig.ets",
                "src/core/mtproto/CryptoUtils.ets",
                "src/core/mtproto/TLMethods.ets",
                "src/core/mtproto/TLSerialization.ets",
                "src/core/mtproto/TLDialogs.ets",
                "src/core/mtproto/MTProtoTransport.ets",
                "src/core/mtproto/AuthKeyCreator.ets",
                "src/core/mtproto/Inflate.ets",
                "src/core/mtproto/MTProtoClient.ets",
                "src/services/RealMessageService.ets",
            ],
            [entry.target_file for entry in batch_manifest.entries],
        )
        self.assertFalse(batch_manifest.entries[-1].count_toward_kpi)
        self.assertIn(
            "Accepted Staged Contract Noise",
            batch_manifest.entries[-1].notes,
        )
        self.assertTrue(
            all(
                entry.pipeline_overrides
                and "frozen_candidate_file" in entry.pipeline_overrides
                and "frozen_candidate_label" in entry.pipeline_overrides
                for entry in batch_manifest.entries
            )
        )
        self.assertEqual(
            "20260407T064332Z-phase05-frozen-batch-baseline",
            batch_manifest.entries[2].pipeline_overrides["frozen_candidate_label"],
        )
        self.assertTrue(
            batch_manifest.entries[2].pipeline_overrides["frozen_candidate_file"].endswith(
                "attempt-01/src/core/mtproto/TLMethods.cj"
            )
        )
        self.assertEqual(
            "20260407T064605Z-phase05-frozen-batch-baseline",
            batch_manifest.entries[4].pipeline_overrides["frozen_candidate_label"],
        )
        self.assertTrue(
            batch_manifest.entries[4].pipeline_overrides["frozen_candidate_file"].endswith(
                "attempt-01/src/core/mtproto/TLDialogs.cj"
            )
        )
        self.assertEqual(
            "20260407T064746Z-phase05-frozen-control-baseline",
            batch_manifest.entries[-1].pipeline_overrides["frozen_candidate_label"],
        )
        self.assertTrue(
            batch_manifest.entries[-1].pipeline_overrides["frozen_candidate_file"].endswith(
                "attempt-01/src/services/RealMessageService.cj"
            )
        )

    def test_load_manifest_supports_ordered_targets_schema_and_preserves_order(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "phase04-core-expansion",
                        "ordered_targets": [
                            {
                                "file": "src/core/mtproto/SessionManager.ets",
                                "timeout": 300,
                                "retries": 2,
                            },
                            {
                                "file": "src/core/mtproto/Datacenter.ets",
                                "timeout": 420,
                                "retries": 1,
                            },
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            batch_manifest = pipeline_batch_runner.load_manifest(manifest)

            self.assertEqual("phase04-core-expansion", batch_manifest.batch_name)
            self.assertEqual(
                PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02",
                batch_manifest.src_root,
            )
            self.assertEqual(
                [
                    "src/core/mtproto/SessionManager.ets",
                    "src/core/mtproto/Datacenter.ets",
                ],
                [entry.target_file for entry in batch_manifest.entries],
            )
            self.assertEqual(300, batch_manifest.entries[0].timeout_seconds)
            self.assertEqual(2, batch_manifest.entries[0].llm_max_retries)
            self.assertEqual(420, batch_manifest.entries[1].timeout_seconds)
            self.assertEqual(1, batch_manifest.entries[1].llm_max_retries)

    def test_load_manifest_supports_per_entry_pipeline_overrides_and_resolves_paths(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            manifest_dir = temp_path / "manifests"
            manifest_dir.mkdir(parents=True, exist_ok=True)
            manifest = manifest_dir / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "phase05-control-baseline",
                        "ordered_targets": [
                            {
                                "file": "src/services/RealMessageService.ets",
                                "pipeline_overrides": {
                                    "repair_anchor_file": "../anchors/real-message-service.cj",
                                    "repair_anchor_label": "control-baseline-anchor",
                                    "frozen_candidate_file": "../anchors/real-message-service-frozen.cj",
                                    "frozen_candidate_label": "control-baseline-frozen",
                                },
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            batch_manifest = pipeline_batch_runner.load_manifest(manifest)

            self.assertEqual(
                str((manifest_dir / "../anchors/real-message-service.cj").resolve()),
                batch_manifest.entries[0].pipeline_overrides["repair_anchor_file"],
            )
            self.assertEqual(
                "control-baseline-anchor",
                batch_manifest.entries[0].pipeline_overrides["repair_anchor_label"],
            )
            self.assertEqual(
                str((manifest_dir / "../anchors/real-message-service-frozen.cj").resolve()),
                batch_manifest.entries[0].pipeline_overrides["frozen_candidate_file"],
            )
            self.assertEqual(
                "control-baseline-frozen",
                batch_manifest.entries[0].pipeline_overrides["frozen_candidate_label"],
            )

    def test_build_pipeline_command_maps_manifest_defaults_and_paths(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "telegramharmony-phase02-batch1",
                        "src_root": "raw_docs/telegramharmony-phase02",
                        "pipeline_defaults": {
                            "mock_mode": True,
                            "verify_dry_run": True,
                            "max_rounds": 2,
                        },
                        "entries": [
                            {
                                "target_file": "src/core/mtproto/CryptoUtils.ets",
                                "risk_level": "low",
                                "verification_mode": "dry-run",
                                "count_toward_kpi": True,
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            batch_manifest = pipeline_batch_runner.load_manifest(manifest)
            entry = batch_manifest.entries[0]
            run_root = temp_path / "runs" / "crypto"
            command = pipeline_batch_runner.build_pipeline_command(
                manifest=batch_manifest,
                entry=entry,
                run_root=run_root,
                python_executable="python3",
                pipeline_script=PROJECT_ROOT / "scripts" / "pipeline_runner.py",
            )

            self.assertEqual(command[0], "python3")
            self.assertIn("scripts/pipeline_runner.py", command[1])
            self.assertIn("--src-root", command)
            self.assertIn(str((temp_path / "raw_docs/telegramharmony-phase02").resolve()), command)
            self.assertIn("--target-file", command)
            self.assertIn("src/core/mtproto/CryptoUtils.ets", command)
            self.assertIn("--mock-mode", command)
            self.assertIn("--verify-dry-run", command)
            self.assertIn("--max-rounds", command)
            self.assertIn("2", command)
            self.assertIn("--summary-path", command)
            self.assertIn(str(run_root / "summary.json"), command)
            self.assertIn("--failure-path", command)
            self.assertIn(str(run_root / "failure.json"), command)

    def test_build_pipeline_command_applies_per_entry_pipeline_overrides(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "phase05-control-baseline",
                        "pipeline_defaults": {
                            "verify_dry_run": True,
                        },
                        "ordered_targets": [
                            {
                                "file": "src/services/RealMessageService.ets",
                                "pipeline_overrides": {
                                    "verify_dry_run": False,
                                    "frozen_candidate_file": "../anchors/real-message-service.cj",
                                    "frozen_candidate_label": "control-baseline-anchor",
                                },
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            batch_manifest = pipeline_batch_runner.load_manifest(manifest)
            entry = batch_manifest.entries[0]
            run_root = temp_path / "runs" / "real-message-service"
            command = pipeline_batch_runner.build_pipeline_command(
                manifest=batch_manifest,
                entry=entry,
                run_root=run_root,
                python_executable="python3",
                pipeline_script=PROJECT_ROOT / "scripts" / "pipeline_runner.py",
            )

            self.assertIn("--verify-no-dry-run", command)
            self.assertNotIn("--verify-dry-run", command)
            self.assertIn("--frozen-candidate-file", command)
            self.assertIn(str((temp_path / "../anchors/real-message-service.cj").resolve()), command)
            self.assertIn("--frozen-candidate-label", command)
            self.assertIn("control-baseline-anchor", command)

    def test_build_pipeline_command_maps_ordered_target_timeout_and_retries(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "phase04-core-expansion",
                        "ordered_targets": [
                            {
                                "file": "src/core/mtproto/SessionManager.ets",
                                "timeout": 300,
                                "retries": 2,
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            batch_manifest = pipeline_batch_runner.load_manifest(manifest)
            entry = batch_manifest.entries[0]
            run_root = temp_path / "runs" / "session-manager"
            command = pipeline_batch_runner.build_pipeline_command(
                manifest=batch_manifest,
                entry=entry,
                run_root=run_root,
                python_executable="python3",
                pipeline_script=PROJECT_ROOT / "scripts" / "pipeline_runner.py",
            )

            self.assertIn("--timeout-seconds", command)
            self.assertIn("300", command)
            self.assertIn("--llm-max-retries", command)
            self.assertIn("2", command)

    def test_run_batch_writes_summary_success_failure_and_truncated_failure_artifacts(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            fake_pipeline = temp_path / "fake_pipeline.py"
            fake_pipeline.write_text(
                """
import json
import sys
from pathlib import Path

args = sys.argv[1:]
def value_of(flag: str) -> str:
    index = args.index(flag)
    return args[index + 1]

run_root = Path(value_of('--run-root'))
summary_path = Path(value_of('--summary-path'))
failure_path = Path(value_of('--failure-path'))
target_file = value_of('--target-file')
run_root.mkdir(parents=True, exist_ok=True)
summary_path.parent.mkdir(parents=True, exist_ok=True)
if target_file.endswith('TLMethods.ets'):
    summary = {
        'status': 'repair-required',
        'target_file': target_file,
        'failure_class': 'review-repair-required',
    }
    summary_path.write_text(json.dumps(summary), encoding='utf-8')
    failure_path.write_text(json.dumps({'failure_class': 'review-repair-required'}), encoding='utf-8')
    sys.stderr.write('compile-error:' + ('x' * 12000))
    raise SystemExit(10)
summary = {
    'status': 'passed',
    'target_file': target_file,
}
summary_path.write_text(json.dumps(summary), encoding='utf-8')
raise SystemExit(0)
""".strip()
                + "\n",
                encoding="utf-8",
            )
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "telegramharmony-phase02-batch1",
                        "src_root": "raw_docs/telegramharmony-phase02",
                        "pipeline_defaults": {
                            "mock_mode": True,
                            "verify_dry_run": True,
                        },
                        "entries": [
                            {
                                "target_file": "src/core/mtproto/CryptoUtils.ets",
                                "risk_level": "low",
                                "verification_mode": "dry-run",
                                "count_toward_kpi": True,
                            },
                            {
                                "target_file": "src/core/mtproto/TLMethods.ets",
                                "risk_level": "medium",
                                "verification_mode": "dry-run",
                                "count_toward_kpi": True,
                            },
                            {
                                "target_file": "src/services/RealMessageService.ets",
                                "risk_level": "control",
                                "verification_mode": "dry-run",
                                "count_toward_kpi": False,
                            },
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            output_root = temp_path / "artifacts" / "batch_runs" / "telegramharmony-phase02-batch1"
            exit_code = pipeline_batch_runner.run_batch(
                manifest_path=manifest,
                batch_run_root=output_root,
                python_executable=sys.executable,
                pipeline_script=fake_pipeline,
                continue_on_error=True,
            )

            self.assertEqual(exit_code, 10)
            batch_summary = json.loads((output_root / "batch-summary.json").read_text(encoding="utf-8"))
            batch_summary_underscore = json.loads((output_root / "batch_summary.json").read_text(encoding="utf-8"))
            success_list = json.loads((output_root / "success-list.json").read_text(encoding="utf-8"))
            failure_list = json.loads((output_root / "failure-list.json").read_text(encoding="utf-8"))
            pattern_candidates = json.loads((output_root / "pattern-candidates.json").read_text(encoding="utf-8"))

            self.assertEqual(batch_summary, batch_summary_underscore)
            self.assertEqual(batch_summary["statistics"]["total_entries"], 3)
            self.assertEqual(batch_summary["statistics"]["counted_entries"], 2)
            self.assertEqual(batch_summary["statistics"]["passed_entries"], 2)
            self.assertEqual(batch_summary["statistics"]["failed_entries"], 1)
            self.assertEqual(batch_summary["statistics"]["repair_required_entries"], 1)
            self.assertEqual(batch_summary["statistics"]["counted_passed_entries"], 1)
            self.assertEqual(batch_summary["statistics"]["counted_failed_entries"], 1)
            self.assertEqual(batch_summary["status"], "partial")
            self.assertEqual(
                success_list["targets"],
                [
                    "src/core/mtproto/CryptoUtils.ets",
                    "src/services/RealMessageService.ets",
                ],
            )
            self.assertEqual(failure_list["targets"], ["src/core/mtproto/TLMethods.ets"])
            self.assertEqual(len(pattern_candidates["candidates"]), 1)
            self.assertEqual(pattern_candidates["candidates"][0]["target_file"], "src/core/mtproto/CryptoUtils.ets")

            failure_artifact = output_root / "failure" / "src-core-mtproto-TLMethods.ets.failure.json"
            failure_stderr = output_root / "failure" / "src-core-mtproto-TLMethods.ets.stderr.log"
            self.assertTrue(failure_artifact.exists())
            self.assertTrue(failure_stderr.exists())
            artifact_payload = json.loads(failure_artifact.read_text(encoding="utf-8"))
            stderr_excerpt = failure_stderr.read_text(encoding="utf-8")
            self.assertEqual(artifact_payload["target_file"], "src/core/mtproto/TLMethods.ets")
            self.assertEqual(artifact_payload["status"], "repair-required")
            self.assertTrue(stderr_excerpt.startswith("compile-error:"))
            self.assertLessEqual(len(stderr_excerpt), pipeline_batch_runner.MAX_FAILURE_STDERR_CHARS)

    def test_run_batch_halts_on_first_failure_by_default_and_marks_remaining_targets_skipped(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            invocations_path = temp_path / "invocations.jsonl"
            fake_pipeline = temp_path / "fake_pipeline.py"
            fake_pipeline.write_text(
                f"""
import json
import sys
from pathlib import Path

INVOCATIONS = Path({json.dumps(str(invocations_path))})
args = sys.argv[1:]
def value_of(flag: str) -> str:
    index = args.index(flag)
    return args[index + 1]

target_file = value_of('--target-file')
summary_path = Path(value_of('--summary-path'))
summary_path.parent.mkdir(parents=True, exist_ok=True)
with INVOCATIONS.open('a', encoding='utf-8') as handle:
    handle.write(json.dumps({{'target_file': target_file}}, ensure_ascii=False) + '\\n')
if target_file.endswith('SessionManager.ets'):
    summary_path.write_text(json.dumps({{
        'status': 'failed',
        'target_file': target_file,
    }}), encoding='utf-8')
    raise SystemExit(10)
summary_path.write_text(json.dumps({{
    'status': 'passed',
    'target_file': target_file,
}}), encoding='utf-8')
raise SystemExit(0)
""".strip()
                + "\n",
                encoding="utf-8",
            )
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "phase04-core-expansion",
                        "ordered_targets": [
                            {
                                "file": "src/core/mtproto/SessionManager.ets",
                                "timeout": 300,
                                "retries": 2,
                            },
                            {
                                "file": "src/core/mtproto/Datacenter.ets",
                                "timeout": 300,
                                "retries": 2,
                            },
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            output_root = temp_path / "artifacts" / "batch_runs" / "phase04-core-expansion"
            exit_code = pipeline_batch_runner.run_batch(
                manifest_path=manifest,
                batch_run_root=output_root,
                python_executable=sys.executable,
                pipeline_script=fake_pipeline,
            )

            self.assertEqual(exit_code, 10)
            invocations = [
                json.loads(line)
                for line in invocations_path.read_text(encoding="utf-8").splitlines()
                if line.strip()
            ]
            self.assertEqual(
                [{"target_file": "src/core/mtproto/SessionManager.ets"}],
                invocations,
            )
            batch_summary = json.loads((output_root / "batch_summary.json").read_text(encoding="utf-8"))
            self.assertEqual("failed", batch_summary["status"])
            self.assertEqual("failed", batch_summary["entries"][0]["status"])
            self.assertEqual("skipped", batch_summary["entries"][1]["status"])
            self.assertEqual(1, batch_summary["statistics"]["failed_entries"])
            self.assertEqual(1, batch_summary["statistics"]["skipped_entries"])

    def test_run_batch_clears_stale_failure_artifacts_before_rerun(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            fake_pipeline = temp_path / "fake_pipeline.py"
            fake_pipeline.write_text(
                """
import json
import sys
from pathlib import Path

args = sys.argv[1:]
def value_of(flag: str) -> str:
    index = args.index(flag)
    return args[index + 1]

summary_path = Path(value_of('--summary-path'))
summary_path.parent.mkdir(parents=True, exist_ok=True)
summary_path.write_text(json.dumps({
    'status': 'passed',
    'target_file': value_of('--target-file'),
}), encoding='utf-8')
raise SystemExit(0)
""".strip()
                + "\n",
                encoding="utf-8",
            )
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "phase04-core-expansion",
                        "ordered_targets": [
                            {
                                "file": "src/core/mtproto/SessionManager.ets",
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            output_root = temp_path / "artifacts" / "batch_runs" / "phase04-core-expansion"
            stale_failure_root = output_root / "failure"
            stale_failure_root.mkdir(parents=True, exist_ok=True)
            (stale_failure_root / "stale.failure.json").write_text("{}", encoding="utf-8")
            (stale_failure_root / "stale.stderr.log").write_text("old", encoding="utf-8")

            exit_code = pipeline_batch_runner.run_batch(
                manifest_path=manifest,
                batch_run_root=output_root,
                python_executable=sys.executable,
                pipeline_script=fake_pipeline,
                continue_on_error=True,
            )

            self.assertEqual(exit_code, 0)
            self.assertFalse(stale_failure_root.exists())
            failure_list = json.loads((output_root / "failure-list.json").read_text(encoding="utf-8"))
            self.assertEqual([], failure_list["targets"])

    def test_run_batch_treats_failed_orchestration_as_failed_entry(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            fake_pipeline = temp_path / "fake_pipeline.py"
            fake_pipeline.write_text(
                """
import json
import sys
from pathlib import Path

args = sys.argv[1:]
def value_of(flag: str) -> str:
    index = args.index(flag)
    return args[index + 1]

summary_path = Path(value_of('--summary-path'))
summary_path.parent.mkdir(parents=True, exist_ok=True)
summary_path.write_text(json.dumps({
    'status': 'passed',
    'target_file': value_of('--target-file'),
    'orchestration': {
        'final_status': 'failed'
    }
}), encoding='utf-8')
raise SystemExit(0)
""".strip()
                + "\n",
                encoding="utf-8",
            )
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "orchestration-status-batch",
                        "src_root": "raw_docs/telegramharmony-phase02",
                        "pipeline_defaults": {
                            "mock_mode": True,
                            "verify_dry_run": True
                        },
                        "entries": [
                            {
                                "target_file": "src/core/mtproto/MTProtoConfig.ets",
                                "risk_level": "low"
                            }
                        ]
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )
            output_root = temp_path / "artifacts" / "batch_runs" / "orchestration-status-batch"
            exit_code = pipeline_batch_runner.run_batch(
                manifest_path=manifest,
                batch_run_root=output_root,
                python_executable=sys.executable,
                pipeline_script=fake_pipeline,
            )

            self.assertEqual(exit_code, 10)
            batch_summary = json.loads((output_root / "batch-summary.json").read_text(encoding="utf-8"))
            self.assertEqual(batch_summary["status"], "failed")
            self.assertEqual(batch_summary["entries"][0]["status"], "failed")
            failure_artifact = output_root / "failure" / "src-core-mtproto-MTProtoConfig.ets.failure.json"
            self.assertTrue(failure_artifact.exists())

    def test_run_batch_propagates_linux_sdk_environment_to_child_processes(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            fake_pipeline = temp_path / "fake_pipeline.py"
            fake_pipeline.write_text(
                """
import json
import os
import sys
from pathlib import Path

args = sys.argv[1:]
def value_of(flag: str) -> str:
    index = args.index(flag)
    return args[index + 1]

summary_path = Path(value_of('--summary-path'))
summary_path.parent.mkdir(parents=True, exist_ok=True)
summary_path.write_text(json.dumps({
    'status': 'passed',
    'target_file': value_of('--target-file'),
    'env_snapshot': {
        'CANGJIE_HOME': os.environ.get('CANGJIE_HOME', ''),
        'PATH': os.environ.get('PATH', ''),
        'LD_LIBRARY_PATH': os.environ.get('LD_LIBRARY_PATH', ''),
    },
}), encoding='utf-8')
raise SystemExit(0)
""".strip()
                + "\n",
                encoding="utf-8",
            )
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "env-propagation-batch",
                        "src_root": "raw_docs/telegramharmony-phase02",
                        "pipeline_defaults": {
                            "mock_mode": True,
                            "verify_dry_run": True,
                        },
                        "entries": [
                            {
                                "target_file": "src/core/mtproto/MTProtoConfig.ets",
                                "risk_level": "low",
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            output_root = temp_path / "artifacts" / "batch_runs" / "env-propagation-batch"
            with mock.patch.dict(
                os.environ,
                {
                    "CANGJIE_HOME": "/opt/cangjie-sdk",
                    "PATH": "/opt/cangjie-sdk/bin:/usr/bin",
                    "LD_LIBRARY_PATH": "/opt/cangjie-sdk/lib",
                },
                clear=False,
            ):
                exit_code = pipeline_batch_runner.run_batch(
                    manifest_path=manifest,
                    batch_run_root=output_root,
                    python_executable=sys.executable,
                    pipeline_script=fake_pipeline,
                )

            self.assertEqual(exit_code, 0)
            per_file_summary = json.loads(
                (
                    output_root
                    / "runs"
                    / "src-core-mtproto-MTProtoConfig.ets"
                    / "summary.json"
                ).read_text(encoding="utf-8")
            )
            env_snapshot = per_file_summary["env_snapshot"]
            self.assertEqual(env_snapshot["CANGJIE_HOME"], "/opt/cangjie-sdk")
            self.assertIn("/opt/cangjie-sdk/bin", env_snapshot["PATH"])
            self.assertIn("/opt/cangjie-sdk/lib", env_snapshot["LD_LIBRARY_PATH"])

    def test_load_manifest_rejects_dependency_misordering(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "telegramharmony-phase02-batch1",
                        "src_root": "raw_docs/telegramharmony-phase02",
                        "entries": [
                            {
                                "target_file": "src/core/mtproto/TLSerialization.ets",
                                "risk_level": "medium",
                                "depends_on": ["src/core/mtproto/MTProtoConfig.ets"]
                            },
                            {
                                "target_file": "src/core/mtproto/MTProtoConfig.ets",
                                "risk_level": "low"
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            with self.assertRaises(pipeline_batch_runner.BatchManifestError):
                pipeline_batch_runner.load_manifest(manifest)

    def test_load_manifest_resolves_manifest_relative_paths(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            manifest_dir = temp_path / "manifests"
            manifest_dir.mkdir(parents=True, exist_ok=True)
            manifest = manifest_dir / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "telegramharmony-phase02-batch1",
                        "src_root": "../raw_docs/telegramharmony-phase02",
                        "pipeline_defaults": {
                            "repair_anchor_file": "../anchors/real-message-service.cj"
                        },
                        "entries": [
                            {
                                "target_file": "src/core/mtproto/MTProtoConfig.ets",
                                "risk_level": "low"
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            batch_manifest = pipeline_batch_runner.load_manifest(manifest)

            self.assertEqual(batch_manifest.src_root, (manifest_dir / "../raw_docs/telegramharmony-phase02").resolve())
            self.assertEqual(
                batch_manifest.pipeline_defaults["repair_anchor_file"],
                str((manifest_dir / "../anchors/real-message-service.cj").resolve()),
            )

    def test_run_batch_continue_on_error_processes_remaining_ordered_targets(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            invocations_path = temp_path / "invocations.jsonl"
            fake_pipeline = temp_path / "fake_pipeline.py"
            fake_pipeline.write_text(
                f"""
import json
import sys
from pathlib import Path

INVOCATIONS = Path({json.dumps(str(invocations_path))})
args = sys.argv[1:]
def value_of(flag: str) -> str:
    index = args.index(flag)
    return args[index + 1]

target_file = value_of('--target-file')
summary_path = Path(value_of('--summary-path'))
summary_path.parent.mkdir(parents=True, exist_ok=True)
with INVOCATIONS.open('a', encoding='utf-8') as handle:
    handle.write(json.dumps({{'target_file': target_file}}, ensure_ascii=False) + '\\n')
if target_file.endswith('SessionManager.ets'):
    summary_path.write_text(json.dumps({{
        'status': 'failed',
        'target_file': target_file,
    }}), encoding='utf-8')
    raise SystemExit(10)
summary_path.write_text(json.dumps({{
    'status': 'passed',
    'target_file': target_file,
}}), encoding='utf-8')
raise SystemExit(0)
""".strip()
                + "\n",
                encoding="utf-8",
            )
            manifest = temp_path / "batch.json"
            manifest.write_text(
                json.dumps(
                    {
                        "batch_name": "phase04-core-expansion",
                        "ordered_targets": [
                            {
                                "file": "src/core/mtproto/SessionManager.ets",
                                "timeout": 300,
                                "retries": 2,
                            },
                            {
                                "file": "src/core/mtproto/Datacenter.ets",
                                "timeout": 300,
                                "retries": 2,
                            },
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )

            output_root = temp_path / "artifacts" / "batch_runs" / "phase04-core-expansion"
            exit_code = pipeline_batch_runner.run_batch(
                manifest_path=manifest,
                batch_run_root=output_root,
                python_executable=sys.executable,
                pipeline_script=fake_pipeline,
                continue_on_error=True,
            )

            self.assertEqual(exit_code, 10)
            invocations = [
                json.loads(line)
                for line in invocations_path.read_text(encoding="utf-8").splitlines()
                if line.strip()
            ]
            self.assertEqual(
                [
                    {"target_file": "src/core/mtproto/SessionManager.ets"},
                    {"target_file": "src/core/mtproto/Datacenter.ets"},
                ],
                invocations,
            )
            batch_summary = json.loads((output_root / "batch_summary.json").read_text(encoding="utf-8"))
            self.assertEqual("partial", batch_summary["status"])
            self.assertEqual(["failed", "passed"], [item["status"] for item in batch_summary["entries"]])


if __name__ == "__main__":
    unittest.main()
