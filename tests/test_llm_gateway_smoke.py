from __future__ import annotations

import sys
import unittest
from pathlib import Path
from unittest import mock


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import llm_gateway_smoke  # noqa: E402


class FakeHTTPResponse:
    def __init__(self, body: bytes, *, status: int = 200, reason: str = "OK", headers: dict[str, str] | None = None) -> None:
        self._body = body
        self._cursor = 0
        self.status = status
        self.reason = reason
        self._headers = headers or {"content-type": "text/event-stream"}

    def read(self, amount: int | None = None) -> bytes:
        if amount is None or amount < 0:
            amount = len(self._body) - self._cursor
        chunk = self._body[self._cursor : self._cursor + amount]
        self._cursor += len(chunk)
        return chunk

    def getheaders(self) -> list[tuple[str, str]]:
        return list(self._headers.items())


class FakeStreamingHTTPResponse:
    def __init__(self, lines: list[bytes], *, status: int = 200, reason: str = "OK", headers: dict[str, str] | None = None) -> None:
        self._buffer = b"".join(lines)
        self._cursor = 0
        self.status = status
        self.reason = reason
        self._headers = headers or {"content-type": "text/event-stream"}
        self.bulk_read_attempted = False
        self.readline_calls = 0

    def read(self, amount: int | None = None) -> bytes:
        if amount != 1:
            self.bulk_read_attempted = True
            raise AssertionError("streaming probe must not call bulk response.read()")
        if self._cursor >= len(self._buffer):
            return b""
        chunk = self._buffer[self._cursor : self._cursor + 1]
        self._cursor += 1
        return chunk

    def readline(self, limit: int = -1) -> bytes:
        del limit
        self.readline_calls += 1
        if self._cursor >= len(self._buffer):
            return b""
        next_newline = self._buffer.find(b"\n", self._cursor)
        if next_newline == -1:
            chunk = self._buffer[self._cursor :]
            self._cursor = len(self._buffer)
            return chunk
        chunk = self._buffer[self._cursor : next_newline + 1]
        self._cursor = next_newline + 1
        return chunk

    def getheaders(self) -> list[tuple[str, str]]:
        return list(self._headers.items())


class FakeConnection:
    def __init__(self, response: FakeHTTPResponse) -> None:
        self.response = response
        self.requests: list[tuple[str, str]] = []
        self.headers: list[tuple[str, str]] = []
        self.ended_with_body: bytes | None = None
        self.connected = False
        self.closed = False

    def connect(self) -> None:
        self.connected = True

    def putrequest(self, method: str, path: str) -> None:
        self.requests.append((method, path))

    def putheader(self, name: str, value: str) -> None:
        self.headers.append((name, value))

    def endheaders(self, body: bytes) -> None:
        self.ended_with_body = body

    def getresponse(self) -> FakeHTTPResponse:
        return self.response

    def close(self) -> None:
        self.closed = True


class LLMGatewaySmokeTests(unittest.TestCase):
    def test_parse_response_body_extracts_stream_content(self) -> None:
        body = (
            b'data: {"choices":[{"delta":{"role":"assistant"}}]}\n\n'
            b'data: {"choices":[{"delta":{"content":"public class "}}]}\n\n'
            b'data: {"choices":[{"delta":{"content":"Demo {}"}}]}\n\n'
            b"data: [DONE]\n\n"
        )

        parsed = llm_gateway_smoke.parse_response_body(body)

        self.assertEqual("stream", parsed["mode"])
        self.assertEqual("public class Demo {}", parsed["output_text"])
        self.assertTrue(parsed["done_seen"])
        self.assertEqual(3, parsed["event_count"])

    def test_probe_gateway_measures_connect_ttft_and_tps(self) -> None:
        fake_response = FakeStreamingHTTPResponse(
            [
                b'data: {"choices":[{"delta":{"content":"public class "}}]}\n',
                b"\n",
                b'data: {"choices":[{"delta":{"content":"Demo {}"}}],"usage":{"completion_tokens":12}}\n',
                b"\n",
                b"data: [DONE]\n",
                b"\n",
            ]
        )
        fake_connection = FakeConnection(fake_response)

        with mock.patch("llm_gateway_smoke.create_connection", return_value=fake_connection), mock.patch(
            "llm_gateway_smoke.time.perf_counter",
            side_effect=[1.0, 1.2, 2.0, 2.7, 4.7],
        ):
            report = llm_gateway_smoke.probe_gateway(
                api_key="test-key",
                base_url="https://example.invalid/v1",
                model="test-model",
                timeout_seconds=30,
                max_tokens=64,
                temperature=0.0,
            )

        self.assertEqual("ok", report["status"])
        self.assertEqual(("POST", "/v1/chat/completions"), fake_connection.requests[0])
        self.assertTrue(fake_connection.connected)
        self.assertTrue(fake_connection.closed)
        self.assertFalse(fake_response.bulk_read_attempted)
        self.assertGreater(fake_response.readline_calls, 0)
        self.assertEqual(0.2, report["metrics"]["connect_time_seconds"])
        self.assertEqual(0.7, report["metrics"]["ttft_seconds"])
        self.assertEqual(2.7, report["metrics"]["total_duration_seconds"])
        self.assertEqual(2.0, report["metrics"]["generation_window_seconds"])
        self.assertEqual(5.0, report["metrics"]["output_estimated_tokens"])
        self.assertEqual(12, report["metrics"]["output_reported_completion_tokens"])
        self.assertEqual(2.5, report["metrics"]["tps_estimated"])
        self.assertEqual(6.0, report["metrics"]["tps_reported"])
        self.assertEqual("public class Demo {}", report["response"]["output_preview"])

    def test_probe_gateway_streaming_ignores_keep_alive_and_usage_heartbeat(self) -> None:
        fake_response = FakeStreamingHTTPResponse(
            [
                b": keep-alive\n",
                b'data: {"usage":{"completion_tokens":9}}\n',
                b'data: {"choices":[{"delta":{"content":"func main() "}}]}\n',
                b'data: {"choices":[{"delta":{"content":"{}"}}]}\n',
                b"data: [DONE]\n",
            ]
        )
        fake_connection = FakeConnection(fake_response)

        with mock.patch("llm_gateway_smoke.create_connection", return_value=fake_connection), mock.patch(
            "llm_gateway_smoke.time.perf_counter",
            side_effect=[10.0, 10.1, 11.0, 11.5, 12.5],
        ):
            report = llm_gateway_smoke.probe_gateway(
                api_key="test-key",
                base_url="https://example.invalid/v1",
                model="test-model",
                timeout_seconds=30,
                max_tokens=64,
                temperature=0.0,
            )

        self.assertEqual("ok", report["status"])
        self.assertEqual("stream", report["response"]["parse_mode"])
        self.assertEqual("func main() {}", report["response"]["output_preview"])
        self.assertTrue(report["response"]["done_seen"])
        self.assertEqual(4, report["response"]["data_event_count"])
        self.assertEqual(3, report["response"]["event_count"])
        self.assertEqual(9, report["metrics"]["output_reported_completion_tokens"])


if __name__ == "__main__":
    unittest.main()
