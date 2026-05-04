#!/usr/bin/env python3
"""静态黑名单拦截器。

功能：
1. 在 LLM Reviewer 与真实编译器之前，先对候选代码做确定性的黑名单扫描；
2. 对协议泄漏、伪隔离、语法倒退与 TypeScript 恶习做零容忍拦截；
3. 输出带有行号、列号、命中词与原始代码片段的结构化证据，供 Orchestrator 直接短路回灌 Repair。
"""

from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass, field
from typing import Dict, List, Pattern, Sequence, Tuple

from precompiled_dependency_registry import (
    collect_service_symbol_allowlist,
    resolve_explicit_staged_contract_public_method_oracle_map,
)


@dataclass(frozen=True)
class StaticRule:
    rule_id: str
    issue_code: str
    required_dimension: str
    severity: str
    pattern: Pattern[str]
    description: str
    repair_hint: str


@dataclass
class StaticViolation:
    rule_id: str
    issue_code: str
    required_dimension: str
    severity: str
    message: str
    matched_text: str
    line: int
    column: int
    line_text: str
    repair_hint: str


@dataclass
class StaticCheckResult:
    passed: bool
    violations: List[StaticViolation] = field(default_factory=list)
    scanned_line_count: int = 0
    rule_count: int = 0

    def to_dict(self) -> Dict[str, object]:
        return {
            "passed": self.passed,
            "scanned_line_count": self.scanned_line_count,
            "rule_count": self.rule_count,
            "violations": [asdict(item) for item in self.violations],
        }


DEFAULT_RULES: Tuple[StaticRule, ...] = (
    StaticRule(
        rule_id="static-tl-protocol-types",
        issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\bTL[A-Z]\w*\b"),
        description="Service 层出现 TL 协议对象。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`TLMethods` / `TLDialogs` / `TLSerialization` 这类 TL* 名字属于协议层，不属于 Service。你不能通过改 import 顺序、改别名或包一层 helper 继续保留它们；只要 Service 里还出现 TL*，静态墙就会直接拦截。\n"
            "[ESCAPE HATCH FOR TL* protocol import]\n"
            "物理删除当前 service 文件中的 `import ...TL*`、TL* 构造/序列化、service-local TL 缓存与本地实现。若 TL* 仅作为源侧 public contract 类型出现在 public method signature，请保留该 source-aligned type name 的外部引用，但不要在当前文件里重定义、构造、导入 `ohos.*` 路径或改名成 `DomainUser` / `DomainChannel`。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 TL* 时，严禁顺手把 `InputPeer/createInputPeer`、`sendRequest(...)`、`Signal/ValueSignal`、`ArrayList` 或 `ohos.*` 路径带回 Service 层。"
        ),
    ),
    StaticRule(
        rule_id="static-input-peer-leak",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Dependency Constraint",
        severity="blocker",
        pattern=re.compile(r"\bInputPeer\b"),
        description="Service 层出现 InputPeer 协议边界对象。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`InputPeer` 是协议边界对象，不属于 Service 层。你不能把它换个变量名或包一层 helper 自欺欺人；只要 Service 代码里还出现 `InputPeer`，静态墙就会直接击穿。\n"
            "[ESCAPE HATCH FOR InputPeer/createInputPeer]\n"
            "把 `InputPeer` 与 `createInputPeer(...)` 全部下沉到 Adapter 私有实现。Service 层只允许传递 `PeerId`、基础标量或纯领域对象，并调用领域级 Adapter 方法。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修协议边界时，严禁重新引入 `sendRequest(...)`、`std.unsafe.*`、TL*、SignalPipe，且继续坚守 Zero-Block Rule 与 Helper Extraction。"
        ),
    ),
    StaticRule(
        rule_id="static-create-input-peer",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\bcreateInputPeer\b"),
        description="Service 层出现 createInputPeer 作弊构造器。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`createInputPeer(...)` 是典型的协议构造作弊器。你不能只改方法名或把调用点藏进别的 helper；只要 Service 里还保留这类方法或调用，扫描器就会继续拦截。\n"
            "[ESCAPE HATCH FOR InputPeer/createInputPeer]\n"
            "彻底删除 Service 层的 `createInputPeer(...)` 方法与所有调用点，把协议构造逻辑滚进 Adapter 私有方法；Service 只能调用领域级接口。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修协议边界时，严禁重新引入 `InputPeer`、`sendRequest(...)`、`std.unsafe.*`、TL* 或 SignalPipe，且继续坚守 Zero-Block Rule 与 Helper Extraction。"
        ),
    ),
    StaticRule(
        rule_id="static-protocol-context-cheat",
        issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\bProtocolContext\b"),
        description="Service 层出现 ProtocolContext 伪隔离作弊。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，这属于伪隔离作弊，请彻底将其从 Service 构造函数、字段与方法签名中抹除。",
    ),
    StaticRule(
        rule_id="static-pseudo-adapter-shell",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\bMTProtoAdapter\b|\bTelegramAdapter\b|\bProtocolAdapter\b|\bSignalPipe\b"),
        description="Service 层出现半合法适配器/信号管道壳子，疑似试图用改名隐藏协议污染。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，不要发明 `MTProtoAdapter` / `TelegramAdapter` / `ProtocolAdapter` / `SignalPipe` 这类半合法壳子；若确实需要协作者，只能复用 source imports、TU dependency closure 或 explicit staged contract allowlist 中已经存在的真实符号，并保持 `private/internal`，绝不能改变源侧 public constructor / public method signature。",
    ),
    StaticRule(
        rule_id="static-generic-tl-container-pollution",
        issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\b(?:Map|HashMap|Array|ArrayList|Vector)<[^>]*\bTL[A-Z]\w*\b[^>]*>"),
        description="集合泛型中出现 TL 协议类型污染。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，Service 文件里的字段、缓存、helper 与局部容器不允许持有 `TL*`。若源侧 public signature 需要 `TL*[]` / `Array<TL*>` 等 contract，请保留该 public contract，并把容器 ownership 与处理逻辑下沉到 `private/internal` 协作者，而不是改名成新的 public 领域类型。",
    ),
    StaticRule(
        rule_id="static-parameter-tl-type-pollution",
        issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r":\s*TL[A-Z]\w*"),
        description="入参或字段类型注解中直接出现 TL 协议类型。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，除源侧已经要求的 public method signature 外，当前 service 文件不应在字段声明、局部状态或 helper 签名里直接持有 `TL*`。保留 source-aligned public contract，删除其余 service-local TL 类型占用。",
    ),
    StaticRule(
        rule_id="static-arrow-tl-return-pollution",
        issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"=>\s*TL[A-Z]\w*"),
        description="返回类型或箭头类型签名中直接出现 TL 协议类型。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，除了源侧 public contract 已明确要求的返回签名外，不要在 service-local helper、lambda 或内部类型别名里继续暴露 `TL*`。若 source public API 明确保留 `TL*`，请仅在 public 边界维持该签名并把实现细节下沉到 `private/internal`。",
    ),
    StaticRule(
        rule_id="static-number-suffix-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\b0[Uu]?[Ll]\b"),
        description="出现 0L / 0UL / 0uL 等数字后缀倒退。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "静态扫描器是基于 AST 和文本硬匹配的！你不能靠注释、解释或伪注解蒙混过关；必须在物理代码层面彻底删除所有 `0L`、`0U`、`0UL` 这类后缀字面量。\n"
            "[ESCAPE HATCH FOR number suffix]\n"
            "仓颉对数字字面量后缀非常严格，禁止混用 C/C++/Java 风格。如果只是零值，请直接写 `0`；如果是为了类型匹配，请强制改用 `Int64(0)`、`UInt32(0)` 等显式类型构造。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修复数字后缀时，严禁引入任何 TL* 协议对象或 SignalPipe。Domain Purity 依然是最高优先级！"
        ),
    ),
    StaticRule(
        rule_id="static-import-from-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bimport\s+.*?\s+from\b"),
        description="出现 ArkTS / TypeScript 风格 import ... from 语法倒退。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "这是 ArkTS / TypeScript 的 `import ... from` 语法，仓颉绝对不认！你不能在注释里说自己修过了；必须在物理代码层面彻底删除整条 `import ... from` 语句。\n"
            "[ESCAPE HATCH FOR import ... from]\n"
            "请强制改用仓颉合法导入形式：`import package_name.*` 或 `import package_name.TypeName`。严禁继续保留 `from` 关键字。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修复导入语法时，严禁引入任何 TL* 协议对象或 SignalPipe。Domain Purity 依然是最高优先级！"
        ),
    ),
    StaticRule(
        rule_id="static-from-import-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bfrom\s+['\"][^'\"]+['\"]\s+import\b"),
        description="出现脚本语言风格 from '...' import 语法倒退。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "这是脚本语言的 `from '...' import ...` 语法，仓颉绝对不认！你不能在注释里说自己修过了；必须在物理代码层面彻底删除整条导入语句。\n"
            "[ESCAPE HATCH FOR import ... from]\n"
            "请改回仓颉合法形式：同包 staged 依赖优先直接引用；若确实需要导入，只允许 `import package_name.*` 或 `import package_name.TypeName`。严禁继续保留 `from` 关键字。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修复导入语法时，严禁引入任何 TL* 协议对象或 SignalPipe。Domain Purity 依然是最高优先级！"
        ),
    ),
    StaticRule(
        rule_id="static-export-class-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bexport\s+class\b"),
        description="出现 ArkTS / TypeScript 风格 export class 导出幻觉。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，仓颉中没有 export class，请改为 public class 或仓颉合法声明形式。",
    ),
    StaticRule(
        rule_id="static-implements-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bimplements\b"),
        description="出现 Java / ArkTS 风格 implements 继承语法幻觉。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，仓颉中没有 implements，请改为 <: 形式。",
    ),
    StaticRule(
        rule_id="static-extends-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bextends\b"),
        description="出现 Java / ArkTS 风格 extends 继承语法幻觉。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，仓颉中没有 extends；尤其禁止在 Service 层给 TL* / InputPeer / 业务实体自造桩类再去继承。若缺少类型定义，请回到 Domain Model、预设映射类型，或把 opaque handle / OpaquePointer 式方案下沉到更底层，而不是在 Service 里继续写 extends。",
    ),
    StaticRule(
        rule_id="static-promise-then-chain",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\.then\s*\("),
        description="出现 TypeScript / ArkTS 风格 Promise `.then(...)` 链式调用残留。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，请彻底删除 `.then(...)` 链式调用，并恢复 source-aligned public contract：若源侧方法本身是 async / `Promise<T>`，改成 `Future<T>` + `spawn { ... }` / `.get()`；若源侧不是 async，就把内部并发封装到 `private/internal` helper 中，不要把 public API 改成同步或伪异步。",
    ),
    StaticRule(
        rule_id="static-promise-catch-chain",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\.catch\s*\("),
        description="出现 TypeScript / ArkTS 风格 Promise `.catch(...)` 链式调用残留。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，请彻底删除 `.catch(...)` 链式调用，改为仓颉显式错误处理或更保守的流程控制。",
    ),
    StaticRule(
        rule_id="static-async-keyword-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\basync\b"),
        description="出现 ArkTS / TypeScript 风格 async 关键字残留。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`async` 是 ArkTS / TypeScript 风格回潮词。仓颉当前这条验证链路不会接受你把 Service 方法继续写成 `async`；注释说明、语义解释或换行排版都骗不过扫描器。\n"
            "[ESCAPE HATCH FOR async]\n"
            "请物理删除 `async` 关键字，并恢复 source-aligned async/sync 合同：若源侧 public method 是 `Promise<T>` / async，改为 `Future<T>` + `spawn {{ ... }}` / `.get()`；若源侧 public method 不是 async，就把并发调度收进 `private/internal` helper，不要借机改写 public 返回形态。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 async 时，严禁顺手把 `std.unsafe.*`、`InputPeer/createInputPeer`、`sendRequest(...)` 或多行闭包逻辑带回 Service 层。继续坚守 Zero-Block Rule 与 Helper Extraction。"
        ),
    ),
    StaticRule(
        rule_id="static-await-keyword-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"\bawait\b"),
        description="出现 ArkTS / TypeScript 风格 await 关键字残留。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`await` 是 ArkTS / TypeScript 风格回潮词。当前仓颉验证链路不接受你继续保留 `await`；换行、注释或包一层 helper 都躲不过扫描器。\n"
            "[ESCAPE HATCH FOR await]\n"
            "请物理删除 `await`，把源侧 `Promise<T>` 映射为 `Future<T>`，并用 `spawn {{ ... }}` + `.get()` 维持异步时序；若返回 `Future<Unit>`，`spawn` 末尾显式写 `()`。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 await 时，严禁顺手把 `std.unsafe.*`、`InputPeer/createInputPeer`、`sendRequest(...)` 或多行闭包逻辑带回 Service 层。继续坚守 Zero-Block Rule 与 Helper Extraction。"
        ),
    ),
    StaticRule(
        rule_id="static-std-concurrent-import-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bstd\.concurrent\b"),
        description="出现 `std.concurrent` 包路径回潮，当前物理链路无法解析。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "当前 Cangjie SDK 6.1.0.818 物理编译链无法解析 `std.concurrent.*`。你不能继续把它当成 `Future` / `spawn` 的来源；只要保留这个包路径，就会直接 compile-fail。\n"
            "[ESCAPE HATCH FOR std.concurrent]\n"
            "物理删除 `import std.concurrent.*` 与所有 `std.concurrent.*` 引用。若需要 `Future`、`spawn`、锁或并发原语，必须且只能改用已验证的 `import std.sync.*`。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 `std.concurrent` 时，严禁顺手把 `async`、`await`、`Promise(...)`、`InputPeer/createInputPeer` 或 TL* 路径带回当前文件。"
        ),
    ),
    StaticRule(
        rule_id="static-atomic-family-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"\bAtomic\s*<[^>\n]+>|\bAtomic[A-Z]\w*\b|\bAtomic\b(?=\s*\()"),
        description="出现 Java/C# 风格 Atomic 家族并发原语幻觉。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`Atomic` / `AtomicInt64` 不是 Service 层的急救贴。你不能靠泛型参数、别名或包装 helper 继续偷渡这些并发原语；只要代码里还出现 `Atomic*`，静态墙就会直接拦截。\n"
            "[ESCAPE HATCH FOR Atomic]\n"
            "如果只是本地消息 ID 计数、缓存版本号或临时序号：优先改成普通 `Int64` 字段；只有在确实存在共享写入时，才用 `Mutex` / `ReentrantMutex` 包住那一小段修改逻辑。若当前场景根本没有真实竞争，就直接删除 Atomic。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 Atomic 时，严禁顺手把 `ReentrantLock`、`Signal/ValueSignal`、TL*、`ArrayList` 或 `ohos.*` 路径带回 Service 层。"
        ),
    ),
    StaticRule(
        rule_id="static-lock-family-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"\bReentrantLock\b|\bLock\b(?!\s*[:=])|\bSemaphore\b"),
        description="出现 Java/C# 风格 Lock / Semaphore 并发原语幻觉。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`ReentrantLock` 是 Java 专属名字，仓颉编译器看到这个词会直接把你打回。你不能在注释里把它伪装成‘仓颉原生并发原语’；必须在物理代码层面彻底删除 `ReentrantLock` / `Lock` / `Semaphore` 这些 Java/C# 幻觉。\n"
            "[ESCAPE HATCH FOR ReentrantLock]\n"
            "必须且只能 `import std.sync.*`，并优先改用 `ReentrantMutex`；若当前场景不需要重入，再退回 `Mutex`。严禁继续发明 Java 风格锁名称。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修锁时，绝对不准用回大括号闭包里的多行逻辑；继续坚守 Zero-Block Rule 与 Helper Extraction。同时严禁引入任何 TL* 协议对象或 SignalPipe。"
        ),
    ),
    StaticRule(
        rule_id="static-arraylist-hallucination",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bArrayList\b"),
        description="出现 Java 风格 ArrayList 集合幻觉（零容忍）。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "静态扫描器会直接硬匹配 `ArrayList`。你在注释里写 // removed ArrayList 或声称自己已经换容器都毫无意义；必须在物理代码层面彻底删除 `ArrayList`。\n"
            "[ESCAPE HATCH FOR ArrayList]\n"
            "在当前仓颉项目中，优先保持源侧已经证明存在的最小容器形态，例如 `Array<T>` / `[]`；不要擅自升级成 `Vector<T>`、`toArray()` 或任何未经真实编译证明可用的集合 API。严禁继续捏造 Java 风格泛型集合。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修复 ArrayList 时，严禁引入任何 TL* 协议对象或 SignalPipe。Domain Purity 依然是最高优先级！"
        ),
    ),
    StaticRule(
        rule_id="static-signal-arraylist-smuggling",
        issue_code="ARCH_EXECUTION_TOPOLOGY_VIOLATION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"\b(?:Value)?Signal\s*<\s*ArrayList\s*<"),
        description="出现 Signal/ValueSignal 包裹 ArrayList 的嵌套走私。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`Signal<ArrayList<...>>` / `ValueSignal<ArrayList<...>>` 是双重走私：既把 Java 容器带回来了，又把影子信号框架带回来了。你不能通过注释、换行或 helper 名称粉饰这件事；必须整段物理删除。\n"
            "[ESCAPE HATCH FOR Signal/ValueSignal]\n"
            "删除 `ArrayList` 型 shadow runtime 与 service-local reactive ownership。若源侧 public API 明确保留 `Signal` / `ValueSignal` 等 reactive contract，请继续保留该 public signature 名称，但把 reactive object 的 ownership externalize 到本文件之外；不要把 public API 改写成 `Vector<T>` / `Option<T>` / 纯同步结果。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 Signal/ValueSignal 时，严禁重新引入 `ArrayList`、TL*、`InputPeer/createInputPeer`、`sendRequest(...)` 或 `ohos.*` 路径。"
        ),
    ),
    StaticRule(
        rule_id="static-promise-domain-smuggling",
        issue_code="ARCH_EXECUTION_TOPOLOGY_VIOLATION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"\bPromise\s*<\s*Domain\w+"),
        description="出现 Promise 包裹领域模型的伪异步残留。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，不要继续保留 ArkTS `Promise<...>` 语法残留。若源侧 public method 本身是 async / `Promise<T>`，请映射为 source-aligned 的 `Future<T>`；若源侧 public method 不是 async，就在内部收敛并发细节，不要把 public API 改写成新的异步或同步契约。",
    ),
    StaticRule(
        rule_id="static-arraylist-domain-smuggling",
        issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\bArrayList\s*<\s*Domain\w+"),
        description="出现 Java 容器包裹领域对象的伪领域集合。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，不要再用 `ArrayList<Domain...>` 这种 Java 容器装载领域对象；请回到当前项目已验证的最小 source-aligned 容器形态，例如 `Array<T>` / `[]`，并避免凭空升级成未经证实的 `Vector<T>` API。",
    ),
    StaticRule(
        rule_id="static-shadow-signal-flow",
        issue_code="ARCH_EXECUTION_TOPOLOGY_VIOLATION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"\bSignal\b|\bValueSignal\b|\bObservable\b"),
        description="Service 层出现自造的信号流/异步包装器影子框架。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`Signal` / `ValueSignal` / `Observable` 是影子框架名，不是当前仓颉 Service 的合法契约。你不能换个类名、放进 helper 或假装它是仓颉标准库的一部分；只要这些词还在，静态墙就会继续拦截。\n"
            "[ESCAPE HATCH FOR Signal/ValueSignal]\n"
            "删除当前 service 文件里的 reactive runtime、registry、cache ownership 与本地实现，但不要借机篡改 source-aligned public contract。若源侧 public API 暴露 `Signal` / `ValueSignal` / 等价 reactive contract，请保留该 public signature 名称，通过外部依赖或 `private/internal` 协作者转发/解析，而不是改写成 `Vector<T>`、`Option<T>` 或纯同步 public API。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 Signal/ValueSignal 时，严禁重新引入 `ArrayList`、TL*、`InputPeer/createInputPeer`、`sendRequest(...)` 或 `ohos.*` 路径。"
        ),
    ),
    StaticRule(
        rule_id="static-shadow-gateway-bridge",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\bGateway\b|\bBridge\b|\bProtocolWrapper\b"),
        description="Service 层出现伪造网关/桥接壳子，疑似试图隐藏协议污染。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，不要通过自造 Gateway/Bridge/ProtocolWrapper 藏匿协议细节；物理删除这些壳层。若确实需要内部 wiring，只能复用 source imports、TU dependency closure 或 explicit staged contract allowlist 中已存在的 `private/internal` 协作者符号，不得在当前文件发明新类型、locator 或桥接实现。",
    ),
    StaticRule(
        rule_id="static-shadow-container",
        issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\bCollection\b|\bDataBuffer\b"),
        description="Service 层出现伪造容器/缓冲区壳子，疑似试图掩盖底层字节流处理。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，禁止在 Service 层定义 Collection/DataBuffer 这类影子容器，请改用纯领域对象并把底层缓存/字节流全部下沉到 Adapter。",
    ),
    StaticRule(
        rule_id="static-import-ohos-package",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bimport\s+ohos(?:\.[A-Za-z0-9_]+)+"),
        description="出现对 `ohos.*` 包路径的直接导入依赖。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "仓颉不认识任何 `@ohos.*` / `ohos.*` 前端路径，也不接受你把它们伪装成当前 Service 层的合法导入。注释说明、别名换皮或 import 排版都骗不过扫描器；必须物理删除这些路径。\n"
            "[ESCAPE HATCH FOR @ohos path]\n"
            "先删除所有 `@ohos.*` / `ohos.*` 导入。只允许保留当前 TU / repo index / 真实 workspace 中已经存在且可解析的真实包；如果当前上下文没有可信包路径，就不要发明任何新 import，尤其不要发明 `import models.*`、`import services.*`、`import ohos.*` 这类假包。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修包路径时，严禁把 TL*、`InputPeer/createInputPeer`、`Signal/ValueSignal` 或 `ArrayList` 重新带回 Service 层。Domain Purity 依然是最高优先级！"
        ),
    ),
    StaticRule(
        rule_id="static-ohos-path-anywhere",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"(?:\b|@)ohos(?:\.[A-Za-z0-9_]+)+"),
        description="代码中出现任何 `ohos.*` 路径残留（全家桶封杀）。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "无论你把 `ohos.*` 写在 import、类型名、变量名还是表达式里，它都不是当前仓颉 Service 的合法路径。你必须物理删除所有残留的 `@ohos.*` / `ohos.*` 片段。\n"
            "[ESCAPE HATCH FOR @ohos path]\n"
            "只允许引用当前 TU / repo index / 真实 workspace 中已经存在的真实包；若当前上下文没有可信包路径，就不要发明任何新 import。尤其不要发明 `import models.*`、`import services.*`、`import ohos.*` 这类假包。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修包路径时，严禁把 TL*、`InputPeer/createInputPeer`、`Signal/ValueSignal` 或 `ArrayList` 重新带回 Service 层。Domain Purity 依然是最高优先级！"
        ),
    ),
    StaticRule(
        rule_id="static-promise-constructor-fantasy",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bPromise(?:<[^\n]+>)?\s*\("),
        description="出现 TypeScript / ArkTS 风格 Promise 直接构造或泛型伪实例化。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，仓颉并发不接受这种 `Promise(...)` / `Promise<T>(...)` 伪构造；请改为 `Future<T>`，并使用 `spawn {{ ... }}`、`.get()` 与显式 `()` 收尾。",
    ),
    StaticRule(
        rule_id="static-promise-return-signature",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r":\s*Promise<|->\s*Promise<"),
        description="函数/方法签名中出现 Promise 返回类型残留。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，ArkTS `Promise<T>` 在当前仓颉链路中必须映射为 `Future<T>`；请补 `import std.sync.*`，并把签名改成常规 `func ...: Future<T>`。",
    ),
    StaticRule(
        rule_id="static-pseudo-producer-pattern",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"\bproducer\b|\bProducer<"),
        description="出现 Producer / producer 伪并发范式残留。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，不要再用 `producer` / `Producer<T>` 给 Promise 换壳；仓颉中请回归 `spawn`、真实领域方法或已验证并发原语。",
    ),
    StaticRule(
        rule_id="static-abstract-func-missing-return",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"abstract\s+func\s+\w+\s*\([^)]*\)(?!\s*[:{])", re.MULTILINE),
        description="出现不带返回类型的非标 abstract func 声明。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，抽象函数声明必须显式给出仓颉合法返回类型或改为具体实现，禁止留下无返回类型的空洞声明。",
    ),
    StaticRule(
        rule_id="static-arkts-interface-colon",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"interface\s+\w+\s*:[^<{]"),
        description="出现 ArkTS / TypeScript 风格 interface 冒号继承写法。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，不要再使用 `interface X: Y` 这种源语言写法；请改为仓颉合法 interface 语法或 `<:` 关系。",
    ),
    StaticRule(
        rule_id="static-unsafe-keyword",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\bstd\.unsafe\b|\bunsafe\b"),
        description="出现 std.unsafe 包或 unsafe 关键字残留（最高威胁）。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "这是终局零容忍项。静态扫描器基于 AST 与文本硬匹配，你在注释里写 // removed std.unsafe 也是无效的自欺欺人。特别是 `import std.unsafe.*` 这一整行，必须在物理代码层面彻底删除。\n"
            "[ESCAPE HATCH FOR std.unsafe FINAL]\n"
            "如果你只是为了强制解包：请改用 `match` 或 `let x = opt ?? default`。如果你只是为了类型转换：请改用 `as` 安全强转。Service 层绝对不允许再 import `std.unsafe.*`。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修复 `std.unsafe` 后，永远不要再重新引入 `import std.unsafe.*`、任何 `unsafe` 变体、任何 TL* 协议对象或 `SignalPipe`。Domain Purity 仍然是最高优先级。"
        ),
    ),
    StaticRule(
        rule_id="static-postfix-non-null-assertion",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"\b[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*\s*!\s*(?=(?:[)\].,;:+\-*/%?}]|$))"),
        description="出现 TypeScript 风格后缀非空断言/强制解包写法。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，请移除后缀 ! 解包恶习，改用仓颉合法的显式判空、默认值或安全解包形式。",
    ),
    StaticRule(
        rule_id="static-double-bang",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"!!"),
        description="出现 TypeScript 风格双叹号恶习。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，请彻底移除双叹号并改用显式判空/判布尔逻辑。",
    ),
    StaticRule(
        rule_id="static-tl-serialization-in-service",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\bTLSerialization\b|\bTLDeserializer\b"),
        description="Service 层出现序列化/反序列化器名称，说明协议细节没有被下沉到 Adapter。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "Service 层连 `TLSerialization` / `TLDeserializer` 的名字都不应该知道。你不能靠包装类、helper 名称或注释解释继续保留这些协议细节；只要这些词还在，说明隔离层仍然失败。\n"
            "[ESCAPE HATCH FOR TL* protocol import]\n"
            "把所有 TL 序列化 / 反序列化、字节拼装、协议构造 100% 下沉到 Adapter 或更底层基础设施。Service 只允许面对纯领域对象和领域级 Adapter 方法。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 TL* 时，严禁重新引入 `sendRequest(...)`、`InputPeer/createInputPeer`、`Signal/ValueSignal`、`ArrayList` 或 `ohos.*` 路径。"
        ),
    ),
    StaticRule(
        rule_id="static-protocol-stub-class",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"\b(?:class|struct|interface)\s+(?:TL[A-Z]\w*|InputPeer(?:[A-Z]\w*)?)\b"),
        description="Service 层试图自造 TL* / InputPeer 协议桩类。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "你正在 Service 层自造 TL* / InputPeer 协议桩类。这不是修复，这是污染扩散。任何 `class TLUser`、`class TLChannel`、`class InputPeer...` 都必须物理删除。\n"
            "[ESCAPE HATCH FOR protocol stub class]\n"
            "所有 TL* 与 InputPeer 都属于底层 CFFI / FFI 协议层。Service 层绝对不允许定义、实现或继承它们。若缺少类型定义，请改回 Domain Model、预设映射类型，或把 opaque handle / OpaquePointer 式方案下沉到底层。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修协议桩类时，严禁顺手重新引入 `extends`、`implements`、`std.unsafe.*`、`ArrayList`、`Signal/ValueSignal` 或 `ohos.*`。"
        ),
    ),
    StaticRule(
        rule_id="static-send-request-in-service",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"(?:\.sendRequest|\bsendRequest)\s*\("),
        description="Service 层直接发送底层请求。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`sendRequest(...)` 是底层请求通道，不属于 Service 层。你不能换个对象名、包一层 helper 或改成链式写法来掩盖；只要 Service 里还在直接发请求，静态墙就会继续拦截。\n"
            "[ESCAPE HATCH FOR sendRequest]\n"
            "把底层请求发送彻底下沉到 Adapter，Service 层只能调用领域级方法，例如 `fetchMessages(...)`、`sendMessage(...)`、`loadHistory(...)` 之类的业务接口，绝不允许直接碰 Request/bytes。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 sendRequest 时，严禁重新引入 `InputPeer/createInputPeer`、`std.unsafe.*`、TL*、SignalPipe，且继续坚守 Zero-Block Rule 与 Helper Extraction。"
        ),
    ),
    StaticRule(
        rule_id="static-binary-buffer-in-service",
        issue_code="ARCH_DOMAIN_PURITY_VIOLATION",
        required_dimension="Architecture Mapping",
        severity="blocker",
        pattern=re.compile(r"(?:\bArray<UInt8>|\bVector<UInt8>)"),
        description="Service 层直接持有底层字节流类型。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，业务层不允许直接操作字节数组，请将二进制细节全部封进 Adapter / 基础设施层。",
    ),
    StaticRule(
        rule_id="static-to-bytes-call",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Dependency Constraint",
        severity="blocker",
        pattern=re.compile(r"\.toBytes\(\)"),
        description="Service 层出现显式转字节调用。",
        repair_hint="系统静态扫描发现致命违规词汇 {match}，显式转字节逻辑必须 100% 下沉到 Adapter 或基础设施层，Service 层不允许直接做 `.toBytes()`。",
    ),
    StaticRule(
        rule_id="static-service-request-type-leak",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Dependency Constraint",
        severity="blocker",
        pattern=re.compile(r"\bMessages(?:GetHistory|SendMessage)\b"),
        description="Service 层出现协议 request/type 名称泄漏。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`MessagesGetHistory` / `MessagesSendMessage` 这类协议 request type 不属于 Service public/internal 视野。只要这些名字还在当前文件里，说明协议层实体没有真正下沉。\n"
            "[ESCAPE HATCH FOR service request-type leakage]\n"
            "物理删除当前 service 文件里的 request type 构造、局部变量、helper 和注释残留。Service 只能调用业务级 contract；协议 request type、bytes、serializer/deserializer 都必须完全下沉到外部依赖或更底层实现。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 request type 泄漏时，严禁把 `sendRequest(...)`、`.toBytes()`、`TLDeserializer`、`ArrayList`、`ValueSignal(...)` 或 `getMTProtoClient()` 一起带回当前文件。"
        ),
    ),
    StaticRule(
        rule_id="static-service-mtprotoclient-accessor-leak",
        issue_code="ARCH_PROTOCOL_ISOLATION",
        required_dimension="Dependency Constraint",
        severity="blocker",
        pattern=re.compile(r"\bgetMTProtoClient\s*\("),
        description="Service 层出现 MTProto 单例/protocol accessor 泄漏。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`getMTProtoClient()` 是协议层 accessor，不属于当前 Service 文件。你不能把它藏进 private helper 或局部变量继续调用；只要这个 accessor 还在，就说明隔离层仍然失败。\n"
            "[ESCAPE HATCH FOR getMTProtoClient leakage]\n"
            "物理删除 `getMTProtoClient()` 的所有调用点与包装 helper，让 service 只面对 source/dependency closure/oracle 已知的业务级 contract，不要直接触碰 MTProto singleton accessor。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 accessor 泄漏时，严禁顺手把 `MessagesGetHistory`、`MessagesSendMessage`、`sendRequest(...)`、`.toBytes()` 或 `TLDeserializer` 留在当前文件。"
        ),
    ),
    StaticRule(
        rule_id="static-service-zero-block-match-arm",
        issue_code="ARCH_MATCH_ZERO_BLOCK_VIOLATION",
        required_dimension="Execution Topology",
        severity="blocker",
        pattern=re.compile(r"\bcase\s+(?:None|Some\s*\([^)\n]+\))\s*=>\s*\{"),
        description="Service 层出现 block-style match arm，违反 Zero-Block 约束。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "当前 service 目标的 `match` 分支必须保持单表达式。`case None => {{}}`、`case Some(...) => {{ ... }}` 这类 block-style arm 会直接被静态墙拦截。\n"
            "[ESCAPE HATCH FOR Zero-Block]\n"
            "把分支里的多步逻辑提取到 `private/internal` helper，再让分支只返回 helper 调用、现成值或单表达式 `()`。空分支唯一合法写法是 `case None => ()`。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 Zero-Block 时，严禁顺手把 `MessagesGetHistory`、`MessagesSendMessage`、`getMTProtoClient()`、`sendRequest(...)` 或 `ValueSignal(...)` 留在当前文件。"
        ),
    ),
    StaticRule(
        rule_id="static-service-option-none-compare",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        pattern=re.compile(r"(?:==|!=)\s*None\b"),
        description="Service 层对 Option / ?T 使用了 None 直接比较。",
        repair_hint=(
            "系统静态扫描发现致命违规词汇 {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "当前 service 目标不接受 `Option` / `?T` 与 `None` 的直接 `==` / `!=` 比较。像 `if (user.accessHash != None)` 这种写法会在真实编译阶段直接炸掉。\n"
            "[ESCAPE HATCH FOR Option/None compare]\n"
            "把 `== None` / `!= None` 物理删除，改用 `match (value)` 或 `if let` 处理可选值。对空分支使用单表达式 `()`，对非空分支直接写合法逻辑，例如 `case Some(hash) => this.userAccessHashes[user.id.toString()] = hash`。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 `Option` 判空时，严禁顺手回潮到 `if (hash != 0)`、后缀 `!` 强解包、`throw TODO`、`ValueSignal(...)` 或 invented collaborator。"
        ),
    ),
)

SERVICE_COLLABORATOR_STD_SYMBOLS = {
    "Array",
    "Bool",
    "Error",
    "Future",
    "HashMap",
    "Int32",
    "Int64",
    "Mutex",
    "Option",
    "ReentrantMutex",
    "String",
    "UInt8",
    "Unit",
    "Vector",
}
UI_TARGET_ROLES = {"page", "component", "viewmodel", "state", "interop"}
PHASE06_UI_EXCEPTION_TAG_KEYS = (
    "structure_tag",
    "ownership_tag",
    "interaction_tags",
    "exception_tags",
    "sample_scope_tags",
)
HYBRID_EXCEPTION_ALLOWED_OHOS_PATH_PREFIXES = (
    "ohos.hybrid_base.",
)
HYBRID_EXCEPTION_ALLOWED_OHOS_PATHS = {
    "ohos.state_macro_manage.HybridComponentEntry",
}

SERVICE_INVENTED_COLLABORATOR_TYPE_PATTERN = re.compile(
    r"\b(?:private|internal)\s+(?:let|var)\s+\w+\s*:\s*([A-Z]\w*)\b"
)
SERVICE_INVENTED_COLLABORATOR_CTOR_PATTERN = re.compile(
    r"\b(?:private|internal)\s+(?:let|var)\s+\w+\s*=\s*([A-Z]\w*)\s*(?:<[^>\n]+>)?\s*\("
)
SERVICE_INVENTED_COLLABORATOR_DECL_PATTERN = re.compile(
    r"\binternal\s+(?:class|interface|struct|enum)\s+([A-Z]\w*)\b"
)
SERVICE_INVENTED_COLLABORATOR_LOCATOR_PATTERN = re.compile(r"\b([A-Z]\w*Locator)\b")
SERVICE_REACTIVE_RUNTIME_TOKEN_PATTERN = r"(?:Signal|ValueSignal|Observable)"
SERVICE_REACTIVE_RUNTIME_OWNERSHIP_PATTERN = re.compile(
    rf"\b(?:private|internal|let|var)\s+\w+\s*:\s*({SERVICE_REACTIVE_RUNTIME_TOKEN_PATTERN}\s*(?:<[^=\n]+>)?)"
)
SERVICE_REACTIVE_HELPER_RETURN_PATTERN = re.compile(
    rf"\b(?:private|internal)\s+func\s+\w+\s*\([^)]*\)\s*:\s*({SERVICE_REACTIVE_RUNTIME_TOKEN_PATTERN}\s*(?:<[^\n{{]+>)?)"
)
SERVICE_REACTIVE_MATERIALIZATION_PATTERN = re.compile(
    rf"({SERVICE_REACTIVE_RUNTIME_TOKEN_PATTERN})\s*(?:<[^(\n]+>)?\s*\("
)
SERVICE_REACTIVE_TODO_PATTERN = re.compile(r"\bthrow\s+TODO\b|\breturn\s+TODO\s*(?:\(|$)")
SERVICE_INVENTED_REACTIVE_SHELL_PATTERN = re.compile(
    r"\b([A-Z](?:\w*(?:Signal|Reactive)\w*(?:Provider|Facade|Shell)|(?:Signal|Reactive)(?:Provider|Facade|Shell)))\b"
)
SERVICE_HASHMAP_DECL_PATTERN = re.compile(
    r"\b(?:private|internal|public|let|var)\s+([A-Za-z_]\w*)\s*:\s*HashMap\s*<"
)
SERVICE_PUBLIC_FUNC_PATTERN = re.compile(
    r"^\s*public\s+func\s+(?P<name>[A-Za-z_]\w*)\s*\((?P<params>[^)]*)\)\s*:\s*(?P<return>[^;{\n]+)",
    re.MULTILINE,
)


def _collect_service_collaborator_allowlist(tu: Dict[str, object] | None) -> set[str]:
    if not isinstance(tu, dict):
        return set(SERVICE_COLLABORATOR_STD_SYMBOLS)
    allowed = set(SERVICE_COLLABORATOR_STD_SYMBOLS)
    allowed.update(collect_service_symbol_allowlist(tu))
    return {symbol for symbol in allowed if symbol}


def _target_role(tu: Dict[str, object] | None) -> str:
    if not isinstance(tu, dict):
        return ""
    target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
    return str(target.get("role", "")).strip().lower()


def _target_scope_label(tu: Dict[str, object] | None) -> str:
    role = _target_role(tu)
    if role == "service":
        return "Service 层"
    if role in UI_TARGET_ROLES:
        return "当前 UI 文件"
    return "当前文件"


def _ui_source_text(tu: Dict[str, object] | None) -> str:
    if not isinstance(tu, dict):
        return ""
    target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
    return str(target.get("source", "") or "")


def _extract_phase06_ui_tag_payload(tu: Dict[str, object] | None) -> Dict[str, object]:
    if not isinstance(tu, dict):
        return {}
    target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
    metadata = tu.get("metadata", {}) if isinstance(tu.get("metadata"), dict) else {}
    payload: Dict[str, object] = {}
    candidate_containers = [
        target.get("ui_prompt_tags"),
        target.get("phase06_ui_tags"),
        metadata.get("ui_prompt_tags"),
        metadata.get("phase06_ui_tags"),
        target,
        metadata,
    ]
    for container in candidate_containers:
        if not isinstance(container, dict):
            continue
        for key in PHASE06_UI_EXCEPTION_TAG_KEYS:
            if key in container and key not in payload:
                payload[key] = container.get(key)
    return payload


def _phase06_ui_exception_tags(tu: Dict[str, object] | None) -> set[str]:
    payload = _extract_phase06_ui_tag_payload(tu)
    raw_tags = payload.get("exception_tags", [])
    if not isinstance(raw_tags, list):
        return set()
    return {str(item).strip() for item in raw_tags if str(item).strip()}


def _has_phase06_ui_exception_tag(tu: Dict[str, object] | None, tag: str) -> bool:
    if _target_role(tu) not in UI_TARGET_ROLES:
        return False
    return tag in _phase06_ui_exception_tags(tu)


def _is_allowed_hybrid_exception_ohos_path(path: str) -> bool:
    return path in HYBRID_EXCEPTION_ALLOWED_OHOS_PATHS or any(
        path.startswith(prefix) for prefix in HYBRID_EXCEPTION_ALLOWED_OHOS_PATH_PREFIXES
    )


def _normalize_line_for_compare(line_text: str) -> str:
    return re.sub(r"\s+", " ", line_text.strip())


def _collect_ui_source_normalized_lines(tu: Dict[str, object] | None) -> set[str]:
    source = _ui_source_text(tu)
    return {
        normalized
        for normalized in (_normalize_line_for_compare(line) for line in source.splitlines())
        if normalized
    }


UI_OHOS_IMPORT_PATTERN = re.compile(
    r"^\s*(?:(?:public|private|protected|internal)\s+)?import\s+"
    r"(ohos(?:\.[A-Za-z0-9_]+)+(?:\.\*)?)\s*$",
    re.MULTILINE,
)


def _collect_ui_source_ohos_imports(tu: Dict[str, object] | None) -> set[str]:
    source = _ui_source_text(tu)
    imports: set[str] = set()
    for match in UI_OHOS_IMPORT_PATTERN.finditer(source):
        imports.add(match.group(1))
    return imports


def _extract_ohos_import_path(line_text: str) -> str:
    match = UI_OHOS_IMPORT_PATTERN.match(line_text.strip())
    return match.group(1) if match else ""


def _extract_ohos_path_from_match(matched_text: str, line_text: str) -> str:
    import_path = _extract_ohos_import_path(line_text)
    if import_path:
        return import_path
    matched_text = matched_text.strip()
    if matched_text.startswith("import "):
        return matched_text[len("import ") :].strip()
    return matched_text


UI_FIELD_DECL_PATTERN = re.compile(
    r"^\s*(?:(?P<visibility>public|private|protected|internal)\s+)?"
    r"(?:(?:open|override|static|mut)\s+)*(?P<mutability>let|var)\s+"
    r"(?P<name>[A-Za-z_]\w*)\s*:\s*(?P<type>[^=\n]+?)(?:\s*=\s*.*)?$"
)
UI_FUNC_DECL_PATTERN = re.compile(
    r"^\s*(?:(?P<visibility>public|private|protected|internal)\s+)?"
    r"(?:(?:open|override|static|mut)\s+)*func\s+(?P<name>[A-Za-z_]\w*)\s*"
    r"\((?P<params>[^)]*)\)\s*:\s*(?P<return>[^={\n]+)"
)
UI_FUNC_DECL_OPTIONAL_RETURN_PATTERN = re.compile(
    r"^\s*(?:(?P<visibility>public|private|protected|internal)\s+)?"
    r"(?:(?:open|override|static|mut)\s+)*func\s+(?P<name>[A-Za-z_]\w*)\s*"
    r"\((?P<params>[^)]*)\)\s*(?::\s*(?P<return>[^={\n]+))?"
)


def _normalize_ui_decl_type(type_text: str) -> str:
    return re.sub(r"\s+", "", type_text.strip())


def _extract_ui_func_signature_key(line_text: str) -> str | None:
    match = UI_FUNC_DECL_OPTIONAL_RETURN_PATTERN.match(line_text.strip())
    if not match:
        return None
    params = _normalize_ui_decl_type(match.group("params"))
    return f"funcsig:{match.group('name')}({params})"


def _extract_ui_arraylist_semantic_key(line_text: str) -> str | None:
    if "ArrayList" not in line_text:
        return None
    field_match = UI_FIELD_DECL_PATTERN.match(line_text.strip())
    if field_match:
        return (
            f"field:{field_match.group('name')}:"
            f"{_normalize_ui_decl_type(field_match.group('type'))}"
        )
    func_match = UI_FUNC_DECL_PATTERN.match(line_text.strip())
    if func_match:
        params = _normalize_ui_decl_type(func_match.group("params"))
        return_type = _normalize_ui_decl_type(func_match.group("return"))
        if "ArrayList" in params or "ArrayList" in return_type:
            return f"func:{func_match.group('name')}({params}):{return_type}"
    return None


def _collect_ui_source_arraylist_semantic_keys(tu: Dict[str, object] | None) -> set[str]:
    source = strip_comments_preserve_layout(_ui_source_text(tu))
    keys: set[str] = set()
    for line_text in source.splitlines():
        key = _extract_ui_arraylist_semantic_key(line_text)
        if key:
            keys.add(key)
    return keys


def _normalize_ui_arraylist_usage_line(line_text: str) -> str:
    normalized = _normalize_line_for_compare(line_text)
    normalized = re.sub(r"^return\s+", "", normalized)
    return normalized.rstrip(";").strip()


def _collect_ui_source_arraylist_usage_lines(tu: Dict[str, object] | None) -> set[str]:
    source = strip_comments_preserve_layout(_ui_source_text(tu))
    return {
        normalized
        for line_text in source.splitlines()
        if "ArrayList" in line_text
        for normalized in [_normalize_ui_arraylist_usage_line(line_text)]
        if normalized
    }


def _collect_ui_source_arraylist_function_keys(tu: Dict[str, object] | None) -> set[str]:
    source = strip_comments_preserve_layout(_ui_source_text(tu))
    keys: set[str] = set()
    current_key: str | None = None
    current_has_arraylist = False
    brace_depth = 0
    for line_text in source.splitlines():
        stripped_line = line_text.strip()
        if current_key is None:
            current_key = _extract_ui_func_signature_key(stripped_line)
            if current_key is None:
                continue
            current_has_arraylist = "ArrayList" in stripped_line
            brace_depth = stripped_line.count("{") - stripped_line.count("}")
            if brace_depth <= 0:
                if current_has_arraylist:
                    keys.add(current_key)
                current_key = None
                current_has_arraylist = False
                brace_depth = 0
            continue
        if "ArrayList" in stripped_line:
            current_has_arraylist = True
        brace_depth += stripped_line.count("{") - stripped_line.count("}")
        if brace_depth <= 0:
            if current_has_arraylist:
                keys.add(current_key)
            current_key = None
            current_has_arraylist = False
            brace_depth = 0
    return keys


def _extract_ui_field_semantic_key(line_text: str) -> str | None:
    match = UI_FIELD_DECL_PATTERN.match(line_text.strip())
    if not match:
        return None
    return f"field:{match.group('name')}:{_normalize_ui_decl_type(match.group('type'))}"


def _collect_ui_source_field_visibility_map(tu: Dict[str, object] | None) -> Dict[str, bool]:
    source = strip_comments_preserve_layout(_ui_source_text(tu))
    visibility_map: Dict[str, bool] = {}
    for line_text in source.splitlines():
        match = UI_FIELD_DECL_PATTERN.match(line_text.strip())
        if not match:
            continue
        key = _extract_ui_field_semantic_key(line_text)
        if not key:
            continue
        visibility_map[key] = match.group("visibility") == "public"
    return visibility_map


def _format_rule_repair_hint(rule: StaticRule, matched_text: str, tu: Dict[str, object] | None) -> str:
    repair_hint = rule.repair_hint.format(match=repr(matched_text))
    role = _target_role(tu)
    if role in UI_TARGET_ROLES and rule.rule_id in {
        "static-arraylist-hallucination",
        "static-import-ohos-package",
        "static-ohos-path-anywhere",
    }:
        repair_hint = (
            repair_hint
            .replace("当前 Service 层", "当前 UI 文件")
            .replace("当前 service 文件", "当前 UI 文件")
            .replace("当前 service target", "当前 UI 目标")
            .replace("Service 层", "当前 UI 文件")
        )
        source_ohos_imports = sorted(_collect_ui_source_ohos_imports(tu))
        has_source_backed_arraylist = "ArrayList<" in _ui_source_text(tu)
        if rule.rule_id == "static-arraylist-hallucination":
            if has_source_backed_arraylist:
                repair_hint += (
                    "\n[UI ARRAYLIST CONTRACT FIDELITY]\n"
                    "对 Phase 06 UI 目标，若 source-aligned 文件已经在同名字段、函数签名或 helper 边界上使用 `ArrayList<T>`，则保留这些 exact source-backed line；只删除当前候选新增、且 source 中不存在的 invented `ArrayList` 用法。不要把 source-backed `ArrayList<T>` 偷换成 `Array<T>` / `[]`、`Vector<T>` 或 `toArray()`。"
                )
            else:
                repair_hint += (
                    "\n[UI COLLECTION NORMALIZATION]\n"
                    "对 Phase 06 UI 目标，保留 page/component/build/builder/list/grid 的声明式结构，但把 `ArrayList<T>` 统一收敛到最小合法集合形态 `Array<T>` / `[]`，并同步更新相关 helper 参数/返回；不要发明 `Vector<T>`、`toArray()` 或新的 collection facade。"
                )
        else:
            if source_ohos_imports:
                repair_hint += (
                    "\n[UI IMPORT CONTRACT FIDELITY]\n"
                    f"对 Phase 06 UI 目标，source-aligned 文件已经显式导入 {source_ohos_imports}。保留这些 exact `ohos.*` import path；只删除当前候选新增、且 source / TU / real workspace 都没有证据的 invented `ohos.*` 路径。"
                )
            else:
                repair_hint += (
                    "\n[UI IMPORT NORMALIZATION]\n"
                    "对 Phase 06 UI 目标，保留 `@Entry` / `@Component` / `build()` / builder / layout tree，但物理删除 `ohos.*` 路径。若当前上下文没有可信替代 import，就宁可保持零 import，也不要发明假包名。"
                )
    return repair_hint


def _normalize_public_method_signature(name: str, params: str, return_type: str) -> str:
    compact_params = re.sub(r"\s+", " ", params).strip()
    compact_return = re.sub(r"\s+", " ", return_type).strip()
    return f"{name}({compact_params}): {compact_return}"


def _make_invented_service_collaborator_violation(
    *,
    rule_id: str,
    matched_text: str,
    line: int,
    column: int,
    line_text: str,
) -> StaticViolation:
    repair_hint = (
        "系统静态扫描发现 invented collaborator / locator 符号 {match}。\n"
        "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
        "Service 文件里的 `private/internal` collaborator type、constructor target、factory、provider、locator 名称，必须来自 source imports、TU dependency closure 或 explicit staged contract allowlist；不存在的名字一律不能发明。\n"
        "[ESCAPE HATCH FOR invented collaborator]\n"
        "物理删除当前文件里凭空发明的 collaborator / locator 壳，例如 `MessageBackend`、`ServiceLocator`、`*Locator`。如果确实需要内部 wiring，只能复用当前 TU 已知的真实符号；中性字段名如 `backend` / `messagePort` 只允许作为变量名，不授权你发明新的类型名。\n"
        "[ANTI-OSCILLATION ANCHOR]\n"
        "修 invented collaborator 时，严禁顺手把 `Gateway` / `Bridge`、`InputPeer/createInputPeer`、TL*、`Signal/ValueSignal` 或虚假包导入带回当前文件。"
    )
    return StaticViolation(
        rule_id=rule_id,
        issue_code="ARCH_DEPENDENCY_CONSTRAINT_VIOLATION",
        required_dimension="Dependency Constraint",
        severity="blocker",
        message=(
            f"系统静态扫描发现 invented collaborator / locator 符号 {matched_text!r}"
            f"（第 {line} 行，第 {column} 列）。该符号不在 source imports、TU dependency closure 或 explicit staged contract allowlist 中。"
        ),
        matched_text=matched_text,
        line=line,
        column=column,
        line_text=line_text.rstrip(),
        repair_hint=repair_hint.format(match=repr(matched_text)),
    )


def _make_service_public_contract_drift_violation(
    *,
    method_name: str,
    matched_text: str,
    expected_signature: str,
    line: int,
    column: int,
    line_text: str,
) -> StaticViolation:
    repair_hint = (
        "系统静态扫描发现 public contract drift {match}。\n"
        "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
        "当前 service target 存在 explicit staged contract bundle，它就是 public compile-contract oracle。你不能再以“domain purity”或“internal async refactor”为理由漂移 public method 的参数类型、返回形态或同步/异步心智。\n"
        "[ESCAPE HATCH FOR staged contract oracle drift]\n"
        "把当前 public method 精确改回 oracle：`{expected}`。尤其不要把 `getMessages(..., limit: Int32)` 漂成 `Int64`，也不要把 `Signal<Array<Message>>` 偷换成 service-local `ValueSignal(...)` 或其它 runtime 实现。\n"
        "[ANTI-OSCILLATION ANCHOR]\n"
        "修 public contract drift 时，严禁顺手把 `MessagesGetHistory`、`MessagesSendMessage`、`getMTProtoClient()`、`sendRequest(...)`、`.toBytes()` 或 `TLDeserializer` 留在当前文件。"
    )
    return StaticViolation(
        rule_id="static-service-public-contract-drift",
        issue_code="ARCH_CONTRACT_RUPTURE",
        required_dimension="Architecture Mapping",
        severity="blocker",
        message=(
            f"系统静态扫描发现 public method {method_name!r} 偏离 explicit staged contract oracle"
            f"（第 {line} 行，第 {column} 列）。期望 `{expected_signature}`，实际为 `{matched_text}`。"
        ),
        matched_text=matched_text,
        line=line,
        column=column,
        line_text=line_text.rstrip(),
        repair_hint=repair_hint.format(match=repr(matched_text), expected=expected_signature),
    )


def _make_service_hashmap_put_violation(
    *,
    matched_text: str,
    line: int,
    column: int,
    line_text: str,
) -> StaticViolation:
    repair_hint = (
        "系统静态扫描发现 HashMap 写入 API 回退 {match}。\n"
        "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
        "当前 service 目标使用的 staged `HashMap` 不支持 Java 风格 `.put(key, value)`。只要当前文件里继续保留 `.put(...)`，真实编译就会直接失败。\n"
        "[ESCAPE HATCH FOR HashMap writes]\n"
        "把当前写法改成索引赋值：`map[key] = value`。例如 `this.userAccessHashes.put(user.id.toString(), hash)` 必须改成 `this.userAccessHashes[user.id.toString()] = hash`；`channelAccessHashes` 同理。\n"
        "[ANTI-OSCILLATION ANCHOR]\n"
        "修 `HashMap` 写入 API 时，严禁顺手改 public signature，也不要把 `?Int64` 安全解包退化回 `if (hash != 0)` 或其它 source-misaligned 判定。"
    )
    return StaticViolation(
        rule_id="static-service-hashmap-put-regression",
        issue_code="ARCH_SYNTAX_REGRESSION",
        required_dimension="Translation Mapping",
        severity="blocker",
        message=(
            f"系统静态扫描发现 HashMap `.put(...)` compile regression {matched_text!r}"
            f"（第 {line} 行，第 {column} 列）。当前 staged `HashMap` 不支持 `.put(...)`。"
        ),
        matched_text=matched_text,
        line=line,
        column=column,
        line_text=line_text.rstrip(),
        repair_hint=repair_hint.format(match=repr(matched_text)),
    )


def _make_ui_public_surface_drift_violation(
    *,
    matched_text: str,
    line: int,
    column: int,
    line_text: str,
) -> StaticViolation:
    return StaticViolation(
        rule_id="static-ui-public-surface-drift",
        issue_code="STATIC_PUBLIC_SURFACE_DRIFT",
        required_dimension="Architecture Mapping",
        severity="blocker",
        message=(
            f"系统静态扫描发现 UI public surface drift {matched_text!r}"
            f"（第 {line} 行，第 {column} 列）。当前字段/变量被错误提升为 `public`，与源侧可见性不一致。"
        ),
        matched_text=matched_text,
        line=line,
        column=column,
        line_text=line_text.rstrip(),
        repair_hint="UI_PUBLIC_DRIFT_DETECTED: Do not elevate visibility to 'public' unless it is public in the original source. Revert to default/private visibility.",
    )


def _is_service_reactive_runtime_line(line_text: str) -> bool:
    stripped_line = line_text.strip()
    if not stripped_line or re.match(r"public\s+func\b", stripped_line):
        return False
    return bool(
        SERVICE_REACTIVE_RUNTIME_OWNERSHIP_PATTERN.search(stripped_line)
        or SERVICE_REACTIVE_HELPER_RETURN_PATTERN.search(stripped_line)
        or SERVICE_REACTIVE_MATERIALIZATION_PATTERN.search(stripped_line)
    )


def _make_service_reactive_violation(
    *,
    rule_id: str,
    matched_text: str,
    line: int,
    column: int,
    line_text: str,
) -> StaticViolation:
    if rule_id == "static-service-reactive-ownership":
        issue_code = "ARCH_EXECUTION_TOPOLOGY_VIOLATION"
        required_dimension = "Execution Topology"
        message = (
            f"系统静态扫描发现 service-local reactive ownership {matched_text!r}"
            f"（第 {line} 行，第 {column} 列）。当前 service 文件不得持有 reactive runtime 类型。"
        )
        repair_hint = (
            "系统静态扫描发现 service-local reactive ownership {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "对当前 service target，`Signal` / `ValueSignal` / `Observable` 只能留在匹配的 public signature。字段、局部变量、缓存、helper 返回类型一旦写成 reactive type，就等于把 public contract 重新落成本地 runtime。\n"
            "[ESCAPE HATCH FOR service reactive ownership]\n"
            "物理删除 `let x: Signal<T>`、`private let cache: Signal<T>`、`private func buildSignal(...): Signal<T>` 这类声明。保留 source-/oracle-aligned public signature，并让 public method 只从 source imports、TU dependency closure、explicit staged contract allowlist 中已知真实符号获取或转发 reactive object。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 reactive ownership 时，严禁顺手引入 `throw TODO`、`ValueSignal(...)`、`SignalPipe(...)`、`MessagesGetHistory`、`MessagesSendMessage`、`getMTProtoClient()` 或 invented provider/facade/shell。"
        )
    elif rule_id == "static-service-reactive-placeholder":
        issue_code = "ARCH_CONTRACT_RUPTURE"
        required_dimension = "Architecture Mapping"
        message = (
            f"系统静态扫描发现 reactive placeholder escape {matched_text!r}"
            f"（第 {line} 行，第 {column} 列）。`throw TODO` / `TODO()` 不能充当 service reactive contract 的返回路径。"
        )
        repair_hint = (
            "系统静态扫描发现 reactive placeholder escape {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`throw TODO` / `TODO()` 不是合法的 reactive contract 实现，也不能作为 `Signal<Array<Message>>` 的占位返回。这样做只是在 public contract 保持不变的表面下，继续逃避真实 external forwarding 路径。\n"
            "[ESCAPE HATCH FOR reactive placeholder]\n"
            "保留 `getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>` 的 exact public shape，但删除 `throw TODO` / `TODO()`。如果当前上下文没有真实 reactive provider，就不要 invent 新 provider/facade/shell/locator；让 public method 直接转发已知外部符号，或让下一轮 compile/repair 暴露缺失 contract，而不是在本文件塞占位实现。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 placeholder 时，严禁顺手引入 `Signal<T>()`、`ValueSignal<T>(...)`、`SignalPipe(...)`、invented collaborator、`MessagesGetHistory` 或 `getMTProtoClient()`。"
        )
    elif rule_id == "static-invented-reactive-shell":
        issue_code = "ARCH_DEPENDENCY_CONSTRAINT_VIOLATION"
        required_dimension = "Dependency Constraint"
        message = (
            f"系统静态扫描发现 invented reactive provider/facade/shell {matched_text!r}"
            f"（第 {line} 行，第 {column} 列）。该符号不在 source imports、TU dependency closure 或 explicit staged contract allowlist 中。"
        )
        repair_hint = (
            "系统静态扫描发现 invented reactive provider/facade/shell {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "如果当前 source imports、TU dependency closure、explicit staged contract allowlist 里没有真实 reactive provider/facade/shell 符号，就不能在 service 文件里凭空发明新的 `*SignalProvider`、`*ReactiveFacade`、`*ReactiveShell`。\n"
            "[ESCAPE HATCH FOR invented reactive shell]\n"
            "物理删除当前 invented reactive shell。只允许复用当前 TU 已知真实符号，或让 public method 直接转发外部 contract；不要为了满足 `Signal<Array<Message>>` 返回而新增 private/local reactive provider 壳。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 invented reactive shell 时，严禁顺手引入 `throw TODO`、`Signal<T>()`、`ValueSignal<T>(...)`、`SignalPipe(...)`、`MessageBackend` 或 `ServiceLocator`。"
        )
    else:
        issue_code = "ARCH_EXECUTION_TOPOLOGY_VIOLATION"
        required_dimension = "Execution Topology"
        message = (
            f"系统静态扫描发现 service-local reactive materialization {matched_text!r}"
            f"（第 {line} 行，第 {column} 列）。当前 service 文件不得构造或占位返回 reactive runtime。"
        )
        repair_hint = (
            "系统静态扫描发现 service-local reactive materialization {match}。\n"
            "[CRITICAL WARNING: DO NOT LIE TO THE SCANNER]\n"
            "`Signal<T>()` / `ValueSignal<T>(...)` / bare reactive constructor return 都属于 service-local reactive runtime materialization。当前 target 只允许在匹配的 public signature 上保留 reactive contract token，绝不允许在实现体内把它重新构造出来。\n"
            "[ESCAPE HATCH FOR reactive materialization]\n"
            "物理删除当前 `Signal` / `ValueSignal` 构造或 placeholder return。保留 `getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>>` 的 exact public contract，但让 public method 只从 source imports、TU dependency closure、explicit staged contract allowlist 中已知真实符号获取或转发 reactive object。若当前上下文没有真实 reactive provider，就不要 invent 新 provider/facade/shell/locator。\n"
            "[ANTI-OSCILLATION ANCHOR]\n"
            "修 reactive materialization 时，严禁顺手引入 `throw TODO`、`SignalPipe(...)`、`MessagesGetHistory`、`MessagesSendMessage`、`getMTProtoClient()`、`MessageBackend` 或 `ServiceLocator`。"
        )

    return StaticViolation(
        rule_id=rule_id,
        issue_code=issue_code,
        required_dimension=required_dimension,
        severity="blocker",
        message=message,
        matched_text=matched_text,
        line=line,
        column=column,
        line_text=line_text.rstrip(),
        repair_hint=repair_hint.format(match=repr(matched_text)),
    )


def strip_comments_preserve_layout(source: str) -> str:
    result: List[str] = []
    index = 0
    length = len(source)
    in_line_comment = False
    in_block_comment = False
    in_string: str | None = None
    escape = False

    while index < length:
        char = source[index]
        next_char = source[index + 1] if index + 1 < length else ""

        if in_line_comment:
            if char == "\n":
                in_line_comment = False
                result.append(char)
            else:
                result.append(" ")
            index += 1
            continue

        if in_block_comment:
            if char == "*" and next_char == "/":
                result.append(" ")
                result.append(" ")
                in_block_comment = False
                index += 2
                continue
            result.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if in_string is not None:
            result.append(char)
            if escape:
                escape = False
            elif char == "\\":
                escape = True
            elif char == in_string:
                in_string = None
            index += 1
            continue

        if char in {'"', "'", '`'}:
            in_string = char
            result.append(char)
            index += 1
            continue

        if char == "/" and next_char == "/":
            result.append(" ")
            result.append(" ")
            in_line_comment = True
            index += 2
            continue

        if char == "/" and next_char == "*":
            result.append(" ")
            result.append(" ")
            in_block_comment = True
            index += 2
            continue

        result.append(char)
        index += 1

    return "".join(result)


def mask_string_literal_contents_preserve_layout(source: str) -> str:
    result: List[str] = []
    index = 0
    length = len(source)
    in_string: str | None = None
    escape = False

    while index < length:
        char = source[index]

        if in_string is not None:
            if escape:
                result.append("\n" if char == "\n" else " ")
                escape = False
            elif char == "\\":
                result.append(" ")
                escape = True
            elif char == in_string:
                result.append(char)
                in_string = None
            else:
                result.append("\n" if char == "\n" else " ")
            index += 1
            continue

        if char in {'"', "'", '`'}:
            in_string = char
            result.append(char)
            index += 1
            continue

        result.append(char)
        index += 1

    return "".join(result)


class StaticBlacklistChecker:
    def __init__(self, rules: Sequence[StaticRule] | None = None, *, max_total_hits: int = 24, max_hits_per_rule: int = 6) -> None:
        self.rules = list(rules or DEFAULT_RULES)
        self.max_total_hits = max_total_hits
        self.max_hits_per_rule = max_hits_per_rule

    def check(self, code: str, *, tu: Dict[str, object] | None = None) -> StaticCheckResult:
        sanitized_code = strip_comments_preserve_layout(code)
        string_masked_sanitized_code = mask_string_literal_contents_preserve_layout(sanitized_code)
        source_lines = code.splitlines()
        sanitized_lines = sanitized_code.splitlines()
        string_masked_sanitized_lines = string_masked_sanitized_code.splitlines()
        violations: List[StaticViolation] = []
        per_rule_counts: Dict[str, int] = {}
        seen: set[tuple[str, int, int, str]] = set()

        for line_number, sanitized_line_text in enumerate(sanitized_lines, start=1):
            original_line_text = source_lines[line_number - 1] if line_number - 1 < len(source_lines) else sanitized_line_text
            for rule in self.rules:
                if self._should_skip_rule(rule, tu):
                    continue
                if per_rule_counts.get(rule.rule_id, 0) >= self.max_hits_per_rule:
                    continue
                scan_line_text = sanitized_line_text
                if rule.rule_id == "static-double-bang" and line_number - 1 < len(string_masked_sanitized_lines):
                    scan_line_text = string_masked_sanitized_lines[line_number - 1]
                for match in rule.pattern.finditer(scan_line_text):
                    if self._should_skip_phase06_ui_exception_match(
                        rule,
                        match.group(0),
                        original_line_text,
                        tu,
                    ):
                        continue
                    if self._should_skip_source_aligned_public_contract_match(
                        rule,
                        match.group(0),
                        original_line_text,
                        tu,
                    ):
                        continue
                    key = (rule.rule_id, line_number, match.start(), match.group(0))
                    if key in seen:
                        continue
                    seen.add(key)
                    per_rule_counts[rule.rule_id] = per_rule_counts.get(rule.rule_id, 0) + 1
                    violations.append(
                        StaticViolation(
                            rule_id=rule.rule_id,
                            issue_code=rule.issue_code,
                            required_dimension=rule.required_dimension,
                            severity=rule.severity,
                            message=self._build_message(rule, match.group(0), line_number, match.start() + 1, tu),
                            matched_text=match.group(0),
                            line=line_number,
                            column=match.start() + 1,
                            line_text=original_line_text.rstrip(),
                            repair_hint=_format_rule_repair_hint(rule, match.group(0), tu),
                        )
                    )
                    if len(violations) >= self.max_total_hits:
                        return StaticCheckResult(
                            passed=False,
                            violations=violations,
                            scanned_line_count=len(sanitized_lines),
                            rule_count=len(self.rules),
                        )
        if len(violations) < self.max_total_hits:
            ui_public_drift_violations = self._collect_ui_public_surface_drift_violations(
                sanitized_lines=sanitized_lines,
                source_lines=source_lines,
                tu=tu,
            )
            for item in ui_public_drift_violations:
                violations.append(item)
                if len(violations) >= self.max_total_hits:
                    break
        custom_violations = self._collect_invented_service_collaborator_violations(
            sanitized_lines=sanitized_lines,
            source_lines=source_lines,
            tu=tu,
        )
        for item in custom_violations:
            violations.append(item)
            if len(violations) >= self.max_total_hits:
                break
        if len(violations) < self.max_total_hits:
            reactive_violations = self._collect_service_reactive_contract_violations(
                sanitized_lines=sanitized_lines,
                source_lines=source_lines,
                tu=tu,
            )
            for item in reactive_violations:
                violations.append(item)
                if len(violations) >= self.max_total_hits:
                    break
        if len(violations) < self.max_total_hits:
            signature_violations = self._collect_service_public_contract_drift_violations(
                sanitized_code=sanitized_code,
                source_lines=source_lines,
                tu=tu,
            )
            for item in signature_violations:
                violations.append(item)
                if len(violations) >= self.max_total_hits:
                    break
        if len(violations) < self.max_total_hits:
            hashmap_violations = self._collect_service_hashmap_put_violations(
                sanitized_lines=sanitized_lines,
                source_lines=source_lines,
                tu=tu,
            )
            for item in hashmap_violations:
                violations.append(item)
                if len(violations) >= self.max_total_hits:
                    break
        return StaticCheckResult(
            passed=not violations,
            violations=violations,
            scanned_line_count=len(sanitized_lines),
            rule_count=len(self.rules),
        )

    @staticmethod
    def _should_skip_phase06_ui_exception_match(
        rule: StaticRule,
        matched_text: str,
        line_text: str,
        tu: Dict[str, object] | None,
    ) -> bool:
        if _has_phase06_ui_exception_tag(tu, "ffi-exception"):
            # FFI rail still blocks std.unsafe imports; only local unsafe blocks are exempted.
            if rule.rule_id == "static-unsafe-keyword" and matched_text == "unsafe":
                return True

        if _has_phase06_ui_exception_tag(tu, "hybrid-exception"):
            if rule.rule_id in {"static-import-ohos-package", "static-ohos-path-anywhere"}:
                path = _extract_ohos_path_from_match(matched_text, line_text)
                return _is_allowed_hybrid_exception_ohos_path(path)

        return False

    @staticmethod
    def _should_skip_rule(rule: StaticRule, tu: Dict[str, object] | None) -> bool:
        if not isinstance(tu, dict):
            return False
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        risk_tags = [str(item) for item in target.get("risk_tags", [])] if isinstance(target.get("risk_tags"), list) else []
        if not role:
            return False
        service_only_rule_ids = {
            "static-tl-protocol-types",
            "static-generic-tl-container-pollution",
            "static-parameter-tl-type-pollution",
            "static-arrow-tl-return-pollution",
            "static-input-peer-leak",
            "static-create-input-peer",
            "static-tl-serialization-in-service",
            "static-protocol-stub-class",
            "static-send-request-in-service",
            "static-binary-buffer-in-service",
            "static-to-bytes-call",
            "static-service-request-type-leak",
            "static-service-mtprotoclient-accessor-leak",
            "static-service-zero-block-match-arm",
            "static-service-option-none-compare",
        }
        if rule.rule_id in service_only_rule_ids:
            return role != "service"
        return False

    @staticmethod
    def _should_skip_source_aligned_public_contract_match(
        rule: StaticRule,
        matched_text: str,
        line_text: str,
        tu: Dict[str, object] | None,
    ) -> bool:
        if not isinstance(tu, dict):
            return False
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        stripped_line = line_text.strip()
        if role in UI_TARGET_ROLES:
            if rule.rule_id == "static-arraylist-hallucination" and "ArrayList" in stripped_line:
                semantic_key = _extract_ui_arraylist_semantic_key(stripped_line)
                if semantic_key:
                    if semantic_key in _collect_ui_source_arraylist_semantic_keys(tu):
                        return True
                function_key = _extract_ui_func_signature_key(stripped_line)
                if function_key:
                    if function_key in _collect_ui_source_arraylist_function_keys(tu):
                        return True
                normalized_usage_line = _normalize_ui_arraylist_usage_line(stripped_line)
                if normalized_usage_line in _collect_ui_source_arraylist_usage_lines(tu):
                    return True
                return _normalize_line_for_compare(stripped_line) in _collect_ui_source_normalized_lines(tu)
            if rule.rule_id in {"static-import-ohos-package", "static-ohos-path-anywhere"}:
                import_path = _extract_ohos_import_path(stripped_line)
                if import_path:
                    return import_path in _collect_ui_source_ohos_imports(tu)
            return False
        if role != "service":
            return False
        if rule.rule_id == "static-shadow-signal-flow" and _is_service_reactive_runtime_line(stripped_line):
            return True
        if not re.match(r"public\s+func\b", stripped_line):
            return False

        signatures = target.get("signatures", []) if isinstance(target.get("signatures"), list) else []
        signature_texts = [
            str(item.get("signature", ""))
            for item in signatures
            if isinstance(item, dict) and item.get("signature")
        ]
        allowed_tl_types = {
            token
            for text in signature_texts
            for token in re.findall(r"\bTL[A-Z]\w*\b", text)
        }
        allowed_reactive_tokens = {
            token
            for text in signature_texts
            for token in re.findall(r"\b(?:Signal|ValueSignal|Observable)\b", text)
        }

        if rule.rule_id in {
            "static-tl-protocol-types",
            "static-generic-tl-container-pollution",
            "static-parameter-tl-type-pollution",
            "static-arrow-tl-return-pollution",
        }:
            matched_tl_types = set(re.findall(r"\bTL[A-Z]\w*\b", matched_text))
            return bool(matched_tl_types & allowed_tl_types)

        if rule.rule_id == "static-shadow-signal-flow":
            matched_reactive_tokens = set(re.findall(r"\b(?:Signal|ValueSignal|Observable)\b", matched_text))
            return bool(matched_reactive_tokens & allowed_reactive_tokens)

        return False

    @staticmethod
    def _collect_ui_public_surface_drift_violations(
        *,
        sanitized_lines: Sequence[str],
        source_lines: Sequence[str],
        tu: Dict[str, object] | None,
    ) -> List[StaticViolation]:
        if not isinstance(tu, dict):
            return []
        role = _target_role(tu)
        if role not in UI_TARGET_ROLES:
            return []
        source_visibility_map = _collect_ui_source_field_visibility_map(tu)
        if not source_visibility_map:
            return []

        violations: List[StaticViolation] = []
        seen: set[tuple[int, str]] = set()
        for line_number, sanitized_line_text in enumerate(sanitized_lines, start=1):
            stripped_line = sanitized_line_text.strip()
            if not stripped_line.startswith("public "):
                continue
            match = UI_FIELD_DECL_PATTERN.match(stripped_line)
            if not match or match.group("visibility") != "public":
                continue
            semantic_key = _extract_ui_field_semantic_key(stripped_line)
            if not semantic_key:
                continue
            source_is_public = source_visibility_map.get(semantic_key)
            if source_is_public is None or source_is_public:
                continue
            original_line_text = source_lines[line_number - 1] if line_number - 1 < len(source_lines) else sanitized_line_text
            key = (line_number, semantic_key)
            if key in seen:
                continue
            seen.add(key)
            violations.append(
                _make_ui_public_surface_drift_violation(
                    matched_text=stripped_line,
                    line=line_number,
                    column=sanitized_line_text.index("public") + 1,
                    line_text=original_line_text,
                )
            )
        return violations

    @staticmethod
    def _collect_invented_service_collaborator_violations(
        *,
        sanitized_lines: Sequence[str],
        source_lines: Sequence[str],
        tu: Dict[str, object] | None,
    ) -> List[StaticViolation]:
        if not isinstance(tu, dict):
            return []
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        if role != "service":
            return []
        allowed = _collect_service_collaborator_allowlist(tu)
        violations: List[StaticViolation] = []
        seen: set[tuple[str, int, str]] = set()
        for line_number, sanitized_line_text in enumerate(sanitized_lines, start=1):
            original_line_text = source_lines[line_number - 1] if line_number - 1 < len(source_lines) else sanitized_line_text
            stripped_line = sanitized_line_text.strip()
            if not stripped_line:
                continue
            for pattern, rule_id in (
                (SERVICE_INVENTED_COLLABORATOR_TYPE_PATTERN, "static-invented-collaborator-type"),
                (SERVICE_INVENTED_COLLABORATOR_CTOR_PATTERN, "static-invented-collaborator-type"),
                (SERVICE_INVENTED_COLLABORATOR_DECL_PATTERN, "static-invented-collaborator-type"),
            ):
                for match in pattern.finditer(sanitized_line_text):
                    symbol = match.group(1)
                    if symbol in allowed:
                        continue
                    key = (rule_id, line_number, symbol)
                    if key in seen:
                        continue
                    seen.add(key)
                    violations.append(
                        _make_invented_service_collaborator_violation(
                            rule_id=rule_id,
                            matched_text=symbol,
                            line=line_number,
                            column=match.start(1) + 1,
                            line_text=original_line_text,
                        )
                    )
            for match in SERVICE_INVENTED_COLLABORATOR_LOCATOR_PATTERN.finditer(sanitized_line_text):
                symbol = match.group(1)
                if symbol in allowed:
                    continue
                key = ("static-invented-collaborator-locator", line_number, symbol)
                if key in seen:
                    continue
                seen.add(key)
                violations.append(
                    _make_invented_service_collaborator_violation(
                        rule_id="static-invented-collaborator-locator",
                        matched_text=symbol,
                        line=line_number,
                        column=match.start(1) + 1,
                        line_text=original_line_text,
                    )
                    )
        return violations

    @staticmethod
    def _collect_service_reactive_contract_violations(
        *,
        sanitized_lines: Sequence[str],
        source_lines: Sequence[str],
        tu: Dict[str, object] | None,
    ) -> List[StaticViolation]:
        if not isinstance(tu, dict):
            return []
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        if role != "service":
            return []

        allowed = _collect_service_collaborator_allowlist(tu)
        violations: List[StaticViolation] = []
        seen: set[tuple[str, int, str]] = set()

        for line_number, sanitized_line_text in enumerate(sanitized_lines, start=1):
            original_line_text = source_lines[line_number - 1] if line_number - 1 < len(source_lines) else sanitized_line_text
            stripped_line = sanitized_line_text.strip()
            if not stripped_line:
                continue

            for pattern, rule_id in (
                (SERVICE_REACTIVE_RUNTIME_OWNERSHIP_PATTERN, "static-service-reactive-ownership"),
                (SERVICE_REACTIVE_HELPER_RETURN_PATTERN, "static-service-reactive-ownership"),
                (SERVICE_REACTIVE_MATERIALIZATION_PATTERN, "static-service-reactive-materialization"),
            ):
                if rule_id == "static-service-reactive-materialization" and re.match(r"public\s+func\b", stripped_line):
                    continue
                for match in pattern.finditer(sanitized_line_text):
                    matched_text = match.group(1)
                    key = (rule_id, line_number, matched_text)
                    if key in seen:
                        continue
                    seen.add(key)
                    violations.append(
                        _make_service_reactive_violation(
                            rule_id=rule_id,
                            matched_text=matched_text,
                            line=line_number,
                            column=match.start(1) + 1,
                            line_text=original_line_text,
                        )
                    )

            for match in SERVICE_REACTIVE_TODO_PATTERN.finditer(sanitized_line_text):
                matched_text = match.group(0)
                key = ("static-service-reactive-placeholder", line_number, matched_text)
                if key in seen:
                    continue
                seen.add(key)
                violations.append(
                    _make_service_reactive_violation(
                        rule_id="static-service-reactive-placeholder",
                        matched_text=matched_text,
                        line=line_number,
                        column=match.start() + 1,
                        line_text=original_line_text,
                    )
                )

            for match in SERVICE_INVENTED_REACTIVE_SHELL_PATTERN.finditer(sanitized_line_text):
                symbol = match.group(1)
                if symbol in allowed:
                    continue
                key = ("static-invented-reactive-shell", line_number, symbol)
                if key in seen:
                    continue
                seen.add(key)
                violations.append(
                    _make_service_reactive_violation(
                        rule_id="static-invented-reactive-shell",
                        matched_text=symbol,
                        line=line_number,
                        column=match.start(1) + 1,
                        line_text=original_line_text,
                    )
                )

        return violations

    @staticmethod
    def _collect_service_public_contract_drift_violations(
        *,
        sanitized_code: str,
        source_lines: Sequence[str],
        tu: Dict[str, object] | None,
    ) -> List[StaticViolation]:
        if not isinstance(tu, dict):
            return []
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        target_path = str(target.get("path", "")).strip()
        role = str(target.get("role", "")).strip().lower()
        if role != "service" or not target_path:
            return []
        oracle_map = resolve_explicit_staged_contract_public_method_oracle_map(target_path=target_path)
        if not oracle_map:
            return []

        violations: List[StaticViolation] = []
        actual_signatures: Dict[str, str] = {}
        for match in SERVICE_PUBLIC_FUNC_PATTERN.finditer(sanitized_code):
            method_name = match.group("name").strip()
            actual_signature = _normalize_public_method_signature(
                method_name,
                match.group("params"),
                match.group("return"),
            )
            actual_signatures[method_name] = actual_signature
            expected_signature = oracle_map.get(method_name)
            if expected_signature is None:
                continue
            if actual_signature == expected_signature:
                continue
            line = sanitized_code.count("\n", 0, match.start()) + 1
            line_text = source_lines[line - 1] if line - 1 < len(source_lines) else ""
            violations.append(
                _make_service_public_contract_drift_violation(
                    method_name=method_name,
                    matched_text=actual_signature,
                    expected_signature=expected_signature,
                    line=line,
                    column=match.start() - sanitized_code.rfind("\n", 0, match.start()),
                    line_text=line_text,
                )
            )
        return violations

    @staticmethod
    def _collect_service_hashmap_put_violations(
        *,
        sanitized_lines: Sequence[str],
        source_lines: Sequence[str],
        tu: Dict[str, object] | None,
    ) -> List[StaticViolation]:
        if not isinstance(tu, dict):
            return []
        target = tu.get("target", {}) if isinstance(tu.get("target"), dict) else {}
        role = str(target.get("role", "")).strip().lower()
        if role != "service":
            return []

        hashmap_symbols: set[str] = set()
        for line_text in sanitized_lines:
            for match in SERVICE_HASHMAP_DECL_PATTERN.finditer(line_text):
                hashmap_symbols.add(match.group(1))
        if not hashmap_symbols:
            return []

        violations: List[StaticViolation] = []
        seen: set[tuple[int, str]] = set()
        for line_number, sanitized_line_text in enumerate(sanitized_lines, start=1):
            original_line_text = source_lines[line_number - 1] if line_number - 1 < len(source_lines) else sanitized_line_text
            if not sanitized_line_text.strip():
                continue
            for symbol in sorted(hashmap_symbols):
                pattern = re.compile(rf"\b(?:this\.)?{re.escape(symbol)}\.put\s*\(")
                for match in pattern.finditer(sanitized_line_text):
                    key = (line_number, symbol)
                    if key in seen:
                        continue
                    seen.add(key)
                    violations.append(
                        _make_service_hashmap_put_violation(
                            matched_text=match.group(0),
                            line=line_number,
                            column=match.start() + 1,
                            line_text=original_line_text,
                        )
                    )
        return violations

    @staticmethod
    def _build_message(rule: StaticRule, matched_text: str, line: int, column: int, tu: Dict[str, object] | None = None) -> str:
        return (
            f"系统静态扫描发现致命违规词汇 {matched_text!r}（第 {line} 行，第 {column} 列）。"
            f"{rule.description} 请彻底将其从{_target_scope_label(tu)}抹除！"
        )


def format_static_evidence(violations: Sequence[StaticViolation]) -> List[str]:
    evidence: List[str] = []
    for item in violations:
        evidence.append(
            f"[{item.rule_id}] line {item.line}, col {item.column}, match={item.matched_text!r}, code={item.issue_code}, snippet={item.line_text.strip()}"
        )
    return evidence


def format_static_stderr(violations: Sequence[StaticViolation]) -> str:
    lines = ["static blacklist firewall blocked candidate before reviewer/compiler:"]
    for item in violations:
        lines.append(
            f"- {item.message} | snippet: {item.line_text.strip()} | repair: {item.repair_hint}"
        )
    return "\n".join(lines)


if __name__ == "__main__":
    import argparse
    from pathlib import Path

    parser = argparse.ArgumentParser(description="静态黑名单拦截器")
    parser.add_argument("file", type=Path)
    args = parser.parse_args()
    text = args.file.read_text(encoding="utf-8")
    result = StaticBlacklistChecker().check(text)
    print(json.dumps(result.to_dict(), ensure_ascii=False, indent=2))
