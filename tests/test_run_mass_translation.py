from __future__ import annotations

import json
import os
import subprocess
import tempfile
import unittest
from contextlib import contextmanager
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = PROJECT_ROOT / "scripts" / "run_mass_translation.sh"
DEFAULT_MANIFEST = PROJECT_ROOT / "docs" / "manifests" / "batch_manifest_phase05.json"
REPO_LOCAL_CANGJIE_HOME = (
    PROJECT_ROOT / "artifacts" / "toolchains" / "cangjie-sdk-linux-x64-6.1.0.818-unzip" / "cangjie"
)


class RunMassTranslationScriptTests(unittest.TestCase):
    @contextmanager
    def _swap_env_local(self, content: str):
        env_local_path = PROJECT_ROOT / ".env.local"
        original_exists = env_local_path.exists()
        original_content = env_local_path.read_text(encoding="utf-8") if original_exists else None
        try:
            env_local_path.write_text(content, encoding="utf-8")
            yield
        finally:
            if original_exists and original_content is not None:
                env_local_path.write_text(original_content, encoding="utf-8")
            elif env_local_path.exists():
                env_local_path.unlink()

    def _write_fake_python(self, temp_path: Path) -> None:
        fake_python = temp_path / "python"
        fake_python.write_text(
            """#!/usr/bin/env python3
import json
import os
import sys
from pathlib import Path

capture_path = Path(os.environ[\"RUN_MASS_TRANSLATION_CAPTURE_PATH\"])
capture_path.write_text(
    json.dumps(
        {
            \"argv\": sys.argv[1:],
            \"env\": {
                \"SILICONFLOW_API_KEY\": os.environ.get(\"SILICONFLOW_API_KEY\", \"\"),
                \"CANGJIE_HOME\": os.environ.get(\"CANGJIE_HOME\", \"\"),
                \"CANGJIE_STDLIB_PATH\": os.environ.get(\"CANGJIE_STDLIB_PATH\", \"\"),
            },
        },
        ensure_ascii=False,
    ),
    encoding=\"utf-8\",
)
raise SystemExit(0)
""",
            encoding="utf-8",
        )
        fake_python.chmod(0o755)

    def test_supports_noninteractive_key_injection_via_stdin(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            capture_path = temp_path / "capture.json"
            self._write_fake_python(temp_path)

            env = os.environ.copy()
            env["PATH"] = f"{temp_path}:{env.get('PATH', '')}"
            env.pop("SILICONFLOW_API_KEY", None)
            env["RUN_MASS_TRANSLATION_CAPTURE_PATH"] = str(capture_path)

            result = subprocess.run(
                ["bash", str(SCRIPT_PATH), "--read-key-from-stdin", str(DEFAULT_MANIFEST)],
                cwd=PROJECT_ROOT,
                env=env,
                input="sf-test-key\n",
                capture_output=True,
                text=True,
                check=False,
            )

            self.assertEqual(0, result.returncode, msg=result.stderr)
            payload = json.loads(capture_path.read_text(encoding="utf-8"))
            self.assertEqual("sf-test-key", payload["env"]["SILICONFLOW_API_KEY"])
            self.assertEqual(str(REPO_LOCAL_CANGJIE_HOME), payload["env"]["CANGJIE_HOME"])
            self.assertEqual(
                str(PROJECT_ROOT / "scripts" / "pipeline_batch_runner.py"),
                payload["argv"][0],
            )
            self.assertIn("--manifest", payload["argv"])
            self.assertIn(str(DEFAULT_MANIFEST), payload["argv"])
            self.assertIn("--continue-on-error", payload["argv"])

    def test_allows_keyless_launch_when_manifest_is_fully_frozen(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            capture_path = temp_path / "capture.json"
            manifest_path = temp_path / "frozen-batch.json"
            manifest_path.write_text(
                json.dumps(
                    {
                        "batch_name": "phase05-frozen-batch",
                        "ordered_targets": [
                            {
                                "file": "src/services/FrozenService.ets",
                                "pipeline_overrides": {
                                    "frozen_candidate_file": "../anchors/FrozenService.cj"
                                },
                            }
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )
            self._write_fake_python(temp_path)

            env = os.environ.copy()
            env["PATH"] = f"{temp_path}:{env.get('PATH', '')}"
            env.pop("SILICONFLOW_API_KEY", None)
            env["RUN_MASS_TRANSLATION_CAPTURE_PATH"] = str(capture_path)

            result = subprocess.run(
                ["bash", str(SCRIPT_PATH), str(manifest_path)],
                cwd=PROJECT_ROOT,
                env=env,
                capture_output=True,
                text=True,
                check=False,
            )

            self.assertEqual(0, result.returncode, msg=result.stderr)
            payload = json.loads(capture_path.read_text(encoding="utf-8"))
            self.assertEqual("", payload["env"]["SILICONFLOW_API_KEY"])
            self.assertIn("--manifest", payload["argv"])
            self.assertIn(str(manifest_path), payload["argv"])

    def test_loads_key_from_env_local_for_non_frozen_manifest(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            capture_path = temp_path / "capture.json"
            manifest_path = temp_path / "fresh-batch.json"
            manifest_path.write_text(
                json.dumps(
                    {
                        "batch_name": "phase05-fresh-batch",
                        "ordered_targets": [
                            {"file": "src/services/FreshService.ets"}
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )
            self._write_fake_python(temp_path)

            env = os.environ.copy()
            env["PATH"] = f"{temp_path}:{env.get('PATH', '')}"
            env.pop("SILICONFLOW_API_KEY", None)
            env["RUN_MASS_TRANSLATION_CAPTURE_PATH"] = str(capture_path)

            with self._swap_env_local("SILICONFLOW_API_KEY=sf-env-local-key\n"):
                result = subprocess.run(
                    ["bash", str(SCRIPT_PATH), str(manifest_path)],
                    cwd=PROJECT_ROOT,
                    env=env,
                    capture_output=True,
                    text=True,
                    check=False,
                )

            self.assertEqual(0, result.returncode, msg=result.stderr)
            payload = json.loads(capture_path.read_text(encoding="utf-8"))
            self.assertEqual("sf-env-local-key", payload["env"]["SILICONFLOW_API_KEY"])

    def test_falls_back_to_openai_api_key_from_env_local(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            capture_path = temp_path / "capture.json"
            manifest_path = temp_path / "fresh-batch.json"
            manifest_path.write_text(
                json.dumps(
                    {
                        "batch_name": "phase05-fresh-batch",
                        "ordered_targets": [
                            {"file": "src/services/FreshService.ets"}
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )
            self._write_fake_python(temp_path)

            env = os.environ.copy()
            env["PATH"] = f"{temp_path}:{env.get('PATH', '')}"
            env.pop("SILICONFLOW_API_KEY", None)
            env.pop("OPENAI_API_KEY", None)
            env["RUN_MASS_TRANSLATION_CAPTURE_PATH"] = str(capture_path)

            with self._swap_env_local("OPENAI_API_KEY=sf-openai-fallback-key\n"):
                result = subprocess.run(
                    ["bash", str(SCRIPT_PATH), str(manifest_path)],
                    cwd=PROJECT_ROOT,
                    env=env,
                    capture_output=True,
                    text=True,
                    check=False,
                )

            self.assertEqual(0, result.returncode, msg=result.stderr)
            payload = json.loads(capture_path.read_text(encoding="utf-8"))
            self.assertEqual("sf-openai-fallback-key", payload["env"]["SILICONFLOW_API_KEY"])

    def test_current_process_env_overrides_env_local_key(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            capture_path = temp_path / "capture.json"
            manifest_path = temp_path / "fresh-batch.json"
            manifest_path.write_text(
                json.dumps(
                    {
                        "batch_name": "phase05-fresh-batch",
                        "ordered_targets": [
                            {"file": "src/services/FreshService.ets"}
                        ],
                    },
                    ensure_ascii=False,
                    indent=2,
                ),
                encoding="utf-8",
            )
            self._write_fake_python(temp_path)

            env = os.environ.copy()
            env["PATH"] = f"{temp_path}:{env.get('PATH', '')}"
            env["SILICONFLOW_API_KEY"] = "sf-process-env-key"
            env["RUN_MASS_TRANSLATION_CAPTURE_PATH"] = str(capture_path)

            with self._swap_env_local("SILICONFLOW_API_KEY=sf-env-local-key\n"):
                result = subprocess.run(
                    ["bash", str(SCRIPT_PATH), str(manifest_path)],
                    cwd=PROJECT_ROOT,
                    env=env,
                    capture_output=True,
                    text=True,
                    check=False,
                )

            self.assertEqual(0, result.returncode, msg=result.stderr)
            payload = json.loads(capture_path.read_text(encoding="utf-8"))
            self.assertEqual("sf-process-env-key", payload["env"]["SILICONFLOW_API_KEY"])


if __name__ == "__main__":
    unittest.main()