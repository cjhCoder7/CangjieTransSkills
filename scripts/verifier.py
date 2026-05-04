#!/usr/bin/env python3
"""三段式验证器外壳。

功能：
1. 提供 `CompileChecker`、`UnitTestChecker`、`BehaviorMockChecker` 三段式验证框架；
2. 默认以 dry-run / mock 模式运行，便于在缺少真实 `cjc` / `cjpm` 环境时完成联调；
3. 支持注入真实编译器绝对路径、SDK 根目录、标准库路径、运行时库路径与额外环境变量；
4. 精确捕获 subprocess 的 stdout / stderr / OSError / timeout，并尽量抽取带行号的诊断信息。
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import platform
import re
import shlex
import subprocess
import time
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Dict, List, Mapping, MutableMapping, Optional, Sequence, Tuple

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_DIR = PROJECT_ROOT / "artifacts" / "verification"
MTPROTO_BEHAVIOR_HARNESS_ROOT = PROJECT_ROOT / "samples" / "mtproto-core-behavior-harness-001" / "src"
MTPROTO_BEHAVIOR_HARNESS_SPECS: Dict[str, Dict[str, object]] = {
    "src/core/mtproto/CryptoUtils.ets": {
        "tests": ["crypto_utils_test.cj"],
        "support": [],
    },
    "src/core/mtproto/TLSerialization.ets": {
        "tests": ["tlserialization_test.cj"],
        "support": ["mtproto_behavior_test_support.cj"],
    },
    "src/core/mtproto/MTProtoConfig.ets": {
        "tests": ["mtprotoconfig_test.cj"],
        "support": ["mtproto_behavior_test_support.cj"],
    },
    "src/core/mtproto/MTProtoTransport.ets": {
        "tests": ["mtprototransport_test.cj"],
        "support": ["mtproto_behavior_test_support.cj"],
    },
    "src/core/mtproto/AuthKeyCreator.ets": {
        "tests": ["authkeycreator_test.cj"],
        "support": ["mtproto_behavior_test_support.cj"],
    },
    "src/core/mtproto/Inflate.ets": {
        "tests": ["inflate_test.cj"],
        "support": ["mtproto_behavior_test_support.cj"],
    },
    "src/core/mtproto/MTProtoClient.ets": {
        "tests": ["mtprotoclient_test.cj"],
        "support": ["mtproto_behavior_test_support.cj"],
    },
}

COMPILER_ERROR_PATTERNS = (
    re.compile(r"(?P<file>[^:\n]+):(?P<line>\d+):(?P<column>\d+):\s*(?P<message>[^\n]+)"),
    re.compile(r"(?P<file>[^:\n]+):(?P<line>\d+):\s*(?P<message>[^\n]+)"),
)
ANSI_ESCAPE_RE = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
COMPILER_HOME_ENV_KEYS = (
    "DEVECO_CANGJIE_PATH",
    "CANGJIE_HARMONY_SDK_PATH",
    "CANGJIE_HOME",
)


def normalize_subprocess_text(value: object) -> str:
    if value is None:
        return ""
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    return str(value)


@dataclass
class StageResult:
    stage: str
    passed: bool
    mode: str
    command: List[str] = field(default_factory=list)
    exit_code: int = 0
    stdout: str = ""
    stderr: str = ""
    duration_seconds: float = 0.0
    failure_type: str = ""
    diagnostic_excerpt: str = ""
    env_overrides: Dict[str, str] = field(default_factory=dict)


@dataclass
class VerifyResult:
    passed: bool
    status: str
    evidence: List[str] = field(default_factory=list)
    failure_type: str = ""
    stage_results: List[StageResult] = field(default_factory=list)


@dataclass
class VerificationConfig:
    is_dry_run: bool = True
    mock_compiler: bool = True
    mock_unit_test: bool = True
    mock_behavior: bool = True
    compile_command_template: str = "cjc --diagnostic-format noColor --output-type staticlib -o {attempt_dir}/candidate_output {compile_input_paths}"
    unit_test_command_template: str = "cjpm test --package-root {workspace_dir}"
    behavior_command_template: str = "python -c 'print(\"behavior-ok\")'"
    timeout_seconds: int = 120
    working_directory: Optional[str] = None
    compiler_executable: str = ""
    package_manager_executable: str = ""
    compiler_home: str = ""
    stdlib_path: str = ""
    runtime_lib_path: str = ""
    tool_bin_path: str = ""
    extra_env: Dict[str, str] = field(default_factory=dict)
    inject_compat_cangjie_home: bool = True


@dataclass
class BehaviorHarnessPlan:
    compile_command: List[str]
    run_command: List[str]


class CommandRunner:
    def run(
        self,
        *,
        stage: str,
        command: Sequence[str],
        cwd: Optional[Path],
        timeout_seconds: int,
        is_dry_run: bool,
        env_overrides: Optional[Mapping[str, str]] = None,
        simulated_failure_type: str = "",
        simulated_stderr: str = "",
    ) -> StageResult:
        start = time.time()
        env_payload = {key: value for key, value in (env_overrides or {}).items() if value}
        if is_dry_run:
            passed = not bool(simulated_failure_type)
            return StageResult(
                stage=stage,
                passed=passed,
                mode="dry-run",
                command=list(command),
                exit_code=0 if passed else 1,
                stdout="dry-run simulated success" if passed else "",
                stderr="" if passed else (simulated_stderr or f"dry-run simulated failure: {simulated_failure_type}"),
                duration_seconds=round(time.time() - start, 4),
                failure_type=simulated_failure_type,
                diagnostic_excerpt="" if passed else extract_compiler_error_excerpt("", simulated_stderr),
                env_overrides=env_payload,
            )

        process_env = os.environ.copy()
        process_env.update(env_payload)
        try:
            completed = subprocess.run(
                list(command),
                cwd=str(cwd) if cwd is not None else None,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=timeout_seconds,
                check=False,
                env=process_env,
            )
        except subprocess.TimeoutExpired as exc:
            stdout = normalize_subprocess_text(exc.stdout)
            stderr = (normalize_subprocess_text(exc.stderr) + "\ncommand timed out").strip()
            return StageResult(
                stage=stage,
                passed=False,
                mode="real",
                command=list(command),
                exit_code=124,
                stdout=stdout,
                stderr=stderr,
                duration_seconds=round(time.time() - start, 4),
                failure_type="timeout",
                diagnostic_excerpt=extract_compiler_error_excerpt(stdout, stderr),
                env_overrides=env_payload,
            )
        except FileNotFoundError as exc:
            stderr = str(exc)
            return StageResult(
                stage=stage,
                passed=False,
                mode="real",
                command=list(command),
                exit_code=127,
                stderr=stderr,
                duration_seconds=round(time.time() - start, 4),
                failure_type="command-not-found",
                diagnostic_excerpt=extract_compiler_error_excerpt("", stderr),
                env_overrides=env_payload,
            )
        except OSError as exc:
            stderr = f"{type(exc).__name__}: {exc}"
            return StageResult(
                stage=stage,
                passed=False,
                mode="real",
                command=list(command),
                exit_code=getattr(exc, "errno", 126) or 126,
                stderr=stderr,
                duration_seconds=round(time.time() - start, 4),
                failure_type="exec-error",
                diagnostic_excerpt=extract_compiler_error_excerpt("", stderr),
                env_overrides=env_payload,
            )

        passed = completed.returncode == 0
        return StageResult(
            stage=stage,
            passed=passed,
            mode="real",
            command=list(command),
            exit_code=completed.returncode,
            stdout=completed.stdout,
            stderr=completed.stderr,
            duration_seconds=round(time.time() - start, 4),
            failure_type="" if passed else f"{stage}-failed",
            diagnostic_excerpt=extract_compiler_error_excerpt(completed.stdout, completed.stderr),
            env_overrides=env_payload,
        )


class BaseChecker:
    stage_name = "base"

    def __init__(self, runner: Optional[CommandRunner] = None) -> None:
        self.runner = runner or CommandRunner()

    def check(self, tu: Dict[str, object], artifact: Dict[str, object], config: VerificationConfig) -> StageResult:
        raise NotImplementedError


class CompileChecker(BaseChecker):
    stage_name = "compile"

    def check(self, tu: Dict[str, object], artifact: Dict[str, object], config: VerificationConfig) -> StageResult:
        metadata = artifact.get("metadata", {}) if isinstance(artifact.get("metadata"), dict) else {}
        candidate_file_path = str(metadata.get("candidate_file_path", ""))
        compile_input_paths = resolve_compile_input_paths(artifact)
        mode = "real" if not (config.is_dry_run or config.mock_compiler) else "dry-run"
        if not candidate_file_path:
            return StageResult(
                stage=self.stage_name,
                passed=False,
                mode=mode,
                exit_code=2,
                stderr="missing candidate_file_path for compile check",
                failure_type="missing-candidate-file",
            )
        candidate_path = Path(candidate_file_path)
        candidate_bytes_written = metadata.get("candidate_bytes_written")
        if candidate_bytes_written is None:
            candidate_bytes_written = metadata.get("bytes_written")
        candidate_size = candidate_path.stat().st_size if candidate_path.exists() else 0
        if not candidate_path.exists():
            return StageResult(
                stage=self.stage_name,
                passed=False,
                mode=mode,
                exit_code=2,
                stderr=f"candidate file does not exist: {candidate_file_path}",
                failure_type="missing-candidate-file",
            )
        has_explicit_candidate_bytes = isinstance(candidate_bytes_written, int) and not isinstance(candidate_bytes_written, bool)
        candidate_is_empty = candidate_size <= 0
        if has_explicit_candidate_bytes:
            candidate_is_empty = candidate_bytes_written <= 0 or candidate_size <= 0
        if candidate_is_empty:
            return StageResult(
                stage=self.stage_name,
                passed=False,
                mode=mode,
                exit_code=2,
                stderr=f"empty generated candidate is not a valid compile target: {candidate_file_path}",
                failure_type="empty-candidate-file",
            )
        missing_compile_inputs = [path for path in compile_input_paths if not Path(path).exists()]
        if missing_compile_inputs:
            return StageResult(
                stage=self.stage_name,
                passed=False,
                mode=mode,
                exit_code=2,
                stderr=f"compile input does not exist: {missing_compile_inputs[0]}",
                failure_type="missing-compile-input",
            )
        simulated_failure = detect_mock_failure(artifact, "compile")
        simulated_stderr = build_simulated_stderr(artifact, self.stage_name, candidate_file_path)
        command = render_command(config.compile_command_template, tu=tu, artifact=artifact, config=config, stage=self.stage_name)
        env_overrides = build_process_env(config)
        return self.runner.run(
            stage=self.stage_name,
            command=command,
            cwd=resolve_working_directory(config, artifact, tu),
            timeout_seconds=config.timeout_seconds,
            is_dry_run=config.is_dry_run or config.mock_compiler,
            env_overrides=env_overrides,
            simulated_failure_type=simulated_failure,
            simulated_stderr=simulated_stderr,
        )


class UnitTestChecker(BaseChecker):
    stage_name = "unit-test"

    def check(self, tu: Dict[str, object], artifact: Dict[str, object], config: VerificationConfig) -> StageResult:
        simulated_failure = detect_mock_failure(artifact, "unit-test")
        simulated_stderr = build_simulated_stderr(artifact, self.stage_name, str((artifact.get("metadata") or {}).get("candidate_file_path", "")))
        command = render_command(config.unit_test_command_template, tu=tu, artifact=artifact, config=config, stage=self.stage_name)
        env_overrides = build_process_env(config)
        return self.runner.run(
            stage=self.stage_name,
            command=command,
            cwd=resolve_working_directory(config, artifact, tu),
            timeout_seconds=config.timeout_seconds,
            is_dry_run=config.is_dry_run or config.mock_unit_test,
            env_overrides=env_overrides,
            simulated_failure_type=simulated_failure,
            simulated_stderr=simulated_stderr,
        )


class BehaviorMockChecker(BaseChecker):
    stage_name = "behavior"

    def check(self, tu: Dict[str, object], artifact: Dict[str, object], config: VerificationConfig) -> StageResult:
        harness_plan = build_mtproto_behavior_harness_plan(tu=tu, artifact=artifact, config=config)
        if harness_plan is not None:
            env_overrides = build_process_env(config)
            simulated_failure = detect_mock_failure(artifact, "behavior")
            simulated_stderr = build_simulated_stderr(
                artifact,
                self.stage_name,
                str((artifact.get("metadata") or {}).get("candidate_file_path", "")),
            )
            combined_command = [*harness_plan.compile_command, "&&", *harness_plan.run_command]
            is_dry_run = config.is_dry_run or config.mock_behavior
            if is_dry_run:
                return self.runner.run(
                    stage=self.stage_name,
                    command=combined_command,
                    cwd=resolve_working_directory(config, artifact, tu),
                    timeout_seconds=config.timeout_seconds,
                    is_dry_run=True,
                    env_overrides=env_overrides,
                    simulated_failure_type=simulated_failure,
                    simulated_stderr=simulated_stderr,
                )
            compile_result = self.runner.run(
                stage=self.stage_name,
                command=harness_plan.compile_command,
                cwd=resolve_working_directory(config, artifact, tu),
                timeout_seconds=config.timeout_seconds,
                is_dry_run=False,
                env_overrides=env_overrides,
            )
            if not compile_result.passed:
                compile_result.command = combined_command
                return compile_result
            run_result = self.runner.run(
                stage=self.stage_name,
                command=harness_plan.run_command,
                cwd=resolve_working_directory(config, artifact, tu),
                timeout_seconds=config.timeout_seconds,
                is_dry_run=False,
                env_overrides=env_overrides,
            )
            return merge_stage_results(compile_result, run_result, combined_command)
        simulated_failure = detect_mock_failure(artifact, "behavior")
        simulated_stderr = build_simulated_stderr(artifact, self.stage_name, str((artifact.get("metadata") or {}).get("candidate_file_path", "")))
        command = render_command(config.behavior_command_template, tu=tu, artifact=artifact, config=config, stage=self.stage_name)
        env_overrides = build_process_env(config)
        return self.runner.run(
            stage=self.stage_name,
            command=command,
            cwd=resolve_working_directory(config, artifact, tu),
            timeout_seconds=config.timeout_seconds,
            is_dry_run=config.is_dry_run or config.mock_behavior,
            env_overrides=env_overrides,
            simulated_failure_type=simulated_failure,
            simulated_stderr=simulated_stderr,
        )


class VerifierHarness:
    def __init__(
        self,
        config: VerificationConfig,
        runner: Optional[CommandRunner] = None,
    ) -> None:
        self.config = normalize_verification_config(config)
        shared_runner = runner or CommandRunner()
        self.compile_checker = CompileChecker(shared_runner)
        self.unit_test_checker = UnitTestChecker(shared_runner)
        self.behavior_checker = BehaviorMockChecker(shared_runner)

    def verify(self, tu: Dict[str, object], artifact: Dict[str, object]) -> VerifyResult:
        stage_results: List[StageResult] = []
        compile_result = self.compile_checker.check(tu, artifact, self.config)
        stage_results.append(compile_result)
        if not compile_result.passed:
            return self._aggregate(stage_results)
        unit_test_result = self.unit_test_checker.check(tu, artifact, self.config)
        stage_results.append(unit_test_result)
        if not unit_test_result.passed:
            return self._aggregate(stage_results)
        behavior_result = self.behavior_checker.check(tu, artifact, self.config)
        stage_results.append(behavior_result)
        return self._aggregate(stage_results)

    def _aggregate(self, stage_results: List[StageResult]) -> VerifyResult:
        failed_stage = next((item for item in stage_results if not item.passed), None)
        evidence = [
            f"{item.stage}:{'passed' if item.passed else 'failed'}:{item.mode}:exit={item.exit_code}"
            for item in stage_results
        ]
        for item in stage_results:
            if item.diagnostic_excerpt:
                evidence.append(f"{item.stage}.diagnostic={item.diagnostic_excerpt[:500]}")
        if failed_stage is not None:
            if failed_stage.stderr:
                evidence.append(f"{failed_stage.stage}.stderr={failed_stage.stderr[:500]}")
            return VerifyResult(
                passed=False,
                status="failed",
                evidence=evidence,
                failure_type=failed_stage.failure_type or failed_stage.stage,
                stage_results=stage_results,
            )
        return VerifyResult(
            passed=True,
            status="passed",
            evidence=evidence,
            failure_type="",
            stage_results=stage_results,
        )


def resolve_config_path(value: str) -> str:
    raw = value.strip()
    if not raw:
        return ""
    return str(Path(raw).expanduser().resolve())


def find_executable_in_dir(directory: Path, *names: str) -> Optional[Path]:
    for name in names:
        candidate = directory / name
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return candidate.resolve()
    return None


def resolve_compiler_binary(compiler_home: Path) -> Optional[Path]:
    return find_executable_in_dir(compiler_home / "build-tools" / "bin", "cjc", "cjc.exe")


def resolve_package_manager_binary(compiler_home: Path) -> Optional[Path]:
    return find_executable_in_dir(compiler_home / "build-tools" / "tools" / "bin", "cjpm", "cjpm.exe")


def derive_compiler_home_from_path(path: Path) -> Optional[Path]:
    candidate_homes: List[Path] = []
    if path.is_file():
        if path.name.startswith("cjc") and path.parent.name == "bin" and path.parent.parent.name == "build-tools":
            candidate_homes.append(path.parents[2])
        if path.name.startswith("cjpm") and path.parent.name == "bin" and path.parent.parent.name == "tools":
            build_tools = path.parent.parent.parent
            if build_tools.name == "build-tools":
                candidate_homes.append(build_tools.parent)
    if path.is_dir():
        candidate_homes.append(path)
        candidate_homes.append(path / "cangjie")
        if path.name == "build-tools":
            candidate_homes.append(path.parent)
        if path.name == "bin" and path.parent.name == "build-tools":
            candidate_homes.append(path.parents[1])
        if path.name == "bin" and path.parent.name == "tools" and path.parent.parent.name == "build-tools":
            candidate_homes.append(path.parents[2])
    seen: set[str] = set()
    for candidate_home in candidate_homes:
        resolved = candidate_home.expanduser().resolve()
        home_key = str(resolved)
        if home_key in seen:
            continue
        seen.add(home_key)
        if resolve_compiler_binary(resolved):
            return resolved
    return None


def host_toolchain_score(compiler_home: Path) -> int:
    label = compiler_home.parent.name.lower()
    host_system = platform.system().lower()
    machine = platform.machine().lower()
    score = 0
    if resolve_compiler_binary(compiler_home):
        score += 100
    if resolve_package_manager_binary(compiler_home):
        score += 20
    if guess_host_stdlib_path(compiler_home):
        score += 40
    if guess_runtime_lib_path(compiler_home):
        score += 20
    if host_system == "linux":
        if "linux" in label:
            score += 50
        if any(token in label for token in ("x64", "x86_64", "amd64")) and machine in {"x86_64", "amd64"}:
            score += 15
        if any(token in label for token in ("mac", "darwin", "windows")):
            score -= 200
    elif host_system == "darwin":
        if any(token in label for token in ("mac", "darwin")):
            score += 50
        if any(token in label for token in ("arm", "aarch64")) and machine in {"arm64", "aarch64"}:
            score += 15
        if any(token in label for token in ("linux", "windows")):
            score -= 200
    elif host_system == "windows":
        if "windows" in label:
            score += 50
        if any(token in label for token in ("linux", "mac", "darwin")):
            score -= 200
    if "unzip" in label:
        score += 5
    return score


def discover_compiler_home_from_env() -> Optional[Path]:
    for key in COMPILER_HOME_ENV_KEYS:
        raw_value = os.environ.get(key, "").strip()
        if not raw_value:
            continue
        compiler_home = derive_compiler_home_from_path(Path(raw_value).expanduser())
        if compiler_home is not None:
            return compiler_home
    return None


def discover_repo_local_compiler_home() -> Optional[Path]:
    toolchains_root = PROJECT_ROOT / "artifacts" / "toolchains"
    if not toolchains_root.exists():
        return None
    best_match: Optional[Tuple[int, Path]] = None
    for candidate in sorted(toolchains_root.glob("*/cangjie")):
        compiler_home = derive_compiler_home_from_path(candidate)
        if compiler_home is None:
            continue
        score = host_toolchain_score(compiler_home)
        if best_match is None or score > best_match[0]:
            best_match = (score, compiler_home)
    return best_match[1] if best_match else None


def normalize_verification_config(config: VerificationConfig) -> VerificationConfig:
    compiler_home = resolve_config_path(config.compiler_home)
    compiler_executable = resolve_config_path(config.compiler_executable)
    package_manager_executable = resolve_config_path(config.package_manager_executable)
    tool_bin_path = resolve_config_path(config.tool_bin_path)
    config.stdlib_path = resolve_config_path(config.stdlib_path)
    config.runtime_lib_path = resolve_config_path(config.runtime_lib_path)
    if config.working_directory:
        config.working_directory = resolve_config_path(config.working_directory)

    compiler_home_path = derive_compiler_home_from_path(Path(compiler_home)) if compiler_home else None
    if compiler_home and compiler_home_path is None:
        compiler_home = ""

    if compiler_executable:
        compiler_executable_path = Path(compiler_executable)
        if not (compiler_executable_path.is_file() and os.access(compiler_executable_path, os.X_OK)):
            compiler_executable = ""
        elif not compiler_home:
            compiler_home_path = derive_compiler_home_from_path(compiler_executable_path)
            if compiler_home_path is not None:
                compiler_home = str(compiler_home_path)

    if package_manager_executable:
        package_manager_path = Path(package_manager_executable)
        if not (package_manager_path.is_file() and os.access(package_manager_path, os.X_OK)):
            package_manager_executable = ""
        elif not compiler_home:
            compiler_home_path = derive_compiler_home_from_path(package_manager_path)
            if compiler_home_path is not None:
                compiler_home = str(compiler_home_path)

    if compiler_executable and not compiler_home:
        compiler_path = Path(compiler_executable)
        if compiler_path.name.startswith("cjc") and compiler_path.parent.name == "bin":
            compiler_home = str(compiler_path.parents[2])

    if not compiler_home:
        discovered_compiler_home = discover_compiler_home_from_env() or discover_repo_local_compiler_home()
        if discovered_compiler_home is not None:
            compiler_home = str(discovered_compiler_home)

    if compiler_home:
        compiler_home_path = Path(compiler_home)
        ensure_compiler_layout_compat(compiler_home_path)
        if not compiler_executable:
            compiler_binary = resolve_compiler_binary(compiler_home_path)
            if compiler_binary is not None:
                compiler_executable = str(compiler_binary)
        if not package_manager_executable:
            package_manager_binary = resolve_package_manager_binary(compiler_home_path)
            if package_manager_binary is not None:
                package_manager_executable = str(package_manager_binary)

    if compiler_home and not tool_bin_path:
        candidate = Path(compiler_home) / "build-tools" / "tools" / "bin"
        tool_bin_path = str(candidate)

    if compiler_home and not config.stdlib_path:
        host_stdlib = guess_host_stdlib_path(Path(compiler_home))
        if host_stdlib:
            config.stdlib_path = str(host_stdlib)

    if compiler_home and not config.runtime_lib_path:
        runtime_path = guess_runtime_lib_path(Path(compiler_home))
        if runtime_path:
            config.runtime_lib_path = str(runtime_path)

    config.compiler_home = compiler_home
    config.compiler_executable = compiler_executable
    config.package_manager_executable = package_manager_executable
    config.tool_bin_path = tool_bin_path
    return config


def guess_host_stdlib_path(compiler_home: Path) -> Optional[Path]:
    candidates = []
    host_system = platform.system().lower()
    machine = platform.machine().lower()
    if host_system == "darwin" and machine in {"arm64", "aarch64"}:
        candidates.append(compiler_home / "build-tools" / "modules" / "darwin_aarch64_cjnative" / "std")
    if host_system == "linux" and machine in {"x86_64", "amd64"}:
        candidates.append(compiler_home / "build-tools" / "modules" / "linux_x86_64_cjnative" / "std")
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def guess_runtime_lib_path(compiler_home: Path) -> Optional[Path]:
    host_system = platform.system().lower()
    machine = platform.machine().lower()
    candidates = []
    if host_system == "darwin" and machine in {"arm64", "aarch64"}:
        candidates.append(compiler_home / "build-tools" / "runtime" / "lib" / "darwin_aarch64_cjnative")
    if host_system == "linux" and machine in {"x86_64", "amd64"}:
        candidates.append(compiler_home / "build-tools" / "runtime" / "lib" / "linux_x86_64_cjnative")
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def ensure_compiler_layout_compat(compiler_home: Path) -> None:
    root_modules = compiler_home / "modules"
    build_modules = compiler_home / "build-tools" / "modules"
    if root_modules.exists() or not build_modules.exists():
        return
    try:
        root_modules.symlink_to(build_modules, target_is_directory=True)
    except FileExistsError:
        return
    except OSError:
        return


def guess_llvm_bin_path(compiler_home: Path) -> Optional[Path]:
    candidate = compiler_home / "build-tools" / "third_party" / "llvm" / "bin"
    return candidate if candidate.exists() else None


def guess_llvm_lib_path(compiler_home: Path) -> Optional[Path]:
    candidate = compiler_home / "build-tools" / "third_party" / "llvm" / "lib"
    return candidate if candidate.exists() else None


def build_process_env(config: VerificationConfig) -> Dict[str, str]:
    env: Dict[str, str] = {}
    compiler_home = config.compiler_home.strip()
    compiler_home_path = Path(compiler_home) if compiler_home else None
    if compiler_home:
        env["DEVECO_CANGJIE_PATH"] = compiler_home
        env["CANGJIE_HARMONY_SDK_PATH"] = compiler_home
        if config.inject_compat_cangjie_home:
            env["CANGJIE_HOME"] = compiler_home
        root_modules = compiler_home_path / "modules" if compiler_home_path else None
        build_modules = compiler_home_path / "build-tools" / "modules" if compiler_home_path else None
        if root_modules and root_modules.exists():
            env["CANGJIE_PATH"] = str(root_modules)
        elif build_modules and build_modules.exists():
            env["CANGJIE_PATH"] = str(build_modules)

    path_parts: List[str] = []
    if compiler_home_path:
        path_parts.append(str(compiler_home_path / "build-tools" / "bin"))
    if config.tool_bin_path:
        path_parts.append(config.tool_bin_path)
    elif compiler_home_path:
        path_parts.append(str(compiler_home_path / "build-tools" / "tools" / "bin"))
    if compiler_home_path:
        llvm_bin_path = guess_llvm_bin_path(compiler_home_path)
        if llvm_bin_path:
            path_parts.append(str(llvm_bin_path))
    if path_parts:
        env["PATH"] = join_env_path(path_parts, os.environ.get("PATH", ""))

    runtime_lib_path = config.runtime_lib_path.strip()
    library_parts: List[str] = []
    if runtime_lib_path:
        library_parts.append(runtime_lib_path)
    if compiler_home_path:
        llvm_lib_path = guess_llvm_lib_path(compiler_home_path)
        if llvm_lib_path:
            library_parts.append(str(llvm_lib_path))
    if library_parts:
        key = "DYLD_LIBRARY_PATH" if platform.system().lower() == "darwin" else "LD_LIBRARY_PATH"
        env[key] = join_env_path(library_parts, os.environ.get(key, ""))

    if config.stdlib_path:
        env["CANGJIE_STDLIB_PATH"] = config.stdlib_path

    for key, value in config.extra_env.items():
        if value:
            env[key] = value
    return env


def join_env_path(prefixes: Sequence[str], current_value: str) -> str:
    items = [item for item in prefixes if item]
    if current_value:
        items.append(current_value)
    return os.pathsep.join(items)


def detect_mock_failure(artifact: Dict[str, object], stage: str) -> str:
    generated_code = str(artifact.get("generated_code", ""))
    marker = f"mock-fail-{stage}"
    return marker if marker in generated_code else ""


def build_simulated_stderr(artifact: Dict[str, object], stage: str, candidate_file_path: str) -> str:
    generated_code = str(artifact.get("generated_code", ""))
    marker = f"mock-fail-{stage}"
    if marker not in generated_code:
        return ""
    return f"{candidate_file_path}:1:1: simulated {stage} error triggered by marker {marker}"


def render_command(
    template: str,
    *,
    tu: Dict[str, object],
    artifact: Dict[str, object],
    config: VerificationConfig,
    stage: str,
) -> List[str]:
    target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
    artifact_metadata = artifact.get("metadata", {}) if isinstance(artifact.get("metadata"), dict) else {}
    compile_input_paths = resolve_compile_input_paths(artifact)
    mapping = {
        "project_root": str(((tu.get("snapshot") or {}) if isinstance(tu.get("snapshot"), dict) else {}).get("root_path", "")),
        "target_path": str(target.get("path", "")),
        "tu_id": str(tu.get("tu_id", "")),
        "workspace_dir": str(artifact_metadata.get("workspace_dir", "")),
        "attempt_dir": str(artifact_metadata.get("attempt_dir", "")),
        "candidate_file_path": str(artifact_metadata.get("candidate_file_path", "")),
        "candidate_rel_path": str(artifact_metadata.get("candidate_rel_path", "")),
        "compile_input_paths": " ".join(shlex.quote(path) for path in compile_input_paths),
        "behavior_test_input_paths": " ".join(shlex.quote(path) for path in resolve_behavior_test_input_paths(tu)),
        "behavior_binary_path": str(resolve_behavior_binary_path(artifact)),
        "compiler_executable": config.compiler_executable,
        "package_manager_executable": config.package_manager_executable,
        "compiler_home": config.compiler_home,
        "stdlib_path": config.stdlib_path,
        "runtime_lib_path": config.runtime_lib_path,
        "tool_bin_path": config.tool_bin_path,
    }
    rendered = template.format(**mapping).strip()
    command = shlex.split(rendered)
    if stage == "compile" and config.compiler_executable and command:
        if command[0] == "cjc":
            command[0] = config.compiler_executable
    if stage == "unit-test" and config.package_manager_executable and command:
        if command[0] == "cjpm":
            command[0] = config.package_manager_executable
    return command


def resolve_compile_input_paths(artifact: Dict[str, object]) -> List[str]:
    artifact_metadata = artifact.get("metadata", {}) if isinstance(artifact.get("metadata"), dict) else {}
    configured = artifact_metadata.get("compile_file_paths")
    if isinstance(configured, list):
        result = [str(item).strip() for item in configured if str(item).strip()]
        if result:
            return result
    candidate_file_path = str(artifact_metadata.get("candidate_file_path", "")).strip()
    return [candidate_file_path] if candidate_file_path else []


def resolve_behavior_binary_path(artifact: Dict[str, object]) -> Path:
    artifact_metadata = artifact.get("metadata", {}) if isinstance(artifact.get("metadata"), dict) else {}
    attempt_dir = str(artifact_metadata.get("attempt_dir", "")).strip()
    base_dir = Path(attempt_dir).resolve() if attempt_dir else PROJECT_ROOT
    return base_dir / "behavior_harness_tests"


def resolve_behavior_test_input_paths(tu: Dict[str, object]) -> List[str]:
    target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
    target_path = str(target.get("path", "")).strip()
    spec = MTPROTO_BEHAVIOR_HARNESS_SPECS.get(target_path)
    if spec is None:
        return []
    filenames = [*spec.get("support", []), *spec.get("tests", [])]
    return [
        str((MTPROTO_BEHAVIOR_HARNESS_ROOT / name).resolve())
        for name in filenames
        if (MTPROTO_BEHAVIOR_HARNESS_ROOT / name).exists()
    ]


def build_mtproto_behavior_harness_plan(
    *,
    tu: Dict[str, object],
    artifact: Dict[str, object],
    config: VerificationConfig,
) -> Optional[BehaviorHarnessPlan]:
    target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
    target_path = str(target.get("path", "")).strip()
    if target_path not in MTPROTO_BEHAVIOR_HARNESS_SPECS:
        return None
    compile_input_paths = resolve_compile_input_paths(artifact)
    test_input_paths = resolve_behavior_test_input_paths(tu)
    if not compile_input_paths or not test_input_paths:
        return None
    behavior_binary_path = resolve_behavior_binary_path(artifact)
    compiler_cmd = config.compiler_executable or "cjc"
    compile_command = [
        compiler_cmd,
        "--diagnostic-format",
        "noColor",
        "--test",
        "-o",
        str(behavior_binary_path),
        *compile_input_paths,
        *test_input_paths,
    ]
    return BehaviorHarnessPlan(
        compile_command=compile_command,
        run_command=[str(behavior_binary_path)],
    )


def merge_stage_results(compile_result: StageResult, run_result: StageResult, combined_command: Sequence[str]) -> StageResult:
    stdout = "\n".join(part for part in [compile_result.stdout.strip(), run_result.stdout.strip()] if part).strip()
    stderr = "\n".join(part for part in [compile_result.stderr.strip(), run_result.stderr.strip()] if part).strip()
    diagnostic_excerpt = run_result.diagnostic_excerpt or compile_result.diagnostic_excerpt
    failure_type = ""
    exit_code = 0
    passed = compile_result.passed and run_result.passed
    if not passed:
        failed_stage = run_result if not run_result.passed else compile_result
        failure_type = failed_stage.failure_type
        exit_code = failed_stage.exit_code
    return StageResult(
        stage=run_result.stage,
        passed=passed,
        mode=run_result.mode,
        command=list(combined_command),
        exit_code=exit_code,
        stdout=stdout,
        stderr=stderr,
        duration_seconds=round(compile_result.duration_seconds + run_result.duration_seconds, 4),
        failure_type=failure_type,
        diagnostic_excerpt=diagnostic_excerpt,
        env_overrides=dict(run_result.env_overrides or compile_result.env_overrides),
    )


def resolve_working_directory(config: VerificationConfig, artifact: Dict[str, object], tu: Dict[str, object]) -> Optional[Path]:
    if config.working_directory:
        return Path(config.working_directory).resolve()
    artifact_metadata = artifact.get("metadata", {}) if isinstance(artifact.get("metadata"), dict) else {}
    workspace_dir = artifact_metadata.get("workspace_dir")
    attempt_dir = artifact_metadata.get("attempt_dir")
    if attempt_dir:
        return Path(str(attempt_dir)).resolve()
    if workspace_dir:
        return Path(str(workspace_dir)).resolve()
    snapshot = tu.get("snapshot", {}) if isinstance(tu.get("snapshot"), dict) else {}
    root_path = snapshot.get("root_path")
    if not root_path:
        return None
    return Path(str(root_path)).resolve()


def extract_compiler_error_excerpt(stdout: object, stderr: object) -> str:
    stdout_text = normalize_subprocess_text(stdout)
    stderr_text = normalize_subprocess_text(stderr)
    combined = "\n".join(part for part in [stderr_text.strip(), stdout_text.strip()] if part).strip()
    combined = ANSI_ESCAPE_RE.sub("", combined)
    if not combined:
        return ""
    for pattern in COMPILER_ERROR_PATTERNS:
        match = pattern.search(combined)
        if match:
            groups = match.groupdict()
            file_path = groups.get("file", "")
            line = groups.get("line", "")
            column = groups.get("column", "")
            message = (groups.get("message", "") or "").strip()
            location = ":".join(part for part in [file_path, line, column] if part)
            if location and message:
                return f"{location}: {message}"
            if location:
                return location
    first_line = next((line.strip() for line in combined.splitlines() if line.strip()), "")
    return first_line[:500]


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def load_json_file(path: Path) -> Dict[str, object]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise SystemExit(f"无效 JSON 结构：{path}")
    return data


def parse_extra_env(items: Sequence[str]) -> Dict[str, str]:
    result: Dict[str, str] = {}
    for item in items:
        if "=" not in item:
            raise SystemExit(f"--extra-env 参数格式错误，应为 KEY=VALUE：{item}")
        key, value = item.split("=", 1)
        key = key.strip()
        if not key:
            raise SystemExit(f"--extra-env 参数缺少键名：{item}")
        result[key] = value
    return result


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="运行 Compile / UnitTest / Behavior 三段式验证")
    parser.add_argument("--tu-json", required=True, help="TU JSON 路径")
    parser.add_argument("--artifact-json", required=True, help="包含 generated_code / metadata 的 JSON 路径")
    parser.add_argument("--output", help="验证结果输出路径")
    parser.add_argument("--no-dry-run", action="store_true", help="关闭 dry-run，尝试调用真实 CLI")
    parser.add_argument("--real-compile", action="store_true", help="关闭 mock_compiler")
    parser.add_argument("--real-unit-test", action="store_true", help="关闭 mock_unit_test")
    parser.add_argument("--real-behavior", action="store_true", help="关闭 mock_behavior")
    parser.add_argument("--compile-cmd", default="cjc --diagnostic-format noColor --output-type staticlib -o {attempt_dir}/candidate_output {compile_input_paths}", help="编译命令模板")
    parser.add_argument("--unit-test-cmd", default="cjpm test --package-root {workspace_dir}", help="单测命令模板")
    parser.add_argument("--behavior-cmd", default="python -c 'print(\"behavior-ok\")'", help="行为检查命令模板")
    parser.add_argument("--timeout-seconds", type=int, default=120, help="单个阶段超时秒数")
    parser.add_argument("--compiler-executable", default="", help="真实 cjc 绝对路径")
    parser.add_argument("--package-manager-executable", default="", help="真实 cjpm 绝对路径")
    parser.add_argument("--compiler-home", default="", help="SDK 根目录，例如 /path/to/cangjie")
    parser.add_argument("--stdlib-path", default="", help="标准库目录，例如 /path/to/cangjie/build-tools/modules/.../std")
    parser.add_argument("--runtime-lib-path", default="", help="运行时库目录，例如 /path/to/cangjie/build-tools/runtime/lib/...")
    parser.add_argument("--tool-bin-path", default="", help="工具目录，例如 /path/to/cangjie/build-tools/tools/bin")
    parser.add_argument("--extra-env", action="append", default=[], help="额外环境变量，格式 KEY=VALUE，可重复传入")
    parser.add_argument("--disable-compat-cangjie-home", action="store_true", help="不要自动注入 CANGJIE_HOME 兼容变量")
    return parser.parse_args(argv)


def default_output_path(tu_json_path: Path) -> Path:
    return DEFAULT_OUTPUT_DIR / f"{tu_json_path.stem}.verify.json"


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    tu_json_path = Path(args.tu_json).resolve()
    artifact_json_path = Path(args.artifact_json).resolve()
    output_path = Path(args.output).resolve() if args.output else default_output_path(tu_json_path)
    tu = load_json_file(tu_json_path)
    artifact = load_json_file(artifact_json_path)
    config = VerificationConfig(
        is_dry_run=not args.no_dry_run,
        mock_compiler=not args.real_compile,
        mock_unit_test=not args.real_unit_test,
        mock_behavior=not args.real_behavior,
        compile_command_template=args.compile_cmd,
        unit_test_command_template=args.unit_test_cmd,
        behavior_command_template=args.behavior_cmd,
        timeout_seconds=args.timeout_seconds,
        compiler_executable=args.compiler_executable,
        package_manager_executable=args.package_manager_executable,
        compiler_home=args.compiler_home,
        stdlib_path=args.stdlib_path,
        runtime_lib_path=args.runtime_lib_path,
        tool_bin_path=args.tool_bin_path,
        extra_env=parse_extra_env(args.extra_env),
        inject_compat_cangjie_home=not args.disable_compat_cangjie_home,
    )
    harness = VerifierHarness(config=config)
    result = harness.verify(tu, artifact)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(asdict(result), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        json.dumps(
            {
                "output_path": str(output_path),
                "passed": result.passed,
                "failure_type": result.failure_type,
                "generated_at": utc_now(),
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
