#!/usr/bin/env python3
"""仓库级翻译流水线指挥器。

功能：
1. 以单条命令顺序调度 RepoIndexer -> RepoMapGenerator -> TUBundler -> Orchestrator；
2. 通过 argparse + 可选 JSON 配置统一管理路径、模型与验证参数；
3. 为每次流水线运行创建独立的 `artifacts/pipeline_runs/<timestamp>/` 目录；
4. 记录阶段级状态、失败信息与最终执行摘要，便于问题追溯。

说明：
- 本脚本不直接实现翻译逻辑，只负责调度已存在的基础设施模块；
- 默认以 mock + dry-run 方式运行，可在没有真实 `cjc` / `cjpm` / 模型环境时完成全链路联调；
- 任一阶段失败都会优雅中断，并把现场写入 `summary.json` 与 `failure.json`。
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import shutil
import sqlite3
import subprocess
import sys
import time
import traceback
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional

from orchestrator import (
    DEFAULT_MODEL,
    DEFAULT_SCHEMA_PATH,
    Orchestrator,
    SchemaPolicy,
    load_architecture_skill_texts,
)
from pattern_memory import DEFAULT_MEMORY_PATH, PatternMemoryEngine
from prompt_assembler import PromptAssembler
from repo_indexer import DEFAULT_EXCLUDE_DIRS, DEFAULT_EXTENSIONS, RepoIndexer
from repo_map_generator import RepoMapGenerator
from tu_bundler import TranslationUnitBundler
from verifier import VerificationConfig
from verifier import VerifierHarness
from workspace_manager import WorkspaceManager

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PIPELINE_ROOT = PROJECT_ROOT / "artifacts" / "pipeline_runs"
DEFAULT_PIPELINE_TIMEOUT_SECONDS = 300
DEFAULT_FULL_PASS_VALIDATOR_PATH = PROJECT_ROOT / "scripts" / "full-pass-summary-validate.py"
DEFAULT_FULL_PASS_SCHEMA_PATH = PROJECT_ROOT / "docs" / "schemas" / "full-pass-summary-schema.json"
DEFAULT_CURRENT_PHASE_PATH = PROJECT_ROOT / ".claude" / "status" / "current-phase.md"
DEFAULT_FULL_PASS_REFRESH_CMD_TEMPLATE = (
    "bash scripts/full-pass-harmony-refresh.sh "
    "--cycle {cycle} "
    "--summary {full_pass_summary_path} "
    "--run-root {run_root} "
    "--target-file {target_file} "
    "--orchestration-output {orchestration_output_path} "
    "--final-output {final_output_path} "
    "--report {full_pass_report_path}"
)


def derive_pipeline_status(default_status: str, orchestration_result: Optional[Dict[str, Any]]) -> str:
    if not isinstance(orchestration_result, dict):
        return default_status
    orchestration_status = str(orchestration_result.get("final_status", "")).strip()
    return orchestration_status or default_status


@dataclass
class PipelineConfig:
    src_root: Path
    target_file: str
    run_root: Path
    db_path: Path
    repo_map_path: Path
    tu_json_path: Path
    orchestration_output_path: Path
    summary_path: Path
    failure_path: Path
    schema_path: Path
    architecture_skill_paths: List[Path]
    pattern_memory_path: Path
    workspace_root: Path
    snapshot_label: str
    llm_model: str
    is_mock_mode: bool
    timeout_seconds: int
    llm_max_retries: int
    max_rounds: int
    pattern_limit: int
    extensions: List[str]
    exclude_dirs: List[str]
    prefer_tree_sitter: bool
    parser_mode: Optional[str]
    diff_report_path: Optional[Path]
    reset_db: bool
    dump_prompt_only: bool
    prompt_dump_path: Path
    repo_map_max_symbols: int
    repo_map_max_imports: int
    repo_map_max_calls: int
    tu_max_depth: int
    tu_max_dependency_files: int
    tu_max_signatures_per_file: int
    verify_is_dry_run: bool
    verify_mock_compiler: bool
    verify_mock_unit_test: bool
    verify_mock_behavior: bool
    compile_cmd: str
    unit_test_cmd: str
    behavior_cmd: str
    verify_working_directory: Optional[str]
    verify_compiler_executable: Optional[Path]
    verify_package_manager_executable: Optional[Path]
    verify_compiler_home: Optional[Path]
    verify_stdlib_path: Optional[Path]
    verify_runtime_lib_path: Optional[Path]
    verify_tool_bin_path: Optional[Path]
    verify_extra_env: Dict[str, str]
    verify_inject_compat_cangjie_home: bool
    repair_anchor_file: Optional[Path]
    repair_anchor_label: Optional[str]
    frozen_candidate_file: Optional[Path]
    frozen_candidate_label: Optional[str]
    full_pass_summary_path: Optional[Path]
    full_pass_validation_schema_path: Optional[Path]
    full_pass_validation_report_path: Optional[Path]
    full_pass_status_path: Optional[Path]
    full_pass_sync_current_phase: bool
    full_pass_refresh_cmd: Optional[str]
    full_pass_max_cycles: int


@dataclass
class StageRecord:
    name: str
    started_at: str
    status: str = "running"
    ended_at: str = ""
    duration_seconds: float = 0.0
    outputs: Dict[str, Any] = field(default_factory=dict)
    error: str = ""
    traceback_text: str = ""


class PipelineExecutionError(RuntimeError):
    def __init__(
        self,
        stage_name: str,
        message: str,
        *,
        exit_code: int = 1,
        failure_class: str = "pipeline-error",
        details: Optional[Dict[str, Any]] = None,
    ) -> None:
        super().__init__(message)
        self.stage_name = stage_name
        self.message = message
        self.exit_code = exit_code
        self.failure_class = failure_class
        self.details = details or {}


class PipelineRunner:
    def __init__(self, config: PipelineConfig) -> None:
        self.config = config
        self.stage_records: List[StageRecord] = []
        self.run_started_at = utc_now()
        self.run_root = config.run_root.resolve()
        self.run_root.mkdir(parents=True, exist_ok=True)

    def run(self) -> int:
        try:
            snapshot_stats = self._run_index_stage()
            repo_map_stats = self._run_repo_map_stage()
            tu = self._run_tu_stage()
            orchestration_result: Dict[str, Any] = {}
            prompt_dump_stats: Optional[Dict[str, Any]] = None
            full_pass_validation: Dict[str, Any] = {}
            full_pass_iterations: List[Dict[str, Any]] = []
            final_status = "passed"
            exit_code = 0
            if self.config.dump_prompt_only:
                prompt_dump_stats = self._run_prompt_dump_stage(tu)
                final_status = "prompt-dumped"
            else:
                max_cycles = max(1, self.config.full_pass_max_cycles if self.config.full_pass_summary_path else 1)
                runtime_repair_anchor = load_repair_anchor_payload(self.config.repair_anchor_file, self.config.repair_anchor_label)
                full_pass_feedback: Optional[Dict[str, Any]] = None
                for cycle in range(1, max_cycles + 1):
                    orchestration_result = self._run_orchestration_stage(
                        tu,
                        cycle=cycle,
                        repair_anchor=runtime_repair_anchor,
                        full_pass_feedback=full_pass_feedback,
                    )
                    if self.config.full_pass_summary_path is None:
                        break
                    refresh_result = self._run_full_pass_refresh_stage(
                        cycle,
                        orchestration_result,
                        force_refresh=cycle > 1,
                    )
                    full_pass_validation = self._run_full_pass_validation_stage(cycle)
                    full_pass_iterations.append(
                        {
                            "cycle": cycle,
                            "orchestration_output_path": orchestration_result.get("output_path", self.config.orchestration_output_path),
                            "refresh": refresh_result,
                            "validation": full_pass_validation,
                        }
                    )
                    validator_exit = int(full_pass_validation.get("validator_exit_code", 22))
                    if validator_exit == 0:
                        break
                    if validator_exit == 10 and cycle < max_cycles:
                        full_pass_feedback = build_full_pass_feedback_payload(full_pass_validation)
                        runtime_repair_anchor = build_runtime_repair_anchor_payload(orchestration_result, cycle, runtime_repair_anchor)
                        continue
                    if validator_exit != 0:
                        raise PipelineExecutionError(
                            "full-pass-validation",
                            build_full_pass_validation_error_message(full_pass_validation.get("report", {}), validator_exit),
                            exit_code=validator_exit,
                            failure_class=classify_full_pass_failure_class(validator_exit),
                            details={
                                "full_pass_validation": full_pass_validation,
                                "full_pass_iterations": full_pass_iterations,
                            },
                        )
                final_status = derive_pipeline_status(final_status, orchestration_result)
            summary = self._build_summary(
                status=final_status,
                snapshot_stats=snapshot_stats,
                repo_map_stats=repo_map_stats,
                tu=tu,
                orchestration_result=orchestration_result,
                prompt_dump_stats=prompt_dump_stats,
                full_pass_validation=full_pass_validation,
                full_pass_iterations=full_pass_iterations,
            )
            write_json(self.config.summary_path, summary)
            self._print_summary(summary)
            return exit_code
        except PipelineExecutionError as exc:
            failure_payload = self._build_failure_payload(exc)
            write_json(self.config.summary_path, failure_payload["summary"])
            write_json(self.config.failure_path, failure_payload)
            self._print_failure(failure_payload)
            return exc.exit_code

    def _run_index_stage(self) -> Dict[str, Any]:
        def action() -> Dict[str, Any]:
            indexer = RepoIndexer(
                root_path=self.config.src_root,
                db_path=self.config.db_path,
                snapshot_label=self.config.snapshot_label,
                extensions=self.config.extensions,
                exclude_dirs=self.config.exclude_dirs,
                prefer_tree_sitter=self.config.prefer_tree_sitter,
                parser_mode=self.config.parser_mode,
                diff_report_path=self.config.diff_report_path,
                reset_db=self.config.reset_db,
            )
            exit_code = indexer.run()
            if exit_code != 0:
                raise PipelineExecutionError("index", f"RepoIndexer 退出码异常：{exit_code}")
            return query_snapshot_stats(self.config.db_path, self.config.snapshot_label)

        return self._execute_stage("index", action)

    def _run_repo_map_stage(self) -> Dict[str, Any]:
        def action() -> Dict[str, Any]:
            generator = RepoMapGenerator(
                db_path=self.config.db_path,
                output_path=self.config.repo_map_path,
                snapshot_label=self.config.snapshot_label,
                max_symbols=self.config.repo_map_max_symbols,
                max_imports=self.config.repo_map_max_imports,
                max_calls=self.config.repo_map_max_calls,
            )
            exit_code = generator.run()
            if exit_code != 0:
                raise PipelineExecutionError("repo-map", f"RepoMapGenerator 退出码异常：{exit_code}")
            return {
                "output_path": str(self.config.repo_map_path),
                "bytes": self.config.repo_map_path.stat().st_size if self.config.repo_map_path.exists() else 0,
                "line_count": count_lines(self.config.repo_map_path),
            }

        return self._execute_stage("repo-map", action)

    def _run_tu_stage(self) -> Dict[str, Any]:
        def action() -> Dict[str, Any]:
            bundler = TranslationUnitBundler(
                db_path=self.config.db_path,
                target_file=self.config.target_file,
                output_path=self.config.tu_json_path,
                snapshot_label=self.config.snapshot_label,
                max_depth=self.config.tu_max_depth,
                max_dependency_files=self.config.tu_max_dependency_files,
                max_signatures_per_file=self.config.tu_max_signatures_per_file,
            )
            exit_code = bundler.run()
            if exit_code != 0:
                raise PipelineExecutionError("tu", f"TranslationUnitBundler 退出码异常：{exit_code}")
            with self.config.tu_json_path.open("r", encoding="utf-8") as handle:
                payload = json.load(handle)
            if not isinstance(payload, dict) or "tu_id" not in payload:
                raise PipelineExecutionError("tu", f"TU JSON 结构无效：{self.config.tu_json_path}")
            return payload

        return self._execute_stage("tu", action)

    def _run_prompt_dump_stage(self, tu: Dict[str, Any]) -> Dict[str, Any]:
        def action() -> Dict[str, Any]:
            schema_policy = SchemaPolicy(self.config.schema_path)
            required_dimensions = schema_policy.required_dimensions(tu)
            architecture_skill_texts = load_architecture_skill_texts(self.config.architecture_skill_paths)
            prompt_assembler = PromptAssembler(
                schema_text=schema_policy.schema_text,
                architecture_skill_texts=architecture_skill_texts,
            )
            pattern_memory = PatternMemoryEngine(self.config.pattern_memory_path)
            pattern_examples = pattern_memory.query_for_tu(tu, limit=self.config.pattern_limit)
            prompt = prompt_assembler.build_translator_prompt(
                tu=tu,
                required_dimensions=required_dimensions,
                attempt=1,
                repair_guidance=[],
                pattern_examples=pattern_examples,
                repair_anchor=load_repair_anchor_payload(self.config.repair_anchor_file, self.config.repair_anchor_label),
            )
            self.config.prompt_dump_path.parent.mkdir(parents=True, exist_ok=True)
            dump_text = render_prompt_dump(
                prompt=prompt,
                tu=tu,
                model=self.config.llm_model,
                schema_path=self.config.schema_path,
                architecture_skill_paths=self.config.architecture_skill_paths,
                required_dimensions=required_dimensions,
                pattern_examples=pattern_examples,
            )
            self.config.prompt_dump_path.write_text(dump_text, encoding='utf-8')
            system_prompt = next((message.content for message in prompt.messages if message.role == 'system'), '')
            user_prompt = next((message.content for message in prompt.messages if message.role == 'user'), '')
            dependency_closure = tu.get('dependency_closure', []) if isinstance(tu.get('dependency_closure'), list) else []
            dependency_paths = [str(item.get('path', '')) for item in dependency_closure if isinstance(item, dict)]
            dependency_signature_count = sum(
                len(item.get('signatures', []))
                for item in dependency_closure
                if isinstance(item, dict) and isinstance(item.get('signatures', []), list)
            )
            return {
                'output_path': str(self.config.prompt_dump_path),
                'system_chars': len(system_prompt),
                'user_chars': len(user_prompt),
                'total_chars': len(system_prompt) + len(user_prompt),
                'estimated_tokens': estimate_token_count(system_prompt) + estimate_token_count(user_prompt),
                'required_dimensions': required_dimensions,
                'pattern_examples_used': len(pattern_examples),
                'dependency_count': len(dependency_paths),
                'dependency_paths': dependency_paths,
                'dependency_signature_count': dependency_signature_count,
                'line_count': count_lines(self.config.prompt_dump_path),
            }

        return self._execute_stage('prompt-dump', action)

    def _run_orchestration_stage(
        self,
        tu: Dict[str, Any],
        *,
        cycle: int,
        repair_anchor: Optional[Dict[str, Any]] = None,
        full_pass_feedback: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        stage_name = f"orchestration[{cycle}]"

        def action() -> Dict[str, Any]:
            verification_config = self._build_verification_config()
            if self.config.frozen_candidate_file is not None:
                result = self._run_frozen_candidate_verification(
                    tu,
                    verification_config=verification_config,
                )
                cycle_output_path = build_cycle_artifact_path(self.config.orchestration_output_path, cycle, label="orchestration")
                write_json(cycle_output_path, result)
                write_json(self.config.orchestration_output_path, result)
                result["output_path"] = str(cycle_output_path)
                result["cycle"] = cycle
                return result
            orchestrator = Orchestrator(
                schema_path=self.config.schema_path,
                architecture_skill_paths=self.config.architecture_skill_paths,
                pattern_memory_path=self.config.pattern_memory_path,
                pattern_limit=self.config.pattern_limit,
                workspace_root=self.config.workspace_root,
                model=self.config.llm_model,
                timeout_seconds=self.config.timeout_seconds,
                max_rounds=self.config.max_rounds,
                use_mock=self.config.is_mock_mode,
                llm_max_retries=self.config.llm_max_retries,
                verification_config=verification_config,
                repair_anchor=repair_anchor,
                full_pass_feedback=full_pass_feedback,
            )
            result = orchestrator.run(tu)
            cycle_output_path = build_cycle_artifact_path(self.config.orchestration_output_path, cycle, label="orchestration")
            write_json(cycle_output_path, result)
            write_json(self.config.orchestration_output_path, result)
            result["output_path"] = str(cycle_output_path)
            result["cycle"] = cycle
            return result

        return self._execute_stage(stage_name, action)

    def _build_verification_config(self) -> VerificationConfig:
        return VerificationConfig(
            is_dry_run=self.config.verify_is_dry_run,
            mock_compiler=self.config.verify_mock_compiler,
            mock_unit_test=self.config.verify_mock_unit_test,
            mock_behavior=self.config.verify_mock_behavior,
            compile_command_template=self.config.compile_cmd,
            unit_test_command_template=self.config.unit_test_cmd,
            behavior_command_template=self.config.behavior_cmd,
            timeout_seconds=self.config.timeout_seconds,
            working_directory=self.config.verify_working_directory,
            compiler_executable=str(self.config.verify_compiler_executable or ""),
            package_manager_executable=str(self.config.verify_package_manager_executable or ""),
            compiler_home=str(self.config.verify_compiler_home or ""),
            stdlib_path=str(self.config.verify_stdlib_path or ""),
            runtime_lib_path=str(self.config.verify_runtime_lib_path or ""),
            tool_bin_path=str(self.config.verify_tool_bin_path or ""),
            extra_env=dict(self.config.verify_extra_env),
            inject_compat_cangjie_home=self.config.verify_inject_compat_cangjie_home,
        )

    def _run_frozen_candidate_verification(
        self,
        tu: Dict[str, Any],
        *,
        verification_config: VerificationConfig,
    ) -> Dict[str, Any]:
        frozen_candidate = load_frozen_candidate_payload(
            self.config.frozen_candidate_file,
            self.config.frozen_candidate_label,
        )
        if frozen_candidate is None:
            raise PipelineExecutionError(
                "orchestration",
                "未提供 frozen candidate 文件，无法执行 verifier-only pipeline",
            )

        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        source_target_path = str(target.get("path") or self.config.target_file)
        tu_id = str(tu.get("tu_id") or build_default_snapshot_label(source_target_path))
        workspace_manager = WorkspaceManager(base_dir=self.config.workspace_root)
        workspace_session = workspace_manager.create_session(tu_id, source_target_path)
        write_result = workspace_manager.write_candidate_code(
            workspace_session,
            attempt=1,
            source_target_path=source_target_path,
            generated_code=str(frozen_candidate["code"]),
            extra_metadata={
                "frozen_candidate_label": frozen_candidate["label"],
                "frozen_candidate_source_path": frozen_candidate["source_path"],
                "mode": "frozen-candidate",
            },
        )
        staged_dependencies = list(
            workspace_manager.stage_precompiled_dependencies(
                workspace_session,
                attempt=1,
                source_target_path=source_target_path,
                tu=tu,
            )
        )
        compile_file_paths = [str(write_result.candidate_file_path)] + [
            str(item.staged_file_path) for item in staged_dependencies
        ]
        artifact = {
            "attempt": 1,
            "generated_code": str(frozen_candidate["code"]),
            "declared_constraints": [
                f"[FROZEN CANDIDATE] label={frozen_candidate['label']}",
            ],
            "notes": [
                "verifier-only pipeline path",
                f"source={frozen_candidate['source_path']}",
            ],
            "metadata": {
                "workspace_dir": str(workspace_session.root_dir),
                "attempt_dir": str(write_result.attempt_dir),
                "candidate_file_path": str(write_result.candidate_file_path),
                "candidate_rel_path": write_result.candidate_rel_path,
                "candidate_manifest_path": str(write_result.manifest_path),
                "candidate_bytes_written": write_result.bytes_written,
                "compile_file_paths": compile_file_paths,
                "staged_dependencies": [
                    {
                        "source_path": item.source_path,
                        "staged_file_path": str(item.staged_file_path),
                        "staged_rel_path": item.staged_rel_path,
                        "original_candidate_path": str(item.original_candidate_path),
                        "normalized_package_name": item.normalized_package_name,
                    }
                    for item in staged_dependencies
                ],
                "normalized_package_name": staged_dependencies[0].normalized_package_name if staged_dependencies else "",
                "frozen_candidate_label": frozen_candidate["label"],
                "frozen_candidate_source_path": frozen_candidate["source_path"],
                "mode": "frozen-candidate",
            },
        }
        workspace_manager.write_round_archive(
            workspace_session,
            attempt=1,
            payload=artifact,
            filename="translation_artifact.json",
        )
        if staged_dependencies:
            workspace_manager.write_round_archive(
                workspace_session,
                attempt=1,
                filename="staged_dependencies.json",
                payload={
                    "target_path": source_target_path,
                    "compile_file_paths": compile_file_paths,
                    "dependencies": artifact["metadata"]["staged_dependencies"],
                },
            )
        workspace_manager.write_round_archive(
            workspace_session,
            attempt=1,
            payload={
                "passed": True,
                "required_dimensions": [],
                "raw_text": "frozen-candidate verifier-only path",
                "issues": [],
                "mode": "frozen-candidate",
            },
            filename="review_result.json",
        )
        verify_result = VerifierHarness(verification_config).verify(tu, artifact)
        workspace_manager.write_round_archive(
            workspace_session,
            attempt=1,
            payload=asdict(verify_result),
            filename="verify_result.json",
        )
        return {
            "tu_id": tu_id,
            "schema_reference": str(self.config.schema_path),
            "pattern_memory_path": str(self.config.pattern_memory_path),
            "workspace_dir": str(workspace_session.root_dir),
            "max_rounds": 1,
            "final_status": "passed" if verify_result.passed else "failed",
            "required_dimensions": [],
            "pattern_examples_used": 0,
            "rounds": [
                {
                    "attempt": 1,
                    "translator_constraints": list(artifact["declared_constraints"]),
                    "review_passed": True,
                    "review_issue_codes": [],
                    "verify_passed": verify_result.passed,
                    "verify_status": verify_result.status,
                    "verify_failure_type": verify_result.failure_type,
                    "repair_guidance": [],
                }
            ],
            "failure_class": "" if verify_result.passed else (verify_result.failure_type or "verify-failed"),
            "infrastructure_failure": None,
            "seed_full_pass_feedback": {},
            "final_artifact": artifact,
            "final_verify": asdict(verify_result),
            "generated_at": utc_now(),
            "execution_mode": "frozen-candidate",
            "frozen_candidate": {
                "label": frozen_candidate["label"],
                "source_path": frozen_candidate["source_path"],
            },
        }

    def _run_full_pass_refresh_stage(
        self,
        cycle: int,
        orchestration_result: Dict[str, Any],
        *,
        force_refresh: bool = False,
    ) -> Dict[str, Any]:
        stage_name = f"full-pass-refresh[{cycle}]"
        record = StageRecord(name=stage_name, started_at=utc_now())
        self.stage_records.append(record)
        print(f"[pipeline] stage={stage_name} status=started")
        start = time.time()
        try:
            summary_path = self.config.full_pass_summary_path
            if summary_path is None:
                raise PipelineExecutionError(stage_name, "未配置 full_pass_summary_path", exit_code=22, failure_class="pipeline-error")
            resolved_template, template_source = resolve_full_pass_refresh_template(
                explicit_template=self.config.full_pass_refresh_cmd,
                summary_path=summary_path,
                cycle=cycle,
                force_refresh=force_refresh,
            )
            if resolved_template is None:
                result = {
                    "cycle": cycle,
                    "skipped": True,
                    "reason": template_source,
                    "summary_path": str(summary_path),
                }
                record.outputs = to_jsonable(result)
                record.status = "passed"
                return result
            report_path = build_cycle_artifact_path(
                self.config.full_pass_validation_report_path or (self.run_root / "full-pass-summary.validation.report.json"),
                cycle,
                label="full-pass-report",
            )
            command = render_full_pass_refresh_command(
                template=resolved_template,
                cycle=cycle,
                summary_path=summary_path,
                run_root=self.run_root,
                target_file=self.config.target_file,
                orchestration_result=orchestration_result,
                report_path=report_path,
            )
            completed = subprocess.run(
                command,
                cwd=str(PROJECT_ROOT),
                shell=True,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                check=False,
            )
            result = {
                "cycle": cycle,
                "command": command,
                "command_template_source": template_source,
                "summary_path": str(summary_path),
                "report_path": str(report_path),
                "exit_code": completed.returncode,
                "stdout": completed.stdout,
                "stderr": completed.stderr,
            }
            record.outputs = to_jsonable(result)
            if completed.returncode != 0:
                record.status = "failed"
                raise PipelineExecutionError(
                    stage_name,
                    f"Full Pass Harness/refresh 命令失败：exit={completed.returncode}",
                    exit_code=22,
                    failure_class="infrastructure-error",
                    details={"full_pass_refresh": result},
                )
            if not summary_path.exists():
                record.status = "failed"
                raise PipelineExecutionError(
                    stage_name,
                    f"Full Pass Harness/refresh 未生成 summary.json：{summary_path}",
                    exit_code=22,
                    failure_class="infrastructure-error",
                    details={"full_pass_refresh": result},
                )
            record.status = "passed"
            return result
        except PipelineExecutionError:
            raise
        except Exception as exc:  # noqa: BLE001
            record.status = "failed"
            record.error = f"{type(exc).__name__}: {exc}"
            record.traceback_text = traceback.format_exc()
            raise PipelineExecutionError(
                stage_name,
                record.error,
                exit_code=22,
                failure_class="pipeline-error",
                details={"traceback": record.traceback_text},
            ) from exc
        finally:
            record.ended_at = utc_now()
            record.duration_seconds = round(time.time() - start, 4)
            print(f"[pipeline] stage={stage_name} status={record.status} duration={record.duration_seconds}s")

    def _run_full_pass_validation_stage(self, cycle: int) -> Dict[str, Any]:
        if self.config.full_pass_summary_path is None:
            return {}

        stage_name = f"full-pass-validation[{cycle}]"
        record = StageRecord(name=stage_name, started_at=utc_now())
        self.stage_records.append(record)
        print(f"[pipeline] stage={stage_name} status=started")
        start = time.time()
        try:
            if not DEFAULT_FULL_PASS_VALIDATOR_PATH.exists():
                raise PipelineExecutionError(
                    stage_name,
                    f"找不到 Full Pass 校验器：{DEFAULT_FULL_PASS_VALIDATOR_PATH}",
                    exit_code=22,
                    failure_class="pipeline-error",
                )
            summary_source = self.config.full_pass_summary_path.expanduser().resolve()
            if not summary_source.exists():
                raise PipelineExecutionError(
                    stage_name,
                    f"找不到 Full Pass summary.json：{summary_source}",
                    exit_code=22,
                    failure_class="pipeline-error",
                )
            linked_summary_path = mirror_file_into_run_root(summary_source, build_cycle_artifact_path(self.run_root / "full-pass-summary.input.json", cycle, label="full-pass-summary"))
            report_path = build_cycle_artifact_path(
                self.config.full_pass_validation_report_path or (self.run_root / "full-pass-summary.validation.report.json"),
                cycle,
                label="full-pass-report",
            )
            schema_path = self.config.full_pass_validation_schema_path or DEFAULT_FULL_PASS_SCHEMA_PATH
            command = [
                sys.executable,
                str(DEFAULT_FULL_PASS_VALIDATOR_PATH),
                "--summary",
                str(linked_summary_path),
                "--schema",
                str(schema_path),
                "--report",
                str(report_path),
            ]
            completed = subprocess.run(
                command,
                cwd=str(PROJECT_ROOT),
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                check=False,
            )
            report_payload: Dict[str, Any] = {}
            if report_path.exists():
                with report_path.open("r", encoding="utf-8") as handle:
                    report_payload = json.load(handle)
            with linked_summary_path.open("r", encoding="utf-8") as handle:
                summary_payload = json.load(handle)
            result = {
                "cycle": cycle,
                "validator_command": command,
                "validator_exit_code": completed.returncode,
                "validator_stdout": completed.stdout,
                "validator_stderr": completed.stderr,
                "summary_input_path": str(linked_summary_path),
                "summary": summary_payload,
                "summary_path": str(linked_summary_path),
                "report_path": str(report_path),
                "schema_path": str(schema_path),
                "report": report_payload,
            }
            if self.config.full_pass_sync_current_phase:
                result["status_sync"] = sync_current_phase_file(
                    status_path=self.config.full_pass_status_path,
                    validation_report=report_payload,
                    summary_payload=summary_payload,
                    report_path=report_path,
                    summary_path=linked_summary_path,
                    target_file=self.config.target_file,
                )
            record.outputs = to_jsonable(result)
            record.status = "passed" if completed.returncode == 0 else "failed"
            return result
        except PipelineExecutionError:
            raise
        except Exception as exc:  # noqa: BLE001
            record.status = "failed"
            record.error = f"{type(exc).__name__}: {exc}"
            record.traceback_text = traceback.format_exc()
            raise PipelineExecutionError(
                stage_name,
                record.error,
                exit_code=22,
                failure_class="pipeline-error",
                details={"traceback": record.traceback_text},
            ) from exc
        finally:
            record.ended_at = utc_now()
            record.duration_seconds = round(time.time() - start, 4)
            print(f"[pipeline] stage={stage_name} status={record.status} duration={record.duration_seconds}s")

    def _execute_stage(self, stage_name: str, action: Any) -> Any:
        record = StageRecord(name=stage_name, started_at=utc_now())
        self.stage_records.append(record)
        print(f"[pipeline] stage={stage_name} status=started")
        start = time.time()
        try:
            result = action()
            record.outputs = to_jsonable(result)
            if stage_name.startswith("orchestration[") and isinstance(result, dict):
                record.status = "passed" if str(result.get("final_status", "")).strip() == "passed" else "failed"
            else:
                record.status = "passed"
            return result
        except PipelineExecutionError as exc:
            record.status = "failed"
            record.error = exc.message
            if exc.details:
                record.outputs = to_jsonable(exc.details)
            raise
        except SystemExit as exc:
            record.status = "failed"
            record.error = str(exc) or f"SystemExit({exc.code})"
            raise PipelineExecutionError(stage_name, record.error) from exc
        except Exception as exc:  # noqa: BLE001 - 这里需要兜住全链路异常并归档
            record.status = "failed"
            record.error = f"{type(exc).__name__}: {exc}"
            record.traceback_text = traceback.format_exc()
            raise PipelineExecutionError(stage_name, record.error) from exc
        finally:
            record.ended_at = utc_now()
            record.duration_seconds = round(time.time() - start, 4)
            print(f"[pipeline] stage={stage_name} status={record.status} duration={record.duration_seconds}s")

    def _build_summary(
        self,
        *,
        status: str,
        snapshot_stats: Dict[str, Any],
        repo_map_stats: Dict[str, Any],
        tu: Dict[str, Any],
        orchestration_result: Optional[Dict[str, Any]] = None,
        prompt_dump_stats: Optional[Dict[str, Any]] = None,
        full_pass_validation: Optional[Dict[str, Any]] = None,
        full_pass_iterations: Optional[List[Dict[str, Any]]] = None,
    ) -> Dict[str, Any]:
        orchestration_result = orchestration_result or {}
        prompt_dump_stats = prompt_dump_stats or {}
        full_pass_validation = full_pass_validation or {}
        full_pass_iterations = full_pass_iterations or []
        final_output_path = extract_final_output_path(orchestration_result)
        rounds = orchestration_result.get("rounds", []) if isinstance(orchestration_result.get("rounds"), list) else []
        repair_rounds = max(0, len(rounds) - 1) if rounds else 0
        return {
            "status": status,
            "generated_at": utc_now(),
            "run_started_at": self.run_started_at,
            "run_root": str(self.run_root),
            "config": to_jsonable(asdict(self.config)),
            "metrics": {
                "files_indexed": snapshot_stats.get("file_count", 0),
                "symbols_indexed": snapshot_stats.get("symbol_count", 0),
                "edges_indexed": snapshot_stats.get("edge_count", 0),
                "tu_dependency_count": len(tu.get("dependency_closure", [])) if isinstance(tu.get("dependency_closure"), list) else 0,
                "pattern_examples_used": prompt_dump_stats.get("pattern_examples_used", orchestration_result.get("pattern_examples_used", 0)),
                "repair_rounds": repair_rounds,
                "prompt_total_chars": prompt_dump_stats.get("total_chars", 0),
                "prompt_estimated_tokens": prompt_dump_stats.get("estimated_tokens", 0),
                "full_pass_cycles": len(full_pass_iterations),
                "full_pass_last_exit_code": full_pass_validation.get("validator_exit_code", 0) if isinstance(full_pass_validation, dict) else 0,
            },
            "artifacts": {
                "db_path": str(self.config.db_path),
                "repo_map_path": str(self.config.repo_map_path),
                "tu_json_path": str(self.config.tu_json_path),
                "orchestration_output_path": str(self.config.orchestration_output_path),
                "pattern_memory_path": str(self.config.pattern_memory_path),
                "workspace_root": str(self.config.workspace_root),
                "prompt_dump_path": str(self.config.prompt_dump_path),
                "final_output_path": final_output_path,
                "full_pass_summary_path": str(self.config.full_pass_summary_path or ""),
                "full_pass_validation_report_path": str(self.config.full_pass_validation_report_path or ""),
            },
            "snapshot": snapshot_stats,
            "repo_map": repo_map_stats,
            "tu": {
                "tu_id": tu.get("tu_id", ""),
                "target_path": ((tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}).get("path", ""),
                "target_role": ((tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}).get("role", ""),
                "dependency_count": len(tu.get("dependency_closure", [])) if isinstance(tu.get("dependency_closure"), list) else 0,
            },
            "prompt_dump": prompt_dump_stats,
            "orchestration": {
                "final_status": orchestration_result.get("final_status", "unknown"),
                "workspace_dir": orchestration_result.get("workspace_dir", ""),
                "round_count": len(rounds),
            },
            "full_pass_validation": full_pass_validation,
            "full_pass_iterations": full_pass_iterations,
            "stage_records": [to_jsonable(asdict(item)) for item in self.stage_records],
        }

    def _build_failure_payload(self, exc: PipelineExecutionError) -> Dict[str, Any]:
        status_value = exc.failure_class if exc.failure_class != "pipeline-error" else "failed"
        summary = {
            "status": status_value,
            "generated_at": utc_now(),
            "run_started_at": self.run_started_at,
            "run_root": str(self.run_root),
            "failed_stage": exc.stage_name,
            "failure_class": exc.failure_class,
            "exit_code": exc.exit_code,
            "error": exc.message,
            "details": to_jsonable(exc.details),
            "config": to_jsonable(asdict(self.config)),
            "stage_records": [to_jsonable(asdict(item)) for item in self.stage_records],
        }
        return {
            "status": status_value,
            "failed_stage": exc.stage_name,
            "failure_class": exc.failure_class,
            "exit_code": exc.exit_code,
            "error": exc.message,
            "details": to_jsonable(exc.details),
            "summary": summary,
            "stage_records": [to_jsonable(asdict(item)) for item in self.stage_records],
            "generated_at": utc_now(),
            "run_root": str(self.run_root),
        }

    def _print_summary(self, summary: Dict[str, Any]) -> None:
        metrics = summary.get("metrics", {}) if isinstance(summary.get("metrics"), dict) else {}
        artifacts = summary.get("artifacts", {}) if isinstance(summary.get("artifacts"), dict) else {}
        output_path = artifacts.get("final_output_path", "") or artifacts.get("prompt_dump_path", "")
        print("[pipeline] Execution Summary")
        print(
            "Symbols Indexed: {symbols} | TU Context: {deps} Dependencies | Repair Rounds: {repairs} | Final Output: {output}".format(
                symbols=metrics.get("symbols_indexed", 0),
                deps=metrics.get("tu_dependency_count", 0),
                repairs=metrics.get("repair_rounds", 0),
                output=output_path,
            )
        )
        if metrics.get("prompt_total_chars", 0):
            print(
                "[pipeline] Prompt Summary: chars={chars} est_tokens={tokens}".format(
                    chars=metrics.get("prompt_total_chars", 0),
                    tokens=metrics.get("prompt_estimated_tokens", 0),
                )
            )
        full_pass = summary.get("full_pass_validation", {}) if isinstance(summary.get("full_pass_validation"), dict) else {}
        if full_pass:
            report = full_pass.get("report", {}) if isinstance(full_pass.get("report"), dict) else {}
            print(
                "[pipeline] Full Pass Validation: class={klass} exit={exit_code} report={report_path}".format(
                    klass=report.get("validation_class", "unknown"),
                    exit_code=full_pass.get("validator_exit_code", ""),
                    report_path=full_pass.get("report_path", ""),
                )
            )
        print(f"[pipeline] Summary JSON: {self.config.summary_path}")

    def _print_failure(self, payload: Dict[str, Any]) -> None:
        print("[pipeline] Execution Failed")
        print(
            "[pipeline] failed_stage={stage} failure_class={failure_class} exit_code={exit_code} error={error}".format(
                stage=payload.get('failed_stage', ''),
                failure_class=payload.get('failure_class', ''),
                exit_code=payload.get('exit_code', ''),
                error=payload.get('error', ''),
            )
        )
        details = payload.get('details', {}) if isinstance(payload.get('details'), dict) else {}
        full_pass = details.get('full_pass_validation', {}) if isinstance(details.get('full_pass_validation'), dict) else {}
        if full_pass:
            print(f"[pipeline] full_pass_report={full_pass.get('report_path', '')}")
        print(f"[pipeline] failure_json={self.config.failure_path}")
        print(f"[pipeline] summary_json={self.config.summary_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="统一调度 RepoIndexer -> RepoMapGenerator -> TUBundler -> Orchestrator")
    parser.add_argument("--config-json", type=str, help="可选 JSON 配置文件路径")
    parser.add_argument("--src-root", type=str, help="待索引源码根目录")
    parser.add_argument("--target-file", type=str, help="待构造 TU 的目标文件，相对 src_root 或绝对路径")
    parser.add_argument("--run-root", type=str, help="本次流水线运行目录，默认 artifacts/pipeline_runs/<timestamp>")
    parser.add_argument("--db-path", type=str, help="SQLite 索引输出路径")
    parser.add_argument("--repo-map-path", type=str, help="Repo Map 输出路径")
    parser.add_argument("--tu-json-path", type=str, help="TU JSON 输出路径")
    parser.add_argument("--orchestration-output-path", type=str, help="Orchestrator 结果输出路径")
    parser.add_argument("--summary-path", type=str, help="summary.json 输出路径")
    parser.add_argument("--failure-path", type=str, help="failure.json 输出路径")
    parser.add_argument("--schema-path", type=str, help="Skill Schema 路径")
    parser.add_argument("--architecture-skill", action="append", default=None, help="可重复传入的架构 Skill 文件路径")
    parser.add_argument("--pattern-memory-path", type=str, help="Pattern Memory JSONL 路径")
    parser.add_argument("--workspace-root", type=str, help="Orchestrator 工作区根目录")
    parser.add_argument("--snapshot-label", type=str, help="索引快照标签")
    parser.add_argument("--llm-model", type=str, help="LLM 模型名")
    parser.add_argument("--timeout-seconds", type=int, help="LLM / 验证超时时间（秒）")
    parser.add_argument("--llm-max-retries", type=int, help="LLM 网络重试次数")
    parser.add_argument("--max-rounds", type=int, help="Orchestrator 最大轮数")
    parser.add_argument("--pattern-limit", type=int, help="Pattern Memory few-shot 条数")
    parser.add_argument("--parser-mode", choices=["regex", "ast", "hybrid"], type=str, help="RepoIndexer 解析模式")
    parser.add_argument("--diff-report-path", type=str, help="Hybrid 模式差异报告输出路径")
    parser.add_argument("--dump-prompt-only", dest="dump_prompt_only", action="store_true", help="只构建并导出最终 Translator Prompt，不调用 LLM")
    parser.add_argument("--no-dump-prompt-only", dest="dump_prompt_only", action="store_false", help="关闭 prompt dump only 模式")
    parser.add_argument("--prompt-dump-path", type=str, help="最终 Prompt 导出路径")
    parser.add_argument("--extensions", nargs="+", help="索引扩展名列表")
    parser.add_argument("--exclude-dirs", nargs="+", help="索引排除目录列表")
    parser.add_argument("--repo-map-max-symbols", type=int, help="Repo Map 每文件最大符号数")
    parser.add_argument("--repo-map-max-imports", type=int, help="Repo Map 每文件最大依赖导入数")
    parser.add_argument("--repo-map-max-calls", type=int, help="Repo Map 每文件最大调用热点数")
    parser.add_argument("--tu-max-depth", type=int, help="TU 依赖闭包最大深度")
    parser.add_argument("--tu-max-dependency-files", type=int, help="TU 最大依赖文件数")
    parser.add_argument("--tu-max-signatures-per-file", type=int, help="TU 每依赖文件最大签名数")
    parser.add_argument("--compile-cmd", type=str, help="CompileChecker 命令模板")
    parser.add_argument("--unit-test-cmd", type=str, help="UnitTestChecker 命令模板")
    parser.add_argument("--behavior-cmd", type=str, help="BehaviorMockChecker 命令模板")
    parser.add_argument("--verify-working-directory", type=str, help="验证命令工作目录")
    parser.add_argument("--verify-compiler-executable", type=str, help="真实 cjc 绝对路径")
    parser.add_argument("--verify-package-manager-executable", type=str, help="真实 cjpm 绝对路径")
    parser.add_argument("--verify-compiler-home", type=str, help="SDK 根目录，例如 /path/to/cangjie")
    parser.add_argument("--verify-stdlib-path", type=str, help="标准库目录，例如 /path/to/cangjie/build-tools/modules/.../std")
    parser.add_argument("--verify-runtime-lib-path", type=str, help="运行时库目录，例如 /path/to/cangjie/build-tools/runtime/lib/...")
    parser.add_argument("--verify-tool-bin-path", type=str, help="工具目录，例如 /path/to/cangjie/build-tools/tools/bin")
    parser.add_argument("--verify-extra-env", action="append", default=None, help="额外验证环境变量，格式 KEY=VALUE，可重复传入")
    parser.add_argument("--repair-anchor-file", type=str, help="冻结修复锚点文件路径（通常指向历史高分候选 .cj）")
    parser.add_argument("--repair-anchor-label", type=str, help="冻结修复锚点标签，例如 round41-attempt06")
    parser.add_argument("--frozen-candidate-file", type=str, help="直接复放的冻结候选文件路径；提供后将跳过 live orchestrator，仅执行 verifier")
    parser.add_argument("--frozen-candidate-label", type=str, help="冻结候选标签，例如 phase05-first-pass-baseline")
    parser.add_argument("--full-pass-summary-path", type=str, help="Full Pass 运行生成的 summary.json 路径；提供后将启用第二闸门")
    parser.add_argument("--full-pass-validation-schema-path", type=str, help="Full Pass summary 校验 schema 路径")
    parser.add_argument("--full-pass-validation-report-path", type=str, help="第二闸门 report.json 输出路径")
    parser.add_argument("--full-pass-status-path", type=str, help="状态板 current-phase.md 路径")
    parser.add_argument("--full-pass-sync-current-phase", dest="full_pass_sync_current_phase", action="store_true", help="校验后同步 current-phase.md")
    parser.add_argument("--no-full-pass-sync-current-phase", dest="full_pass_sync_current_phase", action="store_false", help="不要同步 current-phase.md")
    parser.add_argument("--full-pass-refresh-cmd", type=str, help="在每轮 Orchestrate 后生成/刷新 Full Pass summary.json 的命令模板；若省略，则在 summary 缺失或进入 retry cycle 时自动回落到内建的 FULL_PASS_* 标准别名模板")
    parser.add_argument("--full-pass-max-cycles", type=int, help="Full Pass 外层 repair loop 最大轮数")

    parser.add_argument("--mock-mode", dest="is_mock_mode", action="store_true", help="启用 Mock LLM")
    parser.add_argument("--no-mock-mode", dest="is_mock_mode", action="store_false", help="禁用 Mock LLM")
    parser.set_defaults(is_mock_mode=None)

    parser.add_argument("--prefer-tree-sitter", dest="prefer_tree_sitter", action="store_true", help="优先使用 tree-sitter")
    parser.add_argument("--no-prefer-tree-sitter", dest="prefer_tree_sitter", action="store_false", help="禁用 tree-sitter 优先策略")
    parser.set_defaults(prefer_tree_sitter=None)

    parser.add_argument("--reset-db", dest="reset_db", action="store_true", help="索引前重置 SQLite")
    parser.add_argument("--no-reset-db", dest="reset_db", action="store_false", help="索引前不重置 SQLite")
    parser.set_defaults(reset_db=None)

    parser.add_argument("--verify-dry-run", dest="verify_is_dry_run", action="store_true", help="验证器使用 dry-run")
    parser.add_argument("--verify-no-dry-run", dest="verify_is_dry_run", action="store_false", help="验证器使用真实 subprocess")
    parser.set_defaults(verify_is_dry_run=None)

    parser.add_argument("--verify-mock-compiler", dest="verify_mock_compiler", action="store_true", help="CompileChecker 使用 mock")
    parser.add_argument("--verify-real-compile", dest="verify_mock_compiler", action="store_false", help="CompileChecker 走真实命令")
    parser.set_defaults(verify_mock_compiler=None)

    parser.add_argument("--verify-mock-unit-test", dest="verify_mock_unit_test", action="store_true", help="UnitTestChecker 使用 mock")
    parser.add_argument("--verify-real-unit-test", dest="verify_mock_unit_test", action="store_false", help="UnitTestChecker 走真实命令")
    parser.set_defaults(verify_mock_unit_test=None)

    parser.add_argument("--verify-mock-behavior", dest="verify_mock_behavior", action="store_true", help="BehaviorMockChecker 使用 mock")
    parser.add_argument("--verify-real-behavior", dest="verify_mock_behavior", action="store_false", help="BehaviorMockChecker 走真实命令")
    parser.set_defaults(verify_mock_behavior=None)

    parser.add_argument("--verify-enable-compat-cangjie-home", dest="verify_inject_compat_cangjie_home", action="store_true", help="向验证环境额外注入兼容变量 CANGJIE_HOME")
    parser.add_argument("--verify-disable-compat-cangjie-home", dest="verify_inject_compat_cangjie_home", action="store_false", help="不要向验证环境注入兼容变量 CANGJIE_HOME")
    parser.set_defaults(verify_inject_compat_cangjie_home=None)
    parser.set_defaults(dump_prompt_only=None)
    parser.set_defaults(full_pass_sync_current_phase=None)
    return parser.parse_args()


def load_json_config(path: Optional[str]) -> Dict[str, Any]:
    if not path:
        return {}
    config_path = Path(path).expanduser().resolve()
    with config_path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)
    if not isinstance(payload, dict):
        raise SystemExit(f"配置文件必须是 JSON Object：{config_path}")
    payload["_config_base_dir"] = str(config_path.parent)
    payload["_config_path"] = str(config_path)
    return payload


def build_config(args: argparse.Namespace) -> PipelineConfig:
    raw = load_json_config(args.config_json)
    config_base_dir = Path(str(raw.get("_config_base_dir", PROJECT_ROOT)))

    src_root = resolve_path(
        choose(args.src_root, raw.get("src_root"), None),
        base_dir=config_base_dir,
        label="src_root",
        required=True,
    )
    target_file = choose(args.target_file, raw.get("target_file"), None)
    if not target_file:
        raise SystemExit("必须提供 --target-file 或在 config.json 中设置 target_file")

    snapshot_label = str(choose(args.snapshot_label, raw.get("snapshot_label"), build_default_snapshot_label(target_file)))
    run_root_raw = choose(args.run_root, raw.get("run_root"), None)
    run_root = resolve_optional_path(run_root_raw, base_dir=config_base_dir) or build_default_run_root(snapshot_label, target_file)
    run_root.mkdir(parents=True, exist_ok=True)

    target_slug = slugify(Path(target_file).name) or "target"
    db_path = resolve_optional_path(choose(args.db_path, raw.get("db_path"), None), base_dir=config_base_dir) or (run_root / "repo_index.sqlite")
    repo_map_path = resolve_optional_path(choose(args.repo_map_path, raw.get("repo_map_path"), None), base_dir=config_base_dir) or (run_root / "repo_map.txt")
    tu_json_path = resolve_optional_path(choose(args.tu_json_path, raw.get("tu_json_path"), None), base_dir=config_base_dir) or (run_root / f"{target_slug}.tu.json")
    orchestration_output_path = resolve_optional_path(
        choose(args.orchestration_output_path, raw.get("orchestration_output_path"), None),
        base_dir=config_base_dir,
    ) or (run_root / f"{target_slug}.orchestration.json")
    summary_path = resolve_optional_path(choose(args.summary_path, raw.get("summary_path"), None), base_dir=config_base_dir) or (run_root / "summary.json")
    failure_path = resolve_optional_path(choose(args.failure_path, raw.get("failure_path"), None), base_dir=config_base_dir) or (run_root / "failure.json")
    schema_path = resolve_optional_path(choose(args.schema_path, raw.get("schema_path"), None), base_dir=config_base_dir) or DEFAULT_SCHEMA_PATH

    architecture_skill_raw = args.architecture_skill if args.architecture_skill is not None else raw.get("architecture_skill_paths", [])
    architecture_skill_paths = [resolve_path(item, base_dir=config_base_dir, label="architecture_skill", required=True) for item in architecture_skill_raw]

    pattern_memory_path = resolve_optional_path(choose(args.pattern_memory_path, raw.get("pattern_memory_path"), None), base_dir=config_base_dir) or DEFAULT_MEMORY_PATH
    workspace_root = resolve_optional_path(choose(args.workspace_root, raw.get("workspace_root"), None), base_dir=config_base_dir) or (run_root / "temp_workspace")
    verify_compiler_executable = resolve_optional_path(choose(args.verify_compiler_executable, raw.get("verify_compiler_executable"), None), base_dir=config_base_dir)
    verify_package_manager_executable = resolve_optional_path(choose(args.verify_package_manager_executable, raw.get("verify_package_manager_executable"), None), base_dir=config_base_dir)
    verify_compiler_home = resolve_optional_path(choose(args.verify_compiler_home, raw.get("verify_compiler_home"), None), base_dir=config_base_dir)
    verify_stdlib_path = resolve_optional_path(choose(args.verify_stdlib_path, raw.get("verify_stdlib_path"), None), base_dir=config_base_dir)
    verify_runtime_lib_path = resolve_optional_path(choose(args.verify_runtime_lib_path, raw.get("verify_runtime_lib_path"), None), base_dir=config_base_dir)
    verify_tool_bin_path = resolve_optional_path(choose(args.verify_tool_bin_path, raw.get("verify_tool_bin_path"), None), base_dir=config_base_dir)
    verify_extra_env = normalize_verify_extra_env_config(args.verify_extra_env, raw.get("verify_extra_env"))
    repair_anchor_file = resolve_optional_path(choose(args.repair_anchor_file, raw.get("repair_anchor_file"), None), base_dir=config_base_dir)
    repair_anchor_label = choose(args.repair_anchor_label, raw.get("repair_anchor_label"), None)
    frozen_candidate_file = resolve_optional_path(choose(args.frozen_candidate_file, raw.get("frozen_candidate_file"), None), base_dir=config_base_dir)
    frozen_candidate_label = choose(args.frozen_candidate_label, raw.get("frozen_candidate_label"), None)
    full_pass_summary_path = resolve_optional_path(choose(args.full_pass_summary_path, raw.get("full_pass_summary_path"), None), base_dir=config_base_dir)
    full_pass_validation_schema_path = resolve_optional_path(choose(args.full_pass_validation_schema_path, raw.get("full_pass_validation_schema_path"), None), base_dir=config_base_dir) or DEFAULT_FULL_PASS_SCHEMA_PATH
    full_pass_validation_report_path = resolve_optional_path(choose(args.full_pass_validation_report_path, raw.get("full_pass_validation_report_path"), None), base_dir=config_base_dir)
    full_pass_sync_current_phase = bool(choose(args.full_pass_sync_current_phase, raw.get("full_pass_sync_current_phase"), True))
    full_pass_status_path = resolve_optional_path(choose(args.full_pass_status_path, raw.get("full_pass_status_path"), None), base_dir=config_base_dir) or DEFAULT_CURRENT_PHASE_PATH
    full_pass_refresh_cmd_raw = choose(args.full_pass_refresh_cmd, raw.get("full_pass_refresh_cmd"), None)
    full_pass_refresh_cmd = str(full_pass_refresh_cmd_raw) if full_pass_refresh_cmd_raw not in (None, "") else None
    full_pass_max_cycles = int(choose(args.full_pass_max_cycles, raw.get("full_pass_max_cycles"), 1))
    parser_mode = choose(args.parser_mode, raw.get("parser_mode"), None)
    diff_report_path = resolve_optional_path(choose(args.diff_report_path, raw.get("diff_report_path"), None), base_dir=config_base_dir)
    dump_prompt_only = bool(choose(args.dump_prompt_only, raw.get("dump_prompt_only"), False))
    prompt_dump_path = resolve_optional_path(choose(args.prompt_dump_path, raw.get("prompt_dump_path"), None), base_dir=config_base_dir) or (run_root / "prompt_dump.txt")

    extensions = [str(item) for item in choose(args.extensions, raw.get("extensions"), list(DEFAULT_EXTENSIONS))]
    exclude_dirs = [str(item) for item in choose(args.exclude_dirs, raw.get("exclude_dirs"), sorted(DEFAULT_EXCLUDE_DIRS))]

    return PipelineConfig(
        src_root=src_root,
        target_file=str(target_file),
        run_root=run_root,
        db_path=db_path,
        repo_map_path=repo_map_path,
        tu_json_path=tu_json_path,
        orchestration_output_path=orchestration_output_path,
        summary_path=summary_path,
        failure_path=failure_path,
        schema_path=schema_path,
        architecture_skill_paths=architecture_skill_paths,
        pattern_memory_path=pattern_memory_path,
        workspace_root=workspace_root,
        snapshot_label=snapshot_label,
        llm_model=str(choose(args.llm_model, raw.get("llm_model"), DEFAULT_MODEL)),
        is_mock_mode=bool(choose(args.is_mock_mode, raw.get("is_mock_mode"), True)),
        timeout_seconds=int(choose(args.timeout_seconds, raw.get("timeout_seconds"), DEFAULT_PIPELINE_TIMEOUT_SECONDS)),
        llm_max_retries=int(choose(args.llm_max_retries, raw.get("llm_max_retries"), 3)),
        max_rounds=int(choose(args.max_rounds, raw.get("max_rounds"), 3)),
        pattern_limit=int(choose(args.pattern_limit, raw.get("pattern_limit"), 3)),
        extensions=extensions,
        exclude_dirs=exclude_dirs,
        prefer_tree_sitter=bool(choose(args.prefer_tree_sitter, raw.get("prefer_tree_sitter"), True)),
        parser_mode=str(parser_mode) if parser_mode is not None else None,
        diff_report_path=diff_report_path,
        reset_db=bool(choose(args.reset_db, raw.get("reset_db"), True)),
        dump_prompt_only=dump_prompt_only,
        prompt_dump_path=prompt_dump_path,
        repo_map_max_symbols=int(choose(args.repo_map_max_symbols, raw.get("repo_map_max_symbols"), 6)),
        repo_map_max_imports=int(choose(args.repo_map_max_imports, raw.get("repo_map_max_imports"), 6)),
        repo_map_max_calls=int(choose(args.repo_map_max_calls, raw.get("repo_map_max_calls"), 8)),
        tu_max_depth=int(choose(args.tu_max_depth, raw.get("tu_max_depth"), 2)),
        tu_max_dependency_files=int(choose(args.tu_max_dependency_files, raw.get("tu_max_dependency_files"), 12)),
        tu_max_signatures_per_file=int(choose(args.tu_max_signatures_per_file, raw.get("tu_max_signatures_per_file"), 8)),
        verify_is_dry_run=bool(choose(args.verify_is_dry_run, raw.get("verify_is_dry_run"), True)),
        verify_mock_compiler=bool(choose(args.verify_mock_compiler, raw.get("verify_mock_compiler"), True)),
        verify_mock_unit_test=bool(choose(args.verify_mock_unit_test, raw.get("verify_mock_unit_test"), True)),
        verify_mock_behavior=bool(choose(args.verify_mock_behavior, raw.get("verify_mock_behavior"), True)),
        compile_cmd=str(choose(args.compile_cmd, raw.get("compile_cmd"), "cjc --diagnostic-format noColor --output-type staticlib -o {attempt_dir}/candidate_output {compile_input_paths}")),
        unit_test_cmd=str(choose(args.unit_test_cmd, raw.get("unit_test_cmd"), "cjpm test --package-root {workspace_dir}")),
        behavior_cmd=str(choose(args.behavior_cmd, raw.get("behavior_cmd"), "python -c 'print(\"behavior-ok\")'")),
        verify_working_directory=choose(args.verify_working_directory, raw.get("verify_working_directory"), None),
        verify_compiler_executable=verify_compiler_executable,
        verify_package_manager_executable=verify_package_manager_executable,
        verify_compiler_home=verify_compiler_home,
        verify_stdlib_path=verify_stdlib_path,
        verify_runtime_lib_path=verify_runtime_lib_path,
        verify_tool_bin_path=verify_tool_bin_path,
        verify_extra_env=verify_extra_env,
        verify_inject_compat_cangjie_home=bool(choose(args.verify_inject_compat_cangjie_home, raw.get("verify_inject_compat_cangjie_home"), True)),
        repair_anchor_file=repair_anchor_file,
        repair_anchor_label=str(repair_anchor_label) if repair_anchor_label is not None else None,
        frozen_candidate_file=frozen_candidate_file,
        frozen_candidate_label=str(frozen_candidate_label) if frozen_candidate_label is not None else None,
        full_pass_summary_path=full_pass_summary_path,
        full_pass_validation_schema_path=full_pass_validation_schema_path,
        full_pass_validation_report_path=full_pass_validation_report_path or (run_root / "full-pass-summary.validation.report.json"),
        full_pass_status_path=full_pass_status_path,
        full_pass_sync_current_phase=full_pass_sync_current_phase,
        full_pass_refresh_cmd=full_pass_refresh_cmd,
        full_pass_max_cycles=max(1, full_pass_max_cycles),
    )



def build_cycle_artifact_path(base_path: Path, cycle: int, *, label: str) -> Path:
    base = base_path.expanduser().resolve()
    suffix = ''.join(base.suffixes)
    stem = base.name[:-len(suffix)] if suffix else base.name
    filename = f"{stem}.cycle-{cycle:02d}.{label}{suffix}" if suffix else f"{stem}.cycle-{cycle:02d}.{label}"
    return base.with_name(filename)


def build_full_pass_feedback_payload(validation_result: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "report": validation_result.get("report", {}),
        "summary": validation_result.get("summary", {}),
        "report_path": validation_result.get("report_path", ""),
        "summary_path": validation_result.get("summary_path", ""),
        "cycle": validation_result.get("cycle"),
    }


def build_runtime_repair_anchor_payload(
    orchestration_result: Dict[str, Any],
    cycle: int,
    fallback: Optional[Dict[str, Any]] = None,
) -> Optional[Dict[str, Any]]:
    final_artifact = orchestration_result.get("final_artifact", {}) if isinstance(orchestration_result.get("final_artifact"), dict) else {}
    code = str(final_artifact.get("generated_code", "")).strip()
    metadata = final_artifact.get("metadata", {}) if isinstance(final_artifact.get("metadata"), dict) else {}
    source_path = str(metadata.get("candidate_file_path", ""))
    if not code:
        return fallback
    return {
        "label": f"full-pass-cycle-{cycle:02d}-validator-repair-anchor",
        "code": code,
        "source_path": source_path,
    }


def resolve_full_pass_refresh_template(
    *,
    explicit_template: Optional[str],
    summary_path: Optional[Path],
    cycle: int,
    force_refresh: bool,
) -> tuple[Optional[str], str]:
    if explicit_template:
        return explicit_template, "user-provided"
    if summary_path is None:
        return None, "no-summary-path"
    resolved_summary_path = summary_path.expanduser().resolve()
    if resolved_summary_path.exists() and not force_refresh:
        return None, "existing-summary-no-refresh-command"
    return DEFAULT_FULL_PASS_REFRESH_CMD_TEMPLATE, "builtin-default"


def render_full_pass_refresh_command(
    *,
    template: Optional[str],
    cycle: int,
    summary_path: Path,
    run_root: Path,
    target_file: str,
    orchestration_result: Dict[str, Any],
    report_path: Path,
) -> str:
    if not template:
        return ""
    final_output_path = extract_final_output_path(orchestration_result)
    return template.format(
        cycle=cycle,
        full_pass_summary_path=str(summary_path),
        run_root=str(run_root),
        target_file=target_file,
        orchestration_output_path=str(orchestration_result.get("output_path", "")),
        final_output_path=final_output_path,
        full_pass_report_path=str(report_path),
    )


def classify_full_pass_failure_class(exit_code: int) -> str:
    if exit_code == 10:
        return "repair-required"
    if exit_code in {20, 21}:
        return "infrastructure-error"
    return "pipeline-error"


def build_full_pass_validation_error_message(report: Dict[str, Any], exit_code: int) -> str:
    validation_class = str(report.get("validation_class", "unknown"))
    if exit_code == 10:
        reasons = []
        for item in report.get("nonpassed_assertions", [])[:3]:
            if not isinstance(item, dict):
                continue
            reasons.append(
                "{assertion_id}:{status}:{reason}".format(
                    assertion_id=item.get("assertion_id", ""),
                    status=item.get("status", ""),
                    reason=item.get("failure_reason") or "<missing>",
                )
            )
        reason_text = "; ".join(reasons) if reasons else "实验逻辑未通过，但未提供 failure_reason"
        return f"Full Pass 逻辑未通过：{reason_text}"
    if exit_code in {20, 21}:
        issues = []
        for item in report.get("issues", [])[:3]:
            if not isinstance(item, dict):
                continue
            issues.append(f"{item.get('code', 'issue')}:{item.get('message', '')}")
        issue_text = "; ".join(issues) if issues else validation_class
        return f"Full Pass 证据链断裂：{issue_text}"
    return f"Full Pass 校验器异常退出：exit={exit_code} class={validation_class}"


def mirror_file_into_run_root(source: Path, destination: Path) -> Path:
    source = source.expanduser().resolve()
    destination = destination.expanduser().resolve()
    destination.parent.mkdir(parents=True, exist_ok=True)
    if source == destination:
        return destination
    if destination.exists() or destination.is_symlink():
        destination.unlink()
    try:
        destination.symlink_to(source)
    except OSError:
        shutil.copy2(source, destination)
    return destination


def replace_or_append_managed_block(markdown_text: str, block_name: str, block_text: str, *, anchor: str = "blocked_by:") -> str:
    pattern = re.compile(rf"(?ms)^{re.escape(block_name)}:\n.*?(?=^[a-z_]+:\s*|\Z)")
    replacement = block_text if block_text.endswith("\n") else block_text + "\n"
    if pattern.search(markdown_text):
        return pattern.sub(replacement, markdown_text, count=1)
    marker = f"{anchor}\n"
    if marker in markdown_text:
        return markdown_text.replace(marker, replacement + marker, 1)
    suffix = "" if markdown_text.endswith("\n") else "\n"
    return markdown_text + suffix + replacement


def sync_current_phase_file(
    *,
    status_path: Optional[Path],
    validation_report: Dict[str, Any],
    summary_payload: Dict[str, Any],
    report_path: Path,
    summary_path: Path,
    target_file: str,
) -> Dict[str, Any]:
    if status_path is None:
        return {"synced": False, "reason": "status-path-not-configured"}
    resolved_status_path = status_path.expanduser().resolve()
    if not resolved_status_path.exists():
        return {"synced": False, "reason": f"status-path-missing:{resolved_status_path}"}

    text = resolved_status_path.read_text(encoding="utf-8")
    report_class = str(validation_report.get("validation_class", "unknown"))
    exit_code = str(validation_report.get("exit_code", ""))
    scenario_mode = str(summary_payload.get("scenario_mode", "bcm") or "bcm")
    promotion_assessment = classify_full_pass_promotion(validation_report, summary_payload)
    extracted_ids = ", ".join(validation_report.get("extracted_assertion_ids", [])) or "<none>"
    nonpassed_rows = validation_report.get("nonpassed_assertions", [])
    if isinstance(nonpassed_rows, list) and nonpassed_rows:
        nonpassed_text = "; ".join(
            "{assertion_id}:{status}:{reason}".format(
                assertion_id=item.get("assertion_id", ""),
                status=item.get("status", ""),
                reason=item.get("failure_reason") or "<missing>",
            )
            for item in nonpassed_rows
            if isinstance(item, dict)
        ) or "<none>"
    else:
        nonpassed_text = "none"
    block = "\n".join(
        [
            "latest_full_pass_validation:",
            f"- label: `{summary_payload.get('label', '')}`",
            f"- module: `{((summary_payload.get('module') or {}) if isinstance(summary_payload.get('module'), dict) else {}).get('name', '')}`",
            f"- target_file: `{((summary_payload.get('module') or {}) if isinstance(summary_payload.get('module'), dict) else {}).get('source_file', target_file)}`",
            f"- overall_status: `{summary_payload.get('overall_status', '')}`",
            f"- scenario_mode: `{scenario_mode}`",
            f"- validation_class: `{report_class}`",
            f"- validator_exit_code: `{exit_code}`",
            f"- promotion_assessment: `{promotion_assessment}`",
            f"- extracted_assertions: `{extracted_ids}`",
            f"- nonpassed_assertions: `{nonpassed_text}`",
            f"- summary_path: `{summary_path}`",
            f"- report_path: `{report_path}`",
            f"- synced_at: `{utc_now()}`",
            "",
        ]
    )
    updated = replace_or_append_managed_block(text, "latest_full_pass_validation", block)
    if promotion_assessment == "full-pass-achieved":
        updated = re.sub(r"^phase: .*?$", "phase: `Phase 3C Full Pass achieved`", updated, count=1, flags=re.MULTILINE)
    resolved_status_path.write_text(updated, encoding="utf-8")
    return {
        "synced": True,
        "status_path": str(resolved_status_path),
        "promotion_assessment": promotion_assessment,
        "scenario_mode": scenario_mode,
    }


def classify_full_pass_promotion(validation_report: Dict[str, Any], summary_payload: Dict[str, Any]) -> str:
    if int(validation_report.get("exit_code", 22)) != 0:
        return "not-promoted"
    if str(summary_payload.get("overall_status", "")) != "passed":
        return "not-promoted"
    scenario_mode = str(summary_payload.get("scenario_mode", "bcm") or "bcm")
    if scenario_mode == "smoke":
        return "smoke-only-pass"
    return "full-pass-achieved"


def choose(cli_value: Any, config_value: Any, default: Any) -> Any:
    if cli_value is not None:
        return cli_value
    if config_value is not None:
        return config_value
    return default


def parse_key_value_items(items: Optional[List[str]], *, source_label: str) -> Dict[str, str]:
    result: Dict[str, str] = {}
    for item in items or []:
        if "=" not in item:
            raise SystemExit(f"{source_label} 参数格式错误，应为 KEY=VALUE：{item}")
        key, value = item.split("=", 1)
        key = key.strip()
        if not key:
            raise SystemExit(f"{source_label} 参数缺少键名：{item}")
        result[key] = value
    return result


def normalize_verify_extra_env_config(cli_items: Optional[List[str]], config_value: Any) -> Dict[str, str]:
    cli_payload = parse_key_value_items(cli_items, source_label="--verify-extra-env")
    if cli_payload:
        return cli_payload
    if config_value in (None, ""):
        return {}
    if isinstance(config_value, dict):
        return {str(key): str(value) for key, value in config_value.items()}
    if isinstance(config_value, list):
        return parse_key_value_items([str(item) for item in config_value], source_label="verify_extra_env")
    if isinstance(config_value, str):
        return parse_key_value_items([config_value], source_label="verify_extra_env")
    raise SystemExit("verify_extra_env 仅支持 object、string 或 string list")


def load_repair_anchor_payload(anchor_file: Optional[Path], anchor_label: Optional[str]) -> Optional[Dict[str, str]]:
    return load_code_anchor_payload(anchor_file, anchor_label, label="repair anchor")


def load_frozen_candidate_payload(anchor_file: Optional[Path], anchor_label: Optional[str]) -> Optional[Dict[str, str]]:
    return load_code_anchor_payload(anchor_file, anchor_label, label="frozen candidate")


def load_code_anchor_payload(anchor_file: Optional[Path], anchor_label: Optional[str], *, label: str) -> Optional[Dict[str, str]]:
    if anchor_file is None:
        return None
    resolved = anchor_file.expanduser().resolve()
    if not resolved.exists():
        raise SystemExit(f"{label} 文件不存在：{resolved}")
    code = resolved.read_text(encoding="utf-8")
    if not code.strip():
        raise SystemExit(f"{label} 文件为空：{resolved}")
    return {
        "label": str(anchor_label or resolved.name),
        "code": code,
        "source_path": str(resolved),
    }


def resolve_path(value: Any, *, base_dir: Path, label: str, required: bool) -> Path:
    path = resolve_optional_path(value, base_dir=base_dir)
    if path is None:
        if required:
            raise SystemExit(f"缺少必要路径参数：{label}")
        raise SystemExit(f"路径参数解析失败：{label}")
    return path


def resolve_optional_path(value: Any, *, base_dir: Path) -> Optional[Path]:
    if value in (None, ""):
        return None
    raw = Path(str(value)).expanduser()
    if raw.is_absolute():
        return raw.resolve()
    return (base_dir / raw).resolve()


def query_snapshot_stats(db_path: Path, snapshot_label: str) -> Dict[str, Any]:
    if not db_path.exists():
        raise PipelineExecutionError("index", f"索引库不存在：{db_path}")
    connection = sqlite3.connect(db_path)
    connection.row_factory = sqlite3.Row
    try:
        snapshot = connection.execute(
            "SELECT * FROM snapshots WHERE label = ? ORDER BY id DESC LIMIT 1",
            (snapshot_label,),
        ).fetchone()
        if snapshot is None:
            raise PipelineExecutionError("index", f"找不到快照：{snapshot_label}")
        snapshot_id = int(snapshot["id"])
        file_count = int(connection.execute(
            "SELECT COUNT(*) FROM nodes WHERE snapshot_id = ? AND kind = 'file'",
            (snapshot_id,),
        ).fetchone()[0])
        symbol_count = int(connection.execute(
            "SELECT COUNT(*) FROM nodes WHERE snapshot_id = ? AND kind IN ('class', 'interface', 'function', 'method')",
            (snapshot_id,),
        ).fetchone()[0])
        edge_count = int(connection.execute(
            "SELECT COUNT(*) FROM edges WHERE snapshot_id = ?",
            (snapshot_id,),
        ).fetchone()[0])
        return {
            "snapshot_id": snapshot_id,
            "snapshot_label": snapshot["label"],
            "root_path": snapshot["root_path"],
            "parser_backend": snapshot["parser_backend"],
            "created_at": snapshot["created_at"],
            "file_count": file_count,
            "symbol_count": symbol_count,
            "edge_count": edge_count,
        }
    finally:
        connection.close()


def extract_final_output_path(orchestration_result: Dict[str, Any]) -> str:
    final_artifact = orchestration_result.get("final_artifact")
    if not isinstance(final_artifact, dict):
        return ""
    metadata = final_artifact.get("metadata")
    if not isinstance(metadata, dict):
        return ""
    return str(metadata.get("candidate_file_path", ""))


def count_lines(path: Path) -> int:
    if not path.exists():
        return 0
    with path.open("r", encoding="utf-8") as handle:
        return sum(1 for _ in handle)


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(to_jsonable(payload), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def to_jsonable(value: Any) -> Any:
    if isinstance(value, Path):
        return str(value)
    if isinstance(value, dict):
        return {str(key): to_jsonable(item) for key, item in value.items()}
    if isinstance(value, list):
        return [to_jsonable(item) for item in value]
    if isinstance(value, tuple):
        return [to_jsonable(item) for item in value]
    return value


def build_default_snapshot_label(target_file: str) -> str:
    return f"pipeline-{slugify(Path(target_file).stem) or 'snapshot'}"


def build_default_run_root(snapshot_label: str, target_file: str) -> Path:
    timestamp = dt.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    slug = slugify(f"{snapshot_label}-{Path(target_file).stem}") or "pipeline-run"
    return DEFAULT_PIPELINE_ROOT / f"{timestamp}-{slug}"


def slugify(value: str) -> str:
    allowed = []
    for char in value.lower():
        if char.isalnum():
            allowed.append(char)
        else:
            allowed.append("-")
    text = "".join(allowed).strip("-")
    while "--" in text:
        text = text.replace("--", "-")
    return text


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def estimate_token_count(text: str) -> int:
    if not text:
        return 0
    return max(1, (len(text) + 3) // 4)


def render_prompt_dump(
    *,
    prompt: Any,
    tu: Dict[str, Any],
    model: str,
    schema_path: Path,
    architecture_skill_paths: List[Path],
    required_dimensions: List[str],
    pattern_examples: List[Dict[str, Any]],
) -> str:
    system_prompt = next((message.content for message in prompt.messages if getattr(message, 'role', '') == 'system'), '')
    user_prompt = next((message.content for message in prompt.messages if getattr(message, 'role', '') == 'user'), '')
    target = tu.get('target', {}) if isinstance(tu.get('target'), dict) else {}
    dependency_closure = tu.get('dependency_closure', []) if isinstance(tu.get('dependency_closure'), list) else []
    header = {
        'generated_at': utc_now(),
        'model': model,
        'tu_id': tu.get('tu_id', ''),
        'target_path': target.get('path', ''),
        'target_role': target.get('role', ''),
        'required_dimensions': required_dimensions,
        'schema_path': str(schema_path),
        'architecture_skill_paths': [str(item) for item in architecture_skill_paths],
        'pattern_examples_used': len(pattern_examples),
        'dependency_count': len(dependency_closure),
        'system_chars': len(system_prompt),
        'user_chars': len(user_prompt),
        'total_chars': len(system_prompt) + len(user_prompt),
        'estimated_tokens': estimate_token_count(system_prompt) + estimate_token_count(user_prompt),
    }
    sections = [
        '# Phase-02 Final Prompt Dump',
        '[Metadata]',
        json.dumps(header, ensure_ascii=False, indent=2),
        '[System Prompt]',
        system_prompt,
        '[User Prompt]',
        user_prompt,
    ]
    return '\n\n'.join(sections) + '\n'


def main() -> int:
    args = parse_args()
    config = build_config(args)
    runner = PipelineRunner(config)
    return runner.run()


if __name__ == "__main__":
    raise SystemExit(main())
