from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import verifier  # noqa: E402


class VerifierToolchainDiscoveryTests(unittest.TestCase):
    def create_repo_local_toolchain(self, repo_root: Path) -> Path:
        compiler_home = repo_root / "artifacts" / "toolchains" / "cangjie-sdk-linux-x64-6.1.0.818-unzip" / "cangjie"
        compiler_path = compiler_home / "build-tools" / "bin" / "cjc"
        package_manager_path = compiler_home / "build-tools" / "tools" / "bin" / "cjpm"
        stdlib_path = compiler_home / "build-tools" / "modules" / "linux_x86_64_cjnative" / "std"
        runtime_path = compiler_home / "build-tools" / "runtime" / "lib" / "linux_x86_64_cjnative"

        compiler_path.parent.mkdir(parents=True, exist_ok=True)
        compiler_path.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
        compiler_path.chmod(0o755)

        package_manager_path.parent.mkdir(parents=True, exist_ok=True)
        package_manager_path.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
        package_manager_path.chmod(0o755)

        stdlib_path.mkdir(parents=True, exist_ok=True)
        runtime_path.mkdir(parents=True, exist_ok=True)
        return compiler_home

    def test_normalize_verification_config_auto_discovers_repo_local_toolchain(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            repo_root = Path(temp_dir)
            compiler_home = self.create_repo_local_toolchain(repo_root).resolve()

            with mock.patch.object(verifier, "PROJECT_ROOT", repo_root), mock.patch.object(verifier.platform, "system", return_value="Linux"), mock.patch.object(verifier.platform, "machine", return_value="x86_64"):
                config = verifier.normalize_verification_config(verifier.VerificationConfig())

            self.assertEqual(config.compiler_home, str(compiler_home))
            self.assertEqual(config.compiler_executable, str((compiler_home / "build-tools" / "bin" / "cjc").resolve()))
            self.assertEqual(config.package_manager_executable, str((compiler_home / "build-tools" / "tools" / "bin" / "cjpm").resolve()))
            self.assertEqual(config.tool_bin_path, str((compiler_home / "build-tools" / "tools" / "bin").resolve()))
            self.assertEqual(config.stdlib_path, str((compiler_home / "build-tools" / "modules" / "linux_x86_64_cjnative" / "std").resolve()))
            self.assertEqual(config.runtime_lib_path, str((compiler_home / "build-tools" / "runtime" / "lib" / "linux_x86_64_cjnative").resolve()))

    def test_normalize_verification_config_ignores_invalid_env_and_falls_back_to_repo_toolchain(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            repo_root = Path(temp_dir)
            compiler_home = self.create_repo_local_toolchain(repo_root).resolve()
            env_overrides = {
                "DEVECO_CANGJIE_PATH": "//artifacts/broken-sdk",
                "CANGJIE_HARMONY_SDK_PATH": "//artifacts/broken-sdk",
                "CANGJIE_HOME": "//artifacts/broken-sdk",
            }

            with mock.patch.object(verifier, "PROJECT_ROOT", repo_root), mock.patch.object(verifier.platform, "system", return_value="Linux"), mock.patch.object(verifier.platform, "machine", return_value="x86_64"), mock.patch.dict(verifier.os.environ, env_overrides, clear=False):
                config = verifier.normalize_verification_config(verifier.VerificationConfig())

            self.assertEqual(config.compiler_home, str(compiler_home))
            self.assertEqual(config.compiler_executable, str((compiler_home / "build-tools" / "bin" / "cjc").resolve()))

    def test_verifier_harness_compile_stage_uses_discovered_absolute_cjc(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            repo_root = Path(temp_dir) / "repo"
            repo_root.mkdir(parents=True, exist_ok=True)
            compiler_home = self.create_repo_local_toolchain(repo_root).resolve()

            attempt_dir = Path(temp_dir) / "attempt-01"
            attempt_dir.mkdir(parents=True, exist_ok=True)
            candidate_path = attempt_dir / "candidate.cj"
            candidate_path.write_text("main(): Int64 {\n    0\n}\n", encoding="utf-8")
            artifact = {
                "metadata": {
                    "workspace_dir": str(attempt_dir.parent),
                    "attempt_dir": str(attempt_dir),
                    "candidate_file_path": str(candidate_path),
                    "candidate_rel_path": candidate_path.name,
                }
            }

            with mock.patch.object(verifier, "PROJECT_ROOT", repo_root), mock.patch.object(verifier.platform, "system", return_value="Linux"), mock.patch.object(verifier.platform, "machine", return_value="x86_64"):
                harness = verifier.VerifierHarness(config=verifier.VerificationConfig())
                result = harness.compile_checker.check({}, artifact, harness.config)

            self.assertTrue(result.passed)
            self.assertEqual(result.command[0], str((compiler_home / "build-tools" / "bin" / "cjc").resolve()))


class VerifierCompileCheckerFallbackTests(unittest.TestCase):
    def build_artifact(self, candidate_path: Path) -> dict:
        return {
            "metadata": {
                "workspace_dir": str(candidate_path.parent),
                "attempt_dir": str(candidate_path.parent),
                "candidate_file_path": str(candidate_path),
                "candidate_rel_path": candidate_path.name,
            }
        }

    def test_nonempty_candidate_without_bytes_metadata_uses_file_size_fallback(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            candidate_path = Path(temp_dir) / "candidate.cj"
            candidate_path.write_text('main(): Int64 {\n    0\n}\n', encoding="utf-8")

            result = verifier.CompileChecker().check({}, self.build_artifact(candidate_path), verifier.VerificationConfig())

            self.assertTrue(result.passed)
            self.assertEqual(result.failure_type, "")
            self.assertEqual(result.stage, "compile")


    def test_default_compile_command_uses_staticlib_for_single_tu_compile(self) -> None:
        config = verifier.VerificationConfig()

        self.assertIn("--output-type staticlib", config.compile_command_template)

    def test_missing_bytes_metadata_still_blocks_physically_empty_candidate(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            candidate_path = Path(temp_dir) / "candidate.cj"
            candidate_path.write_text("", encoding="utf-8")

            result = verifier.CompileChecker().check({}, self.build_artifact(candidate_path), verifier.VerificationConfig())

            self.assertFalse(result.passed)
            self.assertEqual(result.failure_type, "empty-candidate-file")
            self.assertIn("empty generated candidate", result.stderr)

    def test_compile_checker_uses_compile_input_paths_when_present(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            candidate_path = Path(temp_dir) / "candidate.cj"
            dependency_path = Path(temp_dir) / "dep.cj"
            candidate_path.write_text('main(): Int64 {\n    0\n}\n', encoding="utf-8")
            dependency_path.write_text('helper(): Int64 {\n    1\n}\n', encoding="utf-8")
            artifact = self.build_artifact(candidate_path)
            artifact["metadata"]["compile_file_paths"] = [str(candidate_path), str(dependency_path)]

            result = verifier.CompileChecker().check({}, artifact, verifier.VerificationConfig())

            self.assertTrue(result.passed)
            self.assertIn(str(candidate_path), result.command)
            self.assertIn(str(dependency_path), result.command)


class VerifierBehaviorHarnessTests(unittest.TestCase):
    def build_tu(self, target_path: str) -> dict:
        return {
            "target": {
                "path": target_path,
            }
        }

    def build_artifact(self, attempt_dir: Path, *, compile_input_paths: list[str]) -> dict:
        candidate_path = Path(compile_input_paths[0])
        return {
            "metadata": {
                "workspace_dir": str(attempt_dir.parent),
                "attempt_dir": str(attempt_dir),
                "candidate_file_path": str(candidate_path),
                "candidate_rel_path": candidate_path.name,
                "compile_file_paths": compile_input_paths,
            }
        }

    def test_behavior_checker_uses_mtproto_harness_for_supported_target(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            attempt_dir = Path(temp_dir) / "attempt-01"
            attempt_dir.mkdir(parents=True, exist_ok=True)
            candidate_path = attempt_dir / "src" / "core" / "mtproto" / "MTProtoTransport.cj"
            candidate_path.parent.mkdir(parents=True, exist_ok=True)
            candidate_path.write_text("package core.mtproto\n\npublic class TCPTransport {}\n", encoding="utf-8")
            dependency_path = attempt_dir / "src" / "core" / "mtproto" / "MTProtoConfig.cj"
            dependency_path.write_text("package core.mtproto\n\npublic class MTProtoConfig {}\n", encoding="utf-8")
            artifact = self.build_artifact(attempt_dir, compile_input_paths=[str(candidate_path), str(dependency_path)])

            result = verifier.BehaviorMockChecker().check(
                self.build_tu("src/core/mtproto/MTProtoTransport.ets"),
                artifact,
                verifier.VerificationConfig(),
            )

            self.assertTrue(result.passed)
            self.assertEqual(result.stage, "behavior")
            self.assertEqual(result.command[0], "cjc")
            self.assertIn("--test", result.command)
            self.assertIn(str(candidate_path), result.command)
            self.assertIn(str(dependency_path), result.command)
            self.assertIn("&&", result.command)
            self.assertTrue(any(part.endswith("mtprototransport_test.cj") for part in result.command))
            self.assertTrue(any(part.endswith("mtproto_behavior_test_support.cj") for part in result.command))
            self.assertIn(str(attempt_dir / "behavior_harness_tests"), result.command)

    def test_behavior_checker_falls_back_to_template_for_unsupported_target(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            attempt_dir = Path(temp_dir) / "attempt-01"
            attempt_dir.mkdir(parents=True, exist_ok=True)
            candidate_path = attempt_dir / "candidate.cj"
            candidate_path.write_text("main(): Int64 {\n    0\n}\n", encoding="utf-8")
            artifact = self.build_artifact(attempt_dir, compile_input_paths=[str(candidate_path)])

            result = verifier.BehaviorMockChecker().check(
                self.build_tu("src/services/RealMessageService.ets"),
                artifact,
                verifier.VerificationConfig(),
            )

            self.assertTrue(result.passed)
            self.assertEqual(["python", "-c", 'print("behavior-ok")'], result.command)

    def test_behavior_checker_uses_crypto_utils_specific_test_without_shared_support(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            attempt_dir = Path(temp_dir) / "attempt-01"
            attempt_dir.mkdir(parents=True, exist_ok=True)
            candidate_path = attempt_dir / "src" / "core" / "mtproto" / "CryptoUtils.cj"
            candidate_path.parent.mkdir(parents=True, exist_ok=True)
            candidate_path.write_text("package core.mtproto\n\npublic class ByteUtils {}\n", encoding="utf-8")
            artifact = self.build_artifact(attempt_dir, compile_input_paths=[str(candidate_path)])

            result = verifier.BehaviorMockChecker().check(
                self.build_tu("src/core/mtproto/CryptoUtils.ets"),
                artifact,
                verifier.VerificationConfig(),
            )

            self.assertTrue(result.passed)
            self.assertTrue(any(part.endswith("crypto_utils_test.cj") for part in result.command))
            self.assertFalse(any(part.endswith("mtproto_behavior_test_support.cj") for part in result.command))

    def test_behavior_checker_uses_tlserialization_and_mtprotoconfig_support_files(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            attempt_dir = Path(temp_dir) / "attempt-01"
            attempt_dir.mkdir(parents=True, exist_ok=True)
            tl_candidate = attempt_dir / "src" / "core" / "mtproto" / "TLSerialization.cj"
            config_candidate = attempt_dir / "src" / "core" / "mtproto" / "MTProtoConfig.cj"
            tl_candidate.parent.mkdir(parents=True, exist_ok=True)
            tl_candidate.write_text("package core.mtproto\n\npublic class TLSerializer {}\npublic class TLDeserializer {}\n", encoding="utf-8")
            config_candidate.write_text("package core.mtproto\n\npublic class SessionInfo {}\npublic class SessionManager {}\n", encoding="utf-8")

            tl_result = verifier.BehaviorMockChecker().check(
                self.build_tu("src/core/mtproto/TLSerialization.ets"),
                self.build_artifact(attempt_dir, compile_input_paths=[str(tl_candidate)]),
                verifier.VerificationConfig(),
            )
            config_result = verifier.BehaviorMockChecker().check(
                self.build_tu("src/core/mtproto/MTProtoConfig.ets"),
                self.build_artifact(attempt_dir, compile_input_paths=[str(config_candidate)]),
                verifier.VerificationConfig(),
            )

            self.assertTrue(tl_result.passed)
            self.assertTrue(config_result.passed)
            self.assertTrue(any(part.endswith("tlserialization_test.cj") for part in tl_result.command))
            self.assertTrue(any(part.endswith("mtprotoconfig_test.cj") for part in config_result.command))
            self.assertTrue(any(part.endswith("mtproto_behavior_test_support.cj") for part in tl_result.command))
            self.assertTrue(any(part.endswith("mtproto_behavior_test_support.cj") for part in config_result.command))

    def test_behavior_checker_uses_mtprotoclient_specific_test_with_shared_support(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            attempt_dir = Path(temp_dir) / "attempt-01"
            attempt_dir.mkdir(parents=True, exist_ok=True)
            candidate_path = attempt_dir / "src" / "core" / "mtproto" / "MTProtoClient.cj"
            candidate_path.parent.mkdir(parents=True, exist_ok=True)
            candidate_path.write_text("package core.mtproto\n\npublic class MTProtoClient {}\n", encoding="utf-8")
            dependency_paths = [
                attempt_dir / "src" / "core" / "mtproto" / "MTProtoTransport.cj",
                attempt_dir / "src" / "core" / "mtproto" / "MTProtoConfig.cj",
                attempt_dir / "src" / "core" / "mtproto" / "AuthKeyCreator.cj",
                attempt_dir / "src" / "core" / "mtproto" / "TLMethods.cj",
                attempt_dir / "src" / "core" / "mtproto" / "Inflate.cj",
            ]
            for path in dependency_paths:
                path.write_text("package core.mtproto\n", encoding="utf-8")

            result = verifier.BehaviorMockChecker().check(
                self.build_tu("src/core/mtproto/MTProtoClient.ets"),
                self.build_artifact(
                    attempt_dir,
                    compile_input_paths=[str(candidate_path), *(str(path) for path in dependency_paths)],
                ),
                verifier.VerificationConfig(),
            )

            self.assertTrue(result.passed)
            self.assertTrue(any(part.endswith("mtprotoclient_test.cj") for part in result.command))
            self.assertTrue(any(part.endswith("mtproto_behavior_test_support.cj") for part in result.command))


class CommandRunnerTimeoutTests(unittest.TestCase):
    def test_timeoutexpired_bytes_payload_is_normalized_without_crashing(self) -> None:
        timeout_error = verifier.subprocess.TimeoutExpired(
            cmd=["fake-binary"],
            timeout=3,
            output=b"partial stdout",
            stderr=b"partial stderr",
        )
        runner = verifier.CommandRunner()

        with mock.patch.object(verifier.subprocess, "run", side_effect=timeout_error):
            result = runner.run(
                stage="behavior",
                command=["fake-binary"],
                cwd=None,
                timeout_seconds=3,
                is_dry_run=False,
            )

        self.assertFalse(result.passed)
        self.assertEqual("timeout", result.failure_type)
        self.assertIn("partial stderr", result.stderr)
        self.assertIn("command timed out", result.stderr)
        self.assertIsInstance(result.stdout, str)
        self.assertIsInstance(result.stderr, str)


if __name__ == "__main__":
    unittest.main()
