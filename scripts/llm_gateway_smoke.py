#!/usr/bin/env python3
"""OpenAI-compatible LLM 网关烟雾测试。

目标：
1. 用极简 streaming 请求测量 Connect Time、TTFT、Total Duration；
2. 解析增量输出文本并估算 output tokens / TPS；
3. 为真实 gateway 诊断提供一份可落盘的 JSON 证据。
"""

from __future__ import annotations

import argparse
import http.client
import json
import os
import socket
import ssl
import time
import urllib.parse
from pathlib import Path
from typing import Dict, List, Optional, Tuple


DEFAULT_BASE_URL = "https://api.openai.com/v1"
DEFAULT_MODEL = os.getenv("OPENAI_MODEL", "Pro/zai-org/GLM-5")
DEFAULT_TIMEOUT_SECONDS = 180
DEFAULT_MAX_OUTPUT_TOKENS = 256
DEFAULT_TEMPERATURE = 0.0
DEFAULT_SMOKE_MESSAGES = [
    {
        "role": "system",
        "content": (
            "你是一名仓颉翻译器。"
            "请把用户提供的 ArkTS 代码转换成仓颉代码，只输出代码，不要解释。"
        ),
    },
    {
        "role": "user",
        "content": (
            "把下面这段 ArkTS 转成仓颉，保留注释语义，输出最小可读代码：\n\n"
            "// smoke sample\n"
            "class Counter {\n"
            "  // current value\n"
            "  private value: number = 0\n\n"
            "  inc(step: number = 1): number {\n"
            "    this.value += step\n"
            "    return this.value\n"
            "  }\n"
            "}\n"
        ),
    },
]


class GatewaySmokeError(RuntimeError):
    """网关烟雾测试失败。"""


def estimate_tokens(char_count: int) -> float:
    return round(char_count / 4.0, 2)


def round_metric(value: float) -> float:
    return round(value, 4)


def build_smoke_payload(
    *,
    model: str,
    max_tokens: int,
    temperature: float,
    messages: Optional[List[Dict[str, str]]] = None,
) -> Dict[str, object]:
    return {
        "model": model,
        "messages": list(messages or DEFAULT_SMOKE_MESSAGES),
        "temperature": temperature,
        "max_tokens": max_tokens,
        "stream": True,
    }


def resolve_endpoint(base_url: str) -> Tuple[urllib.parse.ParseResult, str]:
    normalized = base_url.rstrip("/")
    parsed = urllib.parse.urlparse(normalized)
    if parsed.scheme not in {"http", "https"}:
        raise GatewaySmokeError(f"仅支持 http/https base_url：{base_url}")
    path = (parsed.path.rstrip("/") if parsed.path else "") + "/chat/completions"
    if parsed.query:
        path += f"?{parsed.query}"
    return parsed, path


def create_connection(parsed: urllib.parse.ParseResult, timeout_seconds: int) -> http.client.HTTPConnection:
    port = parsed.port
    if parsed.scheme == "https":
        return http.client.HTTPSConnection(parsed.hostname, port=port, timeout=timeout_seconds, context=ssl.create_default_context())
    return http.client.HTTPConnection(parsed.hostname, port=port, timeout=timeout_seconds)


def extract_stream_delta_text(event_payload: Dict[str, object]) -> str:
    choices = event_payload.get("choices")
    if not isinstance(choices, list) or not choices:
        return ""
    first_choice = choices[0]
    if not isinstance(first_choice, dict):
        return ""
    delta = first_choice.get("delta")
    if not isinstance(delta, dict):
        return ""
    content = delta.get("content")
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: List[str] = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                parts.append(str(item.get("text", "")))
        return "".join(parts)
    return ""


def parse_stream_body(body_text: str) -> Dict[str, object]:
    output_parts: List[str] = []
    event_count = 0
    data_events = 0
    usage: Optional[Dict[str, object]] = None
    done_seen = False

    for raw_line in body_text.splitlines():
        line = raw_line.strip()
        if not line.startswith("data:"):
            continue
        data_events += 1
        payload_text = line[len("data:") :].strip()
        if not payload_text:
            continue
        if payload_text == "[DONE]":
            done_seen = True
            continue
        try:
            payload = json.loads(payload_text)
        except json.JSONDecodeError:
            continue
        event_count += 1
        output_parts.append(extract_stream_delta_text(payload))
        if isinstance(payload.get("usage"), dict):
            usage = payload.get("usage")

    output_text = "".join(output_parts)
    return {
        "mode": "stream",
        "output_text": output_text,
        "event_count": event_count,
        "data_event_count": data_events,
        "done_seen": done_seen,
        "usage": usage,
    }


def parse_nonstream_body(body_text: str) -> Dict[str, object]:
    payload = json.loads(body_text)
    choices = payload.get("choices")
    if not isinstance(choices, list) or not choices:
        raise GatewaySmokeError("响应缺少 choices 字段。")
    first_choice = choices[0]
    if not isinstance(first_choice, dict):
        raise GatewaySmokeError("响应缺少有效 choice。")
    message = first_choice.get("message")
    if not isinstance(message, dict):
        raise GatewaySmokeError("响应缺少 message 字段。")
    content = message.get("content")
    if isinstance(content, str):
        output_text = content
    elif isinstance(content, list):
        parts: List[str] = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                parts.append(str(item.get("text", "")))
        output_text = "\n".join(parts)
    else:
        raise GatewaySmokeError("响应 message.content 不是可解析文本。")
    usage = payload.get("usage") if isinstance(payload.get("usage"), dict) else None
    return {
        "mode": "non-stream",
        "output_text": output_text,
        "event_count": 1,
        "data_event_count": 1,
        "done_seen": False,
        "usage": usage,
    }


def parse_response_body(body_bytes: bytes) -> Dict[str, object]:
    body_text = body_bytes.decode("utf-8", errors="replace")
    stripped = body_text.lstrip()
    if stripped.startswith("data:"):
        parsed = parse_stream_body(body_text)
    else:
        parsed = parse_nonstream_body(body_text)
    parsed["body_text"] = body_text
    return parsed


def read_stream_line(response: http.client.HTTPResponse) -> bytes:
    readline = getattr(response, "readline", None)
    if callable(readline):
        return readline()
    chunks: List[bytes] = []
    while True:
        chunk = response.read(1)
        if not chunk:
            break
        chunks.append(chunk)
        if chunk == b"\n":
            break
    return b"".join(chunks)


def apply_stream_line_to_state(stream_state: Dict[str, object], raw_line: bytes) -> bool:
    body_chunks = stream_state.get("body_chunks")
    if isinstance(body_chunks, list):
        body_chunks.append(raw_line)

    line_text = raw_line.decode("utf-8", errors="replace")
    stripped = line_text.strip()
    if not stripped:
        return False
    if stripped.startswith(":"):
        stream_state["saw_stream_marker"] = True
        return False
    if not stripped.startswith("data:"):
        return False

    stream_state["saw_stream_marker"] = True
    stream_state["data_event_count"] = int(stream_state.get("data_event_count", 0)) + 1
    payload_text = stripped[len("data:") :].strip()
    if not payload_text:
        return False
    if payload_text == "[DONE]":
        stream_state["done_seen"] = True
        return True

    try:
        payload = json.loads(payload_text)
    except json.JSONDecodeError:
        return False
    if not isinstance(payload, dict):
        return False

    stream_state["event_count"] = int(stream_state.get("event_count", 0)) + 1
    output_parts = stream_state.get("output_parts")
    if isinstance(output_parts, list):
        output_parts.append(extract_stream_delta_text(payload))
    if isinstance(payload.get("usage"), dict):
        stream_state["usage"] = payload.get("usage")
    return False


def finalize_stream_state(stream_state: Dict[str, object]) -> Dict[str, object]:
    output_parts = stream_state.get("output_parts")
    body_chunks = stream_state.get("body_chunks")
    output_text = "".join(output_parts) if isinstance(output_parts, list) else ""
    body_bytes = b"".join(body_chunks) if isinstance(body_chunks, list) else b""
    return {
        "mode": "stream",
        "output_text": output_text,
        "event_count": int(stream_state.get("event_count", 0)),
        "data_event_count": int(stream_state.get("data_event_count", 0)),
        "done_seen": bool(stream_state.get("done_seen", False)),
        "usage": stream_state.get("usage") if isinstance(stream_state.get("usage"), dict) else None,
        "body_text": body_bytes.decode("utf-8", errors="replace"),
    }


def read_incremental_response(
    response: http.client.HTTPResponse,
    *,
    request_started_at: float,
) -> Tuple[bytes, Dict[str, object], float, float]:
    first_byte = response.read(1)
    ttft_seconds = time.perf_counter() - request_started_at
    if not first_byte:
        total_duration_seconds = time.perf_counter() - request_started_at
        parsed_response = {
            "mode": "empty",
            "output_text": "",
            "event_count": 0,
            "data_event_count": 0,
            "done_seen": False,
            "usage": None,
            "body_text": "",
        }
        return b"", parsed_response, ttft_seconds, total_duration_seconds

    stream_state: Dict[str, object] = {
        "body_chunks": [],
        "output_parts": [],
        "event_count": 0,
        "data_event_count": 0,
        "done_seen": False,
        "usage": None,
        "saw_stream_marker": False,
    }

    first_line = first_byte + read_stream_line(response)
    should_stop = apply_stream_line_to_state(stream_state, first_line)
    while not should_stop:
        raw_line = read_stream_line(response)
        if not raw_line:
            break
        should_stop = apply_stream_line_to_state(stream_state, raw_line)

    total_duration_seconds = time.perf_counter() - request_started_at
    body_chunks = stream_state.get("body_chunks")
    body_bytes = b"".join(body_chunks) if isinstance(body_chunks, list) else b""
    if bool(stream_state.get("saw_stream_marker", False)):
        parsed_response = finalize_stream_state(stream_state)
    else:
        parsed_response = parse_response_body(body_bytes)
    return body_bytes, parsed_response, ttft_seconds, total_duration_seconds


def probe_gateway(
    *,
    api_key: str,
    base_url: str,
    model: str,
    timeout_seconds: int,
    max_tokens: int,
    temperature: float,
    messages: Optional[List[Dict[str, str]]] = None,
) -> Dict[str, object]:
    parsed_base_url, endpoint_path = resolve_endpoint(base_url)
    payload = build_smoke_payload(
        model=model,
        max_tokens=max_tokens,
        temperature=temperature,
        messages=messages,
    )
    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    connection = create_connection(parsed_base_url, timeout_seconds)

    connect_started_at = time.perf_counter()
    connection.connect()
    connect_time_seconds = time.perf_counter() - connect_started_at

    request_started_at = time.perf_counter()
    connection.putrequest("POST", endpoint_path)
    connection.putheader("Content-Type", "application/json")
    connection.putheader("Authorization", f"Bearer {api_key}")
    connection.putheader("Content-Length", str(len(body)))
    connection.endheaders(body)
    response = connection.getresponse()

    body_bytes, parsed_response, ttft_seconds, total_duration_seconds = read_incremental_response(
        response,
        request_started_at=request_started_at,
    )
    connection.close()
    output_text = str(parsed_response.get("output_text", ""))
    output_char_count = len(output_text)
    output_estimated_tokens = estimate_tokens(output_char_count)
    usage = parsed_response.get("usage") if isinstance(parsed_response.get("usage"), dict) else None
    reported_completion_tokens = None
    if isinstance(usage, dict) and usage.get("completion_tokens") is not None:
        try:
            reported_completion_tokens = int(usage.get("completion_tokens"))  # type: ignore[arg-type]
        except (TypeError, ValueError):
            reported_completion_tokens = None
    generation_window = max(total_duration_seconds - ttft_seconds, 0.0)
    estimated_tps = round(output_estimated_tokens / generation_window, 4) if generation_window > 0 else None
    reported_tps = round(reported_completion_tokens / generation_window, 4) if generation_window > 0 and reported_completion_tokens is not None else None

    headers = {key.lower(): value for key, value in response.getheaders()}
    status_code = int(response.status)
    reason = str(response.reason or "")

    report = {
        "status": "ok" if status_code < 400 else "http-error",
        "base_url": base_url.rstrip("/"),
        "endpoint_path": endpoint_path,
        "model": model,
        "timeout_seconds": timeout_seconds,
        "stream": True,
        "request": {
            "message_count": len(payload["messages"]),
            "input_char_count": sum(len(str(item.get("content", ""))) for item in payload["messages"] if isinstance(item, dict)),
            "input_estimated_tokens": estimate_tokens(
                sum(len(str(item.get("content", ""))) for item in payload["messages"] if isinstance(item, dict))
            ),
            "max_tokens": max_tokens,
            "temperature": temperature,
            "payload_bytes": len(body),
        },
        "http": {
            "scheme": parsed_base_url.scheme,
            "host": parsed_base_url.hostname or "",
            "port": parsed_base_url.port or (443 if parsed_base_url.scheme == "https" else 80),
            "status_code": status_code,
            "reason": reason,
            "headers": headers,
        },
        "metrics": {
            "connect_time_seconds": round_metric(connect_time_seconds),
            "ttft_seconds": round_metric(ttft_seconds),
            "total_duration_seconds": round_metric(total_duration_seconds),
            "generation_window_seconds": round_metric(generation_window),
            "output_char_count": output_char_count,
            "output_estimated_tokens": output_estimated_tokens,
            "output_reported_completion_tokens": reported_completion_tokens,
            "tps_estimated": estimated_tps,
            "tps_reported": reported_tps,
        },
        "response": {
            "parse_mode": parsed_response.get("mode"),
            "event_count": parsed_response.get("event_count"),
            "data_event_count": parsed_response.get("data_event_count"),
            "done_seen": parsed_response.get("done_seen"),
            "body_bytes": len(body_bytes),
            "usage": parsed_response.get("usage"),
            "output_preview": output_text[:400],
        },
    }
    if status_code >= 400:
        report["error"] = {
            "message": f"HTTP {status_code}: {reason}",
            "body_preview": str(parsed_response.get("body_text", ""))[:800],
        }
    return report


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="测量 OpenAI-compatible LLM 网关的 Connect Time / TTFT / TPS")
    parser.add_argument("--base-url", type=str, default=os.getenv("OPENAI_BASE_URL", DEFAULT_BASE_URL), help="OpenAI-compatible base URL")
    parser.add_argument("--api-key", type=str, default=os.getenv("OPENAI_API_KEY"), help="API Key；默认读取 OPENAI_API_KEY")
    parser.add_argument("--model", type=str, default=os.getenv("OPENAI_MODEL", DEFAULT_MODEL), help="模型名")
    parser.add_argument("--timeout-seconds", type=int, default=DEFAULT_TIMEOUT_SECONDS, help="HTTP timeout 秒数")
    parser.add_argument("--max-tokens", type=int, default=DEFAULT_MAX_OUTPUT_TOKENS, help="max_tokens")
    parser.add_argument("--temperature", type=float, default=DEFAULT_TEMPERATURE, help="temperature")
    parser.add_argument("--output", type=str, help="可选 JSON 输出路径")
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    if not args.api_key:
        raise SystemExit("未检测到 API Key；请传入 --api-key 或设置 OPENAI_API_KEY。")

    try:
        report = probe_gateway(
            api_key=str(args.api_key),
            base_url=str(args.base_url),
            model=str(args.model),
            timeout_seconds=int(args.timeout_seconds),
            max_tokens=int(args.max_tokens),
            temperature=float(args.temperature),
        )
    except (GatewaySmokeError, http.client.HTTPException, OSError, socket.timeout, TimeoutError) as exc:
        report = {
            "status": "error",
            "base_url": str(args.base_url).rstrip("/"),
            "model": str(args.model),
            "timeout_seconds": int(args.timeout_seconds),
            "error": {
                "type": exc.__class__.__name__,
                "message": str(exc),
            },
        }
        print(json.dumps(report, ensure_ascii=False, indent=2))
        if args.output:
            output_path = Path(args.output).expanduser().resolve()
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        return 1

    print(json.dumps(report, ensure_ascii=False, indent=2))
    if args.output:
        output_path = Path(args.output).expanduser().resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return 0 if report.get("status") == "ok" else 1


if __name__ == "__main__":
    raise SystemExit(main())
