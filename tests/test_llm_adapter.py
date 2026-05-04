from __future__ import annotations

import io
import json
import os
import socket
import sys
import unittest
import urllib.error
from http.client import IncompleteRead
from pathlib import Path
from unittest import mock


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import llm_adapter  # noqa: E402


class FakeHTTPResponse:
    def __init__(self, payload: dict[str, object]) -> None:
        self.payload = payload
        self._body = json.dumps(self.payload, ensure_ascii=False).encode("utf-8")
        self._cursor = 0

    def __enter__(self) -> "FakeHTTPResponse":
        return self

    def __exit__(self, exc_type, exc, tb) -> bool:
        return False

    def read(self, amount: int | None = None) -> bytes:
        if amount is None or amount < 0:
            amount = len(self._body) - self._cursor
        chunk = self._body[self._cursor : self._cursor + amount]
        self._cursor += len(chunk)
        return chunk

    def __iter__(self):
        yield self.read()


class FakeStreamingHTTPResponse:
    def __init__(self, lines: list[bytes], *, fail_after: int | None = None, failure: Exception | None = None) -> None:
        self.lines = lines
        self.fail_after = fail_after
        self.failure = failure
        self.index = 0
        self.pending_remainder = b""
        self.timeout_values: list[float] = []
        self.bulk_read_attempted = False
        self.readline_calls = 0

    def __enter__(self) -> "FakeStreamingHTTPResponse":
        return self

    def __exit__(self, exc_type, exc, tb) -> bool:
        return False

    def __iter__(self):
        raise AssertionError("streaming path must not iterate over response directly")

    def _next_event(self) -> bytes:
        if self.fail_after is not None and self.index >= self.fail_after and self.failure is not None:
            raise self.failure
        if self.index >= len(self.lines):
            return b""
        item = self.lines[self.index]
        self.index += 1
        return item

    def read(self, amount: int | None = None) -> bytes:
        if amount != 1:
            self.bulk_read_attempted = True
            raise AssertionError("streaming path must not call bulk response.read()")
        if self.pending_remainder:
            chunk = self.pending_remainder[:1]
            self.pending_remainder = self.pending_remainder[1:]
            return chunk
        line = self._next_event()
        if not line:
            return b""
        self.pending_remainder = line[1:]
        return line[:1]

    def readline(self, limit: int = -1) -> bytes:
        del limit
        self.readline_calls += 1
        if self.pending_remainder:
            line = self.pending_remainder
            self.pending_remainder = b""
            return line
        return self._next_event()

    def settimeout(self, value: float) -> None:
        self.timeout_values.append(value)


class SequencedStreamingHTTPResponse:
    def __init__(self, events: list[object]) -> None:
        self.events = events
        self.index = 0
        self.pending_remainder = b""
        self.timeout_values: list[float] = []
        self.bulk_read_attempted = False
        self.readline_calls = 0

    def __enter__(self) -> "SequencedStreamingHTTPResponse":
        return self

    def __exit__(self, exc_type, exc, tb) -> bool:
        return False

    def __iter__(self):
        raise AssertionError("streaming path must not iterate over response directly")

    def _next_event(self) -> bytes:
        if self.index >= len(self.events):
            return b""
        item = self.events[self.index]
        self.index += 1
        if isinstance(item, BaseException):
            raise item
        return bytes(item)

    def read(self, amount: int | None = None) -> bytes:
        if amount != 1:
            self.bulk_read_attempted = True
            raise AssertionError("streaming path must not call bulk response.read()")
        if self.pending_remainder:
            chunk = self.pending_remainder[:1]
            self.pending_remainder = self.pending_remainder[1:]
            return chunk
        line = self._next_event()
        if not line:
            return b""
        self.pending_remainder = line[1:]
        return line[:1]

    def readline(self, limit: int = -1) -> bytes:
        del limit
        self.readline_calls += 1
        if self.pending_remainder:
            line = self.pending_remainder
            self.pending_remainder = b""
            return line
        return self._next_event()

    def settimeout(self, value: float) -> None:
        self.timeout_values.append(value)


class MockLLMAdapterTests(unittest.TestCase):
    def test_mock_translator_emits_real_compile_safe_stub_candidate(self) -> None:
        adapter = llm_adapter.MockLLMAdapter()
        request = llm_adapter.LLMRequest(
            model="mock-model",
            messages=[llm_adapter.ChatMessage(role="user", content="translate")],
            metadata={
                "role": "translator",
                "target_path": "src/core/mtproto/TLSerialization.ets",
                "attempt": 3,
                "repair_guidance": [],
            },
        )

        response = adapter.complete(request)
        payload = json.loads(response.text)
        generated_code = payload["generated_code"]

        self.assertIn("// mock translator artifact", generated_code)
        self.assertIn("main(): Int64", generated_code)
        self.assertNotIn("# mock translator artifact", generated_code)
        self.assertIn(
            "mock translator received src/core/mtproto/TLSerialization.ets",
            payload["notes"],
        )
        self.assertEqual(
            ["Translation Mapping", "Architecture Mapping"],
            payload["declared_constraints"],
        )

    def test_mock_translator_declares_required_dimensions_when_prompt_metadata_provides_them(self) -> None:
        adapter = llm_adapter.MockLLMAdapter()
        request = llm_adapter.LLMRequest(
            model="mock-model",
            messages=[llm_adapter.ChatMessage(role="user", content="translate")],
            metadata={
                "role": "translator",
                "target_path": "raw_docs/phase06-ui-p1/svg4cj/entry/src/main/cangjie/src/render_merman.cj",
                "attempt": 1,
                "required_dimensions": [
                    "Translation Mapping",
                    "Verification Matrix",
                    "Architecture Mapping",
                    "State Contract",
                    "Execution Topology",
                ],
                "repair_guidance": [],
            },
        )

        response = adapter.complete(request)
        payload = json.loads(response.text)

        self.assertEqual(
            [
                "Translation Mapping",
                "Verification Matrix",
                "Architecture Mapping",
                "State Contract",
                "Execution Topology",
            ],
            payload["declared_constraints"],
        )


class OpenAICompatibleLLMAdapterRetryTests(unittest.TestCase):
    def build_request(self) -> llm_adapter.LLMRequest:
        return llm_adapter.LLMRequest(
            model="test-model",
            messages=[llm_adapter.ChatMessage(role="user", content="ping")],
            timeout_seconds=180,
        )

    def build_success_payload(self) -> dict[str, object]:
        return {
            "choices": [
                {
                    "message": {
                        "content": "ok",
                    }
                }
            ]
        }

    def build_stream_line(self, payload: dict[str, object]) -> bytes:
        return f"data: {json.dumps(payload, ensure_ascii=False)}\n".encode("utf-8")

    def test_uses_siliconflow_env_defaults_without_openai_fallback(self) -> None:
        with mock.patch.dict(
            os.environ,
            {
                "SILICONFLOW_API_KEY": "sf-test-key",
            },
            clear=True,
        ):
            adapter = llm_adapter.OpenAICompatibleLLMAdapter()

        self.assertEqual("sf-test-key", adapter.api_key)
        self.assertEqual("https://api.siliconflow.cn/v1", adapter.base_url)

    def test_falls_back_to_openai_api_key_and_base_url(self) -> None:
        with mock.patch.dict(
            os.environ,
            {
                "OPENAI_API_KEY": "legacy-openai-key",
                "OPENAI_BASE_URL": "https://open.example.test/v1",
            },
            clear=True,
        ):
            adapter = llm_adapter.OpenAICompatibleLLMAdapter()

        self.assertEqual("legacy-openai-key", adapter.api_key)
        self.assertEqual("https://open.example.test/v1", adapter.base_url)

    def test_missing_llm_api_key_raises_clear_error(self) -> None:
        with mock.patch.dict(os.environ, {}, clear=True):
            with self.assertRaises(llm_adapter.LLMAdapterError) as ctx:
                llm_adapter.OpenAICompatibleLLMAdapter()

        self.assertIn("SILICONFLOW_API_KEY", str(ctx.exception))
        self.assertIn("OPENAI_API_KEY", str(ctx.exception))

    def test_retries_timeout_then_succeeds(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key")
        request = self.build_request()
        success_response = FakeHTTPResponse(self.build_success_payload())

        with mock.patch(
            "llm_adapter.urllib.request.urlopen",
            side_effect=[socket.timeout("timed out"), success_response],
        ) as mocked_urlopen, mock.patch("llm_adapter.time.sleep") as mocked_sleep:
            response = adapter.complete(request)

        self.assertEqual("ok", response.text)
        self.assertEqual(1, response.retries_used)
        self.assertEqual(2, mocked_urlopen.call_count)
        self.assertEqual([180, 180], [call.kwargs["timeout"] for call in mocked_urlopen.call_args_list])
        request_payload = json.loads(mocked_urlopen.call_args_list[0].args[0].data.decode("utf-8"))
        self.assertEqual(4096, request_payload["max_tokens"])
        mocked_sleep.assert_called_once_with(2.0)

    def test_streaming_sse_accumulates_delta_content_and_emits_heartbeat(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=0)
        request = self.build_request()
        large_delta = "a" * 404
        stream_response = FakeStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "hello "}}]}),
                self.build_stream_line({"choices": [{"delta": {"content": large_delta}}], "usage": {"completion_tokens": 120}}),
                b"data: [DONE]\n",
            ]
        )

        with mock.patch("llm_adapter.urllib.request.urlopen", return_value=stream_response) as mocked_urlopen, mock.patch(
            "sys.stdout",
            new_callable=io.StringIO,
        ) as fake_stdout:
            response = adapter.complete(request)

        self.assertEqual("hello " + large_delta, response.text)
        self.assertEqual("hello " + large_delta, llm_adapter.extract_response_text(response.raw_payload))
        self.assertEqual({"completion_tokens": 120}, response.raw_payload["usage"])
        self.assertFalse(stream_response.bulk_read_attempted)
        self.assertGreater(stream_response.readline_calls, 0)
        request_payload = json.loads(mocked_urlopen.call_args.args[0].data.decode("utf-8"))
        self.assertTrue(request_payload["stream"])
        self.assertIn("Streaming: ~100 tokens", fake_stdout.getvalue())

    def test_streaming_reasoning_chunks_emit_reasoning_tick_and_keep_stream_alive(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=0)
        request = self.build_request()
        stream_response = SequencedStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"reasoning_content": "thinking through constraints"}}]}),
                self.build_stream_line({"choices": [{"delta": {"content": "ok"}}], "usage": {"completion_tokens": 2}}),
                b"data: [DONE]\n",
            ]
        )

        with mock.patch("llm_adapter.urllib.request.urlopen", return_value=stream_response), mock.patch(
            "sys.stdout",
            new_callable=io.StringIO,
        ) as fake_stdout:
            response = adapter.complete(request)

        self.assertEqual("ok", response.text)
        self.assertFalse(stream_response.bulk_read_attempted)
        self.assertGreater(stream_response.readline_calls, 0)
        self.assertIn("[Reasoning Tick]", fake_stdout.getvalue())
        self.assertEqual("thinking through constraints", response.raw_payload["reasoning_content"])
        self.assertEqual(
            "thinking through constraints",
            response.raw_payload["choices"][0]["message"]["reasoning_content"],
        )

    def test_streaming_reasoning_only_timeout_preserves_reasoning_in_partial_response(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=0)
        request = self.build_request()
        stream_response = SequencedStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"reasoning_content": "thinking through constraints"}}]}),
                OSError("cannot read from timed out object"),
            ]
        )

        with mock.patch("llm_adapter.urllib.request.urlopen", return_value=stream_response):
            with self.assertRaises(llm_adapter.LLMNetworkException) as ctx:
                adapter.complete(request)

        self.assertIn("LLM 网络重试耗尽", str(ctx.exception))
        self.assertEqual("[Reasoning]\nthinking through constraints", ctx.exception.partial_response_text)
        self.assertEqual("[Reasoning]\nthinking through constraints", ctx.exception.request_payload["partial_response_text"])

    def test_streaming_incomplete_read_raises_network_exception_with_partial_content(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=0)
        request = self.build_request()
        stream_response = FakeStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "partial content"}}]}),
                b"data: \n",
            ],
            fail_after=1,
            failure=IncompleteRead(b"", 12),
        )

        with mock.patch("llm_adapter.urllib.request.urlopen", return_value=stream_response):
            with self.assertRaises(llm_adapter.LLMNetworkException) as ctx:
                adapter.complete(request)

        self.assertIn("流式读取中断", str(ctx.exception))
        self.assertEqual("partial content", getattr(ctx.exception, "partial_response_text", ""))
        self.assertEqual("partial content", ctx.exception.request_payload["partial_response_text"])

    def test_streaming_hard_wall_clock_timeout_raises_network_exception_with_partial_content(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=0)
        request = llm_adapter.LLMRequest(
            model="test-model",
            messages=[llm_adapter.ChatMessage(role="user", content="ping")],
            timeout_seconds=3,
        )
        stream_response = SequencedStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "partial"}}]}),
                socket.timeout("poll timeout"),
            ]
        )

        class TimeProbe:
            def __init__(self, values: list[float]) -> None:
                self.values = values
                self.index = 0

            def __call__(self) -> float:
                if self.index >= len(self.values):
                    return self.values[-1]
                value = self.values[self.index]
                self.index += 1
                return value

        with mock.patch("llm_adapter.urllib.request.urlopen", return_value=stream_response), mock.patch(
            "llm_adapter.time.time",
            new=TimeProbe([0.0, 0.2, 3.2]),
        ):
            with self.assertRaises(llm_adapter.LLMNetworkException) as ctx:
                adapter.complete(request)

        self.assertIn("Hard wall-clock timeout exceeded", str(ctx.exception))
        self.assertEqual("partial", ctx.exception.partial_response_text)
        self.assertEqual("partial", ctx.exception.request_payload["partial_response_text"])
        self.assertTrue(stream_response.timeout_values)

    def test_streaming_logs_keep_alive_and_heartbeat_json_ticks(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=0)
        request = self.build_request()
        stream_response = SequencedStreamingHTTPResponse(
            [
                b": keep-alive\n",
                self.build_stream_line({"usage": {"completion_tokens": 1}}),
                self.build_stream_line({"choices": [{"delta": {"content": "ok"}}]}),
                b"data: [DONE]\n",
            ]
        )

        with mock.patch("llm_adapter.urllib.request.urlopen", return_value=stream_response), mock.patch(
            "sys.stdout",
            new_callable=io.StringIO,
        ) as fake_stdout:
            response = adapter.complete(request)

        self.assertEqual("ok", response.text)
        stdout_text = fake_stdout.getvalue()
        self.assertIn("[SSE Tick] keep-alive received", stdout_text)
        self.assertIn("[SSE Tick] heartbeat json received", stdout_text)

    def test_streaming_timed_out_object_error_retries_then_succeeds(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=1)
        request = self.build_request()
        timed_out_stream = SequencedStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "partial"}}]}),
                ValueError("cannot read from timed out object"),
            ]
        )
        success_stream = FakeStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "ok"}}], "usage": {"completion_tokens": 1}}),
                b"data: [DONE]\n",
            ]
        )

        with mock.patch(
            "llm_adapter.urllib.request.urlopen",
            side_effect=[timed_out_stream, success_stream],
        ) as mocked_urlopen, mock.patch("llm_adapter.time.sleep") as mocked_sleep:
            response = adapter.complete(request)

        self.assertEqual("ok", response.text)
        self.assertEqual(1, response.retries_used)
        self.assertEqual(2, mocked_urlopen.call_count)
        mocked_sleep.assert_called_once_with(2.0)

    def test_streaming_oserror_timed_out_object_retries_with_identical_payload(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=1)
        request = self.build_request()
        timed_out_stream = SequencedStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "partial"}}]}),
                OSError("cannot read from timed out object"),
            ]
        )
        success_stream = FakeStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "ok"}}], "usage": {"completion_tokens": 1}}),
                b"data: [DONE]\n",
            ]
        )

        with mock.patch(
            "llm_adapter.urllib.request.urlopen",
            side_effect=[timed_out_stream, success_stream],
        ) as mocked_urlopen, mock.patch("llm_adapter.time.sleep") as mocked_sleep:
            response = adapter.complete(request)

        first_payload = json.loads(mocked_urlopen.call_args_list[0].args[0].data.decode("utf-8"))
        second_payload = json.loads(mocked_urlopen.call_args_list[1].args[0].data.decode("utf-8"))
        self.assertEqual("ok", response.text)
        self.assertEqual(1, response.retries_used)
        self.assertEqual(first_payload, second_payload)
        self.assertNotIn("partial_response_text", second_payload)
        mocked_sleep.assert_called_once_with(2.0)

    def test_streaming_incomplete_read_retries_then_succeeds(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=1)
        request = self.build_request()
        incomplete_stream = FakeStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "partial"}}]}),
                b"data: \n",
            ],
            fail_after=1,
            failure=IncompleteRead(b"", 12),
        )
        success_stream = FakeStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "ok"}}], "usage": {"completion_tokens": 1}}),
                b"data: [DONE]\n",
            ]
        )

        with mock.patch(
            "llm_adapter.urllib.request.urlopen",
            side_effect=[incomplete_stream, success_stream],
        ) as mocked_urlopen, mock.patch("llm_adapter.time.sleep") as mocked_sleep:
            response = adapter.complete(request)

        self.assertEqual("ok", response.text)
        self.assertEqual(1, response.retries_used)
        self.assertEqual(2, mocked_urlopen.call_count)
        mocked_sleep.assert_called_once_with(2.0)

    def test_streaming_timed_out_object_error_raises_network_exception_after_retry_exhausted(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key", max_retries=0)
        request = self.build_request()
        timed_out_stream = SequencedStreamingHTTPResponse(
            [
                self.build_stream_line({"choices": [{"delta": {"content": "partial"}}]}),
                OSError("cannot read from timed out object"),
            ]
        )

        with mock.patch("llm_adapter.urllib.request.urlopen", return_value=timed_out_stream):
            with self.assertRaises(llm_adapter.LLMNetworkException) as ctx:
                adapter.complete(request)

        self.assertIn("LLM 网络重试耗尽", str(ctx.exception))
        self.assertEqual("partial", ctx.exception.partial_response_text)
        self.assertEqual("partial", ctx.exception.request_payload["partial_response_text"])

    def test_retries_http_5xx_then_raises_network_exception(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key")
        request = self.build_request()
        http_error = urllib.error.HTTPError(
            url="https://example.invalid/v1/chat/completions",
            code=503,
            msg="Service Unavailable",
            hdrs=None,
            fp=io.BytesIO(b"upstream overloaded"),
        )

        with mock.patch(
            "llm_adapter.urllib.request.urlopen",
            side_effect=[http_error, http_error, http_error, http_error],
        ) as mocked_urlopen, mock.patch("llm_adapter.time.sleep") as mocked_sleep:
            with self.assertRaises(llm_adapter.LLMNetworkException) as ctx:
                adapter.complete(request)

        self.assertIn("HTTP 5xx 重试耗尽", str(ctx.exception))
        self.assertEqual(4, mocked_urlopen.call_count)
        self.assertEqual(180, ctx.exception.timeout_seconds)
        self.assertEqual(
            {
                "model": "test-model",
                "messages": [{"role": "user", "content": "ping"}],
                "temperature": 0.1,
                "max_tokens": 4096,
                "stream": True,
            },
            ctx.exception.request_payload,
        )
        self.assertEqual(
            [mock.call(2.0), mock.call(4.0), mock.call(8.0)],
            mocked_sleep.call_args_list,
        )

    def test_http_4xx_does_not_retry(self) -> None:
        adapter = llm_adapter.OpenAICompatibleLLMAdapter(api_key="test-key")
        request = self.build_request()
        http_error = urllib.error.HTTPError(
            url="https://example.invalid/v1/chat/completions",
            code=401,
            msg="Unauthorized",
            hdrs=None,
            fp=io.BytesIO(b"bad key"),
        )

        with mock.patch(
            "llm_adapter.urllib.request.urlopen",
            side_effect=http_error,
        ) as mocked_urlopen, mock.patch("llm_adapter.time.sleep") as mocked_sleep:
            with self.assertRaises(llm_adapter.LLMHTTPStatusError) as ctx:
                adapter.complete(request)

        self.assertIn("HTTP 401", str(ctx.exception))
        self.assertEqual(1, mocked_urlopen.call_count)
        self.assertEqual(180, ctx.exception.timeout_seconds)
        self.assertEqual(
            {
                "model": "test-model",
                "messages": [{"role": "user", "content": "ping"}],
                "temperature": 0.1,
                "max_tokens": 4096,
                "stream": True,
            },
            ctx.exception.request_payload,
        )
        mocked_sleep.assert_not_called()


if __name__ == "__main__":
    unittest.main()
