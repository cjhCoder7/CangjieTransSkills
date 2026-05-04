from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import workspace_manager  # noqa: E402


class WorkspaceManagerPrecompiledDependencyTests(unittest.TestCase):
    def test_stage_precompiled_dependencies_normalizes_package_and_writes_files(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            dep_a = temp_root / "dep-a.cj"
            dep_b = temp_root / "dep-b.cj"
            dep_a.write_text("package mtproto\n\npublic class MTProtoConfig {}\n", encoding="utf-8")
            dep_b.write_text("package another.pkg\n\npublic class TLSerialization {}\n", encoding="utf-8")
            manager = workspace_manager.WorkspaceManager(
                temp_root / "workspace",
                precompiled_registry={
                    "src/core/mtproto/MTProtoConfig.ets": dep_a,
                    "src/core/mtproto/TLSerialization.ets": dep_b,
                },
            )
            session = manager.create_session(
                "tu::pipeline-mtprotoclient::src::core::mtproto::MTProtoClient.ets",
                "src/core/mtproto/MTProtoClient.ets",
            )
            manager.write_candidate_code(
                session,
                attempt=1,
                source_target_path="src/core/mtproto/MTProtoClient.ets",
                generated_code="package core.mtproto\n\npublic class MTProtoClient {}\n",
            )

            staged = manager.stage_precompiled_dependencies(
                session,
                attempt=1,
                source_target_path="src/core/mtproto/MTProtoClient.ets",
                tu={
                    "target": {
                        "path": "src/core/mtproto/MTProtoClient.ets",
                        "role": "module",
                        "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]"],
                    },
                    "dependency_closure": [
                        {"path": "src/core/mtproto/MTProtoConfig.ets"},
                    ],
                },
            )

            self.assertEqual(len(staged), 2)
            self.assertTrue(all(item.normalized_package_name == "core.mtproto" for item in staged))
            staged_texts = [item.staged_file_path.read_text(encoding="utf-8") for item in staged]
            self.assertTrue(all(text.startswith("package core.mtproto\n") for text in staged_texts))

    def test_stage_precompiled_dependencies_supports_mtproto_core_module_without_async_flow_tag(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            dep_a = temp_root / "dep-a.cj"
            dep_b = temp_root / "dep-b.cj"
            dep_a.write_text("package core.mtproto\n\npublic class MTProtoClient {}\n", encoding="utf-8")
            dep_b.write_text("package core.mtproto\n\npublic class MTProtoTransport {}\n", encoding="utf-8")
            manager = workspace_manager.WorkspaceManager(
                temp_root / "workspace",
                precompiled_registry={
                    "src/core/mtproto/MTProtoClient.ets": dep_a,
                    "src/core/mtproto/MTProtoTransport.ets": dep_b,
                },
            )
            session = manager.create_session(
                "tu::pipeline-inflate::src::core::mtproto::Inflate.ets",
                "src/core/mtproto/Inflate.ets",
            )
            manager.write_candidate_code(
                session,
                attempt=1,
                source_target_path="src/core/mtproto/Inflate.ets",
                generated_code="package core.mtproto\n\npublic func decompress(data: Array<UInt8>): Array<UInt8> { data }\n",
            )

            staged = manager.stage_precompiled_dependencies(
                session,
                attempt=1,
                source_target_path="src/core/mtproto/Inflate.ets",
                tu={
                    "target": {
                        "path": "src/core/mtproto/Inflate.ets",
                        "role": "module",
                        "risk_tags": ["[BINARY_PROTO]"],
                    },
                    "dependency_closure": [],
                },
            )

            self.assertEqual(len(staged), 2)

    def test_realmessageservice_target_stages_curated_contract_bundle_and_normalizes_candidate_package(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            manager = workspace_manager.WorkspaceManager(temp_root / "workspace")
            session = manager.create_session(
                "tu::pipeline-realmessageservice::src::services::RealMessageService.ets",
                "src/services/RealMessageService.ets",
            )
            write_result = manager.write_candidate_code(
                session,
                attempt=1,
                source_target_path="src/services/RealMessageService.ets",
                generated_code="public class RealMessageService {}\n",
            )

            staged = manager.stage_precompiled_dependencies(
                session,
                attempt=1,
                source_target_path="src/services/RealMessageService.ets",
                tu={
                    "target": {
                        "path": "src/services/RealMessageService.ets",
                        "role": "service",
                        "risk_tags": ["[ASYNC_FLOW]", "[SERVICE_LAYER]"],
                    },
                    "dependency_closure": [
                        {"path": "src/core/mtproto/TLDialogs.ets"},
                    ],
                },
            )

            candidate_text = write_result.candidate_file_path.read_text(encoding="utf-8")
            self.assertTrue(candidate_text.startswith("package services\n"))
            self.assertEqual(write_result.candidate_rel_path, "src/services/RealMessageService.cj")

            self.assertEqual(len(staged), 1)
            self.assertEqual(staged[0].source_path, "src/services/RealMessageServiceExternalContracts.ets")
            self.assertEqual(staged[0].normalized_package_name, "services")
            self.assertTrue(
                str(staged[0].original_candidate_path).endswith(
                    "tests/fixtures/anchors/precompiled/realmessageservice_service_contracts.cj"
                )
            )

            staged_text = staged[0].staged_file_path.read_text(encoding="utf-8")
            self.assertTrue(staged_text.startswith("package services\n"))
            self.assertIn("public interface IMessageService", staged_text)
            self.assertEqual(staged[0].staged_rel_path, "src/services/RealMessageServiceExternalContracts.cj")

            compile_file_paths = [str(write_result.candidate_file_path)] + [
                str(item.staged_file_path) for item in staged
            ]
            self.assertEqual(len(compile_file_paths), 2)
            self.assertEqual(compile_file_paths[0], str(write_result.candidate_file_path))
            self.assertEqual(compile_file_paths[1], str(staged[0].staged_file_path))


if __name__ == "__main__":
    unittest.main()
