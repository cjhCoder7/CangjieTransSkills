from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import prompt_assembler  # noqa: E402


PHASE06_UI_MANIFEST_PAYLOAD = {
    "manifest_name": "phase06-ui-sample-manifest",
    "tag_rules": {
        "structure_tags": ["page-shell", "rich-component"],
        "ownership_tags": ["view-model-renderer", "controller-owned-state"],
        "optional_interaction_tags": ["gesture-component"],
        "optional_exception_tags": ["ffi-exception", "hybrid-exception"],
        "optional_sample_scope_tags": ["mixed-app-pattern"],
    },
}

PHASE06_UI_FEW_SHOT_PACK_PAYLOAD = {
    "pack_name": "phase06-ui-few-shot-pack",
    "pack_version": 1,
    "created_at": "2026-04-06T00:00:00Z",
    "selection_policy": {
        "max_examples_per_prompt": 2,
    },
    "entries": [
        {
            "entry_id": "control-page-shell-view-model-renderer",
            "priority": "P0",
            "selection_rank": 1,
            "source_type": "local_repo",
            "target_roles": ["page"],
            "structure_tag": "page-shell",
            "ownership_tag": "view-model-renderer",
            "interaction_tags": [],
            "exception_tags": [],
            "sample_scope_tags": [],
            "source": {"repo_root": "/repo", "commit": "N/A"},
            "source_paths": ["samples/ui-routing-defining-page-layout/entry/src/main/cangjie/pages/FoodCategoryListPage.cj"],
            "why_it_matches": "Local page-shell control with source-aligned routing and page-owned composition.",
            "prompt_hints": ["Preserve page/router boundary", "Keep render helpers source-aligned"],
            "source_excerpt": (
                "@Entry\n"
                "@Component\n"
                "class FoodCategoryListPage {\n"
                "    @State var showList: Bool = false\n"
                "    func openFoodDetail(foodItem: FoodData): Unit {\n"
                "        getUIContext().getRouter().pushUrl(url: \"FoodDetailPage\", params: foodItem.id)\n"
                "    }\n"
                "    func build() {\n"
                "        Column { this.buildHeader() }\n"
                "    }\n"
                "}\n"
            ),
        },
        {
            "entry_id": "external-page-shell-view-model-renderer",
            "priority": "P0",
            "selection_rank": 2,
            "source_type": "external_repo",
            "target_roles": ["page"],
            "structure_tag": "page-shell",
            "ownership_tag": "view-model-renderer",
            "interaction_tags": [],
            "exception_tags": [],
            "sample_scope_tags": [],
            "source": {"url": "https://example.test/ui", "commit": "frozen-external"},
            "source_paths": ["CommonUI/entry/src/main/cangjie/src/pages/badgeSample.cj"],
            "why_it_matches": "External page-shell sample with page-owned state and component composition.",
            "prompt_hints": ["Keep page state minimal", "Child components consume linked props"],
            "source_excerpt": (
                "@Entry\n"
                "@Component\n"
                "class BadgeView {\n"
                "    @State var count1: Int32 = 199\n"
                "    func build() {\n"
                "        Column() {\n"
                "            Grid { GridItem { NumberBadge(count: count1, pos: BadgePosition.RightTop) } }\n"
                "        }\n"
                "    }\n"
                "}\n"
            ),
        },
        {
            "entry_id": "control-page-shell-controller-owned-state",
            "priority": "P0",
            "selection_rank": 1,
            "source_type": "local_repo",
            "target_roles": ["page"],
            "structure_tag": "page-shell",
            "ownership_tag": "controller-owned-state",
            "interaction_tags": [],
            "exception_tags": [],
            "sample_scope_tags": [],
            "source": {"repo_root": "/repo", "commit": "N/A"},
            "source_paths": ["samples/data-persistence-001/entry/src/main/cangjie/pages/ThemeSettingsPage.cj"],
            "why_it_matches": "Local page-shell sample where controller/manager remains the durable truth owner.",
            "prompt_hints": ["Keep manager/controller as truth owner", "UI mirrors minimal display state"],
            "source_excerpt": (
                "@Entry\n"
                "@Component\n"
                "class ThemeSettingsPage {\n"
                "    var manager: Option<UserSettingsManager> = Option<UserSettingsManager>.None\n"
                "    @State var currentTheme: String = \"default\"\n"
                "    protected override func aboutToAppear(): Unit {\n"
                "        this.attachManager()\n"
                "        this.syncFromManager()\n"
                "    }\n"
                "    func build() { Scroll { Column { this.buildHeader() } } }\n"
                "}\n"
            ),
        },
        {
            "entry_id": "gesture-rich-component-controller-owned-state",
            "priority": "P0",
            "selection_rank": 1,
            "source_type": "external_repo",
            "target_roles": ["component"],
            "structure_tag": "rich-component",
            "ownership_tag": "controller-owned-state",
            "interaction_tags": ["gesture-component"],
            "exception_tags": [],
            "sample_scope_tags": [],
            "source": {"url": "https://example.test/photoview", "commit": "gesture-frozen"},
            "source_paths": ["photoView/src/main/cangjie/photo_view.cj"],
            "why_it_matches": "Gesture-heavy reusable component with controller-owned interaction state.",
            "prompt_hints": ["Preserve gesture callbacks", "Do not move long-running work into gestures"],
            "source_excerpt": (
                "@Component\n"
                "public class PhotoView {\n"
                "    @State var model: PhotoViewModel = PhotoViewModel()\n"
                "    func build() {\n"
                "        Flex(FlexParams(direction: FlexDirection.Column)) { }\n"
                "        .gesture(GestureGroup(GestureMode.Exclusive, [TapGesture(count: 2, fingers: 1)]))\n"
                "    }\n"
                "}\n"
            ),
        },
        {
            "entry_id": "rich-component-view-model-renderer",
            "priority": "P1",
            "selection_rank": 1,
            "source_type": "external_repo",
            "target_roles": ["component"],
            "structure_tag": "rich-component",
            "ownership_tag": "view-model-renderer",
            "interaction_tags": [],
            "exception_tags": [],
            "sample_scope_tags": [],
            "source": {"url": "https://example.test/svg", "commit": "renderer-frozen"},
            "source_paths": ["svg/src/main/cangjie/src/svg_image_view.cj"],
            "why_it_matches": "Reusable renderer component that consumes model state without becoming a page shell.",
            "prompt_hints": ["Keep reusable component boundary", "Avoid page/router ownership bleed"],
            "source_excerpt": (
                "@Component\n"
                "public class SVGImageView {\n"
                "    @State var model: SVGImageViewModel = SVGImageViewModel()\n"
                "    @Builder func setSvgCanvas(b: Bool) {\n"
                "        Canvas(this.context2D).width(100.percent).height(100.percent)\n"
                "    }\n"
                "    func build() { Column { setSvgCanvas(pxTovpRes()) } }\n"
                "}\n"
            ),
        },
        {
            "entry_id": "exception-only-ffi-rich-component",
            "priority": "P1",
            "selection_rank": 1,
            "source_type": "external_repo",
            "target_roles": ["component"],
            "structure_tag": "rich-component",
            "ownership_tag": "view-model-renderer",
            "interaction_tags": [],
            "exception_tags": ["ffi-exception"],
            "sample_scope_tags": [],
            "source": {"url": "https://example.test/ffi", "commit": "ffi-frozen"},
            "source_paths": ["avif4cj/src/main/cangjie/avif_decoder.cj"],
            "why_it_matches": "Exception-rail sample for FFI/native UI boundaries only.",
            "prompt_hints": ["Only use on exception-tagged targets"],
            "source_excerpt": (
                "@Component\n"
                "class AvifImageView {\n"
                "    func build() { Image(\"ffi\") }\n"
                "}\n"
            ),
        },
    ],
}


class PromptAssemblerSourceAlignmentTests(unittest.TestCase):
    def test_sanitize_source_for_prompt_strips_comments_and_blank_lines(self) -> None:
        cleaned = prompt_assembler.sanitize_source_for_prompt(
            "/** header */\n"
            "export class Demo {\n"
            "  // comment\n"
            "  value: number // trailing\n"
            "\n"
            "\n"
            "  /* block */\n"
            "  method(): void {}\n"
            "}\n"
        )

        self.assertNotIn("header", cleaned)
        self.assertNotIn("comment", cleaned)
        self.assertNotIn("trailing", cleaned)
        self.assertNotIn("block", cleaned)
        self.assertIn("export class Demo {", cleaned)
        self.assertIn("value: number", cleaned)
        self.assertIn("method(): void {}", cleaned)
        self.assertNotIn("\n\n\n", cleaned)

    def test_translator_prompt_injects_source_alignment_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "signatures": [
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(peerId, limit)", "summary": "fn"}
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping"],
            attempt=1,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("BCM-ALIGN-001", user_prompt)
        self.assertIn("BCM-ALIGN-002", user_prompt)
        self.assertIn("public API 签名", user_prompt)
        self.assertIn("private / internal", user_prompt)
        self.assertIn("raw_docs/telegramharmony-phase02", user_prompt)
        self.assertIn("src/services/RealMessageService.ets", user_prompt)

    def test_translator_prompt_injects_service_protocol_isolation_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"}
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/TLMethods.ets"},
                    {"path": "src/core/mtproto/TLSerialization.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint"],
            attempt=1,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("DOMAIN PURITY VIOLATION AVOIDANCE", user_prompt)
        self.assertIn("You are translating a Service layer file.", user_prompt)
        self.assertIn("MUST NOT directly import or use raw protocol layer details", user_prompt)
        self.assertIn("PROTOCOL ISOLATION", user_prompt)
        self.assertIn("private/internal collaborator seam", user_prompt)
        self.assertIn("OPAQUE HANDLE BAN", user_prompt)
        self.assertIn("MUST NOT invent intermediary 'handle' classes or private helper methods", user_prompt)
        self.assertIn("InputPeerHandle", user_prompt)
        self.assertIn("createInputPeer", user_prompt)
        self.assertIn("any `*Peer*` wrapper", user_prompt)
        self.assertIn("Completely decouple from the peer/input peer concepts", user_prompt)
        self.assertIn("INPUTPEER ZERO-TOLERANCE", user_prompt)
        self.assertIn("The identifiers `InputPeer` and `createInputPeer` MUST NOT appear anywhere in this file", user_prompt)
        self.assertIn("NO PEER-CONVERSION HELPERS", user_prompt)
        self.assertIn("Do NOT write `private func createInputPeer(...)`", user_prompt)
        self.assertIn("PUBLIC SURFACE LOCK", user_prompt)
        self.assertIn("preserve the ArkTS public service surface exactly", user_prompt)
        self.assertIn("Do NOT rewrite public signatures to invented domain-only substitutes", user_prompt)
        self.assertIn("STRICT SIGNATURE PRESERVATION", user_prompt)
        self.assertIn("STRICTLY BANNED from altering public method signatures", user_prompt)
        self.assertIn("Do NOT invent `User`, `Channel`", user_prompt)
        self.assertIn("NO LOCAL MOCKING", user_prompt)
        self.assertIn("Do NOT invent or declare fake `TL*` classes within the Service layer", user_prompt)
        self.assertIn("SYNCHRONOUS/ASYNCHRONOUS FIDELITY", user_prompt)
        self.assertIn("preserve the exact synchronous or asynchronous nature", user_prompt)
        self.assertIn("do NOT wrap it in `Future` merely because internal work uses `spawn`", user_prompt)
        self.assertIn("STRICT CONCURRENCY MANDATE", user_prompt)
        self.assertIn("TypeScript's `async/await` is STRICTLY BANNED", user_prompt)
        self.assertIn("Internal concurrency is allowed, but it MUST NOT force public return types", user_prompt)
        self.assertIn("STD SYNC ONLY", user_prompt)
        self.assertIn("import them from `std.sync.*` only", user_prompt)
        self.assertIn("Absolutely DO NOT import `std.concurrent.*`", user_prompt)
        self.assertIn("COLLABORATOR SYMBOL ALLOWLIST", user_prompt)
        self.assertIn("EXPLICIT STAGED CONTRACT ALLOWLIST FOR THIS TARGET", user_prompt)
        self.assertIn("INVENTED COLLABORATOR ZERO-TOLERANCE", user_prompt)
        self.assertIn("MessageBackend", user_prompt)
        self.assertIn("ServiceLocator", user_prompt)
        self.assertIn("EXPLICIT STAGED CONTRACT PUBLIC ORACLE", user_prompt)
        self.assertIn("PUBLIC METHOD ORACLE FOR THIS TARGET", user_prompt)
        self.assertIn("func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>", user_prompt)
        self.assertIn("PUBLIC CONTRACT FIDELITY AGAINST ORACLE", user_prompt)
        self.assertIn("`Int32` -> `Int64`", user_prompt)
        self.assertIn("TARGETED ORACLE REGRESSION LOCK", user_prompt)
        self.assertIn("`getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>`", user_prompt)
        self.assertIn("MUST NOT materialize that contract via `ValueSignal(...)`", user_prompt)
        self.assertIn("SERVICE PROTOCOL NAME ZERO-TOLERANCE", user_prompt)
        self.assertIn("`MessagesGetHistory` and `MessagesSendMessage`", user_prompt)
        self.assertIn("`getMTProtoClient()`", user_prompt)
        self.assertIn("PHASE 04 INTERNAL PURITY ONLY", user_prompt)
        self.assertIn("not by mutating the source-aligned public API", user_prompt)
        self.assertIn("ZERO-ARGUMENT PUBLIC CONSTRUCTOR & NO DI LEAKAGE", user_prompt)
        self.assertIn("Preserve the exact public constructor signature", user_prompt)
        self.assertIn("emit a zero-arg `public init()`", user_prompt)
        self.assertIn("must stay `private/internal`", user_prompt)
        self.assertIn("INTERNAL WIRING ONLY", user_prompt)
        self.assertIn("OPTION NONE COMPARISON BAN", user_prompt)
        self.assertIn("Do NOT compare `Option` / `?T` values with `== None` or `!= None`", user_prompt)
        self.assertIn("CANGJIE MAP UPDATE RULE", user_prompt)
        self.assertIn("write entries with index assignment (`map[key] = value`) instead of Java-style `.put(key, value)`", user_prompt)
        self.assertIn("SERVICE FILE BOUNDARY", user_prompt)
        self.assertIn("Do NOT stuff support/domain/runtime declarations back into the same service file", user_prompt)
        self.assertIn("`PeerId`, `DomainMessage`, `DomainUser`, `DomainChannel`", user_prompt)
        self.assertIn("NO INLINE PUBLIC DOMAIN TYPES", user_prompt)
        self.assertIn("MUST NOT define or invent new public domain/support classes", user_prompt)
        self.assertIn("REUSE OVER REDECLARE", user_prompt)
        self.assertIn("SINGLE-PUBLIC-TYPE TEMPLATE", user_prompt)
        self.assertIn("Prefer emitting only `RealMessageService` as the public type", user_prompt)
        self.assertIn("PUBLIC CONTRACT TOKEN SCOPE LOCK", user_prompt)
        self.assertIn("those tokens may appear ONLY on the matching public method signatures", user_prompt)
        self.assertIn("Do NOT spread them into top-level imports", user_prompt)
        self.assertIn("NO TL IMPORTS FOR PUBLIC CONTRACT TYPES", user_prompt)
        self.assertIn("without emitting top-level `import ...TL*` / `protocol.TL*` lines", user_prompt)
        self.assertIn("SHADOW SIGNAL RUNTIME BAN", user_prompt)
        self.assertIn("Do NOT invent an observer-backed `MessageSignal`", user_prompt)
        self.assertIn("NO SHADOW STATE INFRASTRUCTURE", user_prompt)
        self.assertIn("strictly BANNED from defining, inventing, or implementing ANY reactive state infrastructure", user_prompt)
        self.assertIn("`Signal`, `ValueSignal`, `SignalPipe`, `Store`, `Observable`", user_prompt)
        self.assertIn("EXTERNAL DEPENDENCY ASSUMPTION", user_prompt)
        self.assertIn("Preserve them only where the source-aligned public contract explicitly requires them", user_prompt)
        self.assertIn("do NOT declare new service-local `Signal<T>` / `Store<T>` variables", user_prompt)
        self.assertIn("NO INLINE COLLABORATOR SHELLS", user_prompt)
        self.assertIn("Do NOT define placeholder service-local collaborator interfaces", user_prompt)
        self.assertIn("NO REACTIVE DECLARATIONS IN SERVICE FILE", user_prompt)
        self.assertIn("this file MUST NOT declare fields, locals, maps, helper return types, constructor state, or caches typed as `Signal`", user_prompt)
        self.assertIn("Do NOT write `let state: Signal<T>` or `var store: Store<T>`", user_prompt)
        self.assertIn("REACTIVE CONTRACT EXTERNALIZATION", user_prompt)
        self.assertIn("preserve that source-aligned public contract while externalizing ownership", user_prompt)
        self.assertIn("without mutating the public signature", user_prompt)
        self.assertIn("PUBLIC REACTIVE CONTRACT RETURN ONLY", user_prompt)
        self.assertIn("only that matching public method may mention the reactive contract", user_prompt)
        self.assertIn("`private/internal` helpers must return non-reactive shapes", user_prompt)
        self.assertIn("REACTIVE CONTRACT POSITION LOCK", user_prompt)
        self.assertIn("`Signal`, `ValueSignal`, and `SignalPipe` may appear ONLY on source-/oracle-aligned public method signatures", user_prompt)
        self.assertIn("Do NOT write `Signal<T>()`, `ValueSignal<T>(...)`, `SignalPipe<T>(...)`", user_prompt)
        self.assertIn("LEGAL REACTIVE FORWARDING PATH", user_prompt)
        self.assertIn("the returned `Signal` must be obtained or forwarded from a real externally provided symbol", user_prompt)
        self.assertIn("If the current context does not expose a real reactive provider/facade symbol, do NOT invent one", user_prompt)
        self.assertIn("TARGETED REACTIVE COLLABORATOR ANCHOR", user_prompt)
        self.assertIn("`MessageTimeline`", user_prompt)
        self.assertIn("private let timeline: MessageTimeline = MessageTimeline()", user_prompt)
        self.assertIn("this.timeline.fetchMessages(params)` / `this.timeline.sendMessage(params)", user_prompt)
        self.assertIn("COMPILE-CLOSURE RETURN RULE", user_prompt)
        self.assertIn("comment-only bodies, empty bodies, or `spawn` blocks that end in comments are compile-failed regressions", user_prompt)
        self.assertIn("NO TODO / REACTIVE PLACEHOLDER ESCAPES", user_prompt)
        self.assertIn("Do NOT use `throw TODO`, `TODO()`, placeholder `Signal<T>()`", user_prompt)
        self.assertIn("let the next compile/repair round expose the missing external contract", user_prompt)
        self.assertIn("NO INLINE COLLABORATOR IMPLEMENTATIONS", user_prompt)
        self.assertIn("Do NOT declare placeholder collaborator implementations", user_prompt)
        self.assertIn("STRICT IDENTIFIER BAN", user_prompt)
        self.assertIn("Absolutely NO `Gateway` or `Bridge` identifiers", user_prompt)
        self.assertIn("PRIVATE COLLABORATOR CONTAINMENT", user_prompt)
        self.assertIn("Internal mechanisms such as `MessagePort`, channels, adapters", user_prompt)
        self.assertIn("They MUST NOT dictate, pollute, or alter public method names", user_prompt)
        self.assertIn("NEUTRAL COLLABORATOR RULE", user_prompt)
        self.assertIn("Neutral field names such as `backend`, `messagePort`, or `transportPort` are acceptable only as variable names", user_prompt)
        self.assertIn("collaborator naming must never leak into public signatures", user_prompt)
        self.assertIn("ZERO-BLOCK / FUTURE COMPILE SHAPE", user_prompt)
        self.assertIn("do NOT hand-roll JS-style resolver constructors", user_prompt)
        self.assertIn("MATCH / LAMBDA SINGLE-EXPRESSION RULE", user_prompt)
        self.assertIn("for Unit branches prefer a single-expression `()`", user_prompt)
        self.assertIn("ZERO-BLOCK STATIC FIREWALL", user_prompt)
        self.assertIn("`case None => {}` and block-style `case Some(...) => { ... }`", user_prompt)
        self.assertIn("PRIORITY", user_prompt)
        self.assertIn("Architectural purity and protocol isolation take absolute precedence", user_prompt)
        self.assertNotIn("internal service-locator managed dependency", user_prompt)
        self.assertNotIn("SIGNATURE TRANSFORMATION AUTHORIZED", user_prompt)
        self.assertNotIn("Gateway/Repository interface", user_prompt)
        self.assertNotIn("must return a `Future`", user_prompt)
        self.assertNotIn("rewrite the service API to a non-reactive domain-safe shape", user_prompt)
        self.assertNotIn("当前无额外 target-specific 指令。", user_prompt)

    def test_translator_system_prompt_injects_critical_output_directive_at_highest_priority(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=1,
            repair_guidance=[],
        )

        system_prompt = next(message.content for message in package.messages if message.role == "system")
        self.assertTrue(system_prompt.startswith("[CRITICAL OUTPUT DIRECTIVE]"))
        self.assertIn("DO NOT overthink type alignments or cryptographic bit-widths", system_prompt)
        self.assertIn("KEEP REASONING BRIEF (Under 500 tokens)", system_prompt)
        self.assertIn("IMMEDIATELY output the Cangjie code blocks", system_prompt)
        self.assertIn("Array<UInt8>", system_prompt)
        self.assertIn("Do NOT attempt to simulate the compiler's memory allocation", system_prompt)

    def test_translator_prompt_lists_same_file_public_symbols(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoConfig.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoConfig.ets",
                    "role": "module",
                    "signatures": [
                        {"kind": "enum", "name": "AuthKeyState", "signature": "enum AuthKeyState", "summary": "enum"},
                        {"kind": "interface", "name": "SessionInfo", "signature": "interface SessionInfo", "summary": "interface"},
                        {"kind": "class", "name": "MTProtoConfig", "signature": "class MTProtoConfig", "summary": "class"},
                        {"kind": "class", "name": "SessionManager", "signature": "class SessionManager", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=2,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("同文件 public symbols", user_prompt)
        self.assertIn("AuthKeyState", user_prompt)
        self.assertIn("SessionInfo", user_prompt)
        self.assertIn("SessionManager", user_prompt)

    def test_translator_prompt_adds_option_binary_proto_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoConfig.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoConfig.ets",
                    "role": "module",
                    "signatures": [
                        {"kind": "class", "name": "MTProtoConfig", "signature": "class MTProtoConfig", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=3,
            repair_guidance=[
                "修复问题: compile-failed",
                "编译器/测试stderr: expected ';' or '<NL>', found '?'",
                "源侧字段: Uint8Array | null",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("?T", user_prompt)
        self.assertIn("不要写 `T?`", user_prompt)
        self.assertIn("Array<UInt8>", user_prompt)
        self.assertIn("None", user_prompt)

    def test_translator_prompt_adds_enum_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoConfig.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoConfig.ets",
                    "role": "module",
                    "signatures": [
                        {"kind": "enum", "name": "AuthKeyState", "signature": "enum AuthKeyState", "summary": "enum"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=4,
            repair_guidance=[
                "修复问题: compile-failed",
                "编译器/测试stderr: expected a enum name after keyword 'enum'",
                "编译器/测试stderr: expected declaration, found Created",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("不要写 `enum class`", user_prompt)
        self.assertIn("| Created", user_prompt)

    def test_translator_prompt_adds_named_argument_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoConfig.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoConfig.ets",
                    "role": "module",
                    "signatures": [
                        {"kind": "class", "name": "SessionManager", "signature": "class SessionManager", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=5,
            repair_guidance=[
                "修复问题: compile-failed",
                "编译器/测试stderr: invalid named arguments prefix 'dcId:'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("不要写 `dcId:`", user_prompt)
        self.assertIn("位置参数", user_prompt)

    def test_translator_prompt_adds_accessor_syntax_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoConfig.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoConfig.ets",
                    "role": "module",
                    "signatures": [
                        {"kind": "interface", "name": "SessionInfo", "signature": "interface SessionInfo", "summary": "interface"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=6,
            repair_guidance=[
                "修复问题: compile-failed",
                "编译器/测试stderr: expected declaration, found 'get'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("不要写 `get dcId()`", user_prompt)
        self.assertIn("func getDcId()", user_prompt)

    def test_translator_prompt_adds_binary_proto_module_guardrails(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::TLMethods.ets",
                "target": {
                    "path": "src/core/mtproto/TLMethods.ets",
                    "role": "module",
                    "risk_tags": ["[BINARY_PROTO]", "module"],
                    "signatures": [
                        {"kind": "class", "name": "InputPeer", "signature": "class InputPeer", "summary": "class"},
                        {"kind": "class", "name": "InputPeerEmpty", "signature": "class InputPeerEmpty extends InputPeer", "summary": "class"},
                        {"kind": "class", "name": "MessagesSendMessage", "signature": "class MessagesSendMessage", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=7,
            repair_guidance=[
                "修复问题: static-blacklist-failed",
                "物理错误定位: [static-extends-regression] line 5, col 29, match='extends'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("`module + [BINARY_PROTO]` 协议模块", user_prompt)
        self.assertIn("只能使用 `<:`", user_prompt)
        self.assertIn("绝不允许回潮成 `extends`", user_prompt)
        self.assertIn("严禁引入 `import std.unsafe.*`", user_prompt)
        self.assertIn("InputPeer", user_prompt)
        self.assertIn("禁止发明 `Vector`", user_prompt)
        self.assertIn("禁止发明 `StringToUtf8`", user_prompt)
        self.assertIn("超出 `Int32` 范围", user_prompt)
        self.assertIn("不要写 `readonly`", user_prompt)
        self.assertIn("不要写 `.append()` / `.push()`", user_prompt)
        self.assertIn("统一按 `Int64` 处理", user_prompt)
        self.assertIn("`Int32(x)` / `Int64(x)` / `UInt8(x)`", user_prompt)
        self.assertIn("`-212046591`", user_prompt)
        self.assertIn("不要用 `as` 做数值转换", user_prompt)
        self.assertIn("ArkTS `number` 若承载 `writeInt32/readInt32`", user_prompt)
        self.assertIn("允许使用最小占位实现", user_prompt)

    def test_translator_prompt_adds_tl_contract_module_guardrails(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::TLDialogs.ets",
                "target": {
                    "path": "src/core/mtproto/TLDialogs.ets",
                    "role": "module",
                    "risk_tags": ["module"],
                    "signatures": [
                        {"kind": "interface", "name": "TLUser", "signature": "interface TLUser", "summary": "interface"},
                        {"kind": "interface", "name": "TLChannel", "signature": "interface TLChannel", "summary": "interface"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=8,
            repair_guidance=[
                "修复问题: static-blacklist-failed",
                "物理错误定位: [static-tl-protocol-types] line 3, col 18, match='TLUser'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("这是定义 TL 协议契约的 module，不是 Service", user_prompt)
        self.assertIn("绝不能为了迎合 Service 静态墙而改名成 `DomainUser` / `DomainChannel`", user_prompt)
        self.assertIn("必须继续保持 public interface kind", user_prompt)
        self.assertIn("internal/private", user_prompt)
        self.assertNotIn("Service 只允许依赖 `PeerId`", user_prompt)

    def test_translator_prompt_adds_async_flow_module_guardrails(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                        {"kind": "function", "name": "getMTProtoClient", "signature": "function getMTProtoClient(): MTProtoClient", "summary": "function"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoConfig.ets"},
                    {"path": "src/core/mtproto/CryptoUtils.ets"},
                    {"path": "src/core/mtproto/TLMethods.ets"},
                    {"path": "src/core/mtproto/TLSerialization.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=9,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("这是 `[ASYNC_FLOW]` 模块", user_prompt)
        self.assertIn("ArkTS `Promise<T>` 返回在仓颉中必须映射为 `Future<T>`", user_prompt)
        self.assertIn("Cangjie SDK 6.1.0.818", user_prompt)
        self.assertIn("全局绝对禁止输出字面量 `async` 或 `await`", user_prompt)
        self.assertIn("`Promise<void>` 必须映射为 `Future<Unit>`", user_prompt)
        self.assertIn("文件顶部必须显式 `import std.sync.*`", user_prompt)
        self.assertIn("绝对不要导入 `std.concurrent.*`", user_prompt)
        self.assertIn("任何 `import std.concurrent.*` 都应视为 compile regression", user_prompt)
        self.assertIn("禁止 `await`", user_prompt)
        self.assertIn("异步执行块使用 `spawn { ... }`", user_prompt)
        self.assertIn("使用 `.get()`", user_prompt)
        self.assertIn("绝不允许把返回值塌成 `Unit`", user_prompt)
        self.assertIn("staged compile", user_prompt)
        self.assertIn("`core.mtproto`", user_prompt)
        self.assertIn("不要写 `import core.mtproto.*`", user_prompt)
        self.assertIn("对这些依赖只能同包直用", user_prompt)
        self.assertIn("TransportManager", user_prompt)
        self.assertIn("AuthKeyCreator", user_prompt)
        self.assertIn("不要在当前文件再次声明同名 `class` / `interface` / `func`", user_prompt)
        self.assertIn("`initialize(forceNewAuthKey = false)`", user_prompt)
        self.assertIn("`sendRequest(data)`", user_prompt)
        self.assertIn("singleton 心智", user_prompt)
        self.assertIn("`MTProtoConfig`、`CryptoUtils`、`TLMethods`、`TLSerialization`、`TLDialogs`", user_prompt)
        self.assertIn("禁止使用 `clientSingleton!`", user_prompt)
        self.assertIn("必须用 `match` 或 `if let` 做安全解包", user_prompt)

    def test_translator_prompt_prunes_service_era_keywords_for_mtprotoclient(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                        {"kind": "function", "name": "getMTProtoClient", "signature": "function getMTProtoClient(): MTProtoClient", "summary": "function"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=9,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("repair_thought_process 只用 1-3 句极简说明", user_prompt)
        for banned in (
            "Adapter / ACL / Domain Mapper",
            "Service 层",
            "Service 模板",
            "详细写出两段思考",
            "0UL",
            "unsafe",
        ):
            self.assertNotIn(banned, user_prompt)

    def test_translator_prompt_minifies_target_source_before_injection(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "source": (
                        "/** doc */\n"
                        "export class MTProtoClient {\n"
                        "  // single line\n"
                        "  value: number // trailing\n"
                        "\n"
                        "\n"
                        "  /* block comment */\n"
                        "  method(): void {}\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping"],
            attempt=11,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[Target Source]", user_prompt)
        self.assertIn("export class MTProtoClient {", user_prompt)
        self.assertIn("value: number", user_prompt)
        self.assertIn("method(): void {}", user_prompt)
        self.assertNotIn("single line", user_prompt)
        self.assertNotIn("block comment", user_prompt)
        self.assertNotIn("/** doc */", user_prompt)
        self.assertNotIn("\n\n\n", user_prompt)

    def test_translator_prompt_adds_async_flow_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=10,
            repair_guidance=[
                "ARCH_SOURCE_ALIGNMENT_VIOLATION: Promise<void> candidate changed to Unit",
                "error: expected ',' or ')', found '='",
                "error: expected declaration, found 'extension'",
                "error: expected '=>' in lambda expression, found keyword 'let'",
                "error: variable in top-level scope must be initialized",
                "static-postfix-non-null-assertion: clientSingleton!",
                "error: can not find package 'std.concurrent'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("ArkTS `Promise<T>` 合同不能塌成同步 `Unit`", user_prompt)
        self.assertIn("`Promise<void>` -> `Future<Unit>`", user_prompt)
        self.assertIn("文件顶部补 `import std.sync.*`", user_prompt)
        self.assertIn("[ESCAPE HATCH FOR std.concurrent]", user_prompt)
        self.assertIn("物理删除所有 `import std.concurrent.*`", user_prompt)
        self.assertIn("用 `spawn { ... }` 替代 `new Promise(...)`", user_prompt)
        self.assertIn("使用 `.get()`", user_prompt)
        self.assertIn("严禁继续输出 `Promise<...>`、`Promise(...)`、`await`", user_prompt)
        self.assertIn("不要继续输出 `forceNewAuthKey: Bool = false`", user_prompt)
        self.assertIn("默认参数必须改写为同名重载展开", user_prompt)
        self.assertIn("`initialize()` 调 `initialize(false)`", user_prompt)
        self.assertIn("所有重载都必须继承源侧访问修饰符", user_prompt)
        self.assertIn("不要再把 `onConnected/onData/onError` 这类方法塞进顶层 extension", user_prompt)
        self.assertIn("lambda 只接受单表达式", user_prompt)
        self.assertIn("不要继续写顶层可变单例变量", user_prompt)
        self.assertIn("禁止在 `clientSingleton`", user_prompt)
        self.assertIn("优先 `match (clientSingleton)`", user_prompt)
        self.assertIn("每次都 new 一个实例", user_prompt)

    def test_translator_prompt_adds_service_phase04_shape_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                        {"kind": "constructor", "name": "constructor", "signature": "constructor()", "summary": "constructor"},
                        {"kind": "function", "name": "fetchMessages", "signature": "fetchMessages(params): Promise<Message[]>", "summary": "fn"},
                        {"kind": "function", "name": "sendMessage", "signature": "sendMessage(params): Promise<Message>", "summary": "fn"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint", "Execution Topology"],
            attempt=11,
            repair_guidance=[
                "修复问题: ARCH_CONTRACT_RUPTURE",
                "审查问题: 构造函数签名改变：源侧是无参构造函数 constructor()，候选添加了 IMTProtoAdapter 参数。",
                "修复问题: ARCH_DEPENDENCY_CONSTRAINT_VIOLATION",
                "审查问题: 在单一服务文件中定义了 PeerId, DomainMessage, DomainUser, DomainChannel, SendMessageParams, GetHistoryParams, MessageSignal, IMTProtoAdapter, IMessageService。",
                "修复问题: compile-failed",
                "编译器/测试stderr: error: expected '=>' in lambda expression, found keyword 'this'",
                "编译器/测试stderr: error: expected '=>' in lambda expression, found keyword 'let'",
                "编译器/测试stderr: error: expected '=>' in lambda expression, found '}'",
                "物理错误定位: case None => {}",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SERVICE PUBLIC INIT CONTRACT]", user_prompt)
        self.assertIn("源侧 public contract 是零参 `constructor()`", user_prompt)
        self.assertIn("恢复零参 `public init()`", user_prompt)
        self.assertIn("不要继续把 `IMTProtoAdapter`", user_prompt)
        self.assertIn("[SERVICE FILE-SCOPE BLOAT]", user_prompt)
        self.assertIn("不要在 `RealMessageService` 目标文件里重新声明整套 support/domain/runtime 类型", user_prompt)
        self.assertIn("`PeerId`、`DomainMessage`、`DomainUser`、`DomainChannel`", user_prompt)
        self.assertIn("public 输出收敛到 `RealMessageService` 本体", user_prompt)
        self.assertIn("[SERVICE ZERO-BLOCK COMPILE SHAPE]", user_prompt)
        self.assertIn("`match` 分支只返回 helper 调用、现成值或单表达式 `()`", user_prompt)
        self.assertIn("[SERVICE FUTURE LAMBDA COMPILE GUIDANCE]", user_prompt)
        self.assertIn("当前 Service 物理链路优先接受 `spawn { ... }` 作为内部并发形态", user_prompt)
        self.assertIn("不要继续写 JS/Promise 风格的 `Future<T>({ resolver => ... })`", user_prompt)
        self.assertIn("只有当源侧 public method 本身就是 `Promise<T>` / async 合同时", user_prompt)
        self.assertIn("若源侧 public method 不是 async，就把 `spawn` / waiter / collaborator 调度封装到 `private/internal` helper", user_prompt)

    def test_translator_prompt_adds_service_arraylist_shadow_runtime_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint"],
            attempt=12,
            repair_guidance=[
                "修复问题: ARCH_SYNTAX_REGRESSION",
                "审查问题: ArrayList observer runtime appeared inside MessageSignal.",
                "物理错误定位: private let observers: ArrayList<(Array<Message>) -> Unit> = ArrayList<(Array<Message>) -> Unit>()",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SERVICE ARRAYLIST ROOT-CAUSE]", user_prompt)
        self.assertIn("shadow signal/runtime", user_prompt)
        self.assertIn("不要把它机械替换成 `Vector` 或 `Array`", user_prompt)
        self.assertIn("[ESCAPE HATCH FOR service shadow signal runtime]", user_prompt)
        self.assertIn("删除内联 `MessageSignal` / observer list / subscription runtime", user_prompt)

    def test_translator_prompt_adds_service_reactive_and_gateway_eradication_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint", "Execution Topology"],
            attempt=13,
            repair_guidance=[
                "修复问题: static-blacklist-failed",
                "物理错误定位: [static-shadow-signal-flow] line 17, col 49, match='Signal', snippet=private let messageSignals: HashMap<String, Signal<Array<Message>>> = HashMap<String, Signal<Array<Message>>>()",
                "物理错误定位: [static-shadow-gateway-bridge] line 146, col 41, match='Gateway', snippet=throw MessageSendException(\"Gateway not configured\")",
                "编译器/测试stderr: let result = await this.gateway.fetchMessages(peerId, limit, this.userAccessHashes, this.channelAccessHashes)",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SERVICE REACTIVE CONTRACT ERADICATION]", user_prompt)
        self.assertIn("`Signal` / `ValueSignal` / `SignalPipe` / `Store` / `Observable` 只能留在 source-/oracle-aligned public signature", user_prompt)
        self.assertIn("不要写 `let signal: Signal<T>`", user_prompt)
        self.assertIn("[ESCAPE HATCH FOR service reactive state]", user_prompt)
        self.assertIn("删除 `messageSignals` 这类 reactive cache/registry", user_prompt)
        self.assertIn("请保留 source-aligned public method shape", user_prompt)
        self.assertIn("把 reactive object 的 ownership externalize 到本文件之外", user_prompt)
        self.assertIn("只有匹配的 public method 可以提到 `Signal` / `ValueSignal`", user_prompt)
        self.assertIn("`private/internal` helper 必须改成 non-reactive return shape", user_prompt)
        self.assertIn("`Signal` / `ValueSignal` / `SignalPipe` / `Store` / `Observable` 只能留在 source-/oracle-aligned public signature", user_prompt)
        self.assertIn("`Signal<T>()`、`return Signal<T>()`、`ValueSignal<T>(...)`、`SignalPipe<T>(...)`", user_prompt)
        self.assertIn("删除 `ValueSignal(...)` / `SignalPipe(...)` / custom publish-subscribe 逻辑与 `throw TODO` 之类 placeholder return", user_prompt)
        self.assertIn("source imports、TU dependency closure、explicit staged contract allowlist 中已知真实符号获取或转发 reactive object", user_prompt)
        self.assertIn("不要发明新的 provider/facade/shell/locator 壳", user_prompt)
        self.assertNotIn("把 service API 改写成 `Array<T>` / `Future<Array<T>>`", user_prompt)
        self.assertIn("[SERVICE GATEWAY SHELL DETECTED]", user_prompt)
        self.assertIn("例如 `IGateway`、`IMessageGateway`、`GatewayImpl`", user_prompt)
        self.assertIn("[ESCAPE HATCH FOR service gateway shell]", user_prompt)
        self.assertIn("删除当前文件中的 gateway/bridge 接口、实现类、factory、占位异常与 DI setter", user_prompt)
        self.assertIn("改成中性命名的 `private/internal` 引用，例如 `backend` / `messagePort`", user_prompt)
        self.assertIn("清空所有包含 `Gateway` / `Bridge` 的字段名、helper 名、factory 名、setter 名、注释和字符串字面量", user_prompt)

    def test_translator_prompt_adds_realmessageservice_first_round_hash_cache_guardrails(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                        {"kind": "function", "name": "cacheUsers", "signature": "cacheUsers(users: TLUser[]): void", "summary": "fn"},
                        {"kind": "function", "name": "cacheChannels", "signature": "cacheChannels(channels: TLChannel[]): void", "summary": "fn"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint"],
            attempt=14,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("REALMESSAGESERVICE HASH CACHE WRITE LOCK", user_prompt)
        self.assertIn("`this.userAccessHashes[user.id.toString()] = hash`", user_prompt)
        self.assertIn("`this.channelAccessHashes[channel.id.toString()] = hash`", user_prompt)
        self.assertIn("Do NOT emit `.put(...)`", user_prompt)
        self.assertIn("REALMESSAGESERVICE OPTION+HASHMAP SINGLE-EXPRESSION SHAPE", user_prompt)
        self.assertIn("`case Some(hash) => this.userAccessHashes[user.id.toString()] = hash`", user_prompt)
        self.assertIn("`case None => ()`", user_prompt)

    def test_translator_prompt_adds_service_tl_public_contract_scope_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["service", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                        {"kind": "function", "name": "cacheUsers", "signature": "cacheUsers(users: TLUser[]): void", "summary": "fn"},
                        {"kind": "function", "name": "cacheChannels", "signature": "cacheChannels(channels: TLChannel[]): void", "summary": "fn"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint"],
            attempt=14,
            repair_guidance=[
                "修复问题: static-blacklist-failed",
                "物理错误定位: [static-tl-protocol-types] line 10, col 17, match='TLUser', snippet=import protocol.TLUser",
                "物理错误定位: [static-tl-protocol-types] line 11, col 17, match='TLChannel', snippet=import protocol.TLChannel",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[ESCAPE HATCH FOR TL* protocol import]", user_prompt)
        self.assertIn("TL* 名字只允许留在匹配的 public method signatures", user_prompt)
        self.assertIn("不要额外写 `import ...TL*`、`protocol.TL*` 顶层导入", user_prompt)
        self.assertNotIn("Service 只允许依赖 `PeerId`", user_prompt)

    def test_translator_prompt_adds_service_invented_collaborator_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                    "source": (
                        "import { Signal } from '@ohos/signalkit'\n"
                        "import { Message, PeerId } from '@ohos/models'\n"
                        "import { IMessageService, SendMessageParams, GetHistoryParams } from '@ohos/services'\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint", "Execution Topology"],
            attempt=15,
            repair_guidance=[
                "修复问题: compile-failed",
                "编译器/测试stderr: error: undeclared type name 'MessageBackend'",
                "编译器/测试stderr: error: undeclared identifier 'ServiceLocator'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SERVICE INVENTED COLLABORATOR DETECTED]", user_prompt)
        self.assertIn("source imports、TU dependency closure、explicit staged contract allowlist", user_prompt)
        self.assertIn("MessageBackend", user_prompt)
        self.assertIn("ServiceLocator", user_prompt)
        self.assertIn("MTProtoClient", user_prompt)
        self.assertIn("IMessageService", user_prompt)

    def test_translator_prompt_adds_service_protocol_name_and_public_oracle_drift_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint", "Execution Topology"],
            attempt=16,
            repair_guidance=[
                "物理错误定位: MessagesGetHistory",
                "物理错误定位: MessagesSendMessage",
                "物理错误定位: getMTProtoClient()",
                "public signature drift against explicit staged contract bundle",
                "candidate: getMessages(peerId: PeerId, limit: Int64): Signal<Array<Message>>",
                "oracle: getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SERVICE PROTOCOL NAME LEAK DETECTED]", user_prompt)
        self.assertIn("`MessagesGetHistory`、`MessagesSendMessage`、`getMTProtoClient()`", user_prompt)
        self.assertIn("[SERVICE PUBLIC CONTRACT ORACLE DRIFT DETECTED]", user_prompt)
        self.assertIn("public compile-contract oracle", user_prompt)
        self.assertIn("getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>", user_prompt)
        self.assertIn("不能漂成 `Int64`", user_prompt)
        self.assertIn("不能在当前文件里落成 `ValueSignal(...)`", user_prompt)

    def test_translator_prompt_adds_service_return_shape_compile_closure_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint", "Execution Topology"],
            attempt=17,
            repair_guidance=[
                "修复问题: compile-failed",
                "error: mismatched types",
                "expected 'Interface-Signal<Struct-Array<Class-Message>>', found 'Unit'",
                "expected '() -> Class-Message', found '() -> Unit'",
                "error: 'put' is not a member of class 'HashMap<Struct-String, Int64>'",
                "error: 'fetchMessages' is not a member of class 'MessageTimeline'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SERVICE RETURN-SHAPE COMPILE CLOSURE FAILURE]", user_prompt)
        self.assertIn("comment-only body、空函数体、只有注释的 `spawn { ... }`", user_prompt)
        self.assertIn("`MessageTimeline`", user_prompt)
        self.assertIn("private let timeline: MessageTimeline = MessageTimeline()", user_prompt)
        self.assertIn("`getMessages(peerId, limit)` 直接 `return this.timeline.getMessages(peerId, limit)`", user_prompt)
        self.assertIn("`this.timeline.fetchMessages(params)`", user_prompt)
        self.assertIn("`this.timeline.sendMessage(params)`", user_prompt)
        self.assertIn("[SERVICE HASHMAP WRITE API REGRESSION]", user_prompt)
        self.assertIn("`this.userAccessHashes[user.id.toString()] = hash`", user_prompt)
        self.assertIn("[SERVICE TIMELINE API GAP DETECTED]", user_prompt)
        self.assertIn("`fetchMessages(params): Future<Array<Message>>`、`sendMessage(params): Future<Message>`", user_prompt)

    def test_translator_prompt_adds_service_option_none_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint", "Execution Topology"],
            attempt=18,
            repair_guidance=[
                "修复问题: compile-failed",
                "error: invalid binary operator '!=' on type 'Enum-Option<Int64>' and 'Enum-AuthKeyState'",
                "if (user.accessHash != None)",
                "if (channel.accessHash == None)",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SERVICE OPTION NONE COMPARISON REGRESSION]", user_prompt)
        self.assertIn("`Option` / `?T` 与 `None` 直接做 `==` / `!=` 比较", user_prompt)
        self.assertIn("改用 `match (user.accessHash)`", user_prompt)
        self.assertIn("`case Some(hash) => this.userAccessHashes[user.id.toString()] = hash`", user_prompt)

    def test_translator_prompt_reinforces_staged_contract_oracle_signature_fidelity_and_protocol_leakage_repairs(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                        {"kind": "constructor", "name": "constructor", "signature": "constructor()", "summary": "constructor"},
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(limit: Int32): Signal<Message[]>", "summary": "fn"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Dependency Constraint", "Execution Topology"],
            attempt=16,
            repair_guidance=[
                "修复问题: ARCH_DEPENDENCY_CONSTRAINT_VIOLATION",
                "审查问题: private collaborator symbol missing from staged contract allowlist",
                "修复问题: static-blacklist-failed",
                "物理错误定位: [static-input-peer-leak] line 43, col 19, match='InputPeer'",
                "物理错误定位: [static-create-input-peer] line 56, col 17, match='createInputPeer'",
                "物理错误定位: [static-send-request-in-service] line 77, col 13, match='sendRequest('",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("COLLABORATOR SYMBOL ALLOWLIST", user_prompt)
        self.assertIn("EXPLICIT STAGED CONTRACT ALLOWLIST FOR THIS TARGET", user_prompt)
        self.assertIn("source imports, TU dependency closure, or explicit staged contract allowlist", user_prompt)
        self.assertIn("PUBLIC SURFACE LOCK", user_prompt)
        self.assertIn(
            "Keep the same public constructor shape, public method names, parameter counts, parameter intent, and return-shape contract",
            user_prompt,
        )
        self.assertIn("STRICT SIGNATURE PRESERVATION", user_prompt)
        self.assertIn("SYNCHRONOUS/ASYNCHRONOUS FIDELITY", user_prompt)
        self.assertIn("[ESCAPE HATCH FOR InputPeer/createInputPeer]", user_prompt)
        self.assertIn("[ESCAPE HATCH FOR sendRequest]", user_prompt)
        self.assertIn("Service 层只能调用领域级方法", user_prompt)

    def test_translator_prompt_adds_await_identifier_repair_directives_for_mtprotoclient_chunk_c(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets::chunk-c",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                    ],
                },
                "metadata": {
                    "chunk_translation": {
                        "chunk_id": "chunk-c",
                        "label": "Network I/O",
                        "expected_members": ["sendRequest", "initConnection", "onData", "getMTProtoClient"],
                        "missing_members": [],
                    }
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=16,
            repair_guidance=[
                "static-await-keyword-regression: line 82, col 17, match='await', snippet=public func await(): Array<UInt8> {",
                "line 107, col 14, match='await', snippet=waiter.await()",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[AWAIT IDENTIFIER REGRESSION]", user_prompt)
        self.assertIn("`await` 在当前链路里不仅不能作为关键字，也不能作为 helper / method / field / local / callsite 标识符", user_prompt)
        self.assertIn("`public func await()`、`awaitResult()`、`waiter.await()`", user_prompt)
        self.assertIn("`takeResult()`、`drainResult()`、`pollReady()`、`readResult()`", user_prompt)
        self.assertIn("只有真实 `Future<T>` 值才允许 `.get()`", user_prompt)

    def test_translator_prompt_adds_from_import_and_zero_block_repair_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets::chunk-c",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                    ],
                },
                "metadata": {
                    "chunk_translation": {
                        "chunk_id": "chunk-c",
                        "label": "Network I/O",
                        "expected_members": ["sendRequest", "onData", "getMTProtoClient"],
                        "missing_members": [],
                    }
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=15,
            repair_guidance=[
                "error: expected declaration, found 'from'",
                "from './MTProtoConfig' import MTProtoConfig, SessionInfo",
                "error: expected '=>' in lambda expression, found '}'",
                "case None => {}",
                "error: expected '=>' in lambda expression, found keyword 'let'",
                "case None => { let newClient = MTProtoClient() }",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("`from './X' import ...`", user_prompt)
        self.assertIn("同包 staged 依赖优先直接引用", user_prompt)
        self.assertIn("`case None => {}` / `case None => { let ... }`", user_prompt)
        self.assertIn("`match` 分支只允许返回 helper 调用或单值", user_prompt)
        self.assertIn("空分支唯一合法写法是 `case None => ()`", user_prompt)
        self.assertIn("`case None => buildSingleton()`", user_prompt)

    def test_translator_prompt_detoxes_mtprotoclient_chunk_c_service_era_directives(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets::chunk-c",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "source": (
                        "async sendRequest(data: Uint8Array): Promise<Uint8Array> {}\n"
                        "private async initConnection(): Promise<void> {}\n"
                        "onData(data: Uint8Array): void {}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                        {"kind": "function", "name": "getMTProtoClient", "signature": "function getMTProtoClient(): MTProtoClient", "summary": "function"},
                    ],
                },
                "metadata": {
                    "chunk_translation": {
                        "chunk_id": "chunk-c",
                        "label": "Network I/O",
                        "expected_members": ["sendRequest", "initConnection", "onConnected", "onDisconnected", "onData", "onError", "getMTProtoClient"],
                        "missing_members": [],
                    }
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoConfig.ets"},
                    {"path": "src/core/mtproto/TLMethods.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=12,
            repair_guidance=[
                "[CHUNK TRANSLATION MODE] 当前只翻译 chunk-c (Network I/O)，禁止重写整个 MTProtoClient 文件。",
                "[CHUNK EXPECTED MEMBERS] sendRequest, initConnection, onConnected, onDisconnected, onData, onError, getMTProtoClient",
                "[READ-ONLY TRANSLATED STUB FROM PREVIOUS CHUNKS]",
                "public class MTProtoClient <: TransportCallback {\n"
                "    private var connectionInitialized: Bool = false\n"
                "    public init() {}\n"
                "    public func initialize(): Future<Unit> {}\n"
                "    private func createAuthKey(): Future<Unit> {}\n"
                "}",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[READ-ONLY TRANSLATED STUB FROM PREVIOUS CHUNKS]", user_prompt)
        self.assertIn("public class MTProtoClient <: TransportCallback", user_prompt)
        self.assertIn("`Future<T>`", user_prompt)
        self.assertIn("`spawn { ... }`", user_prompt)
        self.assertIn("`bigint` 映射为 `Int64`", user_prompt)
        self.assertIn("后缀 `!` 强制解包", user_prompt)
        self.assertIn("不要输出任何 `from './Foo' import ...`", user_prompt)
        self.assertIn("`match` 分支必须保持单表达式", user_prompt)
        self.assertIn("空分支唯一合法写法是 `case None => ()`", user_prompt)
        self.assertIn("`case None => buildSingleton()`", user_prompt)
        self.assertIn("禁止重新声明 `transportManager`、`session`、`pendingRPCs`、`updateCallback`、`connectionInitialized`", user_prompt)
        self.assertIn("不要为了补清单或迎合旧 directive 发明 `onClose()`", user_prompt)
        self.assertIn("不能注册 no-op `RPCCallback` 后立刻返回 `[]`", user_prompt)
        self.assertIn("不要猜 `Channel`、`BlockingQueue`、`Condition`、自造 `Promise` API", user_prompt)
        self.assertIn("优先使用最小 `private/internal` waiter/helper", user_prompt)
        self.assertIn("helper / method / field / local / callsite 标识符", user_prompt)
        self.assertIn("`public func await()`、`awaitResult()`、`waiter.await()`", user_prompt)
        self.assertIn("`takeResult()`、`drainResult()`、`pollReady()`", user_prompt)
        for banned in (
            "[ESCAPE HATCH FOR sendRequest]",
            "Service 层只能调用领域级方法",
            "Service 层绝不允许",
            "Domain Mapper",
            "Adapter interface",
            "Adapter 私有实现",
            "loadHistory(...)",
            "fetchMessages(...)",
            "sendMessage(...)",
            "这里曾是重灾区",
        ):
            self.assertNotIn(banned, user_prompt)

    def test_translator_prompt_scopes_mtprotoclient_chunk_a_away_from_singleton_tail(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets::chunk-a",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "source": (
                        "class RPCCallback {}\n"
                        "export class MTProtoClient implements TransportCallback {\n"
                        "  private transportManager: TransportManager\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "RPCCallback", "signature": "class RPCCallback", "summary": "class"},
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                        {"kind": "function", "name": "getMTProtoClient", "signature": "function getMTProtoClient(): MTProtoClient", "summary": "function"},
                        {"kind": "constructor", "name": "constructor", "signature": "constructor()", "summary": "constructor"},
                    ],
                },
                "metadata": {
                    "chunk_translation": {
                        "chunk_id": "chunk-a",
                        "label": "State Skeleton",
                        "expected_members": [],
                        "missing_members": [],
                    }
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoConfig.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=13,
            repair_guidance=[
                "[CHUNK TRANSLATION MODE] 当前只翻译 chunk-a (State Skeleton)，禁止重写整个 MTProtoClient 文件。",
                "Chunk A 只输出文件前导、helper/type 声明、类头和字段骨架；不要提前生成 constructor / initialize / 认证握手 / 网络 I/O。",
                "禁止在 Chunk A 提前生成 `clientSingleton` 或 `getMTProtoClient()`；这些尾部单例成员只允许留到 Chunk C 处理。",
            ],
        )

        system_prompt = next(message.content for message in package.messages if message.role == "system")
        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("structural skeleton or trivial setter/getter bridge", system_prompt)
        self.assertIn("禁止在 Chunk A 提前生成 `clientSingleton` 或 `getMTProtoClient()`", user_prompt)
        self.assertIn("当前 chunk 只输出 imports、helper/type 声明、类头和字段骨架", user_prompt)
        self.assertIn("仅翻译 MTProtoClient 的 state skeleton", user_prompt)
        self.assertIn("不要输出任何 `from './Foo' import ...`", user_prompt)
        self.assertNotIn("`getMTProtoClient()` 必须保留 singleton 心智", user_prompt)
        self.assertNotIn("禁止使用 `clientSingleton!`", user_prompt)
        self.assertNotIn("AuthKeyCreator", user_prompt)
        self.assertNotIn("TLMethods", user_prompt)
        self.assertNotIn("`spawn { ... }`", user_prompt)
        self.assertNotIn("同文件 public symbols（这些名字若出现在候选中，属于源文件合法 public surface，不得误判为越界发明）: RPCCallback, MTProtoClient, getMTProtoClient", user_prompt)

    def test_translator_prompt_hardens_mtprotoclient_chunk_b_against_dependency_stub_bloat(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets::chunk-b",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "source": (
                        "private async createAuthKey(): Promise<void> {\n"
                        "  const transport = this.transportManager.getTransport()\n"
                        "  const creator = new AuthKeyCreator(transport)\n"
                        "  const result = await creator.createAuthKey()\n"
                        "  this.session.authKey = result.authKey\n"
                        "  this.session.authKeyId = result.authKeyId\n"
                        "  this.session.serverSalt = result.serverSalt\n"
                        "  this.session.authKeyState = AuthKeyState.Created\n"
                        "  SessionManager.saveSession(this.session)\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                    ],
                },
                "metadata": {
                    "chunk_translation": {
                        "chunk_id": "chunk-b",
                        "label": "Auth Handshake",
                        "expected_members": ["createAuthKey", "req_pq_multi", "req_DH_params", "set_client_DH_params"],
                        "missing_members": ["req_pq_multi", "req_DH_params", "set_client_DH_params"],
                    }
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Execution Topology", "Dependency Constraint"],
            attempt=17,
            repair_guidance=[
                "[CHUNK TRANSLATION MODE] 当前只翻译 chunk-b (Auth Handshake)，禁止重写整个 MTProtoClient 文件。",
                "[CHUNK EXPECTED MEMBERS] createAuthKey, req_pq_multi, req_DH_params, set_client_DH_params",
                "[CHUNK SOURCE MISSING MEMBERS] req_pq_multi, req_DH_params, set_client_DH_params",
                "[READ-ONLY TRANSLATED STUB FROM PREVIOUS CHUNKS]",
                "public class MTProtoClient <: TransportCallback {\n"
                "    public func initialize(): Future<Unit> {}\n"
                "}",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("Chunk B 只允许输出单个成员片段 `private func createAuthKey(): Future<Unit>`", user_prompt)
        self.assertIn("禁止在 Chunk B 生成任何依赖 stub / seam / placeholder", user_prompt)
        self.assertIn("不要输出 `AuthKeyCreator`、`AuthKeyResult`、`AuthKeyState`、`SessionManager`、`TCPTransport`、`TransportManager`", user_prompt)
        self.assertIn("若依赖类型尚未 staged compile，就直接引用现有名字并让 verifier / cjc 给出真实物理诊断", user_prompt)
        self.assertIn("对 `req_pq_multi`、`req_DH_params`、`set_client_DH_params`", user_prompt)
        self.assertIn("绝对不要为了补清单去发明空方法或握手 stub", user_prompt)

    def test_translator_prompt_aggressively_trims_mtprotoclient_chunk_a_context(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets::chunk-a",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "source": (
                        "import { MTProtoConfig, SessionInfo, SessionManager, AuthKeyState } from './MTProtoConfig'\n"
                        "import { TransportCallback, TransportManager } from './MTProtoTransport'\n"
                        "class RPCCallback {\n"
                        "  resolve: (result: Uint8Array) => void\n"
                        "  reject: (error: Error) => void\n"
                        "  timeoutId: number\n"
                        "  constructor(resolve: (result: Uint8Array) => void, reject: (error: Error) => void, timeoutId: number) {\n"
                        "    this.resolve = resolve\n"
                        "    this.reject = reject\n"
                        "    this.timeoutId = timeoutId\n"
                        "  }\n"
                        "}\n"
                        "export class MTProtoClient implements TransportCallback {\n"
                        "  private transportManager: TransportManager\n"
                        "  private session: SessionInfo\n"
                        "  private pendingRPCs: Map<string, RPCCallback> = new Map()\n"
                        "  private updateCallback: ((update: Uint8Array) => void) | null = null\n"
                        "  private connectionInitialized: boolean = false\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "RPCCallback", "signature": "class RPCCallback", "summary": "class"},
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                    ],
                },
                "metadata": {
                    "chunk_translation": {
                        "chunk_id": "chunk-a",
                        "label": "State Skeleton",
                        "expected_members": [],
                        "missing_members": [],
                    }
                },
                "dependency_closure": [
                    {
                        "path": "src/core/mtproto/MTProtoConfig.ets",
                        "role": "module",
                        "depth": 1,
                        "summary": "符号=SessionInfo, MTProtoConfig, SessionManager, AuthKeyState",
                        "signatures": [
                            {"kind": "interface", "name": "SessionInfo", "signature": "interface SessionInfo", "summary": "interface"},
                            {"kind": "class", "name": "MTProtoConfig", "signature": "class MTProtoConfig", "summary": "class"},
                            {"kind": "class", "name": "SessionManager", "signature": "class SessionManager", "summary": "class"},
                            {"kind": "enum", "name": "AuthKeyState", "signature": "enum AuthKeyState", "summary": "enum"},
                        ],
                    },
                    {
                        "path": "src/core/mtproto/MTProtoTransport.ets",
                        "role": "module",
                        "depth": 1,
                        "summary": "符号=TransportCallback, TCPTransport, TransportManager",
                        "signatures": [
                            {"kind": "interface", "name": "TransportCallback", "signature": "interface TransportCallback", "summary": "interface"},
                            {"kind": "class", "name": "TCPTransport", "signature": "class TCPTransport", "summary": "class"},
                            {"kind": "class", "name": "TransportManager", "signature": "class TransportManager", "summary": "class"},
                        ],
                    },
                ],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=16,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("class RPCCallback {", user_prompt)
        self.assertIn("constructor(resolve: (result: Uint8Array) => void, reject: (error: Error) => void, timeoutId: number)", user_prompt)
        self.assertIn("private pendingRPCs: Map<string, RPCCallback>", user_prompt)
        self.assertIn("private updateCallback: ((update: Uint8Array) => void) | null", user_prompt)
        self.assertIn("declare interface SessionInfo;", user_prompt)
        self.assertIn("declare interface TransportCallback;", user_prompt)
        self.assertIn("declare class TransportManager;", user_prompt)
        self.assertNotIn("from './MTProtoConfig'", user_prompt)
        self.assertNotIn("SessionManager", user_prompt)
        self.assertNotIn("AuthKeyState", user_prompt)
        self.assertNotIn("TCPTransport", user_prompt)
        self.assertNotIn("new Map()", user_prompt)
        self.assertNotIn("= null", user_prompt)
        self.assertNotIn("= false", user_prompt)

    def test_translator_prompt_minimizes_mtprotoclient_chunk_a_callback_context(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets::chunk-a-callback",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "summary": "MTProto client module with callback and async setup",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "source": "setUpdateCallback(callback: (update: Uint8Array) => void): void { this.updateCallback = callback }",
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                        {"kind": "function", "name": "setUpdateCallback", "signature": "setUpdateCallback(callback: (update: Uint8Array) => void): void", "summary": "method"},
                    ],
                },
                "metadata": {
                    "chunk_translation": {
                        "chunk_id": "chunk-a-callback",
                        "label": "Callback Hook",
                        "expected_members": ["setUpdateCallback"],
                        "missing_members": [],
                    }
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/AuthKeyCreator.ets"},
                    {"path": "src/core/mtproto/TLMethods.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=14,
            repair_guidance=[
                "[CHUNK TRANSLATION MODE] 当前只翻译 chunk-a-callback (Callback Hook)，禁止重写整个 MTProtoClient 文件。",
                "Chunk A-Callback 只输出 setUpdateCallback 成员本体；不要提前生成 constructor / initialize / 认证握手 / 网络 I/O。",
            ],
        )

        system_prompt = next(message.content for message in package.messages if message.role == "system")
        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("structural skeleton or trivial setter/getter bridge", system_prompt)
        self.assertIn("当前 chunk 是同步 callback setter", user_prompt)
        self.assertIn("方法体直接完成 `this.updateCallback = callback` 即可", user_prompt)
        self.assertIn("当前 chunk 无需额外依赖闭包。", user_prompt)
        self.assertNotIn("`spawn { ... }`", user_prompt)
        self.assertNotIn("`Future<T>`", user_prompt)
        self.assertNotIn("AuthKeyCreator", user_prompt)
        self.assertNotIn("TLMethods", user_prompt)
        self.assertNotIn("`bigint` 映射为 `Int64`", user_prompt)

    def test_translator_prompt_hardens_mtprotoclient_chunk_a_ctor_against_ternary_regression(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets::chunk-a-ctor",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "source": (
                        "constructor() {\n"
                        "  this.transportManager = new TransportManager()\n"
                        "  this.session = SessionManager.getSession(MTProtoConfig.USE_TEST_DC ? 2 : 1)\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                        {"kind": "constructor", "name": "constructor", "signature": "constructor()", "summary": "constructor"},
                    ],
                },
                "metadata": {
                    "chunk_translation": {
                        "chunk_id": "chunk-a-ctor",
                        "label": "Constructor Setup",
                        "expected_members": ["constructor"],
                        "missing_members": [],
                    }
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoConfig.ets"},
                ],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
            attempt=17,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("当前 chunk 只处理 constructor 本体", user_prompt)
        self.assertIn("ArkTS 条件表达式 `cond ? a : b` 不是仓颉合法语法", user_prompt)
        self.assertIn("`SessionManager.getSession(dcId)`", user_prompt)
        self.assertIn("绝对不要保留 `? :`", user_prompt)

    def test_translator_prompt_adds_phase06_ui_lane_guardrails_for_component_targets(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::telegram::src::pages::PhotoViewComponent.ets",
                "target": {
                    "path": "src/components/PhotoViewComponent.ets",
                    "role": "component",
                    "summary": "pinch zoom photo view component",
                    "source": (
                        "@Component\n"
                        "struct PhotoViewComponent {\n"
                        "  build() {\n"
                        "    // pinch gesture surface\n"
                        "  }\n"
                        "}\n"
                    ),
                    "risk_tags": ["component"],
                    "state_tags": [],
                    "thread_tags": ["main-thread-ui"],
                    "interop_tags": [],
                    "signatures": [
                        {"kind": "component", "name": "PhotoViewComponent", "signature": "component PhotoViewComponent", "summary": "component"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Execution Topology"],
            attempt=1,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[CRITICAL UI TRANSLATION DIRECTIVES]", user_prompt)
        self.assertIn("Phase 06 UI lane is active for this target", user_prompt)
        self.assertIn("`phase06-ui-sample-manifest`", user_prompt)
        self.assertIn("[Tag Resolution]", user_prompt)
        self.assertIn("structure_tag=rich-component", user_prompt)
        self.assertIn("ownership_tag=view-model-renderer", user_prompt)
        self.assertIn("interaction_tags=[gesture-component]", user_prompt)
        self.assertIn("exception_tags=[]", user_prompt)
        self.assertIn("[Source Alignment Lock]", user_prompt)
        self.assertIn("`@Entry`, `@Component`, `build()`", user_prompt)
        self.assertIn("[Source-Era Vocabulary Normalization]", user_prompt)
        self.assertIn("Do NOT apply vocabulary cleanup mechanically", user_prompt)
        self.assertIn("No source-backed `ohos.*` import is visible for this target", user_prompt)
        self.assertIn("`ArrayList<T>` is not source-backed in this target", user_prompt)
        self.assertIn("defaulting to `Array<T>` / `[]`", user_prompt)
        self.assertIn("Do NOT compensate by inventing `Vector<T>`", user_prompt)
        self.assertIn("[Ownership Lock]", user_prompt)
        self.assertIn("[Execution Lock]", user_prompt)
        self.assertIn("gesture thresholds, cancellation semantics, callback order", user_prompt)
        self.assertIn("[Boundary Lock]", user_prompt)
        self.assertIn("No exception tags are active for this target", user_prompt)
        self.assertIn("[Hard Ban List]", user_prompt)
        self.assertIn("Do NOT hallucinate fake pages, components, builders, providers, or runtime facades", user_prompt)
        self.assertIn("[Phase 06 UI Few-Shot]", user_prompt)
        self.assertIn("id=rich-component-view-model-renderer", user_prompt)
        self.assertIn("rich-component targets are reusable view blocks", user_prompt)
        self.assertIn("They must not assume page / router / ability ownership", user_prompt)
        self.assertIn("`view-model-renderer` means the UI consumes external snapshot / render model / intents", user_prompt)
        self.assertEqual(package.metadata["phase06_ui_examples_count"], 1)
        self.assertNotIn("当前无额外 target-specific 指令。", user_prompt)

    def test_phase06_ui_dynamic_repair_directives_normalize_ohos_and_arraylist_without_vector_fallback(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::pages::FoodCategoryListPage.cj",
                "target": {
                    "path": "pages/FoodCategoryListPage.cj",
                    "role": "page",
                    "summary": "phase06 ui page",
                    "source": (
                        "@Entry\n"
                        "@Component\n"
                        "class FoodCategoryListPage {\n"
                        "  build() {}\n"
                        "}\n"
                    ),
                    "risk_tags": ["page", "routing"],
                    "thread_tags": ["main-thread-ui"],
                    "signatures": [
                        {"kind": "page", "name": "FoodCategoryListPage", "signature": "page FoodCategoryListPage", "summary": "page"},
                    ],
                    "ui_prompt_tags": {
                        "structure_tag": "page-shell",
                        "ownership_tag": "view-model-renderer",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Execution Topology"],
            attempt=1,
            repair_guidance=[
                "修复问题: static-blacklist-failed",
                "物理错误定位: [static-import-ohos-package] line 4, col 1, match='import ohos.arkui.state_macro_manage'",
                "物理错误定位: [static-arraylist-hallucination] line 25, col 26, match='ArrayList'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[UI IMPORT NORMALIZATION]", user_prompt)
        self.assertIn("保留 `@Entry` / `@Component` / `build()` / builder / layout tree", user_prompt)
        self.assertIn("宁可保持零 import", user_prompt)
        self.assertIn("[UI ARRAYLIST NORMALIZATION]", user_prompt)
        self.assertIn("把所有 UI-local `ArrayList<T>`", user_prompt)
        self.assertIn("统一收敛到 `Array<T>` / `[]`", user_prompt)
        self.assertNotIn("优先改用合法集合 `Vector<T>()`", user_prompt)

    def test_phase06_ui_source_backed_import_and_arraylist_contracts_are_preserved(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::pages::FoodCategoryListPage.cj",
                "target": {
                    "path": "pages/FoodCategoryListPage.cj",
                    "role": "page",
                    "summary": "phase06 ui page",
                    "source": (
                        "package ohos_app_cangjie_entry\n"
                        "\n"
                        "import kit.ArkUI.*\n"
                        "import ohos.arkui.state_macro_manage.*\n"
                        "import std.collection.*\n"
                        "\n"
                        "@Entry\n"
                        "@Component\n"
                        "class FoodCategoryListPage {\n"
                        "    func visibleFoods(): ArrayList<FoodData> {\n"
                        "        return []\n"
                        "    }\n"
                        "\n"
                        "    func buildGridRow(rowItems: ArrayList<FoodData>): Unit {\n"
                        "    }\n"
                        "}\n"
                    ),
                    "risk_tags": ["page", "routing"],
                    "thread_tags": ["main-thread-ui"],
                    "signatures": [
                        {"kind": "page", "name": "FoodCategoryListPage", "signature": "page FoodCategoryListPage", "summary": "page"},
                    ],
                    "ui_prompt_tags": {
                        "structure_tag": "page-shell",
                        "ownership_tag": "view-model-renderer",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Execution Topology"],
            attempt=1,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("Source-backed UI macro import(s) are visible in this file", user_prompt)
        self.assertIn("ohos.arkui.state_macro_manage.*", user_prompt)
        self.assertIn("Preserve those exact import paths", user_prompt)
        self.assertIn("`ArrayList<T>` is source-backed in this UI target", user_prompt)
        self.assertIn("Do NOT collapse a source-backed `ArrayList<T>` contract", user_prompt)

    def test_phase06_ui_native_cangjie_targets_use_snapshot_truth_path_and_fidelity_lock(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::components::markdown_heading_component.cj",
                "snapshot": {
                    "root_path": "/repo/raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src",
                },
                "target": {
                    "path": "components/markdown_heading_component.cj",
                    "role": "component",
                    "summary": "phase06 ui component",
                    "source": (
                        "package markdown.components\n"
                        "\n"
                        "internal import ohos.base.*\n"
                        "internal import ohos.component.*\n"
                        "import ohos.state_manage.*\n"
                        "import ohos.state_macro_manage.*\n"
                        "\n"
                        "@Component\n"
                        "class MarkdownHeadingComponent {\n"
                        "    @State var level: Int64 = 1\n"
                        "    func build() {\n"
                        "        Column() {}\n"
                        "    }\n"
                        "    public func refreshData(refreshNodeViews: ArrayList<NodeView>, level: Int64): Unit {\n"
                        "        this.level = level\n"
                        "    }\n"
                        "}\n"
                    ),
                    "risk_tags": ["component", "state-decorator"],
                    "thread_tags": ["main-thread-ui"],
                    "signatures": [
                        {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "component"},
                        {"kind": "function", "name": "refreshData", "signature": "refreshData(refreshNodeViews: ArrayList<NodeView>, level: Int64): Unit", "summary": "method"},
                    ],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
            attempt=1,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("源侧真理路径: /repo/raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src/components/markdown_heading_component.cj", user_prompt)
        self.assertIn("[Native Cangjie Fidelity Lock]", user_prompt)
        self.assertIn("already authored in Cangjie (`.cj`)", user_prompt)
        self.assertIn("Default to emitting the whole `target.source` file as a verbatim baseline.", user_prompt)
        self.assertIn("copy the exact method body line-for-line", user_prompt)
        self.assertIn("Do NOT normalize sibling branches, reorder conditionals, rewrite comments, or restyle indentation/braces outside the exact local blocker named in repair guidance.", user_prompt)
        self.assertIn("Source-backed UI macro import(s) are visible in this file: [ohos.base.*, ohos.component.*, ohos.state_macro_manage.*, ohos.state_manage.*].", user_prompt)
        self.assertIn("Source-backed method/body names already present in this file include [build, refreshData].", user_prompt)

    def test_phase06_ui_native_cangjie_generic_helper_heads_are_surface_backed_in_prompt(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::viewmodel::chart_data_service.cj",
                "snapshot": {
                    "root_path": "/repo/raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie",
                },
                "target": {
                    "path": "services/ChartDataService.cj",
                    "role": "viewmodel",
                    "summary": "source-backed stock chart service helper",
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
                        "    public func loadTimeLineData(): ArrayList<TimeLineDataPoint> {\n"
                        "        return loadAndParseData(\"MockTimeLineData.json\", \"timeLineData\") { itemVal =>\n"
                        "            None\n"
                        "        }\n"
                        "    }\n"
                        "    public func loadKLineData(): ArrayList<KLinePointWrapper> {\n"
                        "        return ArrayList<KLinePointWrapper>()\n"
                        "    }\n"
                        "}\n"
                    ),
                    "risk_tags": ["service"],
                    "thread_tags": [],
                    "signatures": [
                        {"kind": "class", "name": "ChartDataServices", "signature": "class ChartDataServices", "summary": "class"},
                        {"kind": "function", "name": "loadTimeLineData", "signature": "loadTimeLineData(): ArrayList<TimeLineDataPoint>", "summary": "method"},
                        {"kind": "function", "name": "loadKLineData", "signature": "loadKLineData(): ArrayList<KLinePointWrapper>", "summary": "method"},
                    ],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "view-model-renderer",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
            attempt=1,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn(
            "完整 source 还原样声明了这些 target-file class-local member/helper method head: private func loadAndParseData<T>(filename: String, jsonKey: String, parser: (JsonValue) -> Option<T>): ArrayList<T>",
            user_prompt,
        )
        self.assertIn("Source-backed method/body names already present in this file include [loadAndParseData, loadTimeLineData, loadKLineData].", user_prompt)

    def test_phase06_ui_translator_prompt_treats_from_ohos_imports_as_source_backed(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::components::editor_kit::editorText.cj",
                "target": {
                    "path": "editor_kit/editorText.cj",
                    "role": "component",
                    "summary": "source-backed component with from-import macros",
                    "source": (
                        "package editor_kit\n"
                        "from ohos import base.*\n"
                        "from ohos import component.*\n"
                        "from ohos import state_macro_manage.*\n"
                        "from ohos import state_manage.*\n"
                        "@Component\n"
                        "public class EditorKit {\n"
                        "    public func render() {}\n"
                        "}\n"
                    ),
                    "risk_tags": ["component"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "signatures": [
                        {"kind": "class", "name": "EditorKit", "signature": "class EditorKit", "summary": "class"},
                        {"kind": "method", "name": "render", "signature": "render()", "summary": "method"},
                    ],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
            attempt=1,
            repair_guidance=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn(
            "Source-backed UI macro import(s) are visible in this file: [ohos.base.*, ohos.component.*, ohos.state_macro_manage.*, ohos.state_manage.*].",
            user_prompt,
        )
        self.assertNotIn("No source-backed `ohos.*` import is visible for this target", user_prompt)

    def test_phase06_ui_dynamic_repair_keeps_source_backed_class_shape_when_fixing_postfix_non_null(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::components::editor_kit::editorText.cj",
                "target": {
                    "path": "editor_kit/editorText.cj",
                    "role": "component",
                    "summary": "source-backed controller + component target",
                    "source": (
                        "package editor_kit\n"
                        "from ohos import component.*\n"
                        "public class EditorKitController {\n"
                        "    public EditorKitController(\n"
                        "        private var width!: Float64,\n"
                        "        private var height!: Float64,\n"
                        "    ) {}\n"
                        "    func bindEditorKit(editorKit: EditorKit) {}\n"
                        "}\n"
                        "@Component\n"
                        "public class EditorKit {\n"
                        "    public func render() {}\n"
                        "}\n"
                    ),
                    "risk_tags": ["component", "state-decorator"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "signatures": [
                        {"kind": "class", "name": "EditorKitController", "signature": "class EditorKitController", "summary": "class"},
                        {"kind": "class", "name": "EditorKit", "signature": "class EditorKit", "summary": "class"},
                    ],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
            attempt=2,
            repair_guidance=[
                "static-blacklist-failed",
                "static-postfix-non-null-assertion: width!",
                "系统静态扫描发现致命违规词汇 'width!'，请移除后缀 ! 解包恶习。",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SOURCE-BACKED FIELD-HEAD PATCH ONLY]", user_prompt)
        self.assertIn("只允许在原字段声明处做词法级修补", user_prompt)
        self.assertIn("禁止只输出字段区、截断类后半段", user_prompt)

    def test_phase06_ui_dynamic_repair_locks_same_file_helper_invocation_case_when_fixing_postfix_non_null(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::viewmodel::style_extensions.cj",
                "target": {
                    "path": "views/StyleExtensions.cj",
                    "role": "viewmodel",
                    "summary": "source-backed style helper repair",
                    "source": (
                        "package ohos_app_cangjie_entry.views\n"
                        "import ohos.base.*\n"
                        "import ohos.component.*\n"
                        "public extension CanvasRenderingContext2D {\n"
                        "    func drawLine(x1: Float64, y1: Float64, x2: Float64, y2: Float64, dash!: Array<Float64> = [0.0, 0.0], width!: Float64 = 1.0) {\n"
                        "    }\n"
                        "    func drawGrid(dims: ChartDimensions, rows: Int64, cols: Int64) {\n"
                        "        this.drawLine(0.0, 0.0, 1.0, 1.0)\n"
                        "    }\n"
                        "}\n"
                    ),
                    "risk_tags": ["service"],
                    "thread_tags": [],
                    "signatures": [
                        {"kind": "extension", "name": "CanvasRenderingContext2D", "signature": "extension CanvasRenderingContext2D", "summary": "extension"},
                    ],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "view-model-renderer",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
            attempt=2,
            repair_guidance=[
                "static-blacklist-failed",
                "static-postfix-non-null-assertion: dash!",
                "审查问题: Method name case mismatch in `drawGrid`. The candidate calls `this.DrawLine`, but the method defined in the same extension is `drawLine`.",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[SOURCE-BACKED SAME-FILE HELPER CASE LOCK]", user_prompt)
        self.assertIn("不要把 `drawLine` 改写成 `DrawLine`", user_prompt)

    def test_phase06_ui_dynamic_repair_preserves_source_backed_import_and_arraylist_contracts(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::pages::FoodCategoryListPage.cj",
                "target": {
                    "path": "pages/FoodCategoryListPage.cj",
                    "role": "page",
                    "summary": "phase06 ui page",
                    "source": (
                        "package ohos_app_cangjie_entry\n"
                        "import kit.ArkUI.*\n"
                        "import ohos.arkui.state_macro_manage.*\n"
                        "import std.collection.*\n"
                        "\n"
                        "@Entry\n"
                        "@Component\n"
                        "class FoodCategoryListPage {\n"
                        "    func visibleFoods(): ArrayList<FoodData> {\n"
                        "        return []\n"
                        "    }\n"
                        "}\n"
                    ),
                    "risk_tags": ["page", "routing"],
                    "thread_tags": ["main-thread-ui"],
                    "signatures": [
                        {"kind": "page", "name": "FoodCategoryListPage", "signature": "page FoodCategoryListPage", "summary": "page"},
                    ],
                    "ui_prompt_tags": {
                        "structure_tag": "page-shell",
                        "ownership_tag": "view-model-renderer",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Execution Topology"],
            attempt=1,
            repair_guidance=[
                "修复问题: static-blacklist-failed",
                "物理错误定位: [static-import-ohos-package] line 3, col 1, match='import ohos.fake.runtime'",
                "物理错误定位: [static-arraylist-hallucination] line 12, col 27, match='ArrayList'",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[NATIVE CANGJIE WHOLE-FILE BASELINE]", user_prompt)
        self.assertIn("默认先把 `target.source` 整文件原样作为候选基线", user_prompt)
        self.assertIn("只允许在该局部附近做最小修补", user_prompt)
        self.assertIn("[UI IMPORT CONTRACT FIDELITY]", user_prompt)
        self.assertIn("source-aligned 文件已经显式导入 [ohos.arkui.state_macro_manage.*]", user_prompt)
        self.assertIn("保留 source 文件里已经存在的 exact `ohos.*` import", user_prompt)
        self.assertIn("[UI ARRAYLIST CONTRACT FIDELITY]", user_prompt)
        self.assertIn("source-aligned 文件已经真实使用 `ArrayList<T>`", user_prompt)
        self.assertIn("只删除当前候选里 source 文件不存在的 invented `ArrayList` 用法", user_prompt)

    def test_phase06_ui_dynamic_repair_blocks_native_viewmodel_listener_state_and_delegation_drift(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        source = (
            "package photoView\n"
            "import ohos.base.*\n"
            "import ohos.component.*\n"
            "import ohos.state_macro_manage.*\n"
            "import ohos.state_manage.*\n"
            "@Observed\n"
            "public class PhotoViewModel {\n"
            "    @Publish\n"
            "    var strSrc: String = \"\"\n"
            "    @Publish\n"
            "    var sWidth: Float64 = 0.0\n"
            "    @Publish\n"
            "    public var scale: Float64 = 1.0\n"
            "    public func setOnLongClickListener(listener: OnLongPressListener): PhotoViewModel {\n"
            "        return this\n"
            "    }\n"
            "    public func setOnPhotoTapListener(listener: OnPhotoTapListener): PhotoViewModel {\n"
            "        return this\n"
            "    }\n"
            "    public func setOnMatrixChangeListener(listener: OnMatrixChangedListener): PhotoViewModel {\n"
            "        return this\n"
            "    }\n"
            "}\n"
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::photoview4cj::photo_view_model.cj",
                "target": {
                    "path": "photo_view_model.cj",
                    "role": "viewmodel",
                    "summary": "角色=viewmodel; 风险=state-decorator, model; 文件=photo_view_model.cj",
                    "source": source,
                    "risk_tags": ["model", "state-decorator"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": ["gesture-component"],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "PhotoViewModel", "signature": "class PhotoViewModel", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
            attempt=2,
            repair_guidance=[
                "Public method parameter types changed from source-backed interfaces to function types, violating BCM-ALIGN-001.",
                "Source excerpt explicitly declares '@Publish var strSrc: String', '@Publish var sWidth: Float64', '@Publish var scale: Float64'. Candidate replaces these with invented fields '@Publish private var imageUri: String', '@Publish private var viewWidth: Float64', '@Publish private var attacher: PhotoViewAttacher'.",
                "Unauthorized implementation refactoring from self-contained state management to a delegation pattern via invented 'PhotoViewAttacher'.",
            ],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[PHASE06 SOURCE-BACKED VIEWMODEL ANTI-DRIFT]", user_prompt)
        self.assertIn("保留这些 source-backed `@Publish` state field head 的名字/装饰器/所有权", user_prompt)
        self.assertIn("var strSrc: String = \"\"", user_prompt)
        self.assertIn("var sWidth: Float64 = 0.0", user_prompt)
        self.assertIn("public var scale: Float64 = 1.0", user_prompt)
        self.assertIn("保留这些 source-backed listener/callback public method head 的参数 contract", user_prompt)
        self.assertIn("public func setOnPhotoTapListener(listener: OnPhotoTapListener): PhotoViewModel", user_prompt)
        self.assertIn("Do NOT rewrite them into bare function types", user_prompt)
        self.assertIn("不要改成 `attacher` / delegate / facade / helper-owned state 模式", user_prompt)

    def test_phase06_ui_few_shot_prefers_local_control_for_same_page_shell_match(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )

        examples = assembler._prepare_phase06_ui_few_shot_examples(
            {
                "tu_id": "tu::telegram::src::pages::ListPage.ets",
                "target": {
                    "path": "src/pages/ListPage.ets",
                    "role": "page",
                    "source": "@Entry\n@Component\nstruct ListPage { build() {} }\n",
                    "ui_prompt_tags": {
                        "structure_tag": "page-shell",
                        "ownership_tag": "view-model-renderer",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "page", "name": "ListPage", "signature": "page ListPage", "summary": "page"},
                    ],
                },
                "dependency_closure": [],
            }
        )

        self.assertEqual(
            [item["entry_id"] for item in examples],
            [
                "control-page-shell-view-model-renderer",
                "external-page-shell-view-model-renderer",
            ],
        )

    def test_phase06_ui_few_shot_requires_exact_match_and_excludes_gesture_or_exception_pollution(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )

        examples = assembler._prepare_phase06_ui_few_shot_examples(
            {
                "tu_id": "tu::telegram::src::pages::SettingsPage.ets",
                "target": {
                    "path": "src/pages/SettingsPage.ets",
                    "role": "page",
                    "source": "@Entry\n@Component\nstruct SettingsPage { build() {} }\n",
                    "ui_prompt_tags": {
                        "structure_tag": "page-shell",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "page", "name": "SettingsPage", "signature": "page SettingsPage", "summary": "page"},
                    ],
                },
                "dependency_closure": [],
            }
        )

        self.assertEqual([item["entry_id"] for item in examples], ["control-page-shell-controller-owned-state"])
        self.assertNotIn("gesture-rich-component-controller-owned-state", [item["entry_id"] for item in examples])
        self.assertNotIn("exception-only-ffi-rich-component", [item["entry_id"] for item in examples])

    def test_default_phase06_ui_few_shot_pack_is_present_and_loadable(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
        )

        pack = assembler._load_phase06_ui_few_shot_pack()

        self.assertTrue(prompt_assembler.DEFAULT_PHASE06_UI_FEW_SHOT_PACK_PATH.exists())
        self.assertEqual(pack.get("pack_name"), "phase06-ui-few-shot-pack")
        self.assertGreaterEqual(len(pack.get("entries", [])), 9)
        self.assertIn(
            "local-ui-routing-page-shell-view-model-renderer",
            [item.get("entry_id") for item in pack.get("entries", []) if isinstance(item, dict)],
        )

    def test_phase06_ui_effective_signatures_drop_builder_parser_noise_without_source_func_heads(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        tu = {
            "tu_id": "tu::phase06::components::markdown_heading_component.cj",
            "target": {
                "path": "components/markdown_heading_component.cj",
                "role": "component",
                "source": (
                    "package markdown.components\n"
                    "@Component\n"
                    "class MarkdownHeadingComponent {\n"
                    "    func build() { Column() { Text() } }\n"
                    "    public func refreshData(refreshNodeViews: ArrayList<NodeView>, level: Int64): Unit {\n"
                    "    }\n"
                    "}\n"
                ),
                "ui_prompt_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
                "signatures": [
                    {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "class"},
                    {"kind": "method", "name": "Column", "signature": "Column()", "summary": "method"},
                    {"kind": "method", "name": "Text", "signature": "Text()", "summary": "method"},
                ],
            },
            "dependency_closure": [],
        }

        signatures = assembler._get_effective_target_signatures(tu)

        self.assertEqual(
            [item["name"] for item in signatures],
            ["MarkdownHeadingComponent"],
        )

    def test_phase06_ui_effective_signatures_drop_nondeclared_match_and_builder_noise(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        tu = {
            "tu_id": "tu::phase06::components::editor_kit::editorText.cj",
            "target": {
                "path": "editor_kit/editorText.cj",
                "role": "component",
                "source": (
                    "package editor_kit\n"
                    "public class EditorKitController {\n"
                    "    public EditorKitController(width: Float64, height: Float64) {}\n"
                    "    func bindEditorKit(editorKit: EditorKit) {}\n"
                    "}\n"
                    "@Component\n"
                    "public class EditorKit {\n"
                    "    public func render() {}\n"
                    "}\n"
                ),
                "ui_prompt_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
                "signatures": [
                    {"kind": "class", "name": "EditorKitController", "signature": "class EditorKitController", "summary": "class"},
                    {"kind": "class", "name": "EditorKit", "signature": "class EditorKit", "summary": "class"},
                    {"kind": "method", "name": "EditorKitController", "signature": "public EditorKitController(width: Float64, height: Float64)", "summary": "constructor"},
                    {"kind": "method", "name": "match", "signature": "match(spansValue[i].spanType)", "summary": "method"},
                    {"kind": "method", "name": "Scroll", "signature": "Scroll(this.scroller)", "summary": "method"},
                ],
            },
            "dependency_closure": [],
        }

        signatures = assembler._get_effective_target_signatures(tu)

        self.assertEqual(
            [(item["kind"], item["name"]) for item in signatures],
            [
                ("class", "EditorKitController"),
                ("class", "EditorKit"),
                ("method", "EditorKitController"),
            ],
        )

    def test_phase06_ui_reviewer_payload_prefers_declared_method_heads_over_builder_parser_noise(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        tu = {
            "tu_id": "tu::phase06::components::markdown_heading_component.cj",
            "target": {
                "path": "components/markdown_heading_component.cj",
                "role": "component",
                "source": (
                    "package markdown.components\n"
                    "@Component\n"
                    "class MarkdownHeadingComponent {\n"
                    "    func build() { Column() { Text() } }\n"
                    "    public func refreshData(refreshNodeViews: ArrayList<NodeView>, level: Int64): Unit {\n"
                    "    }\n"
                    "}\n"
                ),
                "ui_prompt_tags": {
                    "structure_tag": "rich-component",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": [],
                },
                "signatures": [
                    {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "class"},
                    {"kind": "method", "name": "Column", "signature": "Column()", "summary": "method"},
                    {"kind": "method", "name": "Text", "signature": "Text()", "summary": "method"},
                ],
            },
            "dependency_closure": [],
        }

        reviewer_payload = assembler._build_reviewer_tu_payload(tu)
        target_payload = reviewer_payload["target"]

        self.assertEqual(
            target_payload["public_surface_symbols"],
            ["MarkdownHeadingComponent", "refreshData"],
        )
        self.assertEqual(
            [item["name"] for item in target_payload["signatures"]],
            ["MarkdownHeadingComponent"],
        )
        self.assertEqual(
            target_payload["source_backed_public_method_heads"],
            ["public func refreshData(refreshNodeViews: ArrayList<NodeView>, level: Int64): Unit"],
        )

    def test_phase06_ui_reviewer_payload_does_not_promote_package_local_helper_types_to_public_surface(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        tu = {
            "tu_id": "tu::phase06::view::CustomTabBarPage.cj",
            "target": {
                "path": "view/CustomTabBarPage.cj",
                "role": "page",
                "source": (
                    "package customtabbar.view\n"
                    "@Builder\n"
                    "public func buildCustonTab() {\n"
                    "    CustomTabBarPage()\n"
                    "}\n"
                    "@Entry\n"
                    "@Component\n"
                    "public class CustomTabBarPage {\n"
                    "    func build() { Column() { CustomTabBar() } }\n"
                    "}\n"
                    "@Component\n"
                    "class CustomTabBar {\n"
                    "    func build() { TabItem() }\n"
                    "}\n"
                    "@Component\n"
                    "class TabItem {\n"
                    "    func build() { Text() }\n"
                    "}\n"
                ),
                "ui_prompt_tags": {
                    "structure_tag": "page-shell",
                    "ownership_tag": "controller-owned-state",
                    "interaction_tags": [],
                    "exception_tags": [],
                    "sample_scope_tags": ["mixed-app-pattern"],
                },
                "signatures": [
                    {"kind": "class", "name": "CustomTabBarPage", "signature": "class CustomTabBarPage", "summary": "class"},
                    {"kind": "class", "name": "CustomTabBar", "signature": "class CustomTabBar", "summary": "class"},
                    {"kind": "class", "name": "TabItem", "signature": "class TabItem", "summary": "class"},
                ],
            },
            "dependency_closure": [],
        }

        reviewer_payload = assembler._build_reviewer_tu_payload(tu)
        target_payload = reviewer_payload["target"]

        self.assertEqual(
            target_payload["public_surface_symbols"],
            ["CustomTabBarPage", "buildCustonTab"],
        )

    def test_reviewer_prompt_includes_source_surface_context(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoConfig.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoConfig.ets",
                    "role": "module",
                    "summary": "module summary",
                    "source": "export interface SessionInfo {}\nexport class SessionManager {}",
                    "signatures": [
                        {"kind": "interface", "name": "SessionInfo", "signature": "interface SessionInfo", "summary": "interface"},
                        {"kind": "class", "name": "SessionManager", "signature": "class SessionManager", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "public class SessionManager {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[Source Alignment 铁律]", user_prompt)
        self.assertIn("SessionInfo", user_prompt)
        self.assertIn("SessionManager", user_prompt)
        self.assertIn("public_surface_symbols", user_prompt)
        self.assertIn("getter/setter", user_prompt)

    def test_reviewer_prompt_minifies_source_excerpt(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoConfig.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoConfig.ets",
                    "role": "module",
                    "summary": "module summary",
                    "source": (
                        "/** doc */\n"
                        "export interface SessionInfo {\n"
                        "  // comment\n"
                        "  dcId: number // trailing\n"
                        "\n"
                        "  /* block */\n"
                        "  getAuthKey(): string\n"
                        "}\n"
                    ),
                    "signatures": [
                        {"kind": "interface", "name": "SessionInfo", "signature": "interface SessionInfo", "summary": "interface"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "public interface SessionInfo {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("dcId: number", user_prompt)
        self.assertIn("getAuthKey(): string", user_prompt)
        self.assertNotIn("/** doc */", user_prompt)
        self.assertNotIn("// comment", user_prompt)
        self.assertNotIn("block */", user_prompt)

    def test_reviewer_prompt_compacts_translator_output_and_drops_duplicate_raw_payload_noise(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoConfig.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoConfig.ets",
                    "role": "module",
                    "summary": "module summary",
                    "source": "export class MTProtoConfig {}",
                    "signatures": [
                        {"kind": "class", "name": "MTProtoConfig", "signature": "class MTProtoConfig", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={
                "repair_thought_process": "Preserve source-aligned structure.",
                "generated_code": "public class MTProtoConfig {}",
                "declared_constraints": ["Translation Mapping"],
                "notes": ["note-1", "note-2"],
                "raw_text": "{\"repair_thought_process\":\"dup\",\"code\":\"dup\"}",
                "workspace_dir": "/tmp/workspace",
                "attempt_dir": "/tmp/workspace/attempt-01",
                "candidate_file_path": "/tmp/workspace/attempt-01/MTProtoConfig.cj",
                "candidate_bytes_written": 1234,
            },
            required_dimensions=["Translation Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("[Translator 输出]", user_prompt)
        self.assertIn("Preserve source-aligned structure.", user_prompt)
        self.assertIn("public class MTProtoConfig {}", user_prompt)
        self.assertIn("\"declared_constraints\": [", user_prompt)
        self.assertNotIn("\"raw_text\"", user_prompt)
        self.assertNotIn("/tmp/workspace", user_prompt)
        self.assertNotIn("candidate_bytes_written", user_prompt)

    def test_reviewer_prompt_adds_binary_proto_guardrails(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::TLSerialization.ets",
                "target": {
                    "path": "src/core/mtproto/TLSerialization.ets",
                    "role": "module",
                    "risk_tags": ["[BINARY_PROTO]", "module"],
                    "signatures": [
                        {"kind": "class", "name": "TLSerializer", "signature": "class TLSerializer", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "public class TLSerializer {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("`Uint8Array -> Array<UInt8>`", user_prompt)
        self.assertIn("compile-safe 保守实现", user_prompt)
        self.assertIn("不要仅因 O(N^2) 性能推测把候选 blocker 掉", user_prompt)
        self.assertIn("`-212046591`", user_prompt)
        self.assertIn("不得凭空臆造新的 overflow blocker", user_prompt)
        self.assertIn("ArkTS `number -> Int32`、`bigint -> Int64`", user_prompt)
        self.assertIn("最多给 major note", user_prompt)

    def test_reviewer_prompt_adds_tl_contract_module_guardrails(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::TLDialogs.ets",
                "target": {
                    "path": "src/core/mtproto/TLDialogs.ets",
                    "role": "module",
                    "risk_tags": ["module"],
                    "signatures": [
                        {"kind": "interface", "name": "TLUser", "signature": "interface TLUser", "summary": "interface"},
                        {"kind": "interface", "name": "TLChannel", "signature": "interface TLChannel", "summary": "interface"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "public interface TLUser {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("这是定义 TL 协议契约的 module，不是 Service", user_prompt)
        self.assertIn("不得仅凭 `TL*` 前缀判定 `ARCH_DOMAIN_PURITY_VIOLATION`", user_prompt)
        self.assertIn("DomainUser", user_prompt)

    def test_reviewer_prompt_adds_async_flow_module_guardrails(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::telegram::src::core::mtproto::MTProtoClient.ets",
                "target": {
                    "path": "src/core/mtproto/MTProtoClient.ets",
                    "role": "module",
                    "risk_tags": ["[ASYNC_FLOW]", "[BINARY_PROTO]", "async-flow"],
                    "signatures": [
                        {"kind": "class", "name": "MTProtoClient", "signature": "class MTProtoClient", "summary": "class"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoConfig.ets"},
                    {"path": "src/core/mtproto/TLMethods.ets"},
                ],
            },
            artifact_payload={
                "repair_thought_process": "test",
                "code": "package core.mtproto",
                "declared_constraints": [],
                "notes": [],
            },
            required_dimensions=["Translation Mapping", "Execution Topology"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("这是 `[ASYNC_FLOW]` module", user_prompt)
        self.assertIn("删除字面量 `async` / `await`", user_prompt)
        self.assertIn("Cangjie SDK 6.1.0.818", user_prompt)
        self.assertIn("出现任何字面量 `async` / `await` 都属于硬回退", user_prompt)
        self.assertIn("等价映射为仓颉 `Future<T>`", user_prompt)
        self.assertIn("不能仅因候选去掉了字面量 `async` / `await` 而判 blocker", user_prompt)
        self.assertIn("缺失 `import std.sync.*`", user_prompt)
        self.assertIn("错翻成 `Unit`", user_prompt)
        self.assertIn("internal/private` 的最小 stub", user_prompt)
        self.assertIn("再次声明同名 `class` / `interface` / `func`", user_prompt)
        self.assertIn("`initialize(forceNewAuthKey = false)`", user_prompt)
        self.assertIn("同名重载展开默认值", user_prompt)
        self.assertIn("`Future<Unit>` 返回心智", user_prompt)
        self.assertIn("`Future<Array<UInt8>>`", user_prompt)
        self.assertIn("`sendRequest`", user_prompt)
        self.assertIn("singleton 心智", user_prompt)
        self.assertIn("后缀 `!`", user_prompt)
        self.assertIn("`match` / `if let` + 惰性初始化", user_prompt)

    def test_reviewer_prompt_adds_service_phase04_override_guardrails(self) -> None:
        assembler = prompt_assembler.PromptAssembler(schema_text="# Translation Mapping\n- test")
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::telegram::src::services::RealMessageService.ets",
                "target": {
                    "path": "src/services/RealMessageService.ets",
                    "role": "service",
                    "risk_tags": ["[ASYNC_FLOW]", "service", "async-flow", "signal-or-store"],
                    "signatures": [
                        {"kind": "class", "name": "RealMessageService", "signature": "class RealMessageService", "summary": "class"},
                        {"kind": "function", "name": "cacheUsers", "signature": "cacheUsers(users: TLUser[]): void", "summary": "fn"},
                        {"kind": "function", "name": "cacheChannels", "signature": "cacheChannels(channels: TLChannel[]): void", "summary": "fn"},
                        {"kind": "function", "name": "getMessages", "signature": "getMessages(peerId, limit): Signal<Message[]>", "summary": "fn"},
                        {"kind": "function", "name": "fetchMessages", "signature": "fetchMessages(params): Promise<Message[]>", "summary": "fn"},
                        {"kind": "function", "name": "sendMessage", "signature": "sendMessage(params): Promise<Message>", "summary": "fn"},
                    ],
                },
                "dependency_closure": [
                    {"path": "src/core/mtproto/MTProtoClient.ets"},
                    {"path": "src/core/mtproto/TLMethods.ets"},
                    {"path": "src/core/mtproto/TLSerialization.ets"},
                ],
            },
            artifact_payload={
                "repair_thought_process": "test",
                "code": "public class RealMessageService {}",
                "declared_constraints": ["Architecture Mapping", "State Contract", "Execution Topology"],
                "notes": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract", "Execution Topology"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("Phase 04 service translation", user_prompt)
        self.assertIn("domain purity / protocol isolation", user_prompt)
        self.assertIn("高于 Phase 03 source alignment", user_prompt)
        self.assertIn("`TLUser` / `TLChannel` / `TL*` 改写为 `DomainUser` / `DomainChannel`", user_prompt)
        self.assertIn("不得仅因 public signature 改动就判 `ARCH_SOURCE_ALIGNMENT_VIOLATION`", user_prompt)
        self.assertIn("删除 `createInputPeer` / `InputPeer` / `sendRequest` / `toBytes()` / `TLDeserializer`", user_prompt)
        self.assertIn("`Promise<T>` 等价映射为仓颉 `Future<T>`", user_prompt)
        self.assertIn("`spawn` 维持异步心智", user_prompt)
        self.assertIn("anchor-defined signal implementation", user_prompt)
        self.assertIn("无 source 依据地新增 public helper / observer methods", user_prompt)
        self.assertIn("public constructor 参数", user_prompt)
        self.assertIn("把核心接口替换成无关契约", user_prompt)
        self.assertNotIn("当前无额外 reviewer target-specific 指令。", user_prompt)

    def test_reviewer_prompt_adds_phase06_ui_lane_guardrails_for_page_targets(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::telegram::src::pages::ChatPage.ets",
                "target": {
                    "path": "src/pages/ChatPage.ets",
                    "role": "page",
                    "summary": "chat page with builder layers",
                    "source": (
                        "@Entry\n"
                        "@Component\n"
                        "struct ChatPage {\n"
                        "  build() {}\n"
                        "}\n"
                    ),
                    "risk_tags": ["routing", "page"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": ["main-thread-ui", "callback-entry"],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "page-shell",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": ["hybrid-exception"],
                        "sample_scope_tags": ["mixed-app-pattern"],
                    },
                    "signatures": [
                        {"kind": "page", "name": "ChatPage", "signature": "page ChatPage", "summary": "page"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "public struct ChatPage {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping", "Architecture Mapping", "Execution Topology"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("这是 Phase 06 UI translation reviewer lane", user_prompt)
        self.assertIn("[Tag Resolution]", user_prompt)
        self.assertIn("structure_tag=page-shell", user_prompt)
        self.assertIn("ownership_tag=controller-owned-state", user_prompt)
        self.assertIn("interaction_tags=[]", user_prompt)
        self.assertIn("exception_tags=[hybrid-exception]", user_prompt)
        self.assertIn("sample_scope_tags=[mixed-app-pattern]", user_prompt)
        self.assertIn("target.role=page", user_prompt)
        self.assertIn("[Review Focus]", user_prompt)
        self.assertIn("不得仅因页面拆出 source-aligned 子组件", user_prompt)
        self.assertIn("必须阻断 invented page/component shell", user_prompt)
        self.assertIn("对 `page-shell`，reviewer 应要求页面只承担 page/router/lifecycle/short-lived UI state", user_prompt)
        self.assertIn("对 `controller-owned-state`，必须阻断 shadow local state", user_prompt)
        self.assertIn("对 `hybrid-exception`，reviewer 必须要求 `UI shell / controller / native or runtime` 显式分层", user_prompt)
        self.assertIn("不得要求把 `mixed-app-pattern` 的 app 级复杂度压回单文件", user_prompt)
        self.assertNotIn("当前无额外 reviewer target-specific 指令。", user_prompt)

    def test_reviewer_prompt_uses_source_backed_ui_public_methods_beyond_truncated_signatures(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        source = (
            "package markdown.components\n"
            "import ohos.base.*\n"
            "import ohos.component.*\n"
            "import ohos.state_manage.*\n"
            "import ohos.state_macro_manage.*\n"
            "\n"
            "@Component\n"
            "class MarkdownHeadingComponent {\n"
            "    var markdownConfiguration: MarkdownConfiguration\n"
            "    var nodeViews: ArrayList<NodeView>\n"
            "    var marginTop: Float64\n"
            "    var marginBottom: Float64\n"
            "    var fontCallback: (String) -> Unit\n"
            "    var imageCallback: (String) -> Unit\n"
            "    var isFull: Bool\n"
            "    var headingComponents: ArrayList<MarkdownHeadingComponent>\n"
            "    func build() { Column() { Text() } }\n"
            "    public func refreshData(refreshNodeViews: ArrayList<NodeView>, level: Int64): Unit {\n"
            "    }\n"
            "}\n"
        )
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::phase06::components::markdown_heading_component.cj",
                "target": {
                    "path": "components/markdown_heading_component.cj",
                    "role": "component",
                    "summary": "角色=component; 符号=MarkdownHeadingComponent, Column, Text; 风险=list-or-grid, state-decorator, component; 文件=markdown_heading_component.cj",
                    "source": source,
                    "risk_tags": ["component", "list-or-grid", "state-decorator"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "class"},
                        {"kind": "method", "name": "Column", "signature": "Column()", "summary": "method"},
                        {"kind": "method", "name": "Text", "signature": "Text()", "summary": "method"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "class MarkdownHeadingComponent {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping", "Architecture Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("refreshData", user_prompt)
        self.assertIn("完整 source 还显式声明了这些 public method head", user_prompt)
        self.assertIn("source_backed_public_method_heads", user_prompt)
        self.assertIn('"source_excerpt_is_truncated": false', user_prompt)
        self.assertIn("不得仅凭摘要缺口把它们判成 unauthorized public surface", user_prompt)

    def test_reviewer_prompt_treats_source_backed_ui_uninitialized_fields_as_non_blocking_without_compile_evidence(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        source = (
            "package markdown.components\n"
            "@Component\n"
            "class MarkdownHeadingComponent {\n"
            "    var markdownConfiguration: MarkdownConfiguration\n"
            "    var nodeViews: ArrayList<NodeView>\n"
            "    var marginTop: Float64\n"
            "    var marginBottom: Float64\n"
            "    var fontCallback: (String) -> Unit\n"
            "    var imageCallback: (String) -> Unit\n"
            "    var isFull: Bool\n"
            "}\n"
        )
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::phase06::components::markdown_heading_component.cj",
                "target": {
                    "path": "components/markdown_heading_component.cj",
                    "role": "component",
                    "summary": "角色=component; 符号=MarkdownHeadingComponent; 风险=component, state-decorator; 文件=markdown_heading_component.cj",
                    "source": source,
                    "risk_tags": ["component", "state-decorator"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "class MarkdownHeadingComponent {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping", "Architecture Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("source_backed_uninitialized_field_heads", user_prompt)
        self.assertIn("var markdownConfiguration: MarkdownConfiguration", user_prompt)
        self.assertIn("不得在没有 verify.compile / real cjc 失败证据时", user_prompt)
        self.assertIn("不得仅凭这些字段本身推断 `ARCH_SYNTAX_REGRESSION`", user_prompt)

    def test_reviewer_prompt_treats_source_backed_ui_build_and_invocation_patterns_as_non_blocking(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        source = (
            "package markdown.components\n"
            "@Component\n"
            "class MarkdownHeadingComponent {\n"
            "    func build() { Column() { Text() } }\n"
            "    @Builder\n"
            "    func headingTitleComponent() {\n"
            "        if ((item.node as CommonmarkLink)().getDestination().startsWith(\"http://\")) {\n"
            "            if (getLinkString(item).isSome()) {\n"
            "                headingLinkComponent(item, getLinkString(item)(), markdownConfiguration, level)\n"
            "            }\n"
            "        }\n"
            "    }\n"
            "}\n"
        )
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::phase06::components::markdown_heading_component.cj",
                "target": {
                    "path": "components/markdown_heading_component.cj",
                    "role": "component",
                    "summary": "角色=component; 符号=MarkdownHeadingComponent; 风险=component",
                    "source": source,
                    "risk_tags": ["component"],
                    "state_tags": [],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "class MarkdownHeadingComponent {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping", "Architecture Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("source_backed_build_head", user_prompt)
        self.assertIn("func build()", user_prompt)
        self.assertIn("source_backed_invocation_patterns", user_prompt)
        self.assertIn("(item.node as CommonmarkLink)()", user_prompt)
        self.assertIn("getLinkString(item)()", user_prompt)
        self.assertIn("不得在没有 verify.compile / real cjc 失败证据时，仅凭语言直觉把它们判成 `ARCH_SYNTAX_REGRESSION`", user_prompt)
        self.assertIn("`UNDEFINED_SYMBOL_RUPTURE`", user_prompt)
        self.assertIn("不得要求为这些 source-backed 调用额外补 invented import", user_prompt)


    def test_translator_prompt_clips_large_source_backed_cj_component_to_anchor_section(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        helper_block = "\n".join(f"    private func helper{i}(): Unit {{}}" for i in range(240))
        source = (
            "package editor.kit\n"
            "import ohos.component.*\n"
            "import ohos.state_manage.*\n"
            "\n"
            "public class EditorKitController {\n"
            f"{helper_block}\n"
            "}\n"
            "\n"
            "@Component\n"
            "public class EditorKit {\n"
            "    @State var subHeight: Float64 = 0.0\n"
            "    @State var subWidth: Float64 = 0.0\n"
            "    public func render() {\n"
            "        Scroll() { Text(\"editor\") }\n"
            "    }\n"
            "    func build() {\n"
            "        Column() { this.render() }\n"
            "    }\n"
            "}\n"
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::components::editor_kit::editorText.cj",
                "target": {
                    "path": "editor_kit/editorText.cj",
                    "role": "component",
                    "summary": "large source-backed editor component",
                    "source": source,
                    "risk_tags": ["component", "state-decorator"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "EditorKit", "signature": "class EditorKit", "summary": "class"},
                        {"kind": "method", "name": "render", "signature": "render()", "summary": "method"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
            attempt=1,
            repair_guidance=[],
            pattern_examples=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        target_source_section = user_prompt.split("[Target Source]", 1)[1]
        self.assertIn("source excerpt truncated for large Phase06 UI target", user_prompt)
        self.assertIn("import ohos.component.*", user_prompt)
        self.assertIn("@Component", user_prompt)
        self.assertIn("public class EditorKit", user_prompt)
        self.assertIn("public func render()", user_prompt)
        self.assertNotIn("private func helper0()", target_source_section)
        self.assertNotIn("private func helper239()", target_source_section)

    def test_phase06_ui_large_source_excerpt_keeps_leading_controller_context_for_component_targets(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        controller_noise = "".join(f"    private func helper{i}(): Unit {{}}\n" for i in range(240))
        source = (
            "package editor_kit\n"
            "from ohos import base.*\n"
            "from ohos import component.*\n"
            "from ohos import state_manage.*\n"
            "public class EditorKitController {\n"
            "    public EditorKitController(\n"
            "        private var width!: Float64,\n"
            "        private var height!: Float64,\n"
            "    ) {}\n"
            "    func bindEditorKit(editorKit: EditorKit) {}\n"
            + controller_noise
            + "}\n"
            "@Component\n"
            "public class EditorKit {\n"
            "    public func render() {}\n"
            "}\n"
        )
        package = assembler.build_translator_prompt(
            tu={
                "tu_id": "tu::phase06::components::editor_kit::editorText.cj",
                "target": {
                    "path": "editor_kit/editorText.cj",
                    "role": "component",
                    "summary": "large source-backed controller + component target",
                    "source": source,
                    "risk_tags": ["component", "state-decorator"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "EditorKitController", "signature": "class EditorKitController", "summary": "class"},
                        {"kind": "class", "name": "EditorKit", "signature": "class EditorKit", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
            attempt=1,
            repair_guidance=[],
            pattern_examples=[],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        target_source_section = user_prompt.split("[Target Source]", 1)[1]
        self.assertIn("source excerpt truncated for large Phase06 UI target", user_prompt)
        self.assertIn("from ohos import component.*", target_source_section)
        self.assertIn("public class EditorKitController", target_source_section)
        self.assertIn("public EditorKitController(", target_source_section)
        self.assertIn("func bindEditorKit(editorKit: EditorKit)", target_source_section)
        self.assertIn("@Component", target_source_section)
        self.assertIn("public class EditorKit", target_source_section)
        self.assertNotIn("private func helper239()", target_source_section)

    def test_reviewer_prompt_exposes_simple_sample_source_backed_invocation_patterns(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        source = """package ohos_app_cangjie_entry
import ohos.state_macro_manage.*
import ohos.prompt_action.*
@Entry
@Component
public class SimpleSample {
    @State var data: PhotoViewModel = PhotoViewModel()
    func onAccept(index: Int64): Unit {
        data.setScale(Random().nextFloat64() + 1.0, true)
    }
    func build() {
        Image().onClick({ event => Router.back() })
    }
    public func onPageShow(): Unit {
        sleep(Duration.second / 120)
    }
    public func getData(): PhotoViewModel {
        data
    }
}
@CustomDialog
class CustomDialogExample2 {
    var confirm: (Int64) -> Unit
}
"""
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::phase06::photoview4cj::simple_sample.cj",
                "target": {
                    "path": "simple_sample.cj",
                    "role": "page",
                    "summary": "role=page; risks=gesture-component, dialog; file=simple_sample.cj",
                    "source": source,
                    "risk_tags": ["gesture-component", "dialog"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "page-shell",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": ["gesture-component"],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "SimpleSample", "signature": "class SimpleSample", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": source, "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping", "Architecture Mapping", "State Contract"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("source_backed_invocation_patterns", user_prompt)
        self.assertIn("Random().nextFloat64()", user_prompt)
        self.assertIn("Router.back()", user_prompt)
        self.assertIn("sleep(Duration.second / 120)", user_prompt)
        self.assertIn("`UNDEFINED_SYMBOL_RUPTURE`", user_prompt)
        self.assertIn("invented import", user_prompt)

    def test_reviewer_prompt_treats_source_backed_native_cangjie_method_bodies_as_non_blocking_without_verify_red(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        source = (
            "package photoView\n"
            "import ohos.base.*\n"
            "import ohos.component.*\n"
            "import ohos.image.PixelMap\n"
            "import ohos.matrix4.*\n"
            "import ohos.resource_manager.*\n"
            "import ohos.state_macro_manage.*\n"
            "import ohos.state_manage.*\n"
            "@Observed\n"
            "public class PhotoViewModel {\n"
            "    @Publish var rotateAngle: Float64 = 0.0\n"
            "    @Publish var scale: Float64 = 1.0\n"
            "    @Publish var offsetX: Float64 = 0.0\n"
            "    @Publish var offsetY: Float64 = 0.0\n"
            "    @Publish var centerX: Float64 = 0.0\n"
            "    @Publish var centerY: Float64 = 0.0\n"
            "    @Publish var centerZ: Float64 = 0.0\n"
            "    @Publish var matrix: Matrix4Transit = Matrix4.identity()\n"
            "    public func initMatrix(): Unit {\n"
            "        matrix.rotate(RotateOption(x: 0.0, y: 0.0, z: 1.0, angle: Float32(rotateAngle)))\n"
            "    }\n"
            "    public func setRotationCenter(x: Float64, y: Float64, z: Float64): PhotoViewModel {\n"
            "        centerX = z\n"
            "        centerY = y\n"
            "        centerZ = z\n"
            "        return this\n"
            "    }\n"
            "}\n"
        )
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::phase06::photoview4cj::photo_view_model.cj",
                "target": {
                    "path": "photo_view_model.cj",
                    "role": "viewmodel",
                    "summary": "角色=viewmodel; 风险=state-decorator, model; 文件=photo_view_model.cj",
                    "source": source,
                    "risk_tags": ["model", "state-decorator"],
                    "state_tags": ["state-decorator"],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": ["gesture-component"],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "PhotoViewModel", "signature": "class PhotoViewModel", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": source, "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping", "State Contract"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("source-backed `.cj`", user_prompt)
        self.assertIn("不得仅凭纯语义推断把 source 已存在的方法体判成 `ARCH_STATE_CONTRACT_VIOLATION` / `ARCH_SOURCE_ALIGNMENT_RUPTURE`", user_prompt)
        self.assertIn("只有 candidate 明显偏离 source-backed body，或真实 verify/behavior 证据为红时，才允许打回", user_prompt)

    def test_reviewer_prompt_uses_same_package_source_backed_helper_heads_from_snapshot_root(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            components = root / "components"
            components.mkdir(parents=True, exist_ok=True)
            target_path = components / "markdown_heading_component.cj"
            helper_path = components / "markdown_base_component.cj"
            target_source = (
                "package markdown.components\n"
                "@Component\n"
                "class MarkdownHeadingComponent {\n"
                "    @Builder\n"
                "    func headingTitleComponent() {\n"
                "        headingTextComponent(item, markdownConfiguration, level)\n"
                "        headingFootnoteComponent(item, markdownConfiguration, level, fontCallback)\n"
                "    }\n"
                "}\n"
            )
            helper_source = (
                "package markdown.components\n"
                "func headingTextComponent(nodeView: NodeView, markdownConfiguration: MarkdownConfiguration, level: Int64) {}\n"
                "func headingFootnoteComponent(nodeView: NodeView, markdownConfiguration: MarkdownConfiguration, level: Int64, fontCallback: (String) -> Unit) {}\n"
            )
            target_path.write_text(target_source)
            helper_path.write_text(helper_source)

            assembler = prompt_assembler.PromptAssembler(
                schema_text="# Translation Mapping\n- test",
                phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
                phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
            )
            package = assembler.build_reviewer_prompt(
                tu={
                    "tu_id": "tu::phase06::components::markdown_heading_component.cj",
                    "snapshot": {"root_path": str(root)},
                    "target": {
                        "path": "components/markdown_heading_component.cj",
                        "role": "component",
                        "summary": "角色=component; 符号=MarkdownHeadingComponent; 风险=component",
                        "source": target_source,
                        "risk_tags": ["component"],
                        "state_tags": [],
                        "thread_tags": [],
                        "interop_tags": [],
                        "ui_prompt_tags": {
                            "structure_tag": "rich-component",
                            "ownership_tag": "controller-owned-state",
                            "interaction_tags": [],
                            "exception_tags": [],
                            "sample_scope_tags": [],
                        },
                        "signatures": [
                            {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "class"},
                        ],
                    },
                    "dependency_closure": [],
                },
                artifact_payload={"generated_code": "class MarkdownHeadingComponent {}", "declared_constraints": [], "notes": []},
                required_dimensions=["Translation Mapping", "Dependency Constraint"],
            )

            user_prompt = next(message.content for message in package.messages if message.role == "user")
            self.assertIn("source_backed_package_local_helper_heads", user_prompt)
            self.assertIn("func headingTextComponent(nodeView: NodeView, markdownConfiguration: MarkdownConfiguration, level: Int64)", user_prompt)
            self.assertIn("func headingFootnoteComponent(nodeView: NodeView, markdownConfiguration: MarkdownConfiguration, level: Int64, fontCallback: (String) -> Unit)", user_prompt)
            self.assertIn("不得仅因当前单文件候选未内联定义、也未显式 import", user_prompt)

    def test_reviewer_prompt_uses_same_package_source_backed_type_heads_from_snapshot_root(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            components = root / "components"
            components.mkdir(parents=True, exist_ok=True)
            target_path = components / "markdown_heading_component.cj"
            helper_path = components / "markdown_code_line_image_span_component.cj"
            target_source = (
                "package markdown.components\n"
                "@Component\n"
                "class MarkdownHeadingComponent {\n"
                "    @Builder\n"
                "    func headingTitleComponent() {\n"
                "        MarkdownCodeLineImageSpanComponent(markdownConfiguration: markdownConfiguration, strCode: \"x\", strUrl: \"y\")\n"
                "    }\n"
                "}\n"
            )
            helper_source = (
                "package markdown.components\n"
                "@Component\n"
                "class MarkdownCodeLineImageSpanComponent {\n"
                "}\n"
            )
            target_path.write_text(target_source)
            helper_path.write_text(helper_source)

            assembler = prompt_assembler.PromptAssembler(
                schema_text="# Translation Mapping\n- test",
                phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
                phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
            )
            package = assembler.build_reviewer_prompt(
                tu={
                    "tu_id": "tu::phase06::components::markdown_heading_component.cj",
                    "snapshot": {"root_path": str(root)},
                    "target": {
                        "path": "components/markdown_heading_component.cj",
                        "role": "component",
                        "summary": "角色=component; 符号=MarkdownHeadingComponent; 风险=component",
                        "source": target_source,
                        "risk_tags": ["component"],
                        "state_tags": [],
                        "thread_tags": [],
                        "interop_tags": [],
                        "ui_prompt_tags": {
                            "structure_tag": "rich-component",
                            "ownership_tag": "controller-owned-state",
                            "interaction_tags": [],
                            "exception_tags": [],
                            "sample_scope_tags": [],
                        },
                        "signatures": [
                            {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "class"},
                        ],
                    },
                    "dependency_closure": [],
                },
                artifact_payload={"generated_code": "class MarkdownHeadingComponent {}", "declared_constraints": [], "notes": []},
                required_dimensions=["Translation Mapping", "Dependency Constraint"],
            )

            user_prompt = next(message.content for message in package.messages if message.role == "user")
            self.assertIn("source_backed_package_local_helper_heads", user_prompt)
            self.assertIn("class MarkdownCodeLineImageSpanComponent", user_prompt)
            self.assertIn("不得仅因当前单文件候选未内联定义、也未显式 import", user_prompt)

    def test_reviewer_prompt_treats_source_backed_target_file_member_helpers_as_non_blocking(self) -> None:
        assembler = prompt_assembler.PromptAssembler(
            schema_text="# Translation Mapping\n- test",
            phase06_ui_manifest_payload=PHASE06_UI_MANIFEST_PAYLOAD,
            phase06_ui_few_shot_pack_payload=PHASE06_UI_FEW_SHOT_PACK_PAYLOAD,
        )
        source = (
            "package markdown.components\n"
            "@Component\n"
            "class MarkdownHeadingComponent {\n"
            "    func build() {\n"
            "        headingTitleComponent()\n"
            "    }\n"
            "    @Builder\n"
            "    func headingTitleComponent() { Text() }\n"
            "    func isMarginTop(): Float64 { 0.0 }\n"
            "    func tableLineHeight(): Float64 { 1.0 }\n"
            "    public func refreshData(refreshNodeViews: ArrayList<NodeView>, level: Int64): Unit {}\n"
            "}\n"
        )
        package = assembler.build_reviewer_prompt(
            tu={
                "tu_id": "tu::phase06::components::markdown_heading_component.cj",
                "target": {
                    "path": "components/markdown_heading_component.cj",
                    "role": "component",
                    "summary": "角色=component; 符号=MarkdownHeadingComponent; 风险=component",
                    "source": source,
                    "risk_tags": ["component"],
                    "state_tags": [],
                    "thread_tags": [],
                    "interop_tags": [],
                    "ui_prompt_tags": {
                        "structure_tag": "rich-component",
                        "ownership_tag": "controller-owned-state",
                        "interaction_tags": [],
                        "exception_tags": [],
                        "sample_scope_tags": [],
                    },
                    "signatures": [
                        {"kind": "class", "name": "MarkdownHeadingComponent", "signature": "class MarkdownHeadingComponent", "summary": "class"},
                    ],
                },
                "dependency_closure": [],
            },
            artifact_payload={"generated_code": "class MarkdownHeadingComponent {}", "declared_constraints": [], "notes": []},
            required_dimensions=["Translation Mapping", "Architecture Mapping"],
        )

        user_prompt = next(message.content for message in package.messages if message.role == "user")
        self.assertIn("source_backed_member_method_heads", user_prompt)
        self.assertIn("func headingTitleComponent()", user_prompt)
        self.assertIn("func isMarginTop(): Float64", user_prompt)
        self.assertIn("func tableLineHeight(): Float64", user_prompt)
        self.assertIn("不得仅因它们未列入 `source_backed_public_method_heads` 或 `target.signatures`，就把候选中的同名成员方法判成 unauthorized public surface", user_prompt)


if __name__ == "__main__":
    unittest.main()
