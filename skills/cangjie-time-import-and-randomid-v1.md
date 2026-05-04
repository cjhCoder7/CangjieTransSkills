# Skill Metadata
- Skill ID: `CJ-TIME-IMPORT-RANDOMID-001-V1`
- Skill Name: `cangjie-time-import-and-randomid-v1`
- Skill Class: `Architecture`
- Scope: 专门修复真实 `cjc` 中由 `DateTime` 未导入、局部 `randomId` 生成和时间 API 误用触发的编译错误，强制执行“使用 `DateTime` 就必须 `import std.time.*`”的时间导入规则。
- Tags: `cangjie`, `std.time`, `DateTime`, `randomId`, `import`, `compile`, `service`
- Version: `V1`

# Trigger Condition
- 真实 `cjc` / repair guidance 中出现以下任一项时必须触发：
  - `undeclared identifier 'DateTime'`
  - `DateTime.now()`
  - `nanosecond`
  - `randomId`
- 候选代码中出现以下坏味道时也必须触发：
  - 在 Service 内部临时生成 `randomId`
  - 使用了 `DateTime`，却没有 `import std.time.*`
  - 时间导入修好了，但保留了不再使用的旧导入，例如 `std.convert.*`

# Core Concept
- `DateTime` 不属于默认作用域；**只要你写了 `DateTime`，就必须显式导入 `std.time.*`。**
- 当前阶段的优先级不是设计一个完美的 ID 系统，而是先拿到 compile-safe 候选：
  1. **首选**：把 `randomId` / 时间戳生成下沉到 Adapter 或调用方；
  2. **次选**：如果本轮为了 compile-safe 必须在本地生成，使用已物理验证通过的最小模板；
  3. **同步清理**：如果删掉了时间逻辑，就把多余导入一起删掉，不要留 `unused import` 噪音。

# 铁血军规
- **军规 1：DateTime Requires Import**
  - 只要候选中出现 `DateTime`，文件顶部必须出现：
    ```text
    import std.time.*
    ```
  - **绝对禁止**：直接写 `DateTime.now()` 却没有时间导入。

- **军规 2：Adapter First**
  - 优先把 `randomId` 生成放到 Adapter / 调用方。
  - 如果 `adapter.sendMessage(...)` 已经接收 `randomId`，Service 只负责传递 compile-safe 值，不要临场发明复杂时间工具。

- **军规 3：Compile-Safe Fallback Only**
  - 当本轮必须在 Service 内生成局部 `randomId` 时，当前已验证的最小生路是：
    ```text
    Int64(DateTime.now().nanosecond)
    ```
  - 不要再臆造 `.toMilliseconds()`、`.milliSeconds` 或其他未验证成员。

- **军规 4：Clean Stale Imports**
  - 如果时间逻辑被移除，就把 `import std.time.*` 一起删掉。
  - 如果 `std.convert.*` 等旧导入已经没用，也要一并清理。

# Compile-Safe Positive Example
```text
import std.collection.*
import std.time.*

open class RealMessageService {
    private let adapter: IMTProtoAdapter

    public init(adapter: IMTProtoAdapter) {
        this.adapter = adapter
    }

    private func nextRandomId(): Int64 {
        Int64(DateTime.now().nanosecond)
    }

    public func sendMessage(peerId: Int64, text: String, accessHash: Int64): DomainMessage {
        let randomId = this.nextRandomId()
        this.adapter.sendMessage(peerId, text, accessHash, randomId)
    }
}
```

# Negative Contrast
- **反面例子：必炸**
  ```text
  import std.collection.*

  let randomId = Int64(DateTime.now().nanosecond)
  ```

- **正面例子：唯一生路**
  ```text
  import std.time.*

  let randomId = Int64(DateTime.now().nanosecond)
  ```

# Repair Checklist
- 全文扫描：
  - `DateTime`
  - `randomId`
  - `nanosecond`
  - `import std.time.*`
- 若发现 `DateTime` 但没导入 `std.time.*`：
  - 立即补导入；
  - 再检查是否仍有 `unused import`。
- 若发现本地生成 `randomId`：
  - 先判断能否下沉到 Adapter / 调用方；
  - 不能下沉时，收敛为 `nextRandomId()` helper，不要把时间逻辑散落在主流程。
- 若时间逻辑已经删除：
  - 删除 stale import，例如 `std.time.*`、`std.convert.*`。

# Hard Verdict
只要候选中还出现以下任一项，就说明这层还没修穿：
- `undeclared identifier 'DateTime'`
- 使用 `DateTime` 却没有 `import std.time.*`
- 继续使用 `.toMilliseconds()` / `.milliSeconds`
- 出现 `unused import 'std.convert.*'` 这类明显陈旧导入

# Sources
- 来源列表：
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-031-round32-match-helper-push/temp_workspace/20260330T053001Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-07/src/services/RealMessageService.cj`
  - `artifacts/tmp_round33_probe/time_bad.cj`
  - `artifacts/tmp_round33_probe/time_ok.cj`
  - `skills/cangjie-init-array-time-syntax-v1.md`

# Evolution Log
- 版本演进记录：
  - `[2026-03-30] [V1.0-initial] 基于 Round 32 的真实 DateTime 编译错误与本地 time probe，新增时间导入 / randomId 专项 Skill，强制 DateTime -> std.time.* 配对并提供 compile-safe fallback。`
