#!/usr/bin/env python3
"""工作区管理器。

功能：
1. 为每次 Orchestrator 运行创建唯一的临时工作区；
2. 为每轮翻译尝试创建独立的 attempt 目录；
3. 将候选 `.cj` 代码真实落盘到沙盒目录；
4. 记录运行与尝试级 manifest，便于后续接入真实编译器与归档分析。
"""

from __future__ import annotations

import datetime as dt
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Dict, Mapping, Optional, Sequence

from precompiled_dependency_registry import (
    DEFAULT_PRECOMPILED_CANDIDATE_REGISTRY,
    ExplicitStagedContractSpec,
    PrecompiledDependencySpec,
    collect_dependency_paths,
    derive_normalized_package_name,
    filter_dependency_paths_for_target,
    normalize_registry,
    resolve_explicit_staged_contract_specs,
    resolve_precompiled_dependency_specs,
    rewrite_package_declaration,
    target_uses_explicit_staged_contracts,
)

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_WORKSPACE_ROOT = PROJECT_ROOT / "artifacts" / "temp_workspace"
MTPROTO_CORE_DIR = Path("src/core/mtproto")


@dataclass
class WorkspaceSession:
    session_id: str
    root_dir: Path
    tu_id: str
    target_path: str
    created_at: str


@dataclass
class CandidateWriteResult:
    attempt: int
    attempt_dir: Path
    candidate_file_path: Path
    candidate_rel_path: str
    manifest_path: Path
    bytes_written: int


@dataclass
class StagedDependencyWriteResult:
    source_path: str
    staged_file_path: Path
    staged_rel_path: str
    original_candidate_path: Path
    normalized_package_name: str


class WorkspaceManager:
    def __init__(
        self,
        base_dir: Path = DEFAULT_WORKSPACE_ROOT,
        *,
        precompiled_registry: Optional[Mapping[str, str | Path]] = None,
    ) -> None:
        self.base_dir = base_dir.resolve()
        self.base_dir.mkdir(parents=True, exist_ok=True)
        self.precompiled_registry = normalize_registry(precompiled_registry or DEFAULT_PRECOMPILED_CANDIDATE_REGISTRY)

    def create_session(self, tu_id: str, target_path: str) -> WorkspaceSession:
        timestamp = utc_now_for_fs()
        slug = slugify(tu_id)[:80] or "translation-task"
        session_id = f"{timestamp}-{slug}"
        root_dir = self.base_dir / session_id
        root_dir.mkdir(parents=True, exist_ok=True)
        session = WorkspaceSession(
            session_id=session_id,
            root_dir=root_dir,
            tu_id=tu_id,
            target_path=target_path,
            created_at=utc_now(),
        )
        self._write_json(
            root_dir / "session.json",
            {
                "session_id": session.session_id,
                "root_dir": str(session.root_dir),
                "tu_id": session.tu_id,
                "target_path": session.target_path,
                "created_at": session.created_at,
            },
        )
        return session

    def write_candidate_code(
        self,
        session: WorkspaceSession,
        *,
        attempt: int,
        source_target_path: str,
        generated_code: str,
        extra_metadata: Optional[Dict[str, object]] = None,
    ) -> CandidateWriteResult:
        attempt_dir = session.root_dir / f"attempt-{attempt:02d}"
        candidate_rel_path = build_candidate_relative_path(source_target_path)
        candidate_file_path = attempt_dir / candidate_rel_path
        candidate_file_path.parent.mkdir(parents=True, exist_ok=True)
        normalized_target_path = Path(source_target_path).as_posix()
        materialized_code = generated_code
        if target_uses_explicit_staged_contracts(normalized_target_path):
            materialized_code = rewrite_package_declaration(
                generated_code,
                derive_normalized_package_name(normalized_target_path),
            )
        candidate_file_path.write_text(materialized_code, encoding="utf-8")
        manifest_path = attempt_dir / "attempt_manifest.json"
        manifest_payload = {
            "attempt": attempt,
            "source_target_path": source_target_path,
            "candidate_file_path": str(candidate_file_path),
            "candidate_rel_path": candidate_rel_path,
            "workspace_dir": str(session.root_dir),
            "attempt_dir": str(attempt_dir),
            "bytes_written": candidate_file_path.stat().st_size,
            "written_at": utc_now(),
            "metadata": extra_metadata or {},
        }
        self._write_json(manifest_path, manifest_payload)
        return CandidateWriteResult(
            attempt=attempt,
            attempt_dir=attempt_dir,
            candidate_file_path=candidate_file_path,
            candidate_rel_path=candidate_rel_path,
            manifest_path=manifest_path,
            bytes_written=candidate_file_path.stat().st_size,
        )

    def write_round_archive(
        self,
        session: WorkspaceSession,
        *,
        attempt: int,
        payload: Dict[str, object],
        filename: str,
    ) -> Path:
        attempt_dir = session.root_dir / f"attempt-{attempt:02d}"
        attempt_dir.mkdir(parents=True, exist_ok=True)
        path = attempt_dir / filename
        self._write_json(path, payload)
        return path

    def stage_precompiled_dependencies(
        self,
        session: WorkspaceSession,
        *,
        attempt: int,
        source_target_path: str,
        tu: Dict[str, object],
        include_same_directory_pool: bool = True,
    ) -> Sequence[StagedDependencyWriteResult]:
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        risk_tags = [str(item) for item in target.get("risk_tags", [])] if isinstance(target.get("risk_tags"), list) else []
        normalized_target_path = Path(source_target_path).as_posix()
        is_mtproto_core_module = Path(normalized_target_path).parent == MTPROTO_CORE_DIR
        explicit_contract_specs = resolve_explicit_staged_contract_specs(target_path=normalized_target_path)
        if not explicit_contract_specs:
            if role != "module":
                return []
            if "[ASYNC_FLOW]" not in risk_tags and not is_mtproto_core_module:
                return []
        dependency_paths = filter_dependency_paths_for_target(
            normalized_target_path,
            collect_dependency_paths(tu),
        )
        dependency_specs = list(
            resolve_precompiled_dependency_specs(
                target_path=source_target_path,
                dependency_paths=dependency_paths,
                registry=self.precompiled_registry,
                include_same_directory_pool=include_same_directory_pool,
            )
        )
        ordered_specs: Dict[str, PrecompiledDependencySpec | ExplicitStagedContractSpec] = {}
        for spec in explicit_contract_specs:
            ordered_specs[spec.source_path] = spec
        for spec in dependency_specs:
            ordered_specs[spec.source_path] = spec
        if not ordered_specs:
            return []
        attempt_dir = session.root_dir / f"attempt-{attempt:02d}"
        normalized_package_name = derive_normalized_package_name(source_target_path)
        results = []
        for spec in ordered_specs.values():
            staged_rel_path = build_candidate_relative_path(spec.source_path)
            staged_file_path = attempt_dir / staged_rel_path
            staged_file_path.parent.mkdir(parents=True, exist_ok=True)
            code = spec.candidate_path.read_text(encoding="utf-8")
            staged_code = rewrite_package_declaration(code, normalized_package_name)
            staged_file_path.write_text(staged_code, encoding="utf-8")
            results.append(
                StagedDependencyWriteResult(
                    source_path=spec.source_path,
                    staged_file_path=staged_file_path,
                    staged_rel_path=staged_rel_path,
                    original_candidate_path=spec.candidate_path,
                    normalized_package_name=normalized_package_name,
                )
            )
        return results

    def _write_json(self, path: Path, payload: Dict[str, object]) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def build_candidate_relative_path(source_target_path: str) -> str:
    source = Path(source_target_path)
    filename = source.stem + ".cj"
    if source.parent == Path("."):
        return filename
    return source.with_suffix(".cj").as_posix()


def slugify(value: str) -> str:
    text = re.sub(r"[^A-Za-z0-9._-]+", "-", value.strip())
    text = re.sub(r"-+", "-", text).strip("-")
    return text.lower()


def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def utc_now_for_fs() -> str:
    return dt.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
