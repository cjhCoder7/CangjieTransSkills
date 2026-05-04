#!/usr/bin/env python3
"""已验证依赖候选注册表与 staging 辅助工具。"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
from typing import Dict, Iterable, List, Mapping, Sequence, Tuple


PROJECT_ROOT = Path(__file__).resolve().parents[1]

DEFAULT_PRECOMPILED_CANDIDATE_REGISTRY: Dict[str, str] = {
    "src/core/mtproto/MTProtoClient.ets": (
        "tests/fixtures/anchors/precompiled/mtprotoclient_source_aligned.cj"
    ),
    "src/core/mtproto/MTProtoConfig.ets": (
        "tests/fixtures/anchors/precompiled/mtprotoconfig_source_aligned.cj"
    ),
    "src/core/mtproto/CryptoUtils.ets": (
        "tests/fixtures/anchors/precompiled/cryptoutils_source_aligned.cj"
    ),
    "src/core/mtproto/TLMethods.ets": (
        "artifacts/pipeline_runs/phase03-tlmethods-repair-003/"
        "temp_workspace/20260401T020951Z-tu-pipeline-tlmethods-src-core-mtproto-tlmethods.ets/"
        "attempt-01/src/core/mtproto/TLMethods.cj"
    ),
    "src/core/mtproto/TLSerialization.ets": (
        "tests/fixtures/anchors/precompiled/tlserialization_source_aligned.cj"
    ),
    "src/core/mtproto/TLDialogs.ets": (
        "artifacts/pipeline_runs/phase03-tldialogs-repair-002/"
        "temp_workspace/20260401T025220Z-tu-pipeline-tldialogs-src-core-mtproto-tldialogs.ets/"
        "attempt-02/src/core/mtproto/TLDialogs.cj"
    ),
    "src/core/mtproto/MTProtoTransport.ets": (
        "tests/fixtures/anchors/precompiled/mtprototransport_source_aligned.cj"
    ),
    "src/core/mtproto/AuthKeyCreator.ets": (
        "tests/fixtures/anchors/precompiled/authkeycreator_source_aligned.cj"
    ),
    "src/core/mtproto/Inflate.ets": (
        "tests/fixtures/anchors/precompiled/inflate_source_aligned.cj"
    ),
}

DEFAULT_EXPLICIT_STAGED_CONTRACT_REGISTRY: Dict[str, Tuple[Dict[str, object], ...]] = {
    "src/services/RealMessageService.ets": (
        {
            "source_path": "src/services/RealMessageServiceExternalContracts.ets",
            "candidate_path": "tests/fixtures/anchors/precompiled/realmessageservice_service_contracts.cj",
            "provided_symbols": (
                "IMessageService",
                "PeerId",
                "Message",
                "MessageTimeline",
                "Signal",
                "SendMessageParams",
                "GetHistoryParams",
                "TLUser",
                "TLChannel",
            ),
        },
    ),
}

TARGET_SPECIFIC_DEPENDENCY_EXCLUDES: Dict[str, Tuple[str, ...]] = {
    "src/services/RealMessageService.ets": (
        "src/core/mtproto/TLDialogs.ets",
    ),
}

ARKTS_NAMED_IMPORT_RE = re.compile(r"import\s*\{(?P<body>[^}]+)\}\s*from", re.MULTILINE)
ARKTS_DEFAULT_IMPORT_RE = re.compile(r"import\s+(?P<name>[A-Za-z_]\w*)\s+from", re.MULTILINE)
IDENTIFIER_RE = re.compile(r"[A-Za-z_]\w*")
PUBLIC_INTERFACE_BLOCK_RE = re.compile(
    r"public\s+interface\s+(?P<name>[A-Za-z_]\w*)(?:<[^>{}]+>)?\s*\{(?P<body>.*?)\}",
    re.DOTALL,
)
INTERFACE_METHOD_RE = re.compile(
    r"^\s*func\s+(?P<name>[A-Za-z_]\w*)\s*\((?P<params>[^)]*)\)\s*:\s*(?P<return>[^;{\n]+)",
    re.MULTILINE,
)


@dataclass(frozen=True)
class PrecompiledDependencySpec:
    source_path: str
    candidate_path: Path

    @property
    def symbol_name(self) -> str:
        return Path(self.source_path).stem


@dataclass(frozen=True)
class ExplicitStagedContractSpec:
    source_path: str
    candidate_path: Path
    provided_symbols: Tuple[str, ...]


def normalize_registry(registry: Mapping[str, str | Path] | None = None) -> Dict[str, Path]:
    result: Dict[str, Path] = {}
    for source_path, candidate_path in (registry or DEFAULT_PRECOMPILED_CANDIDATE_REGISTRY).items():
        resolved = Path(candidate_path)
        if not resolved.is_absolute():
            resolved = (PROJECT_ROOT / resolved).resolve()
        result[str(source_path)] = resolved
    return result


def normalize_explicit_staged_contract_registry(
    registry: Mapping[str, Sequence[Mapping[str, object] | ExplicitStagedContractSpec]] | None = None,
) -> Dict[str, Tuple[ExplicitStagedContractSpec, ...]]:
    result: Dict[str, Tuple[ExplicitStagedContractSpec, ...]] = {}
    raw_registry = registry or DEFAULT_EXPLICIT_STAGED_CONTRACT_REGISTRY
    for target_path, entries in raw_registry.items():
        normalized_entries: List[ExplicitStagedContractSpec] = []
        for entry in entries:
            if isinstance(entry, ExplicitStagedContractSpec):
                candidate_path = entry.candidate_path
                if not candidate_path.is_absolute():
                    candidate_path = (PROJECT_ROOT / candidate_path).resolve()
                normalized_entries.append(
                    ExplicitStagedContractSpec(
                        source_path=entry.source_path,
                        candidate_path=candidate_path,
                        provided_symbols=tuple(entry.provided_symbols),
                    )
                )
                continue
            source_path = str(entry.get("source_path", "")).strip()
            candidate_path = Path(str(entry.get("candidate_path", "")).strip())
            if not candidate_path.is_absolute():
                candidate_path = (PROJECT_ROOT / candidate_path).resolve()
            provided_symbols = tuple(
                str(item).strip()
                for item in entry.get("provided_symbols", [])
                if str(item).strip()
            )
            normalized_entries.append(
                ExplicitStagedContractSpec(
                    source_path=source_path,
                    candidate_path=candidate_path,
                    provided_symbols=provided_symbols,
                )
            )
        result[str(target_path)] = tuple(normalized_entries)
    return result


def derive_normalized_package_name(target_path: str) -> str:
    source = Path(target_path)
    parent_parts = list(source.parent.parts)
    if parent_parts and parent_parts[0] == "src":
        parent_parts = parent_parts[1:]
    if not parent_parts:
        return "root"
    return ".".join(parent_parts)


def filter_dependency_paths_for_target(target_path: str, dependency_paths: Sequence[str] | None = None) -> List[str]:
    excluded = set(TARGET_SPECIFIC_DEPENDENCY_EXCLUDES.get(str(target_path), ()))
    return [
        str(path)
        for path in (dependency_paths or [])
        if str(path) and str(path) not in excluded
    ]


def rewrite_package_declaration(code: str, package_name: str) -> str:
    lines = code.splitlines()
    if lines and lines[0].startswith("package "):
        lines[0] = f"package {package_name}"
    else:
        lines.insert(0, f"package {package_name}")
    return "\n".join(lines) + "\n"


def resolve_precompiled_dependency_specs(
    *,
    target_path: str,
    dependency_paths: Sequence[str] | None = None,
    registry: Mapping[str, Path] | None = None,
    include_same_directory_pool: bool = False,
) -> List[PrecompiledDependencySpec]:
    normalized_registry = dict(registry or normalize_registry())
    normalized_target_path = Path(target_path).as_posix()
    filtered_dependency_paths = filter_dependency_paths_for_target(normalized_target_path, dependency_paths)
    dependency_set = {str(item) for item in filtered_dependency_paths if str(item)}
    source = Path(normalized_target_path)
    same_directory_sources = {
        path
        for path in normalized_registry
        if Path(path).parent == source.parent and path != normalized_target_path
    }
    selected_sources = set()
    if include_same_directory_pool:
        selected_sources.update(same_directory_sources)
    selected_sources.update(path for path in dependency_set if path in normalized_registry and path != normalized_target_path)
    ordered_sources = sorted(selected_sources)
    explicit_specs = resolve_explicit_staged_contract_specs(target_path=normalized_target_path)
    resolved_specs = [
        PrecompiledDependencySpec(source_path=path, candidate_path=normalized_registry[path])
        for path in ordered_sources
        if normalized_registry[path].exists()
    ]
    return [
        *[
            PrecompiledDependencySpec(
                source_path=spec.source_path,
                candidate_path=spec.candidate_path,
            )
            for spec in explicit_specs
        ],
        *resolved_specs,
    ]


def resolve_explicit_staged_contract_specs(
    *,
    target_path: str,
    registry: Mapping[str, Sequence[Mapping[str, object] | ExplicitStagedContractSpec]] | None = None,
) -> List[ExplicitStagedContractSpec]:
    normalized_registry = normalize_explicit_staged_contract_registry(registry)
    return [
        spec
        for spec in normalized_registry.get(str(target_path), ())
        if spec.candidate_path.exists()
    ]


def resolve_explicit_staged_contract_symbols(
    *,
    target_path: str,
    registry: Mapping[str, Sequence[Mapping[str, object] | ExplicitStagedContractSpec]] | None = None,
) -> List[str]:
    seen = set()
    ordered: List[str] = []
    for spec in resolve_explicit_staged_contract_specs(target_path=target_path, registry=registry):
        for symbol in spec.provided_symbols:
            if symbol and symbol not in seen:
                seen.add(symbol)
                ordered.append(symbol)
    return ordered


def _normalize_signature_whitespace(signature: str) -> str:
    return re.sub(r"\s+", " ", signature).strip().rstrip(";")


def extract_primary_public_interface_method_oracle(contract_text: str) -> List[Dict[str, str]]:
    best_methods: List[Dict[str, str]] = []
    for match in PUBLIC_INTERFACE_BLOCK_RE.finditer(contract_text):
        container_name = match.group("name")
        body = match.group("body")
        methods: List[Dict[str, str]] = []
        for method_match in INTERFACE_METHOD_RE.finditer(body):
            signature = (
                f"func {method_match.group('name')}("
                f"{method_match.group('params').strip()}"
                f"): {method_match.group('return').strip()}"
            )
            methods.append(
                {
                    "container_name": container_name,
                    "name": method_match.group("name").strip(),
                    "signature": _normalize_signature_whitespace(signature),
                    "normalized_signature": _normalize_signature_whitespace(
                        signature.removeprefix("func ").strip()
                    ),
                }
            )
        if len(methods) > len(best_methods):
            best_methods = methods
    return best_methods


def resolve_explicit_staged_contract_public_method_oracle(
    *,
    target_path: str,
    registry: Mapping[str, Sequence[Mapping[str, object] | ExplicitStagedContractSpec]] | None = None,
) -> List[Dict[str, str]]:
    ordered: List[Dict[str, str]] = []
    seen = set()
    for spec in resolve_explicit_staged_contract_specs(target_path=target_path, registry=registry):
        try:
            contract_text = spec.candidate_path.read_text(encoding="utf-8")
        except OSError:
            continue
        for item in extract_primary_public_interface_method_oracle(contract_text):
            name = item["name"]
            if name in seen:
                continue
            seen.add(name)
            ordered.append(item)
    return ordered


def resolve_explicit_staged_contract_public_method_oracle_map(
    *,
    target_path: str,
    registry: Mapping[str, Sequence[Mapping[str, object] | ExplicitStagedContractSpec]] | None = None,
) -> Dict[str, str]:
    return {
        item["name"]: item["normalized_signature"]
        for item in resolve_explicit_staged_contract_public_method_oracle(
            target_path=target_path,
            registry=registry,
        )
    }


def target_uses_explicit_staged_contracts(
    target_path: str,
    *,
    registry: Mapping[str, Sequence[Mapping[str, object] | ExplicitStagedContractSpec]] | None = None,
) -> bool:
    return bool(resolve_explicit_staged_contract_specs(target_path=target_path, registry=registry))


def collect_source_import_symbols(source_text: str) -> List[str]:
    if not source_text:
        return []
    ordered: List[str] = []
    seen = set()
    for match in ARKTS_NAMED_IMPORT_RE.finditer(source_text):
        for token in IDENTIFIER_RE.findall(match.group("body")):
            if token not in seen:
                seen.add(token)
                ordered.append(token)
    for match in ARKTS_DEFAULT_IMPORT_RE.finditer(source_text):
        token = match.group("name")
        if token and token not in seen:
            seen.add(token)
            ordered.append(token)
    return ordered


def collect_service_symbol_allowlist(
    tu: Mapping[str, object],
    *,
    registry: Mapping[str, Sequence[Mapping[str, object] | ExplicitStagedContractSpec]] | None = None,
) -> List[str]:
    target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
    target_path = Path(str(target.get("path", "")).strip()).as_posix()
    target_source = str(target.get("source", ""))
    ordered: List[str] = []
    seen = set()
    for token in collect_source_import_symbols(target_source):
        if token and token not in seen:
            seen.add(token)
            ordered.append(token)
    for dependency_path in collect_dependency_paths(tu):
        token = Path(dependency_path).stem
        if token and token not in seen:
            seen.add(token)
            ordered.append(token)
    for token in resolve_explicit_staged_contract_symbols(target_path=target_path, registry=registry):
        if token and token not in seen:
            seen.add(token)
            ordered.append(token)
    return ordered


def format_precompiled_dependency_context(
    target_path: str,
    *,
    dependency_paths: Sequence[str] | None = None,
    registry: Mapping[str, Path] | None = None,
    include_same_directory_pool: bool = False,
) -> str:
    specs = resolve_precompiled_dependency_specs(
        target_path=target_path,
        dependency_paths=dependency_paths,
        registry=registry,
        include_same_directory_pool=include_same_directory_pool,
    )
    if not specs:
        return "当前没有可注入的已验证依赖候选。"
    package_name = derive_normalized_package_name(target_path)
    contract_symbols = resolve_explicit_staged_contract_symbols(target_path=target_path)
    curated_symbols = [
        *contract_symbols,
        *[
            spec.symbol_name
            for spec in specs
            if spec.symbol_name not in contract_symbols
        ],
    ]
    symbols = ", ".join(dict.fromkeys(curated_symbols))
    return (
        f"Verifier 会把以下已验证依赖候选与当前文件一起 staged compile，并统一 package 为 `{package_name}`: {symbols}。\n"
        f"若这些依赖与当前候选处于同一 package，请同包直用，不要写 `import {package_name}.*` 这种自导入。"
    )


def collect_dependency_paths(tu: Mapping[str, object]) -> List[str]:
    dependency_closure = tu.get("dependency_closure", []) if isinstance(tu.get("dependency_closure"), list) else []
    result: List[str] = []
    for item in dependency_closure:
        if not isinstance(item, dict):
            continue
        path = str(item.get("path", "")).strip()
        if path:
            result.append(path)
    return result
