# Option Admission Skill

- intake_mode: `kernel-admission-mvp`
- source_markdown: `research/external-baselines/CangjieTransSkills/option/README.md`
- intake_time: `2026-03-27T15:34:27Z`
- source_manifest: `artifacts/knowledge_admission/source-manifest.jsonl`
- admission_index: `artifacts/knowledge_admission/admission-index.json`
- runs_root: `artifacts/knowledge_admission/runs/option`
- counts: `{"ADMITTED_CONTEXT_ONLY": 4, "ADMITTED_VERIFIED": 11}`
- routing_rule: `L3 真实证据 > L2 项目约束 > L1 一般知识`

## Core Definitions

- `Option<T>` 表示仓颉中的可选值容器。
- `?T` 是 `Option<T>` 的简写。
- `Some(v)` 表示有值，`None` 表示无值。
- `??` 用于提供默认值；`match` / `if-let` / `while-let` 用于解构可选值。
- 当 L1 文档与当前编译器行为冲突时，以本轮 admission 的 L3 证据为准。

## Verified Snippets

### `snippet-001` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `wrappable`
- heading_context: `仓颉语言 Option 类型 / 1. 定义`
- source_lines: `6-9`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-001/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
enum Option<T> {
    | Some(T)
    | None
}
```

### `snippet-005` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 5. 解构方式 / 5.1 模式匹配（match）`
- source_lines: `53-63`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-005/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
func getString(p: ?Int64): String {
    match (p) {
        case Some(x) => "${x}"
        case None => "none"
    }
}

main() {
    println(getString(Some(1)))       // "1"
    println(getString(None<Int64>))   // "none"
}
```

### `snippet-006` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 5. 解构方式 / 5.2 coalescing 操作符 `??``
- source_lines: `70-76`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-006/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
main() {
    let a = Some(1)
    let b: ?Int64 = None
    let r1: Int64 = a ?? 0   // 1
    let r2: Int64 = b ?? 0   // 0
    println("${r1}, ${r2}")   // "1, 0"
}
```

### `snippet-007` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 5. 解构方式 / 5.3 问号操作符 `?.``
- source_lines: `86-98`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-007/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
struct R {
    public var a: Int64
    public init(a: Int64) {
        this.a = a
    }
}

main() {
    let x = Some(R(100))
    let y: ?R = None
    let r1 = x?.a   // Some(100)
    let r2 = y?.a   // None
}
```

### `snippet-008` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 5. 解构方式 / 5.3 问号操作符 `?.``
- source_lines: `103-116`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-008/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
class A {
    public var b: B = B()
}
class B {
    public var c: ?C = C()
}
class C {
    public var d: Int64 = 100
}

main() {
    let a = Some(A())
    let r1 = a?.b.c?.d   // Some(100)
}
```

### `snippet-009` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 5. 解构方式 / 5.4 `getOrThrow()``
- source_lines: `123-133`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-009/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
main() {
    let a = Some(1)
    let r1 = a.getOrThrow()   // 1

    let b: ?Int64 = None
    try {
        let r2 = b.getOrThrow()
    } catch (e: NoneValueException) {
        println("b is None")   // 输出: b is None
    }
}
```

### `snippet-010` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 6. if-let 条件解构 / 6.1 基本用法`
- source_lines: `145-153`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-010/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
main() {
    let opt: ?Int64 = 42
    // print 42
    if (let Some(v) <- opt) {
        println(v)
    } else {
        println("invalid")
    }
}
```

### `snippet-011` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 6. if-let 条件解构 / 6.2 多条件组合（`&&`）`
- source_lines: `160-173`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-011/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
main() {
    let a = Some(3)
    let d = Some(1)

    // 两个 let 模式同时匹配
    if (let Some(e) <- a && let Some(f) <- d) {
        println("${e} ${f}")   // 输出: 3 1
    }

    // let 模式 + 布尔条件
    if (let Some(f) <- d && f > 0) {
        println(f)   // 输出: 1
    }
}
```

### `snippet-012` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 6. if-let 条件解构 / 6.3 或条件（`||`）`
- source_lines: `180-187`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-012/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
main() {
    let a: ?Int64 = Some(3)
    let d: ?Int64 = None

    if (let Some(_) <- a || let Some(_) <- d) {
        println("至少一个有值")
    }
}
```

### `snippet-013` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 7. while-let 循环解构`
- source_lines: `197-203`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-013/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
main() {
    let list = [1, 2, 3]
    var it = list.iterator()
    while (let Some(i) <- it.next()) {
        println(i) // 逐行输出 1 2 3
    }
}
```

### `snippet-015` [L3-VERIFIED]
- status: `ADMITTED_VERIFIED`
- shape: `standalone`
- heading_context: `仓颉语言 Option 类型 / 9. 完整可运行示例`
- source_lines: `236-287`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-015/verify_result.json`
- note: 已通过真实 compile 体检；unit-test / behavior 保持 dry-run
```cangjie
func findUser(id: Int64): ?String {
    if (id == 1) {
        "Alice"       // 自动包装为 Some("Alice")
    } else {
        None
    }
}

func findAge(name: String): ?Int64 {
    if (name == "Alice") {
        30
    } else {
        None
    }
}

main() {
    // ?? 提供默认值
    let name = findUser(1) ?? "unknown"
    println("name = ${name}")   // name = Alice

    // if-let 条件解构
    if (let Some(user) <- findUser(1)) {
        println("找到用户: ${user}")   // 找到用户: Alice
    }

    // if-let + && 组合
    if (let Some(user) <- findUser(1) && let Some(age) <- findAge(user)) {
        println("${user} 年龄 ${age}")   // Alice 年龄 30
    }

    // while-let 遍历
    let ids = [1, 2, 3]
    var it = ids.iterator()
    while (let Some(id) <- it.next()) {
        let display = findUser(id) ?? "未知用户"
        println("id=${id}: ${display}")
    }
    // id=1: Alice
    // id=2: 未知用户
    // id=3: 未知用户

    // match 完整分支
    match (findUser(99)) {
        case Some(u) => println(u)
        case None => println("用户不存在")   // 用户不存在
    }

    // getOrThrow
    let sure = findUser(1).getOrThrow()
    println("sure = ${sure}")   // sure = Alice
}
```

## Context-only Snippets

### `snippet-002` [L3-CONTEXT-ONLY]
- status: `ADMITTED_CONTEXT_ONLY`
- shape: `context-only`
- heading_context: `仓颉语言 Option 类型 / 2. 简写语法 `?T``
- source_lines: `20-21`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-002/admission_result.json`
- note: 该片段是语法/表达式级演示，不构造最小单文件候选程序
```cangjie
let a: ?Int64 = Some(100)     // 等价于 Option<Int64>
let b: ?String = None          // 等价于 Option<String>
```

### `snippet-003` [L3-CONTEXT-ONLY]
- status: `ADMITTED_CONTEXT_ONLY`
- shape: `context-only`
- heading_context: `仓颉语言 Option 类型 / 3. 自动包装`
- source_lines: `30-32`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-003/admission_result.json`
- note: 该片段是语法/表达式级演示，不构造最小单文件候选程序
```cangjie
let a: Option<Int64> = 100     // 自动包装为 Some(100)
let b: ?Int64 = 100            // 同上
let c: Option<String> = "hi"   // 自动包装为 Some("hi")
```

### `snippet-004` [L3-CONTEXT-ONLY]
- status: `ADMITTED_CONTEXT_ONLY`
- shape: `context-only`
- heading_context: `仓颉语言 Option 类型 / 4. 显式 `None<T>``
- source_lines: `41-42`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-004/admission_result.json`
- note: 该片段是语法/表达式级演示，不构造最小单文件候选程序
```cangjie
let a = None<Int64>   // a: Option<Int64>
let b = None<Bool>    // b: Option<Bool>
```

### `snippet-014` [L3-CONTEXT-ONLY]
- status: `ADMITTED_CONTEXT_ONLY`
- shape: `context-only`
- heading_context: `仓颉语言 Option 类型 / 7. while-let 循环解构`
- source_lines: `208-215`
- evidence: `artifacts/knowledge_admission/runs/option/snippet-014/admission_result.json`
- note: 该片段是语法/表达式级演示，不构造最小单文件候选程序
```cangjie
let list = [1, 2, 3]
var it = list.iterator()
while (true) {
    match (it.next()) {
        case Some(i) => println(i)
        case None => break
    }
}
```

## Deprecated / Quarantine

- 当前没有 `[L3-DEPRECATED]` 片段。

## Admission Metadata

- `source-manifest.jsonl`: `artifacts/knowledge_admission/source-manifest.jsonl`
- `admission-index.json`: `artifacts/knowledge_admission/admission-index.json`
- `runs/option`: `artifacts/knowledge_admission/runs/option`
