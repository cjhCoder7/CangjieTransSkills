from __future__ import annotations

import json
import os
import subprocess
import tempfile
import time
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = PROJECT_ROOT / "scripts" / "find_harmony_artifact.py"


class FindHarmonyArtifactTests(unittest.TestCase):
    def run_script(
        self,
        project_root: Path,
        output_format: str = "json",
        extra_args: list[str] | None = None,
    ) -> subprocess.CompletedProcess[str]:
        command = [
            "python3",
            str(SCRIPT_PATH),
            "--project-root",
            str(project_root),
            "--format",
            output_format,
        ]
        if extra_args:
            command.extend(extra_args)
        return subprocess.run(
            command,
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )

    def write_project_metadata(self, project_root: Path) -> None:
        appscope = project_root / "AppScope"
        module_main = project_root / "entry" / "src" / "main"
        appscope.mkdir(parents=True, exist_ok=True)
        module_main.mkdir(parents=True, exist_ok=True)
        (appscope / "app.json5").write_text(
            """
{
  "app": {
    "bundleName": "com.example.deveco_cangjie_control_project"
  }
}
""".strip()
            + "\n",
            encoding="utf-8",
        )
        (module_main / "module.json5").write_text(
            """
{
  "module": {
    "mainElement": "EntryAbility",
    "abilities": [
      {
        "name": "EntryAbility"
      }
    ]
  }
}
""".strip()
            + "\n",
            encoding="utf-8",
        )

    def write_host_probe(self, output_path: Path, *, hdc_targets: list[str] | None = None) -> None:
        payload = {
            "host": {
                "os": "Microsoft Windows 11 家庭中文版",
                "kernel": "10.0.26200.26200",
                "arch": "64-bit",
                "hostname": "test-host",
            },
            "paths": {
                "deveco_studio_home": r"C:\Users\18489\AppData\Local\Programs\DevEcoStudio-6.0.2.650",
                "hdc": r"C:\Users\18489\AppData\Local\OpenHarmony\Sdk\20\toolchains\hdc.exe",
            },
            "device_connectivity": {
                "target_channel_ready": True,
                "hdc_target_count": len(hdc_targets or ["127.0.0.1:5555"]),
                "hdc_targets": hdc_targets or ["127.0.0.1:5555"],
            },
            "assessment": {
                "staging_full_ready": True,
            },
        }
        output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8-sig")

    def test_reports_latest_hap_and_project_metadata_as_json(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            self.write_project_metadata(project_root)

            older_hap = project_root / "entry" / "build" / "default" / "outputs" / "default" / "entry-default-unsigned.hap"
            newer_hap = project_root / "entry" / "build" / "release" / "outputs" / "default" / "entry-release-signed.hap"
            older_hap.parent.mkdir(parents=True, exist_ok=True)
            newer_hap.parent.mkdir(parents=True, exist_ok=True)
            older_hap.write_text("older", encoding="utf-8")
            newer_hap.write_text("newer", encoding="utf-8")
            now = time.time()
            os.utime(older_hap, (now - 60, now - 60))
            os.utime(newer_hap, (now, now))

            result = self.run_script(project_root, "json")

            self.assertEqual(0, result.returncode, msg=result.stderr or result.stdout)
            payload = json.loads(result.stdout)
            self.assertEqual(str(project_root.resolve()), payload["project_root"])
            self.assertEqual("com.example.deveco_cangjie_control_project", payload["bundle_name"])
            self.assertEqual("EntryAbility", payload["ability_name"])
            self.assertEqual(str(newer_hap.resolve()), payload["latest_hap_path"])
            self.assertEqual(2, len(payload["hap_candidates"]))

    def test_env_format_prints_exports_for_latest_hap(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            self.write_project_metadata(project_root)
            hap_path = project_root / "entry" / "build" / "release" / "outputs" / "default" / "entry-release-signed.hap"
            hap_path.parent.mkdir(parents=True, exist_ok=True)
            hap_path.write_text("hap", encoding="utf-8")

            result = self.run_script(project_root, "env")

            self.assertEqual(0, result.returncode, msg=result.stderr or result.stdout)
            self.assertIn('FULL_PASS_PKG_NAME="com.example.deveco_cangjie_control_project"', result.stdout)
            self.assertIn('FULL_PASS_ABILITY_NAME="EntryAbility"', result.stdout)
            self.assertIn(f'FULL_PASS_HAP_PATH="{hap_path.resolve().as_posix()}"', result.stdout)

    def test_returns_exit_code_2_when_project_has_no_hap_yet(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            self.write_project_metadata(project_root)

            result = self.run_script(project_root, "json")

            self.assertEqual(2, result.returncode, msg=result.stderr or result.stdout)
            payload = json.loads(result.stdout)
            self.assertEqual("com.example.deveco_cangjie_control_project", payload["bundle_name"])
            self.assertEqual("EntryAbility", payload["ability_name"])
            self.assertEqual("", payload["latest_hap_path"])
            self.assertEqual([], payload["hap_candidates"])

    def test_env_format_can_merge_host_probe_facts_for_full_pass_local(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            self.write_project_metadata(project_root)
            host_probe_path = project_root / "artifacts" / "environment" / "full-pass-host-profile.windows.json"
            host_probe_path.parent.mkdir(parents=True, exist_ok=True)
            self.write_host_probe(host_probe_path)

            result = self.run_script(
                project_root,
                "env",
                [
                    "--host-probe-json",
                    str(host_probe_path),
                    "--target-name",
                    "Enjoy 90 Pro Max",
                ],
            )

            self.assertEqual(2, result.returncode, msg=result.stderr or result.stdout)
            self.assertIn('FULL_PASS_HOST_OS="windows"', result.stdout)
            self.assertIn('FULL_PASS_DEVECO_STUDIO_HOME="C:/Users/18489/AppData/Local/Programs/DevEcoStudio-6.0.2.650"', result.stdout)
            self.assertIn('FULL_PASS_HARMONY_SDK_HOME="C:/Users/18489/AppData/Local/OpenHarmony/Sdk/20"', result.stdout)
            self.assertIn('FULL_PASS_HDC_PATH="C:/Users/18489/AppData/Local/OpenHarmony/Sdk/20/toolchains/hdc.exe"', result.stdout)
            self.assertIn(f'FULL_PASS_HOST_PROBE_JSON="{host_probe_path.as_posix()}"', result.stdout)
            self.assertIn('FULL_PASS_TARGET_TYPE="emulator"', result.stdout)
            self.assertIn('FULL_PASS_HDC_SERIAL="127.0.0.1:5555"', result.stdout)
            self.assertIn('FULL_PASS_TARGET_ID="$FULL_PASS_HDC_SERIAL"', result.stdout)
            self.assertIn('FULL_PASS_TARGET_NAME="Enjoy 90 Pro Max"', result.stdout)
            self.assertIn('# FULL_PASS_HAP_PATH="<missing: build the project to produce a .hap artifact>"', result.stdout)
            self.assertIn('FULL_PASS_EXERCISE_CMD="\\"$FULL_PASS_HDC_PATH\\" -t \\"$FULL_PASS_HDC_SERIAL\\" shell uitest dumpLayout -b \\"$FULL_PASS_PKG_NAME\\""', result.stdout)

    def test_json_format_includes_host_probe_payload_when_requested(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            self.write_project_metadata(project_root)
            hap_path = project_root / "entry" / "build" / "release" / "outputs" / "default" / "entry-release-signed.hap"
            hap_path.parent.mkdir(parents=True, exist_ok=True)
            hap_path.write_text("hap", encoding="utf-8")
            host_probe_path = project_root / "artifacts" / "environment" / "full-pass-host-profile.windows.json"
            host_probe_path.parent.mkdir(parents=True, exist_ok=True)
            self.write_host_probe(host_probe_path, hdc_targets=[])

            result = self.run_script(
                project_root,
                "json",
                [
                    "--host-probe-json",
                    str(host_probe_path),
                    "--target-id",
                    "device-serial-001",
                    "--target-name",
                    "Lab Device",
                    "--target-type",
                    "device",
                ],
            )

            self.assertEqual(0, result.returncode, msg=result.stderr or result.stdout)
            payload = json.loads(result.stdout)
            self.assertEqual(str(hap_path.resolve()), payload["latest_hap_path"])
            self.assertEqual("windows", payload["host_probe"]["host_os"])
            self.assertEqual("device-serial-001", payload["host_probe"]["target_id"])
            self.assertEqual("Lab Device", payload["host_probe"]["target_name"])
            self.assertEqual("device", payload["host_probe"]["target_type"])


if __name__ == "__main__":
    unittest.main()
