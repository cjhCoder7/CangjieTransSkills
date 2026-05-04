#!/usr/bin/env python3
"""Prompt 组装器。

功能：
1. 为 Translator 构建“资深仓颉/ArkTS 双栈架构师”角色 Prompt；
2. 为 Reviewer 构建“苛刻的架构审查委员会”角色 Prompt；
3. 基于 `SKILL_SCHEMA_V2`、架构 Skill 与 Pattern Memory，对 Prompt 做角色隔离与约束裁剪；
4. 将依赖签名从 Pretty JSON 压缩为更接近 `.d.ts` 的声明式上下文，降低 Token 膨胀。
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple

from llm_adapter import ChatMessage
from precompiled_dependency_registry import (
    collect_service_symbol_allowlist,
    derive_normalized_package_name,
    resolve_explicit_staged_contract_public_method_oracle,
)


ARKTS_BLOCK_COMMENT_RE = re.compile(r"/\*.*?\*/", re.DOTALL)
ARKTS_LINE_COMMENT_RE = re.compile(r"//.*?$", re.MULTILINE)
UI_GESTURE_HINT_RE = re.compile(r"\b(gesture|drag|swipe|pinch|zoom|rotate|touch|pan|scale)\b", re.IGNORECASE)
PHASE06_UI_FUNC_HEAD_RE = re.compile(
    r"(?:^|\n)\s*(?P<modifiers>(?:(?:public|private|protected|internal|open|override|static|mut|sealed|abstract)\s+)*)"
    r"func\s+(?P<name>[A-Za-z_]\w*)(?P<generic_suffix><[^()\n]*>)?\s*\(",
    re.MULTILINE,
)
PHASE06_UI_TYPE_HEAD_RE = re.compile(
    r"^\s*(?P<modifiers>(?:(?:public|private|protected|internal|open|override|static|mut|sealed|abstract)\s+)*)"
    r"(?P<kind>class|struct|interface|enum)\s+(?P<name>[A-Za-z_]\w*)\b",
    re.MULTILINE,
)
PHASE06_UI_UNINITIALIZED_FIELD_HEAD_RE = re.compile(
    r"^\s*(?:(?:public|private|protected|internal)\s+)?"
    r"(?:(?:open|override|static|mut)\s+)*(?:let|var)\s+"
    r"(?P<name>[A-Za-z_]\w*)\s*:\s*(?P<type>[^=\n]+?)\s*$"
)
PHASE06_UI_FIELD_HEAD_RE = re.compile(
    r"^\s*(?:(?:public|private|protected|internal)\s+)?"
    r"(?:(?:open|override|static|mut)\s+)*(?:let|var)\s+"
    r"(?P<name>[A-Za-z_]\w*)\s*:\s*(?P<type>.+?)\s*$"
)
PHASE06_UI_CAST_CALL_PATTERN_RE = re.compile(r"\([^)]+\s+as\s+[A-Za-z_]\w*\)\(\)")
PHASE06_UI_CALL_AFTER_CALL_PATTERN_RE = re.compile(r"[A-Za-z_][\w\.]*\([^()\n]*\)\(\)")
PHASE06_UI_CONSTRUCTOR_MEMBER_CALL_PATTERN_RE = re.compile(
    r"\b[A-Za-z_]\w*\([^()\n]*\)\.(?:`[^`\n]+`|[A-Za-z_]\w*)\([^()\n]*\)"
)
PHASE06_UI_CAP_QUALIFIED_CALL_PATTERN_RE = re.compile(
    r"\b[A-Z][A-Za-z0-9_]*(?:\.[A-Za-z_]\w*)*\.(?:`[^`\n]+`|[A-Za-z_]\w*)\([^()\n]*\)"
)
PHASE06_UI_ROOT_CALL_WITH_CAP_QUALIFIED_ARG_PATTERN_RE = re.compile(
    r"(?<!\.)\b[A-Za-z_]\w*\([^()\n]*\b[A-Z][A-Za-z0-9_]*(?:\.[A-Za-z_]\w*)+[^()\n]*\)"
)
PHASE06_UI_INVOCATION_PATTERN_RES = (
    PHASE06_UI_CAST_CALL_PATTERN_RE,
    PHASE06_UI_CALL_AFTER_CALL_PATTERN_RE,
    PHASE06_UI_CONSTRUCTOR_MEMBER_CALL_PATTERN_RE,
    PHASE06_UI_CAP_QUALIFIED_CALL_PATTERN_RE,
    PHASE06_UI_ROOT_CALL_WITH_CAP_QUALIFIED_ARG_PATTERN_RE,
)
PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PHASE06_UI_MANIFEST_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
DEFAULT_PHASE06_UI_FEW_SHOT_PACK_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_few_shot_pack.json"
PHASE06_UI_TARGET_ROLES = {"page", "component", "viewmodel", "state", "interop"}
PHASE06_UI_DEFAULT_TAG_RULES = {
    "structure_tags": ["page-shell", "rich-component"],
    "ownership_tags": ["view-model-renderer", "controller-owned-state"],
    "optional_interaction_tags": ["gesture-component"],
    "optional_exception_tags": ["ffi-exception", "hybrid-exception"],
    "optional_sample_scope_tags": ["mixed-app-pattern"],
}


@dataclass
class PromptPackage:
    messages: List[ChatMessage]
    metadata: Dict[str, object] = field(default_factory=dict)


class PromptAssembler:
    def __init__(
        self,
        schema_text: str,
        architecture_skill_texts: Optional[Sequence[str]] = None,
        phase06_ui_manifest_path: Optional[str | Path] = None,
        phase06_ui_manifest_payload: Optional[Dict[str, object]] = None,
        phase06_ui_few_shot_pack_path: Optional[str | Path] = None,
        phase06_ui_few_shot_pack_payload: Optional[Dict[str, object]] = None,
    ) -> None:
        self.schema_text = schema_text
        self.architecture_skill_texts = list(architecture_skill_texts or [])
        self.phase06_ui_manifest_path = (
            Path(phase06_ui_manifest_path).resolve()
            if phase06_ui_manifest_path is not None else
            DEFAULT_PHASE06_UI_MANIFEST_PATH
        )
        self._phase06_ui_manifest_payload = (
            phase06_ui_manifest_payload if isinstance(phase06_ui_manifest_payload, dict) else None
        )
        self.phase06_ui_few_shot_pack_path = (
            Path(phase06_ui_few_shot_pack_path).resolve()
            if phase06_ui_few_shot_pack_path is not None else
            DEFAULT_PHASE06_UI_FEW_SHOT_PACK_PATH
        )
        self._phase06_ui_few_shot_pack_payload = (
            phase06_ui_few_shot_pack_payload if isinstance(phase06_ui_few_shot_pack_payload, dict) else None
        )

    def build_translator_prompt(
        self,
        tu: Dict[str, object],
        required_dimensions: Sequence[str],
        attempt: int,
        repair_guidance: Sequence[str],
        pattern_examples: Optional[Sequence[Dict[str, object]]] = None,
        repair_anchor: Optional[Dict[str, object]] = None,
    ) -> PromptPackage:
        schema_excerpt = self._build_schema_excerpt(required_dimensions)
        architecture_excerpt = self._build_architecture_excerpt(limit=4, repair_guidance=repair_guidance)
        tu_context = self._render_translator_tu_context(tu)
        prepared_pattern_examples = self._prepare_pattern_examples(
            pattern_examples or tu.get("similar_patterns", []),
            limit=3,
        )
        few_shot_payload = self._build_pattern_examples(prepared_pattern_examples)
        prepared_ui_few_shot_examples = self._prepare_phase06_ui_few_shot_examples(tu)
        ui_few_shot_payload = self._build_phase06_ui_few_shot_examples(prepared_ui_few_shot_examples)
        anchor_context = self._render_repair_anchor_context(repair_anchor)
        system_prompt = (
            "[CRITICAL OUTPUT DIRECTIVE]\n"
            "- DO NOT overthink type alignments or cryptographic bit-widths in the hidden reasoning phase.\n"
            "- KEEP REASONING BRIEF (Under 500 tokens).\n"
            "- IMMEDIATELY output the Cangjie code blocks. If a type mapping is ambiguous, use the simplest valid Cangjie equivalent (e.g., Array<UInt8>) and proceed. Do NOT attempt to simulate the compiler's memory allocation.\n"
            "你是一名资深仓颉 / ArkTS 双栈架构师。\n"
            "你的唯一职责是：基于 Translation Unit、依赖闭包签名、Schema 约束、修复建议、冻结锚点与历史成功模式，"
            "产出尽可能准确的目标侧翻译候选。\n"
            "你不是审查员，不要替 Reviewer 做结论，不要输出空泛解释。\n"
            "你必须只输出一个 JSON 对象，不要输出 XML、Markdown 围栏或任何 JSON 之外的文本。\n"
            "JSON 字段顺序必须固定为：repair_thought_process(string), code(string), declared_constraints(string[]), notes(string[])。\n"
            "repair_thought_process 是必填字段，且必须放在 code 之前；该字段只写极简前置说明，不要展开成长篇推理。"
            "code 可以是候选代码或翻译骨架，但必须反映对依赖接口签名和边界约束的理解。\n"
            "如果给出了 Frozen Anchor State，它不是灵感样例，而是本轮绝对结构基线；除非 repair guidance 明确要求，否则严禁重写整个类结构。"
        )
        if self._is_mtprotoclient_structural_chunk(tu):
            system_prompt += (
                "\n- If the current chunk is a structural skeleton or trivial setter/getter bridge, skip async/network/auth reasoning and emit only the requested members immediately.\n"
                "- For structural or trivial chunks, do not spend hidden reasoning on Future/spawn/default-parameter expansion unless the target source excerpt explicitly needs it."
            )
        source_alignment_excerpt = self._build_source_alignment_excerpt(tu)
        user_sections = [
            f"[当前轮次]\nattempt={attempt}",
            "[必达约束维度]",
            json.dumps(list(required_dimensions), ensure_ascii=False, indent=2),
            "[Repair Guidance]",
            json.dumps(list(repair_guidance), ensure_ascii=False, indent=2),
            "[Source Alignment 铁律]",
            source_alignment_excerpt,
            "[Dynamic Repair Directives]",
            self._build_dynamic_repair_directives(tu, repair_guidance),
            "[Target-Specific Guardrails]",
            self._build_target_specific_directives(tu),
        ]
        if anchor_context:
            user_sections.extend(["[Frozen Anchor State]", anchor_context])
        user_sections.extend(
            [
                "[SKILL_SCHEMA_V2 摘要]",
                schema_excerpt,
                "[Architecture Skill 摘要]",
                architecture_excerpt or "当前未提供额外 Architecture Skill。",
                "[Pattern Memory Few-Shot]",
                few_shot_payload,
            ]
        )
        if prepared_ui_few_shot_examples:
            user_sections.extend(
                [
                    "[Phase 06 UI Few-Shot]",
                    ui_few_shot_payload,
                ]
            )
        user_sections.extend(
            [
                "[Translation Unit]",
                tu_context,
                "[输出要求]",
                "1. 只输出一个 JSON 对象，不要输出 XML、Markdown 围栏或任何额外文本。",
                "2. JSON 字段顺序固定：repair_thought_process, code, declared_constraints, notes；repair_thought_process 必须放在 code 之前。",
                "3. repair_thought_process 只用 1-3 句极简说明本轮如何守住 source-aligned public contract、异步合同或依赖隔离，不要展开长篇推理。",
                "4. code 字段直接给出候选代码，优先最小编辑并保留已验证骨架。",
                "5. declared_constraints 只列出本轮实际覆盖到的约束维度。",
                "6. notes 只记录关键风险、未决点或锚点引用，保持精简。",
                "7. 如果存在 Frozen Anchor State，你必须基于锚点做最小编辑：优先保留已通过静态墙的 import / 字段 / 方法骨架，严禁重写整个类。",
            ]
        )
        user_prompt = "\n\n".join(user_sections)
        return PromptPackage(
            messages=[
                ChatMessage(role="system", content=system_prompt),
                ChatMessage(role="user", content=user_prompt),
            ],
            metadata={
                "role": "translator",
                "tu_id": tu.get("tu_id", ""),
                "target_path": ((tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}).get("path", ""),
                "attempt": attempt,
                "required_dimensions": list(required_dimensions),
                "repair_guidance": list(repair_guidance),
                "pattern_examples_count": len(prepared_pattern_examples),
                "phase06_ui_examples_count": len(prepared_ui_few_shot_examples),
                "repair_anchor_label": str((repair_anchor or {}).get("label", "")),
                "repair_anchor_source": str((repair_anchor or {}).get("source_path", "")),
            },
        )

    def _build_source_alignment_excerpt(self, tu: Dict[str, object]) -> str:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        target_path = str(target.get("path", ""))
        source_path = self._resolve_source_truth_path(tu)
        signatures = self._get_effective_target_signatures(tu)
        public_symbols = self._collect_source_alignment_public_symbols(tu, signatures=signatures)
        ui_public_method_heads = self._phase06_ui_source_public_method_heads(tu)
        ui_listener_method_heads = self._phase06_ui_source_listener_method_heads(tu)
        ui_member_method_heads = self._phase06_ui_source_member_method_heads(tu)
        ui_publish_field_heads = self._phase06_ui_source_publish_field_heads(tu)
        ui_uninitialized_field_heads = self._phase06_ui_source_uninitialized_field_heads(tu)
        signature_bundle = render_signature_bundle(
            signatures,
            source_path=target_path or "target",
            include_source_comment=False,
        )
        lines = [
            f"源侧真理路径: {source_path}",
            "BCM-ALIGN-001 / Signature Parity: public API 签名必须与 ArkTS 源侧保持 1:1 同名同义，不得擅自加参数、拆接口、发明新的 public 类型或改变参数心智。",
            "BCM-ALIGN-002 / Encapsulated Enhancement: 并发、锁、Epoch、缓存击穿、线程切换等增强只能藏在 private / internal 作用域，绝不能改变调用方看到的 public surface。",
            "翻译铁律: 上述源侧真理路径对应的源文件是绝对真理；你只能做最小代价等价映射，不能借翻译之名重构公共 API。",
            f"本轮 target: {target_path or 'unknown'}；若存在 public 方法/类型，优先保留名称、参数数量、参数语义与返回心智。",
        ]
        if public_symbols:
            lines.append(
                "同文件 public symbols（这些名字若出现在候选中，属于源文件合法 public surface，不得误判为越界发明）: "
                + ", ".join(public_symbols)
            )
        if ui_public_method_heads:
            lines.append(
                "完整 source 还显式声明了这些 public method head（即便 target.signatures / public_surface_symbols 因截断漏掉，也属于合法 public surface）: "
                + "; ".join(ui_public_method_heads[:6])
            )
        if ui_listener_method_heads:
            lines.append(
                "完整 source 还原样声明了这些 listener/callback public method head: "
                + "; ".join(ui_listener_method_heads[:6])
                + "。若这些 source-backed head 的参数类型本来就是 listener interface/object contract，不得把它们改写成裸函数类型。"
            )
        ui_build_head = self._phase06_ui_source_build_head(tu)
        if ui_build_head:
            lines.append(
                "完整 source 还保留了这些 component/builder method head: "
                + ui_build_head
                + "。reviewer 不得仅凭惯用写法想象，强行把它改判成别的 override/visibility 形态。"
            )
        if ui_member_method_heads:
            lines.append(
                "完整 source 还原样声明了这些 target-file class-local member/helper method head: "
                + "; ".join(ui_member_method_heads[:8])
                + "。这些属于源文件已存在的成员方法事实；reviewer 不得仅因它们未出现在 `source_backed_public_method_heads` / `target.signatures` 中，就把候选里的同名方法判成 unauthorized public surface 或 `ARCH_SOURCE_ALIGNMENT_RUPTURE`。"
            )
        if ui_publish_field_heads:
            lines.append(
                "完整 source 还保留了这些 source-backed `@Publish` state field head，例如: "
                + "; ".join(ui_publish_field_heads[:8])
                + "。不得 rename/remove 这些状态字段，也不得用 invented delegate/proxy/attacher 字段替换它们的所有权。"
            )
        ui_invocation_patterns = self._phase06_ui_source_invocation_patterns(tu)
        if ui_invocation_patterns:
            lines.append(
                "完整 source 还原样使用这些调用形态，例如: "
                + "; ".join(ui_invocation_patterns[:6])
                + "，reviewer 不得在没有 verify.compile / real cjc 失败证据时，仅凭语言直觉把它们判成 `ARCH_SYNTAX_REGRESSION` 或 `UNDEFINED_SYMBOL_RUPTURE`，也不得要求为这些 source-backed 调用额外补 invented import。"
            )
        ui_package_local_helper_heads = self._phase06_ui_same_package_helper_heads(tu)
        if ui_package_local_helper_heads:
            lines.append(
                "同包 snapshot root 还确认存在这些 package-local helper head: "
                + "; ".join(ui_package_local_helper_heads[:6])
                + "。reviewer 不得仅因当前单文件候选未内联定义、也未显式 import，就把同包 helper 调用判成 undefined symbol rupture。"
            )
        if ui_uninitialized_field_heads:
            lines.append(
                "完整 source 还保留了 source-backed 未初始化字段声明，例如: "
                + "; ".join(ui_uninitialized_field_heads[:6])
                + "。在没有真实 compile / verifier 红灯前，reviewer 不得仅凭这些字段本身推断 `ARCH_SYNTAX_REGRESSION`。"
            )
        lines.append(
            "等价映射例外: 若源侧 public interface 含属性，而仓颉 interface 不支持存储字段，允许保留 interface kind，并把属性降级为 getter/setter 访问器；承载存储字段的实现类必须是 private/internal，绝不能新增 public surface。"
        )
        lines.append(
            "等价映射例外: 若源侧方法/构造器带默认参数，而当前仓颉链路不接受参数列表内联默认值，则允许使用同名重载做最小等价映射；补出来的重载必须保持原访问修饰符，少参数重载只能做默认值转发，不能改方法名、返回心智或职责。"
        )
        if signature_bundle:
            lines.extend(["源侧 public surface 摘要（d.ts 风格）:", signature_bundle])
        return "\n".join(lines)

    def _collect_target_public_symbols(self, target: Dict[str, object]) -> List[str]:
        signatures = target.get("signatures", []) if isinstance(target.get("signatures", []), list) else []
        return self._collect_public_symbols_from_signatures(signatures)

    def _collect_source_alignment_public_symbols(
        self,
        tu: Dict[str, object],
        *,
        signatures: Optional[Sequence[object]] = None,
    ) -> List[str]:
        effective_signatures = list(signatures) if signatures is not None else self._get_effective_target_signatures(tu)
        collected = self._collect_public_symbols_from_signatures(effective_signatures)
        if not self._is_phase06_ui_target(tu):
            return collected
        collected = []
        seen = set()
        for head in self._phase06_ui_source_public_type_heads(tu):
            match = re.match(r"^public\s+(?:class|struct|interface|enum)\s+([A-Za-z_]\w*)\b", head)
            if not match:
                continue
            name = match.group(1)
            if name in seen:
                continue
            seen.add(name)
            collected.append(name)
        if not collected:
            for name in self._phase06_ui_source_primary_type_names(tu):
                if name in seen:
                    continue
                seen.add(name)
                collected.append(name)
        for head in self._phase06_ui_source_public_method_heads(tu):
            match = re.match(r"^public\s+func\s+([A-Za-z_]\w*)\b", head)
            if not match:
                continue
            name = match.group(1)
            if name in seen:
                continue
            seen.add(name)
            collected.append(name)
        return collected

    def _phase06_ui_source_declared_method_names(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source_text = self._phase06_ui_source_text(tu)
        if not source_text:
            return []
        names: List[str] = []
        seen = set()
        for match in re.finditer(
            r"(?:^|\n)\s*(?:public|protected|private|internal|open|override|sealed|abstract|\s)*\s*func\s+([A-Za-z_]\w*)(?:<[^()\n]*>)?\s*\(",
            source_text,
        ):
            name = match.group(1).strip()
            if not name or name in seen:
                continue
            seen.add(name)
            names.append(name)
        return names

    def _collect_public_symbols_from_signatures(self, signatures: Sequence[object]) -> List[str]:
        collected: List[str] = []
        seen = set()
        for item in signatures:
            if not isinstance(item, dict):
                continue
            name = str(item.get("name", "")).strip()
            if not name or name in seen:
                continue
            seen.add(name)
            collected.append(name)
        return collected

    def _collect_service_collaborator_allow_symbols(self, tu: Dict[str, object]) -> List[str]:
        return collect_service_symbol_allowlist(tu)

    def _collect_service_public_contract_oracle(self, tu: Dict[str, object]) -> List[Dict[str, str]]:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        target_path = str(target.get("path", "")).strip()
        if not target_path:
            return []
        return resolve_explicit_staged_contract_public_method_oracle(target_path=target_path)

    def _get_effective_target_signatures(self, tu: Dict[str, object]) -> List[Dict[str, object]]:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        signatures = target.get("signatures", []) if isinstance(target.get("signatures", []), list) else []
        target_path = str(target.get("path", "")).strip()
        chunk_id = self._get_chunk_translation_id(tu)
        if self._is_phase06_ui_target(tu):
            declared_method_names = set(self._phase06_ui_source_declared_method_names(tu))
            ui_public_method_names = {
                match.group(1)
                for head in self._phase06_ui_source_public_method_heads(tu)
                for match in [re.match(r"^public\s+func\s+([A-Za-z_]\w*)\b", head)]
                if match
            }
            ui_public_type_names = {
                match.group(1)
                for head in self._phase06_ui_source_public_type_heads(tu)
                for match in [re.match(r"^public\s+(?:class|struct|interface|enum|object)\s+([A-Za-z_]\w*)\b", head)]
                if match
            }
            filtered: List[Dict[str, object]] = []
            for item in signatures:
                if not isinstance(item, dict):
                    continue
                kind = str(item.get("kind", "")).strip().lower()
                name = str(item.get("name", "")).strip()
                if kind == "method" and name:
                    if (
                        name not in declared_method_names
                        and name not in ui_public_method_names
                        and name not in ui_public_type_names
                    ):
                        continue
                filtered.append(item)
            return filtered
        if not target_path.endswith("MTProtoClient.ets") or not chunk_id:
            return [item for item in signatures if isinstance(item, dict)]
        allowed_names_by_chunk = {
            "chunk-a": {"RPCCallback", "MTProtoClient"},
            "chunk-a-ctor": {"MTProtoClient", "constructor"},
            "chunk-a-callback": {"MTProtoClient", "setUpdateCallback"},
            "chunk-a-init": {"MTProtoClient", "initialize"},
            "chunk-b": {"MTProtoClient", "createAuthKey"},
            "chunk-c": {
                "RPCCallback",
                "MTProtoClient",
                "sendRequest",
                "initConnection",
                "onConnected",
                "onDisconnected",
                "onData",
                "onError",
                "getMTProtoClient",
            },
        }
        allowed_names = allowed_names_by_chunk.get(chunk_id)
        if not allowed_names:
            return [item for item in signatures if isinstance(item, dict)]
        filtered = [
            item for item in signatures
            if isinstance(item, dict) and str(item.get("name", "")).strip() in allowed_names
        ]
        return filtered

    def _get_chunk_translation_id(self, tu: Dict[str, object]) -> str:
        metadata = tu.get("metadata", {}) if isinstance(tu.get("metadata"), dict) else {}
        chunk_translation = (
            metadata.get("chunk_translation", {})
            if isinstance(metadata.get("chunk_translation"), dict)
            else {}
        )
        return str(chunk_translation.get("chunk_id", "")).strip()

    def _is_mtprotoclient_chunk(self, tu: Dict[str, object], *chunk_ids: str) -> bool:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        target_path = str(target.get("path", ""))
        if not target_path.endswith("MTProtoClient.ets"):
            return False
        if not chunk_ids:
            return True
        return self._get_chunk_translation_id(tu) in set(chunk_ids)

    def _is_mtprotoclient_trivial_callback_chunk(self, tu: Dict[str, object]) -> bool:
        return self._is_mtprotoclient_chunk(tu, "chunk-a-callback")

    def _is_mtprotoclient_structural_chunk(self, tu: Dict[str, object]) -> bool:
        return self._is_mtprotoclient_chunk(tu, "chunk-a", "chunk-a-callback")

    def _is_mtprotoclient_chunk_c(self, tu: Dict[str, object]) -> bool:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        target_path = str(target.get("path", ""))
        return target_path.endswith("MTProtoClient.ets") and self._get_chunk_translation_id(tu) == "chunk-c"

    def _build_target_specific_directives(self, tu: Dict[str, object]) -> str:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        risk_tags = [str(item) for item in target.get("risk_tags", [])] if isinstance(target.get("risk_tags"), list) else []
        public_symbols = self._collect_public_symbols_from_signatures(self._get_effective_target_signatures(tu))
        has_tl_contract_surface = any(re.match(r"^TL[A-Z]\w*$", symbol) for symbol in public_symbols)
        has_async_flow = "[ASYNC_FLOW]" in risk_tags or "async-flow" in risk_tags
        target_path = str(target.get("path", ""))
        chunk_id = self._get_chunk_translation_id(tu)
        is_mtprotoclient_chunk_c = self._is_mtprotoclient_chunk_c(tu)
        ui_directives = self._build_phase06_ui_target_specific_directives(tu)
        if ui_directives:
            return ui_directives
        if role == "service":
            collaborator_allow_symbols = self._collect_service_collaborator_allow_symbols(tu)
            collaborator_allowlist_preview = ", ".join(collaborator_allow_symbols) if collaborator_allow_symbols else "(empty)"
            service_public_contract_oracle = self._collect_service_public_contract_oracle(tu)
            oracle_signature_preview = (
                "; ".join(item["signature"] for item in service_public_contract_oracle)
                if service_public_contract_oracle else "(none)"
            )
            return join_unique_lines(
                [
                    "[CRITICAL ARCHITECTURE DIRECTIVES]",
                    "DOMAIN PURITY VIOLATION AVOIDANCE: You are translating a Service layer file. You MUST NOT directly import or use raw protocol layer details (e.g., TLMethods, TLSerialization, sendRequest, raw byte manipulations).",
                    "PROTOCOL ISOLATION: If the source ArkTS code mixes network IO/TL layer logic with business logic, you MUST push the raw protocol execution behind a private/internal collaborator seam that reuses a real symbol already present in the source imports, TU dependency closure, or explicit staged contract allowlist for this target. Preserve the business logic (state updates, validation) while keeping protocol execution outside the public service surface.",
                    "PUBLIC SURFACE LOCK: You MUST preserve the ArkTS public service surface exactly unless a later repair directive explicitly narrows a single exception. Keep the same public constructor shape, public method names, parameter counts, parameter intent, and return-shape contract. Do NOT rewrite public signatures to invented domain-only substitutes, and do NOT introduce new public helper types to paper over protocol isolation.",
                    "STRICT SIGNATURE PRESERVATION: You are STRICTLY BANNED from altering public method signatures to achieve 'domain purity'. If the ArkTS public method uses a specific contract type, the Cangjie public method MUST keep that exact source-aligned type equivalent. Do NOT invent `User`, `Channel`, or other renamed domain-cleanup types to rewrite the public API.",
                    "NO LOCAL MOCKING: Do NOT invent or declare fake `TL*` classes within the Service layer to satisfy compiler checks.",
                    "SYNCHRONOUS/ASYNCHRONOUS FIDELITY: You MUST preserve the exact synchronous or asynchronous nature of the original ArkTS method contract. If ArkTS returns a plain `Array<Message>` / `Signal<Message[]>` / direct value, keep that public contract shape; do NOT wrap it in `Future` merely because internal work uses `spawn`, channels, or collaborator calls. Only source methods that are actually async / Promise-based may surface as `Future<T>`.",
                    "STRICT CONCURRENCY MANDATE: The use of TypeScript's `async/await` is STRICTLY BANNED. Use Cangjie's concurrency primitives only behind the source-aligned public contract. Internal concurrency is allowed, but it MUST NOT force public return types or public method shapes to drift.",
                    "STD SYNC ONLY: When this file needs `Future`, `spawn`, locks, or other concurrency primitives, import them from `std.sync.*` only. Absolutely DO NOT import `std.concurrent.*`, because the current verified toolchain expects `std.sync.*` and `std.concurrent.*` is a compile-failed regression.",
                    "OPAQUE HANDLE BAN: You MUST NOT invent intermediary 'handle' classes or private helper methods (such as `InputPeerHandle`, `createInputPeer`, or any `*Peer*` wrapper) to sneak protocol-level data types into the Service layer. Completely decouple from the peer/input peer concepts natively found in the MTProto payload layer.",
                    "INPUTPEER ZERO-TOLERANCE: The identifiers `InputPeer` and `createInputPeer` MUST NOT appear anywhere in this file, including `private/internal` helpers, local variables, collaborator method calls, comments, or string literals.",
                    "NO PEER-CONVERSION HELPERS: Do NOT write `private func createInputPeer(...)`, `resolveInputPeer(...)`, `toInputPeer(...)`, or any similar peer-conversion wrapper. If an external collaborator needs protocol peer resolution, call a higher-level `private/internal` collaborator method that accepts `PeerId` directly and hides the conversion entirely outside this file.",
                    "COLLABORATOR SYMBOL ALLOWLIST: Any `private/internal` collaborator type, constructor target, factory, provider, or locator symbol MUST already exist in the source imports, TU dependency closure, or explicit staged contract allowlist for this target. If a symbol is absent from those sources, DO NOT emit it.",
                    f"EXPLICIT STAGED CONTRACT ALLOWLIST FOR THIS TARGET: {collaborator_allowlist_preview}.",
                    "INVENTED COLLABORATOR ZERO-TOLERANCE: Do NOT invent `MessageBackend`, `ServiceLocator`, `*Locator`, or any other private collaborator / locator shell that is absent from the source imports, TU dependency closure, or explicit staged contract allowlist.",
                    "EXPLICIT STAGED CONTRACT PUBLIC ORACLE: If this target has an explicit staged contract bundle, that bundle is the public compile-contract oracle for this round. Its public method names, parameter counts, parameter types, return shapes, and sync/async nature take precedence over looser source excerpts or truncated target.signatures.",
                    f"PUBLIC METHOD ORACLE FOR THIS TARGET: {oracle_signature_preview}.",
                    "PUBLIC CONTRACT FIDELITY AGAINST ORACLE: Public service methods MUST match the explicit staged contract oracle exactly. Do NOT widen/narrow parameter bit-widths (for example `Int32` -> `Int64`), do NOT rewrite `Signal<Array<Message>>` into another public return shape, and do NOT replace externally provided contract tokens with invented public/domain-cleanup types.",
                    "TARGETED ORACLE REGRESSION LOCK: `getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>` is the required public shape for this target. `limit` MUST remain `Int32`, `Signal<Array<Message>>` MUST remain the public return contract, and the service file MUST NOT materialize that contract via `ValueSignal(...)` or any service-local reactive runtime.",
                    "SERVICE PROTOCOL NAME ZERO-TOLERANCE: The protocol request/type names `MessagesGetHistory` and `MessagesSendMessage`, and the singleton/protocol accessor `getMTProtoClient()`, MUST NOT appear anywhere in this service file, including `private/internal` helpers, locals, comments, or string literals.",
                    "PHASE 04 INTERNAL PURITY ONLY: For service-layer translation, Phase 04 domain purity must be achieved through `private/internal` refactoring, not by mutating the source-aligned public API. Do NOT use Phase 04 as an excuse to change public constructor signatures, rename public methods, or replace source-facing params/returns with invented public domain types.",
                    "ZERO-ARGUMENT PUBLIC CONSTRUCTOR & NO DI LEAKAGE: Preserve the exact public constructor signature of the original ArkTS service. If the source exposes a zero-arg public constructor (`constructor()`), you MUST emit a zero-arg `public init()` and keep DI collaborators out of public constructor parameters. Adapters, repositories, ports, helpers, observers, epochs, state-holders, or already-known collaborator references must stay `private/internal`.",
                    "INTERNAL WIRING ONLY: If protocol isolation needs an internal collaborator, initialize it privately through `private/internal` factories, setters, holders, or already-staged same-package dependencies that are real symbols in the current TU context. `public init()` may only do local state initialization and must never become a DI surface.",
                    "OPTION NONE COMPARISON BAN: Do NOT compare `Option` / `?T` values with `== None` or `!= None`. For `TLUser.accessHash` / `TLChannel.accessHash` and similar optional fields, use `match (value)` or `if let`; never rely on direct `None` equality operators.",
                    "CANGJIE MAP UPDATE RULE: For `HashMap<K, V>`, write entries with index assignment (`map[key] = value`) instead of Java-style `.put(key, value)`. `.put(...)` is not a member of the staged `HashMap` implementation used in this pipeline.",
                    *(
                        [
                            "REALMESSAGESERVICE HASH CACHE WRITE LOCK: In `RealMessageService`, keep `cacheUsers(...)` / `cacheChannels(...)` aligned to the existing cache fields and write successful `accessHash` updates with exact index assignment: `this.userAccessHashes[user.id.toString()] = hash` and `this.channelAccessHashes[channel.id.toString()] = hash`. Do NOT emit `.put(...)`, wrapper helpers, or alternate map-write APIs for these two cache updates.",
                            "REALMESSAGESERVICE OPTION+HASHMAP SINGLE-EXPRESSION SHAPE: When handling `TLUser.accessHash` / `TLChannel.accessHash`, prefer a single-expression `match` form such as `case Some(hash) => this.userAccessHashes[user.id.toString()] = hash` and `case None => ()`; do not introduce block-style `case ... => { ... }` just to update these caches.",
                        ]
                        if target_path.endswith("RealMessageService.ets") else []
                    ),
                    "SERVICE FILE BOUNDARY: Do NOT stuff support/domain/runtime declarations back into the same service file. Avoid emitting a second cluster of public `PeerId`, `DomainMessage`, `DomainUser`, `DomainChannel`, `SendMessageParams`, `GetHistoryParams`, `MessageSignal`, `IMTProtoAdapter`, `IMessageService`, observer, or runtime-registration types inside this file.",
                    "NO INLINE PUBLIC DOMAIN TYPES: You MUST NOT define or invent new public domain/support classes inside this service file. Assume required domain models already exist in external dependencies. If a local processing structure is unavoidable, it MUST stay `private/internal` and must not expand the public file surface.",
                    "REUSE OVER REDECLARE: Reuse source-aligned or anchor-defined same-package domain/support types whenever possible. If a helper is unavoidable, keep it `private/internal`, minimal, and scoped to the service implementation; do NOT paper over missing dependencies by declaring many new public support/domain types here.",
                    "SINGLE-PUBLIC-TYPE TEMPLATE: Unless the same source file explicitly declares otherwise, keep this output centered on the service implementation itself. Prefer emitting only `RealMessageService` as the public type from this file, and reference `Message`, `PeerId`, params, domain DTOs, and signal/store abstractions by name instead of redeclaring them here.",
                    "PUBLIC CONTRACT TOKEN SCOPE LOCK: If a source-aligned public signature must mention `TL*`, `Signal`, `ValueSignal`, `Store`, or other externally provided contract names, those tokens may appear ONLY on the matching public method signatures. Do NOT spread them into top-level imports, fields, locals, caches, constructor wiring, or `private/internal` helper signatures.",
                    "NO TL IMPORTS FOR PUBLIC CONTRACT TYPES: Preserve source-aligned `TLUser` / `TLChannel` / `TL*` public method signatures without emitting top-level `import ...TL*` / `protocol.TL*` lines from this service file. Treat these names as externally resolved contract references at the public boundary, not as local protocol imports to rewire.",
                    "SHADOW SIGNAL RUNTIME BAN: Do NOT invent an observer-backed `MessageSignal`, `SignalRuntime`, subscription list, or any container-backed signal runtime (`ArrayList`, `Vector`, observer registries) inside this file. Reuse an anchor-defined/same-package signal-store abstraction if one already exists, or keep only minimal `private/internal` glue.",
                    "NO SHADOW STATE INFRASTRUCTURE: You are strictly BANNED from defining, inventing, or implementing ANY reactive state infrastructure within this file. This includes classes or types named `Signal`, `ValueSignal`, `SignalPipe`, `Store`, `Observable`, or any custom publish/subscribe mechanism.",
                    "EXTERNAL DEPENDENCY ASSUMPTION: If the ArkTS source uses signals or reactive state, assume an external domain/reactive dependency already provides those contract types. Preserve them only where the source-aligned public contract explicitly requires them; do NOT declare new service-local `Signal<T>` / `Store<T>` variables, caches, or helper signatures in this file.",
                    "NO INLINE COLLABORATOR SHELLS: Do NOT define placeholder service-local collaborator interfaces, factories, adapters, or protocol shells within this file. Assume any required collaborator contract already exists externally and keep local references `private/internal`.",
                    "NO REACTIVE DECLARATIONS IN SERVICE FILE: Even with external dependencies available, this file MUST NOT declare fields, locals, maps, helper return types, constructor state, or caches typed as `Signal`, `ValueSignal`, `SignalPipe`, `Store`, or `Observable`. Do NOT write `let state: Signal<T>` or `var store: Store<T>` anywhere in this file.",
                    "REACTIVE CONTRACT EXTERNALIZATION: If the source exposes reactive state, preserve that source-aligned public contract while externalizing ownership. Assume a separately provided facade or collaborator owns the reactive object, and let the service implementation forward or resolve it without mutating the public signature. The service implementation file itself must not own, cache, construct, or publish new reactive state objects.",
                    "PUBLIC REACTIVE CONTRACT RETURN ONLY: If a source-aligned public method returns `Signal` / `ValueSignal` / `Observable`, only that matching public method may mention the reactive contract. `private/internal` helpers must return non-reactive shapes (`Unit`, cached arrays, booleans, ids, etc.), perform setup/fetch side effects, and let the public method itself obtain or forward the externally owned reactive object.",
                    "REACTIVE CONTRACT POSITION LOCK: `Signal`, `ValueSignal`, and `SignalPipe` may appear ONLY on source-/oracle-aligned public method signatures. Do NOT write `Signal<T>()`, `ValueSignal<T>(...)`, `SignalPipe<T>(...)`, `let x: Signal<T> = ...`, `private let cache: Signal<T>`, `private func buildSignal(...): Signal<T>`, or `return Signal<T>()` anywhere in this file.",
                    "LEGAL REACTIVE FORWARDING PATH: For this target, `getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>` MUST stay exact, but the returned `Signal` must be obtained or forwarded from a real externally provided symbol already present in the source imports, TU dependency closure, or explicit staged contract allowlist. If the current context does not expose a real reactive provider/facade symbol, do NOT invent one; do NOT emit a new provider/facade/shell/locator just to satisfy the return contract.",
                    *(
                        [
                            "TARGETED REACTIVE COLLABORATOR ANCHOR: This target's explicit staged contract allowlist includes `MessageTimeline`. Prefer a `private/internal` field such as `private let timeline: MessageTimeline = MessageTimeline()`. Implement `getMessages(peerId, limit)` as a direct forward to `this.timeline.getMessages(peerId, limit)`. For the public async methods, prefer direct `Future` forwarding to `this.timeline.fetchMessages(params)` / `this.timeline.sendMessage(params)` when the staged contract already exposes those exact `Future` returns; only fall back to `replaceMessages(...)` / `appendMessage(...)` inside a `private/internal` helper when you truly need extra side effects."
                        ]
                        if "MessageTimeline" in collaborator_allow_symbols else []
                    ),
                    "COMPILE-CLOSURE RETURN RULE: Signature fidelity alone is insufficient. Every non-`Unit` method body must end with a concrete expression of the exact oracle-aligned return type; comment-only bodies, empty bodies, or `spawn` blocks that end in comments are compile-failed regressions. `Future<Array<Message>>` methods must end with a real `Future<Array<Message>>` expression (for example direct collaborator forwarding, or `spawn { ... }` whose body ends with `Array<Message>`); `Future<Message>` methods must end with a real `Future<Message>` expression; `Signal<Array<Message>>` bodies must forward a real external signal object.",
                    "NO TODO / REACTIVE PLACEHOLDER ESCAPES: Do NOT use `throw TODO`, `TODO()`, placeholder `Signal<T>()`, `ValueSignal<T>(...)`, `SignalPipe<T>(...)`, or invented reactive provider/facade/shell runtime as an escape hatch. If no legal external reactive provider is visible, keep the public signature exact, remove the service-local materialization, and let the next compile/repair round expose the missing external contract instead of fabricating a local runtime here.",
                    "NO INLINE COLLABORATOR IMPLEMENTATIONS: Do NOT declare placeholder collaborator implementations, internal protocol executors, or factory wrappers inside this file. Concrete collaborator implementations must live outside the service file.",
                    "STRICT IDENTIFIER BAN: Absolutely NO `Gateway` or `Bridge` identifiers in class names, type names, variables, helpers, setter names, comments, or string literals anywhere in this file.",
                    "PRIVATE COLLABORATOR CONTAINMENT: Internal mechanisms such as `MessagePort`, channels, adapters, or helper collaborators are allowed ONLY when they are strictly `private/internal`. They MUST NOT dictate, pollute, or alter public method names, public parameter types, public return types, or constructor shape.",
                    "NEUTRAL COLLABORATOR RULE: Neutral field names such as `backend`, `messagePort`, or `transportPort` are acceptable only as variable names. They do NOT authorize inventing `MessageBackend`, `ServiceLocator`, `BackendLocator`, or any new collaborator type / locator shell. The referenced collaborator symbol itself must already exist in the source imports, TU dependency closure, or explicit staged contract allowlist, and collaborator naming must never leak into public signatures.",
                    "ZERO-BLOCK / FUTURE COMPILE SHAPE: For Service-layer async methods, prefer the physically validated form `spawn { ... }`; do NOT hand-roll JS-style resolver constructors such as `Future<T>({ resolver => ... })` when the body contains multiple statements, side effects, or `match` branches.",
                    "MATCH / LAMBDA SINGLE-EXPRESSION RULE: `match` arms, array-builder lambdas, and `Future`-related closures must not use block-style `case ... => { ... }` for side effects. Extract cache updates / signal publication / state writes into `private/internal` helpers so each arm or lambda stays a single expression; for Unit branches prefer a single-expression `()` or restructure control flow outside the `match`.",
                    "ZERO-BLOCK STATIC FIREWALL: `case None => {}` and block-style `case Some(...) => { ... }` are deterministic blockers for this target. Empty branches must be `case None => ()`, and non-empty branches must collapse to a single helper call or a single returned expression.",
                    "PRIORITY: Architectural purity and protocol isolation take absolute precedence over strict line-by-line source alignment.",
                ]
            )
        if role != "module":
            return "当前无额外 target-specific 指令。"
        if target_path.endswith("MTProtoClient.ets") and chunk_id == "chunk-a":
            return join_unique_lines(
                [
                    "当前 chunk 只输出 imports、helper/type 声明、类头和字段骨架，不涉及 constructor / setUpdateCallback / initialize / 认证握手 / 网络 I/O / 单例尾巴。",
                    "字段与类型名只做最小等价映射即可：保留 `TransportCallback`、`TransportManager`、`SessionInfo`、`RPCCallback`、`pendingRPCs`、`updateCallback`、`connectionInitialized` 等骨架名字，不要提前补方法逻辑。",
                    "不要在这个结构骨架 chunk 里发明 `Future`、`spawn`、`.get()`、默认参数重载、callback contract 履约逻辑或额外 helper；这些全部留给后续 chunk。",
                    "不要为了补齐上下文去展开不相关依赖；只保留当前字段骨架真正需要的最小类型引用。",
                    "当前文件与 staged 依赖属于同包场景；同包符号优先直接引用，不要输出任何 `from './Foo' import ...`、`import ... from './Foo'` 或其它前端/脚本语言导入语法。",
                    "若确实需要 import，只允许保留已验证的标准库导入，例如 `import std.sync.*`、`import std.collection.*`；不要为同包 `MTProtoConfig` / `CryptoUtils` / `TL*` 依赖生成顶层导入行。",
                ]
            )
        if target_path.endswith("MTProtoClient.ets") and chunk_id == "chunk-a-callback":
            return join_unique_lines(
                [
                    "当前 chunk 是同步 callback setter，不涉及 initialize / createAuthKey / sendRequest / 网络 I/O / 单例尾巴。",
                    "只需保持 source-aligned 签名：`setUpdateCallback(callback: (update: Uint8Array) => void): void` -> 仓颉等价 `(Array<UInt8>) -> Unit`。",
                    "方法体直接完成 `this.updateCallback = callback` 即可；不要发明 `Future`、`spawn`、`.get()`、默认参数重载、加密位宽推演或额外 helper。",
                    "不要新增 imports、依赖 stub、顶层声明或其他 public members；输出必须只是可插入 `MTProtoClient` 类体的成员片段。",
                ]
            )
        shared_lines: List[str] = []
        if has_async_flow:
            normalized_package = derive_normalized_package_name(target_path)
            shared_lines.extend(
                [
                    "这是 `[ASYNC_FLOW]` 模块。源侧 ArkTS `Promise<T>` 返回在仓颉中必须映射为 `Future<T>`；`initialize` / `sendRequest` / `createAuthKey` / `initConnection` 必须继续保留异步时序心智，绝不允许把返回值塌成 `Unit` 或写同步假注释。",
                    "按当前 Cangjie SDK 6.1.0.818 物理编译链，候选里全局绝对禁止输出字面量 `async` 或 `await` 关键字。",
                    "文件顶部必须显式 `import std.sync.*`；`Promise<void>` 必须映射为 `Future<Unit>`，`Promise<Uint8Array>` / `Promise<Array<UInt8>>` 必须映射为 `Future<Array<UInt8>>`。",
                    "绝对不要导入 `std.concurrent.*`。当前物理编译链对 `Future` / `spawn` 的已验证入口是 `std.sync.*`；任何 `import std.concurrent.*` 都应视为 compile regression。",
                    "函数签名禁止保留字面量 `async`；应改为常规 `func ...: Future<T>`。函数体内禁止 `await`；异步执行块使用 `spawn { ... }`，等待已有 `Future` 结果时使用 `.get()`；若 `spawn` 产出 `Future<Unit>`，末尾必须显式写 `()`。",
                    "对当前尚未翻成真实绿灯的 `TransportCallback` / `TransportManager` / `AuthKeyCreator` / `decompress`，只允许使用 `internal/private` 的极简 stub 或 adapter seam 占位；严禁新增任何 source 中不存在的 public class、public constructor 或 public function。",
                    "必须保住 `MTProtoClient` 的 callback contract：`onConnected` / `onDisconnected` / `onData` / `onError` 这些方法不能凭空消失。若仓颉不接受 `implements` 关键字，请改用合法语法或直接在类体中保留对应 public 方法，而不是删契约。",
                    "若源侧方法带默认参数，当前仓颉实现必须用同名重载展开，禁止继续输出 `param: T = value`。少参数重载只负责把默认值转发给完整签名，且所有重载必须继承源侧访问修饰符。",
                    "禁止在 `Option<T>` / 可空类型上使用后缀 `!` 强制解包；请改用 `match` 或 `if let` 做安全解包。",
                ]
            )
            if target_path.endswith("MTProtoClient.ets") and not chunk_id:
                shared_lines.extend(
                    [
                        "对 `MTProtoClient` 本轮必须死守三条 source-aligned public contract：`initialize(forceNewAuthKey = false)` 的默认参数必须展开为同访问级别重载，例如 `public func initialize(): ... { initialize(false) }` + `public func initialize(forceNewAuthKey: Bool): ...`；`sendRequest(data)` 仍是源侧合法 public 方法；`getMTProtoClient()` 必须保留 singleton 心智，不能退化为每次都 new。",
                        "`initialize` / `createAuthKey` / `initConnection` 这类源侧 `Promise<void>` 方法，目标侧必须落成 `Future<Unit>`；`sendRequest(data)` 这类源侧 `Promise<Uint8Array>` 方法，目标侧必须落成 `Future<Array<UInt8>>`。",
                        "当前 verifier 会把 `MTProtoConfig`、`CryptoUtils`、`TLMethods`、`TLSerialization`、`TLDialogs` 与当前文件 staged compile，并统一 package 为 `"
                        + normalized_package
                        + "`；对这些依赖只能同包直用，不要写 `import "
                        + normalized_package
                        + ".*`，也不要在当前文件再次声明同名 `class` / `interface` / `func`。",
                        "若 `MTProtoConfig` / `SessionInfo` / `SessionManager` / `TLDeserializer` / `TLSerializer` / `InitConnection` / `InvokeWithLayer` / `HelpGetConfig` 已由 staged compile 提供，只能直接引用现成依赖。",
                        "`getMTProtoClient()` 禁止使用 `clientSingleton!` 或任何后缀 `!` 强制解包。若单例状态是 `Option` / 可空类型，必须用 `match` 或 `if let` 做安全解包，并在入口处完成惰性初始化。",
                        "若需要惰性初始化单例，请把状态收进 `internal/private` holder，并使用显式判空 + 初始化分支，例如先 `match (clientSingleton)` 取现有实例，`case None` 下创建实例并写回，再返回安全解包后的值。",
                    ]
                )
                return join_unique_lines(shared_lines)
            if target_path.endswith("MTProtoClient.ets") and chunk_id == "chunk-a-ctor":
                shared_lines.extend(
                    [
                        "当前 chunk 只处理 constructor 本体；不要重新声明字段、setUpdateCallback、initialize、createAuthKey、sendRequest、callback methods 或单例尾巴。",
                        "ArkTS 条件表达式 `cond ? a : b` 不是仓颉合法语法。若 constructor 里要根据 `MTProtoConfig.USE_TEST_DC` 选择 DC id，必须先写合法局部值，例如 `let dcId = if (MTProtoConfig.USE_TEST_DC) { 2 } else { 1 }`，再调用 `SessionManager.getSession(dcId)`；绝对不要保留 `? :`。",
                    ]
                )
                return join_unique_lines(shared_lines)
            if target_path.endswith("MTProtoClient.ets") and chunk_id in {"chunk-a", "chunk-a-callback"}:
                shared_lines.extend(
                    [
                        "当前 chunk 只允许输出状态骨架或生命周期 setup。禁止提前生成 `clientSingleton` 或 `getMTProtoClient()`；尾部单例 contract 只允许在 Chunk C 处理。",
                    ]
                )
                return join_unique_lines(shared_lines)
            if target_path.endswith("MTProtoClient.ets") and chunk_id == "chunk-a-init":
                shared_lines.extend(
                    [
                        "当前 chunk 只处理 `initialize`。默认参数必须展开为同名重载，且返回心智必须保持 `Future<Unit>`；不要提前生成 `sendRequest(data)` 或 `getMTProtoClient()`。",
                    ]
                )
                return join_unique_lines(shared_lines)
            if target_path.endswith("MTProtoClient.ets") and chunk_id == "chunk-b":
                shared_lines.extend(
                    [
                        "当前 chunk 只处理认证握手。`createAuthKey` 必须保持 `Future<Unit>` 心智；不要提前生成 `sendRequest(data)`、`clientSingleton` 或 `getMTProtoClient()`。",
                        "Chunk B 只允许输出单个成员片段 `private func createAuthKey(): Future<Unit>`；不要输出 imports、类头、字段、顶层 helper、注释块或额外方法。",
                        "禁止在 Chunk B 生成任何依赖 stub / seam / placeholder。不要输出 `AuthKeyCreator`、`AuthKeyResult`、`AuthKeyState`、`SessionManager`、`TCPTransport`、`TransportManager` 的 `class` / `interface` / `enum` / `func` 声明。",
                        "若依赖类型尚未 staged compile，就直接引用现有名字并让 verifier / cjc 给出真实物理诊断；不要为了自救而扩写依赖骨架。",
                        "对 `req_pq_multi`、`req_DH_params`、`set_client_DH_params` 这些 source missing members，只记录为缺失事实；绝对不要为了补清单去发明空方法或握手 stub。",
                    ]
                )
                return join_unique_lines(shared_lines)
            if target_path.endswith("MTProtoClient.ets") and is_mtprotoclient_chunk_c:
                shared_lines.extend(
                    [
                        "当前 chunk 负责网络 I/O 与单例尾巴收口：`sendRequest(data)` 仍是源侧合法 public 方法；`getMTProtoClient()` 必须保留 singleton 心智，不能退化为每次都 new。",
                        "`sendRequest(data)` 这类源侧 `Promise<Uint8Array>` 方法，目标侧必须落成 `Future<Array<UInt8>>`。",
                        "`getMTProtoClient()` 禁止使用 `clientSingleton!` 或任何后缀 `!` 强制解包。若单例状态是 `Option` / 可空类型，必须用 `match` 或 `if let` 做安全解包，并在入口处完成惰性初始化。",
                        "若需要惰性初始化单例，请把状态收进 `internal/private` holder，并使用显式判空 + 初始化分支，例如先 `match (clientSingleton)` 取现有实例，`case None` 下创建实例并写回，再返回安全解包后的值。",
                        "同包 staged 依赖直接引用即可；不要输出任何 `from './Foo' import ...`、`import ... from './Foo'` 或其它脚本语言导入语法。",
                        "Chunk C 只允许输出 `sendRequest`、`initConnection`、`onConnected`、`onDisconnected`、`onData`、`onError`、`getMTProtoClient()` 以及必要的 `private/internal` helper。前序 stub 已经提供字段骨架；禁止重新声明 `transportManager`、`session`、`pendingRPCs`、`updateCallback`、`connectionInitialized`，也不要重复输出 constructor / `initialize` / `createAuthKey`。",
                        "Source truth 中 callback 合同只有 `onConnected()`、`onDisconnected()`、`onData(...)`、`onError(...)`。不要为了补清单或迎合旧 directive 发明 `onClose()` 或其他源侧不存在的 public callback 方法。",
                        "`sendRequest(data)` 不能注册 no-op `RPCCallback` 后立刻返回 `[]`。必须保留真实 RPC 响应合同：把真实 resolve/reject 路径挂到 pending RPC，并让返回的 `Future<Array<UInt8>>` 等待响应完成；若需要多步桥接，请提取 `private/internal` helper，但不要伪造成功结果。",
                        "若 callback -> `Future<Array<UInt8>>` 的桥接细节不确定，不要猜 `Channel`、`BlockingQueue`、`Condition`、自造 `Promise` API 或其它未在依赖闭包里出现的同步原语。优先使用最小 `private/internal` waiter/helper（例如保存 `result/error` 的小状态对象），让回调只写 waiter，`spawn` 内显式等待 waiter 变为已完成状态；这种 compile-safe 近似优先于长时间推理。",
                        "`await` 在这个 chunk 里不仅是关键字禁词，也不能出现在任何 helper / method / field / local / callsite 标识符中。禁止生成 `public func await()`、`awaitResult()`、`waiter.await()`、`helper.await` 这类命名；若需要 waiter API，请改用不含 `await` 的名字，例如 `takeResult()`、`drainResult()`、`pollReady()`。",
                        "`match` 分支必须保持单表达式。禁止输出 `case None => {}`、`case None => { let ... }`、`case Some(...) => { ... }` 这类 block-style 分支；若需要多步逻辑，先提取到 `private/internal` helper，再让分支只返回 helper 调用。",
                        "空分支唯一合法写法是 `case None => ()`。若 `onData` / callback / singleton 初始化分支确实需要多步逻辑，必须先提取成 `private/internal` helper，再写成 `case Some(x) => helper(x)` 或 `case None => buildSingleton()` 这类单表达式返回；禁止 `case None => {}`，也禁止在 `case None =>` 后直接跟裸多行语句。",
                    ]
                )
        if has_tl_contract_surface and "[BINARY_PROTO]" not in risk_tags:
            lines = shared_lines + [
                "这是定义 TL 协议契约的 module，不是 Service。源侧 public symbols 中出现的 `TLUser` / `TLChannel` 等 TL* 名字属于合法同文件 public surface，绝不能为了迎合 Service 静态墙而改名成 `DomainUser` / `DomainChannel` 或直接删除。",
                "若源侧签名是 `interface`，目标侧必须继续保持 public interface kind；若仓颉 interface 不支持存储字段，可使用 getter/setter accessor-based interface，并让承载字段的实现类保持 `internal/private`。",
                "允许存在 `internal/private` 的实现类作为存储载体，但不得新增 source 中不存在的 public constructor、public class 或其它 public symbol。",
            ]
            if public_symbols:
                lines.append("本文件必须保留的同文件 public symbols: " + ", ".join(public_symbols))
            return join_unique_lines(lines)
        if "[BINARY_PROTO]" not in risk_tags:
            return join_unique_lines(shared_lines) if shared_lines else "当前无额外 target-specific 指令。"
        lines = shared_lines + [
            "这是 `module + [BINARY_PROTO]` 协议模块，不是 Service。凡是 Source Alignment / target.signatures 中已出现的 `TL*`、`InputPeer*`、`toBytes()`、`Array<UInt8>` 相关 public surface，都属于合法源侧真理，不得为了迎合 Service 规则而删除、降级或改名。",
            "若源侧存在继承层次（例如 `InputPeerEmpty` / `InputPeerUser` / `InputPeerChat` / `InputPeerChannel` 继承 `InputPeer`），必须保留这条层次关系；仓颉里只能使用 `<:`，绝不允许回潮成 `extends`，也绝不允许把子类拍平为互不相关的独立 class。",
            "严禁引入 `import std.unsafe.*`。当前 TU 只是协议数据结构与字节容器，不需要 unsafe，也不允许靠 unsafe 绕过类型或初始化问题。",
            "ArkTS `Uint8Array` 映射为 `Array<UInt8>`；ArkTS `bigint` 映射为 `Int64`；零值请写 `0` 或 `Int64(0)`，绝不允许 `0L` / `0U` / `0UL`。",
            "在这个协议模块里，ArkTS `number` 若承载 `writeInt32/readInt32` 这类固定宽度整数语义，可映射为 `Int32`；ArkTS `bigint` 映射为 `Int64`。不要把这类固定宽度数值误翻成浮点或随意放大位宽。",
            "ArkTS `readonly` 不能原样带进仓颉。常量字段请改成仓颉合法的 `let` / `static let`，不要写 `readonly`。",
            "内部字节容器优先保持 `Array<UInt8>` / `[]` 的最小形态。禁止发明 `Vector`、`ArrayList`、`toArray()` 或其它未经真实编译证明可用的集合类型 / API。",
            "如果需要向 `Array<UInt8>` 末尾追加字节，不要写 `.append()` / `.push()`；请使用内部 helper 通过 `Array<UInt8>(old.size + 1, { index: Int64 => ... })` 重建新数组，避免继续调用不存在的成员方法。",
            "数组索引与 `size` 相关运算统一按 `Int64` 处理；不要把 `Int32` 直接拿去索引 `Array<T>`。",
            "不要用 `as` 做数值转换；在这里 `as Int32` / `as UInt8` 往往会产出 `Option<T>` 并直接炸掉位运算。数值转换优先使用 `Int32(x)` / `Int64(x)` / `UInt8(x)` 这类构造器。",
            "禁止发明 `StringToUtf8`、`Utf8ToString`、`.toInt32()`、`.toInt64()` 这类来源不明的 helper / 方法名；若 UTF-8 转换 API 没有经过真实编译证明，就保留更保守的最小占位实现，也不要编造标准库名字。",
            "若 `writeString` / `readString` 缺少可编译的 UTF-8 helper，允许使用最小占位实现保住 public surface，例如 `let _ = value` / `return \"\"`；不要为了追求语义完整去发明新的字符串 API。",
            "若十六进制字面量超出 `Int32` 范围，必须改写成等价的有符号 `Int32` 常量；不要为了偷懒把 source-aligned 的 public 常量类型擅自改成 `Int64`。",
            "位模式必须精确等价，不能随便猜负数。例：`0xf35c6d01` 作为 32-bit 有符号常量的等价值是 `-212046591`，计算方式是 `0xf35c6d01 - 0x100000000`。",
            "若编译器提示缺少协议类型或初始化构造，请补最小、source-aligned 的同文件定义或构造器，不要删除现有 public surface，不要把 `InputPeer` 树改写成无继承的平面数据类。",
        ]
        if public_symbols:
            lines.append("本文件必须保留的同文件 public symbols: " + ", ".join(public_symbols))
        return join_unique_lines(lines)

    def _render_repair_anchor_context(self, repair_anchor: Optional[Dict[str, object]]) -> str:
        if not isinstance(repair_anchor, dict):
            return ""
        code = str(repair_anchor.get("code", "")).strip()
        if not code:
            return ""
        label = str(repair_anchor.get("label", "") or "anchor")
        source_path = str(repair_anchor.get("source_path", "") or "")
        clipped_code = self._clip_repair_anchor_code(code, limit=6000)
        lines = [
            f"label={label}",
            f"source_path={source_path or 'n/a'}",
            "规则: 以下代码是你之前写出的高分候选，是本轮唯一允许的结构基线。",
            "规则: 你必须在它基础上做最小编辑，严禁重写整个类、重新发明 import / 字段 / 方法骨架。",
            "规则: 优先保留已通过静态墙的结构，只局部修复当前 repair guidance 指向的问题。",
            "规则: 若缺少 TL* / InputPeer 类型，禁止在 Service 层自造 class / struct / interface / extends；改为 Domain Model、预设映射类型，或把 opaque handle / OpaquePointer 式方案下沉到底层。",
            "规则: 若锚点已经过静态墙，任何重新引入 `std.unsafe.*` 的行为都视为破坏性降级。",
            "[Anchor Code]",
            clipped_code,
        ]
        return "\n".join(lines)

    def _clip_repair_anchor_code(self, code: str, limit: int) -> str:
        compact = code.strip()
        if len(compact) <= limit:
            return compact
        return compact[: limit - 3] + "..."

    def build_reviewer_prompt(
        self,
        tu: Dict[str, object],
        artifact_payload: Dict[str, object],
        required_dimensions: Sequence[str],
    ) -> PromptPackage:
        schema_excerpt = self._build_schema_excerpt(required_dimensions)
        architecture_excerpt = self._build_architecture_excerpt(limit=4)
        source_alignment_excerpt = self._build_source_alignment_excerpt(tu)
        system_prompt = (
            "[CRITICAL OUTPUT DIRECTIVE]\n"
            "- KEEP REASONING BRIEF (Under 500 tokens).\n"
            "- IMMEDIATELY output the JSON review object.\n"
            "你是一个极其苛刻的架构审查委员会。\n"
            "你的职责不是翻译代码，而是基于 SKILL_SCHEMA_V2 与架构 Skill 约束，对候选翻译做结构化审查。\n"
            "你必须输出 JSON 对象，且仅输出 JSON，不要带 Markdown 围栏。\n"
            "JSON 必须包含：pass(boolean), issues(array)。\n"
            "issues 中每项必须包含：code, severity, message, required_dimension, evidence。\n"
            "只要缺少关键约束、状态边界、线程边界、依赖契约或互操作约束，就必须判定为不通过。\n"
            "如果候选里的 public 类型或方法已经出现在 target.signatures / Source Alignment 摘要中，就不得把它误判成越界发明；只有新增了源侧不存在的 public surface，才能按 source alignment rupture 处理。\n"
            "若 source_excerpt 已明确出现某个 export class 的 public method，但 target.signatures / public_surface_symbols 因截断未列出该方法，也不得仅凭列表缺失就判定 unauthorized public surface。\n"
            "若 Translation Unit.target.source_excerpt_is_truncated=true，或 target.source_backed_public_method_heads / target.source_backed_listener_method_heads / target.source_backed_member_method_heads / target.source_backed_publish_field_heads / target.source_backed_uninitialized_field_heads / target.source_backed_build_head / target.source_backed_invocation_patterns / target.source_backed_package_local_helper_heads 已给出更完整的源侧或同包事实，你必须优先信这些 source-backed 事实；不得仅因 excerpt 未展示完整方法/字段，或仅凭语言直觉，就臆造 unauthorized public surface、syntax blocker 或 undefined symbol rupture。\n"
            "若源侧方法带默认参数，而候选用同名重载集合表达默认值语义（例如零参重载转发到完整签名），只要访问修饰符、方法名、返回心智与默认值语义保持一致，就应视为允许的最小等价映射，不得误判为 unauthorized public surface 或 signature rupture。\n"
            "若源侧 public interface 带属性，而仓颉 interface 不支持存储字段，则允许使用 getter/setter accessor-based interface 作为最小等价映射；private/internal 实现类不应被判定为 public contract rupture。\n"
            "你对以下情况实行零容忍：1) 代码中出现 `0L`、`0U`、`0UL`、`import ... from`、`std.unsafe.*`、`!`、`!!` 等语法倒退时，必须返回 `ARCH_SYNTAX_REGRESSION`；2) `repair_thought_process` 里声称会做 Adapter / ACL / Domain 隔离，但代码仍出现 `ProtocolContext`、`TL*`、`InputPeer`、`createInputPeer`、`Buffer` 等协议泄漏时，必须按 `ARCH_DOMAIN_PURITY_VIOLATION` 或 `ARCH_PROTOCOL_ISOLATION` 打回，并明确指出“思路与代码不一致”。"
        )
        user_prompt = "\n\n".join(
            [
                "[审查必达维度]",
                json.dumps(list(required_dimensions), ensure_ascii=False, indent=2),
                "[Source Alignment 铁律]",
                source_alignment_excerpt,
                "[Target-Specific Reviewer Guardrails]",
                self._build_target_specific_reviewer_directives(tu),
                "[SKILL_SCHEMA_V2 摘要]",
                schema_excerpt,
                "[Architecture Skill 摘要]",
                architecture_excerpt or "当前未提供额外 Architecture Skill。",
                "[Translation Unit 摘要]",
                json.dumps(self._build_reviewer_tu_payload(tu), ensure_ascii=False, indent=2),
                "[Translator 输出]",
                json.dumps(self._build_reviewer_artifact_payload(artifact_payload), ensure_ascii=False, indent=2),
                "[输出要求]",
                "1. 仅输出 JSON。",
                "2. pass=true 时 issues 可以为空数组。",
                "3. pass=false 时 issues 至少给出一条 blocker 或 major。",
                "4. evidence 必须引用 declared_constraints、target 风险标签或依赖上下文中的具体事实。",
                "5. 一旦扫到 `0L`、`0U`、`0UL`、ArkTS `import ... from`、`std.unsafe.*`、`!`、`!!`，必须直接判定 `ARCH_SYNTAX_REGRESSION`。",
                "6. 一旦 repair_thought_process 声称会隔离协议，但代码仍出现 `ProtocolContext`、`TL*`、`InputPeer`、`createInputPeer`、`Buffer`，必须直接按 `ARCH_DOMAIN_PURITY_VIOLATION` 或 `ARCH_PROTOCOL_ISOLATION` 打回。",
                "7. 只要候选 public surface 与 Source Alignment 摘要中的同文件 public symbols / target.signatures 一致，就不得误报 `ARCH_SOURCE_ALIGNMENT_VIOLATION` 或 `ARCH_CONTRACT_RUPTURE`。",
                "8. 若源侧是带属性的 public interface，而仓颉 interface 不支持存储字段，则允许使用 getter/setter accessor-based interface 作为最小等价映射；private/internal 实现类不计入 public surface rupture。",
                "9. 若 source_excerpt 已明确出现某个 export class 的 public method，但 target.signatures / public_surface_symbols 因截断未列出该方法，不能仅凭列表缺失就判定 unauthorized public surface。",
                "10. 若源侧默认参数被目标侧展开为同名重载集合，只要访问修饰符、方法名、返回心智与默认值语义一致，就应视为允许的等价映射；不要把该零参/少参转发重载误判为 public surface rupture。",
                "11. 若 `Translation Unit.target.source_excerpt_is_truncated=true`，或 `source_backed_public_method_heads` / `source_backed_listener_method_heads` / `source_backed_member_method_heads` / `source_backed_publish_field_heads` / `source_backed_uninitialized_field_heads` / `source_backed_build_head` / `source_backed_invocation_patterns` / `source_backed_package_local_helper_heads` 已提供更完整 source-backed 事实，不得仅凭 excerpt 缺口、单文件视角或语言想象臆造 blocker。",
            ]
        )
        return PromptPackage(
            messages=[
                ChatMessage(role="system", content=system_prompt),
                ChatMessage(role="user", content=user_prompt),
            ],
            metadata={
                "role": "reviewer",
                "tu_id": tu.get("tu_id", ""),
                "required_dimensions": list(required_dimensions),
                "declared_constraints": list(artifact_payload.get("declared_constraints", [])) if isinstance(artifact_payload.get("declared_constraints", []), list) else [],
            },
        )

    def _build_target_specific_reviewer_directives(self, tu: Dict[str, object]) -> str:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        risk_tags = [str(item) for item in target.get("risk_tags", [])] if isinstance(target.get("risk_tags"), list) else []
        public_symbols = self._collect_public_symbols_from_signatures(self._get_effective_target_signatures(tu))
        has_tl_contract_surface = any(re.match(r"^TL[A-Z]\w*$", symbol) for symbol in public_symbols)
        has_async_flow = "[ASYNC_FLOW]" in risk_tags or "async-flow" in risk_tags
        ui_directives = self._build_phase06_ui_reviewer_directives(tu)
        if ui_directives:
            return ui_directives
        if role == "service":
            return "\n".join(
                [
                    "这是 Phase 04 service translation。reviewer 必须把 domain purity / protocol isolation 视为高于 Phase 03 source alignment 的 override。",
                    "若候选为消除协议污染而把 `TLUser` / `TLChannel` / `TL*` 改写为 `DomainUser` / `DomainChannel` / 纯仓颉领域类型，不得仅因 public signature 改动就判 `ARCH_SOURCE_ALIGNMENT_VIOLATION`、`ARCH_SIGNATURE_PARITY_VIOLATION` 或 `ARCH_RETURN_TYPE_MUTATION`。",
                    "若候选删除 `createInputPeer` / `InputPeer` / `sendRequest` / `toBytes()` / `TLDeserializer` 并把协议细节下沉到 adapter / repository / gateway，reviewer 应把这视为正向 Phase 04 结构修复，而不是 contract rupture。",
                    "若候选把 ArkTS `Promise<T>` 等价映射为仓颉 `Future<T>`，并通过 `spawn` 维持异步心智，或使用 anchor-defined signal implementation 承载 `Signal<Message[]>` 语义，不得仅因字面类型名变化就返回 blocker。",
                    "但 reviewer 仍必须阻断与协议净化无关的 public surface 膨胀：无 source 依据地新增 public helper / observer methods、把 DI / bridge / epoch infra 暴露为 public constructor 参数、或把核心接口替换成无关契约，仍应按 unauthorized public surface / contract rupture 打回。",
                    "对 service 目标，真正的 blocker 应聚焦在：TL* / InputPeer / raw bytes / `async` / `await` 回潮，或 domain-safe rewrite 之后仍然破坏业务 contract、状态语义与可观察行为。",
                ]
            )
        if role != "module":
            return "当前无额外 reviewer target-specific 指令。"
        shared_lines: List[str] = []
        if has_async_flow:
            target_path = str(target.get("path", ""))
            shared_lines.extend(
                [
                    "这是 `[ASYNC_FLOW]` module。reviewer 必须区分“删除字面量 `async` / `await`”和“保留异步返回合同”这两件事：只要 source 侧 `Promise<T>` 已被等价映射为仓颉 `Future<T>`，且执行时序仍通过 `spawn { ... }` / `.get()` 维持，就不能仅因候选去掉了字面量 `async` / `await` 而判 blocker。",
                    "按当前 Cangjie SDK 6.1.0.818 物理编译链，候选里出现任何字面量 `async` / `await` 都属于硬回退；reviewer 必须直接判为 blocker。",
                    "但若候选继续暴露 `Promise<...>`、把 `Promise<void>` / `Promise<Uint8Array>` 错翻成 `Unit`、缺失 `import std.sync.*`、写同步假注释，或把 `transport.connect()` / `createAuthKey()` 硬改成阻塞同步流程，必须继续按 `ARCH_SOURCE_ALIGNMENT_VIOLATION` / `ARCH_EXECUTION_TOPOLOGY_VIOLATION` 打回。",
                    "若候选对 `TransportCallback` / `TransportManager` / `AuthKeyCreator` / `decompress` 使用 `internal/private` 的最小 stub 作为 compile-safe 过渡，同时没有新增 source 中不存在的 public surface，这在当前 `Syntax Over Semantics` 阶段是可接受的；不要仅因此误报 public contract rupture。",
                    "若候选继续直接引用 `MTProtoConfig`、`CryptoUtils`、`TLMethods`、`TLSerialization`、`TLDialogs` 这些已验证依赖符号且未在当前文件重定义它们，这应被视为正向 source alignment，而不是重复定义。",
                    "但若某个依赖符号已经出现在 Dependency Closure / staged compile 上下文中，候选就绝不能在当前文件再次声明同名 `class` / `interface` / `func`；哪怕是 `internal/private` stub 也属于 compile-time redefinition 风险，必须按 `ARCH_DEPENDENCY_CONSTRAINT` 或 `ARCH_SOURCE_ALIGNMENT_VIOLATION` 打回。",
                    "若源侧方法带默认参数，而候选使用同名重载展开默认值，例如零参重载仅转发到完整签名，这属于允许的最小等价映射；reviewer 不得仅因目标侧没有内联 `= value` 就判定 contract rupture。",
                ]
            )
            if target_path.endswith("MTProtoClient.ets"):
                shared_lines.extend(
                    [
                        "对 `MTProtoClient` 特别约束：`initialize(forceNewAuthKey = false)` 的默认参数属于 source contract，但在仓颉里应被接受为同访问级别重载集合；同时，这组重载仍需保持 `Future<Unit>` 返回心智。`sendRequest` 是源文件中明确存在的合法 public method，且返回心智应为 `Future<Array<UInt8>>`；`getMTProtoClient()` 必须保留 singleton 心智。",
                        "如果 source_excerpt 已展示 `sendRequest`，reviewer 不得仅因 `target.signatures` 截断漏掉该方法，就把它误判成 unauthorized public surface。",
                        "若候选在 `getMTProtoClient()` 或其它 `Option<T>` 解包处使用后缀 `!`，或通过每次都 new 来逃避单例判空，这都违反 singleton safety；reviewer 必须要求使用 `match` / `if let` + 惰性初始化写回。",
                    ]
                )
        if has_tl_contract_surface and "[BINARY_PROTO]" not in risk_tags:
            return "\n".join(
                shared_lines
                + [
                    "这是定义 TL 协议契约的 module，不是 Service。只要 `TLUser` / `TLChannel` 等名字已经出现在 target.signatures / same-file public symbols 中，就不得仅凭 `TL*` 前缀判定 `ARCH_DOMAIN_PURITY_VIOLATION`。",
                    "若源侧是 public interface，目标侧允许使用 accessor-based public interface + `internal/private` 实现类做最小等价映射；`internal TLUserImpl` / `internal TLChannelImpl` 不属于 public surface rupture。",
                    "只有当候选删除了源侧 `TLUser` / `TLChannel` 等 public symbols，或把它们改名成 `DomainUser` / `DomainChannel` 这类新 public 类型时，才按 `ARCH_SOURCE_ALIGNMENT_VIOLATION` / `ARCH_CONTRACT_RUPTURE` 打回。",
                ]
            )
        if "[BINARY_PROTO]" not in risk_tags:
            return "\n".join(shared_lines) if shared_lines else "当前无额外 reviewer target-specific 指令。"
        return "\n".join(
            shared_lines
            + [
                "`Uint8Array -> Array<UInt8>` 属于当前项目已接受的 source-aligned 等价映射。若 public surface 仅做了这类映射，不得单独据此判定 `ARCH_SOURCE_ALIGNMENT_VIOLATION`。",
                "在这个协议模块里，ArkTS `number -> Int32`、`bigint -> Int64` 属于可接受的 fixed-width source mapping；只要 public surface 的语义位宽与调用心智保持一致，不得单独据此判定 `ARCH_SOURCE_ALIGNMENT_VIOLATION`。",
                "若仓颉标准库中缺少已被真实编译证明可用的 UTF-8 helper，`writeString` / `readString` 的 compile-safe 保守实现或最小占位实现可以作为阶段性通过候选；除非 public surface 被改坏，否则不得因这类占位实现返回 blocker，最多给 major note。",
                "若为了避开不存在的 `append/push` 而使用 `Array<UInt8>(old.size + 1, { ... })` 重建数组，这在当前 `Syntax Over Semantics` 阶段可接受；不要仅因 O(N^2) 性能推测把候选 blocker 掉。",
                "若真实 `cjc` 已经接受某个常量字面量或常量表达式，reviewer 不得凭空臆造新的 overflow blocker；常量溢出只能基于真实编译证据或明确的位模式不等价事实。",
                "但 32-bit 常量的位模式必须精确等价。例如源侧 `0xf35c6d01` 若在候选中写成有符号 `Int32`，唯一正确等价值是 `-212046591`；任何随意猜测的负数都必须按 `ARCH_SOURCE_ALIGNMENT_VIOLATION` 打回。",
            ]
        )

    def _build_phase06_ui_target_specific_directives(self, tu: Dict[str, object]) -> str:
        if not self._is_phase06_ui_target(tu):
            return ""
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        resolution = self._resolve_phase06_ui_tags(tu)
        structure_tag = str(resolution.get("structure_tag", ""))
        ownership_tag = str(resolution.get("ownership_tag", ""))
        interaction_tags = resolution.get("interaction_tags", []) if isinstance(resolution.get("interaction_tags", []), list) else []
        exception_tags = resolution.get("exception_tags", []) if isinstance(resolution.get("exception_tags", []), list) else []
        sample_scope_tags = resolution.get("sample_scope_tags", []) if isinstance(resolution.get("sample_scope_tags", []), list) else []
        source_ohos_imports = self._collect_phase06_ui_source_ohos_imports(tu)
        has_source_backed_arraylist = self._phase06_ui_source_contains_arraylist(tu)
        source_is_native_cangjie = self._phase06_ui_source_is_native_cangjie(tu)
        source_method_names = self._phase06_ui_source_declared_method_names(tu)
        publish_field_heads = self._phase06_ui_source_publish_field_heads(tu)
        listener_method_heads = self._phase06_ui_source_listener_method_heads(tu)
        has_gesture = "gesture-component" in interaction_tags
        has_ffi_exception = "ffi-exception" in exception_tags
        has_hybrid_exception = "hybrid-exception" in exception_tags
        lines: List[str] = [
            "[CRITICAL UI TRANSLATION DIRECTIVES]",
            f"Phase 06 UI lane is active for this target. Tag vocabulary source: `{resolution.get('manifest_name', 'phase06-ui-sample-manifest')}`; do NOT invent new UI tag classes.",
            "[Tag Resolution]",
            f"structure_tag={structure_tag}",
            f"ownership_tag={ownership_tag}",
            f"interaction_tags={format_list_inline(interaction_tags)}",
            f"exception_tags={format_list_inline(exception_tags)}",
            f"sample_scope_tags={format_list_inline(sample_scope_tags)}",
            f"resolution_source={resolution.get('resolution_source', 'heuristic-role-and-risk-tags')}",
            f"target.role={role}",
            "Each UI target must resolve to exactly one structure_tag and one ownership_tag. interaction/exception/sample_scope tags are additive only.",
            "[Source Alignment Lock]",
            "Preserve source-aligned `@Entry`, `@Component`, `build()`, page/component names, route names, prop names, state names, callback names, and parameter semantics 1:1 unless a later repair directive narrows one concrete syntax issue.",
            "Do NOT invent placeholder pages, components, builders, controllers, or facades to paper over an uncertain UI mapping.",
            "Do NOT collapse a multi-file UI/app pattern back into one mega page just to make the output look simpler.",
        ]
        if source_is_native_cangjie:
            lines.extend(
                [
                    "[Native Cangjie Fidelity Lock]",
                    "This source-aligned UI target is already authored in Cangjie (`.cj`). Treat `target.source` as the canonical implementation, not as a fresh cross-language translation task.",
                    "Default to emitting the whole `target.source` file as a verbatim baseline. Unless repair guidance calls out one concrete blocker, keep the file structurally identical and avoid whole-file rewrites.",
                    f"Source-backed method/body names already present in this file include {format_list_inline(source_method_names[:4])}. Unless repair guidance explicitly targets one of them, preserve existing method bodies, branch structure, comment placement, and brace shape exactly.",
                    "For long source-backed methods such as `build()` and other existing helpers/public methods, copy the exact method body line-for-line before making any localized fix. Do NOT reflow, dedupe, or 'clean up' large branches just to look nicer.",
                    "Do NOT normalize sibling branches, reorder conditionals, rewrite comments, or restyle indentation/braces outside the exact local blocker named in repair guidance.",
                    "Do NOT emit `...`, `omitted`, placeholder comments, half-written methods, or unclosed class scopes. If you keep a source-backed class/component, output its full body and all closing braces.",
                ]
            )
        if source_is_native_cangjie and role in {"viewmodel", "state"}:
            lines.extend(
                [
                    "[PHASE06 SOURCE-BACKED VIEWMODEL ANTI-DRIFT]",
                    "保留这些 source-backed `@Publish` state field head 的名字/装饰器/所有权；不要 rename/remove，也不要把 durable state 偷换成 invented proxy/delegate field。",
                ]
            )
            if publish_field_heads:
                lines.append(
                    "source-backed `@Publish` state field head: "
                    + "; ".join(publish_field_heads[:8])
                )
            if listener_method_heads:
                lines.extend(
                    [
                        "保留这些 source-backed listener/callback public method head 的参数 contract: "
                        + "; ".join(listener_method_heads[:6]),
                        "Do NOT rewrite them into bare function types when the source-backed head already names an interface/object listener contract.",
                    ]
                )
            lines.append(
                "若 source 文件直接在当前类持有并更新状态，不要改成 `attacher` / delegate / facade / helper-owned state 模式，也不要发明 source 中不存在的 delegator 类型来接管状态所有权。"
            )
        lines.extend(
            [
                "[Source-Era Vocabulary Normalization]",
                "Do NOT apply vocabulary cleanup mechanically. For Phase 06 UI, source-backed imports and source-backed container contracts outrank blanket normalization rules.",
                "Delete only invented `@ohos.*` / `ohos.*` paths that are absent from the source-aligned file, current TU, or real workspace. Never replace a deleted path with a fake package.",
                "Delete or normalize only invented container rewrites that are absent from the source-aligned file. Never replace a deleted container with `Vector<T>`, `toArray()`, fake collection helpers, or a new provider/facade.",
                "[Ownership Lock]",
                "Resolve one state owner and keep it singular. Do NOT duplicate state across page locals, component locals, controller caches, and invented stores.",
                "Do NOT invent bridge/provider/facade/repository shells unless the source already exposes that boundary.",
                "[Execution Lock]",
            ]
        )
        if source_ohos_imports:
            lines.extend(
                [
                    f"Source-backed UI macro import(s) are visible in this file: {format_list_inline(source_ohos_imports)}.",
                    "Preserve those exact import paths when they back copied source-aligned decorators/macros such as `@Entry`, `@Component`, `@State`, `@Builder`, or `@Prop`; do NOT delete them merely because they start with `ohos.`.",
                ]
            )
        else:
            lines.append(
                "No source-backed `ohos.*` import is visible for this target. If an `@ohos.*` / `ohos.*` path appears in the candidate, physically delete it and prefer zero import over a fake replacement."
            )
        if has_source_backed_arraylist:
            lines.extend(
                [
                    "`ArrayList<T>` is source-backed in this UI target. Preserve it on matching source-aligned signatures, fields, and helper boundaries that already use it, and keep `std.collection.*` when that is the source-backed dependency.",
                    "Do NOT collapse a source-backed `ArrayList<T>` contract to `Array<T>` / `[]` merely to look more 'native'.",
                ]
            )
        else:
            lines.append(
                "`ArrayList<T>` is not source-backed in this target. If it appears only as an invented UI-local container, normalize it to the minimal pipeline-legal form, defaulting to `Array<T>` / `[]`."
            )
        lines.append("Do NOT compensate by inventing `Vector<T>`, `toArray()`, fake collection helpers, or a new provider/facade just to keep old vocabulary alive.")
        if has_gesture or role in {"page", "component"}:
            lines.extend(
                [
                    "Preserve gesture thresholds, cancellation semantics, callback order, animation trigger boundaries, and main-thread UI handoff. Do NOT move network/storage/long-running work into gesture callbacks or `build()`.",
                ]
            )
        else:
            lines.append("No exception-only execution pattern is active beyond normal source-aligned UI callback ordering and main-thread handoff.")
        lines.append("[Boundary Lock]")
        if has_ffi_exception:
            lines.append("FFI/native details must stay inside `private/internal` adapters or helpers. Public UI contract, page props, and component props must not leak decoder/native ownership details unless the source explicitly does so.")
        if has_hybrid_exception:
            lines.append("Hybrid runtime splits must stay explicit. Keep `UI shell / controller / native or runtime` boundaries separate; do NOT collapse ArkTS/Cangjie or UI/controller/native concerns into one file.")
        if not exception_tags:
            lines.append("No exception tags are active for this target. Stay on the general UI rail and do NOT invent FFI/hybrid boundaries.")
        lines.append("[Hard Ban List]")
        lines.extend(
            [
                "Do NOT inline service / repository / native shells into UI files.",
                "Do NOT rewrite the public UI contract just to look more 'Cangjie-native'.",
                "Do NOT hallucinate fake pages, components, builders, providers, or runtime facades that are absent from the source-aligned file.",
            ]
        )
        if structure_tag == "page-shell":
            lines.extend(
                [
                    "page-shell targets own page/router/lifecycle composition and only short-lived UI state.",
                    "Do NOT inline repository/persistence/runtime truth into the page file.",
                ]
            )
        if structure_tag == "rich-component":
            lines.extend(
                [
                    "rich-component targets are reusable view blocks.",
                    "They must not assume page / router / ability ownership.",
                ]
            )
        if ownership_tag == "view-model-renderer":
            lines.append("`view-model-renderer` means the UI consumes external snapshot / render model / intents. Do NOT invent a local store, signal, or service cache as a second truth owner.")
        if ownership_tag == "controller-owned-state":
            lines.append("`controller-owned-state` means the controller/viewmodel/store remains the only durable truth owner; UI mirrors minimal display state and must not absorb async/persistence duties.")
        if "mixed-app-pattern" in sample_scope_tags:
            lines.append("`mixed-app-pattern` is sample-scope only. It does NOT authorize flattening app-level complexity into one translated file.")
        return join_unique_lines(lines)

    def _build_reviewer_artifact_payload(self, artifact_payload: Dict[str, object]) -> Dict[str, object]:
        if not isinstance(artifact_payload, dict):
            return {}
        compact: Dict[str, object] = {}
        repair_thought_process = artifact_payload.get("repair_thought_process")
        if isinstance(repair_thought_process, str) and repair_thought_process.strip():
            compact["repair_thought_process"] = repair_thought_process.strip()
        generated_code = artifact_payload.get("generated_code")
        code = artifact_payload.get("code")
        if isinstance(generated_code, str) and generated_code.strip():
            compact["generated_code"] = generated_code
        elif isinstance(code, str) and code.strip():
            compact["code"] = code
        declared_constraints = artifact_payload.get("declared_constraints")
        if isinstance(declared_constraints, list):
            compact["declared_constraints"] = [item for item in declared_constraints if isinstance(item, str)]
        notes = artifact_payload.get("notes")
        if isinstance(notes, list):
            compact["notes"] = [item for item in notes if isinstance(item, str)][:8]
        target_path = artifact_payload.get("target_path")
        if isinstance(target_path, str) and target_path.strip():
            compact["target_path"] = target_path.strip()
        return compact

    def _build_phase06_ui_reviewer_directives(self, tu: Dict[str, object]) -> str:
        if not self._is_phase06_ui_target(tu):
            return ""
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        resolution = self._resolve_phase06_ui_tags(tu)
        structure_tag = str(resolution.get("structure_tag", ""))
        ownership_tag = str(resolution.get("ownership_tag", ""))
        interaction_tags = resolution.get("interaction_tags", []) if isinstance(resolution.get("interaction_tags", []), list) else []
        exception_tags = resolution.get("exception_tags", []) if isinstance(resolution.get("exception_tags", []), list) else []
        sample_scope_tags = resolution.get("sample_scope_tags", []) if isinstance(resolution.get("sample_scope_tags", []), list) else []
        source_ohos_imports = self._collect_phase06_ui_source_ohos_imports(tu)
        has_source_backed_arraylist = self._phase06_ui_source_contains_arraylist(tu)
        lines: List[str] = [
            "这是 Phase 06 UI translation reviewer lane。reviewer 必须按已解析标签审查文件职责、状态所有权和边界，不要把 UI 结构化拆分本身误判成 rupture。",
            "[Tag Resolution]",
            f"structure_tag={structure_tag}",
            f"ownership_tag={ownership_tag}",
            f"interaction_tags={format_list_inline(interaction_tags)}",
            f"exception_tags={format_list_inline(exception_tags)}",
            f"sample_scope_tags={format_list_inline(sample_scope_tags)}",
            f"target.role={role}",
            "[Review Focus]",
            "若候选保持 source-aligned `@Entry`, `@Component`, `build()`, page/component names, route names, props/callback semantics，就不得仅因页面拆出 source-aligned 子组件、辅助渲染块或 builder 层次，就误报 `ARCH_CONTRACT_RUPTURE` 或 unauthorized public surface。",
            "必须阻断 invented page/component shell、fake provider/facade、placeholder builder tree，以及无 source 依据的 public UI contract rewrite。",
        ]
        if self._phase06_ui_source_is_native_cangjie(tu):
            lines.append(
                "若当前目标是 source-backed `.cj`，且候选保持 `target.source` 原样或只做 source-local 最小修补，reviewer 不得仅凭纯语义推断把 source 已存在的方法体判成 `ARCH_STATE_CONTRACT_VIOLATION` / `ARCH_SOURCE_ALIGNMENT_RUPTURE`；只有 candidate 明显偏离 source-backed body，或真实 verify/behavior 证据为红时，才允许打回。"
            )
        if source_ohos_imports:
            lines.append(
                f"source excerpt 已显式给出 UI 宏 import {format_list_inline(source_ohos_imports)}。若候选保留这些 exact import path 以支撑 `@Entry` / `@Component` / `@State` / `@Builder` / `@Prop`，这是正向 source alignment，不得仅因其以 `ohos.` 开头就判为 blocker。"
            )
        else:
            lines.append("若候选引入 source excerpt / TU / real workspace 中都不存在的 `ohos.*` path，reviewer 必须按 invented import drift 打回。")
        if has_source_backed_arraylist:
            lines.append(
                "若 source-aligned 文件已经在字段、函数签名或 helper 边界上使用 `ArrayList<T>`，reviewer 必须要求 exact parity；把这些 exact token 改写成 `Array<T>` / `[]` 不是优化，而是 contract drift。"
            )
        else:
            lines.append("若 `ArrayList<T>` 并非 source-backed，却在候选中作为 invented UI-local container 出现，reviewer 应要求回到最小合法集合形态，而不是接受容器幻觉。")
        ui_public_method_heads = self._phase06_ui_source_public_method_heads(tu)
        ui_listener_method_heads = self._phase06_ui_source_listener_method_heads(tu)
        if ui_public_method_heads:
            lines.append(
                "若完整 source 已显式声明 public method head "
                + "; ".join(ui_public_method_heads[:6])
                + "，即便 `target.signatures` / `public_surface_symbols` / `source_excerpt` 因截断未完整呈现，reviewer 也不得仅凭摘要缺口把它们判成 unauthorized public surface 或 `ARCH_SOURCE_ALIGNMENT_RUPTURE`。"
            )
        if ui_listener_method_heads:
            lines.append(
                "若完整 source 已原样声明这些 listener/callback public method head "
                + "; ".join(ui_listener_method_heads[:6])
                + "，reviewer 必须要求 exact parameter contract；不得接受把 source-backed listener interface/object 参数改写成裸函数类型。"
            )
        ui_build_head = self._phase06_ui_source_build_head(tu)
        if ui_build_head:
            lines.append(
                "若完整 source 已原样声明 component/builder method head "
                + ui_build_head
                + "，reviewer 不得仅凭惯用写法要求把它改成别的 override/visibility 形态；只有 candidate 偏离 source 或真实编译为红时，才允许打回。"
            )
        ui_member_method_heads = self._phase06_ui_source_member_method_heads(tu)
        ui_publish_field_heads = self._phase06_ui_source_publish_field_heads(tu)
        if ui_member_method_heads:
            lines.append(
                "若完整 source 已原样声明这些 target-file class-local member/helper method head "
                + "; ".join(ui_member_method_heads[:8])
                + "，reviewer 不得仅因它们未列入 `source_backed_public_method_heads` 或 `target.signatures`，就把候选中的同名成员方法判成 unauthorized public surface；只有真实 source 不存在、visibility 被额外提升，或 candidate 明显改写职责时，才允许打回。"
            )
        if ui_publish_field_heads:
            lines.append(
                "若完整 source 已原样声明这些 source-backed `@Publish` state field head "
                + "; ".join(ui_publish_field_heads[:8])
                + "，reviewer 必须阻断 rename/remove/decorator drift，也不得接受用 invented delegate/proxy/attacher 字段替换这些状态拥有者。"
            )
        ui_invocation_patterns = self._phase06_ui_source_invocation_patterns(tu)
        if ui_invocation_patterns:
            lines.append(
                "若完整 source 已原样使用这些调用形态 "
                + "; ".join(ui_invocation_patterns[:6])
                + "，reviewer 不得在没有 verify.compile / real cjc 失败证据时，仅凭语言直觉把它们判成 `ARCH_SYNTAX_REGRESSION`。"
            )
            if self._phase06_ui_source_is_native_cangjie(tu):
                lines.append(
                    "若当前目标是 source-backed `.cj` 文件，且这些调用形态已在完整 source 中原样存在，在没有真实 compile / verifier 红灯前，reviewer 不得把它们判成 `UNDEFINED_SYMBOL_RUPTURE`，也不得要求为这些 source-backed 调用额外补 invented import。"
                )
        ui_package_local_helper_heads = self._phase06_ui_same_package_helper_heads(tu)
        if ui_package_local_helper_heads:
            lines.append(
                "若 snapshot root 同包已确认存在这些 package-local helper head "
                + "; ".join(ui_package_local_helper_heads[:6])
                + "，reviewer 不得仅因当前单文件候选未内联定义、也未显式 import，就把这些同包 helper 调用判成 undefined symbol rupture。"
            )
        ui_uninitialized_field_heads = self._phase06_ui_source_uninitialized_field_heads(tu)
        if ui_uninitialized_field_heads:
            lines.append(
                "若完整 source 已原样保留未初始化字段声明 "
                + "; ".join(ui_uninitialized_field_heads[:6])
                + "，reviewer 不得在没有 verify.compile / real cjc 失败证据时，仅凭语言直觉把它们判成 `ARCH_SYNTAX_REGRESSION` 或 `UNDEFINED_SYMBOL_RUPTURE`，也不得要求为这些 source-backed 调用额外补 invented import。"
            )
        if structure_tag == "page-shell":
            lines.append("对 `page-shell`，reviewer 应要求页面只承担 page/router/lifecycle/short-lived UI state；若候选把 repository/persistence/native truth 内联进 page，应按架构越界打回。")
        if structure_tag == "rich-component":
            lines.append("对 `rich-component`，reviewer 不应要求它承担 page/router/ability 责任；若候选把组件膨胀成 page shell，应按职责漂移打回。")
        if ownership_tag == "view-model-renderer":
            lines.append("对 `view-model-renderer`，不得要求 renderer 本地拥有 controller truth；但若候选发明 shadow store、service cache 或 duplicate state，必须判为 blocker。")
        if ownership_tag == "controller-owned-state":
            lines.append("对 `controller-owned-state`，必须阻断 shadow local state、duplicate store、invented provider/facade/local cache 接管 controller truth。")
        if "gesture-component" in interaction_tags:
            lines.append("对 `gesture-component`，手势阈值、取消语义、回调顺序、动画触发边界和主线程 handoff 都属于 blocker-level contract；漂移时必须打回。")
        if "ffi-exception" in exception_tags:
            lines.append("对 `ffi-exception`，native/FFI 细节必须留在 `private/internal` adapter 边界；若泄漏进 public UI contract、page props 或 component props，应打回。")
        if "hybrid-exception" in exception_tags:
            lines.append("对 `hybrid-exception`，reviewer 必须要求 `UI shell / controller / native or runtime` 显式分层；不得接受把 hybrid 逻辑塌缩成单文件 mega page 的候选。")
        if "mixed-app-pattern" in sample_scope_tags:
            lines.append("不得要求把 `mixed-app-pattern` 的 app 级复杂度压回单文件；它只是 sample-scope tag，不是结构扁平化许可。")
        return join_unique_lines(lines)

    def _phase06_ui_source_text(self, tu: Dict[str, object]) -> str:
        if not isinstance(tu, dict):
            return ""
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        return str(target.get("source", "") or "")

    def _resolve_source_truth_path(self, tu: Dict[str, object]) -> str:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        target_path = str(target.get("path", "")).strip()
        if self._is_phase06_ui_target(tu):
            snapshot = tu.get("snapshot", {}) if isinstance(tu.get("snapshot"), dict) else {}
            snapshot_root = str(snapshot.get("root_path", "")).strip()
            if snapshot_root and target_path:
                return f"{snapshot_root.rstrip('/')}/{target_path}"
            if snapshot_root:
                return snapshot_root
        source_root = "raw_docs/telegramharmony-phase02"
        return f"{source_root}/{target_path}" if target_path else source_root

    def _collect_phase06_ui_source_ohos_imports(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source = self._phase06_ui_source_text(tu)
        if not source:
            return []
        imports = {
            match.group(1)
            for match in re.finditer(
                r"^\s*(?:(?:public|private|protected|internal)\s+)?import\s+"
                r"(ohos(?:\.[A-Za-z0-9_]+)+(?:\.\*)?)\s*$",
                source,
                re.MULTILINE,
            )
        }
        for match in re.finditer(
            r"^\s*from\s+ohos\s+import\s+([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)*(?:\.\*)?)\s*$",
            source,
            re.MULTILINE,
        ):
            suffix = match.group(1).strip()
            if suffix:
                imports.add(f"ohos.{suffix}" if not suffix.startswith("ohos.") else suffix)
        return sorted(imports)

    def _phase06_ui_source_contains_arraylist(self, tu: Dict[str, object]) -> bool:
        if not self._is_phase06_ui_target(tu):
            return False
        return "ArrayList<" in self._phase06_ui_source_text(tu)

    def _phase06_ui_source_is_native_cangjie(self, tu: Dict[str, object]) -> bool:
        if not self._is_phase06_ui_target(tu):
            return False
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        return str(target.get("path", "")).strip().endswith(".cj")

    def _phase06_ui_source_public_method_heads(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source = sanitize_source_for_prompt(self._phase06_ui_source_text(tu))
        if not source:
            return []
        heads: List[str] = []
        seen = set()
        for item in self._phase06_ui_extract_func_heads(source):
            if not item["is_public"]:
                continue
            head = item["head"]
            if head in seen:
                continue
            seen.add(head)
            heads.append(head)
        return heads

    def _phase06_ui_source_build_head(self, tu: Dict[str, object]) -> str:
        if not self._is_phase06_ui_target(tu):
            return ""
        source = sanitize_source_for_prompt(self._phase06_ui_source_text(tu))
        if not source:
            return ""
        for item in self._phase06_ui_extract_func_heads(source):
            if item["name"] == "build":
                return item["head"]
        return ""

    def _phase06_ui_source_member_method_heads(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source = sanitize_source_for_prompt(self._phase06_ui_source_text(tu))
        if not source:
            return []
        public_heads = set(self._phase06_ui_source_public_method_heads(tu))
        member_heads: List[str] = []
        seen = set()
        for item in self._phase06_ui_extract_func_heads(source):
            head = item["head"]
            if not head or head in public_heads or item["name"] == "build":
                continue
            if head in seen:
                continue
            seen.add(head)
            member_heads.append(head)
        return member_heads

    def _phase06_ui_source_listener_method_heads(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        listener_heads: List[str] = []
        seen = set()
        for head in self._phase06_ui_source_public_method_heads(tu):
            if not re.search(r"\b(?:[A-Za-z_]\w*Listener|[A-Za-z_]\w*Callback)\b", head):
                continue
            if head in seen:
                continue
            seen.add(head)
            listener_heads.append(head)
        return listener_heads

    def _phase06_ui_source_publish_field_heads(self, tu: Dict[str, object]) -> List[str]:
        return self._phase06_ui_source_decorated_field_heads(tu, "Publish")

    def _phase06_ui_source_decorated_field_heads(self, tu: Dict[str, object], decorator: str) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source = sanitize_source_for_prompt(self._phase06_ui_source_text(tu))
        if not source:
            return []
        target_decorator = decorator.strip()
        if not target_decorator:
            return []
        heads: List[str] = []
        seen = set()
        pending_decorators: List[str] = []
        for raw_line in source.splitlines():
            stripped = raw_line.strip()
            if not stripped:
                pending_decorators = []
                continue
            if stripped.startswith("@"):
                pending_decorators.append(stripped.lstrip("@").split("(", 1)[0].strip())
                continue
            if target_decorator not in pending_decorators:
                pending_decorators = []
                continue
            pending_decorators = []
            normalized = re.sub(r"\s+", " ", stripped)
            if not PHASE06_UI_FIELD_HEAD_RE.match(normalized):
                continue
            if normalized in seen:
                continue
            seen.add(normalized)
            heads.append(normalized)
        return heads

    def _phase06_ui_source_invocation_patterns(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source = sanitize_source_for_prompt(self._phase06_ui_source_text(tu))
        if not source:
            return []
        patterns: List[str] = []
        seen = set()
        for regex in PHASE06_UI_INVOCATION_PATTERN_RES:
            for match in regex.finditer(source):
                pattern = match.group(0).strip()
                if not pattern or pattern in seen:
                    continue
                seen.add(pattern)
                patterns.append(pattern)
                if len(patterns) >= 8:
                    return patterns
        return patterns

    def _phase06_ui_same_package_helper_heads(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        snapshot = tu.get("snapshot", {}) if isinstance(tu.get("snapshot"), dict) else {}
        root_path = str(snapshot.get("root_path", "")).strip()
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        target_rel_path = str(target.get("path", "")).strip()
        target_source = self._phase06_ui_source_text(tu)
        package_name = self._phase06_ui_source_package_name(tu)
        if not root_path or not target_rel_path or not target_source or not package_name:
            return []
        root = Path(root_path)
        if not root.exists():
            return []
        target_abs_path = (root / target_rel_path).resolve()
        referenced_names = set(self._phase06_ui_source_referenced_call_names(target_source))
        if not referenced_names:
            return []
        helper_heads: List[str] = []
        seen = set()
        for file_path in sorted(root.rglob("*.cj")):
            try:
                resolved = file_path.resolve()
            except OSError:
                continue
            if resolved == target_abs_path:
                continue
            try:
                text = file_path.read_text()
            except OSError:
                continue
            if self._extract_phase06_ui_package_name(text) != package_name:
                continue
            sanitized = sanitize_source_for_prompt(text)
            for item in self._phase06_ui_extract_func_heads(sanitized):
                name = item["name"]
                if name not in referenced_names or name in seen:
                    continue
                seen.add(name)
                helper_heads.append(item["head"])
                if len(helper_heads) >= 8:
                    return helper_heads
            for item in self._phase06_ui_extract_type_heads(sanitized):
                name = item["name"]
                if name not in referenced_names or name in seen:
                    continue
                seen.add(name)
                helper_heads.append(item["head"])
                if len(helper_heads) >= 8:
                    return helper_heads
        return helper_heads

    def _phase06_ui_source_package_name(self, tu: Dict[str, object]) -> str:
        if not self._is_phase06_ui_target(tu):
            return ""
        return self._extract_phase06_ui_package_name(self._phase06_ui_source_text(tu))

    def _extract_phase06_ui_package_name(self, source_text: str) -> str:
        match = re.search(r"^\s*package\s+([A-Za-z_][\w\.]*)", source_text, re.MULTILINE)
        return match.group(1).strip() if match else ""

    def _phase06_ui_source_referenced_call_names(self, source_text: str) -> List[str]:
        names: List[str] = []
        seen = set()
        for match in re.finditer(r"(?<![\.\w])([A-Za-z_]\w*)\s*\(", source_text):
            name = match.group(1).strip()
            if not name or name in seen or name in {"if", "for", "match", "return"}:
                continue
            seen.add(name)
            names.append(name)
        return names

    def _phase06_ui_extract_func_heads(self, source: str) -> List[Dict[str, object]]:
        heads: List[Dict[str, object]] = []
        seen = set()
        for match in PHASE06_UI_FUNC_HEAD_RE.finditer(source):
            name = match.group("name").strip()
            if not name:
                continue
            modifiers = re.sub(r"\s+", " ", str(match.group("modifiers") or "")).strip()
            generic_suffix = str(match.group("generic_suffix") or "").strip()
            open_paren_index = source.find("(", match.start("name"), match.end())
            if open_paren_index < 0:
                continue
            parsed = self._parse_phase06_ui_func_signature(source, open_paren_index)
            if parsed is None:
                continue
            params, return_type = parsed
            head = self._normalize_phase06_ui_func_head(
                name=name,
                params=params,
                return_type=return_type,
                modifiers=modifiers,
                generic_suffix=generic_suffix,
            )
            if head in seen:
                continue
            seen.add(head)
            heads.append(
                {
                    "name": name,
                    "head": head,
                    "is_public": any(token == "public" for token in modifiers.split()),
                }
            )
        return heads

    def _phase06_ui_extract_type_heads(self, source: str) -> List[Dict[str, object]]:
        heads: List[Dict[str, object]] = []
        seen = set()
        for match in PHASE06_UI_TYPE_HEAD_RE.finditer(source):
            name = match.group("name").strip()
            kind = match.group("kind").strip()
            if not name:
                continue
            modifiers = re.sub(r"\s+", " ", str(match.group("modifiers") or "")).strip()
            prefix = f"{modifiers} " if modifiers else ""
            head = f"{prefix}{kind} {name}"
            if head in seen:
                continue
            seen.add(head)
            heads.append(
                {
                    "name": name,
                    "head": head,
                    "is_public": any(token == "public" for token in modifiers.split()),
                }
            )
        return heads

    def _phase06_ui_source_public_type_heads(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source = sanitize_source_for_prompt(self._phase06_ui_source_text(tu))
        if not source:
            return []
        return [
            item["head"]
            for item in self._phase06_ui_extract_type_heads(source)
            if bool(item.get("is_public"))
        ]

    def _phase06_ui_source_primary_type_names(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source = sanitize_source_for_prompt(self._phase06_ui_source_text(tu))
        if not source:
            return []
        type_heads = self._phase06_ui_extract_type_heads(source)
        if not type_heads:
            return []
        primary_name = str(type_heads[0].get("name", "")).strip()
        return [primary_name] if primary_name else []

    def _parse_phase06_ui_func_signature(self, source: str, open_paren_index: int) -> Optional[Tuple[str, str]]:
        length = len(source)
        index = open_paren_index + 1
        paren_depth = 1
        while index < length and paren_depth > 0:
            char = source[index]
            if char == "(":
                paren_depth += 1
            elif char == ")":
                paren_depth -= 1
            index += 1
        if paren_depth != 0:
            return None

        params = source[open_paren_index + 1 : index - 1]
        while index < length and source[index].isspace():
            index += 1
        if index >= length or source[index] != ":":
            return params, ""

        index += 1
        return_start = index
        paren_depth = 0
        angle_depth = 0
        bracket_depth = 0
        while index < length:
            char = source[index]
            if char == "(":
                paren_depth += 1
            elif char == ")" and paren_depth > 0:
                paren_depth -= 1
            elif char == "<":
                angle_depth += 1
            elif char == ">" and angle_depth > 0:
                angle_depth -= 1
            elif char == "[":
                bracket_depth += 1
            elif char == "]" and bracket_depth > 0:
                bracket_depth -= 1
            elif char in {"{", "=", "\n"} and paren_depth == 0 and angle_depth == 0 and bracket_depth == 0:
                break
            index += 1
        return params, source[return_start:index]

    def _normalize_phase06_ui_func_head(
        self,
        *,
        name: str,
        params: str,
        return_type: str,
        modifiers: str = "",
        generic_suffix: str = "",
    ) -> str:
        normalized_modifiers = re.sub(r"\s+", " ", modifiers).strip()
        normalized_params = re.sub(r"\s+", " ", params).strip()
        normalized_return_type = re.sub(r"\s+", " ", return_type).strip()
        prefix = f"{normalized_modifiers} " if normalized_modifiers else ""
        head = f"{prefix}func {name}{generic_suffix}({normalized_params})"
        if normalized_return_type:
            head += f": {normalized_return_type}"
        return head

    def _phase06_ui_source_uninitialized_field_heads(self, tu: Dict[str, object]) -> List[str]:
        if not self._is_phase06_ui_target(tu):
            return []
        source = sanitize_source_for_prompt(self._phase06_ui_source_text(tu))
        if not source:
            return []
        heads: List[str] = []
        seen = set()
        for line in source.splitlines():
            stripped = line.strip()
            if not stripped or stripped.startswith("@"):
                continue
            match = PHASE06_UI_UNINITIALIZED_FIELD_HEAD_RE.match(stripped)
            if not match:
                continue
            head = re.sub(r"\s+", " ", stripped)
            if head in seen:
                continue
            seen.add(head)
            heads.append(head)
        return heads

    def _is_phase06_ui_target(self, tu: Dict[str, object]) -> bool:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        return role in PHASE06_UI_TARGET_ROLES or self._has_explicit_phase06_ui_tags(tu)

    def _has_explicit_phase06_ui_tags(self, tu: Dict[str, object]) -> bool:
        return bool(self._extract_phase06_ui_tag_payload(tu))

    def _extract_phase06_ui_tag_payload(self, tu: Dict[str, object]) -> Dict[str, object]:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        metadata = (tu.get("metadata") or {}) if isinstance(tu.get("metadata"), dict) else {}
        payload: Dict[str, object] = {}
        candidate_containers = [
            target.get("ui_prompt_tags"),
            target.get("phase06_ui_tags"),
            metadata.get("ui_prompt_tags"),
            metadata.get("phase06_ui_tags"),
            target,
            metadata,
        ]
        tag_keys = ("structure_tag", "ownership_tag", "interaction_tags", "exception_tags", "sample_scope_tags")
        for container in candidate_containers:
            if not isinstance(container, dict):
                continue
            for key in tag_keys:
                if key in container and key not in payload:
                    payload[key] = container.get(key)
        return payload

    def _load_phase06_ui_manifest(self) -> Dict[str, object]:
        if self._phase06_ui_manifest_payload is not None:
            return self._phase06_ui_manifest_payload
        if not self.phase06_ui_manifest_path.exists():
            self._phase06_ui_manifest_payload = {}
            return self._phase06_ui_manifest_payload
        try:
            loaded = json.loads(self.phase06_ui_manifest_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            loaded = {}
        self._phase06_ui_manifest_payload = loaded if isinstance(loaded, dict) else {}
        return self._phase06_ui_manifest_payload

    def _phase06_ui_tag_rules(self) -> Dict[str, List[str]]:
        manifest = self._load_phase06_ui_manifest()
        tag_rules = manifest.get("tag_rules", {}) if isinstance(manifest.get("tag_rules"), dict) else {}
        resolved: Dict[str, List[str]] = {}
        for key, default_value in PHASE06_UI_DEFAULT_TAG_RULES.items():
            raw_value = tag_rules.get(key, default_value)
            resolved[key] = [str(item) for item in raw_value if str(item)] if isinstance(raw_value, list) else list(default_value)
        return resolved

    def _resolve_phase06_ui_tags(self, tu: Dict[str, object]) -> Dict[str, object]:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        state_tags = [str(item) for item in target.get("state_tags", [])] if isinstance(target.get("state_tags"), list) else []
        thread_tags = [str(item) for item in target.get("thread_tags", [])] if isinstance(target.get("thread_tags"), list) else []
        interop_tags = [str(item) for item in target.get("interop_tags", [])] if isinstance(target.get("interop_tags"), list) else []
        raw_payload = self._extract_phase06_ui_tag_payload(tu)
        rules = self._phase06_ui_tag_rules()
        structure_tags = rules["structure_tags"]
        ownership_tags = rules["ownership_tags"]
        interaction_tag_allowlist = rules["optional_interaction_tags"]
        exception_tag_allowlist = rules["optional_exception_tags"]
        sample_scope_allowlist = rules["optional_sample_scope_tags"]
        explicit_structure = self._normalize_phase06_ui_tag(raw_payload.get("structure_tag"), structure_tags)
        explicit_ownership = self._normalize_phase06_ui_tag(raw_payload.get("ownership_tag"), ownership_tags)
        interaction_tags = self._normalize_phase06_ui_tag_list(raw_payload.get("interaction_tags"), interaction_tag_allowlist)
        exception_tags = self._normalize_phase06_ui_tag_list(raw_payload.get("exception_tags"), exception_tag_allowlist)
        sample_scope_tags = self._normalize_phase06_ui_tag_list(raw_payload.get("sample_scope_tags"), sample_scope_allowlist)

        structure_tag = explicit_structure
        if not structure_tag:
            structure_tag = "page-shell" if role == "page" else "rich-component"
        if structure_tag not in structure_tags:
            structure_tag = structure_tags[0]

        ownership_tag = explicit_ownership
        if not ownership_tag:
            if role in {"viewmodel", "state", "interop"} or state_tags or "callback-entry" in thread_tags:
                ownership_tag = "controller-owned-state"
            else:
                ownership_tag = "view-model-renderer"
        if ownership_tag not in ownership_tags:
            ownership_tag = ownership_tags[0]

        if "gesture-component" not in interaction_tags and self._looks_like_phase06_ui_gesture_target(tu):
            interaction_tags = interaction_tags + ["gesture-component"]
        if not exception_tags and self._looks_like_phase06_ui_ffi_target(tu):
            exception_tags = ["ffi-exception"]

        return {
            "manifest_name": str(self._load_phase06_ui_manifest().get("manifest_name", "phase06-ui-sample-manifest")),
            "structure_tag": structure_tag,
            "ownership_tag": ownership_tag,
            "interaction_tags": interaction_tags,
            "exception_tags": exception_tags,
            "sample_scope_tags": sample_scope_tags,
            "resolution_source": "explicit-target-ui-tags" if raw_payload else "heuristic-role-and-risk-tags",
        }

    def _load_phase06_ui_few_shot_pack(self) -> Dict[str, object]:
        if self._phase06_ui_few_shot_pack_payload is not None:
            return self._phase06_ui_few_shot_pack_payload
        if not self.phase06_ui_few_shot_pack_path.exists():
            self._phase06_ui_few_shot_pack_payload = {}
            return self._phase06_ui_few_shot_pack_payload
        try:
            loaded = json.loads(self.phase06_ui_few_shot_pack_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            loaded = {}
        self._phase06_ui_few_shot_pack_payload = loaded if isinstance(loaded, dict) else {}
        return self._phase06_ui_few_shot_pack_payload

    def _prepare_phase06_ui_few_shot_examples(self, tu: Dict[str, object]) -> List[Dict[str, object]]:
        if not self._is_phase06_ui_target(tu):
            return []
        pack = self._load_phase06_ui_few_shot_pack()
        entries = pack.get("entries", []) if isinstance(pack.get("entries"), list) else []
        if not entries:
            return []
        selection_policy = (
            pack.get("selection_policy", {})
            if isinstance(pack.get("selection_policy"), dict) else {}
        )
        limit = int(selection_policy.get("max_examples_per_prompt", 2) or 2)
        resolution = self._resolve_phase06_ui_tags(tu)
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        target_role = str(target.get("role", "")).strip().lower()
        interaction_tags = set(
            resolution.get("interaction_tags", [])
            if isinstance(resolution.get("interaction_tags", []), list) else []
        )
        exception_tags = set(
            resolution.get("exception_tags", [])
            if isinstance(resolution.get("exception_tags", []), list) else []
        )
        sample_scope_tags = set(
            resolution.get("sample_scope_tags", [])
            if isinstance(resolution.get("sample_scope_tags", []), list) else []
        )
        prepared: List[Tuple[int, int, Dict[str, object]]] = []
        for index, item in enumerate(entries):
            if not isinstance(item, dict) or not self._phase06_ui_few_shot_entry_is_safe(item):
                continue
            entry_structure = str(item.get("structure_tag", "")).strip()
            entry_ownership = str(item.get("ownership_tag", "")).strip()
            if entry_structure != str(resolution.get("structure_tag", "")):
                continue
            if entry_ownership != str(resolution.get("ownership_tag", "")):
                continue
            entry_interactions = set(item.get("interaction_tags", [])) if isinstance(item.get("interaction_tags", []), list) else set()
            entry_exceptions = set(item.get("exception_tags", [])) if isinstance(item.get("exception_tags", []), list) else set()
            entry_sample_scope = set(item.get("sample_scope_tags", [])) if isinstance(item.get("sample_scope_tags", []), list) else set()
            if entry_exceptions and not exception_tags:
                continue
            if entry_interactions and not interaction_tags:
                continue
            score = 200
            if target_role in {
                str(role).strip().lower()
                for role in (item.get("target_roles", []) if isinstance(item.get("target_roles", []), list) else [])
                if str(role).strip()
            }:
                score += 40
            score += 40 * len(interaction_tags & entry_interactions)
            score += 50 * len(exception_tags & entry_exceptions)
            score += 10 * len(sample_scope_tags & entry_sample_scope)
            if not interaction_tags and not entry_interactions:
                score += 10
            if not exception_tags and not entry_exceptions:
                score += 10
            priority = str(item.get("priority", "")).strip().upper()
            if priority == "P0":
                score += 20
            elif priority == "P1":
                score += 10
            if str(item.get("source_type", "")).strip() == "local_repo":
                score += 15
            selection_rank = int(item.get("selection_rank", index + 1) or index + 1)
            prepared.append((score, selection_rank, item))
        prepared.sort(key=lambda row: (-row[0], row[1]))
        return [row[2] for row in prepared[:max(0, limit)]]

    def _phase06_ui_few_shot_entry_is_safe(self, item: Dict[str, object]) -> bool:
        excerpt = str(item.get("source_excerpt", "")).strip()
        if not excerpt:
            return False
        if "${" in excerpt:
            return False
        return True

    def _build_phase06_ui_few_shot_examples(self, examples: object) -> str:
        if not isinstance(examples, list) or not examples:
            return "当前无匹配的 Phase 06 UI few-shot。"
        chunks: List[str] = []
        for index, item in enumerate(examples, start=1):
            if not isinstance(item, dict):
                continue
            prompt_hints = item.get("prompt_hints", []) if isinstance(item.get("prompt_hints", []), list) else []
            source = item.get("source", {}) if isinstance(item.get("source"), dict) else {}
            chunks.append(
                "\n".join(
                    [
                        f"[UI Example {index}] id={item.get('entry_id', '')}",
                        f"priority={item.get('priority', '')}",
                        f"source_type={item.get('source_type', '')}",
                        f"target_roles={format_list_inline(item.get('target_roles', []))}",
                        f"tags=structure:{item.get('structure_tag', '')}; ownership:{item.get('ownership_tag', '')}; interaction:{format_list_inline(item.get('interaction_tags', []))}; exception:{format_list_inline(item.get('exception_tags', []))}; sample_scope:{format_list_inline(item.get('sample_scope_tags', []))}",
                        f"source_ref={source.get('url', source.get('repo_root', ''))}@{source.get('commit', '')}",
                        f"source_paths={format_list_inline(item.get('source_paths', []))}",
                        f"why_it_matches={item.get('why_it_matches', '')}",
                        f"prompt_hints={'; '.join(str(hint) for hint in prompt_hints if str(hint)) or 'none'}",
                        "source_excerpt:",
                        clip_text(str(item.get("source_excerpt", "")), 1400),
                    ]
                )
            )
        return "\n\n---\n\n".join(chunks) if chunks else "当前无匹配的 Phase 06 UI few-shot。"

    def _normalize_phase06_ui_tag(self, value: object, allowed: Sequence[str]) -> str:
        tag = str(value).strip()
        return tag if tag in set(allowed) else ""

    def _normalize_phase06_ui_tag_list(self, value: object, allowed: Sequence[str]) -> List[str]:
        if not isinstance(value, list):
            return []
        allowed_set = set(allowed)
        normalized: List[str] = []
        seen = set()
        for item in value:
            tag = str(item).strip()
            if not tag or tag not in allowed_set or tag in seen:
                continue
            seen.add(tag)
            normalized.append(tag)
        return normalized

    def _looks_like_phase06_ui_gesture_target(self, tu: Dict[str, object]) -> bool:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        combined = " ".join(
            [
                str(target.get("path", "")),
                str(target.get("summary", "")),
                str(target.get("source", "")),
            ]
        )
        return bool(UI_GESTURE_HINT_RE.search(combined))

    def _looks_like_phase06_ui_ffi_target(self, tu: Dict[str, object]) -> bool:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        interop_tags = [str(item) for item in target.get("interop_tags", [])] if isinstance(target.get("interop_tags"), list) else []
        combined = " ".join(
            [
                str(target.get("path", "")),
                str(target.get("summary", "")),
                str(target.get("source", "")),
                " ".join(interop_tags),
            ]
        ).lower()
        return role == "interop" and any(token in combined for token in ("ffi", "napi", "native", "pixmap", "decoder"))

    def _build_schema_excerpt(self, required_dimensions: Sequence[str]) -> str:
        sections = []
        for dimension in required_dimensions:
            section = extract_markdown_section(self.schema_text, dimension)
            if section:
                sections.append(section)
        if not sections:
            return self.schema_text[:2000]
        return "\n\n".join(sections)

    def _build_architecture_excerpt(self, limit: int, repair_guidance: Optional[Sequence[str]] = None) -> str:
        if not self.architecture_skill_texts:
            return ""
        ranked_texts = self._rank_architecture_skills(repair_guidance=repair_guidance)
        parts: List[str] = []
        total_chars = 0
        for text in ranked_texts:
            if len(parts) >= limit:
                break
            excerpt = self._clip_architecture_skill(text, limit=2200)
            if not excerpt:
                continue
            parts.append(excerpt)
            total_chars += len(excerpt)
            if total_chars >= 8800:
                break
        return "\n\n---\n\n".join(parts)

    def _rank_architecture_skills(self, repair_guidance: Optional[Sequence[str]] = None) -> List[str]:
        focus_terms = self._build_architecture_focus_terms(repair_guidance)
        scored: List[tuple[int, int, str]] = []
        for index, text in enumerate(self.architecture_skill_texts):
            normalized = text.lower()
            score = 0
            for term in focus_terms:
                if term in normalized:
                    score += 2
            if "compile" in normalized or "compiler" in normalized:
                score += 3
            if "syntax" in normalized:
                score += 3
            if "option" in normalized or "match" in normalized or "hashmap" in normalized:
                score += 2
            if "lambda" in normalized or "closure" in normalized:
                score += 4
            if "regression" in normalized or "firewall" in normalized:
                score += 4
            if "unsafe" in normalized or "inputpeer" in normalized or "createinputpeer" in normalized:
                score += 2
            if "case _ => {" in normalized or "helper" in normalized or "expression" in normalized:
                score += 4
            if "zero-block" in normalized or "helper extraction" in normalized or "match-helper" in normalized:
                score += 6
            if "struct" in normalized or "domain model" in normalized or "public init" in normalized:
                score += 3
            if "std.time" in normalized or "randomid" in normalized or "time import" in normalized:
                score += 4
            if repair_guidance and self._looks_like_lambda_match_failure(repair_guidance):
                if "lambda" in normalized and "match" in normalized:
                    score += 20
                if "helper" in normalized or "case _ => {" in normalized:
                    score += 10
            if repair_guidance and self._looks_like_match_helper_extraction_failure(repair_guidance):
                if "match-helper" in normalized or ("zero-block" in normalized and "helper extraction" in normalized):
                    score += 40
                if "case some(" in normalized or "case _ => {" in normalized or "helper" in normalized:
                    score += 15
            if repair_guidance and self._looks_like_regression_firewall_needed(repair_guidance):
                if "regression" in normalized and "firewall" in normalized:
                    score += 20
                if "unsafe" in normalized or "inputpeer" in normalized or "createinputpeer" in normalized or "tl*" in normalized:
                    score += 8
            if repair_guidance and self._looks_like_init_array_api_failure(repair_guidance):
                if "constructor" in normalized and "array" in normalized:
                    score += 20
                if "init" in normalized or "append" in normalized:
                    score += 10
            if repair_guidance and self._looks_like_domain_model_init_failure(repair_guidance):
                if "skill name: `cangjie-struct-init-domain-model-v1`" in normalized:
                    score += 80
                if "uninitialized member variable" in normalized or ("struct" in normalized and "init" in normalized):
                    score += 35
                if "domain model" in normalized or "domainuser" in normalized or "domainchannel" in normalized or "domainmessage" in normalized:
                    score += 12
            if repair_guidance and self._looks_like_time_import_failure(repair_guidance):
                if "skill name: `cangjie-time-import-and-randomid-v1`" in normalized:
                    score += 80
                if "std.time" in normalized or "datetime" in normalized or "randomid" in normalized:
                    score += 35
                if "import" in normalized and "time" in normalized:
                    score += 12
            scored.append((score, index, text))
        scored.sort(key=lambda item: (-item[0], item[1]))
        return [item[2] for item in scored]

    def _looks_like_lambda_match_failure(self, repair_guidance: Sequence[str]) -> bool:
        combined = " ".join(str(item) for item in repair_guidance if str(item)).lower()
        return ("expected '=>'" in combined or 'lambda expression' in combined) and ('match' in combined or 'let' in combined)

    def _looks_like_regression_firewall_needed(self, repair_guidance: Sequence[str]) -> bool:
        combined = " ".join(str(item) for item in repair_guidance if str(item)).lower()
        regression_terms = (
            "static-blacklist-failed",
            "regression alert",
            "std.unsafe",
            "tluser",
            "tlchannel",
            "inputpeer",
            "createinputpeer",
            "sendrequest",
            "reentrantlock",
            "reentrantmutex",
            "async",
            "protocolcontext",
            "signalpipe",
            "valuesignal",
        )
        return any(term in combined for term in regression_terms)

    def _looks_like_match_helper_extraction_failure(self, repair_guidance: Sequence[str]) -> bool:
        combined = " ".join(str(item) for item in repair_guidance if str(item)).lower()
        has_lambda_signal = ("expected '=>'" in combined or 'lambda expression' in combined)
        has_block_signal = (
            'case some(' in combined
            or 'case _ => {' in combined
            or '=> {' in combined
            or "found keyword 'let'" in combined
            or "found keyword 'this'" in combined
            or "found keyword 'match'" in combined
        )
        return has_lambda_signal and has_block_signal

    def _looks_like_init_array_api_failure(self, repair_guidance: Sequence[str]) -> bool:
        combined = " ".join(str(item) for item in repair_guidance if str(item)).lower()
        api_terms = (
            "constructor",
            "append",
            "invalid binary operator '+'",
            "tomilliseconds",
            "milliseconds",
            "array<",
        )
        return any(term in combined for term in api_terms)

    def _looks_like_domain_model_init_failure(self, repair_guidance: Sequence[str]) -> bool:
        combined = " ".join(str(item) for item in repair_guidance if str(item)).lower()
        init_terms = (
            "uninitialized member variable",
            "is not initialized in the constructor of class or struct",
            "public struct domainuser",
            "public struct domainchannel",
            "public struct domainmessage",
        )
        return any(term in combined for term in init_terms)

    def _looks_like_time_import_failure(self, repair_guidance: Sequence[str]) -> bool:
        combined = " ".join(str(item) for item in repair_guidance if str(item)).lower()
        has_datetime = "datetime" in combined
        has_time_signal = (
            "undeclared identifier" in combined
            or "std.time" in combined
            or "nanosecond" in combined
            or "randomid" in combined
        )
        return has_datetime and has_time_signal

    def _build_dynamic_repair_directives(self, tu: Dict[str, object], repair_guidance: Sequence[str]) -> str:
        target = (tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        risk_tags = [str(item) for item in target.get("risk_tags", [])] if isinstance(target.get("risk_tags"), list) else []
        public_symbols = self._collect_target_public_symbols(target)
        has_tl_contract_surface = any(re.match(r"^TL[A-Z]\w*$", symbol) for symbol in public_symbols)
        has_async_flow_module = role == "module" and ("[ASYNC_FLOW]" in risk_tags or "async-flow" in risk_tags)
        is_mtprotoclient_chunk_c = self._is_mtprotoclient_chunk_c(tu)
        allow_protocol_surface = role == "module" and ("[BINARY_PROTO]" in risk_tags or has_tl_contract_surface)
        raw_combined = " ".join(str(item) for item in repair_guidance if str(item))
        combined = raw_combined.lower()
        directives: List[str] = []
        if self._phase06_ui_source_is_native_cangjie(tu):
            directives.extend(
                [
                    '[NATIVE CANGJIE WHOLE-FILE BASELINE]',
                    '当前目标是 source-backed `.cj` 文件。默认先把 `target.source` 整文件原样作为候选基线；除非 repair guidance 明确点名某个具体 blocker，否则不要重写整文件。',
                    '[ESCAPE HATCH FOR native Cangjie local repair]',
                    '若 repair guidance 只命中某个方法、分支或语法点，只允许在该局部附近做最小修补；不要重排 sibling branches、不要去重、不要重缩进，也不要顺手改写其它 source-backed method body。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '除非 repair guidance 明确要求，否则不要改写 source-backed 注释位置、brace shape、条件分支顺序、builder 树、字段顺序或其它已经存在的 `.cj` 结构。',
                ]
            )
        service_collaborator_allow_symbols = self._collect_service_collaborator_allow_symbols(tu) if role == "service" else []
        service_public_contract_oracle = self._collect_service_public_contract_oracle(tu) if role == "service" else []
        service_public_contract_oracle_map = {
            item["name"]: item["normalized_signature"]
            for item in service_public_contract_oracle
        }
        has_unsafe = 'std.unsafe' in combined or ' unsafe' in combined or 'unsafe ' in combined
        has_std_concurrent = 'std.concurrent' in combined or "can not find package 'std.concurrent'" in combined
        has_arraylist = 'arraylist' in combined
        has_import_from = (
            'import ... from' in combined
            or bool(re.search(r"\bimport\s+.*?\s+from\b", raw_combined, re.IGNORECASE))
            or bool(re.search(r"\bfrom\s+['\"][^'\"]+['\"]\s+import\b", raw_combined, re.IGNORECASE))
            or "found 'from'" in combined
        )
        has_number_suffix = (
            'number suffix' in combined
            or '数字后缀' in combined
            or bool(re.search(r"\b0[Uu]?[Ll]\b", raw_combined, re.IGNORECASE))
        )
        has_fake_package_import = (
            'can not find package' in combined
            or 'fake package import' in combined
            or 'import models.*' in combined
            or 'import services.*' in combined
            or 'import services.typename' in combined
        )
        has_zero_block_violation = (
            'arch_match_zero_block_violation' in combined
            or 'arch_match_helper_violation' in combined
            or 'zero-block rule' in combined
            or 'cj-match-helper-extraction-001-v1' in combined
            or 'helper extraction' in combined
            or bool(re.search(r"case\s+(?:some|none)\b[^\n]*=>\s*\{", raw_combined, re.IGNORECASE))
            or (
                ("expected '=>'" in raw_combined or 'lambda expression' in combined)
                and ('case none' in combined or 'case some' in combined)
            )
        )
        has_input_peer = 'inputpeer' in combined or 'createinputpeer' in combined
        has_send_request = 'sendrequest(' in combined or '.sendrequest(' in combined or 'sendrequest' in combined
        has_service_protocol_name_leak = role == "service" and (
            'messagesgethistory' in combined
            or 'messagessendmessage' in combined
            or 'getmtprotoclient()' in combined
            or 'getmtprotoclient(' in combined
        )
        has_async = ' async ' in f' {combined} ' or '\nasync' in combined or 'async ' in combined
        has_async_contract_collapse = (
            'promise<void>' in combined
            or 'promise<uint8array>' in combined
            or 'promise<array<uint8>>' in combined
            or 'future<unit>' in combined
            or 'future<array<uint8>>' in combined
            or '塌成 unit' in combined
            or '改为 `unit`' in combined
            or '改为 unit' in combined
        )
        has_default_parameter_failure = "expected ',' or ')', found '='" in raw_combined
        has_extension_failure = "expected declaration, found 'extension'" in raw_combined
        has_lambda_block_failure = "expected '=>' in lambda expression" in raw_combined
        has_top_level_var_failure = "variable in top-level scope must be initialized" in raw_combined
        has_service_public_init_violation = role == "service" and (
            'public constructor 参数' in combined
            or '无参构造函数' in combined
            or 'public init(adapter' in combined
            or (
                'constructor()' in raw_combined
                and (
                    'adapter' in combined
                    or 'bridge' in combined
                    or 'gateway' in combined
                    or 'repository' in combined
                    or 'imtprotoadapter' in combined
                )
            )
        )
        has_service_file_scope_bloat = role == "service" and (
            'arch_dependency_constraint_violation' in combined
            or '单一服务文件' in combined
            or '服务文件中重新定义' in combined
            or '10+ 个 public 类型' in combined
            or '所有类型堆砌在单一服务文件中' in combined
        )
        has_gateway_shell = role == "service" and (
            'static-shadow-gateway-bridge' in combined
            or 'gateway not configured' in combined
            or bool(re.search(r"\b(?:i[a-z]*gateway|gatewayimpl|messagegateway|bridgeimpl|protocoladapter|gatewayfactory)\b", combined))
        )
        undeclared_service_symbols = [
            symbol
            for symbol in re.findall(r"undeclared (?:type name|identifier) '([A-Z]\w+)'", raw_combined)
            if symbol not in service_collaborator_allow_symbols
        ]
        has_invented_service_collaborator = role == "service" and (
            "messagebackend" in combined
            or "servicelocator" in combined
            or any(symbol.endswith("Locator") for symbol in undeclared_service_symbols)
            or "MessageBackend" in undeclared_service_symbols
            or "ServiceLocator" in undeclared_service_symbols
        )
        has_service_public_contract_drift = role == "service" and bool(service_public_contract_oracle_map) and (
            'signature drift' in combined
            or 'public contract fidelity' in combined
            or 'contract drift' in combined
            or 'explicit staged contract' in combined
            or 'public signature drift' in combined
            or 'getmessages(peerid: peerid, limit: int64)' in combined
            or ('getmessages' in combined and 'int64' in combined and 'int32' in combined)
        )
        has_service_return_shape_compile_closure_failure = role == "service" and (
            (
                "expected 'interface-signal<struct-array<class-message>>'" in combined
                and "found 'unit'" in combined
            )
            or (
                "expected '() -> class-message'" in combined
                and "found '() -> unit'" in combined
            )
            or (
                "expected '() -> struct-array<class-message>'" in combined
                and "found '() -> unit'" in combined
            )
            or (
                "signal provision" in combined
                and "awaiting external collaborator wiring" in combined
            )
        )
        has_service_hashmap_put_failure = role == "service" and (
            "'put' is not a member of class 'hashmap" in combined
            or ('hashmap' in combined and '.put(' in combined)
        )
        has_service_option_none_compare_failure = role == "service" and (
            "!= none" in combined
            or "== none" in combined
            or ("invalid binary operator" in combined and "option<" in combined and "none" in combined)
        )
        has_service_message_timeline_member_gap = role == "service" and (
            'messagetimeline' in combined
            and (
                "'fetchmessages' is not a member of class 'messagetimeline'" in combined
                or "'sendmessage' is not a member of class 'messagetimeline'" in combined
            )
        )
        has_postfix_non_null_assertion = (
            'static-postfix-non-null-assertion' in combined
            or 'clientsingleton!' in combined
            or '后缀 ! 解包' in combined
        )
        has_await = (
            ' await ' in f' {combined} '
            or '\nawait' in combined
            or 'await ' in combined
            or bool(re.search(r"\bawait\b", raw_combined, re.IGNORECASE))
        )
        has_ohos_path = (
            'escape hatch for @ohos path' in combined
            or 'static-import-ohos-package' in combined
            or '@ohos.' in combined
            or 'ohos.' in combined
        )
        has_tl_protocol_import = (
            'escape hatch for tl* protocol import' in combined
            or 'static-tl-protocol-types' in combined
            or 'static-tl-serialization-in-service' in combined
            or bool(re.search(r"\btl(?:methods|serialization|deserializer|dialogs|user|channel)\b", combined))
        )
        has_atomic = (
            'escape hatch for atomic' in combined
            or 'static-atomic-family-regression' in combined
            or bool(re.search(r"\batomic(?:\s*<|[A-Z])", raw_combined, re.IGNORECASE))
        )
        has_signal = (
            'escape hatch for signal/valuesignal' in combined
            or 'static-shadow-signal-flow' in combined
            or 'static-signal-arraylist-smuggling' in combined
            or 'valuesignal' in combined
            or 'observable' in combined
            or bool(re.search(r"\bsignal\s*<", raw_combined, re.IGNORECASE))
        )
        has_protocol_stub_class = (
            'escape hatch for protocol stub class' in combined
            or 'static-protocol-stub-class' in combined
            or bool(re.search(r"\b(?:class|struct|interface)\s+(?:tl[a-z]\w*|inputpeer[a-z]\w*)", combined))
        )
        has_extends_regression = (
            'escape hatch for extends regression' in combined
            or 'static-extends-regression' in combined
            or ' extends ' in f' {combined} '
        )
        has_option_binary_proto_failure = (
            'uint8array' in combined
            or '| null' in raw_combined
            or "found '?'" in raw_combined
            or "found `?`" in raw_combined
            or "expected ';' or '<nl>', found '?'" in combined
        )
        has_enum_syntax_failure = (
            "after keyword 'enum'" in raw_combined
            or "expected declaration, found created" in combined
            or "expected declaration, found ','" in raw_combined
            or "expected declaration, found ','" in combined
        )
        has_named_argument_failure = (
            "invalid named arguments prefix" in combined
            or "named parameter" in combined
        )
        has_accessor_syntax_failure = (
            "expected declaration, found 'get'" in raw_combined
            or "expected declaration, found 'get'" in combined
        )
        if is_mtprotoclient_chunk_c:
            has_input_peer = False
            has_send_request = False
        if has_option_binary_proto_failure:
            directives.extend(
                [
                    '[CRITICAL WARNING: OPTIONAL / BINARY PROTO SYNTAX REGRESSION]',
                    '编译器已经给出物理证据：后缀可空写法 `T?` 在当前仓颉链路不合法。不要写 `T?`；可空必须写成前缀 `?T`，空值必须写 `None`，严禁继续输出 `null`。',
                    '[ESCAPE HATCH FOR Uint8Array/null/interface fields]',
                    'ArkTS `Uint8Array` 默认映射为 `Array<UInt8>`；ArkTS `Uint8Array | null` 映射为 `?Array<UInt8>`。不要写 `Array<Byte>?`、`Array<UInt8>?` 或 `null`。',
                    '如果源侧是 data-only `export interface`（字段 + 少量方法），优先保留 `public interface` 这个 kind，并把属性降级成 getter/setter 访问器；承载存储字段的实现类必须是 private/internal。不要新增 public constructor，也不要新增 source 中不存在的 public 类型。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修可空/二进制时，严禁为绕过编译而新增 source 中不存在的 public surface；同文件已在 target.signatures 中出现的 public symbols 必须原样保留。',
                ]
            )
        if has_enum_syntax_failure:
            directives.extend(
                [
                    '[CRITICAL WARNING: ENUM SYNTAX REGRESSION]',
                    '仓颉 enum 不接受 `enum class`、逗号分隔成员或裸行成员。不要写 `enum class`。',
                    '[ESCAPE HATCH FOR enum syntax]',
                    '请使用仓颉物理可编译的枚举写法，例如：`public enum AuthKeyState { | None | Created }`。每个成员前都要有 `|`，不要加逗号。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 enum 语法时，不要顺手改动同文件 public surface 的名称、数量或职责。',
                ]
            )
        if has_named_argument_failure:
            directives.extend(
                [
                    '[CRITICAL WARNING: NAMED ARGUMENT REGRESSION]',
                    '当前仓颉编译器已经明确拒绝命名参数前缀。不要写 `dcId:` 这类命名参数。',
                    '[ESCAPE HATCH FOR named arguments]',
                    '构造器和普通函数调用一律改回位置参数，按声明顺序传值；如果调用点来自源侧对象字面量，也请先下沉到 private/internal 实现类，再用位置参数构造。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修命名参数时，不要改变 public surface，也不要顺手把 interface 降级成新的 public class。',
                ]
            )
        if has_accessor_syntax_failure:
            directives.extend(
                [
                    '[CRITICAL WARNING: ACCESSOR SYNTAX REGRESSION]',
                    '仓颉 interface/类方法声明里不要写 `get dcId()` 这种属性访问器语法。不要写 `get dcId()`。',
                    '[ESCAPE HATCH FOR accessor syntax]',
                    '若要表达属性访问器，请显式写成方法：`func getDcId(): Int32`、`func getAuthKey(): ?Array<UInt8>`；setter 同理写成 `func setX(value: T): Unit`。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修访问器语法时，只改声明形式，不要顺手把 interface 改回 public class。',
                ]
            )
        if has_unsafe:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '静态扫描器是基于 AST 和文本硬匹配的！你在注释里写 // removed std.unsafe 是毫无意义的自欺欺人。特别是 `import std.unsafe.*` 这一整行，必须在物理代码层面彻底删除。',
                    '[ESCAPE HATCH FOR std.unsafe FINAL]',
                    '如果你是为了强制解包：请改用 match 或 let x = opt ?? default，不要引入 unsafe。',
                    '如果你是为了指针操作或类型转换：Service 层绝对不需要指针；请把转换逻辑推到更底层的 CFFI 层，或改用 as 安全强转。Service 层绝不允许保留 `import std.unsafe.*`。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修复 std.unsafe 后，永远不要再重新引入 `import std.unsafe.*`、任何 `unsafe` 变体、任何 TL* 协议对象或 SignalPipe。Domain Purity 依然是最高优先级！',
                ]
            )
        if has_arraylist:
            if self._is_phase06_ui_target(tu) and self._phase06_ui_source_contains_arraylist(tu):
                directives.extend(
                    [
                        '[UI ARRAYLIST CONTRACT FIDELITY]',
                        '当前 Phase 06 UI 目标的 source-aligned 文件已经真实使用 `ArrayList<T>`。保留这些 exact source-backed `ArrayList<T>` 字段、函数签名与 helper 边界，并继续保留对应的 `std.collection.*` 依赖；不要因为旧的泛化规则就把它们一刀切改成 `Array<T>` / `[]`。',
                        '[ESCAPE HATCH FOR UI ArrayList contract fidelity]',
                        '只删除当前候选里 source 文件不存在的 invented `ArrayList` 用法；不要把 source-backed `ArrayList<T>` contract 偷换成 `Array<T>`、`Vector<T>`、`toArray()` 或 collection facade。',
                        '[ANTI-OSCILLATION ANCHOR]',
                        '修 UI ArrayList 时，不要重写页面结构、不要吸收 controller truth、不要发明新的 runtime store，也不要把 source-backed `ArrayList<T>` 再误判成必须删除的旧词。',
                    ]
                )
            else:
                directives.extend(
                    [
                        '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                        '静态扫描器会直接硬匹配 `ArrayList`。你在注释里写 // removed ArrayList 或声称自己已经换容器都毫无意义；必须在物理代码层面彻底删除 `ArrayList`。',
                        '[ESCAPE HATCH FOR ArrayList]',
                        '在当前仓颉项目中，优先回到已验证的最小集合形态，例如 `Array<T>` / `[]`；不要擅自升级成 `Vector<T>`、`toArray()` 或任何未经真实编译证明可用的集合 API。严禁继续保留 Java 风格泛型集合。',
                        '[ANTI-OSCILLATION ANCHOR]',
                        '修复 ArrayList 时，严禁引入任何 TL* 协议对象或 SignalPipe。Domain Purity 依然是最高优先级！',
                    ]
                )
            if self._is_phase06_ui_target(tu) and not self._phase06_ui_source_contains_arraylist(tu):
                directives.extend(
                    [
                        '[UI ARRAYLIST NORMALIZATION]',
                        '对 Phase 06 UI 目标，保留 `@Entry` / `@Component` / `build()` / builder / list / grid 的声明式结构，但把所有 UI-local `ArrayList<T>` 字段、helper 入参/返回、临时列表统一收敛到 `Array<T>` / `[]`，并同步更新相关 helper 签名与循环边界。',
                        '[ESCAPE HATCH FOR UI collection normalization]',
                        '删 `ArrayList` 时，不要因此重写页面结构、吸收 controller truth，也不要发明 `Vector<T>`、`toArray()`、collection facade 或新的 runtime store。目标是保结构、去黑词，不是推倒重来。',
                    ]
                )
            if role == "service":
                directives.extend(
                    [
                        '[SERVICE ARRAYLIST ROOT-CAUSE]',
                        '当前 `ArrayList` 并不是单纯的容器选型问题，而是你在 Service 文件里发明了 shadow signal/runtime（例如 observer-backed `MessageSignal`）。不要把它机械替换成 `Vector` 或 `Array`；应直接删除这整块内联 signal/runtime 壳层。',
                        '[ESCAPE HATCH FOR service shadow signal runtime]',
                        '保留 `RealMessageService` 本体，删除内联 `MessageSignal` / observer list / subscription runtime；改为引用现有 same-package / anchor-defined signal-store 类型，或把确实必要的桥接收进 `private/internal` helper，而不是继续在当前文件堆 public support types。',
                    ]
                )
        if has_import_from:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '这是脚本语言导入语法回潮，仓颉绝对不认！无论是 `import ... from` 还是 `from \'./X\' import ...`，都必须在物理代码层面彻底删除。',
                    '[ESCAPE HATCH FOR import ... from]',
                    '请强制改用仓颉合法导入形式：同包 staged 依赖优先直接引用；若确实需要导入，只允许 `import package_name.*` 或 `import package_name.TypeName`。严禁继续保留 `from` 关键字。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修复导入语法时，严禁引入任何 TL* 协议对象或 SignalPipe。Domain Purity 依然是最高优先级！',
                ]
            )
        if has_number_suffix:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '静态扫描器是基于 AST 和文本硬匹配的！你不能靠注释、解释或伪注解蒙混过关；必须在物理代码层面彻底删除所有 `0L`、`0U`、`0UL` 这类后缀字面量。',
                    '[ESCAPE HATCH FOR number suffix]',
                    '仓颉对数字字面量后缀非常严格，禁止混用 C/C++/Java 风格。如果只是零值，请直接写 `0`；如果是为了类型匹配，请强制改用 `Int64(0)`、`UInt32(0)` 等显式类型构造。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修复数字后缀时，严禁引入任何 TL* 协议对象或 SignalPipe。Domain Purity 依然是最高优先级！',
                ]
            )
        if has_std_concurrent:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '`std.concurrent.*` 在当前 Cangjie SDK 6.1.0.818 物理编译链下不可解析。你不能继续把它当成 `Future` / `spawn` / 锁的来源；只要保留这个包路径，就会直接 compile-fail。',
                    '[ESCAPE HATCH FOR std.concurrent]',
                    '物理删除所有 `import std.concurrent.*` 与 `std.concurrent.*` 路径引用。若需要 `Future`、`spawn`、锁或其它并发原语，必须且只能改用已验证的 `import std.sync.*`。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 `std.concurrent` 时，严禁顺手把 `async`、`await`、`Promise(...)`、`InputPeer/createInputPeer`、TL* 或 `ohos.*` 路径带回当前文件。',
                ]
            )
        if has_ohos_path:
            if self._is_phase06_ui_target(tu) and self._collect_phase06_ui_source_ohos_imports(tu):
                directives.extend(
                    [
                        '[UI IMPORT CONTRACT FIDELITY]',
                        f"当前 Phase 06 UI 目标的 source-aligned 文件已经显式导入 {format_list_inline(self._collect_phase06_ui_source_ohos_imports(tu))}。这些 exact import path 是 source-backed UI 宏依赖，不要仅因它们以 `ohos.` 开头就机械删除。",
                        '[ESCAPE HATCH FOR UI import contract fidelity]',
                        '保留 source 文件里已经存在的 exact `ohos.*` import；只删除当前候选新增、且 source / TU / real workspace 都没有证据的 invented `ohos.*` path。更不要把它们替换成假想的 `kit.*`、`models.*`、`services.*` 包来补位。',
                        '[ANTI-OSCILLATION ANCHOR]',
                        '修 UI import 时，严禁顺手改写 `@Entry` / `@Component` / `@State` / `@Builder` / `@Prop` 结构，也不要再把 source-backed import 误导成必须归零。',
                    ]
                )
            else:
                directives.extend(
                    [
                        '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                        '仓颉不认识任何 `@ohos.*` / `ohos.*` 前端路径，也不接受你把它们伪装成当前目标文件的合法导入。注释说明、别名换皮或 import 排版都骗不过扫描器；必须物理删除这些路径。',
                        '[ESCAPE HATCH FOR @ohos path]',
                        '先删除所有 `@ohos.*` / `ohos.*` 导入。只允许保留当前 TU / repo index / 真实 workspace 中已经存在且可解析的真实包；如果当前上下文没有可信包路径，就不要发明任何新 import，尤其不要发明 `import models.*`、`import services.*`、`import ohos.*` 这类假包。',
                        '[ANTI-OSCILLATION ANCHOR]',
                        '修包路径时，严禁把 TL*、`InputPeer/createInputPeer`、`Signal/ValueSignal` 或 `ArrayList` 重新带回当前文件。',
                    ]
                )
            if self._is_phase06_ui_target(tu) and not self._collect_phase06_ui_source_ohos_imports(tu):
                directives.extend(
                    [
                        '[UI IMPORT NORMALIZATION]',
                        '对 Phase 06 UI 目标，保留 `@Entry` / `@Component` / `build()` / builder / layout tree，但不要机械抄回 `ohos.*` 包路径。删掉这些路径本身，不等于重写声明式 UI 结构。',
                        '[ESCAPE HATCH FOR UI import normalization]',
                        '如果当前上下文没有可信替代 import，就宁可保持零 import，也不要发明 `models.*`、`services.*`、`ohos.*` 或其它假包名来补位。',
                    ]
                )
        if has_tl_protocol_import and not allow_protocol_surface:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '`TLMethods` / `TLDialogs` / `TLSerialization` 这类 TL* 名字属于协议层，不属于 Service。你不能通过改 import 顺序、改别名或包一层 helper 继续保留它们；只要 Service 里还出现 TL*，静态墙就会直接拦截。',
                    '[ESCAPE HATCH FOR TL* protocol import]',
                    '物理删除所有 `import ...TL*` 与本文件内部的 TL* 实现/使用。若 TL* 仅作为 source-aligned public contract 类型出现，请保留该 public contract 名字的外部引用，但不要在当前 service 文件里重定义、构造、序列化或直接操作 TL*。TL* 名字只允许留在匹配的 public method signatures；不要额外写 `import ...TL*`、`protocol.TL*` 顶层导入、字段类型或 `private/internal` helper 签名。所有 TL 构造、请求与序列化都必须下沉到 `private/internal` 协作者或外部依赖。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 TL* 时，严禁顺手把 `InputPeer/createInputPeer`、`sendRequest(...)`、`Signal/ValueSignal`、`ArrayList` 或 `ohos.*` 路径带回 Service 层。',
                ]
            )
        if has_atomic:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '`Atomic` / `AtomicInt64` 不是 Service 层的急救贴。你不能靠泛型参数、别名或包装 helper 继续偷渡这些并发原语；只要代码里还出现 `Atomic*`，静态墙就会直接拦截。',
                    '[ESCAPE HATCH FOR Atomic]',
                    '如果只是本地消息 ID 计数、缓存版本号或临时序号：优先改成普通 `Int64` 字段；只有在确实存在共享写入时，才用 `Mutex` / `ReentrantMutex` 包住那一小段修改逻辑。若当前场景根本没有真实竞争，就直接删除 Atomic。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 Atomic 时，严禁顺手把 `ReentrantLock`、`Signal/ValueSignal`、TL*、`ArrayList` 或 `ohos.*` 路径带回 Service 层。',
                ]
            )
        if has_signal:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '`Signal` / `ValueSignal` / `Observable` 是影子框架名，不是当前仓颉 Service 的合法契约。你不能换个类名、放进 helper 或假装它是仓颉标准库的一部分；只要这些词还在，静态墙就会继续拦截。',
                    '[ESCAPE HATCH FOR Signal/ValueSignal]',
                    '删除本文件内部自造的 reactive runtime、registry 与缓存所有权，但不要借机篡改 source-aligned public contract。若源侧 public API 暴露 `Signal` / `ValueSignal` / 等价 reactive contract，请把它当成外部提供的 contract 名字来引用或转发，而不是在当前文件里新建实现、缓存或替换成别的 public 返回类型。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 Signal/ValueSignal 时，严禁重新引入 `ArrayList`、TL*、`InputPeer/createInputPeer`、`sendRequest(...)` 或 `ohos.*` 路径。',
                ]
            )
            if role == "service":
                directives.extend(
                    [
                        '[SERVICE REACTIVE CONTRACT ERADICATION]',
                        '对 Service 目标，`Signal` / `ValueSignal` / `SignalPipe` / `Store` / `Observable` 只能留在 source-/oracle-aligned public signature；字段类型、局部变量类型、`HashMap<String, Signal<...>>`、helper 返回类型、构造调用、placeholder return 都不允许存在。不要写 `let signal: Signal<T>`、`private let cache: Signal<T>`、`private func buildSignal(...): Signal<T>`、`Signal<T>()`、`return Signal<T>()`、`ValueSignal<T>(...)`、`SignalPipe<T>(...)`、`store.publish(...)`。',
                        '[ESCAPE HATCH FOR service reactive state]',
                        '删除 `messageSignals` 这类 reactive cache/registry，删除 `ValueSignal(...)` / `SignalPipe(...)` / custom publish-subscribe 逻辑与 `throw TODO` 之类 placeholder return。若 source 需要 reactive contract，请保留 source-aligned public method shape，并把 reactive object 的 ownership externalize 到本文件之外；当前 service 文件本身不得拥有、构造或重命名 public reactive contract。只有匹配的 public method 可以提到 `Signal` / `ValueSignal`；`private/internal` helper 必须改成 non-reactive return shape（例如 `Unit` / `Array<Message>` / `Bool`），再让 public method 直接从 source imports、TU dependency closure、explicit staged contract allowlist 中已知真实符号获取或转发 reactive object。若当前上下文根本没有真实 reactive provider/facade symbol，就不要发明新的 provider/facade/shell/locator 壳。',
                    ]
                )
        if has_gateway_shell:
            directives.extend(
                [
                    '[SERVICE GATEWAY SHELL DETECTED]',
                    '你正在 Service 文件里自造 gateway/bridge 壳层，例如 `IGateway`、`IMessageGateway`、`GatewayImpl`、factory 或“Gateway not configured”之类的占位异常。这仍然是在当前文件里偷渡基础设施。',
                    '[ESCAPE HATCH FOR service gateway shell]',
                    '删除当前文件中的 gateway/bridge 接口、实现类、factory、占位异常与 DI setter。若必须依赖外部协作者，请改成中性命名的 `private/internal` 引用，例如 `backend` / `messagePort`，或直接假定 source-aligned 依赖已在别处提供；不要在本文件声明任何 gateway/bridge 类型。',
                    '同时清空所有包含 `Gateway` / `Bridge` 的字段名、helper 名、factory 名、setter 名、注释和字符串字面量。不要留下 `gateway`、`createGateway`、`setGateway`、`Gateway not configured` 这类残余文本，因为静态墙会继续命中。',
                ]
            )
        if has_service_protocol_name_leak:
            directives.extend(
                [
                    '[SERVICE PROTOCOL NAME LEAK DETECTED]',
                    '这轮证据表明你把协议请求/单例 accessor 的名字直接漏进了 Service 文件，例如 `MessagesGetHistory`、`MessagesSendMessage`、`getMTProtoClient()`。这不是“内部纯化”，而是协议层实体回潮。',
                    '[ESCAPE HATCH FOR service protocol name leakage]',
                    '物理删除这些名字在当前 service 文件中的所有出现位置，包括 request 构造、helper、局部变量、注释和字符串。Service 只允许调用 source-aligned / oracle-aligned 的业务方法与外部 contract；协议 request type、bytes、singleton accessor 必须完全下沉到外部依赖或更底层实现。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修协议名泄漏时，严禁把 `sendRequest(...)`、`.toBytes()`、`TLDeserializer`、`ArrayList`、`ValueSignal(...)` 或 `InputPeer/createInputPeer` 一起带回 Service 层。',
                ]
            )
        if has_invented_service_collaborator:
            directives.extend(
                [
                    '[SERVICE INVENTED COLLABORATOR DETECTED]',
                    '这轮 compile / review 证据已经表明你在 Service 文件里凭空发明了私有协作者或 locator，例如 `MessageBackend`、`ServiceLocator`。这不是 source-aligned isolation，而是新的壳层污染。',
                    '[ESCAPE HATCH FOR invented collaborator]',
                    '物理删除所有不在 source imports、TU dependency closure、explicit staged contract allowlist 中的 `private/internal` collaborator type、constructor target、factory、provider、locator。允许继续引用的 staged contract 仅包括：'
                    + ", ".join(service_collaborator_allow_symbols)
                    + '。',
                    '若确实需要内部 wiring，请只复用当前 TU 已知的真实符号；中性字段名如 `backend` / `messagePort` 只能作为变量名，绝不意味着你可以发明 `MessageBackend` / `ServiceLocator` / `*Locator` 类型或调用。',
                ]
            )
        if has_service_public_contract_drift:
            oracle_preview = "; ".join(item["signature"] for item in service_public_contract_oracle)
            directives.extend(
                [
                    '[SERVICE PUBLIC CONTRACT ORACLE DRIFT DETECTED]',
                    '这轮证据表明候选的 public method 已经偏离 explicit staged contract bundle。对当前 service target，explicit staged contract bundle 是 public compile-contract oracle，不允许再以“domain purity”或“internal async refactor”为理由漂移 public signature。',
                    '[ESCAPE HATCH FOR staged contract oracle drift]',
                    '把所有 public methods 的参数类型、参数个数、返回形态、同步/异步心智精确对齐到 oracle：'
                    + oracle_preview
                    + '。',
                    '重点回归：`getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>` 中 `limit` 只能是 `Int32`，不能漂成 `Int64`；`Signal<Array<Message>>` 只能作为外部 public contract token 存在，不能在当前文件里落成 `ValueSignal(...)` 或任何 service-local signal runtime。',
                ]
            )
        if has_service_return_shape_compile_closure_failure:
            timeline_available = "MessageTimeline" in service_collaborator_allow_symbols
            directives.extend(
                [
                    '[SERVICE RETURN-SHAPE COMPILE CLOSURE FAILURE]',
                    '编译器已经证明你虽然保住了 oracle-aligned public signature，但方法体实际返回了 `Unit`。comment-only body、空函数体、只有注释的 `spawn { ... }` 都不算返回值；这会把 `Signal<Array<Message>>` / `Future<Message>` / `Future<Array<Message>>` 直接编译成红灯。',
                    '[ESCAPE HATCH FOR service return-shape closure]',
                    (
                        '当前 explicit staged contract allowlist 已提供 `MessageTimeline`。请优先写成 `private let timeline: MessageTimeline = MessageTimeline()`，并让 '
                        '`getMessages(peerId, limit)` 直接 `return this.timeline.getMessages(peerId, limit)`；`fetchMessages(...)` 直接 `return this.timeline.fetchMessages(params)`；'
                        '`sendMessage(...)` 直接 `return this.timeline.sendMessage(params)`。若确实需要额外 side effects，再把多步逻辑收进 `private/internal` helper，并确保 public 方法最终返回真实 `Future` 表达式。'
                        if timeline_available else
                        '请让每个非 `Unit` 方法体都以精确 oracle 类型的具体表达式收尾：`Signal<Array<Message>>` 必须 forward 一个真实外部 signal object，`Future<Array<Message>>` 必须返回真实 `Future<Array<Message>>` 表达式，`Future<Message>` 必须返回真实 `Future<Message>` 表达式。'
                    ),
                    '不要把函数体留成注释，更不要用 `throw TODO`、空 `spawn`、或伪 `Future` 壳逃避返回值。',
                ]
            )
        if has_service_hashmap_put_failure:
            directives.extend(
                [
                    '[SERVICE HASHMAP WRITE API REGRESSION]',
                    '编译器已经给出物理证据：当前仓颉 `HashMap` 没有 Java 风格 `.put(key, value)`。继续输出 `.put(...)` 只会 compile-fail。',
                    '[ESCAPE HATCH FOR HashMap writes]',
                    '把 `this.userAccessHashes.put(user.id.toString(), hash)` 改成 `this.userAccessHashes[user.id.toString()] = hash`；`channelAccessHashes` 同理。对 staged `HashMap<K, V>`，写入统一使用索引赋值，读取再用 `get(...)` / `contains(...)` / `match`。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 `HashMap` 写入 API 时，不要顺手改 public signature，也不要把 `accessHash` 的 `?Int64` 安全解包退化回 `if (hash != 0)` 这类未对齐写法。',
                ]
            )
        if has_service_option_none_compare_failure:
            directives.extend(
                [
                    '[SERVICE OPTION NONE COMPARISON REGRESSION]',
                    '编译器已经给出物理证据：当前仓颉链路不接受把 `Option` / `?T` 与 `None` 直接做 `==` / `!=` 比较。继续输出 `if (user.accessHash != None)`、`if (channel.accessHash == None)` 只会 compile-fail。',
                    '[ESCAPE HATCH FOR Option/None handling]',
                    '对 `TLUser.accessHash` / `TLChannel.accessHash` 这类 `?Int64`，改用 `match (user.accessHash)` / `match (channel.accessHash)` 或等价 `if let`；不要先写一层 `if (opt != None)` 再在里面 `match`。None 分支保持单表达式 `()`，非空分支直接做合法写入，例如 `case Some(hash) => this.userAccessHashes[user.id.toString()] = hash`。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 `Option` 判空时，不要顺手回潮到 `if (hash != 0)`、`!` 强制解包、`throw TODO`、`ValueSignal(...)` 或任何 invented collaborator。',
                ]
            )
        if has_service_message_timeline_member_gap:
            directives.extend(
                [
                    '[SERVICE TIMELINE API GAP DETECTED]',
                    '这轮 compile 证据表明候选已经选中了 `MessageTimeline` 这条合法 external collaborator 路径，但调用的内部 API 形状与 staged contract 不一致。',
                    '[ESCAPE HATCH FOR MessageTimeline API]',
                    '对本轮 staged `MessageTimeline`，允许的 compile-safe internal API 是：`getMessages(peerId, limit): Signal<Array<Message>>`、`fetchMessages(params): Future<Array<Message>>`、`sendMessage(params): Future<Message>`、`replaceMessages(peerId, messages): Unit`、`appendMessage(peerId, message): Unit`。不要再调用不存在的 timeline 方法名，也不要把这些 internal helper 暴露成 public API。',
                ]
            )
        if has_protocol_stub_class and not allow_protocol_surface:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '你正在 Service 层自造 TL* / InputPeer 协议桩类。这不是修复，这是污染扩散。任何 `class TLUser`、`class TLChannel`、`class InputPeer...` 都必须物理删除。',
                    '[ESCAPE HATCH FOR protocol stub class]',
                    '所有 TL* 与 InputPeer 都属于底层 CFFI / FFI 协议层。Service 层绝对不允许定义、实现或继承它们。若缺少类型定义，请改回 Domain Model、预设映射类型，或把 opaque handle / OpaquePointer 式方案下沉到底层。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修协议桩类时，严禁顺手重新引入 `extends`、`implements`、`std.unsafe.*`、`ArrayList`、`Signal/ValueSignal` 或 `ohos.*`。',
                ]
            )
        if has_extends_regression:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '`extends` 在这里不是合法面向对象修复，而是源语言回潮。尤其当你把它用在 TL* / InputPeer / 业务桩类上时，编译器与静态墙都会直接击穿。',
                    '[ESCAPE HATCH FOR extends regression]',
                    '如果确实是仓颉合法继承，请只在真实、已知的标准库或项目内正式类型层次上使用 `<:`；如果只是因为缺少协议类型，请删掉整个 stub class，改回 Domain Model、预设映射类型或更底层 opaque handle 方案。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 extends 时，严禁顺手把 TL*、InputPeer、`std.unsafe.*`、`ArrayList` 或 `Signal/ValueSignal` 重新带回 Service 层。',
                ]
            )
        if has_fake_package_import:
            directives.extend(
                [
                    '[FAKE PACKAGE IMPORT DETECTED]',
                    '编译器已经给出物理证据：`can not find package`。这说明你把移除 `@ohos.*` 的逃生通道错误地实现成了捏造包名。仓颉编译器不会接受不存在的 `models.*` / `services.*` 导入。',
                    '[ESCAPE HATCH FOR fake package import]',
                    '只允许引用当前 TU / repo index / 真实 workspace 中确实存在的包。若当前上下文没有可用包，就不要发明 `import models.*`、`import services.*` 或 `import services.TypeName`；优先删除虚假 import，让依赖回到真实签名上下文。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修包导入时，严禁把已经清零的 `@ohos.*`、TL*、InputPeer 或 SignalPipe 重新带回 Service 层。',
                ]
            )
        if has_service_public_init_violation:
            directives.extend(
                [
                    '[SERVICE PUBLIC INIT CONTRACT]',
                    '审查证据已经明确指出：源侧 public contract 是零参 `constructor()`。不要继续把 `IMTProtoAdapter`、gateway、repository、bridge、observer runtime、epoch 或其它基础设施暴露成 `public init(...)` 参数。',
                    '[ESCAPE HATCH FOR service public init]',
                    '恢复零参 `public init()`；若确实需要协议隔离依赖，请改成 `private/internal` wiring，例如内部默认 provider、same-package factory、private helper 或 internal setter/holder。`public init()` 只能保留本地字段初始化与最小状态准备。',
                ]
            )
        if has_service_file_scope_bloat:
            directives.extend(
                [
                    '[SERVICE FILE-SCOPE BLOAT]',
                    'Review 已经给出边界违规证据：不要在 `RealMessageService` 目标文件里重新声明整套 support/domain/runtime 类型。尤其不要把 `PeerId`、`DomainMessage`、`DomainUser`、`DomainChannel`、`SendMessageParams`、`GetHistoryParams`、`MessageSignal`、`IMTProtoAdapter`、`IMessageService`、observer/runtime registration 一次性全塞回当前文件。',
                    '[ESCAPE HATCH FOR service file boundary]',
                    '优先直接引用 source-aligned / anchor-defined / same-package 现成类型；若当前上下文缺少实现细节，也保留引用并让 staged dependency closure 解析。只允许新增为当前 service 本体不可避免的 `private/internal` helper，且不得新增无 source 依据的 public 类型簇。除非 source 明确同文件声明，否则应把 public 输出收敛到 `RealMessageService` 本体，而不是再输出一组 public models/params/signal/runtime types。',
                ]
            )
        if has_zero_block_violation:
            directives.extend(
                [
                    '[ZERO-BLOCK / MATCH-HELPER VIOLATION DETECTED]',
                    'Review 与编译证据已经明确指出：`match` 分支、Array 构造 lambda、闭包体里都不允许塞副作用或多步逻辑。你不能在 `case ... =>` 后直接 put / append / 构造 / 更新状态，也不能输出 `case None => {}` / `case None => { let ... }` 这类 block-style 分支。',
                    '[ESCAPE HATCH FOR Zero-Block]',
                    '把所有 `case ... =>` 里的状态更新、数组构造、缓存写回提取成 helper，例如 `handleCacheHit(...)`、`handleCacheMiss(...)`、`buildAppendedMessages(...)`；`match` 分支只允许返回 helper 调用或单值。若空分支什么都不做，也要改成单表达式而不是 `{}` block。继续坚守 Zero-Block Rule 与 Helper Extraction。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 Zero-Block 时，严禁为图省事重新引入 `import std.unsafe.*`、`import models.*`、`import services.*`、TL* 协议对象或 SignalPipe。',
                ]
            )
            if role == "service":
                directives.extend(
                    [
                        '[SERVICE ZERO-BLOCK COMPILE SHAPE]',
                        '对 Service 目标，`getMessages` / `fetchMessages` / `sendMessage` 里的缓存写回、signal 发布、锁释放、数组拼接都应提取到 `private/internal` helper。`match` 分支只返回 helper 调用、现成值或单表达式 `()`；不要继续输出 `case None => {}`、`case Some(x) => { let ... }` 这种 block-style 分支。',
                    ]
                )
        if has_input_peer and not allow_protocol_surface:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '`InputPeer` / `createInputPeer(...)` 是协议边界残留，不属于 Service 层。你不能换个函数名或包一层 helper 糊弄过去；只要 Service 里还出现这些词，静态墙就会继续拦截。',
                    '[ESCAPE HATCH FOR InputPeer/createInputPeer]',
                    '把 `InputPeer` 与 `createInputPeer(...)` 全部下沉到 Adapter 私有实现。Service 只允许传递 `PeerId`、基础标量或纯领域对象，并调用领域级 Adapter 方法。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修协议边界时，严禁重新引入 `sendRequest(...)`、`std.unsafe.*`、TL*、SignalPipe，且继续坚守 Zero-Block Rule 与 Helper Extraction。',
                ]
            )
        if has_send_request:
            directives.extend(
                [
                    '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                    '`sendRequest(...)` 是底层请求通道，不属于 Service 层。你不能换个对象名、包一层 helper 或改成链式写法来掩盖；只要 Service 里还在直接发请求，静态墙就会继续拦截。',
                    '[ESCAPE HATCH FOR sendRequest]',
                    '把底层请求发送彻底下沉到 Adapter，Service 层只能调用领域级方法，例如 `fetchMessages(...)`、`sendMessage(...)`、`loadHistory(...)` 之类的业务接口，绝不允许直接碰 Request/bytes。',
                    '[ANTI-OSCILLATION ANCHOR]',
                    '修 sendRequest 时，严禁重新引入 `InputPeer/createInputPeer`、`std.unsafe.*`、TL*、SignalPipe，且继续坚守 Zero-Block Rule 与 Helper Extraction。',
                ]
            )
        if has_async_contract_collapse and has_async_flow_module:
            directives.extend(
                [
                    '[ASYNC CONTRACT MUST SURVIVE]',
                    'Review 已经给出物理结论：ArkTS `Promise<T>` 合同不能塌成同步 `Unit`。当前仓颉目标必须改成 `Future<T>`：`Promise<void>` -> `Future<Unit>`，`Promise<Uint8Array>` -> `Future<Array<UInt8>>`。',
                    '[ESCAPE HATCH FOR async-flow Future contract]',
                    '文件顶部补 `import std.sync.*`，把方法签名改成常规 `func ...: Future<T>`；用 `spawn { ... }` 替代 `new Promise(...)`，在需要串接结果时使用 `.get()`，`Future<Unit>` 的 `spawn` 末尾显式写 `()`。',
                    '严禁继续输出 `Promise<...>`、`Promise(...)`、`await` 或同步假注释，例如 “Synchronous connect assumption”。',
                    '对 `TransportManager` / `AuthKeyCreator` / `decompress` 这类尚未落绿的依赖，允许使用 `internal/private` 极简 seam 占位，但不得新增 source 中不存在的 public surface。',
                ]
            )
        if has_default_parameter_failure:
            directives.extend(
                [
                    '[DEFAULT PARAMETER SYNTAX REGRESSION]',
                    '编译器已经拒绝参数默认值写法。不要继续输出 `forceNewAuthKey: Bool = false` 这类参数声明。',
                    '[ESCAPE HATCH FOR default parameter]',
                    '默认参数必须改写为同名重载展开，而不是直接删默认语义。少参数重载只做默认值转发，完整签名保留真实实现；所有重载都必须继承源侧访问修饰符。',
                    '例如源侧 `initialize(forceNewAuthKey = false)`，目标侧应改成 `initialize()` 调 `initialize(false)`，而不是继续把 `= false` 写在参数列表里，也不是直接删除默认语义。',
                ]
            )
        if has_extension_failure:
            directives.extend(
                [
                    '[TOP-LEVEL EXTENSION REGRESSION]',
                    '当前仓颉链路不接受顶层 `extension MTProtoClient`。不要再把 `onConnected/onData/onError` 这类方法塞进顶层 extension。',
                    '[ESCAPE HATCH FOR extension]',
                    '把 callback 方法直接收回 `MTProtoClient` 类体，或抽到合法的 `internal/private` helper；顶层只能放合法声明，不能放 extension 魔法。',
                ]
            )
        if has_lambda_block_failure:
            directives.extend(
                [
                    '[LAMBDA BLOCK REGRESSION]',
                    '编译器已经明确说明 lambda 只接受单表达式。不要在 `resolve = { ... }` / `reject = { ... }` 里直接写多条 `let` / `match` / 状态更新。',
                    '[ESCAPE HATCH FOR lambda block]',
                    '把多步逻辑提取到 `private/internal` helper，让 lambda 只做一个 helper 调用或单表达式返回。',
                ]
            )
            if role == "service":
                directives.extend(
                    [
                        '[SERVICE FUTURE LAMBDA COMPILE GUIDANCE]',
                        '当前 Service 物理链路优先接受 `spawn { ... }` 作为内部并发形态，不要继续写 JS/Promise 风格的 `Future<T>({ resolver => ... })` 或其它 resolver lambda 包装。',
                        '推荐骨架：只有当源侧 public method 本身就是 `Promise<T>` / async 合同时，才保持 `public func ...: Future<T> { spawn { let result = loadMessages(...); this.updateCache(...); result } }`；若源侧 public method 不是 async，就把 `spawn` / waiter / collaborator 调度封装到 `private/internal` helper 中，并在 public 方法边界恢复 source-aligned 返回形态。若仍需 `match`，请先在 helper 中完成多步状态更新，再让 `spawn` / lambda 只返回最终值。',
                    ]
                )
        if has_top_level_var_failure:
            directives.extend(
                [
                    '[TOP-LEVEL SINGLETON REGRESSION]',
                    '不要继续写顶层可变单例变量 `var clientSingleton: ?MTProtoClient = None`。当前链路不接受这种顶层状态写法。',
                    '[ESCAPE HATCH FOR singleton state]',
                    '若必须保留 `getMTProtoClient()` 的单例心智，请把状态收进合法的 `internal/private` holder；若没有经过验证的 holder 语法，就先使用更保守的 compile-safe getter，而不是继续顶层裸写可变状态。',
                ]
            )
        if has_postfix_non_null_assertion:
            directives.extend(
                [
                    '[SINGLETON FORCE-UNWRAP REGRESSION]',
                    '禁止在 `clientSingleton` 或任何 `Option<T>` / 可空类型上使用后缀 `!` 强制解包。`clientSingleton!` 这类写法会被静态墙直接拦截。',
                    '[ESCAPE HATCH FOR singleton safe unwrap]',
                    '请使用安全解包：优先 `match (clientSingleton)`，`case Some(existing) => existing`，`case None => { let created = MTProtoClient(); clientSingleton = Some(created); created }`；若当前链路接受 `if let`，也只能用于同等安全的显式绑定。',
                    '单例必须在访问入口完成惰性初始化，随后返回已判空的实例；不要通过“每次都 new 一个实例”来规避判空，也不要把同步单例退化成非单例 getter。',
                ]
            )
            if self._is_phase06_ui_target(tu) and self._phase06_ui_source_is_native_cangjie(tu):
                directives.extend(
                    [
                    '[SOURCE-BACKED FIELD-HEAD PATCH ONLY]',
                    '若静态墙命中 source-backed 字段头里的后缀 `!`（例如 `width!:`、`text!:`），只允许在原字段声明处做词法级修补：删除该 `!`，同时保留字段名、顺序、默认值、ownership 与 surrounding class shape 不变。',
                    '修这类字段头时，必须继续保留同文件 controller/component 的完整 source-backed methods 与 build tree；禁止只输出字段区、截断类后半段，或顺手删除后续方法体来换取通过静态墙。',
                ]
            )
            if self._is_phase06_ui_target(tu) and self._phase06_ui_source_is_native_cangjie(tu):
                source_method_names = self._phase06_ui_source_declared_method_names(tu)
                lowercase_helper_name = next(
                    (
                        name for name in source_method_names
                        if name and name[0].islower()
                    ),
                    "",
                )
                directives.append('[SOURCE-BACKED SAME-FILE HELPER CASE LOCK]')
                if lowercase_helper_name:
                    directives.append(
                        f"同文件已有 helper/member method 调用名大小写必须与 source 完全一致；不要把 `{lowercase_helper_name}` 改写成 `{lowercase_helper_name[:1].upper()}{lowercase_helper_name[1:]}`，也不要借机发明新的 alias / facade helper。"
                    )
                else:
                    directives.append(
                        '同文件已有 helper/member method 调用名大小写必须与 source 完全一致；不要改写调用名首字母大小写，也不要借机发明新的 alias / facade helper。'
                    )
        if has_async or has_await:
            if has_async_flow_module:
                directives.extend(
                    [
                        '[LITERAL ASYNC/AWAIT MUST GO, ASYNC CONTRACT MUST STAY]',
                        '这是 `[ASYNC_FLOW]` 模块，不是同步 Service。当前链路不接受字面量 `async` / `await`，但这不等于你可以删掉异步返回合同。',
                        '[ESCAPE HATCH FOR async keyword in async-flow module]',
                        '物理删除 `async` / `await`，把方法签名改成常规 `func ...: Future<T>`，并用 `spawn { ... }` + `.get()` 维持时序；禁止回潮到 `Promise<...>`，也严禁把 `transport.connect()` / `createAuthKey()` 改写成同步阻塞假设。',
                    ]
                )
                if has_await:
                    directives.extend(
                        [
                            '[AWAIT IDENTIFIER REGRESSION]',
                            '`await` 在当前链路里不仅不能作为关键字，也不能作为 helper / method / field / local / callsite 标识符。`public func await()`、`awaitResult()`、`waiter.await()` 这类命名都会被静态墙拦截。',
                            '[ESCAPE HATCH FOR await identifier]',
                            '若需要 waiter/helper，请改用不含 `await` 的名字，例如 `takeResult()`、`drainResult()`、`pollReady()`、`readResult()`；只有真实 `Future<T>` 值才允许 `.get()`。',
                        ]
                    )
            else:
                directives.extend(
                    [
                        '[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]',
                        '`async` 是 ArkTS / TypeScript 风格回潮词。仓颉当前这条验证链路不会接受你把 Service 方法继续写成 `async`；注释说明、语义解释或换行排版都骗不过扫描器。',
                        '[ESCAPE HATCH FOR async]',
                        '请物理删除 `async` 关键字，优先回到当前项目已验证的同步写法；若确实需要并发，只能使用 `spawn { ... }` 或已验证的仓颉并发原语，并把复杂逻辑提取成 helper。',
                        '[ANTI-OSCILLATION ANCHOR]',
                        '修 async 时，严禁顺手把 `std.unsafe.*`、`InputPeer/createInputPeer`、`sendRequest(...)` 或多行闭包逻辑带回 Service 层。继续坚守 Zero-Block Rule 与 Helper Extraction。',
                    ]
                )
        if not directives:
            return '当前无额外动态 repair 指令。'
        return '\n'.join(directives)


    def _build_architecture_focus_terms(self, repair_guidance: Optional[Sequence[str]] = None) -> List[str]:
        terms = [
            "compile",
            "compiler",
            "syntax",
            "null",
            "option",
            "match",
            "hashmap",
            "named arguments",
            "named argument",
            "optional chaining",
            "atomic",
            "coalescing",
            "number suffix",
            "0l",
            "0u",
            "0ul",
            "arraylist",
            "import ... from",
            "import package_name.*",
            "int64(0)",
            "uint32(0)",
            "lambda",
            "closure",
            "match expression",
            "case _ => {",
            "case some(",
            "=> {",
            "helper",
            "helper extraction",
            "zero-block",
            "match-helper",
            "regression",
            "firewall",
            "static-blacklist-failed",
            "static blacklist",
            "std.unsafe",
            "import std.unsafe.*",
            "unsafe",
            "can not find package",
            "fake package import",
            "ohos.*",
            "tlmethods",
            "tlserialization",
            "tldialogs",
            "arch_match_zero_block_violation",
            "arch_match_helper_violation",
            "tluser",
            "tlchannel",
            "inputpeer",
            "createinputpeer",
            "sendrequest",
            "reentrantlock",
            "reentrantmutex",
            "async",
            "protocolcontext",
            "signalpipe",
            "valuesignal",
            "hashmap[",
            "constructor",
            "init",
            "array",
            "append",
            "datetime",
            "std.time",
            "randomid",
            "time import",
            "tomilliseconds",
            "milliseconds",
            "nanosecond",
            "uninitialized member variable",
            "constructor of class or struct",
            "public struct",
            "public init",
            "domain model",
            "domainuser",
            "domainchannel",
            "domainmessage",
        ]
        raw_guidance = " ".join(str(item) for item in (repair_guidance or []) if str(item))
        dynamic_terms = re.findall(r"[a-z][a-z0-9_\-]{3,}", raw_guidance.lower())
        terms.extend(dynamic_terms)
        return list(dict.fromkeys(terms))

    def _clip_architecture_skill(self, text: str, limit: int) -> str:
        compact = text.strip()
        if len(compact) <= limit:
            return compact
        return compact[: limit - 3] + "..."

    def _prepare_pattern_examples(self, pattern_examples: object, limit: int) -> List[Dict[str, object]]:
        if not isinstance(pattern_examples, list) or not pattern_examples or limit <= 0:
            return []
        prepared: List[Dict[str, object]] = []
        for item in pattern_examples:
            if not isinstance(item, dict):
                continue
            if not self._pattern_example_is_safe(item):
                continue
            prepared.append(item)
            if len(prepared) >= limit:
                break
        return prepared

    def _pattern_example_is_safe(self, item: Dict[str, object]) -> bool:
        excerpt = str(item.get("generated_code_excerpt", ""))
        if not excerpt.strip():
            return False
        if "${" in excerpt:
            return False
        lowered = excerpt.lower()
        banned_literals = (
            "# mock translator artifact",
            "mock mode does not emit real .cj business code",
            "case _ => {",
            "std.unsafe",
            "inputpeer",
            "createinputpeer",
            "sendrequest",
            "reentrantlock",
            "reentrantmutex",
            "async",
            "protocolcontext",
            "signalpipe",
            "valuesignal",
            "signal<",
            "observable",
            "arraylist",
            "atomic<",
            "ohos.",
            "export class",
            "implements",
            "extends",
            "hashmap[",
            "constructor(",
            ".append(",
            "tomilliseconds",
            "milliseconds",
        )
        if any(token in lowered for token in banned_literals):
            return False
        if re.search(r"case\s+Some\([^)]*\)\s*=>\s*\{", excerpt):
            return False
        if re.search(r"\b(?:0L|0U|0UL)\b", excerpt):
            return False
        if re.search(r"\bTL[A-Z]\w*\b", excerpt):
            return False
        if re.search(r"\+\s*\[", excerpt):
            return False
        return True

    def _build_pattern_examples(self, pattern_examples: object) -> str:
        if not isinstance(pattern_examples, list) or not pattern_examples:
            return "当前暂无可复用 Pattern Memory。"
        chunks: List[str] = []
        for index, item in enumerate(pattern_examples[:3], start=1):
            if not isinstance(item, dict):
                continue
            signatures = item.get("target_signatures", []) if isinstance(item.get("target_signatures", []), list) else []
            rendered_signatures = render_signature_bundle(
                signatures,
                source_path=str(item.get("target_path", f"pattern-{index}")),
                include_source_comment=False,
            )
            chunks.append(
                "\n".join(
                    [
                        f"[Pattern {index}] id={item.get('pattern_id', '')} score={item.get('score', 0)}",
                        f"role={item.get('target_role', '')}",
                        f"constraints={', '.join(str(v) for v in item.get('declared_constraints', []) if str(v)) or 'none'}",
                        f"dependency_roles={', '.join(str(v) for v in item.get('dependency_roles', []) if str(v)) or 'none'}",
                        "signatures:",
                        rendered_signatures or "// 无可用签名",
                        "generated_code_excerpt:",
                        clip_text(str(item.get("generated_code_excerpt", "")), 800) or "",
                        f"notes={'; '.join(str(v) for v in item.get('notes', []) if str(v)) or 'none'}",
                    ]
                )
            )
        if not chunks:
            return "当前暂无可复用 Pattern Memory。"
        return "\n\n---\n\n".join(chunks)

    def _render_translator_tu_context(self, tu: Dict[str, object]) -> str:
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        dependency_closure = self._get_effective_dependency_closure(tu)
        sanitized_target_source = self._get_effective_target_source(tu)
        effective_target_signatures = self._get_effective_target_signatures(tu)
        target_summary_lines = [
            f"tu_id: {tu.get('tu_id', '')}",
            f"target.path: {target.get('path', '')}",
            f"target.role: {target.get('role', '')}",
            f"target.summary: {self._get_effective_target_summary(tu)}",
            f"target.risk_tags: {format_list_inline(target.get('risk_tags', []))}",
            f"target.state_tags: {format_list_inline(target.get('state_tags', []))}",
            f"target.thread_tags: {format_list_inline(target.get('thread_tags', []))}",
            f"target.interop_tags: {format_list_inline(target.get('interop_tags', []))}",
        ]
        target_signatures = render_signature_bundle(
            effective_target_signatures,
            source_path=str(target.get("path", "target")),
            include_source_comment=False,
        )
        dependency_blocks: List[str] = []
        for item in dependency_closure:
            if not isinstance(item, dict):
                continue
            dependency_blocks.append(render_dependency_entry(item))
        return "\n\n".join(
            [
                "[TU Summary]",
                "\n".join(target_summary_lines),
                "[Target Signatures - d.ts Style]",
                target_signatures or "// 无可用目标签名",
                "[Target Source]",
                sanitized_target_source,
                "[Dependency Closure - d.ts Style]",
                "\n\n".join(dependency_blocks)
                if dependency_blocks
                else ("当前 chunk 无需额外依赖闭包。" if self._is_mtprotoclient_trivial_callback_chunk(tu) else "当前无依赖闭包。"),
            ]
        )

    def _get_effective_target_summary(self, tu: Dict[str, object]) -> str:
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        if self._is_mtprotoclient_chunk(tu, "chunk-a"):
            return "仅翻译 MTProtoClient 的 state skeleton：imports、RPCCallback、类头和字段骨架；不要提前展开任何方法实现。"
        if self._is_mtprotoclient_trivial_callback_chunk(tu):
            return "仅翻译 MTProtoClient.setUpdateCallback(callback) 这个同步 setter；输出必须是可插入类体的成员片段。"
        return str(target.get("summary", ""))

    def _get_effective_target_source(self, tu: Dict[str, object]) -> str:
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        sanitized = sanitize_source_for_prompt(str(target.get("source", "")))
        if self._is_mtprotoclient_chunk(tu, "chunk-a"):
            return self._build_mtprotoclient_chunk_a_source_excerpt(sanitized)
        if self._is_phase06_ui_target(tu) and self._phase06_ui_source_is_native_cangjie(tu):
            return self._build_phase06_ui_translator_source_excerpt(tu, sanitized)
        return sanitized

    def _build_phase06_ui_translator_source_excerpt(self, tu: Dict[str, object], source_text: str) -> str:
        if not source_text.strip():
            return ""
        if len(source_text) <= 6000:
            return source_text

        header_excerpt = self._extract_phase06_ui_translator_header_excerpt(source_text)
        leading_type_excerpt = self._extract_phase06_ui_translator_leading_type_excerpt(source_text)
        primary_method_excerpt = self._extract_phase06_ui_translator_primary_method_excerpt(tu, source_text)
        anchor_excerpt = self._extract_phase06_ui_translator_anchor_excerpt(tu, source_text)
        parts = [part for part in [header_excerpt] if part]
        parts.append(
            f"// source excerpt truncated for large Phase06 UI target: original_chars={len(source_text)}; rely on source-backed heads/signatures for omitted details."
        )
        if leading_type_excerpt:
            parts.append("// source-backed leading type excerpt")
            parts.append(leading_type_excerpt)
        if primary_method_excerpt and primary_method_excerpt not in leading_type_excerpt:
            parts.append("// source-backed primary method excerpt")
            parts.append(primary_method_excerpt)
        if anchor_excerpt and anchor_excerpt not in leading_type_excerpt:
            parts.append("// source-backed role anchor excerpt")
            parts.append(anchor_excerpt)
        return "\n\n".join(part for part in parts if part.strip())

    def _extract_phase06_ui_translator_header_excerpt(self, source_text: str) -> str:
        lines = source_text.splitlines()
        header_lines: List[str] = []
        started = False
        for line in lines:
            stripped = line.strip()
            if not stripped and not started:
                continue
            if stripped.startswith("package ") or stripped.startswith("import ") or stripped.startswith("from "):
                started = True
                header_lines.append(line)
                continue
            if not stripped and started:
                header_lines.append(line)
                continue
            if started:
                break
        return clip_text("\n".join(header_lines).strip(), 1200)

    def _extract_phase06_ui_translator_leading_type_excerpt(self, source_text: str) -> str:
        match = re.search(
            r"^\s*(?:public\s+)?(?:class|struct|interface|enum|object)\s+([A-Za-z_]\w*)",
            source_text,
            re.MULTILINE,
        )
        if not match:
            return ""
        type_name = match.group(1).strip()
        excerpt_lines: List[str] = []
        constructor_active = False
        constructor_balance = 0
        for index, line in enumerate(source_text[match.start() :].splitlines()):
            stripped = line.strip()
            if index == 0:
                excerpt_lines.append(line)
                continue
            if not stripped:
                if excerpt_lines and excerpt_lines[-1].strip():
                    excerpt_lines.append(line)
                continue
            if constructor_active:
                excerpt_lines.append(line)
                constructor_balance += line.count("(") - line.count(")")
                if constructor_balance <= 0 and "{" in line:
                    constructor_active = False
                continue
            if re.match(
                rf"^(?:(?:public|protected|private|internal|open|override|sealed|abstract)\s+)?{re.escape(type_name)}\s*\(",
                stripped,
            ):
                excerpt_lines.append(line)
                constructor_balance = line.count("(") - line.count(")")
                constructor_active = constructor_balance > 0 or "{" not in line
                continue
            if re.match(
                r"^(?:(?:public|protected|private|internal|open|override|sealed|abstract)\s+)?func\b",
                stripped,
            ):
                break
            excerpt_lines.append(line)
            if len("\n".join(excerpt_lines)) >= 1400:
                break
        return clip_text("\n".join(excerpt_lines).strip(), 1400)

    def _extract_phase06_ui_translator_primary_method_excerpt(self, tu: Dict[str, object], source_text: str) -> str:
        candidate_heads = self._phase06_ui_source_member_method_heads(tu) + self._phase06_ui_source_public_method_heads(tu)
        seen = set()
        for head in candidate_heads:
            name_match = re.search(r"\bfunc\s+([A-Za-z_]\w*)\b", head)
            if not name_match:
                continue
            name = name_match.group(1).strip()
            if not name or name in seen or re.match(r"^helper\d*$", name):
                continue
            seen.add(name)
            match = re.search(
                rf"^\s*(?:(?:public|protected|private|internal|open|override|sealed|abstract)\s+)?func\s+{re.escape(name)}\s*\(",
                source_text,
                re.MULTILINE,
            )
            if match:
                return clip_text(source_text[match.start() :].strip(), 2600)
        return ""

    def _extract_phase06_ui_translator_anchor_excerpt(self, tu: Dict[str, object], source_text: str) -> str:
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        anchor_index = -1
        if role == "component":
            anchor_index = source_text.rfind("@Component")
        elif role == "page":
            anchor_index = source_text.rfind("@Entry")
            if anchor_index < 0:
                anchor_index = source_text.rfind("@Component")
        elif role == "viewmodel":
            anchor_index = source_text.rfind("class ")
            if anchor_index < 0:
                anchor_index = source_text.rfind("struct ")
        if anchor_index < 0:
            anchor_index = max(0, len(source_text) - 4200)
        start = max(0, anchor_index)
        return clip_text(source_text[start:].strip(), 4200)

    def _build_mtprotoclient_chunk_a_source_excerpt(self, source_text: str) -> str:
        if not source_text.strip():
            return ""

        rpc_field_prefixes = ("resolve:", "reject:", "timeoutId:", "constructor(")
        client_field_prefixes = (
            "private transportManager:",
            "private session:",
            "private pendingRPCs:",
            "private updateCallback:",
            "private connectionInitialized:",
        )
        lines: List[str] = []
        in_rpcallback = False
        in_client = False

        for raw_line in source_text.splitlines():
            stripped = raw_line.strip()
            if not stripped or stripped.startswith("import "):
                continue
            if stripped == "class RPCCallback {":
                lines.append(stripped)
                in_rpcallback = True
                in_client = False
                continue
            if stripped.startswith("export class MTProtoClient"):
                lines.append(stripped)
                in_client = True
                in_rpcallback = False
                continue
            if in_rpcallback:
                if stripped.startswith(rpc_field_prefixes):
                    lines.append(stripped)
                    continue
                if stripped == "}":
                    lines.append("}")
                    in_rpcallback = False
                continue
            if in_client and stripped.startswith(client_field_prefixes):
                compact = re.sub(r"\s*=\s*new Map\(\)", "", stripped)
                compact = re.sub(r"\s*=\s*null", "", compact)
                compact = re.sub(r"\s*=\s*false", "", compact)
                lines.append(compact)

        if not lines:
            return source_text
        return "\n".join(lines)

    def _get_effective_dependency_closure(self, tu: Dict[str, object]) -> List[Dict[str, object]]:
        dependency_closure = tu.get("dependency_closure", []) if isinstance(tu.get("dependency_closure"), list) else []
        if self._is_mtprotoclient_chunk(tu, "chunk-a"):
            return self._build_mtprotoclient_chunk_a_dependency_closure(dependency_closure)
        if self._is_mtprotoclient_trivial_callback_chunk(tu):
            return []
        return [item for item in dependency_closure if isinstance(item, dict)]

    def _build_mtprotoclient_chunk_a_dependency_closure(
        self,
        dependency_closure: Sequence[object],
    ) -> List[Dict[str, object]]:
        desired_entries = [
            (
                "src/core/mtproto/MTProtoConfig.ets",
                {"SessionInfo"},
                [
                    {
                        "kind": "interface",
                        "name": "SessionInfo",
                        "signature": "interface SessionInfo",
                        "summary": "interface",
                    }
                ],
                "仅保留 Chunk A 字段骨架所需的 SessionInfo 声明。",
            ),
            (
                "src/core/mtproto/MTProtoTransport.ets",
                {"TransportCallback", "TransportManager"},
                [
                    {
                        "kind": "interface",
                        "name": "TransportCallback",
                        "signature": "interface TransportCallback",
                        "summary": "interface",
                    },
                    {
                        "kind": "class",
                        "name": "TransportManager",
                        "signature": "class TransportManager",
                        "summary": "class",
                    },
                ],
                "仅保留 Chunk A 类头与字段所需的 transport 类型名。",
            ),
        ]
        rendered_entries: List[Dict[str, object]] = []
        for path, allowed_names, fallback_signatures, fallback_summary in desired_entries:
            existing = next(
                (
                    item for item in dependency_closure
                    if isinstance(item, dict) and str(item.get("path", "")) == path
                ),
                None,
            )
            signatures = []
            if isinstance(existing, dict):
                raw_signatures = existing.get("signatures", [])
                if isinstance(raw_signatures, list):
                    signatures = [
                        item
                        for item in raw_signatures
                        if isinstance(item, dict) and str(item.get("name", "")).strip() in allowed_names
                    ]
            rendered_entries.append(
                {
                    "path": path,
                    "role": str((existing or {}).get("role", "")).strip() or "module",
                    "depth": int((existing or {}).get("depth", 1) or 1),
                    "summary": fallback_summary,
                    "reasons": (existing or {}).get("reasons", []) if isinstance((existing or {}).get("reasons", []), list) else [],
                    "signatures": signatures or fallback_signatures,
                }
            )
        return rendered_entries

    def _build_reviewer_tu_payload(self, tu: Dict[str, object]) -> Dict[str, object]:
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        signatures = self._get_effective_target_signatures(tu)
        sanitized_source = sanitize_source_for_prompt(str(target.get("source", "")))
        clipped_source = clip_text(sanitized_source, limit=1600)
        ui_public_method_heads = self._phase06_ui_source_public_method_heads(tu)
        ui_listener_method_heads = self._phase06_ui_source_listener_method_heads(tu)
        ui_member_method_heads = self._phase06_ui_source_member_method_heads(tu)
        ui_publish_field_heads = self._phase06_ui_source_publish_field_heads(tu)
        ui_uninitialized_field_heads = self._phase06_ui_source_uninitialized_field_heads(tu)
        return {
            "tu_id": tu.get("tu_id", ""),
            "target": {
                "path": target.get("path", ""),
                "role": target.get("role", ""),
                "summary": target.get("summary", ""),
                "risk_tags": target.get("risk_tags", []),
                "state_tags": target.get("state_tags", []),
                "thread_tags": target.get("thread_tags", []),
                "interop_tags": target.get("interop_tags", []),
                "public_surface_symbols": self._collect_source_alignment_public_symbols(tu, signatures=signatures),
                "signatures": signatures,
                "source_excerpt": clipped_source,
                "source_excerpt_is_truncated": len(sanitized_source) > len(clipped_source),
                "source_backed_public_method_heads": ui_public_method_heads,
                "source_backed_listener_method_heads": ui_listener_method_heads,
                "source_backed_build_head": self._phase06_ui_source_build_head(tu),
                "source_backed_member_method_heads": ui_member_method_heads,
                "source_backed_publish_field_heads": ui_publish_field_heads,
                "source_backed_invocation_patterns": self._phase06_ui_source_invocation_patterns(tu),
                "source_backed_package_local_helper_heads": self._phase06_ui_same_package_helper_heads(tu),
                "source_backed_uninitialized_field_heads": ui_uninitialized_field_heads,
            },
            "dependency_count": len(tu.get("dependency_closure", [])) if isinstance(tu.get("dependency_closure", []), list) else 0,
        }


def extract_markdown_section(markdown_text: str, title: str) -> str:
    pattern = re.compile(rf"^#{{1,6}}\s+{re.escape(title)}\s*$", re.MULTILINE)
    match = pattern.search(markdown_text)
    if match is None:
        return ""
    start = match.start()
    next_match = re.search(r"^#{1,6}\s+.+$", markdown_text[match.end() :], re.MULTILINE)
    if next_match is None:
        return markdown_text[start:].strip()
    end = match.end() + next_match.start()
    return markdown_text[start:end].strip()


def format_list_inline(value: object) -> str:
    if not isinstance(value, list):
        return "[]"
    items = [str(item) for item in value if str(item)]
    return "[" + ", ".join(items) + "]" if items else "[]"


def join_unique_lines(lines: Sequence[str]) -> str:
    ordered: List[str] = []
    seen = set()
    for line in lines:
        compact = str(line).strip()
        if not compact or compact in seen:
            continue
        seen.add(compact)
        ordered.append(compact)
    return "\n".join(ordered)


def sanitize_source_for_prompt(source_text: str) -> str:
    if not source_text.strip():
        return ""
    stripped = ARKTS_BLOCK_COMMENT_RE.sub("", source_text)
    stripped = ARKTS_LINE_COMMENT_RE.sub("", stripped)
    stripped = re.sub(r"[ \t]+\n", "\n", stripped)
    stripped = re.sub(r"\n[ \t]+\n", "\n\n", stripped)
    stripped = re.sub(r"\n{3,}", "\n\n", stripped)
    return stripped.strip()


def clip_text(text: str, limit: int) -> str:
    compact = text.strip()
    if len(compact) <= limit:
        return compact
    return compact[: limit - 3] + "..."


def render_dependency_entry(entry: Dict[str, object]) -> str:
    path = str(entry.get("path", ""))
    summary = str(entry.get("summary", ""))
    role = str(entry.get("role", ""))
    depth = entry.get("depth", 0)
    reasons = entry.get("reasons", []) if isinstance(entry.get("reasons", []), list) else []
    signatures = entry.get("signatures", []) if isinstance(entry.get("signatures", []), list) else []
    header_lines = [
        f"// 来源: {path}",
        f"// 角色: {role} | 深度: {depth}",
        f"// 摘要: {summary}",
    ]
    reason_text = render_reason_summary(reasons)
    if reason_text:
        header_lines.append(f"// 依赖原因: {reason_text}")
    signature_block = render_signature_bundle(signatures, source_path=path, include_source_comment=False)
    return "\n".join(header_lines + [signature_block or "// 无可用签名"])


def render_reason_summary(reasons: Sequence[object]) -> str:
    parts: List[str] = []
    for item in reasons[:6]:
        if not isinstance(item, dict):
            continue
        edge_type = str(item.get("edge_type", "")).strip()
        symbol_name = str(item.get("symbol_name", "")).strip()
        if edge_type and symbol_name:
            parts.append(f"{edge_type}:{symbol_name}")
        elif edge_type:
            parts.append(edge_type)
    return "; ".join(parts)


def render_signature_bundle(
    signatures: object,
    *,
    source_path: str,
    include_source_comment: bool,
) -> str:
    if not isinstance(signatures, list) or not signatures:
        return ""
    normalized = [normalize_signature_item(item) for item in signatures if isinstance(item, dict)]
    normalized = [item for item in normalized if item]
    if not normalized:
        return ""
    containers: List[Dict[str, object]] = []
    top_level: List[Dict[str, object]] = []
    methods_by_parent: Dict[Tuple[str, str], List[Dict[str, object]]] = {}
    for item in sorted(normalized, key=lambda row: (int(row.get("start_line", 0)), kind_rank(str(row.get("kind", ""))), str(row.get("name", "")))):
        kind = str(item.get("kind", ""))
        if kind in {"class", "interface"}:
            containers.append(item)
            continue
        if kind == "method":
            parent_name = str(item.get("parent_name", ""))
            parent_kind = str(item.get("parent_kind", ""))
            if parent_name and parent_kind in {"class", "interface"}:
                methods_by_parent.setdefault((parent_kind, parent_name), []).append(item)
                continue
        top_level.append(item)

    lines: List[str] = []
    if include_source_comment and source_path:
        lines.append(f"// 来源: {source_path}")
    for container in containers:
        rendered = render_container_signature(container, methods_by_parent.get((str(container.get("kind", "")), str(container.get("name", ""))), []))
        if rendered:
            lines.append(rendered)
    for item in top_level:
        rendered = render_top_level_signature(item)
        if rendered:
            lines.append(rendered)
    return "\n\n".join(lines)


def normalize_signature_item(item: Dict[str, object]) -> Dict[str, object]:
    return {
        "kind": str(item.get("kind", "")),
        "name": str(item.get("name", "")),
        "signature": str(item.get("signature", "")),
        "summary": str(item.get("summary", "")),
        "start_line": int(item.get("start_line", 0) or 0),
        "end_line": int(item.get("end_line", 0) or 0),
        "role": str(item.get("role", "")),
        "parent_name": str(item.get("parent_name", "")),
        "parent_kind": str(item.get("parent_kind", "")),
    }


def render_container_signature(container: Dict[str, object], child_methods: Sequence[Dict[str, object]]) -> str:
    head = extract_declaration_head(str(container.get("signature", "")))
    kind = str(container.get("kind", "")).strip() or "class"
    name = str(container.get("name", "")).strip() or "Anonymous"
    if not head:
        head = f"{kind} {name}"
    head = strip_common_modifiers(head)
    if not head.startswith(("class ", "interface ")):
        head = f"{kind} {name}"
    if child_methods:
        lines = [f"declare {head} {{"]
        for method in sorted(child_methods, key=lambda row: (int(row.get("start_line", 0)), str(row.get("name", "")))):
            rendered = render_method_signature(method)
            if rendered:
                lines.append(f"  {rendered}")
        lines.append("}")
        return "\n".join(lines)
    return f"declare {head};"


def render_top_level_signature(item: Dict[str, object]) -> str:
    kind = str(item.get("kind", "")).strip()
    if kind == "function":
        return render_function_signature(item)
    if kind == "method":
        return render_method_signature(item)
    if kind in {"class", "interface"}:
        return render_container_signature(item, [])
    return ""


def render_function_signature(item: Dict[str, object]) -> str:
    name = str(item.get("name", "")).strip() or "anonymous"
    head = extract_declaration_head(str(item.get("signature", "")))
    head = strip_common_modifiers(head)
    if not head:
        return f"declare function {name}(...args: unknown[]): unknown;"
    if head.startswith("function "):
        return f"declare {head.rstrip(';')};"
    if head.startswith(("const ", "let ", "var ")):
        return f"declare {head.rstrip(';')};"
    if "=>" in head:
        return f"declare const {name}: {head};"
    if name in head and "(" in head:
        return f"declare function {head.rstrip(';')};"
    return f"declare function {name}(...args: unknown[]): unknown;"


def render_method_signature(item: Dict[str, object]) -> str:
    name = str(item.get("name", "")).strip() or "anonymous"
    head = extract_declaration_head(str(item.get("signature", "")))
    head = strip_common_modifiers(head, keep_visibility=True)
    if not head:
        return f"{name}(...args: unknown[]): unknown;"
    if head.startswith("function "):
        head = head[len("function ") :].strip()
    return head.rstrip(" ;") + ";"


def extract_declaration_head(signature: str) -> str:
    compact = re.sub(r"\s+", " ", signature).strip()
    if not compact:
        return ""
    if "{" in compact:
        compact = compact.split("{", 1)[0].strip()
    compact = compact.rstrip()
    while compact.endswith(("=", ":")):
        compact = compact[:-1].rstrip()
    return compact


def strip_common_modifiers(head: str, *, keep_visibility: bool = False) -> str:
    compact = re.sub(r"\s+", " ", head).strip()
    compact = re.sub(r"^(?:export\s+)+", "", compact)
    compact = re.sub(r"^(?:default\s+)+", "", compact)
    compact = re.sub(r"\basync\s+", "", compact)
    if not keep_visibility:
        compact = re.sub(r"^(?:public|private|protected|readonly|declare|abstract|override|static)\s+", "", compact)
    else:
        compact = re.sub(r"^(?:declare|abstract|override)\s+", "", compact)
        compact = re.sub(r"\basync\s+", "", compact)
    return compact.strip()


def kind_rank(kind: str) -> int:
    if kind == "class":
        return 0
    if kind == "interface":
        return 1
    if kind == "function":
        return 2
    if kind == "method":
        return 3
    return 9
