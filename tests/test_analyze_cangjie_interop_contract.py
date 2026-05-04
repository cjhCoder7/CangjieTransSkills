from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = PROJECT_ROOT / "scripts" / "analyze_cangjie_interop_contract.py"


class AnalyzeCangjieInteropContractTests(unittest.TestCase):
    def run_script(self, project_root: Path, output_format: str = "json") -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                "python3",
                str(SCRIPT_PATH),
                "--project-root",
                str(project_root),
                "--format",
                output_format,
            ],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )

    def write_loader_files(self, project_root: Path) -> None:
        entry_root = project_root / "entry"
        loader_root = entry_root / "src" / "main" / "cangjie" / "loader"
        loader_root.mkdir(parents=True, exist_ok=True)
        (entry_root / "oh-package.json5").write_text(
            """
{
  "dependencies": {
    "libark_interop_loader.so": "file:./src/main/cangjie/loader"
  }
}
""".strip()
            + "\n",
            encoding="utf-8",
        )
        (loader_root / "libark_interop_loader.d.ts").write_text(
            'export declare function requireCJLib(name: string): Object\n',
            encoding="utf-8",
        )

    def write_cangjie_exports(self, project_root: Path) -> None:
        cangjie_root = project_root / "entry" / "src" / "main" / "cangjie"
        cangjie_root.mkdir(parents=True, exist_ok=True)
        (cangjie_root / "index.cj").write_text(
            """
package ohos_app_cangjie_entry

internal import ohos.ark_interop.JSModule
internal import ohos.ark_interop.JSContext
internal import ohos.ark_interop.JSCallInfo
internal import ohos.ark_interop.JSValue

func testCJ(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    runtime.string("ok").toJSValue()
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports => exports["testCJ"] = runtime.function(testCJ).toJSValue()
}
""".strip()
            + "\n",
            encoding="utf-8",
        )

    def write_generated_default_types(self, project_root: Path) -> None:
        types_root = project_root / "entry" / "src" / "main" / "cangjie" / "types" / "libohos_app_cangjie_entry"
        types_root.mkdir(parents=True, exist_ok=True)
        (types_root / "Index.d.ts").write_text(
            """
declare const _default: {
  testCJ(value: string): string;
};

export default _default;
""".strip()
            + "\n",
            encoding="utf-8",
        )

    def write_direct_named_import_page(self, project_root: Path) -> None:
        page_root = project_root / "entry" / "src" / "main" / "ets" / "pages"
        page_root.mkdir(parents=True, exist_ok=True)
        (page_root / "Index.ets").write_text(
            """
import { testCJ } from 'libohos_app_cangjie_entry.so'

@Entry
@Component
struct Index {
  build() {
    Text(testCJ("worker"))
  }
}
""".strip()
            + "\n",
            encoding="utf-8",
        )

    def write_loader_usage_page(self, project_root: Path) -> None:
        page_root = project_root / "entry" / "src" / "main" / "ets" / "pages"
        page_root.mkdir(parents=True, exist_ok=True)
        (page_root / "Index.ets").write_text(
            """
import { requireCJLib } from 'libark_interop_loader.so'

interface CustomLib {
  testCJ(value: string): string
}

let cjlib = requireCJLib("libohos_app_cangjie_entry.so") as CustomLib

@Entry
@Component
struct Index {
  build() {
    Text(cjlib.testCJ("worker"))
  }
}
""".strip()
            + "\n",
            encoding="utf-8",
        )

    def write_direct_default_import_page(self, project_root: Path) -> None:
        page_root = project_root / "entry" / "src" / "main" / "ets" / "pages"
        page_root.mkdir(parents=True, exist_ok=True)
        (page_root / "Index.ets").write_text(
            """
import cjlib from 'libohos_app_cangjie_entry.so'

@Entry
@Component
struct Index {
  build() {
    Text(cjlib.testCJ("worker"))
  }
}
""".strip()
            + "\n",
            encoding="utf-8",
        )

    def test_reports_mismatch_when_named_import_targets_cangjie_so(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            self.write_loader_files(project_root)
            self.write_cangjie_exports(project_root)
            self.write_generated_default_types(project_root)
            self.write_direct_named_import_page(project_root)

            result = self.run_script(project_root)

            self.assertEqual(2, result.returncode, msg=result.stderr or result.stdout)
            payload = json.loads(result.stdout)
            self.assertEqual("mismatch", payload["assessment"]["status"])
            self.assertEqual("loader-object", payload["assessment"]["recommended_contract_shape"])
            self.assertIn("direct_named_import_on_cangjie_so", payload["assessment"]["issue_codes"])
            self.assertIn("testCJ", payload["arkts_direct_imports"][0]["symbols"])

    def test_reports_mismatch_when_default_import_bypasses_loader_path(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            self.write_loader_files(project_root)
            self.write_cangjie_exports(project_root)
            self.write_generated_default_types(project_root)
            self.write_direct_default_import_page(project_root)

            result = self.run_script(project_root)

            self.assertEqual(2, result.returncode, msg=result.stderr or result.stdout)
            payload = json.loads(result.stdout)
            self.assertEqual("mismatch", payload["assessment"]["status"])
            self.assertEqual("loader-object", payload["assessment"]["recommended_contract_shape"])
            self.assertIn("direct_import_bypasses_loader_path", payload["assessment"]["issue_codes"])
            self.assertEqual("default", payload["arkts_direct_imports"][0]["mode"])

    def test_reports_aligned_when_loader_contract_is_used(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            project_root = Path(temp_dir)
            self.write_loader_files(project_root)
            self.write_cangjie_exports(project_root)
            self.write_generated_default_types(project_root)
            self.write_loader_usage_page(project_root)

            result = self.run_script(project_root)

            self.assertEqual(0, result.returncode, msg=result.stderr or result.stdout)
            payload = json.loads(result.stdout)
            self.assertEqual("aligned", payload["assessment"]["status"])
            self.assertEqual("loader-object", payload["assessment"]["recommended_contract_shape"])
            self.assertEqual([], payload["assessment"]["issue_codes"])
            self.assertTrue(payload["loader"]["available"])
            self.assertEqual(["testCJ"], payload["cangjie_exports"][0]["symbols"])


if __name__ == "__main__":
    unittest.main()
