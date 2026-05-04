from __future__ import annotations

import sys
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import precompiled_dependency_registry as registry  # noqa: E402


class PrecompiledDependencyRegistryTests(unittest.TestCase):
    def test_default_registry_paths_exist_for_mtprotoclient_dependency_chain(self) -> None:
        normalized = registry.normalize_registry()
        expected_sources = {
            "src/core/mtproto/MTProtoClient.ets",
            "src/core/mtproto/MTProtoConfig.ets",
            "src/core/mtproto/MTProtoTransport.ets",
            "src/core/mtproto/AuthKeyCreator.ets",
            "src/core/mtproto/Inflate.ets",
            "src/core/mtproto/CryptoUtils.ets",
            "src/core/mtproto/TLMethods.ets",
            "src/core/mtproto/TLSerialization.ets",
            "src/core/mtproto/TLDialogs.ets",
        }
        self.assertTrue(expected_sources.issubset(set(normalized.keys())))
        for source_path in expected_sources:
            self.assertTrue(normalized[source_path].exists(), source_path)

    def test_resolve_precompiled_dependency_specs_includes_explicit_mtprotoclient_dependencies(self) -> None:
        specs = registry.resolve_precompiled_dependency_specs(
            target_path="src/core/mtproto/MTProtoClient.ets",
            dependency_paths=[
                "src/core/mtproto/MTProtoConfig.ets",
                "src/core/mtproto/MTProtoTransport.ets",
                "src/core/mtproto/AuthKeyCreator.ets",
                "src/core/mtproto/Inflate.ets",
            ],
            registry=registry.normalize_registry(),
            include_same_directory_pool=False,
        )
        self.assertEqual(
            [item.source_path for item in specs],
            [
                "src/core/mtproto/AuthKeyCreator.ets",
                "src/core/mtproto/Inflate.ets",
                "src/core/mtproto/MTProtoConfig.ets",
                "src/core/mtproto/MTProtoTransport.ets",
            ],
        )

    def test_same_directory_pool_for_transport_includes_mtprotoclient_anchor(self) -> None:
        specs = registry.resolve_precompiled_dependency_specs(
            target_path="src/core/mtproto/MTProtoTransport.ets",
            dependency_paths=[],
            registry=registry.normalize_registry(),
            include_same_directory_pool=True,
        )

        self.assertIn("src/core/mtproto/MTProtoClient.ets", [item.source_path for item in specs])

    def test_materialized_mtproto_registry_entries_use_curated_precompiled_fixtures(self) -> None:
        normalized = registry.normalize_registry()
        expected_suffixes = {
            "src/core/mtproto/MTProtoClient.ets": "tests/fixtures/anchors/precompiled/mtprotoclient_source_aligned.cj",
            "src/core/mtproto/MTProtoConfig.ets": "tests/fixtures/anchors/precompiled/mtprotoconfig_source_aligned.cj",
            "src/core/mtproto/CryptoUtils.ets": "tests/fixtures/anchors/precompiled/cryptoutils_source_aligned.cj",
            "src/core/mtproto/TLSerialization.ets": "tests/fixtures/anchors/precompiled/tlserialization_source_aligned.cj",
        }
        for source_path, suffix in expected_suffixes.items():
            self.assertTrue(str(normalized[source_path]).endswith(suffix), source_path)

    def test_realmessageservice_explicit_contract_registry_resolves_curated_fixture_and_symbols(self) -> None:
        specs = registry.resolve_explicit_staged_contract_specs(
            target_path="src/services/RealMessageService.ets"
        )

        self.assertEqual(len(specs), 1)
        self.assertEqual(specs[0].source_path, "src/services/RealMessageServiceExternalContracts.ets")
        self.assertTrue(specs[0].candidate_path.exists())
        self.assertTrue(
            str(specs[0].candidate_path).endswith(
                "tests/fixtures/anchors/precompiled/realmessageservice_service_contracts.cj"
            )
        )
        self.assertEqual(
            list(specs[0].provided_symbols),
            [
                "IMessageService",
                "PeerId",
                "Message",
                "MessageTimeline",
                "Signal",
                "SendMessageParams",
                "GetHistoryParams",
                "TLUser",
                "TLChannel",
            ],
        )
        self.assertEqual(
            registry.resolve_explicit_staged_contract_symbols(
                target_path="src/services/RealMessageService.ets"
            ),
            [
                "IMessageService",
                "PeerId",
                "Message",
                "MessageTimeline",
                "Signal",
                "SendMessageParams",
                "GetHistoryParams",
                "TLUser",
                "TLChannel",
            ],
        )

    def test_realmessageservice_precompiled_specs_keep_curated_contract_and_exclude_tldialogs(self) -> None:
        specs = registry.resolve_precompiled_dependency_specs(
            target_path="src/services/RealMessageService.ets",
            dependency_paths=["src/core/mtproto/TLDialogs.ets"],
            registry=registry.normalize_registry(),
            include_same_directory_pool=False,
        )

        self.assertEqual(
            [item.source_path for item in specs],
            ["src/services/RealMessageServiceExternalContracts.ets"],
        )

    def test_collect_service_symbol_allowlist_merges_source_dependency_and_curated_contract_symbols(self) -> None:
        allowlist = registry.collect_service_symbol_allowlist(
            {
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "source": (
                        "import { Signal } from '@ohos/signalkit'\n"
                        "import { Message, PeerId } from '@ohos/models'\n"
                        "import { IMessageService, SendMessageParams, GetHistoryParams } from '@ohos/services'\n"
                    ),
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            }
        )

        for symbol in (
            "Signal",
            "Message",
            "MessageTimeline",
            "PeerId",
            "IMessageService",
            "SendMessageParams",
            "GetHistoryParams",
            "MTProtoClient",
            "TLUser",
            "TLChannel",
        ):
            self.assertIn(symbol, allowlist)

    def test_realmessageservice_explicit_contract_public_method_oracle_uses_imessageservice(self) -> None:
        oracle = registry.resolve_explicit_staged_contract_public_method_oracle(
            target_path="src/services/RealMessageService.ets"
        )

        self.assertEqual(
            [item["name"] for item in oracle],
            [
                "cacheUsers",
                "cacheChannels",
                "getMessages",
                "fetchMessages",
                "sendMessage",
            ],
        )
        self.assertTrue(all(item["container_name"] == "IMessageService" for item in oracle))
        oracle_map = registry.resolve_explicit_staged_contract_public_method_oracle_map(
            target_path="src/services/RealMessageService.ets"
        )
        self.assertEqual(
            oracle_map["getMessages"],
            "getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>",
        )
        self.assertEqual(
            oracle_map["fetchMessages"],
            "fetchMessages(params: GetHistoryParams): Future<Array<Message>>",
        )


if __name__ == "__main__":
    unittest.main()
