# Skill Metadata
- Skill ID: `CJ-INIT-ARRAY-TIME-SYNTAX-001-V1`
- Skill Name: `cangjie-init-array-time-syntax-v1`
- Skill Class: `Architecture`
- Scope: 专门修复真实 `cjc` 中与 `constructor`、`Array.append`、`Array + [item]`、`DateTime.now().toMilliseconds()` / `.milliSeconds` 相关的深层语法与 API 幻觉，目标是把候选从“接近 compile pass”推进到真正的 compile-safe 服务骨架。
- Tags: `cangjie`, `init`, `constructor`, `array`, `datetime`, `compile`, `api`, `syntax`
- Version: `V1`

# Trigger Condition
- 真实 `cjc` / review evidence 中出现以下任一项时必须触发：
  - `expected declaration, found 'constructor'`
  - `'append' is not a member of struct 'Array<...>'`
  - `invalid binary operator '+' on type 'Array<...>'`
  - `'toMilliseconds' is not a member of struct 'DateTime'`
  - `'milliSeconds' is not a member of struct 'DateTime'`
- 当候选已经通过静态墙，但仍卡在这些基础语法/API 细节时，应把本 Skill 放入高优先级队列。

# Core Concept
- 当前不是架构大方向错了，而是模型把 ArkTS / Java / 伪集合 API 幻觉带进了仓颉代码。
- 这些点必须用真实 `cjc` 口径硬纠正：
  1. **仓颉类初始化用 `init`，不是 `constructor`**；
  2. **`Array<T>` 没有 `.append(...)`**；
  3. **`Array<T>` 不能用 `+ [item]` 追加**；
  4. **`DateTime.now()` 没有 `.toMilliseconds()` 或 `.milliSeconds`**。
- 如果你不确定某个 API 是否存在：
  - 优先回到已物理验证的最小模板；
  - 不要臆造成员名。

# Syntax Iron Laws
- **铁律 1：类初始化必须写 `init`**
  - 正确：
    ```text
    public init(adapter: IMTProtoAdapter) {
        this.adapter = adapter
    }
    ```
  - 错误：
    ```text
    public constructor(adapter: IMTProtoAdapter) {
        this.adapter = adapter
    }
    ```

- **铁律 2：`Array<T>` 不支持 `.append(...)`**
  - 严禁：`existing.append(message)`
  - 严禁：`result.add(item)` 当 `result` 是 `Array<T>`

- **铁律 3：`Array<T>` 不支持 `existing + [item]`**
  - 严禁：`existing + [message]`
  - 严禁：`[...existing, message]`
  - 如果需要追加元素，使用“重建数组”模板。

- **铁律 4：`DateTime.now()` 不支持毫秒成员幻觉**
  - 严禁：`DateTime.now().toMilliseconds()`
  - 严禁：`DateTime.now().milliSeconds`
  - 如果确实需要一个 compile-safe 的局部时间数值：
    - 可以用 `Int64(DateTime.now().nanosecond)`
    - 但更推荐把随机 ID / 时间戳生成下沉到 Adapter 或调用方，而不是在 Service 里现编。

# Physically Verified Local Facts
以下结论已通过本地真实 `cjc --output-type staticlib` 验证：
- `public init(...)`：**可编译**
- `public constructor(...)`：**报错** `expected declaration, found 'constructor'`
- `items.append(item)`：**报错** `'append' is not a member of struct 'Array<...>'`
- `items + [item]`：**报错** `invalid binary operator '+'`
- `Int64(DateTime.now().nanosecond)`：**可编译**

# Compile-Safe Array Append Pattern
如果必须把 `message` 追加到 `existing: Array<DomainMessage>`，当前 compile-safe 模板是：

```text
private func appendMessage(existing: Array<DomainMessage>, message: DomainMessage): Array<DomainMessage> {
    Array<DomainMessage>(existing.size + 1, { index: Int64 =>
        match (index == existing.size) {
            case true => message
            case _ => existing[index]
        }
    })
}
```

这是当前本地已物理验证通过的追加模板。

# RealMessageService-Safe Pattern
```text
open class RealMessageService {
    private let messageCache = HashMap<String, Array<DomainMessage>>()
    private let adapter: IMTProtoAdapter

    public init(adapter: IMTProtoAdapter) {
        this.adapter = adapter
    }

    private func appendMessage(existing: Array<DomainMessage>, message: DomainMessage): Array<DomainMessage> {
        Array<DomainMessage>(existing.size + 1, { index: Int64 =>
            match (index == existing.size) {
                case true => message
                case _ => existing[index]
            }
        })
    }

    private func appendMessageToCache(key: String, message: DomainMessage): Unit {
        match (this.messageCache.get(key)) {
            case Some(existing) => this.messageCache.add(key, this.appendMessage(existing, message))
            case _ => this.messageCache.add(key, [message])
        }
    }
}
```

# Preferred Time Fallback
如果当前 Service 还在本地硬造 `randomId` / 时间戳，请优先改成：
- **首选**：交给 `adapter.sendMessage(...)` 返回真正的 `DomainMessage`
- **次选**：若只是为了 compile-safe 占位，可使用：
  ```text
  Int64(DateTime.now().nanosecond)
  ```
- **禁止**：
  ```text
  DateTime.now().toMilliseconds()
  DateTime.now().milliSeconds
  ```

# Repair Checklist
- 看到 `constructor`：统一替换为 `init`
- 看到 `Array.append`：立即改为显式 helper 重建数组
- 看到 `existing + [message]`：立即改为 `Array<T>(size + 1, lambda)` 模板
- 看到 `DateTime.now().toMilliseconds()` / `.milliSeconds`：
  - 优先删掉本地时间戳生成；
  - 必要时改成 `Int64(DateTime.now().nanosecond)`
- 如果 `match` 分支里同时出现数组重建：
  - 保持 `case` 分支单表达式；
  - 复杂数组逻辑提到 helper。

# Hard Verdict
只要候选中还出现以下任一项，就说明这一层还没修穿：
- `constructor(`
- `.append(` 且左值是 `Array<...>`
- `+ [message]`
- `[...existing, message]`
- `.toMilliseconds()`
- `.milliSeconds`

# Sources
- 来源列表：
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-029-round30-regression-firewall/RealMessageService.orchestration.json`
  - `artifacts/tmp_round31_probe/constructor_ok.cj`
  - `artifacts/tmp_round31_probe/constructor_bad.cj`
  - `artifacts/tmp_round31_array_probe/probe3.cj`
  - `artifacts/tmp_round31_time_probe/time_ok.cj`
  - `artifacts/tmp_round31_service_probe/service_probe.cj`

# Evolution Log
- 版本演进记录：
  - `[2026-03-30] [V1.0-initial] 基于 Round 30 的真实编译错误与本地 cjc 微实验，新增 init / Array / DateTime 专项 Skill，目标是把候选进一步推进到 compile-safe 服务骨架。`
