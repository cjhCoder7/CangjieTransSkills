from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import pipeline_runner  # noqa: E402


class PipelineRunnerDefaultRefreshTemplateTests(unittest.TestCase):
    def test_existing_summary_skips_builtin_template_on_first_cycle(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            summary_path = Path(temp_dir) / "summary.json"
            summary_path.write_text("{}\n", encoding="utf-8")
            template, source = pipeline_runner.resolve_full_pass_refresh_template(
                explicit_template=None,
                summary_path=summary_path,
                cycle=1,
                force_refresh=False,
            )
            self.assertIsNone(template)
            self.assertEqual(source, "existing-summary-no-refresh-command")

    def test_missing_summary_uses_builtin_template(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            summary_path = Path(temp_dir) / "summary.json"
            template, source = pipeline_runner.resolve_full_pass_refresh_template(
                explicit_template=None,
                summary_path=summary_path,
                cycle=1,
                force_refresh=False,
            )
            self.assertEqual(source, "builtin-default")
            self.assertEqual(template, pipeline_runner.DEFAULT_FULL_PASS_REFRESH_CMD_TEMPLATE)
            self.assertIn("scripts/full-pass-harmony-refresh.sh", template)
            self.assertIn("--cycle {cycle}", template)

    def test_retry_cycle_forces_builtin_template_even_when_summary_exists(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            summary_path = Path(temp_dir) / "summary.json"
            summary_path.write_text("{}\n", encoding="utf-8")
            template, source = pipeline_runner.resolve_full_pass_refresh_template(
                explicit_template=None,
                summary_path=summary_path,
                cycle=2,
                force_refresh=True,
            )
            self.assertEqual(source, "builtin-default")
            self.assertEqual(template, pipeline_runner.DEFAULT_FULL_PASS_REFRESH_CMD_TEMPLATE)

    def test_explicit_template_has_highest_priority(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            summary_path = Path(temp_dir) / "summary.json"
            summary_path.write_text("{}\n", encoding="utf-8")
            template, source = pipeline_runner.resolve_full_pass_refresh_template(
                explicit_template="bash -lc 'echo custom-refresh'",
                summary_path=summary_path,
                cycle=1,
                force_refresh=False,
            )
            self.assertEqual(source, "user-provided")
            self.assertEqual(template, "bash -lc 'echo custom-refresh'")


if __name__ == "__main__":
    unittest.main()
