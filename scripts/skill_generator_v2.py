#!/usr/bin/env python3
"""V2 Skill 生成器。

功能：
1. 读取 Markdown / HTML 源文档。
2. 使用硬编码的“压缩版 V2 Schema 骨架”组装 Prompt，而不是把 `SKILL_SCHEMA_V2.md` 全文注入模型。
3. 调用 OpenAI 兼容的 Chat Completions API，或读取本地 mock 输出。
4. 对返回结果做结构校验、内容约束校验，并在失败时自动发起修复重试。
5. 将最终结果保存到 `skills/` 目录。

说明：
- 脚本仅使用 Python 标准库，可直接运行。
- 若未配置 `OPENAI_API_KEY`，可用 `--mock-output-file` 走通离线流程。
- 默认使用 OpenAI 兼容接口：`OPENAI_BASE_URL/chat/completions`。
- `--schema` 参数仅保留兼容性检查，不再把 Schema 全文注入 Prompt。
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import textwrap
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from html.parser import HTMLParser
from pathlib import Path
from typing import List, Optional, Sequence

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SCHEMA_PATH = PROJECT_ROOT / "skills" / "SKILL_SCHEMA_V2.md"
DEFAULT_OUTPUT_DIR = PROJECT_ROOT / "skills"
DEFAULT_MODEL = "claude-3"
DEFAULT_SYSTEM_PROMPT = textwrap.dedent(
    """
    你是一个面向 HarmonyOS ArkTS → 仓颉架构迁移的 Skill 生成器。
    你不是聊天助手，不要解释过程，不要写前言，不要写 JSON，不要写围栏外说明。
    你只能输出完整 Markdown 正文，且必须从 `# Skill Metadata` 开始。
    绝对禁止输出以下占位内容：`...`、`…`、`略`、`待补充`、`TBD`、`同上`、`自行处理`。
    如果信息不足，必须写入 `# Known Gaps`，不能省略章节，不能编造事实。
    对 Architecture 类 Skill，必须优先保证 Architecture Mapping、Boundary Contract、Execution Topology、State Contract、Performance Envelope 的丰满度。
    """
).strip()

REQUIRED_V2_HEADERS = [
    "# Skill Metadata",
    "# Trigger Condition",
    "# Core Concept",
    "# Architecture Mapping",
    "# Dependency Constraint",
    "# Boundary Contract",
    "# Execution Topology",
    "# State Contract",
    "# Progressive Modules",
    "# Translation Mapping",
    "# Performance Envelope",
    "# Failure Model",
    "# Verification Matrix",
    "# Composition With Other Skills",
    "# Retrieval Fallback",
    "# Security / Privacy Constraint",
    "# Migration Strategy",
    "# Examples",
    "# Test & Debug",
    "# Sources",
    "# Known Gaps",
    "# Evolution Log",
]

SECTION_RULES = [
    {
        "header": "# Skill Metadata",
        "constraint": "写清 Skill ID、Skill Name、Skill Class、Scope、Tags、Version 六项；不要留空。",
        "keywords": ["Skill ID", "Skill Name", "Skill Class", "Scope", "Tags", "Version"],
    },
    {
        "header": "# Trigger Condition",
        "constraint": "写任务触发条件、强制触发条件、不适用条件；触发词要具体到 ArkTS 迹象。",
        "keywords": ["任务触发条件", "强制触发条件", "不适用条件"],
    },
    {
        "header": "# Core Concept",
        "constraint": "用最短原则压缩结论，并给出一句致命风险提示。",
        "keywords": ["最短知识结论", "一句话风险提示"],
    },
    {
        "header": "# Architecture Mapping",
        "constraint": "写源侧角色、目标侧角色、保留策略、重构策略；不要退化成 API 列表。",
        "keywords": ["源侧角色", "目标侧角色", "保留策略", "重构策略"],
    },
    {
        "header": "# Dependency Constraint",
        "constraint": "写必需依赖、可选依赖、冲突依赖、环境前提；前提缺失时必须明确降级。",
        "keywords": ["必需依赖", "可选依赖", "冲突依赖", "环境前提"],
    },
    {
        "header": "# Boundary Contract",
        "constraint": "写边界类型、输入、输出、生命周期归属、资源释放责任、错误传递方式。",
        "keywords": ["边界类型", "输入", "输出", "生命周期归属", "资源释放责任", "错误传递方式"],
    },
    {
        "header": "# Execution Topology",
        "constraint": "明确线程模型、主线程提交点、后台处理点、串行要求、批处理要求。",
        "keywords": ["线程模型", "主线程提交点", "后台处理点", "串行要求", "批处理要求"],
    },
    {
        "header": "# State Contract",
        "constraint": "明确状态所有者、真值来源、可变字段、衍生字段、持久化策略、一致性规则。",
        "keywords": ["状态所有者", "真值来源", "可变字段", "衍生字段", "持久化策略", "一致性规则"],
    },
    {
        "header": "# Progressive Modules",
        "constraint": "必须包含 Module 1 到 Module 4，且层层递进到工程约束。",
        "keywords": ["## Module 1：概念最小版", "## Module 2：常见映射", "## Module 3：跨层模式", "## Module 4：工程级约束"],
    },
    {
        "header": "# Translation Mapping",
        "constraint": "写 ArkTS 对应写法、仓颉对应写法、允许差异、禁止直译点。",
        "keywords": ["ArkTS 对应写法", "仓颉对应写法", "允许差异", "禁止直译点"],
    },
    {
        "header": "# Performance Envelope",
        "constraint": "写主线程预算、吞吐量关注点、内存关注点、建议优化手段。",
        "keywords": ["主线程预算", "吞吐量关注点", "内存关注点", "建议优化手段"],
    },
    {
        "header": "# Failure Model",
        "constraint": "列出典型失败路径、触发迹象、恢复策略与禁止修复方式。",
        "keywords": ["失败场景", "触发迹象", "恢复策略", "禁止修复方式"],
    },
    {
        "header": "# Verification Matrix",
        "constraint": "按用例、输入、预期、验证层次组织；不能只写一句‘编译通过’。",
        "keywords": ["验证目标", "输入条件", "预期结果", "验证层次"],
    },
    {
        "header": "# Composition With Other Skills",
        "constraint": "明确上游 Skill、下游 Skill、组合顺序、误用风险。",
        "keywords": ["上游 Skill", "下游 Skill", "组合顺序", "误用风险"],
    },
    {
        "header": "# Retrieval Fallback",
        "constraint": "提供 CLI / Python 检索入口，优先使用仓库内可执行方式，如 `rg -n` 与 `python scripts/skill_generator_v2.py --source ... --skill-name ... --skill-class ...`；不要编造 CLI、假参数或 Python 包。",
        "keywords": ["CLI / Python 检索示例", "官方资料回查入口", "降级策略", "rg -n", "python scripts/skill_generator_v2.py", "--source", "--skill-name", "--skill-class"],
    },
    {
        "header": "# Security / Privacy Constraint",
        "constraint": "说明线程安全、数据最小暴露、敏感状态边界或消息泄露风险。",
        "keywords": ["数据暴露边界", "线程安全约束", "隐私或敏感信息注意事项"],
    },
    {
        "header": "# Migration Strategy",
        "constraint": "说明最小迁移路径、过渡层、替换顺序与回滚点。",
        "keywords": ["最小迁移路径", "过渡层", "替换顺序", "回滚点"],
    },
    {
        "header": "# Examples",
        "constraint": "只允许放概念性伪代码或结构草图，不要生成完整 `.cj` 业务源码。",
        "keywords": ["概念性示例", "伪代码", "结构草图"],
    },
    {
        "header": "# Test & Debug",
        "constraint": "写单测、集成、线程诊断、日志观测与失败定位建议。",
        "keywords": ["单测策略", "集成验证", "诊断日志", "排错步骤"],
    },
    {
        "header": "# Sources",
        "constraint": "列出本次输入文档与引用来源，不可伪造不存在的外部文档。",
        "keywords": ["输入来源", "引用依据"],
    },
    {
        "header": "# Known Gaps",
        "constraint": "写当前未知项、未确认 API、环境依赖和潜在误差来源。",
        "keywords": ["当前未知", "待验证", "环境限制"],
    },
    {
        "header": "# Evolution Log",
        "constraint": "写本次生成版本、关键改动和后续待补方向。",
        "keywords": ["版本记录", "本次改动", "后续补强方向"],
    },
]

ARCHITECTURE_CRITICAL_HEADERS = {
    "# Architecture Mapping": ["源侧角色", "目标侧角色", "重构策略"],
    "# Boundary Contract": ["边界类型", "输入", "输出", "资源释放责任"],
    "# Execution Topology": ["主线程", "后台", "提交点", "批处理"],
    "# State Contract": ["状态所有者", "真值来源", "一致性规则"],
    "# Performance Envelope": ["主线程预算", "吞吐量关注点", "内存关注点"],
}


@dataclass
class SourceDocument:
    path: Path
    kind: str
    content: str


class HTMLTextExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self._skip_depth = 0
        self._chunks: List[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, Optional[str]]]) -> None:
        if tag.lower() in {"script", "style", "noscript"}:
            self._skip_depth += 1
        elif tag.lower() in {"p", "div", "section", "article", "li", "tr", "h1", "h2", "h3", "h4", "h5", "h6", "br"}:
            self._chunks.append("\n")

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() in {"script", "style", "noscript"} and self._skip_depth > 0:
            self._skip_depth -= 1
        elif tag.lower() in {"p", "div", "section", "article", "li", "tr", "h1", "h2", "h3", "h4", "h5", "h6"}:
            self._chunks.append("\n")

    def handle_data(self, data: str) -> None:
        if self._skip_depth == 0:
            self._chunks.append(data)

    def get_text(self) -> str:
        return "".join(self._chunks)


class SkillGenerationError(RuntimeError):
    pass


@dataclass
class AttemptArtifact:
    attempt: int
    prompt: str
    raw_output: str = ""
    markdown: str = ""
    issues: list[str] | None = None
    error: str = ""


def project_relative(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(PROJECT_ROOT.resolve()))
    except Exception:
        return str(path)


def normalize_whitespace(text: str) -> str:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def read_text_file(path: Path) -> str:
    encodings = ["utf-8", "utf-8-sig", "gb18030", "latin-1"]
    last_error: Optional[Exception] = None
    for encoding in encodings:
        try:
            return path.read_text(encoding=encoding)
        except Exception as exc:
            last_error = exc
    raise SkillGenerationError(f"无法读取文件：{path}；最后错误：{last_error}")


def html_to_text(raw_html: str) -> str:
    parser = HTMLTextExtractor()
    parser.feed(raw_html)
    parser.close()
    return normalize_whitespace(parser.get_text())


def markdown_to_text(raw_markdown: str) -> str:
    return normalize_whitespace(raw_markdown)


def detect_kind(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix in {".md", ".markdown"}:
        return "markdown"
    if suffix in {".html", ".htm"}:
        return "html"
    return "text"


def read_source_document(path: Path) -> SourceDocument:
    if not path.exists():
        raise SkillGenerationError(f"源文件不存在：{path}")
    raw_text = read_text_file(path)
    kind = detect_kind(path)
    content = html_to_text(raw_text) if kind == "html" else markdown_to_text(raw_text)
    return SourceDocument(path=path, kind=kind, content=content)


def limit_text(text: str, max_chars: int) -> str:
    if max_chars <= 0 or len(text) <= max_chars:
        return text
    clipped = text[:max_chars].rstrip()
    return clipped + "\n\n[已根据 max_chars 截断原文，以控制 Prompt 长度]"


def load_source_documents(paths: Sequence[Path], max_chars: int) -> list[SourceDocument]:
    documents: list[SourceDocument] = []
    for path in paths:
        document = read_source_document(path)
        documents.append(
            SourceDocument(
                path=document.path,
                kind=document.kind,
                content=limit_text(document.content, max_chars=max_chars),
            )
        )
    return documents


def ensure_schema_path_exists(schema_path: Path) -> None:
    if not schema_path.exists():
        raise SkillGenerationError(f"Schema 文件不存在：{schema_path}")


def infer_skill_id(skill_name: str, skill_class: str) -> str:
    prefix = {
        "Atomic": "ATOM",
        "Pattern": "PATTERN",
        "Architecture": "ARCH",
    }[skill_class]
    normalized = re.sub(r"[^a-zA-Z0-9]+", "-", skill_name).strip("-")
    return f"{prefix}-{normalized.upper()}-AUTO"


def sanitize_filename(skill_name: str) -> str:
    filename = re.sub(r"[^a-zA-Z0-9._-]+", "-", skill_name.strip().lower())
    filename = re.sub(r"-+", "-", filename).strip("-")
    if not filename:
        raise SkillGenerationError("无法从 skill-name 推导文件名")
    if not filename.endswith(".md"):
        filename += ".md"
    return filename


def ensure_output_in_skills(output_path: Path) -> Path:
    resolved_output = output_path.resolve()
    resolved_skills = DEFAULT_OUTPUT_DIR.resolve()
    try:
        resolved_output.relative_to(resolved_skills)
    except ValueError as exc:
        raise SkillGenerationError(f"输出路径必须位于 skills/ 目录内：{output_path}") from exc
    return resolved_output


def resolve_output_path(output_arg: Optional[str], skill_name: str) -> Path:
    if output_arg:
        candidate = (PROJECT_ROOT / output_arg).resolve() if not Path(output_arg).is_absolute() else Path(output_arg).resolve()
    else:
        candidate = (DEFAULT_OUTPUT_DIR / sanitize_filename(skill_name)).resolve()
    return ensure_output_in_skills(candidate)


def build_compressed_schema_skeleton(skill_class: str) -> str:
    lines: list[str] = []
    lines.append("以下是压缩版 V2 Schema 骨架。它只保留顶级章节、必含小项和每章一条硬约束。")
    lines.append("你必须严格按这个顺序输出，不允许丢章节，不允许改标题。")
    for index, rule in enumerate(SECTION_RULES, start=1):
        lines.append(f"{index}. {rule['header']}")
        lines.append(f"   - 硬约束：{rule['constraint']}")
        lines.append(f"   - 必含小项：{' / '.join(rule['keywords'])}")
        if skill_class == "Architecture" and rule["header"] in ARCHITECTURE_CRITICAL_HEADERS:
            lines.append("   - Architecture 加强要求：本章必须写出系统级角色分工、边界和线程责任，不能退化为组件说明。")
    return "\n".join(lines)


def render_source_documents(source_documents: Sequence[SourceDocument]) -> str:
    blocks: list[str] = []
    for index, document in enumerate(source_documents, start=1):
        blocks.append(
            textwrap.dedent(
                f"""
                ## Source Document {index}
                - Path: `{project_relative(document.path)}`
                - Kind: `{document.kind}`

                ```text
                {document.content}
                ```
                """
            ).strip()
        )
    return "\n\n".join(blocks)


def build_prompt(
    *,
    skill_name: str,
    skill_id: str,
    skill_class: str,
    source_documents: Sequence[SourceDocument],
    extra_instructions: Sequence[str],
    scope_hint: str,
) -> str:
    compressed_schema = build_compressed_schema_skeleton(skill_class)
    joined_documents = render_source_documents(source_documents)
    extra_text = "\n".join(f"- {item}" for item in extra_instructions) if extra_instructions else "- 无额外指令"
    scope_hint_text = scope_hint if scope_hint else "请根据源文档自动提炼 Scope。"

    return textwrap.dedent(
        f"""
        任务：基于输入源材料，生成一个新的 V2 Skill Markdown。

        生成目标：
        - Skill Name: `{skill_name}`
        - Skill ID: `{skill_id}`
        - Skill Class: `{skill_class}`
        - Scope Hint: {scope_hint_text}

        全局硬规则：
        1. 第一行必须是 `# Skill Metadata`。
        2. 必须包含全部 V2 顶级章节，且顺序与骨架完全一致。
        3. 正文必须使用中文。
        4. 绝对禁止使用 `...`、`…`、`略`、`待补充`、`TBD`、`同上`、`自行处理`。
        5. 不要输出前言、道歉、解释说明、JSON 或围栏外闲聊。
        6. 如果信息不足，写到 `# Known Gaps`，不要编造。
        7. `# Examples` 里只允许概念性伪代码或结构草图，绝对不要输出完整 `.cj` 业务源码。
        8. 如果是 Architecture 类 Skill，优先保证 Architecture Mapping、Boundary Contract、Execution Topology、State Contract、Performance Envelope 的深度与约束性。
        9. `# Retrieval Fallback` 中的 CLI / Python 检索示例必须优先使用仓库内可执行方式，例如 `rg -n` 与 `python scripts/skill_generator_v2.py --source ... --skill-name ... --skill-class ...`，不要编造不存在的 CLI、SDK、假参数或 Python 包。
        10. 所有顶级章节都要有实质内容，不能只有一句空话。

        压缩版 Schema 骨架：
        {compressed_schema}

        额外指令：
        {extra_text}

        源材料：
        {joined_documents}

        现在直接输出完整 Skill Markdown 正文。
        """
    ).strip()


def build_repair_prompt(
    *,
    base_prompt: str,
    previous_markdown: str,
    issues: Sequence[str],
    attempt: int,
) -> str:
    issue_text = "\n".join(f"- {item}" for item in issues)
    return textwrap.dedent(
        f"""
        这是第 {attempt} 次修复生成。你上一版输出没有通过本地校验。

        失败原因：
        {issue_text}

        修复规则：
        1. 不要改变 Skill 主题，不要改写成别的知识域。
        2. 必须保留全部 V2 顶级章节和原顺序。
        3. 必须删除任何 `...`、`…`、`略`、`待补充`、`TBD`、`同上`、`自行处理`。
        4. 必须把缺失章节补全，把过薄章节写实。
        5. 仍然只输出 Markdown 正文，且第一行必须是 `# Skill Metadata`。

        原始任务：
        {base_prompt}

        你上一版的输出：
        ```markdown
        {previous_markdown}
        ```

        现在请输出修复后的完整 Markdown。
        """
    ).strip()


def build_transport_retry_prompt(base_prompt: str, error_message: str, attempt: int) -> str:
    return textwrap.dedent(
        f"""
        这是第 {attempt} 次生成尝试。上一轮请求失败，错误摘要如下：
        - {error_message}

        请继续执行同一任务，但保持简洁、守规矩、不要省略正文。

        原始任务：
        {base_prompt}
        """
    ).strip()


def get_response_text(content: object) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: list[str] = []
        for item in content:
            if isinstance(item, dict):
                item_type = item.get("type")
                if item_type == "text":
                    parts.append(str(item.get("text", "")))
                elif "text" in item:
                    parts.append(str(item["text"]))
        return "\n".join(part for part in parts if part)
    return str(content)


def call_llm(
    prompt: str,
    model: str = DEFAULT_MODEL,
    *,
    system_prompt: Optional[str] = None,
    timeout_seconds: int = 180,
) -> str:
    api_key = os.getenv("OPENAI_API_KEY")
    base_url = os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1").rstrip("/")
    resolved_system_prompt = system_prompt or os.getenv("SKILL_GENERATOR_SYSTEM_PROMPT", DEFAULT_SYSTEM_PROMPT)

    if not api_key:
        raise SkillGenerationError("未检测到 OPENAI_API_KEY。请配置 OpenAI 兼容接口，或使用 --mock-output-file 进行离线流程演练。")

    payload = {
        "model": model,
        "temperature": 0.2,
        "messages": [
            {"role": "system", "content": resolved_system_prompt},
            {"role": "user", "content": prompt},
        ],
    }

    request = urllib.request.Request(
        url=f"{base_url}/chat/completions",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=timeout_seconds) as response:
            response_text = response.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise SkillGenerationError(f"LLM 接口返回 HTTP {exc.code}: {body}") from exc
    except urllib.error.URLError as exc:
        raise SkillGenerationError(f"无法连接 LLM 接口：{exc}") from exc
    except TimeoutError as exc:
        raise SkillGenerationError(f"LLM 请求超时：{exc}") from exc

    try:
        payload = json.loads(response_text)
        choice = payload["choices"][0]
        message = choice["message"]
        content = message.get("content", "")
    except (KeyError, IndexError, TypeError, json.JSONDecodeError) as exc:
        raise SkillGenerationError(f"无法解析 LLM 响应：{response_text}") from exc

    text = get_response_text(content).strip()
    if not text:
        raise SkillGenerationError("LLM 返回了空内容")
    return text


def extract_markdown_payload(raw_text: str) -> str:
    fenced_patterns = [
        r"```markdown\n(.*?)\n```",
        r"```md\n(.*?)\n```",
        r"```\n(# Skill Metadata[\s\S]*?)\n```",
    ]
    for pattern in fenced_patterns:
        match = re.search(pattern, raw_text, flags=re.DOTALL)
        if match:
            return normalize_whitespace(match.group(1))

    marker = "# Skill Metadata"
    index = raw_text.find(marker)
    if index >= 0:
        return normalize_whitespace(raw_text[index:])

    return normalize_whitespace(raw_text)


def extract_section_body(markdown: str, header: str) -> str:
    pattern = rf"(?ms)^{re.escape(header)}\n(.*?)(?=^# [^#]|\Z)"
    match = re.search(pattern, markdown)
    if not match:
        return ""
    return match.group(1).strip()


def collect_validation_issues(markdown: str, skill_class: str) -> list[str]:
    issues: list[str] = []
    forbidden_tokens = ["...", "…", "\n略\n", "待补充", "TBD", "同上", "自行处理"]
    for token in forbidden_tokens:
        if token in markdown:
            issues.append(f"检测到非法占位或偷懒表达：{token}")

    if not markdown.startswith("# Skill Metadata"):
        issues.append("生成结果必须以 '# Skill Metadata' 开头")

    missing = [header for header in REQUIRED_V2_HEADERS if header not in markdown]
    if missing:
        issues.append(f"缺少 V2 必填章节：{missing}")

    last_index = -1
    for header in REQUIRED_V2_HEADERS:
        current_index = markdown.find(header)
        if current_index >= 0 and current_index < last_index:
            issues.append(f"章节顺序错误：{header}")
        if current_index >= 0:
            last_index = current_index

    for rule in SECTION_RULES:
        header = rule["header"]
        body = extract_section_body(markdown, header)
        if not body:
            issues.append(f"章节内容为空：{header}")
            continue
        if len(body) < 40:
            issues.append(f"章节内容过短：{header}")
        missing_keywords = [keyword for keyword in rule["keywords"] if keyword not in body and keyword not in markdown]
        if missing_keywords:
            issues.append(f"章节 `{header}` 缺少必含小项：{missing_keywords}")
        if header == "# Retrieval Fallback":
            if "rg -n" not in body:
                issues.append("`# Retrieval Fallback` 必须包含基于 `rg -n` 的仓库内检索命令")
            if "python scripts/skill_generator_v2.py" not in body:
                issues.append("`# Retrieval Fallback` 必须包含基于 `python scripts/skill_generator_v2.py` 的仓库内命令")
            required_python_tokens = ["--source", "--skill-name", "--skill-class"]
            for token in required_python_tokens:
                if token not in body:
                    issues.append(f"`# Retrieval Fallback` 中的 Python 命令缺少必要参数：{token}")
            forbidden_retrieval_tokens = ["harmony-skill", "harmony_skill_api", "pip install", "npm install"]
            for token in forbidden_retrieval_tokens:
                if token in body:
                    issues.append(f"`# Retrieval Fallback` 出现了疑似编造的检索入口：{token}")
            if re.search(r"python scripts/skill_generator_v2\.py\s+--skill(\s|$)", body):
                issues.append("`# Retrieval Fallback` 使用了不存在的 `--skill` 参数，应改为 `--skill-name`")
            if re.search(r"python scripts/skill_generator_v2\.py[^\n]*--analyze", body):
                issues.append("`# Retrieval Fallback` 使用了不存在的 `--analyze` 参数")

    if skill_class == "Architecture":
        for header, keywords in ARCHITECTURE_CRITICAL_HEADERS.items():
            body = extract_section_body(markdown, header)
            matched = [keyword for keyword in keywords if keyword in body]
            if len(matched) < max(2, len(keywords) - 1):
                issues.append(f"Architecture 关键章节不够丰满：{header}；当前缺少关键词覆盖，建议至少覆盖 {keywords}")

    return issues


def validate_v2_markdown(markdown: str, skill_class: str) -> None:
    issues = collect_validation_issues(markdown, skill_class)
    if issues:
        raise SkillGenerationError("；".join(issues))


def write_text(path: Path, content: str, overwrite: bool) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and not overwrite:
        raise SkillGenerationError(f"输出文件已存在，请使用 --overwrite：{path}")
    path.write_text(content + "\n", encoding="utf-8")


def dump_attempt_artifact(base_dir: Path, artifact: AttemptArtifact) -> None:
    base_dir.mkdir(parents=True, exist_ok=True)
    prefix = f"attempt-{artifact.attempt:02d}"
    (base_dir / f"{prefix}.prompt.txt").write_text(artifact.prompt + "\n", encoding="utf-8")
    if artifact.raw_output:
        (base_dir / f"{prefix}.raw.txt").write_text(artifact.raw_output + "\n", encoding="utf-8")
    if artifact.markdown:
        (base_dir / f"{prefix}.markdown.md").write_text(artifact.markdown + "\n", encoding="utf-8")
    if artifact.issues:
        (base_dir / f"{prefix}.issues.txt").write_text("\n".join(artifact.issues) + "\n", encoding="utf-8")
    if artifact.error:
        (base_dir / f"{prefix}.error.txt").write_text(artifact.error + "\n", encoding="utf-8")


def generate_with_retries(
    *,
    base_prompt: str,
    model: str,
    skill_class: str,
    max_attempts: int,
    timeout_seconds: int,
    attempt_dump_dir: Optional[Path],
) -> tuple[str, str]:
    current_prompt = base_prompt
    last_error: Optional[SkillGenerationError] = None
    last_markdown = ""

    for attempt in range(1, max_attempts + 1):
        print(f"[skill_generator_v2] 第 {attempt}/{max_attempts} 次调用模型", file=sys.stderr)
        try:
            raw_output = call_llm(
                prompt=current_prompt,
                model=model,
                timeout_seconds=timeout_seconds,
            )
            markdown = extract_markdown_payload(raw_output)
            issues = collect_validation_issues(markdown, skill_class)
            artifact = AttemptArtifact(
                attempt=attempt,
                prompt=current_prompt,
                raw_output=raw_output,
                markdown=markdown,
                issues=issues,
            )
            if attempt_dump_dir is not None:
                dump_attempt_artifact(attempt_dump_dir, artifact)
            if not issues:
                return raw_output, markdown
            last_error = SkillGenerationError("；".join(issues))
            if attempt >= max_attempts:
                raise last_error
            current_prompt = build_repair_prompt(
                base_prompt=base_prompt,
                previous_markdown=markdown,
                issues=issues,
                attempt=attempt + 1,
            )
            time.sleep(1)
        except SkillGenerationError as exc:
            artifact = AttemptArtifact(
                attempt=attempt,
                prompt=current_prompt,
                error=str(exc),
            )
            if attempt_dump_dir is not None:
                dump_attempt_artifact(attempt_dump_dir, artifact)
            last_error = exc
            if attempt >= max_attempts:
                raise
            current_prompt = build_transport_retry_prompt(
                base_prompt=base_prompt,
                error_message=str(exc),
                attempt=attempt + 1,
            )
            time.sleep(1)

    if last_error is not None:
        raise last_error
    raise SkillGenerationError("未知错误：重试流程未返回结果")


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="根据压缩版 V2 Schema 骨架生成 Skill Markdown")
    parser.add_argument("--source", action="append", required=True, help="输入源文档路径，可重复传入")
    parser.add_argument("--skill-name", required=True, help="目标 Skill 名称，例如 signal-based-reactive-pipeline")
    parser.add_argument("--skill-id", help="目标 Skill ID；若不传则自动推导")
    parser.add_argument(
        "--skill-class",
        choices=["Atomic", "Pattern", "Architecture"],
        required=True,
        help="Skill 粒度类别",
    )
    parser.add_argument("--scope-hint", default="", help="传给 Prompt 的 Scope 提示")
    parser.add_argument("--extra-instruction", action="append", default=[], help="额外 Prompt 约束，可重复传入")
    parser.add_argument("--schema", default=str(DEFAULT_SCHEMA_PATH), help="Schema 文件路径，仅做存在性检查")
    parser.add_argument("--output", help="输出 Markdown 路径；必须位于 skills/ 目录内")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="模型名，默认 claude-3")
    parser.add_argument("--max-source-chars", type=int, default=8000, help="单个源文档最大字符数")
    parser.add_argument("--timeout-seconds", type=int, default=180, help="单次模型请求超时秒数")
    parser.add_argument("--max-attempts", type=int, default=3, help="最大尝试次数，包含自动修复重试")
    parser.add_argument("--dump-prompt-file", help="将首次 Prompt 输出到文件，便于调试")
    parser.add_argument("--dump-attempt-dir", help="将每次尝试的 prompt / raw / issues 落盘到目录")
    parser.add_argument("--mock-output-file", help="跳过 API 调用，直接读取本地 Markdown 作为 LLM 输出")
    parser.add_argument("--overwrite", action="store_true", help="允许覆盖已有输出文件")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)

    source_paths = [
        (PROJECT_ROOT / item).resolve() if not Path(item).is_absolute() else Path(item).resolve()
        for item in args.source
    ]
    schema_path = (PROJECT_ROOT / args.schema).resolve() if not Path(args.schema).is_absolute() else Path(args.schema).resolve()
    output_path = resolve_output_path(args.output, args.skill_name)
    skill_id = args.skill_id or infer_skill_id(args.skill_name, args.skill_class)

    ensure_schema_path_exists(schema_path)
    source_documents = load_source_documents(source_paths, max_chars=args.max_source_chars)
    prompt = build_prompt(
        skill_name=args.skill_name,
        skill_id=skill_id,
        skill_class=args.skill_class,
        source_documents=source_documents,
        extra_instructions=args.extra_instruction,
        scope_hint=args.scope_hint,
    )

    if args.dump_prompt_file:
        prompt_path = (PROJECT_ROOT / args.dump_prompt_file).resolve() if not Path(args.dump_prompt_file).is_absolute() else Path(args.dump_prompt_file).resolve()
        write_text(prompt_path, prompt, overwrite=True)

    if args.mock_output_file:
        mock_path = (PROJECT_ROOT / args.mock_output_file).resolve() if not Path(args.mock_output_file).is_absolute() else Path(args.mock_output_file).resolve()
        raw_output = read_text_file(mock_path)
        markdown = extract_markdown_payload(raw_output)
        validate_v2_markdown(markdown, args.skill_class)
    else:
        attempt_dump_dir = None
        if args.dump_attempt_dir:
            attempt_dump_dir = (PROJECT_ROOT / args.dump_attempt_dir).resolve() if not Path(args.dump_attempt_dir).is_absolute() else Path(args.dump_attempt_dir).resolve()
        raw_output, markdown = generate_with_retries(
            base_prompt=prompt,
            model=args.model,
            skill_class=args.skill_class,
            max_attempts=args.max_attempts,
            timeout_seconds=args.timeout_seconds,
            attempt_dump_dir=attempt_dump_dir,
        )
        validate_v2_markdown(markdown, args.skill_class)

    write_text(output_path, markdown, overwrite=args.overwrite)

    print("Skill 生成完成")
    print(f"- Skill Name: {args.skill_name}")
    print(f"- Skill ID: {skill_id}")
    print(f"- Skill Class: {args.skill_class}")
    print(f"- Output: {project_relative(output_path)}")
    print(f"- Sources: {', '.join(project_relative(path) for path in source_paths)}")
    print(f"- Prompt Chars: {len(prompt)}")
    if args.mock_output_file:
        print(f"- Mode: mock ({args.mock_output_file})")
    else:
        print(f"- Mode: llm ({args.model})")
        print(f"- Raw Output Chars: {len(raw_output)}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SkillGenerationError as exc:
        print(f"[skill_generator_v2] 错误：{exc}", file=sys.stderr)
        raise SystemExit(1)
