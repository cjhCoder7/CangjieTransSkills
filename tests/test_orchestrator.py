from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import orchestrator  # noqa: E402


class OrchestratorReviewerJsonRecoveryTests(unittest.TestCase):
    def test_try_parse_json_payload_recovers_from_leading_brace_noise(self) -> None:
        payload = orchestrator.try_parse_json_payload('{\n{"pass": true, "issues": []}')

        self.assertEqual(payload, {"pass": True, "issues": []})

    def test_parse_reviewer_response_accepts_recovered_payload(self) -> None:
        result = orchestrator.parse_reviewer_response(
            '{\n{"pass": true, "issues": []}',
            ["Verification Matrix"],
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.issues, [])

    def test_resolve_frozen_anchor_path_supports_controlled_expansion_modules(self) -> None:
        frozen_dir = PROJECT_ROOT / "tests" / "fixtures" / "anchors"
        cases = {
            "src/core/mtproto/CryptoUtils.ets": "cryptoutils_module_frozen.json",
            "src/core/mtproto/TLSerialization.ets": "tlserialization_module_frozen.json",
            "src/core/mtproto/MTProtoConfig.ets": "mtprotoconfig_module_frozen.json",
            "src/core/mtproto/MTProtoTransport.ets": "mtprototransport_module_frozen.json",
            "src/core/mtproto/AuthKeyCreator.ets": "authkeycreator_module_frozen.json",
            "src/core/mtproto/Inflate.ets": "inflate_module_frozen.json",
        }

        for target_path, filename in cases.items():
            with self.subTest(target_path=target_path):
                anchor_path = orchestrator.resolve_frozen_anchor_path(
                    target_path=target_path,
                    chunk_id="module",
                    frozen_anchor_dir=frozen_dir,
                )
                self.assertIsNotNone(anchor_path)
                self.assertEqual(filename, Path(anchor_path).name)


class RaisingAdapter:
    def __init__(self, exc: Exception) -> None:
        self.exc = exc

    def complete(self, request):
        raise self.exc


class ReturningAdapter:
    def __init__(self, text: str) -> None:
        self.text = text
        self.calls = 0

    def complete(self, request):
        self.calls += 1
        return SimpleNamespace(text=self.text, raw_payload={})


class RaisingTranslator:
    def __init__(self, exc: Exception) -> None:
        self.exc = exc

    def process(self, **kwargs):
        raise self.exc


class SuccessfulTranslator:
    def process(self, **kwargs):
        attempt = int(kwargs.get("attempt", 1))
        return orchestrator.TranslationArtifact(
            attempt=attempt,
            generated_code="main(): Int64 {\n    return 0\n}\n",
            declared_constraints=["Translation Mapping"],
            notes=[],
            metadata={},
        )


class ReturningCodeTranslator:
    def __init__(self, code: str, *, metadata: dict[str, object] | None = None) -> None:
        self.code = code
        self.metadata = metadata or {}
        self.calls = 0

    def process(self, **kwargs):
        self.calls += 1
        attempt = int(kwargs.get("attempt", 1))
        return orchestrator.TranslationArtifact(
            attempt=attempt,
            generated_code=self.code,
            declared_constraints=["Translation Mapping"],
            notes=[],
            metadata=dict(self.metadata),
        )


class ChunkRecordingTranslator:
    def __init__(self) -> None:
        self.calls: list[dict[str, object]] = []

    def process(self, **kwargs):
        tu = kwargs["tu"]
        repair_guidance = list(kwargs.get("repair_guidance", []))
        tu_id = str(tu.get("tu_id", ""))
        self.calls.append(
            {
                "tu_id": tu_id,
                "repair_guidance": repair_guidance,
                "target_source": str(((tu.get("target") or {}) if isinstance(tu.get("target"), dict) else {}).get("source", "")),
            }
        )
        attempt = int(kwargs.get("attempt", 1))
        if tu_id.endswith("::chunk-a"):
            code = (
                "import std.sync.*\n\n"
                "internal class RPCCallback {}\n\n"
                "public class MTProtoClient {\n"
                "    private let session: SessionInfo\n\n"
            )
        elif tu_id.endswith("::chunk-a-ctor"):
            code = (
                "    public init() {}\n"
            )
        elif tu_id.endswith("::chunk-a-callback"):
            code = (
                "    public func setUpdateCallback(callback: (Array<UInt8>) -> Unit): Unit {}\n"
            )
        elif tu_id.endswith("::chunk-a-init"):
            code = (
                "    public func initialize(): Future<Unit> {\n"
                "        spawn { () }\n"
                "    }\n"
            )
        elif tu_id.endswith("::chunk-b"):
            code = (
                "    private func createAuthKey(): Future<Unit> {\n"
                "        spawn { () }\n"
                "    }\n"
            )
        elif tu_id.endswith("::chunk-c"):
            code = (
                "    public func sendRequest(data: Array<UInt8>): Future<Array<UInt8>> {\n"
                "        spawn { [] }\n"
                "    }\n\n"
                "    private func initConnection(): Future<Unit> {\n"
                "        spawn { () }\n"
                "    }\n\n"
                "    public func onConnected(): Unit {}\n"
                "    public func onDisconnected(): Unit {}\n"
                "    public func onData(data: Array<UInt8>): Unit {}\n"
                "    public func onError(error: Error): Unit {}\n"
                "}\n\n"
                "public func getMTProtoClient(): MTProtoClient {\n"
                "    return MTProtoClient()\n"
                "}\n"
            )
        else:
            raise AssertionError(f"unexpected chunk TU: {tu_id}")
        return orchestrator.TranslationArtifact(
            attempt=attempt,
            generated_code=code,
            declared_constraints=["Translation Mapping", "Execution Topology"],
            notes=[f"generated for {tu_id}"],
            metadata={},
        )


class RaisingReviewer:
    def __init__(self, exc: Exception) -> None:
        self.exc = exc

    def process(self, *args, **kwargs):
        raise self.exc


class PassingReviewer:
    def process(self, tu, artifact, required_dimensions):
        return orchestrator.ReviewResult(
            passed=True,
            issues=[],
            required_dimensions=list(required_dimensions),
            raw_text='{"pass": true, "issues": []}',
        )


class AlignmentRuptureReviewer:
    def __init__(self) -> None:
        self.calls = 0

    def process(self, tu, artifact, required_dimensions):
        self.calls += 1
        return orchestrator.ReviewResult(
            passed=False,
            issues=[
                orchestrator.ReviewIssue(
                    code="ARCH_SOURCE_ALIGNMENT_RUPTURE",
                    severity="error",
                    message="candidate drifted from the source-backed native .cj definition",
                    required_dimension="Translation Mapping",
                    evidence="source-backed page must stay aligned with the exact source text",
                )
            ],
            required_dimensions=list(required_dimensions),
            raw_text='{"pass": false, "issues": [{"code": "ARCH_SOURCE_ALIGNMENT_RUPTURE"}]}',
        )


class UnexpectedReviewer:
    def __init__(self) -> None:
        self.calls = 0

    def process(self, *args, **kwargs):
        self.calls += 1
        raise AssertionError("reviewer should have been bypassed")


class UnexpectedTranslator:
    def __init__(self) -> None:
        self.calls = 0

    def process(self, *args, **kwargs):
        self.calls += 1
        raise AssertionError("translator should have been bypassed")


class StaticPassFirewall:
    def process(self, tu, artifact):
        return orchestrator.StaticCheckResult(passed=True, violations=[], scanned_line_count=1, rule_count=0)


class RecordingVerifier:
    def __init__(self) -> None:
        self.calls = 0

    def verify(self, tu, artifact):
        self.calls += 1
        return orchestrator.VerifyResult(
            passed=True,
            status="passed",
            evidence=[],
            failure_type="",
            stage_results=[],
        )


class OrchestratorInfrastructureFailureTests(unittest.TestCase):
    def make_orchestrator(self) -> orchestrator.Orchestrator:
        temp_root = Path(self.temp_dir.name)
        subject = orchestrator.Orchestrator(
            schema_path=orchestrator.DEFAULT_SCHEMA_PATH,
            architecture_skill_paths=[],
            pattern_memory_path=temp_root / "pattern_memory.jsonl",
            pattern_limit=0,
            workspace_root=temp_root / "workspace",
            model="mock-model",
            timeout_seconds=180,
            max_rounds=2,
            use_mock=True,
            llm_max_retries=0,
            verification_config=orchestrator.VerificationConfig(),
            frozen_anchor_dir=temp_root / "anchors",
        )
        return subject

    def make_tu(self) -> dict[str, object]:
        return {
            "tu_id": "tu::tests::service",
            "target": {
                "path": "src/services/TestService.ets",
                "role": "service",
                "risk_tags": [],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
            },
            "dependency_closure": [],
        }

    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)

    def test_translator_network_failure_aborts_without_writing_candidate(self) -> None:
        subject = self.make_orchestrator()
        subject.translator = RaisingTranslator(
            orchestrator.LLMNetworkException(
                "timed out",
                request_payload={
                    "model": "mock-model",
                    "messages": [{"role": "system", "content": "translator prompt"}],
                    "temperature": 0.1,
                    "partial_response_text": "partial candidate",
                },
                timeout_seconds=180,
                partial_response_text="partial candidate",
            )
        )

        result = subject.run(self.make_tu())
        workspace_dir = Path(result["workspace_dir"])
        failure_path = workspace_dir / "attempt-01" / "infrastructure_failure.json"
        partial_dump_path = workspace_dir / "attempt-01" / "partial_transcript_dump.txt"
        failure_payload = json.loads(failure_path.read_text(encoding="utf-8"))

        self.assertEqual("infrastructure-error", result["final_status"])
        self.assertEqual("infrastructure-error", result["failure_class"])
        self.assertEqual("translator-api", result["infrastructure_failure"]["stage"])
        self.assertEqual(180, result["infrastructure_failure"]["timeout_seconds"])
        self.assertEqual("translator prompt", result["infrastructure_failure"]["request_payload"]["messages"][0]["content"])
        self.assertEqual("skipped", result["final_verify"]["status"])
        self.assertEqual([], list(workspace_dir.rglob("*.cj")))
        self.assertTrue(partial_dump_path.exists())
        self.assertEqual("partial candidate", partial_dump_path.read_text(encoding="utf-8"))
        self.assertEqual(result["infrastructure_failure"], failure_payload)

    def test_reviewer_network_failure_aborts_without_invoking_verify(self) -> None:
        subject = self.make_orchestrator()
        subject.translator = SuccessfulTranslator()
        subject.static_firewall = StaticPassFirewall()
        subject.reviewer = RaisingReviewer(
            orchestrator.LLMNetworkException(
                "timed out",
                request_payload={
                    "model": "mock-model",
                    "messages": [{"role": "system", "content": "reviewer prompt"}],
                    "temperature": 0.0,
                    "response_format": {"type": "json_object"},
                },
                timeout_seconds=180,
            )
        )
        verifier = RecordingVerifier()
        subject.verifier = verifier

        result = subject.run(self.make_tu())
        workspace_dir = Path(result["workspace_dir"])
        candidate_files = list(workspace_dir.rglob("*.cj"))
        failure_path = workspace_dir / "attempt-01" / "infrastructure_failure.json"
        failure_payload = json.loads(failure_path.read_text(encoding="utf-8"))

        self.assertEqual("infrastructure-error", result["final_status"])
        self.assertEqual("reviewer-api", result["infrastructure_failure"]["stage"])
        self.assertEqual(180, result["infrastructure_failure"]["timeout_seconds"])
        self.assertEqual("reviewer prompt", result["infrastructure_failure"]["request_payload"]["messages"][0]["content"])
        self.assertEqual(0, verifier.calls)
        self.assertEqual(1, len(candidate_files))
        self.assertGreater(candidate_files[0].stat().st_size, 0)
        self.assertFalse((workspace_dir / "attempt-01" / "verify_result.json").exists())
        self.assertEqual(result["infrastructure_failure"], failure_payload)

    def test_mtprotoclient_bypasses_reviewer_and_invokes_verify(self) -> None:
        subject = self.make_orchestrator()
        subject.translator = SuccessfulTranslator()
        subject.static_firewall = StaticPassFirewall()
        reviewer = UnexpectedReviewer()
        subject.reviewer = reviewer
        verifier = RecordingVerifier()
        subject.verifier = verifier
        tu = {
            "tu_id": "tu::tests::mtproto-client-review-bypass",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": "export class MTProtoClient {}",
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        review_path = workspace_dir / "attempt-01" / "review_result.json"
        review_payload = json.loads(review_path.read_text(encoding="utf-8"))

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(0, reviewer.calls)
        self.assertEqual(1, verifier.calls)
        self.assertTrue(review_path.exists())
        self.assertTrue(review_payload["passed"])
        self.assertEqual([], review_payload["issues"])
        self.assertIn('"bypassed": true', review_payload["raw_text"])
        self.assertIn("temporary targeted bypass", review_payload["raw_text"])

    def test_realmessageservice_bypasses_reviewer_and_invokes_verify(self) -> None:
        subject = self.make_orchestrator()
        subject.translator = SuccessfulTranslator()
        subject.static_firewall = StaticPassFirewall()
        reviewer = UnexpectedReviewer()
        subject.reviewer = reviewer
        verifier = RecordingVerifier()
        subject.verifier = verifier
        tu = {
            "tu_id": "tu::tests::real-message-service-review-bypass",
            "target": {
                "path": "src/services/RealMessageService.ets",
                "role": "service",
                "summary": "Real message service",
                "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": "export class RealMessageService {}",
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        review_path = workspace_dir / "attempt-01" / "review_result.json"
        review_payload = json.loads(review_path.read_text(encoding="utf-8"))

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(0, reviewer.calls)
        self.assertEqual(1, verifier.calls)
        self.assertTrue(review_path.exists())
        self.assertTrue(review_payload["passed"])
        self.assertEqual([], review_payload["issues"])
        self.assertIn('"bypassed": true', review_payload["raw_text"])
        self.assertIn("src/services/RealMessageService.ets", review_payload["raw_text"])
        self.assertIn("static-passed service candidate", review_payload["raw_text"])
        self.assertIn("verifier real compile probe", review_payload["raw_text"])

    def test_phase06_source_backed_native_cangjie_equivalent_bypasses_reviewer_and_invokes_verify(self) -> None:
        subject = self.make_orchestrator()
        source_text = """/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package photoView

public class PhotoViewModel {
    var helpText: String = "http://example.com // keep"
    // source-backed comment
    public func setVertical(isVertical: Bool): PhotoViewModel {
        return this
    }
}
"""
        candidate_text = """package photoView

public class PhotoViewModel {
    var helpText: String = "http://example.com // keep"

    public func setVertical(isVertical: Bool): PhotoViewModel {
        return this
    }
}
"""
        subject.translator = ReturningCodeTranslator(candidate_text)
        subject.static_firewall = StaticPassFirewall()
        reviewer = UnexpectedReviewer()
        subject.reviewer = reviewer
        verifier = RecordingVerifier()
        subject.verifier = verifier
        tu = {
            "tu_id": "tu::tests::phase06-ui-native-review-bypass",
            "target": {
                "path": "photo_view_model.cj",
                "role": "viewmodel",
                "summary": "Phase06 native source-backed viewmodel",
                "risk_tags": ["model"],
                "state_tags": ["state-decorator"],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
                "ui_prompt_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": ["gesture-component"],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        review_path = workspace_dir / "attempt-01" / "review_result.json"
        review_payload = json.loads(review_path.read_text(encoding="utf-8"))

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(0, reviewer.calls)
        self.assertEqual(1, verifier.calls)
        self.assertTrue(review_path.exists())
        self.assertTrue(review_payload["passed"])
        self.assertEqual([], review_payload["issues"])
        self.assertIn('"bypassed": true', review_payload["raw_text"])
        self.assertIn("initial source-backed native .cj baseline special lane", review_payload["raw_text"])
        self.assertIn("source-equivalent after comment + verifier-compatible declaration-head normalization", review_payload["raw_text"])

    def test_phase06_source_backed_native_cangjie_equivalent_allows_verifier_compatible_declaration_head_normalization(self) -> None:
        tu = {
            "tu_id": "tu::tests::phase06-ui-native-review-bypass-normalized",
            "target": {
                "path": "editor_kit/editorText.cj",
                "role": "component",
                "summary": "Phase06 native source-backed component",
                "risk_tags": ["component"],
                "state_tags": ["state-decorator"],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": """package editor_kit
public class EditorKitController {
    public func setWidth(width!: Float64): Unit {
        return ()
    }
}
""",
                "ui_prompt_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            },
            "dependency_closure": [],
        }
        artifact = orchestrator.TranslationArtifact(
            attempt=1,
            generated_code="""package editor_kit
public class EditorKitController {
    public func setWidth(width: Float64): Unit {
        return ()
    }
}
""",
            declared_constraints=["Translation Mapping"],
            notes=[],
            metadata={},
        )

        self.assertTrue(orchestrator.is_phase06_source_backed_native_cangjie_equivalent(tu, artifact))
        reason = orchestrator.resolve_reviewer_bypass_reason(tu, artifact)
        self.assertIsNotNone(reason)
        self.assertIn("source-equivalent after comment + verifier-compatible declaration-head normalization", reason)

    def test_phase06_large_source_backed_native_cangjie_special_lane_bypasses_translator_and_reviewer(self) -> None:
        subject = self.make_orchestrator()
        helper_noise = "".join(f"    private func helper{i}(): Unit {{ return () }}\n" for i in range(220))
        source_text = (
            """package editor_kit
from ohos import component.*
from ohos import state_manage.*

public class EditorKitController {
    public EditorKitController(
        private var width!: Float64,
        private var height!: Float64,
    ) {}
    func updateEditorSpanStyle(index!: Int32 = -1): Unit {
        return ()
    }
"""
            + helper_noise
            + """}

@Component
public class EditorKit {
    public func render() {
        Text("editor")
    }
}
"""
        )
        subject.translator = UnexpectedTranslator()
        subject.static_firewall = StaticPassFirewall()
        reviewer = UnexpectedReviewer()
        subject.reviewer = reviewer
        verifier = RecordingVerifier()
        subject.verifier = verifier
        tu = {
            "tu_id": "tu::tests::phase06-ui-native-special-lane",
            "target": {
                "path": "editor_kit/editorText.cj",
                "role": "component",
                "summary": "Phase06 large native source-backed component",
                "risk_tags": ["component"],
                "state_tags": ["state-decorator"],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
                "ui_prompt_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        candidate_path = workspace_dir / "attempt-01" / "editor_kit" / "editorText.cj"
        review_path = workspace_dir / "attempt-01" / "review_result.json"
        review_payload = json.loads(review_path.read_text(encoding="utf-8"))
        candidate_text = candidate_path.read_text(encoding="utf-8")

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(0, subject.translator.calls)
        self.assertEqual(0, reviewer.calls)
        self.assertEqual(1, verifier.calls)
        self.assertTrue(result["final_artifact"]["metadata"]["source_backed_native_cangjie_special_lane"])
        self.assertGreater(result["final_artifact"]["metadata"]["source_backed_native_cangjie_postfix_normalization_count"], 0)
        self.assertIn("private var width: Float64", candidate_text)
        self.assertIn("func updateEditorSpanStyle(index: Int32 = -1): Unit", candidate_text)
        self.assertIn("private func helper219(): Unit", candidate_text)
        self.assertNotIn("source excerpt truncated for large Phase06 UI target", candidate_text)
        self.assertIn("large source-backed native .cj special lane", review_payload["raw_text"])
        self.assertIn("source-equivalent after comment + verifier-compatible declaration-head normalization", review_payload["raw_text"])

    def test_phase06_small_source_backed_native_cangjie_initial_baseline_bypasses_translator_and_reviewer(self) -> None:
        subject = self.make_orchestrator()
        subject.translator = UnexpectedTranslator()
        subject.static_firewall = StaticPassFirewall()
        reviewer = UnexpectedReviewer()
        subject.reviewer = reviewer
        verifier = RecordingVerifier()
        subject.verifier = verifier
        source_text = """package ohos_app_cangjie_entry.services
import encoding.json.JsonValue
import std.collection.ArrayList

import ohos.resource_manager.ResourceManager

import ohos_app_cangjie_entry.models.*

public class ChartDataServices {
    private let resourceManager: ResourceManager

    private func loadAndParseData<T>(filename: String, jsonKey: String, parser: (JsonValue) -> Option<T>): ArrayList<T> {
        let result = ArrayList<T>()
        result
    }

    public func loadTimeLineData(): ArrayList<TimeLineDataPoint> {
        return loadAndParseData("MockTimeLineData.json", "timeLineData") { itemVal =>
            None
        }
    }
}
"""
        tu = {
            "tu_id": "tu::tests::phase06-ui-native-initial-baseline",
            "target": {
                "path": "services/ChartDataService.cj",
                "role": "viewmodel",
                "summary": "Phase06 small native source-backed stock chart service helper",
                "risk_tags": ["viewmodel", "list-or-grid"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
                "ui_prompt_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "view-model-renderer",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        candidate_path = workspace_dir / "attempt-01" / "services" / "ChartDataService.cj"
        review_path = workspace_dir / "attempt-01" / "review_result.json"
        review_payload = json.loads(review_path.read_text(encoding="utf-8"))
        candidate_text = candidate_path.read_text(encoding="utf-8")

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(0, subject.translator.calls)
        self.assertEqual(0, reviewer.calls)
        self.assertEqual(1, verifier.calls)
        self.assertTrue(result["final_artifact"]["metadata"]["source_backed_native_cangjie_special_lane"])
        self.assertEqual(
            "initial-source-baseline",
            result["final_artifact"]["metadata"]["source_backed_native_cangjie_special_lane_reason"],
        )
        self.assertIn("initial source-backed native .cj baseline special lane", review_payload["raw_text"])
        self.assertEqual(
            orchestrator._normalize_source_backed_native_cangjie_text(source_text),
            orchestrator._normalize_source_backed_native_cangjie_text(candidate_text),
        )

    def test_phase06_source_backed_native_cangjie_alignment_repair_special_lane_promotes_after_review_failure(self) -> None:
        subject = self.make_orchestrator()
        subject.seed_repair_anchor = orchestrator.build_repair_anchor_payload(
            code="package ohos_app_cangjie_entry\nclass SeedAnchor {}\n",
            label="seed-anchor-for-alignment-repair-test",
            source_path="tests/fixtures/seed-anchor.cj",
        )
        source_text = """package ohos_app_cangjie_entry

@Entry
@Component
class NewsDetailView {
    @State var imageIp: String = "http://192.168.3.11:8000"
    @State var strLike: String = ""

    func build() {
        Row() {
            Text("👉 分享")
            Text("💬 0")
            Text(strLike)
            Text("🌟 收藏")
        }
    }
}
"""
        candidate_text = """package ohos_app_cangjie_entry

@Entry
@Component
class NewsDetailView {
    @State var imageIp: String = "http:"
    @State var strLike: String = ""

    func build() {
        Row() {
            Text("👉 分享")
            Text("💬 0")
            Text(strLike)
            Text("🌟 收藏")
            Text("🌟 收藏")
        }
    }
}
"""
        translator = ReturningCodeTranslator(candidate_text)
        subject.translator = translator
        subject.static_firewall = StaticPassFirewall()
        reviewer = AlignmentRuptureReviewer()
        subject.reviewer = reviewer
        verifier = RecordingVerifier()
        subject.verifier = verifier
        tu = {
            "tu_id": "tu::tests::phase06-ui-native-alignment-repair",
            "target": {
                "path": "news_detail.cj",
                "role": "page",
                "summary": "Phase06 native source-backed detail page",
                "risk_tags": ["page"],
                "state_tags": ["state-decorator"],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
                "ui_prompt_tags": {
                    "structure_tag": "mixed-app-pattern",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": ["page"],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        candidate_path = workspace_dir / "attempt-02" / "news_detail.cj"
        review_path = workspace_dir / "attempt-02" / "review_result.json"
        review_payload = json.loads(review_path.read_text(encoding="utf-8"))
        candidate_text = candidate_path.read_text(encoding="utf-8")

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(1, translator.calls)
        self.assertEqual(1, reviewer.calls)
        self.assertEqual(2, verifier.calls)
        self.assertTrue(result["final_artifact"]["metadata"]["source_backed_native_cangjie_special_lane"])
        self.assertEqual(
            "review-alignment-repair",
            result["final_artifact"]["metadata"]["source_backed_native_cangjie_special_lane_reason"],
        )
        self.assertTrue(review_payload["passed"])
        self.assertIn("alignment-repair special lane", review_payload["raw_text"])
        self.assertIn("http://192.168.3.11:8000", candidate_text)
        self.assertEqual(
            orchestrator._normalize_source_backed_native_cangjie_text(source_text),
            orchestrator._normalize_source_backed_native_cangjie_text(candidate_text),
        )

    def test_phase06_source_backed_native_cangjie_equivalent_requires_exact_non_comment_structure(self) -> None:
        tu = {
            "tu_id": "tu::tests::phase06-ui-native-review-bypass-check",
            "target": {
                "path": "photo_view_model.cj",
                "role": "viewmodel",
                "summary": "Phase06 native source-backed viewmodel",
                "risk_tags": ["model"],
                "state_tags": ["state-decorator"],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": "package photoView\npublic class PhotoViewModel {\n    public func setScale(sca: Float64, anima: Bool): PhotoViewModel {\n        return this\n    }\n}\n",
                "phase06_ui_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": ["gesture-component"],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
            },
            "dependency_closure": [],
        }
        artifact = orchestrator.TranslationArtifact(
            attempt=1,
            generated_code="package photoView\npublic class PhotoViewModel {\n    public func setScale(scale: Float64): PhotoViewModel {\n        return this\n    }\n}\n",
            declared_constraints=["Translation Mapping"],
            notes=[],
            metadata={},
        )

        self.assertFalse(orchestrator.is_phase06_source_backed_native_cangjie_equivalent(tu, artifact))
        self.assertIsNone(orchestrator.resolve_reviewer_bypass_reason(tu, artifact))

    def test_mtprotoclient_chunked_translation_assembles_single_candidate_and_injects_cumulative_readonly_stub(self) -> None:
        subject = self.make_orchestrator()
        translator = ChunkRecordingTranslator()
        subject.translator = translator
        subject.static_firewall = StaticPassFirewall()
        subject.reviewer = PassingReviewer()
        verifier = RecordingVerifier()
        subject.verifier = verifier
        source_path = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
        source_text = source_path.read_text(encoding="utf-8")
        tu = {
            "tu_id": "tu::tests::mtproto-client",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        candidate_path = workspace_dir / "attempt-01" / "src" / "core" / "mtproto" / "MTProtoClient.cj"
        candidate_text = candidate_path.read_text(encoding="utf-8")
        chunk_plan_path = workspace_dir / "attempt-01" / "chunk_plan.json"
        chunk_artifact_path = workspace_dir / "attempt-01" / "translation_chunk-a.json"

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(1, verifier.calls)
        self.assertEqual(
            [
                "tu::tests::mtproto-client::chunk-a",
                "tu::tests::mtproto-client::chunk-a-ctor",
                "tu::tests::mtproto-client::chunk-a-callback",
                "tu::tests::mtproto-client::chunk-a-init",
                "tu::tests::mtproto-client::chunk-b",
                "tu::tests::mtproto-client::chunk-c",
            ],
            [str(item["tu_id"]) for item in translator.calls],
        )
        self.assertIn("[READ-ONLY TRANSLATED STUB FROM PREVIOUS CHUNKS]", "\n".join(str(item) for item in translator.calls[1]["repair_guidance"]))
        self.assertIn("public class MTProtoClient", "\n".join(str(item) for item in translator.calls[1]["repair_guidance"]))
        self.assertIn("Chunk A-Constructor", "\n".join(str(item) for item in translator.calls[1]["repair_guidance"]))
        self.assertIn("public init() {}", "\n".join(str(item) for item in translator.calls[2]["repair_guidance"]))
        self.assertIn("Chunk A-Callback", "\n".join(str(item) for item in translator.calls[2]["repair_guidance"]))
        self.assertIn("这是一个同步 setter chunk", "\n".join(str(item) for item in translator.calls[2]["repair_guidance"]))
        self.assertIn("public func setUpdateCallback(callback: (Array<UInt8>) -> Unit): Unit {}", "\n".join(str(item) for item in translator.calls[3]["repair_guidance"]))
        self.assertIn("public func initialize(): Future<Unit> {}", "\n".join(str(item) for item in translator.calls[4]["repair_guidance"]))
        self.assertIn("private func createAuthKey(): Future<Unit> {}", "\n".join(str(item) for item in translator.calls[5]["repair_guidance"]))
        self.assertIn("`public func await()`、`awaitResult()`、`waiter.await()`", "\n".join(str(item) for item in translator.calls[5]["repair_guidance"]))
        self.assertTrue(candidate_path.exists())
        self.assertTrue(chunk_plan_path.exists())
        self.assertTrue(chunk_artifact_path.exists())
        self.assertIn("private func createAuthKey(): Future<Unit>", candidate_text)
        self.assertIn("public func sendRequest(data: Array<UInt8>): Future<Array<UInt8>>", candidate_text)
        self.assertIn("public func getMTProtoClient(): MTProtoClient", candidate_text)
        self.assertTrue(result["final_artifact"]["metadata"]["chunked_translation"])
        self.assertEqual(
            ["chunk-a", "chunk-a-ctor", "chunk-a-callback", "chunk-a-init", "chunk-b", "chunk-c"],
            result["final_artifact"]["metadata"]["chunk_ids"],
        )

    def test_mtprotoclient_chunked_translation_uses_frozen_anchor_for_chunk_a(self) -> None:
        subject = self.make_orchestrator()
        anchor_dir = Path(self.temp_dir.name) / "anchors"
        anchor_dir.mkdir(parents=True, exist_ok=True)
        anchor_path = anchor_dir / "mtprotoclient_chunk_a_frozen.json"
        anchor_payload = {
            "chunk": {
                "chunk_id": "chunk-a",
                "label": "State Skeleton",
                "description": "imports, helper declarations, MTProtoClient class header, and state fields only",
                "source_text": "class RPCCallback {}\nexport class MTProtoClient implements TransportCallback {}\n",
                "expected_members": [],
                "found_members": [],
                "missing_members": [],
            },
            "artifact": {
                "attempt": 1,
                "generated_code": (
                    "import std.sync.*\n"
                    "import std.collection.*\n\n"
                    "class RPCCallback {\n"
                    "    public var resolve: (Array<UInt8>) -> Unit\n"
                    "    public var reject: (Error) -> Unit\n"
                    "    public var timeoutId: Int64\n"
                    "\n"
                    "    public init(resolve: (Array<UInt8>) -> Unit, reject: (Error) -> Unit, timeoutId: Int64) {\n"
                    "        this.resolve = resolve\n"
                    "        this.reject = reject\n"
                    "        this.timeoutId = timeoutId\n"
                    "    }\n"
                    "}\n\n"
                    "public class MTProtoClient <: TransportCallback {\n"
                    "    private var transportManager: TransportManager\n"
                    "    private var session: SessionInfo\n"
                    "    private var pendingRPCs: HashMap<String, RPCCallback> = HashMap<String, RPCCallback>()\n"
                    "    private var updateCallback: ?((Array<UInt8>) -> Unit) = None\n"
                    "    private var connectionInitialized: Bool = false"
                ),
                "declared_constraints": [
                    "Translation Mapping",
                    "Dependency Constraint",
                ],
                "notes": [
                    "fixture frozen chunk-a anchor",
                ],
                "metadata": {
                    "target_path": "src/core/mtproto/MTProtoClient.ets",
                    "repair_thought_process": "fixture frozen anchor",
                },
            },
        }
        anchor_path.write_text(json.dumps(anchor_payload, ensure_ascii=False, indent=2), encoding="utf-8")

        translator = ChunkRecordingTranslator()
        subject.translator = translator
        subject.static_firewall = StaticPassFirewall()
        subject.reviewer = PassingReviewer()
        verifier = RecordingVerifier()
        subject.verifier = verifier
        source_path = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
        source_text = source_path.read_text(encoding="utf-8")
        tu = {
            "tu_id": "tu::tests::mtproto-client-frozen-anchor",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        chunk_artifact_path = workspace_dir / "attempt-01" / "translation_chunk-a.json"
        readonly_stub_path = workspace_dir / "attempt-01" / "readonly_stub_after_chunk-a.json"
        chunk_payload = json.loads(chunk_artifact_path.read_text(encoding="utf-8"))
        readonly_stub_payload = json.loads(readonly_stub_path.read_text(encoding="utf-8"))

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(1, verifier.calls)
        self.assertEqual(
            [
                "tu::tests::mtproto-client-frozen-anchor::chunk-a-ctor",
                "tu::tests::mtproto-client-frozen-anchor::chunk-a-callback",
                "tu::tests::mtproto-client-frozen-anchor::chunk-a-init",
                "tu::tests::mtproto-client-frozen-anchor::chunk-b",
                "tu::tests::mtproto-client-frozen-anchor::chunk-c",
            ],
            [str(item["tu_id"]) for item in translator.calls],
        )
        self.assertTrue(chunk_artifact_path.exists())
        self.assertTrue(readonly_stub_path.exists())
        self.assertTrue(chunk_payload["artifact"]["metadata"]["frozen_anchor"])
        self.assertEqual(str(anchor_path.resolve()), chunk_payload["artifact"]["metadata"]["frozen_anchor_path"])
        self.assertIn("loaded frozen anchor", "\n".join(chunk_payload["artifact"]["notes"]))
        self.assertIn("import std.sync.*", readonly_stub_payload["stub"])
        self.assertIn("public class MTProtoClient", readonly_stub_payload["stub"])
        self.assertIn("pendingRPCs", readonly_stub_payload["stub"])
        self.assertIn("[READ-ONLY TRANSLATED STUB FROM PREVIOUS CHUNKS]", "\n".join(str(item) for item in translator.calls[0]["repair_guidance"]))
        self.assertIn("pendingRPCs", "\n".join(str(item) for item in translator.calls[0]["repair_guidance"]))

    def test_mtprotoclient_chunked_translation_uses_frozen_anchor_for_chunk_a_init(self) -> None:
        subject = self.make_orchestrator()
        anchor_dir = Path(self.temp_dir.name) / "anchors"
        anchor_dir.mkdir(parents=True, exist_ok=True)
        anchor_path = anchor_dir / "mtprotoclient_chunk_a_init_frozen.json"
        anchor_payload = {
            "chunk": {
                "chunk_id": "chunk-a-init",
                "label": "Initialize Flow",
                "description": "initialize overloads only",
                "source_text": "async initialize(forceNewAuthKey: boolean = false): Promise<void> {}\n",
                "expected_members": ["initialize"],
                "found_members": ["initialize"],
                "missing_members": [],
            },
            "artifact": {
                "attempt": 1,
                "generated_code": (
                    "public func initialize(): Future<Unit> {\n"
                    "    return initialize(false)\n"
                    "}\n\n"
                    "public func initialize(forceNewAuthKey: Bool): Future<Unit> {\n"
                    "    spawn {\n"
                    "        let transport = this.transportManager.getTransport()\n"
                    "        transport.setCallback(this)\n"
                    "        if (forceNewAuthKey) {\n"
                    "            this.session.authKey = None\n"
                    "            this.session.authKeyState = AuthKeyState.None\n"
                    "        }\n"
                    "        transport.connect().get()\n"
                    "        if (this.session.authKey.isNone()) {\n"
                    "            this.createAuthKey().get()\n"
                    "        }\n"
                    "    }\n"
                    "}"
                ),
                "declared_constraints": [
                    "Translation Mapping",
                    "Dependency Constraint",
                    "Execution Topology",
                ],
                "notes": [
                    "fixture frozen chunk-a-init anchor",
                ],
                "metadata": {
                    "target_path": "src/core/mtproto/MTProtoClient.ets",
                    "repair_thought_process": "fixture frozen anchor",
                },
            },
        }
        anchor_path.write_text(json.dumps(anchor_payload, ensure_ascii=False, indent=2), encoding="utf-8")

        translator = ChunkRecordingTranslator()
        subject.translator = translator
        subject.static_firewall = StaticPassFirewall()
        subject.reviewer = PassingReviewer()
        verifier = RecordingVerifier()
        subject.verifier = verifier
        source_path = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
        source_text = source_path.read_text(encoding="utf-8")
        tu = {
            "tu_id": "tu::tests::mtproto-client-frozen-anchor-init",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        chunk_artifact_path = workspace_dir / "attempt-01" / "translation_chunk-a-init.json"
        readonly_stub_path = workspace_dir / "attempt-01" / "readonly_stub_after_chunk-a-init.json"
        chunk_payload = json.loads(chunk_artifact_path.read_text(encoding="utf-8"))
        readonly_stub_payload = json.loads(readonly_stub_path.read_text(encoding="utf-8"))

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(1, verifier.calls)
        self.assertEqual(
            [
                "tu::tests::mtproto-client-frozen-anchor-init::chunk-a",
                "tu::tests::mtproto-client-frozen-anchor-init::chunk-a-ctor",
                "tu::tests::mtproto-client-frozen-anchor-init::chunk-a-callback",
                "tu::tests::mtproto-client-frozen-anchor-init::chunk-b",
                "tu::tests::mtproto-client-frozen-anchor-init::chunk-c",
            ],
            [str(item["tu_id"]) for item in translator.calls],
        )
        self.assertTrue(chunk_artifact_path.exists())
        self.assertTrue(readonly_stub_path.exists())
        self.assertTrue(chunk_payload["artifact"]["metadata"]["frozen_anchor"])
        self.assertEqual(str(anchor_path.resolve()), chunk_payload["artifact"]["metadata"]["frozen_anchor_path"])
        self.assertIn("loaded frozen anchor", "\n".join(chunk_payload["artifact"]["notes"]))
        self.assertIn("public func initialize(): Future<Unit> {}", readonly_stub_payload["stub"])
        self.assertIn("public func initialize(forceNewAuthKey: Bool): Future<Unit> {}", readonly_stub_payload["stub"])
        self.assertIn("[READ-ONLY TRANSLATED STUB FROM PREVIOUS CHUNKS]", "\n".join(str(item) for item in translator.calls[3]["repair_guidance"]))
        self.assertIn("public func initialize(): Future<Unit> {}", "\n".join(str(item) for item in translator.calls[3]["repair_guidance"]))

    def test_mtprotoclient_chunked_translation_uses_frozen_anchor_for_chunk_a_ctor(self) -> None:
        subject = self.make_orchestrator()
        anchor_dir = Path(self.temp_dir.name) / "anchors"
        anchor_dir.mkdir(parents=True, exist_ok=True)
        anchor_path = anchor_dir / "mtprotoclient_chunk_a_ctor_frozen.json"
        anchor_payload = {
            "chunk": {
                "chunk_id": "chunk-a-ctor",
                "label": "Constructor",
                "description": "constructor member only",
                "source_text": "constructor() {\n  this.transportManager = new TransportManager()\n  this.session = SessionManager.getSession(MTProtoConfig.USE_TEST_DC ? 2 : 1)\n}\n",
                "expected_members": ["constructor"],
                "found_members": ["constructor"],
                "missing_members": [],
            },
            "artifact": {
                "attempt": 1,
                "generated_code": (
                    "public init() {\n"
                    "    this.transportManager = TransportManager()\n"
                    "    let dcId = if (MTProtoConfig.USE_TEST_DC) { 2 } else { 1 }\n"
                    "    this.session = SessionManager.getSession(dcId)\n"
                    "}"
                ),
                "declared_constraints": [
                    "Translation Mapping",
                    "Dependency Constraint",
                ],
                "notes": [
                    "fixture frozen chunk-a-ctor anchor",
                ],
                "metadata": {
                    "target_path": "src/core/mtproto/MTProtoClient.ets",
                    "repair_thought_process": "fixture frozen anchor",
                },
            },
        }
        anchor_path.write_text(json.dumps(anchor_payload, ensure_ascii=False, indent=2), encoding="utf-8")

        translator = ChunkRecordingTranslator()
        subject.translator = translator
        subject.static_firewall = StaticPassFirewall()
        subject.reviewer = PassingReviewer()
        verifier = RecordingVerifier()
        subject.verifier = verifier
        source_path = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
        source_text = source_path.read_text(encoding="utf-8")
        tu = {
            "tu_id": "tu::tests::mtproto-client-frozen-anchor-ctor",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        chunk_artifact_path = workspace_dir / "attempt-01" / "translation_chunk-a-ctor.json"
        readonly_stub_path = workspace_dir / "attempt-01" / "readonly_stub_after_chunk-a-ctor.json"
        chunk_payload = json.loads(chunk_artifact_path.read_text(encoding="utf-8"))
        readonly_stub_payload = json.loads(readonly_stub_path.read_text(encoding="utf-8"))

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(1, verifier.calls)
        self.assertEqual(
            [
                "tu::tests::mtproto-client-frozen-anchor-ctor::chunk-a",
                "tu::tests::mtproto-client-frozen-anchor-ctor::chunk-a-callback",
                "tu::tests::mtproto-client-frozen-anchor-ctor::chunk-a-init",
                "tu::tests::mtproto-client-frozen-anchor-ctor::chunk-b",
                "tu::tests::mtproto-client-frozen-anchor-ctor::chunk-c",
            ],
            [str(item["tu_id"]) for item in translator.calls],
        )
        self.assertTrue(chunk_artifact_path.exists())
        self.assertTrue(readonly_stub_path.exists())
        self.assertTrue(chunk_payload["artifact"]["metadata"]["frozen_anchor"])
        self.assertEqual(str(anchor_path.resolve()), chunk_payload["artifact"]["metadata"]["frozen_anchor_path"])
        self.assertIn("loaded frozen anchor", "\n".join(chunk_payload["artifact"]["notes"]))
        self.assertIn("public init() {}", readonly_stub_payload["stub"])
        self.assertNotIn("MTProtoConfig.USE_TEST_DC ? 2 : 1", readonly_stub_payload["stub"])
        self.assertIn("[READ-ONLY TRANSLATED STUB FROM PREVIOUS CHUNKS]", "\n".join(str(item) for item in translator.calls[1]["repair_guidance"]))
        self.assertIn("public init() {}", "\n".join(str(item) for item in translator.calls[1]["repair_guidance"]))

    def test_mtprotoclient_chunked_translation_uses_frozen_anchor_for_chunk_c(self) -> None:
        subject = self.make_orchestrator()
        anchor_dir = Path(self.temp_dir.name) / "anchors"
        anchor_dir.mkdir(parents=True, exist_ok=True)
        anchor_path = anchor_dir / "mtprotoclient_chunk_c_frozen.json"
        anchor_payload = {
            "chunk": {
                "chunk_id": "chunk-c",
                "label": "Network I/O",
                "description": "remaining network I/O, callbacks, class tail, and singleton tail",
                "source_text": "async sendRequest(data: Uint8Array): Promise<Uint8Array> {}\nprivate async initConnection(): Promise<void> {}\nonData(data: Uint8Array): void {}\n",
                "expected_members": ["sendRequest", "initConnection", "onConnected", "onDisconnected", "onData", "onError", "getMTProtoClient"],
                "found_members": ["sendRequest", "initConnection", "onConnected", "onDisconnected", "onData", "onError", "getMTProtoClient"],
                "missing_members": [],
            },
            "artifact": {
                "attempt": 1,
                "generated_code": (
                    "  public func sendRequest(data: Array<UInt8>): Future<Array<UInt8>> {\n"
                    "    spawn {\n"
                    "      if (!this.connectionInitialized) {\n"
                    "        this.initConnection().get()\n"
                    "      }\n"
                    "      let waiter = RPCWaiter()\n"
                    "      this.transportManager.getTransport().send(data)\n"
                    "      waiter.takeResult()\n"
                    "    }\n"
                    "  }\n\n"
                    "  private func initConnection(): Future<Unit> { spawn { () } }\n"
                    "  public func onConnected(): Unit {}\n"
                    "  public func onDisconnected(): Unit {}\n"
                    "  public func onData(data: Array<UInt8>): Unit {}\n"
                    "  public func onError(error: Error): Unit {}\n"
                    "}\n\n"
                    "internal class RPCWaiter {\n"
                    "    private var result: ?Array<UInt8> = None\n"
                    "    private var error: ?Error = None\n"
                    "    private var completed: Bool = false\n"
                    "    public func setResult(arr: Array<UInt8>): Unit { this.result = Some(arr); this.completed = true }\n"
                    "    public func setError(err: Error): Unit { this.error = Some(err); this.completed = true }\n"
                    "    public func takeResult(): Array<UInt8> { while (!this.completed) {}; match (this.error) { case Some(e) => throw e case None => match (this.result) { case Some(arr) => arr case None => [] } } }\n"
                    "}\n\n"
                    "private var clientSingleton: ?MTProtoClient = None\n"
                    "private func initSingleton(): MTProtoClient { let client = MTProtoClient(); clientSingleton = Some(client); client }\n"
                    "public func getMTProtoClient(): MTProtoClient { match (clientSingleton) { case Some(client) => client case None => initSingleton() } }\n"
                ),
                "declared_constraints": [
                    "Translation Mapping",
                    "Verification Matrix",
                    "Dependency Constraint",
                    "Execution Topology",
                ],
                "notes": [
                    "fixture frozen chunk-c anchor",
                ],
                "metadata": {
                    "target_path": "src/core/mtproto/MTProtoClient.ets",
                    "repair_thought_process": "fixture frozen anchor",
                },
            },
        }
        anchor_path.write_text(json.dumps(anchor_payload, ensure_ascii=False, indent=2), encoding="utf-8")

        translator = ChunkRecordingTranslator()
        subject.translator = translator
        subject.static_firewall = StaticPassFirewall()
        subject.reviewer = PassingReviewer()
        verifier = RecordingVerifier()
        subject.verifier = verifier
        source_path = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
        source_text = source_path.read_text(encoding="utf-8")
        tu = {
            "tu_id": "tu::tests::mtproto-client-frozen-anchor-c",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        chunk_artifact_path = workspace_dir / "attempt-01" / "translation_chunk-c.json"
        candidate_path = workspace_dir / "attempt-01" / "src" / "core" / "mtproto" / "MTProtoClient.cj"
        chunk_payload = json.loads(chunk_artifact_path.read_text(encoding="utf-8"))
        candidate_text = candidate_path.read_text(encoding="utf-8")

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(1, verifier.calls)
        self.assertEqual(
            [
                "tu::tests::mtproto-client-frozen-anchor-c::chunk-a",
                "tu::tests::mtproto-client-frozen-anchor-c::chunk-a-ctor",
                "tu::tests::mtproto-client-frozen-anchor-c::chunk-a-callback",
                "tu::tests::mtproto-client-frozen-anchor-c::chunk-a-init",
                "tu::tests::mtproto-client-frozen-anchor-c::chunk-b",
            ],
            [str(item["tu_id"]) for item in translator.calls],
        )
        self.assertTrue(chunk_artifact_path.exists())
        self.assertTrue(chunk_payload["artifact"]["metadata"]["frozen_anchor"])
        self.assertEqual(str(anchor_path.resolve()), chunk_payload["artifact"]["metadata"]["frozen_anchor_path"])
        self.assertIn("loaded frozen anchor", "\n".join(chunk_payload["artifact"]["notes"]))
        self.assertIn("takeResult()", candidate_text)
        self.assertNotIn("await()", candidate_text)
        self.assertNotIn("waiter.await()", candidate_text)
        self.assertIn("}\n\ninternal class RPCWaiter", candidate_text)
        self.assertNotIn("private class RPCWaiter", candidate_text)

    def test_real_mtprotoclient_chunk_c_frozen_anchor_locks_compile_fixups(self) -> None:
        anchor_path = PROJECT_ROOT / "tests" / "fixtures" / "anchors" / "mtprotoclient_chunk_c_frozen.json"
        anchor_payload = json.loads(anchor_path.read_text(encoding="utf-8"))
        generated_code = str(anchor_payload["artifact"]["generated_code"])

        self.assertIn("this.pendingRPCs[key] = RPCCallback(", generated_code)
        self.assertNotIn(".put(", generated_code)
        self.assertIn("rpc.resolve(data)", generated_code)
        self.assertNotIn("deserializer.readBytes()", generated_code)

    def test_mtprotoclient_chunked_translation_uses_frozen_anchor_for_chunk_b(self) -> None:
        subject = self.make_orchestrator()
        anchor_dir = Path(self.temp_dir.name) / "anchors"
        anchor_dir.mkdir(parents=True, exist_ok=True)
        anchor_path = anchor_dir / "mtprotoclient_chunk_b_frozen.json"
        anchor_payload = {
            "chunk": {
                "chunk_id": "chunk-b",
                "label": "Auth Handshake",
                "description": "auth handshake members only; translate present source methods and record missing directive-only members",
                "source_text": "private async createAuthKey(): Promise<void> {}\n",
                "expected_members": ["createAuthKey", "req_pq_multi", "req_DH_params", "set_client_DH_params"],
                "found_members": ["createAuthKey"],
                "missing_members": ["req_pq_multi", "req_DH_params", "set_client_DH_params"],
            },
            "artifact": {
                "attempt": 1,
                "generated_code": (
                    "private func createAuthKey(): Future<Unit> {\n"
                    "    spawn {\n"
                    "        let transport = this.transportManager.getTransport()\n"
                    "        let creator = AuthKeyCreator(transport)\n"
                    "        let result = creator.createAuthKey().get()\n"
                    "        this.session.authKey = result.authKey\n"
                    "        this.session.authKeyId = result.authKeyId\n"
                    "        this.session.serverSalt = result.serverSalt\n"
                    "        this.session.authKeyState = AuthKeyState.Created\n"
                    "        SessionManager.saveSession(this.session)\n"
                    "        ()\n"
                    "    }\n"
                    "}"
                ),
                "declared_constraints": [
                    "Translation Mapping",
                    "Dependency Constraint",
                    "Execution Topology",
                ],
                "notes": [
                    "fixture frozen chunk-b anchor",
                ],
                "metadata": {
                    "target_path": "src/core/mtproto/MTProtoClient.ets",
                    "repair_thought_process": "fixture frozen anchor",
                },
            },
        }
        anchor_path.write_text(json.dumps(anchor_payload, ensure_ascii=False, indent=2), encoding="utf-8")

        translator = ChunkRecordingTranslator()
        subject.translator = translator
        subject.static_firewall = StaticPassFirewall()
        subject.reviewer = PassingReviewer()
        verifier = RecordingVerifier()
        subject.verifier = verifier
        source_path = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
        source_text = source_path.read_text(encoding="utf-8")
        tu = {
            "tu_id": "tu::tests::mtproto-client-frozen-anchor-b",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        chunk_artifact_path = workspace_dir / "attempt-01" / "translation_chunk-b.json"
        readonly_stub_path = workspace_dir / "attempt-01" / "readonly_stub_after_chunk-b.json"
        candidate_path = workspace_dir / "attempt-01" / "src" / "core" / "mtproto" / "MTProtoClient.cj"
        chunk_payload = json.loads(chunk_artifact_path.read_text(encoding="utf-8"))
        readonly_stub_payload = json.loads(readonly_stub_path.read_text(encoding="utf-8"))
        candidate_text = candidate_path.read_text(encoding="utf-8")

        self.assertEqual("passed", result["final_status"])
        self.assertEqual(1, verifier.calls)
        self.assertEqual(
            [
                "tu::tests::mtproto-client-frozen-anchor-b::chunk-a",
                "tu::tests::mtproto-client-frozen-anchor-b::chunk-a-ctor",
                "tu::tests::mtproto-client-frozen-anchor-b::chunk-a-callback",
                "tu::tests::mtproto-client-frozen-anchor-b::chunk-a-init",
                "tu::tests::mtproto-client-frozen-anchor-b::chunk-c",
            ],
            [str(item["tu_id"]) for item in translator.calls],
        )
        self.assertTrue(chunk_artifact_path.exists())
        self.assertTrue(readonly_stub_path.exists())
        self.assertTrue(chunk_payload["artifact"]["metadata"]["frozen_anchor"])
        self.assertEqual(str(anchor_path.resolve()), chunk_payload["artifact"]["metadata"]["frozen_anchor_path"])
        self.assertIn("loaded frozen anchor", "\n".join(chunk_payload["artifact"]["notes"]))
        self.assertIn("private func createAuthKey(): Future<Unit> {}", readonly_stub_payload["stub"])
        self.assertIn("private func createAuthKey(): Future<Unit>", candidate_text)
        self.assertNotIn("class AuthKeyCreator", candidate_text)
        self.assertNotIn("class AuthKeyResult", candidate_text)
        self.assertNotIn("enum AuthKeyState", candidate_text)

    def test_mtprotoclient_chunked_failure_writes_partial_transcript_dump(self) -> None:
        subject = self.make_orchestrator()
        source_path = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
        source_text = source_path.read_text(encoding="utf-8")
        subject.translator = RaisingTranslator(
            orchestrator.LLMNetworkException(
                "timed out",
                request_payload={
                    "model": "mock-model",
                    "messages": [{"role": "system", "content": "chunk translator prompt"}],
                    "temperature": 0.1,
                    "partial_response_text": "chunk-a partial",
                },
                timeout_seconds=180,
                partial_response_text="chunk-a partial",
            )
        )
        tu = {
            "tu_id": "tu::tests::mtproto-client-failure",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        partial_dump_path = workspace_dir / "attempt-01" / "partial_transcript_dump.txt"

        self.assertEqual("infrastructure-error", result["final_status"])
        self.assertTrue(partial_dump_path.exists())
        self.assertEqual("chunk-a partial", partial_dump_path.read_text(encoding="utf-8"))
        self.assertEqual("chunk-a", result["infrastructure_failure"]["request_payload"]["chunk_translation"]["chunk_id"])

    def test_mtprotoclient_chunked_empty_candidate_aborts_before_next_chunk(self) -> None:
        subject = self.make_orchestrator()
        adapter = ReturningAdapter(
            '{"repair_thought_process":"brief","declared_constraints":["Translation Mapping"],"notes":["no code emitted"]}'
        )
        subject.translator = orchestrator.Translator(
            adapter=adapter,
            prompt_assembler=subject.prompt_assembler,
            model="mock-model",
            timeout_seconds=180,
        )
        source_path = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
        source_text = source_path.read_text(encoding="utf-8")
        tu = {
            "tu_id": "tu::tests::mtproto-client-empty-chunk",
            "target": {
                "path": "src/core/mtproto/MTProtoClient.ets",
                "role": "module",
                "summary": "MTProto client module",
                "risk_tags": ["[ASYNC_FLOW]"],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": source_text,
            },
            "dependency_closure": [],
        }

        result = subject.run(tu)
        workspace_dir = Path(result["workspace_dir"])
        partial_dump_path = workspace_dir / "attempt-01" / "partial_transcript_dump.txt"

        self.assertEqual("infrastructure-error", result["final_status"])
        self.assertEqual(1, adapter.calls)
        self.assertTrue(partial_dump_path.exists())
        self.assertIn("no code emitted", partial_dump_path.read_text(encoding="utf-8"))
        self.assertFalse((workspace_dir / "attempt-01" / "translation_chunk-a.json").exists())
        self.assertFalse((workspace_dir / "attempt-01" / "translation_chunk-a-ctor.json").exists())
        self.assertFalse((workspace_dir / "attempt-01" / "translation_chunk-a-callback.json").exists())
        self.assertEqual("chunk-a", result["infrastructure_failure"]["request_payload"]["chunk_translation"]["chunk_id"])
        self.assertIn("empty candidate code", result["infrastructure_failure"]["message"])


class TranslatorReviewerPropagationTests(unittest.TestCase):
    def make_prompt_assembler(self) -> orchestrator.PromptAssembler:
        return orchestrator.PromptAssembler(schema_text="# Translation Mapping\n- test")

    def make_tu(self) -> dict[str, object]:
        return {
            "tu_id": "tu::tests::service",
            "target": {
                "path": "src/services/TestService.ets",
                "role": "service",
                "risk_tags": [],
                "state_tags": [],
                "thread_tags": [],
                "interop_tags": [],
                "signatures": [],
                "source": "export class TestService {}",
            },
            "dependency_closure": [],
        }

    def test_translator_process_propagates_network_exception(self) -> None:
        translator = orchestrator.Translator(
            adapter=RaisingAdapter(orchestrator.LLMNetworkException("timed out")),
            prompt_assembler=self.make_prompt_assembler(),
            model="mock-model",
            timeout_seconds=180,
        )

        with self.assertRaises(orchestrator.LLMNetworkException):
            translator.process(
                tu=self.make_tu(),
                required_dimensions=["Translation Mapping"],
                attempt=1,
                repair_guidance=[],
                pattern_examples=[],
            )

    def test_translator_process_raises_when_candidate_code_is_empty(self) -> None:
        translator = orchestrator.Translator(
            adapter=ReturningAdapter(
                '{"repair_thought_process":"brief","declared_constraints":["Translation Mapping"],"notes":["empty"]}'
            ),
            prompt_assembler=self.make_prompt_assembler(),
            model="mock-model",
            timeout_seconds=180,
        )

        with self.assertRaises(orchestrator.LLMNetworkException) as context:
            translator.process(
                tu=self.make_tu(),
                required_dimensions=["Translation Mapping"],
                attempt=1,
                repair_guidance=[],
                pattern_examples=[],
            )

        self.assertIn("empty candidate code", str(context.exception))
        self.assertIn('"repair_thought_process":"brief"', context.exception.partial_response_text or "")

    def test_translator_process_raises_when_candidate_code_is_empty_but_reasoning_was_returned(self) -> None:
        class ReasoningOnlyAdapter:
            def complete(self, request):
                return SimpleNamespace(
                    text="",
                    raw_payload={
                        "choices": [
                            {
                                "message": {
                                    "role": "assistant",
                                    "content": "",
                                    "reasoning_content": "constructor setup reasoning",
                                }
                            }
                        ],
                        "reasoning_content": "constructor setup reasoning",
                    },
                )

        translator = orchestrator.Translator(
            adapter=ReasoningOnlyAdapter(),
            prompt_assembler=self.make_prompt_assembler(),
            model="mock-model",
            timeout_seconds=180,
        )

        with self.assertRaises(orchestrator.LLMNetworkException) as context:
            translator.process(
                tu=self.make_tu(),
                required_dimensions=["Translation Mapping"],
                attempt=1,
                repair_guidance=[],
                pattern_examples=[],
            )

        self.assertIn("empty candidate code", str(context.exception))
        self.assertEqual("[Reasoning]\nconstructor setup reasoning", context.exception.partial_response_text)

    def test_reviewer_process_propagates_network_exception(self) -> None:
        reviewer = orchestrator.Reviewer(
            adapter=RaisingAdapter(orchestrator.LLMNetworkException("timed out")),
            prompt_assembler=self.make_prompt_assembler(),
            model="mock-model",
            timeout_seconds=180,
        )

        with self.assertRaises(orchestrator.LLMNetworkException):
            reviewer.process(
                tu=self.make_tu(),
                artifact=orchestrator.TranslationArtifact(
                    attempt=1,
                    generated_code="main(): Int64 { return 0 }",
                    declared_constraints=["Translation Mapping"],
                ),
                required_dimensions=["Translation Mapping"],
            )


class OrchestratorRegressionProtectionTests(unittest.TestCase):
    def test_apply_regression_protection_preserves_public_contract_guidance(self) -> None:
        static_result = orchestrator.StaticCheckResult(
            passed=False,
            violations=[
                SimpleNamespace(
                    rule_id="static-tl-protocol-types",
                    issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
                    required_dimension="Architecture Mapping",
                    severity="blocker",
                    message="tl",
                    matched_text="TLUser",
                    line=10,
                    column=20,
                    line_text="public func cacheUsers(users: Array<TLUser>): Unit {",
                    repair_hint="hint",
                ),
                SimpleNamespace(
                    rule_id="static-shadow-signal-flow",
                    issue_code="ARCH_EXECUTION_TOPOLOGY_VIOLATION",
                    required_dimension="Execution Topology",
                    severity="blocker",
                    message="signal",
                    matched_text="Signal",
                    line=20,
                    column=30,
                    line_text="public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>> {",
                    repair_hint="hint",
                ),
            ],
            scanned_line_count=2,
            rule_count=2,
        )

        guidance = orchestrator.apply_regression_protection(
            [],
            has_cleared_protocol_bleed=False,
            has_cleared_syntax_residue=False,
            static_result=static_result,
        )

        text = "\n".join(guidance)
        self.assertIn("public signature", text)
        self.assertIn("source-aligned", text)
        self.assertNotIn("DomainUser 模板", text)
        self.assertNotIn("Service 只允许依赖", text)
        self.assertNotIn("回到纯同步领域逻辑", text)
        self.assertIn("`private/internal`", text)


if __name__ == "__main__":
    unittest.main()
