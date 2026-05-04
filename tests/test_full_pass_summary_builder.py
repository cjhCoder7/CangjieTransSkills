from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
BUILDER_PATH = PROJECT_ROOT / "scripts" / "full-pass-summary-builder.py"
REFRESH_PATH = PROJECT_ROOT / "scripts" / "full-pass-harmony-refresh.sh"
VALIDATOR_PATH = PROJECT_ROOT / "scripts" / "full-pass-summary-validate.py"
SCHEMA_PATH = PROJECT_ROOT / "docs" / "schemas" / "full-pass-summary-schema.json"
VALID_LOG_PATH = PROJECT_ROOT / "docs" / "schemas" / "examples" / "full-pass-runtime.valid.log"
NONPASS_LOG_PATH = PROJECT_ROOT / "docs" / "schemas" / "examples" / "full-pass-runtime.nonpass.log"


class FullPassSummaryBuilderTests(unittest.TestCase):
    maxDiff = None

    def run_builder(
        self,
        log_path: Path,
        summary_path: Path,
        label: str,
        *,
        scenario_mode: str = "bcm",
        expected_assertions: str = "BCM-CONC-001,BCM-STATE-001,BCM-ASYNC-003",
    ) -> subprocess.CompletedProcess[str]:
        command = [
            "python3",
            str(BUILDER_PATH),
            "--log-input",
            str(log_path),
            "--raw-log-path",
            str(log_path),
            "--summary-output",
            str(summary_path),
            "--label",
            label,
            "--module-name",
            "RealMessageService",
            "--source-file",
            "src/services/RealMessageService.ets",
            "--candidate-file",
            "src/services/RealMessageService.cj",
            "--ui-route",
            "/chat/detail",
            "--peer-scope",
            "dialog:42",
            "--host-os",
            "Linux",
            "--host-arch",
            "x86_64",
            "--node-mode",
            "headless-host",
            "--deveco-studio-home",
            "/opt/DevEco-Studio",
            "--harmony-sdk-home",
            "/opt/HarmonySDK",
            "--hdc-path",
            "/opt/HarmonySDK/toolchains/hdc",
            "--host-probe-json",
            "artifacts/environment/full-pass-host-profile.json",
            "--target-type",
            "emulator",
            "--target-id",
            "emulator-5554",
            "--target-name",
            "Harmony Emulator",
            "--target-os-version",
            "5.0.0",
            "--target-serial-redacted",
            "true",
            "--build-id",
            f"build-{label}",
            "--bundle-name",
            "org.example.rms",
            "--artifact-path",
            "artifacts/builds/real-message-service.hap",
            "--install-status",
            "passed",
            "--launch-status",
            "passed",
            "--log-source",
            "file",
            "--log-capture-command",
            f"cat {log_path}",
            "--scenario-mode",
            scenario_mode,
            "--expected-assertions",
            expected_assertions,
        ]
        return subprocess.run(command, cwd=PROJECT_ROOT, capture_output=True, text=True, check=False)

    def run_validator(self, summary_path: Path, report_path: Path) -> subprocess.CompletedProcess[str]:
        command = [
            "python3",
            str(VALIDATOR_PATH),
            "--summary",
            str(summary_path),
            "--schema",
            str(SCHEMA_PATH),
            "--report",
            str(report_path),
        ]
        return subprocess.run(command, cwd=PROJECT_ROOT, capture_output=True, text=True, check=False)

    def test_builder_generates_valid_pass_summary(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            summary_path = Path(temp_dir) / "valid-summary.json"
            report_path = Path(temp_dir) / "valid-report.json"
            builder = self.run_builder(VALID_LOG_PATH, summary_path, "builder-valid")
            self.assertEqual(builder.returncode, 0, msg=builder.stderr or builder.stdout)
            validator = self.run_validator(summary_path, report_path)
            self.assertEqual(validator.returncode, 0, msg=validator.stderr or validator.stdout)
            payload = json.loads(summary_path.read_text(encoding="utf-8"))
            self.assertEqual(payload["overall_status"], "passed")
            self.assertEqual(payload["build"]["install_status"], "passed")
            self.assertEqual(payload["build"]["launch_status"], "passed")
            self.assertTrue(payload["runtime_log_capture"]["main_thread_refresh_seen"])
            self.assertEqual(payload["scenario_mode"], "bcm")

    def test_builder_generates_valid_nonpass_summary(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            summary_path = Path(temp_dir) / "nonpass-summary.json"
            report_path = Path(temp_dir) / "nonpass-report.json"
            builder = self.run_builder(NONPASS_LOG_PATH, summary_path, "builder-nonpass")
            self.assertEqual(builder.returncode, 0, msg=builder.stderr or builder.stdout)
            validator = self.run_validator(summary_path, report_path)
            self.assertEqual(validator.returncode, 10, msg=validator.stderr or validator.stdout)
            payload = json.loads(summary_path.read_text(encoding="utf-8"))
            self.assertEqual(payload["overall_status"], "failed")
            failures = {item["assertion_id"]: item for item in payload["assertions"]}
            self.assertEqual(failures["BCM-ASYNC-003"]["status"], "failed")
            self.assertIn("main", failures["BCM-ASYNC-003"]["failure_reason"].lower())

    def test_builder_generates_valid_smoke_summary(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            log_path = temp_path / "smoke.log"
            log_path.write_text(
                "\n".join(
                    [
                        "04-08 10:33:20.100 1000 1000 I testTag Ability onForeground",
                        "04-08 10:33:20.200 1000 1000 I CANGJIE-RUNTIME Runtime started",
                    ]
                )
                + "\n",
                encoding="utf-8",
            )
            summary_path = temp_path / "smoke-summary.json"
            report_path = temp_path / "smoke-report.json"
            builder = self.run_builder(
                log_path,
                summary_path,
                "builder-smoke",
                scenario_mode="smoke",
                expected_assertions="SMOKE-LAUNCH-001",
            )
            self.assertEqual(builder.returncode, 0, msg=builder.stderr or builder.stdout)
            validator = self.run_validator(summary_path, report_path)
            self.assertEqual(validator.returncode, 0, msg=validator.stderr or validator.stdout)
            payload = json.loads(summary_path.read_text(encoding="utf-8"))
            self.assertEqual(payload["scenario_mode"], "smoke")
            self.assertEqual(payload["overall_status"], "passed")
            assertions = {item["assertion_id"]: item for item in payload["assertions"]}
            self.assertEqual(assertions["SMOKE-LAUNCH-001"]["status"], "passed")
            self.assertIn("SMOKE_CHAIN_PASSED", assertions["SMOKE-LAUNCH-001"]["evidence"]["matched_event_names"])


    def test_refresh_harness_reports_missing_alias_env_clearly(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            run_root = Path(temp_dir) / "run"
            run_root.mkdir()
            summary_path = Path(temp_dir) / "summary.json"
            report_path = Path(temp_dir) / "report.json"
            result = subprocess.run(
                [
                    "bash",
                    str(REFRESH_PATH),
                    "--cycle",
                    "1",
                    "--summary",
                    str(summary_path),
                    "--run-root",
                    str(run_root),
                    "--target-file",
                    "src/services/RealMessageService.ets",
                    "--orchestration-output",
                    str(Path(temp_dir) / "orchestration.json"),
                    "--final-output",
                    "src/services/RealMessageService.cj",
                    "--report",
                    str(report_path),
                ],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
                env={},
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Error: FULL_PASS_HDC_SERIAL is not set", result.stderr or result.stdout)

    def test_refresh_harness_accepts_alias_env_and_generates_summary(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            fake_hdc = temp_path / "hdc"
            fake_hdc.write_text(
                """#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "list" && "${2:-}" == "targets" ]]; then
  printf 'emulator-5554\n'
  exit 0
fi
if [[ "${1:-}" == "-t" && "${2:-}" == "emulator-5554" && "${3:-}" == "shell" && "${4:-}" == "hilog" ]]; then
  cat <<'LOG'
03-30 21:00:01.100 2001 2001 I RMS RMS_FETCH_BEGIN BCM-CONC-001 worker fetch begin
03-30 21:00:01.210 2001 2001 I RMS RMS_SEND_END BCM-STATE-001 BCM-CONC-001 worker send end
03-30 21:00:01.330 1000 1000 I BCM_TRACE RMS_UI_REFRESH_DELIVERED BCM-ASYNC-003 main refresh delivered
LOG
  exit 0
fi
printf 'fake hdc unsupported args: %s\n' "$*" >&2
exit 0
""",
                encoding="utf-8",
            )
            fake_hdc.chmod(0o755)

            deveco_home = temp_path / "DevEco Studio"
            harmony_home = temp_path / "HarmonySDK"
            deveco_home.mkdir()
            harmony_home.mkdir()
            run_root = temp_path / "run"
            run_root.mkdir()
            summary_path = temp_path / "summary.json"
            report_path = temp_path / "report.json"

            env = {
                "PATH": f"{temp_path}:{Path('/usr/bin')}:{Path('/bin')}",
                "PYTHON_BIN": "python3",
                "FULL_PASS_HDC_PATH": str(fake_hdc),
                "FULL_PASS_HDC_SERIAL": "emulator-5554",
                "FULL_PASS_TARGET_NAME": "Harmony Emulator",
                "FULL_PASS_DEVECO_STUDIO_HOME": str(deveco_home),
                "FULL_PASS_HARMONY_SDK_HOME": str(harmony_home),
                "FULL_PASS_PKG_NAME": "org.example.rms",
                "FULL_PASS_ABILITY_NAME": "EntryAbility",
                "FULL_PASS_EXPECTED_ASSERTIONS": "BCM-CONC-001,BCM-STATE-001,BCM-ASYNC-003",
                "FULL_PASS_HILOG_FILTER": "BCM_TRACE|BCM-|RMS_",
                "FULL_PASS_CLEAN_DIR": r"C:\temp\rms-cache",
                "FULL_PASS_ASSUME_PREINSTALLED": "1",
                "FULL_PASS_ASSUME_PRELAUNCHED": "1",
                "FULL_PASS_EXERCISE_CMD": "printf exercise-ok\n",
            }
            result = subprocess.run(
                [
                    "bash",
                    str(REFRESH_PATH),
                    "--cycle",
                    "1",
                    "--summary",
                    str(summary_path),
                    "--run-root",
                    str(run_root),
                    "--target-file",
                    "src/services/RealMessageService.ets",
                    "--orchestration-output",
                    str(temp_path / "orchestration.json"),
                    "--final-output",
                    "src/services/RealMessageService.cj",
                    "--report",
                    str(report_path),
                ],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
                env=env,
            )
            self.assertEqual(result.returncode, 0, msg=result.stderr or result.stdout)
            payload = json.loads(summary_path.read_text(encoding="utf-8"))
            self.assertEqual(payload["overall_status"], "passed")
            self.assertEqual(payload["build"]["bundle_name"], "org.example.rms")
            self.assertEqual(payload["scenario_mode"], "bcm")
            self.assertIn("C:/temp/rms-cache", (result.stderr or "") + (result.stdout or ""))
            raw_log_path = run_root / "full-pass-cycle-01" / "logs" / "runtime.raw.log"
            filtered_log_path = run_root / "full-pass-cycle-01" / "logs" / "runtime.filtered.log"
            self.assertTrue(raw_log_path.exists())
            self.assertTrue(filtered_log_path.exists())
            filtered_text = filtered_log_path.read_text(encoding="utf-8")
            self.assertIn("BCM_TRACE", filtered_text)
            self.assertNotIn("fake hdc unsupported", filtered_text)

    def test_refresh_harness_smoke_mode_generates_summary_without_expected_assertions(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            fake_hdc = temp_path / "hdc"
            fake_hdc.write_text(
                """#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "list" && "${2:-}" == "targets" ]]; then
  printf 'emulator-5554\n'
  exit 0
fi
if [[ "${1:-}" == "-t" && "${2:-}" == "emulator-5554" && "${3:-}" == "shell" && "${4:-}" == "hilog" ]]; then
  cat <<'LOG'
04-08 10:33:20.100 1000 1000 I testTag Ability onForeground
04-08 10:33:20.200 1000 1000 I CANGJIE-RUNTIME Runtime started
LOG
  exit 0
fi
printf 'fake hdc unsupported args: %s\n' "$*" >&2
exit 0
""",
                encoding="utf-8",
            )
            fake_hdc.chmod(0o755)

            deveco_home = temp_path / "DevEco Studio"
            harmony_home = temp_path / "HarmonySDK"
            deveco_home.mkdir()
            harmony_home.mkdir()
            run_root = temp_path / "run"
            run_root.mkdir()
            summary_path = temp_path / "summary-smoke.json"
            report_path = temp_path / "report-smoke.json"

            env = {
                "PATH": f"{temp_path}:{Path('/usr/bin')}:{Path('/bin')}",
                "PYTHON_BIN": "python3",
                "FULL_PASS_HDC_PATH": str(fake_hdc),
                "FULL_PASS_HDC_SERIAL": "emulator-5554",
                "FULL_PASS_TARGET_NAME": "Harmony Emulator",
                "FULL_PASS_DEVECO_STUDIO_HOME": str(deveco_home),
                "FULL_PASS_HARMONY_SDK_HOME": str(harmony_home),
                "FULL_PASS_PKG_NAME": "org.example.rms",
                "FULL_PASS_ABILITY_NAME": "EntryAbility",
                "FULL_PASS_SCENARIO_MODE": "smoke",
                "FULL_PASS_INSTALL_CMD": "printf install-ok\\n",
                "FULL_PASS_LAUNCH_CMD": "printf launch-ok\\n",
                "FULL_PASS_EXERCISE_CMD": "printf exercise-ok\\n",
            }
            result = subprocess.run(
                [
                    "bash",
                    str(REFRESH_PATH),
                    "--cycle",
                    "1",
                    "--summary",
                    str(summary_path),
                    "--run-root",
                    str(run_root),
                    "--target-file",
                    "src/services/RealMessageService.ets",
                    "--orchestration-output",
                    str(temp_path / "orchestration.json"),
                    "--final-output",
                    "src/services/RealMessageService.cj",
                    "--report",
                    str(report_path),
                ],
                cwd=PROJECT_ROOT,
                capture_output=True,
                text=True,
                check=False,
                env=env,
            )
            self.assertEqual(result.returncode, 0, msg=result.stderr or result.stdout)
            payload = json.loads(summary_path.read_text(encoding="utf-8"))
            self.assertEqual(payload["scenario_mode"], "smoke")
            self.assertEqual(payload["overall_status"], "passed")
            assertions = {item["assertion_id"]: item for item in payload["assertions"]}
            self.assertEqual(assertions["SMOKE-LAUNCH-001"]["status"], "passed")
            validator = self.run_validator(summary_path, report_path)
            self.assertEqual(validator.returncode, 0, msg=validator.stderr or validator.stdout)

    def test_refresh_harness_is_valid_bash_and_has_help(self) -> None:
        syntax = subprocess.run(
            ["bash", "-n", str(REFRESH_PATH)],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(syntax.returncode, 0, msg=syntax.stderr or syntax.stdout)
        help_result = subprocess.run(
            ["bash", str(REFRESH_PATH), "--help"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(help_result.returncode, 0, msg=help_result.stderr or help_result.stdout)
        self.assertIn("Usage:", help_result.stdout)


if __name__ == "__main__":
    unittest.main()
