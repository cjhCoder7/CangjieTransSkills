from __future__ import annotations

import sys
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import static_blacklist_checker  # noqa: E402


class StaticBlacklistCheckerContextTests(unittest.TestCase):
    def test_static_double_bang_skips_source_backed_string_literal_content(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        source = (
            "package ohos_app_cangjie_entry.page.home\n"
            "@Component\n"
            "public class homeBody {\n"
            "    @State\n"
            "    var turntableTitle: String = \"今天学习什么!!\"\n"
            "}\n"
        )
        result = checker.check(
            source,
            tu={
                "target": {
                    "path": "page/home/homeBody.cj",
                    "role": "component",
                    "risk_tags": ["component", "state-decorator"],
                    "source": source,
                }
            },
        )

        self.assertTrue(result.passed, result.to_dict())
        self.assertFalse(any(item.rule_id == "static-double-bang" for item in result.violations))

    def test_static_double_bang_still_blocks_executable_operator_usage(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class Demo {\n"
                "    public func toggle(flag: Bool) {\n"
                "        if (!!flag) {\n"
                "            return\n"
                "        }\n"
                "    }\n"
                "}\n"
            )
        )

        self.assertFalse(result.passed)
        self.assertTrue(any(item.rule_id == "static-double-bang" for item in result.violations))

    def test_static_double_bang_skips_comment_content(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class Demo {\n"
                "    public func note() {\n"
                "        // !! comment-only marker should stay ignored\n"
                "        return\n"
                "    }\n"
                "}\n"
            )
        )

        self.assertTrue(result.passed, result.to_dict())
        self.assertFalse(any(item.rule_id == "static-double-bang" for item in result.violations))

    def test_binary_buffer_rule_skips_binary_proto_module(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            "public interface SessionInfo {\n    var authKey: ?Array<UInt8>\n}\n",
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["[BINARY_PROTO]"],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_protocol_rules_skip_binary_proto_module(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public abstract class InputPeer {}\n"
                "public class InputPeerEmpty <: InputPeer {}\n"
                "public class MessagesSendMessage {\n"
                "    public var peer: InputPeer = InputPeerEmpty()\n"
                "    public func toBytes(): Array<UInt8> {\n"
                "        return Array<UInt8>()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["[BINARY_PROTO]"],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_binary_proto_module_allows_messages_symbols_and_singleton_match_tokens(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class MessagesGetHistory {}\n"
                "public class MessagesSendMessage {}\n"
                "public class MTProtoClient {}\n"
                "public func getMTProtoClient(): MTProtoClient {\n"
                "    match (clientSingleton) {\n"
                "        case None => {}\n"
                "        case Some(existing) => { existing }\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]"],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_tl_symbol_rules_skip_binary_proto_module(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class TLConstructors {}\n"
                "public class TLSerializer {\n"
                "    public func write(items: Array<TLMessage>): Unit {}\n"
                "    public func decode(item: TLMessage): TLMessage {\n"
                "        return item\n"
                "    }\n"
                "}\n"
                "public class TLDeserializer {}\n"
            ),
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["[BINARY_PROTO]"],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_tl_contract_rules_skip_non_service_module(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public interface TLUser {\n"
                "    func getId(): Int64\n"
                "}\n"
                "internal class TLUserImpl <: TLUser {\n"
                "    private let id: Int64\n"
                "    public init(id: Int64) {\n"
                "        this.id = id\n"
                "    }\n"
                "    public func getId(): Int64 {\n"
                "        this.id\n"
                "    }\n"
                "}\n"
                "public interface TLChannel {\n"
                "    func getId(): Int64\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["module"],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_binary_buffer_rule_still_blocks_service_surface(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            "public class RealMessageService {\n    public func load(): ?Array<UInt8> {\n        None\n    }\n}\n",
            tu={
                "target": {
                    "role": "service",
                    "risk_tags": [],
                }
            },
        )

        self.assertFalse(result.passed)
        self.assertTrue(any(item.rule_id == "static-binary-buffer-in-service" for item in result.violations))

    def test_protocol_rules_still_block_service_surface(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    public func create(peer: InputPeer): Array<UInt8> {\n"
                "        return peer.toBytes()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "service",
                    "risk_tags": [],
                }
            },
        )

        self.assertFalse(result.passed)
        self.assertTrue(any(item.rule_id == "static-input-peer-leak" for item in result.violations))
        self.assertTrue(any(item.rule_id == "static-binary-buffer-in-service" for item in result.violations))
        self.assertTrue(any(item.rule_id == "static-to-bytes-call" for item in result.violations))

    def test_async_flow_module_blocks_promise_return_signature(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package core.mtproto\n\n"
                "public class MTProtoClient {\n"
                "    public func initialize(forceNewAuthKey: Bool): Promise<Unit> {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]"],
                }
            },
        )

        self.assertFalse(result.passed)
        self.assertTrue(any(item.rule_id == "static-promise-return-signature" for item in result.violations))

    def test_async_flow_module_allows_future_return_signature(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package core.mtproto\n"
                "import std.sync.*\n\n"
                "public class MTProtoClient {\n"
                "    public func initialize(forceNewAuthKey: Bool): Future<Unit> {\n"
                "        spawn { () }\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]"],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_blocks_await_keyword_regression(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package core.mtproto\n"
                "import std.sync.*\n\n"
                "public class MTProtoClient {\n"
                "    public func initialize(): Future<Unit> {\n"
                "        let task = spawn { () }\n"
                "        await task\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]"],
                }
            },
        )

        self.assertFalse(result.passed)
        self.assertTrue(any(item.rule_id == "static-await-keyword-regression" for item in result.violations))

    def test_blocks_from_import_regression(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "from './MTProtoConfig' import MTProtoConfig, SessionInfo\n"
                "public class MTProtoClient {}\n"
            ),
            tu={
                "target": {
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]"],
                }
            },
        )

        self.assertFalse(result.passed)
        self.assertTrue(any(item.rule_id == "static-from-import-regression" for item in result.violations))

    def test_blocks_std_concurrent_import_regression(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package services\n"
                "import std.concurrent.*\n\n"
                "public class RealMessageService {\n"
                "    public func fetchMessages(): Future<Array<Message>> {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService"},
                    ],
                }
            },
        )

        self.assertFalse(result.passed)
        violation = next(item for item in result.violations if item.rule_id == "static-std-concurrent-import-regression")
        self.assertIn("std.sync.*", violation.repair_hint)
        self.assertIn("compile-fail", violation.repair_hint)

    def test_service_source_aligned_public_tl_and_signal_contracts_are_allowed(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    public func cacheUsers(users: Array<TLUser>): Unit {\n"
                "        ()\n"
                "    }\n"
                "    public func cacheChannels(channels: Array<TLChannel>): Unit {\n"
                "        ()\n"
                "    }\n"
                "    public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>> {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "cacheUsers", "signature": "cacheUsers(users: TLUser[]): void"},
                        {"kind": "function", "name": "cacheChannels", "signature": "cacheChannels(channels: TLChannel[]): void"},
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(peerId, limit): Signal<Message[]>"},
                    ],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_service_public_getmessages_int64_signature_drift_fails(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    public func getMessages(limit: Int64): Signal<Array<Message>> {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(limit: Int32): Signal<Message[]>"},
                    ],
                }
            },
        )

        self.assertFalse(result.passed)

    def test_service_public_int32_signature_and_public_contract_tokens_pass_without_false_positive(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    public func cacheUsers(users: Array<TLUser>): Unit {\n"
                "        ()\n"
                "    }\n"
                "    public func cacheChannels(channels: Array<TLChannel>): Unit {\n"
                "        ()\n"
                "    }\n"
                "    public func getMessages(limit: Int32): Signal<Array<Message>> {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "cacheUsers", "signature": "cacheUsers(users: TLUser[]): void"},
                        {"kind": "function", "name": "cacheChannels", "signature": "cacheChannels(channels: TLChannel[]): void"},
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(limit: Int32): Signal<Message[]>"},
                    ],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertFalse(any(item.rule_id == "static-tl-protocol-types" for item in result.violations))
        self.assertFalse(any(item.rule_id == "static-shadow-signal-flow" for item in result.violations))

    def test_service_private_tl_and_signal_state_still_fail_with_lockdown_hints(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    private let cachedUsers: Array<TLUser> = []\n"
                "    private let signalCache: Signal<Array<Message>>\n"
                "    public func cacheUsers(users: Array<TLUser>): Unit {\n"
                "        ()\n"
                "    }\n"
                "    public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>> {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "cacheUsers", "signature": "cacheUsers(users: TLUser[]): void"},
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(peerId, limit): Signal<Message[]>"},
                    ],
                }
            },
        )

        self.assertFalse(result.passed)
        tl_hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-tl-protocol-types")
        signal_hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-service-reactive-ownership")
        self.assertIn("source-aligned", tl_hint)
        self.assertIn("public contract", tl_hint)
        self.assertNotIn("Service 只允许依赖", tl_hint)
        self.assertIn("只能留在匹配的 public signature", signal_hint)
        self.assertIn("`private let cache: Signal<T>`", signal_hint)
        self.assertIn("explicit staged contract allowlist", signal_hint)
        self.assertIn("invented provider/facade/shell", signal_hint)

    def test_service_invented_collaborator_and_locator_are_blocked(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    private let backend: MessageBackend\n"
                "    public init() {\n"
                "        this.backend = ServiceLocator.getMessageBackend()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow"],
                    "source": (
                        "import { Signal } from '@ohos/signalkit'\n"
                        "import { Message, PeerId } from '@ohos/models'\n"
                        "import { IMessageService, SendMessageParams, GetHistoryParams } from '@ohos/services'\n"
                    ),
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
        )

        self.assertFalse(result.passed)
        self.assertTrue(any(item.rule_id == "static-invented-collaborator-type" for item in result.violations))
        self.assertTrue(any(item.rule_id == "static-invented-collaborator-locator" for item in result.violations))
        hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-invented-collaborator-type")
        self.assertIn("explicit staged contract allowlist", hint)
        self.assertIn("MessageBackend", hint)
        self.assertIn("ServiceLocator", hint)

    def test_service_known_dependency_collaborator_symbol_is_allowed(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    private let client: MTProtoClient\n"
                "    public init() {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service"],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_service_explicit_staged_message_timeline_collaborator_is_allowed(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    private let timeline: MessageTimeline = MessageTimeline()\n"
                "    public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>> {\n"
                "        this.timeline.getMessages(peerId, limit)\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(peerId, limit): Signal<Message[]>"},
                    ],
                },
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_service_protocol_request_names_accessor_and_zero_block_are_blocked(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    public func fetchMessages(params: GetHistoryParams): Future<Array<Message>> {\n"
                "        let request = MessagesGetHistory()\n"
                "        let send = MessagesSendMessage()\n"
                "        let client = getMTProtoClient()\n"
                "        match (parse(params)) {\n"
                "            case None => {}\n"
                "            case Some(msg) => { msg }\n"
                "        }\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "fetchMessages", "signature": "fetchMessages(params): Future<Array<Message>>"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
        )

        self.assertFalse(result.passed)
        rule_ids = {item.rule_id for item in result.violations}
        self.assertIn("static-service-request-type-leak", rule_ids)
        self.assertIn("static-service-mtprotoclient-accessor-leak", rule_ids)
        self.assertIn("static-service-zero-block-match-arm", rule_ids)

    def test_service_option_none_comparison_and_hashmap_put_are_blocked(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    private let userAccessHashes: HashMap<String, Int64> = HashMap<String, Int64>()\n"
                "    private func cache(hash: Option<Int64>): Unit {\n"
                "        if (hash != None) {\n"
                "            this.userAccessHashes.put(\"user\", Int64(1))\n"
                "        }\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service"],
                }
            },
        )

        self.assertFalse(result.passed)
        rule_ids = {item.rule_id for item in result.violations}
        self.assertIn("static-service-option-none-compare", rule_ids)
        self.assertIn("static-service-hashmap-put-regression", rule_ids)
        option_hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-service-option-none-compare")
        hashmap_hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-service-hashmap-put-regression")
        self.assertIn("改用 `match (value)` 或 `if let`", option_hint)
        self.assertIn("`map[key] = value`", hashmap_hint)

    def test_service_public_contract_oracle_blocks_signature_drift(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    public func getMessages(peerId: PeerId, limit: Int64): Signal<Array<Message>> {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(peerId, limit): Signal<Message[]>"},
                    ],
                }
            },
        )

        self.assertFalse(result.passed)
        drift = next(item for item in result.violations if item.rule_id == "static-service-public-contract-drift")
        self.assertEqual(drift.issue_code, "ARCH_CONTRACT_RUPTURE")
        self.assertIn("limit: Int32", drift.repair_hint)
        self.assertIn("ValueSignal(...)", drift.repair_hint)

    def test_service_public_contract_oracle_allows_source_aligned_signature_tokens(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    public func cacheUsers(users: Array<TLUser>): Unit {\n"
                "        ()\n"
                "    }\n"
                "    public func cacheChannels(channels: Array<TLChannel>): Unit {\n"
                "        ()\n"
                "    }\n"
                "    public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>> {\n"
                "        abort()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "cacheUsers", "signature": "cacheUsers(users: TLUser[]): void"},
                        {"kind": "function", "name": "cacheChannels", "signature": "cacheChannels(channels: TLChannel[]): void"},
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(peerId, limit): Signal<Message[]>"},
                    ],
                }
            },
        )

        self.assertTrue(result.passed)
        self.assertEqual(result.violations, [])

    def test_service_reactive_materialization_placeholder_and_invented_shell_are_blocked(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "public class RealMessageService {\n"
                "    public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>> {\n"
                "        let live: Signal<Array<Message>> = existingSignal\n"
                "        let pending = ValueSignal<Array<Message>>([])\n"
                "        let shell = ReactiveSignalFacade()\n"
                "        throw TODO()\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(peerId, limit): Signal<Message[]>"},
                    ],
                }
            },
        )

        self.assertFalse(result.passed)
        rule_ids = {item.rule_id for item in result.violations}
        self.assertIn("static-service-reactive-ownership", rule_ids)
        self.assertIn("static-service-reactive-materialization", rule_ids)
        self.assertIn("static-service-reactive-placeholder", rule_ids)
        self.assertIn("static-invented-reactive-shell", rule_ids)
        ownership_hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-service-reactive-ownership")
        materialization_hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-service-reactive-materialization")
        placeholder_hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-service-reactive-placeholder")
        shell_hint = next(item.repair_hint for item in result.violations if item.rule_id == "static-invented-reactive-shell")
        self.assertIn("`let x: Signal<T>`", ownership_hint)
        self.assertIn("exact public contract", materialization_hint)
        self.assertIn("`throw TODO` / `TODO()`", placeholder_hint)
        self.assertIn("`*SignalProvider`、`*ReactiveFacade`、`*ReactiveShell`", shell_hint)

    def test_phase06_ui_source_backed_arraylist_allows_signature_level_match_ignoring_mutability(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package ohos_app_cangjie_entry\n"
                "import kit.ArkUI.*\n"
                "import ohos.arkui.state_macro_manage.*\n"
                "\n"
                "@Entry\n"
                "@Component\n"
                "class FoodCategoryListPage {\n"
                "    let visibleFoodsCache: ArrayList<FoodData>\n"
                "    func visibleFoods(): ArrayList<FoodData> {\n"
                "        return []\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "pages/FoodCategoryListPage.cj",
                    "role": "page",
                    "risk_tags": ["page", "routing"],
                    "source": (
                        "package ohos_app_cangjie_entry\n"
                        "import kit.ArkUI.*\n"
                        "import ohos.arkui.state_macro_manage.*\n"
                        "\n"
                        "@Entry\n"
                        "@Component\n"
                        "class FoodCategoryListPage {\n"
                        "    var visibleFoodsCache: ArrayList<FoodData>\n"
                        "    func visibleFoods(): ArrayList<FoodData> {\n"
                        "        return []\n"
                        "    }\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "page", "name": "FoodCategoryListPage", "signature": "page FoodCategoryListPage"},
                    ],
                }
            },
        )

        self.assertTrue(result.passed, result.to_dict())
        self.assertEqual([], result.violations)

    def test_phase06_ui_source_backed_arraylist_allows_body_constructor_and_explicit_return_type(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package ohos_app_cangjie_entry.components.List\n"
                "import std.random.Random\n"
                "import std.collection.ArrayList\n"
                "\n"
                "let random: Random = Random()\n"
                "\n"
                "public func generateUserEntity(): UserEntity {\n"
                "    var index: Int64 = random.nextInt64()\n"
                "    if (index < 0) {\n"
                "        index *= -1\n"
                "    }\n"
                "    return defaultUserEntities[index]\n"
                "}\n"
                "\n"
                "public func generateUserEntities(num: Int64): ArrayList<UserEntity> {\n"
                "    return ArrayList<UserEntity>(num, { _ => generateUserEntity()})\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "components/List/User.cj",
                    "role": "viewmodel",
                    "risk_tags": ["viewmodel", "list-or-grid"],
                    "source": (
                        "package ohos_app_cangjie_entry.components.List\n"
                        "import std.random.Random\n"
                        "import std.collection.ArrayList\n"
                        "\n"
                        "let random: Random = Random()\n"
                        "\n"
                        "public func generateUserEntity() {\n"
                        "    var index: Int64 = random.nextInt64()\n"
                        "    if (index < 0) {\n"
                        "        index *= -1\n"
                        "    }\n"
                        "    defaultUserEntities[index];\n"
                        "}\n"
                        "\n"
                        "public func generateUserEntities(num: Int64) {\n"
                        "    ArrayList<UserEntity>(num, { _ => generateUserEntity()});\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "function", "name": "generateUserEntity", "signature": "generateUserEntity()"},
                        {"kind": "function", "name": "generateUserEntities", "signature": "generateUserEntities(num: Int64)"},
                    ],
                }
            },
        )

        self.assertTrue(result.passed, result.to_dict())
        self.assertEqual([], result.violations)

    def test_phase06_ui_source_backed_generic_arraylist_helper_signature_and_constructor_pass(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package ohos_app_cangjie_entry.services\n"
                "import encoding.json.JsonValue\n"
                "import std.collection.ArrayList\n"
                "\n"
                "public class ChartDataServices {\n"
                "    private func loadAndParseData<T>(filename: String, jsonKey: String, parser: (JsonValue) -> Option<T>): ArrayList<T> {\n"
                "        let result = ArrayList<T>()\n"
                "        result\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "services/ChartDataService.cj",
                    "role": "viewmodel",
                    "risk_tags": ["viewmodel", "list-or-grid"],
                    "source": (
                        "package ohos_app_cangjie_entry.services\n"
                        "import encoding.json.JsonValue\n"
                        "import std.collection.ArrayList\n"
                        "\n"
                        "public class ChartDataServices {\n"
                        "    private func loadAndParseData<T>(filename: String, jsonKey: String, parser: (JsonValue) -> Option<T>): ArrayList<T> {\n"
                        "        let result = ArrayList<T>()\n"
                        "        result\n"
                        "    }\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "ChartDataServices", "signature": "class ChartDataServices"},
                    ],
                }
            },
        )

        self.assertTrue(result.passed, result.to_dict())
        self.assertEqual([], result.violations)

    def test_phase06_ui_untyped_arraylist_helper_signature_and_constructor_still_fail(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package ohos_app_cangjie_entry.services\n"
                "import encoding.json.JsonValue\n"
                "import std.collection.ArrayList\n"
                "\n"
                "public class ChartDataServices {\n"
                "    private func loadAndParseData(filename: String, jsonKey: String, parser: (JsonValue) -> Option): ArrayList {\n"
                "        let result = ArrayList()\n"
                "        result\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "services/ChartDataService.cj",
                    "role": "viewmodel",
                    "risk_tags": ["viewmodel", "list-or-grid"],
                    "source": (
                        "package ohos_app_cangjie_entry.services\n"
                        "import encoding.json.JsonValue\n"
                        "import std.collection.ArrayList\n"
                        "\n"
                        "public class ChartDataServices {\n"
                        "    private func loadAndParseData<T>(filename: String, jsonKey: String, parser: (JsonValue) -> Option<T>): ArrayList<T> {\n"
                        "        let result = ArrayList<T>()\n"
                        "        result\n"
                        "    }\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "ChartDataServices", "signature": "class ChartDataServices"},
                    ],
                }
            },
        )

        self.assertFalse(result.passed)
        self.assertTrue(any(item.rule_id == "static-arraylist-hallucination" for item in result.violations))

    def test_phase06_ui_source_backed_internal_ohos_imports_are_allowed(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package ohos_app_cangjie_entry.pages\n"
                "\n"
                "internal import ohos.base.*\n"
                "internal import ohos.component.*\n"
                "internal import ohos.state_manage.*\n"
                "import ohos.state_macro_manage.*\n"
                "\n"
                "@Entry\n"
                "@Component\n"
                "class BadgeView {\n"
                "    @State var count: Int32 = 1\n"
                "    func build() {\n"
                "        Column() {\n"
                "            Text(count.toString())\n"
                "        }\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "pages/BadgeView.cj",
                    "role": "page",
                    "risk_tags": ["page", "badgeview"],
                    "source": (
                        "package ohos_app_cangjie_entry.pages\n"
                        "\n"
                        "internal import ohos.base.*\n"
                        "internal import ohos.component.*\n"
                        "internal import ohos.state_manage.*\n"
                        "import ohos.state_macro_manage.*\n"
                        "\n"
                        "@Entry\n"
                        "@Component\n"
                        "class BadgeView {\n"
                        "    @State var count: Int32 = 1\n"
                        "    func build() {\n"
                        "        Column() {\n"
                        "            Text(count.toString())\n"
                        "        }\n"
                        "    }\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "page", "name": "BadgeView", "signature": "page BadgeView"},
                    ],
                }
            },
        )

        self.assertTrue(result.passed, result.to_dict())
        self.assertFalse(any(item.rule_id == "static-import-ohos-package" for item in result.violations))
        self.assertFalse(any(item.rule_id == "static-ohos-path-anywhere" for item in result.violations))

    def test_phase06_ui_public_surface_drift_blocks_visibility_elevation_while_allowing_source_backed_arraylist(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package markdown.components\n"
                "import ohos.base.*\n"
                "import ohos.component.*\n"
                "import ohos.state_manage.*\n"
                "import ohos.state_macro_manage.*\n"
                "\n"
                "@Component\n"
                "class MarkdownHeadingComponent {\n"
                "    public var nodeViews: ArrayList<NodeView>\n"
                "    public var indexList: ArrayList<Int64> = ArrayList<Int64>()\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "components/markdown_heading_component.cj",
                    "role": "component",
                    "risk_tags": ["component", "list-or-grid", "state-decorator"],
                    "source": (
                        "package markdown.components\n"
                        "import ohos.base.*\n"
                        "import ohos.component.*\n"
                        "import ohos.state_manage.*\n"
                        "import ohos.state_macro_manage.*\n"
                        "\n"
                        "@Component\n"
                        "class MarkdownHeadingComponent {\n"
                        "    var nodeViews: ArrayList<NodeView>\n"
                        "    var indexList: ArrayList<Int64> = ArrayList<Int64>()\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent"},
                    ],
                }
            },
        )

        self.assertFalse(result.passed)
        rule_ids = {item.rule_id for item in result.violations}
        self.assertIn("static-ui-public-surface-drift", rule_ids)
        self.assertNotIn("static-arraylist-hallucination", rule_ids)
        public_drift = next(item for item in result.violations if item.rule_id == "static-ui-public-surface-drift")
        self.assertEqual("STATIC_PUBLIC_SURFACE_DRIFT", public_drift.issue_code)
        self.assertEqual(
            "UI_PUBLIC_DRIFT_DETECTED: Do not elevate visibility to 'public' unless it is public in the original source. Revert to default/private visibility.",
            public_drift.repair_hint,
        )

    def test_phase06_ui_invented_ohos_and_arraylist_still_block_with_source_aware_hints(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package ohos_app_cangjie_entry\n"
                "import kit.ArkUI.*\n"
                "import ohos.arkui.state_macro_manage.*\n"
                "import ohos.fake.runtime.*\n"
                "\n"
                "@Entry\n"
                "@Component\n"
                "class FoodCategoryListPage {\n"
                "    func visibleFoods(): ArrayList<FoodData> {\n"
                "        return []\n"
                "    }\n"
                "\n"
                "    func inventedFoods(): ArrayList<FoodData> {\n"
                "        return []\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "pages/FoodCategoryListPage.cj",
                    "role": "page",
                    "risk_tags": ["page", "routing"],
                    "source": (
                        "package ohos_app_cangjie_entry\n"
                        "import kit.ArkUI.*\n"
                        "import ohos.arkui.state_macro_manage.*\n"
                        "\n"
                        "@Entry\n"
                        "@Component\n"
                        "class FoodCategoryListPage {\n"
                        "    func visibleFoods(): ArrayList<FoodData> {\n"
                        "        return []\n"
                        "    }\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "page", "name": "FoodCategoryListPage", "signature": "page FoodCategoryListPage"},
                    ],
                }
            },
        )

        self.assertFalse(result.passed)
        ohos_violation = next(item for item in result.violations if item.rule_id == "static-import-ohos-package")
        arraylist_violation = next(item for item in result.violations if item.rule_id == "static-arraylist-hallucination")
        self.assertIn("当前 UI 文件", ohos_violation.message)
        self.assertIn("当前 UI 文件", ohos_violation.repair_hint)
        self.assertIn("[UI IMPORT CONTRACT FIDELITY]", ohos_violation.repair_hint)
        self.assertIn("ohos.arkui.state_macro_manage.*", ohos_violation.repair_hint)
        self.assertIn("[UI ARRAYLIST CONTRACT FIDELITY]", arraylist_violation.repair_hint)
        self.assertIn("只删除当前候选新增、且 source 中不存在的 invented `ArrayList` 用法", arraylist_violation.repair_hint)
        self.assertNotIn("宁可保持零 import", ohos_violation.repair_hint)

    def test_phase06_ui_ffi_exception_allows_unsafe_keyword(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package avif4cj\n"
                "public class AvifDecoder {\n"
                "    private func decodeffi(): Int32 {\n"
                "        unsafe {\n"
                "            return 1\n"
                "        }\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "avif4cj/src/main/cangjie/avif_decoder.cj",
                    "role": "viewmodel",
                    "risk_tags": ["viewmodel"],
                },
                "metadata": {
                    "phase06_ui_tags": {
                        "exception_tags": ["ffi-exception"],
                    }
                },
            },
        )

        self.assertTrue(result.passed, result.to_dict())
        self.assertEqual([], result.violations)

    def test_phase06_ui_hybrid_exception_allows_hybrid_runtime_imports(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()
        result = checker.check(
            (
                "package ohos_app_cangjie_entry\n"
                "import ohos.hybrid_base.CJPageEntry\n"
                "import ohos.hybrid_base.HybridComponentBase\n"
                "import ohos.state_macro_manage.HybridComponentEntry\n"
                "\n"
                "@HybridComponentEntry\n"
                "class Index <: HybridComponentBase {\n"
                "    let entry: CJPageEntry? = None\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "entry/src/main/cangjie/index.cj",
                    "role": "component",
                    "risk_tags": ["component"],
                    "ui_prompt_tags": {
                        "exception_tags": ["hybrid-exception"],
                    },
                }
            },
        )

        self.assertTrue(result.passed, result.to_dict())
        self.assertEqual([], result.violations)

    def test_phase06_ui_regular_targets_still_block_ffi_and_hybrid_exception_patterns(self) -> None:
        checker = static_blacklist_checker.StaticBlacklistChecker()

        ffi_result = checker.check(
            (
                "package avif4cj\n"
                "public class AvifDecoder {\n"
                "    private func decodeffi(): Int32 {\n"
                "        unsafe {\n"
                "            return 1\n"
                "        }\n"
                "    }\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "avif4cj/src/main/cangjie/avif_decoder.cj",
                    "role": "viewmodel",
                    "risk_tags": ["viewmodel"],
                }
            },
        )
        self.assertFalse(ffi_result.passed)
        self.assertTrue(any(item.rule_id == "static-unsafe-keyword" for item in ffi_result.violations))

        hybrid_result = checker.check(
            (
                "package ohos_app_cangjie_entry\n"
                "import ohos.hybrid_base.CJPageEntry\n"
                "import ohos.state_macro_manage.HybridComponentEntry\n"
                "\n"
                "@HybridComponentEntry\n"
                "class Index {\n"
                "    let entry: CJPageEntry? = None\n"
                "}\n"
            ),
            tu={
                "target": {
                    "path": "entry/src/main/cangjie/index.cj",
                    "role": "component",
                    "risk_tags": ["component"],
                }
            },
        )
        self.assertFalse(hybrid_result.passed)
        hybrid_rule_ids = {item.rule_id for item in hybrid_result.violations}
        self.assertIn("static-import-ohos-package", hybrid_rule_ids)
        self.assertIn("static-ohos-path-anywhere", hybrid_rule_ids)


if __name__ == "__main__":
    unittest.main()
