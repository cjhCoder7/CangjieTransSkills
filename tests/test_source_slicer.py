from __future__ import annotations

import sys
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import source_slicer  # noqa: E402


SOURCE_PATH = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoClient.ets"
TRANSPORT_SOURCE_PATH = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoTransport.ets"
AUTHKEYCREATOR_SOURCE_PATH = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "AuthKeyCreator.ets"
INFLATE_SOURCE_PATH = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "Inflate.ets"
CRYPTOUTILS_SOURCE_PATH = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "CryptoUtils.ets"
TLSERIALIZATION_SOURCE_PATH = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "TLSerialization.ets"
MTPROTOCONFIG_SOURCE_PATH = PROJECT_ROOT / "raw_docs" / "telegramharmony-phase02" / "src" / "core" / "mtproto" / "MTProtoConfig.ets"


class MTProtoClientSourceSlicerTests(unittest.TestCase):
    def test_build_chunk_plan_returns_six_source_aligned_chunks(self) -> None:
        source_text = SOURCE_PATH.read_text(encoding="utf-8")

        plan = source_slicer.build_chunk_plan(
            target_path="src/core/mtproto/MTProtoClient.ets",
            source_text=source_text,
        )

        self.assertEqual("mtprotoclient-method-boundary-v4", plan.strategy)
        self.assertEqual(
            ["chunk-a", "chunk-a-ctor", "chunk-a-callback", "chunk-a-init", "chunk-b", "chunk-c"],
            [chunk.chunk_id for chunk in plan.chunks],
        )

        chunk_a = plan.chunks[0]
        chunk_a_ctor = plan.chunks[1]
        chunk_a_callback = plan.chunks[2]
        chunk_a_init = plan.chunks[3]
        chunk_b = plan.chunks[4]
        chunk_c = plan.chunks[5]

        self.assertIn("export class MTProtoClient implements TransportCallback {", chunk_a.source_text)
        self.assertIn("private pendingRPCs: Map<string, RPCCallback> = new Map()", chunk_a.source_text)
        self.assertNotIn("constructor() {", chunk_a.source_text)
        self.assertNotIn("setUpdateCallback(callback: (update: Uint8Array) => void): void {", chunk_a.source_text)
        self.assertNotIn("async initialize(forceNewAuthKey: boolean = false): Promise<void> {", chunk_a.source_text)

        self.assertIn("constructor() {", chunk_a_ctor.source_text)
        self.assertNotIn("setUpdateCallback(callback: (update: Uint8Array) => void): void {", chunk_a_ctor.source_text)
        self.assertNotIn("async initialize(forceNewAuthKey: boolean = false): Promise<void> {", chunk_a_ctor.source_text)

        self.assertIn("setUpdateCallback(callback: (update: Uint8Array) => void): void {", chunk_a_callback.source_text)
        self.assertNotIn("constructor() {", chunk_a_callback.source_text)
        self.assertNotIn("async initialize(forceNewAuthKey: boolean = false): Promise<void> {", chunk_a_callback.source_text)

        self.assertIn("async initialize(forceNewAuthKey: boolean = false): Promise<void> {", chunk_a_init.source_text)
        self.assertNotIn("constructor() {", chunk_a_init.source_text)
        self.assertNotIn("setUpdateCallback(callback: (update: Uint8Array) => void): void {", chunk_a_init.source_text)
        self.assertNotIn("createAuthKey(): Promise<void>", chunk_a_init.source_text)
        self.assertNotIn("createAuthKey(): Promise<void>", chunk_a.source_text)

        self.assertIn("private async createAuthKey(): Promise<void> {", chunk_b.source_text)
        self.assertNotIn("async sendRequest(data: Uint8Array): Promise<Uint8Array> {", chunk_b.source_text)
        self.assertIn("req_pq_multi", chunk_b.missing_members)
        self.assertIn("req_DH_params", chunk_b.missing_members)
        self.assertIn("set_client_DH_params", chunk_b.missing_members)

        self.assertIn("async sendRequest(data: Uint8Array): Promise<Uint8Array> {", chunk_c.source_text)
        self.assertIn("onData(data: Uint8Array): void {", chunk_c.source_text)
        self.assertIn("export function getMTProtoClient(): MTProtoClient {", chunk_c.source_text)
        self.assertNotIn("onClose", chunk_c.expected_members)
        self.assertNotIn("onClose", chunk_c.missing_members)
        self.assertFalse(any("onClose" in warning for warning in plan.warnings))

    def test_assemble_chunks_preserves_declared_order(self) -> None:
        source_text = SOURCE_PATH.read_text(encoding="utf-8")
        plan = source_slicer.build_chunk_plan(
            target_path="src/core/mtproto/MTProtoClient.ets",
            source_text=source_text,
        )

        assembled = source_slicer.assemble_chunk_translations(
            plan,
            {
                "chunk-a": "AAA",
                "chunk-a-ctor": "BBB",
                "chunk-a-callback": "CCC",
                "chunk-a-init": "DDD",
                "chunk-b": "EEE",
                "chunk-c": "FFF",
            },
        )

        self.assertEqual("AAA\n\nBBB\n\nCCC\n\nDDD\n\nEEE\n\nFFF\n", assembled)

    def test_build_chunk_plan_supports_controlled_expansion_modules_as_single_chunks(self) -> None:
        cases = [
            ("src/core/mtproto/CryptoUtils.ets", CRYPTOUTILS_SOURCE_PATH, "cryptoutils-single-anchor-v1", "module"),
            ("src/core/mtproto/TLSerialization.ets", TLSERIALIZATION_SOURCE_PATH, "tlserialization-single-anchor-v1", "module"),
            ("src/core/mtproto/MTProtoConfig.ets", MTPROTOCONFIG_SOURCE_PATH, "mtprotoconfig-single-anchor-v1", "module"),
            ("src/core/mtproto/MTProtoTransport.ets", TRANSPORT_SOURCE_PATH, "mtprototransport-single-anchor-v1", "module"),
            ("src/core/mtproto/AuthKeyCreator.ets", AUTHKEYCREATOR_SOURCE_PATH, "authkeycreator-single-anchor-v1", "module"),
            ("src/core/mtproto/Inflate.ets", INFLATE_SOURCE_PATH, "inflate-single-anchor-v1", "module"),
        ]

        for target_path, source_path, expected_strategy, expected_chunk_id in cases:
            with self.subTest(target_path=target_path):
                plan = source_slicer.build_chunk_plan(
                    target_path=target_path,
                    source_text=source_path.read_text(encoding="utf-8"),
                )

                self.assertEqual(expected_strategy, plan.strategy)
                self.assertEqual([expected_chunk_id], [chunk.chunk_id for chunk in plan.chunks])
                self.assertEqual([], plan.chunks[0].missing_members)
                self.assertIn("Excerpted from ForestBook/TelegramHarmony", plan.chunks[0].source_text)

    def test_build_readonly_stub_keeps_only_skeleton_signatures(self) -> None:
        translated_code = """import std.sync.*
import std.collection.*

class RPCCallback {
    public var resolve: (Array<UInt8>) -> Unit
    public var reject: (Exception) -> Unit
    public var timeoutId: Int64

    public init(resolve: (Array<UInt8>) -> Unit, reject: (Exception) -> Unit, timeoutId: Int64) {
        this.resolve = resolve
        this.reject = reject
        this.timeoutId = timeoutId
    }
}

public class MTProtoClient <: TransportCallback {
    private let transportManager: TransportManager
    private var session: SessionInfo
    private let pendingRPCs: HashMap<String, RPCCallback> = HashMap<String, RPCCallback>()
    private var updateCallback: ?((Array<UInt8>) -> Unit) = None
    private var connectionInitialized: Bool = false

    public init() {
        this.transportManager = TransportManager()
        this.session = SessionManager.getSession(MTProtoConfig.USE_TEST_DC ? 2 : 1)
    }

    public func setUpdateCallback(callback: (Array<UInt8>) -> Unit): Unit {
        this.updateCallback = callback
    }

    public func initialize(): Future<Unit> {
        return initialize(false)
    }

    public func initialize(forceNewAuthKey: Bool): Future<Unit> {
        spawn {
            let transport = this.transportManager.getTransport()
            transport.setCallback(this)
            if (forceNewAuthKey) {
                this.session.authKey = None
                this.session.authKeyState = AuthKeyState.None
            }
            transport.connect().get()
            if (this.session.authKey == None) {
                this.createAuthKey().get()
            }
        }
    }

    private func createAuthKey(): Future<Unit> {
        spawn {
            // Placeholder for Chunk B implementation
        }
    }

    public func onConnected(): Unit {
        // Placeholder for TransportCallback contract
    }

    public func onDisconnected(): Unit {
        // Placeholder for TransportCallback contract
    }

    public func onData(data: Array<UInt8>): Unit {
        // Placeholder for TransportCallback contract
    }

    public func onError(error: Exception): Unit {
        // Placeholder for TransportCallback contract
    }
}

private var clientSingleton: ?MTProtoClient = None

public func getMTProtoClient(): MTProtoClient {
    match (clientSingleton) {
        case Some(c) => c
        case None => {
            let c = MTProtoClient()
            clientSingleton = Some(c)
            c
        }
    }
}
"""

        stub = source_slicer.build_readonly_stub(translated_code, max_chars=4000)

        expected = """import std.sync.*
import std.collection.*
class RPCCallback {
    public var resolve: (Array<UInt8>) -> Unit
    public var reject: (Exception) -> Unit
    public var timeoutId: Int64
    public init(resolve: (Array<UInt8>) -> Unit, reject: (Exception) -> Unit, timeoutId: Int64) {}
}
public class MTProtoClient <: TransportCallback {
    private let transportManager: TransportManager
    private var session: SessionInfo
    private let pendingRPCs: HashMap<String, RPCCallback>
    private var updateCallback: ?((Array<UInt8>) -> Unit)
    private var connectionInitialized: Bool
    public init() {}
    public func setUpdateCallback(callback: (Array<UInt8>) -> Unit): Unit {}
    public func initialize(): Future<Unit> {}
    public func initialize(forceNewAuthKey: Bool): Future<Unit> {}
    private func createAuthKey(): Future<Unit> {}
    public func onConnected(): Unit {}
    public func onDisconnected(): Unit {}
    public func onData(data: Array<UInt8>): Unit {}
    public func onError(error: Exception): Unit {}
}
private var clientSingleton: ?MTProtoClient
public func getMTProtoClient(): MTProtoClient {}"""

        self.assertEqual(expected, stub)
        self.assertNotIn("let transport =", stub)
        self.assertNotIn("transport.connect().get()", stub)
        self.assertNotIn("let c = MTProtoClient()", stub)
        self.assertNotIn("match (clientSingleton)", stub)

    def test_build_chunked_readonly_stub_merges_split_mtprotoclient_members_into_single_class(self) -> None:
        chunk_outputs = {
            "chunk-a": """package core.mtproto

import std.sync.*
import std.collection.*

public class RPCCallback {
    public let resolve: (Array<UInt8>) -> Unit
    public let reject: (Exception) -> Unit
    public let timeoutId: Int64
}

public class MTProtoClient <: TransportCallback {
    private var transportManager: ?TransportManager = None
    private var session: ?SessionInfo = None
    private var pendingRPCs: HashMap<String, RPCCallback> = HashMap<String, RPCCallback>()
    private var updateCallback: ?(Array<UInt8>)->Unit = None
    private var connectionInitialized: Bool = false

    public func onConnected(): Unit {}
    public func onDisconnected(): Unit {}
}
""",
            "chunk-a-ctor": """public init() {
        this.transportManager = TransportManager()
    }
""",
            "chunk-a-callback": """public func setUpdateCallback(callback: (Array<UInt8>) -> Unit): Unit {
        this.updateCallback = callback
    }

""",
            "chunk-a-init": """public func initialize(): Future<Unit> {
        initialize(false)
    }

""",
            "chunk-b": """private func createAuthKey(): Future<Unit> {
        spawn {
            ()
        }
    }
""",
        }

        stub = source_slicer.build_chunked_readonly_stub(
            target_path="src/core/mtproto/MTProtoClient.ets",
            translated_chunks=chunk_outputs,
            max_chars=4000,
        )

        self.assertEqual(1, stub.count("public class MTProtoClient <: TransportCallback {"))
        self.assertIn("    public init() {}", stub)
        self.assertIn("    public func setUpdateCallback(callback: (Array<UInt8>) -> Unit): Unit {}", stub)
        self.assertIn("    public func initialize(): Future<Unit> {}", stub)
        self.assertIn("    private func createAuthKey(): Future<Unit> {}", stub)
        self.assertNotIn("}\npublic init()", stub)
        self.assertNotIn("}\nprivate func createAuthKey()", stub)

    def test_build_chunked_readonly_stub_ignores_singleton_tail_until_chunk_c(self) -> None:
        chunk_outputs = {
            "chunk-a": """import std.sync.*
import std.collection.*

class RPCCallback {
    public let resolve: (Array<UInt8>) -> Unit
}

private var clientSingleton: Option<MTProtoClient> = None

public func getMTProtoClient(): MTProtoClient {
    match (clientSingleton) {
        case Some(client) => client
        case None => MTProtoClient()
    }
}

public class MTProtoClient <: TransportCallback {
    private var transportManager: Option<TransportManager> = None
}
""",
            "chunk-a-ctor": """public init() {}
""",
            "chunk-a-callback": """public func setUpdateCallback(callback: (Array<UInt8>) -> Unit): Unit {
        this.updateCallback = callback
    }
""",
        }

        stub = source_slicer.build_chunked_readonly_stub(
            target_path="src/core/mtproto/MTProtoClient.ets",
            translated_chunks=chunk_outputs,
            max_chars=4000,
        )

        self.assertNotIn("clientSingleton", stub)
        self.assertNotIn("getMTProtoClient", stub)
        self.assertIn("public class MTProtoClient <: TransportCallback {", stub)
        self.assertIn("    public init() {}", stub)


if __name__ == "__main__":
    unittest.main()
