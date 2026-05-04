#!/usr/bin/env python3
"""LLM 通信适配器。

功能：
1. 提供统一的 OpenAI 兼容 Chat Completions 调用接口；
2. 支持 Timeout、指数退避重试与基础容错；
3. 提供 Mock Adapter，便于离线联调 Orchestrator。
"""

from __future__ import annotations

import json
import os
import socket
import time
from http.client import IncompleteRead
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Sequence

DEFAULT_BASE_URL = "https://api.siliconflow.cn/v1"
DEFAULT_MODEL = os.getenv("OPENAI_MODEL", "Pro/zai-org/GLM-5")
DEFAULT_TIMEOUT_SECONDS = 180
DEFAULT_MAX_OUTPUT_TOKENS = 4096
STREAM_READ_POLL_SECONDS = 5.0
RETRYABLE_STREAM_ERROR_SNIPPETS = (
    "cannot read from timed out object",
    "timed out object",
)


class LLMAdapterError(RuntimeError):
    """LLM 适配器错误。"""

    def __init__(
        self,
        message: str,
        *,
        request_payload: Optional[Dict[str, object]] = None,
        timeout_seconds: Optional[int] = None,
        partial_response_text: Optional[str] = None,
    ) -> None:
        self.request_payload = request_payload
        self.timeout_seconds = timeout_seconds
        self.partial_response_text = partial_response_text
        super().__init__(message)


class LLMHTTPStatusError(LLMAdapterError):
    """HTTP 状态码错误。"""

    def __init__(
        self,
        status_code: int,
        detail: str,
        *,
        request_payload: Optional[Dict[str, object]] = None,
        timeout_seconds: Optional[int] = None,
    ) -> None:
        self.status_code = status_code
        self.detail = detail
        super().__init__(
            f"HTTP {status_code}: {detail}",
            request_payload=request_payload,
            timeout_seconds=timeout_seconds,
        )

    @property
    def is_retryable(self) -> bool:
        return 500 <= self.status_code < 600


class LLMNetworkException(LLMAdapterError):
    """网络层 / 基础设施层异常。"""


class _RetryableTransportError(LLMAdapterError):
    """可重试的底层网络传输错误。"""


@dataclass
class ChatMessage:
    role: str
    content: str


@dataclass
class LLMRequest:
    model: str
    messages: List[ChatMessage]
    temperature: float = 0.1
    timeout_seconds: int = DEFAULT_TIMEOUT_SECONDS
    max_tokens: int = DEFAULT_MAX_OUTPUT_TOKENS
    expect_json: bool = False
    metadata: Dict[str, object] = field(default_factory=dict)


@dataclass
class LLMResponse:
    text: str
    raw_payload: Dict[str, object]
    model: str
    retries_used: int = 0


class OpenAICompatibleLLMAdapter:
    def __init__(
        self,
        *,
        api_key: Optional[str] = None,
        base_url: Optional[str] = None,
        default_model: str = DEFAULT_MODEL,
        timeout_seconds: int = DEFAULT_TIMEOUT_SECONDS,
        max_retries: int = 3,
        backoff_base_seconds: float = 2.0,
        backoff_multiplier: float = 2.0,
        backoff_max_seconds: float = 8.0,
        default_temperature: float = 0.1,
    ) -> None:
        env_siliconflow_api_key = os.getenv("SILICONFLOW_API_KEY")
        env_openai_api_key = os.getenv("OPENAI_API_KEY")
        self.api_key = api_key or env_siliconflow_api_key or env_openai_api_key
        if base_url:
            resolved_base_url = base_url
        elif api_key or env_siliconflow_api_key:
            resolved_base_url = os.getenv("SILICONFLOW_BASE_URL") or os.getenv("OPENAI_BASE_URL") or DEFAULT_BASE_URL
        elif env_openai_api_key:
            resolved_base_url = os.getenv("OPENAI_BASE_URL") or os.getenv("SILICONFLOW_BASE_URL") or DEFAULT_BASE_URL
        else:
            resolved_base_url = os.getenv("SILICONFLOW_BASE_URL") or os.getenv("OPENAI_BASE_URL") or DEFAULT_BASE_URL
        self.base_url = resolved_base_url.rstrip("/")
        self.default_model = default_model
        self.timeout_seconds = timeout_seconds
        self.max_retries = max_retries
        self.backoff_base_seconds = backoff_base_seconds
        self.backoff_multiplier = backoff_multiplier
        self.backoff_max_seconds = backoff_max_seconds
        self.default_temperature = default_temperature
        if not self.api_key:
            raise LLMAdapterError("未检测到 SILICONFLOW_API_KEY 或 OPENAI_API_KEY，无法发起真实 LLM 调用。")

    def complete(self, request: LLMRequest) -> LLMResponse:
        payload = self._build_payload(request)
        retries_used = 0
        timeout_seconds = request.timeout_seconds or self.timeout_seconds
        for attempt in range(self.max_retries + 1):
            try:
                raw_payload = self._post_json(payload, timeout_seconds=timeout_seconds)
                text = extract_response_text(raw_payload)
                return LLMResponse(
                    text=text,
                    raw_payload=raw_payload,
                    model=request.model or self.default_model,
                    retries_used=retries_used,
                )
            except LLMHTTPStatusError as exc:
                if not exc.is_retryable:
                    raise
                if attempt >= self.max_retries:
                    raise LLMNetworkException(
                        f"LLM HTTP 5xx 重试耗尽：status={exc.status_code} attempts={attempt + 1} detail={exc.detail}",
                        request_payload=exc.request_payload or payload,
                        timeout_seconds=exc.timeout_seconds or timeout_seconds,
                        partial_response_text=exc.partial_response_text,
                    ) from exc
                retries_used += 1
                sleep_seconds = compute_backoff(
                    attempt=attempt,
                    base_seconds=self.backoff_base_seconds,
                    multiplier=self.backoff_multiplier,
                    max_seconds=self.backoff_max_seconds,
                )
                time.sleep(sleep_seconds)
            except _RetryableTransportError as exc:
                if attempt >= self.max_retries:
                    raise LLMNetworkException(
                        f"LLM 网络重试耗尽：attempts={attempt + 1} error={exc}",
                        request_payload=exc.request_payload or payload,
                        timeout_seconds=exc.timeout_seconds or timeout_seconds,
                        partial_response_text=exc.partial_response_text,
                    ) from exc
                retries_used += 1
                sleep_seconds = compute_backoff(
                    attempt=attempt,
                    base_seconds=self.backoff_base_seconds,
                    multiplier=self.backoff_multiplier,
                    max_seconds=self.backoff_max_seconds,
                )
                time.sleep(sleep_seconds)
        raise LLMAdapterError("未知错误：LLM 调用重试流程未返回结果。")

    def _build_payload(self, request: LLMRequest) -> Dict[str, object]:
        payload: Dict[str, object] = {
            "model": request.model or self.default_model,
            "messages": [{"role": msg.role, "content": msg.content} for msg in request.messages],
            "temperature": request.temperature,
            "max_tokens": request.max_tokens,
            "stream": True,
        }
        if request.expect_json:
            payload["response_format"] = {"type": "json_object"}
        return payload

    def _post_json(self, payload: Dict[str, object], timeout_seconds: int) -> Dict[str, object]:
        request = urllib.request.Request(
            url=f"{self.base_url}/chat/completions",
            data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self.api_key}",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=timeout_seconds) as response:
                return self._read_streaming_response(response, request_payload=payload, timeout_seconds=timeout_seconds)
        except urllib.error.HTTPError as exc:
            body = exc.read().decode("utf-8", errors="ignore") if hasattr(exc, "read") else ""
            raise LLMHTTPStatusError(
                exc.code,
                body or str(exc.reason),
                request_payload=payload,
                timeout_seconds=timeout_seconds,
            ) from exc
        except (urllib.error.URLError, TimeoutError, socket.timeout) as exc:
            raise _RetryableTransportError(
                f"网络错误或超时：{exc}",
                request_payload=payload,
                timeout_seconds=timeout_seconds,
            ) from exc
        except json.JSONDecodeError as exc:
            raise LLMAdapterError(
                f"响应 JSON 解析失败：{exc}",
                request_payload=payload,
                timeout_seconds=timeout_seconds,
            ) from exc

    def _read_streaming_response(
        self,
        response: object,
        *,
        request_payload: Dict[str, object],
        timeout_seconds: int,
    ) -> Dict[str, object]:
        raw_lines: List[str] = []
        full_content = ""
        full_reasoning = ""
        last_event_payload: Optional[Dict[str, object]] = None
        last_usage: Optional[Dict[str, object]] = None
        next_progress_token_mark = 100
        next_reasoning_token_mark = 100
        reasoning_tick_emitted = False
        start_time = time.time()
        configure_stream_socket_timeout(response, timeout_seconds=timeout_seconds)

        def partial_stream_text() -> str:
            return build_partial_stream_text(full_content=full_content, full_reasoning=full_reasoning)

        try:
            while True:
                elapsed = time.time() - start_time
                ensure_within_hard_wall_clock(
                    elapsed=elapsed,
                    timeout_seconds=timeout_seconds,
                    request_payload=request_payload,
                    partial_response_text=partial_stream_text(),
                )
                try:
                    raw_line = read_stream_line(response)
                except socket.timeout:
                    elapsed = time.time() - start_time
                    ensure_within_hard_wall_clock(
                        elapsed=elapsed,
                        timeout_seconds=timeout_seconds,
                        request_payload=request_payload,
                        partial_response_text=partial_stream_text(),
                    )
                    continue
                if is_empty_stream_line(raw_line):
                    break
                line_text = decode_stream_line(raw_line)
                raw_lines.append(line_text)
                elapsed = time.time() - start_time
                stripped = line_text.strip()
                if not stripped:
                    ensure_within_hard_wall_clock(
                        elapsed=elapsed,
                        timeout_seconds=timeout_seconds,
                        request_payload=request_payload,
                        partial_response_text=partial_stream_text(),
                    )
                    continue
                if stripped.startswith(":"):
                    print(f"[SSE Tick] keep-alive received at {elapsed:.1f}s", flush=True)
                    ensure_within_hard_wall_clock(
                        elapsed=elapsed,
                        timeout_seconds=timeout_seconds,
                        request_payload=request_payload,
                        partial_response_text=partial_stream_text(),
                    )
                    continue
                if not stripped.startswith("data:"):
                    ensure_within_hard_wall_clock(
                        elapsed=elapsed,
                        timeout_seconds=timeout_seconds,
                        request_payload=request_payload,
                        partial_response_text=partial_stream_text(),
                    )
                    continue
                data_text = stripped[len("data:") :].strip()
                if not data_text:
                    ensure_within_hard_wall_clock(
                        elapsed=elapsed,
                        timeout_seconds=timeout_seconds,
                        request_payload=request_payload,
                        partial_response_text=partial_stream_text(),
                    )
                    continue
                if data_text == "[DONE]":
                    break
                try:
                    event_payload = json.loads(data_text)
                except json.JSONDecodeError:
                    ensure_within_hard_wall_clock(
                        elapsed=elapsed,
                        timeout_seconds=timeout_seconds,
                        request_payload=request_payload,
                        partial_response_text=partial_stream_text(),
                    )
                    continue
                if not isinstance(event_payload, dict):
                    ensure_within_hard_wall_clock(
                        elapsed=elapsed,
                        timeout_seconds=timeout_seconds,
                        request_payload=request_payload,
                        partial_response_text=partial_stream_text(),
                    )
                    continue
                usage = event_payload.get("usage")
                if isinstance(usage, dict):
                    last_usage = usage
                if not payload_has_stream_choices(event_payload):
                    print(f"[SSE Tick] heartbeat json received at {elapsed:.1f}s", flush=True)
                    ensure_within_hard_wall_clock(
                        elapsed=elapsed,
                        timeout_seconds=timeout_seconds,
                        request_payload=request_payload,
                        partial_response_text=partial_stream_text(),
                    )
                    continue
                last_event_payload = event_payload
                reasoning_text = extract_stream_reasoning_text(event_payload)
                if reasoning_text:
                    full_reasoning += reasoning_text
                    reasoning_tokens = estimate_token_count(full_reasoning)
                    if not reasoning_tick_emitted:
                        print(f"[Reasoning Tick] reasoning activity at {elapsed:.1f}s", flush=True)
                        reasoning_tick_emitted = True
                    while reasoning_tokens >= next_reasoning_token_mark:
                        print(f"[Reasoning Tick] ~{next_reasoning_token_mark} reasoning tokens at {elapsed:.1f}s", flush=True)
                        next_reasoning_token_mark += 100
                delta_text = extract_stream_delta_text(event_payload)
                if delta_text:
                    full_content += delta_text
                    estimated_tokens = estimate_token_count(full_content)
                    while estimated_tokens >= next_progress_token_mark:
                        print(f"[llm_adapter] Streaming: ~{next_progress_token_mark} tokens...", flush=True)
                        next_progress_token_mark += 100
                ensure_within_hard_wall_clock(
                    elapsed=elapsed,
                    timeout_seconds=timeout_seconds,
                    request_payload=request_payload,
                    partial_response_text=partial_stream_text(),
                )
        except KeyboardInterrupt as exc:
            raise LLMNetworkException(
                "Streaming interrupted by KeyboardInterrupt",
                request_payload=attach_partial_response_text(request_payload, partial_stream_text()),
                timeout_seconds=timeout_seconds,
                partial_response_text=partial_stream_text(),
            ) from exc
        except LLMAdapterError as exc:
            raise attach_partial_stream_state(
                exc,
                request_payload=request_payload,
                timeout_seconds=timeout_seconds,
                partial_response_text=partial_stream_text(),
            )
        except (IncompleteRead, urllib.error.URLError, TimeoutError, socket.timeout) as exc:
            raise build_retryable_stream_transport_error(
                exc,
                request_payload=request_payload,
                timeout_seconds=timeout_seconds,
                partial_response_text=partial_stream_text(),
            ) from exc
        except (OSError, ValueError) as exc:
            if is_retryable_stream_read_error(exc):
                raise build_retryable_stream_transport_error(
                    exc,
                    request_payload=request_payload,
                    timeout_seconds=timeout_seconds,
                    partial_response_text=partial_stream_text(),
                ) from exc
            raise LLMAdapterError(
                f"流式读取失败：{exc}",
                request_payload=attach_partial_response_text(request_payload, partial_stream_text()),
                timeout_seconds=timeout_seconds,
                partial_response_text=partial_stream_text(),
            ) from exc
        except Exception as exc:
            if is_retryable_stream_read_error(exc):
                raise build_retryable_stream_transport_error(
                    exc,
                    request_payload=request_payload,
                    timeout_seconds=timeout_seconds,
                    partial_response_text=partial_stream_text(),
                ) from exc
            raise LLMAdapterError(
                f"流式读取失败：{exc}",
                request_payload=attach_partial_response_text(request_payload, partial_stream_text()),
                timeout_seconds=timeout_seconds,
                partial_response_text=partial_stream_text(),
            ) from exc

        if last_event_payload is None:
            raw_text = "".join(raw_lines).strip()
            if not raw_text:
                raise LLMAdapterError(
                    "响应体为空。",
                    request_payload=request_payload,
                    timeout_seconds=timeout_seconds,
                    partial_response_text=partial_stream_text(),
                )
            fallback_payload = json.loads(raw_text)
            if not isinstance(fallback_payload, dict):
                raise LLMAdapterError(
                    "响应 JSON 不是 object。",
                    request_payload=request_payload,
                    timeout_seconds=timeout_seconds,
                    partial_response_text=partial_stream_text(),
                )
            return fallback_payload

        return build_stream_completion_payload(
            full_content=full_content,
            full_reasoning=full_reasoning,
            last_event_payload=last_event_payload,
            usage=last_usage,
        )


class MockLLMAdapter:
    def __init__(self) -> None:
        self.default_model = "mock-model"

    def complete(self, request: LLMRequest) -> LLMResponse:
        role = str(request.metadata.get("role", "generic"))
        if role == "translator":
            text = self._mock_translator(request)
        elif role == "reviewer":
            text = self._mock_reviewer(request)
        else:
            text = json.dumps({"message": "mock response"}, ensure_ascii=False)
        return LLMResponse(text=text, raw_payload={"mock": True}, model=request.model or self.default_model, retries_used=0)

    def _mock_translator(self, request: LLMRequest) -> str:
        target_path = str(request.metadata.get("target_path", "unknown"))
        attempt = int(request.metadata.get("attempt", 1))
        repair_guidance = [str(item) for item in request.metadata.get("repair_guidance", [])] if isinstance(request.metadata.get("repair_guidance"), list) else []
        required_dimensions = [str(item) for item in request.metadata.get("required_dimensions", [])] if isinstance(request.metadata.get("required_dimensions"), list) else []
        declared_constraints = list(required_dimensions) if required_dimensions else ["Translation Mapping"]
        if attempt > 1 and "Architecture Mapping" not in declared_constraints:
            declared_constraints.append("Architecture Mapping")
        for item in repair_guidance:
            if item.startswith("补充约束:"):
                declared_constraints.append(item.split(":", 1)[1].strip())
        declared_constraints = dedupe_preserve_order(declared_constraints)
        payload = {
            "generated_code": "\n".join(
                [
                    "// mock translator artifact",
                    f"// target: {target_path}",
                    f"// attempt: {attempt}",
                    f"// declared_constraints: {', '.join(declared_constraints)}",
                    "// note: mock mode does not emit real .cj business code.",
                    "",
                    "main(): Int64 {",
                    "    return 0",
                    "}",
                ]
            ),
            "declared_constraints": declared_constraints,
            "notes": [
                f"mock translator received {target_path}",
                f"repair_guidance={repair_guidance}",
            ],
        }
        return json.dumps(payload, ensure_ascii=False)

    def _mock_reviewer(self, request: LLMRequest) -> str:
        required_dimensions = [str(item) for item in request.metadata.get("required_dimensions", [])] if isinstance(request.metadata.get("required_dimensions"), list) else []
        declared_constraints = [str(item) for item in request.metadata.get("declared_constraints", [])] if isinstance(request.metadata.get("declared_constraints"), list) else []
        issues = []
        for dimension in required_dimensions:
            if dimension not in declared_constraints:
                issues.append(
                    {
                        "code": f"missing-{slugify(dimension)}",
                        "severity": "blocker",
                        "message": f"缺少 {dimension} 约束。",
                        "required_dimension": dimension,
                        "evidence": f"declared_constraints={declared_constraints}",
                    }
                )
        payload = {"pass": not issues, "issues": issues}
        return json.dumps(payload, ensure_ascii=False)


def compute_backoff(attempt: int, base_seconds: float, multiplier: float, max_seconds: float) -> float:
    return min(max_seconds, base_seconds * (multiplier ** attempt))


def estimate_token_count(text: str) -> int:
    return int(len(text) / 4)


def configure_stream_socket_timeout(response: object, *, timeout_seconds: int) -> None:
    read_timeout_seconds = min(float(timeout_seconds), STREAM_READ_POLL_SECONDS)
    if read_timeout_seconds <= 0:
        return
    candidates = [response]
    for attr_path in (
        ("fp",),
        ("fp", "raw"),
        ("fp", "raw", "_sock"),
        ("fp", "raw", "_sock", "sock"),
        ("_sock",),
    ):
        current = response
        for attr_name in attr_path:
            current = getattr(current, attr_name, None)
            if current is None:
                break
        if current is not None:
            candidates.append(current)
    seen_ids = set()
    for candidate in candidates:
        if candidate is None:
            continue
        candidate_id = id(candidate)
        if candidate_id in seen_ids:
            continue
        seen_ids.add(candidate_id)
        setter = getattr(candidate, "settimeout", None)
        if not callable(setter):
            continue
        try:
            setter(read_timeout_seconds)
            return
        except Exception:
            continue


def ensure_within_hard_wall_clock(
    *,
    elapsed: float,
    timeout_seconds: int,
    request_payload: Dict[str, object],
    partial_response_text: str,
) -> None:
    if elapsed <= timeout_seconds:
        return
    raise LLMNetworkException(
        f"Hard wall-clock timeout exceeded after {elapsed:.1f}s",
        request_payload=attach_partial_response_text(request_payload, partial_response_text),
        timeout_seconds=timeout_seconds,
        partial_response_text=partial_response_text,
    )


def build_retryable_stream_transport_error(
    exc: Exception,
    *,
    request_payload: Dict[str, object],
    timeout_seconds: int,
    partial_response_text: str,
) -> _RetryableTransportError:
    return _RetryableTransportError(
        f"流式读取中断：{exc}",
        request_payload=attach_partial_response_text(request_payload, partial_response_text),
        timeout_seconds=timeout_seconds,
        partial_response_text=partial_response_text,
    )


def attach_partial_stream_state(
    exc: LLMAdapterError,
    *,
    request_payload: Dict[str, object],
    timeout_seconds: int,
    partial_response_text: str,
) -> LLMAdapterError:
    existing_payload = exc.request_payload if isinstance(exc.request_payload, dict) else request_payload
    exc.request_payload = attach_partial_response_text(existing_payload, partial_response_text)
    exc.timeout_seconds = exc.timeout_seconds or timeout_seconds
    if exc.partial_response_text is None:
        exc.partial_response_text = partial_response_text
    return exc


def is_retryable_stream_read_error(exc: Exception) -> bool:
    if isinstance(exc, (IncompleteRead, urllib.error.URLError, TimeoutError, socket.timeout)):
        return True
    if not isinstance(exc, (OSError, ValueError, RuntimeError)):
        return False
    combined = " | ".join(iter_exception_messages(exc)).lower()
    return any(snippet in combined for snippet in RETRYABLE_STREAM_ERROR_SNIPPETS)


def iter_exception_messages(exc: BaseException) -> List[str]:
    messages: List[str] = []
    seen_ids = set()
    current: Optional[BaseException] = exc
    while current is not None and id(current) not in seen_ids:
        seen_ids.add(id(current))
        text = str(current).strip()
        if text:
            messages.append(text)
        next_exc = current.__cause__ if current.__cause__ is not None else current.__context__
        current = next_exc
    return messages


def decode_stream_line(raw_line: object) -> str:
    if isinstance(raw_line, bytes):
        return raw_line.decode("utf-8", errors="replace")
    return str(raw_line)


def is_empty_stream_line(raw_line: object) -> bool:
    return raw_line in ("", b"", None)


def read_stream_line(response: object) -> object:
    readline = getattr(response, "readline", None)
    if callable(readline):
        return readline()
    reader = getattr(response, "read", None)
    if not callable(reader):
        raise LLMAdapterError("流式响应对象既不支持 readline() 也不支持 read(1)。")
    chunks: List[str] = []
    while True:
        chunk = reader(1)
        if chunk in ("", b"", None):
            break
        text = decode_stream_line(chunk)
        chunks.append(text)
        if text.endswith("\n"):
            break
    return "".join(chunks)


def payload_has_stream_choices(payload: Dict[str, object]) -> bool:
    choices = payload.get("choices")
    return isinstance(choices, list) and bool(choices)


def extract_text_delta(value: object) -> str:
    if isinstance(value, str):
        return value
    if isinstance(value, list):
        parts: List[str] = []
        for item in value:
            if isinstance(item, dict):
                if item.get("type") == "text":
                    parts.append(str(item.get("text", "")))
                    continue
                if "text" in item:
                    parts.append(str(item.get("text", "")))
                    continue
                if "content" in item:
                    parts.append(str(item.get("content", "")))
        return "\n".join([part for part in parts if part])
    return ""


def extract_stream_delta_text(payload: Dict[str, object]) -> str:
    choices = payload.get("choices")
    if not isinstance(choices, list) or not choices:
        return ""
    first_choice = choices[0]
    if not isinstance(first_choice, dict):
        return ""
    delta = first_choice.get("delta")
    if not isinstance(delta, dict):
        return ""
    return extract_text_delta(delta.get("content"))


def extract_stream_reasoning_text(payload: Dict[str, object]) -> str:
    choices = payload.get("choices")
    if not isinstance(choices, list) or not choices:
        return ""
    first_choice = choices[0]
    if not isinstance(first_choice, dict):
        return ""
    delta = first_choice.get("delta")
    if not isinstance(delta, dict):
        return ""
    for key in ("reasoning_content", "reasoning", "reasoning_text"):
        text = extract_text_delta(delta.get(key))
        if text:
            return text
    for key in ("reasoning_content", "reasoning", "reasoning_text"):
        text = extract_text_delta(first_choice.get(key))
        if text:
            return text
    return ""


def attach_partial_response_text(request_payload: Dict[str, object], partial_response_text: str) -> Dict[str, object]:
    payload = dict(request_payload)
    payload["partial_response_text"] = partial_response_text
    return payload


def build_partial_stream_text(*, full_content: str, full_reasoning: str) -> str:
    if full_reasoning and full_content:
        return f"[Reasoning]\n{full_reasoning}\n\n[Content]\n{full_content}"
    if full_reasoning:
        return f"[Reasoning]\n{full_reasoning}"
    return full_content


def build_stream_completion_payload(
    *,
    full_content: str,
    full_reasoning: str,
    last_event_payload: Dict[str, object],
    usage: Optional[Dict[str, object]],
) -> Dict[str, object]:
    payload: Dict[str, object] = {
        "choices": [
            {
                "message": {
                    "role": "assistant",
                    "content": full_content,
                }
            }
        ]
    }
    if full_reasoning:
        payload["reasoning_content"] = full_reasoning
        payload["choices"][0]["message"]["reasoning_content"] = full_reasoning
    for key in ("id", "model", "created", "system_fingerprint", "object"):
        value = last_event_payload.get(key)
        if value is not None:
            payload[key] = value
    if usage is not None:
        payload["usage"] = usage
    choices = last_event_payload.get("choices")
    if isinstance(choices, list) and choices and isinstance(choices[0], dict):
        finish_reason = choices[0].get("finish_reason")
        if finish_reason is not None:
            payload["choices"][0]["finish_reason"] = finish_reason
    return payload


def extract_response_text(payload: Dict[str, object]) -> str:
    choices = payload.get("choices")
    if not isinstance(choices, list) or not choices:
        raise LLMAdapterError("响应缺少 choices 字段。")
    message = choices[0].get("message") if isinstance(choices[0], dict) else None
    if not isinstance(message, dict):
        raise LLMAdapterError("响应缺少 message 字段。")
    content = message.get("content")
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: List[str] = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                parts.append(str(item.get("text", "")))
        if parts:
            return "\n".join(parts)
    raise LLMAdapterError("响应 message.content 不是可解析文本。")


def slugify(value: str) -> str:
    return value.strip().lower().replace(" ", "-")


def dedupe_preserve_order(items: Sequence[str]) -> List[str]:
    seen = set()
    result: List[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result
