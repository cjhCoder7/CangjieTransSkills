# Skill Metadata
- Skill ID: `CJ-STRUCT-INIT-DOMAIN-MODEL-001-V1`
- Skill Name: `cangjie-struct-init-domain-model-v1`
- Skill Class: `Architecture`
- Scope: 专门修复真实 `cjc` 中由本地简化 `DomainUser` / `DomainChannel` / `DomainMessage` 声明触发的 `uninitialized member variable` 致命错误，强制执行“有 `let` 字段就必须显式 `init`”的领域模型初始化规则。
- Tags: `cangjie`, `struct`, `class`, `init`, `domain model`, `uninitialized member variable`, `compile`, `service`
- Version: `V1`

# Trigger Condition
- 真实 `cjc` / repair guidance 中出现以下任一项时必须触发：
  - `the uninitialized member variable`
  - `is not initialized in the constructor of class or struct`
  - `public struct DomainUser`
  - `public struct DomainChannel`
  - `public struct DomainMessage`
- 候选代码中出现以下坏味道时也必须触发：
  - 本地声明 `public struct Xxx`，其中存在多个 `public let ...` 字段，但没有 `public init(...)`
  - 为了绕过依赖，直接在 Service 文件里临时补领域模型，却忘了初始化所有字段

# Core Concept
- 当前不是“业务逻辑不完整”，而是模型为了尽快编译，临时在 Service 文件里造了一套最小领域模型，却把最基本的构造规则丢了。
- **在仓颉里，只要 `struct` / `class` 上有 `let` 成员，就必须确保构造阶段把它们全部初始化。**
- 这层的目标不是做漂亮设计，而是先把领域模型声明变成 compile-safe：
  1. **优先复用依赖闭包里已经存在的领域类型签名，不重复声明；**
  2. **如果必须本地声明，就给每个 `let` 字段配套显式 `public init(...)`；**
  3. **不要靠“晚点赋值”“空壳 struct”“删字段”糊过去。**

# 铁血军规
- **军规 1：No Naked Let Fields**
  - 只要 `struct` / `class` 中出现 `let` 字段，就必须显式初始化全部字段。
  - **绝对禁止**：
    ```text
    public struct DomainUser {
        public let id: Int64
        public let accessHash: Int64
    }
    ```

- **军规 2：Prefer Reuse Over Redefinition**
  - 如果 TU / 依赖闭包已经给出领域模型签名，优先沿用，不要在 Service 文件重复造一个“简化版”。
  - 只有在当前候选无法引用现成定义、且本轮目的是 compile-safe 骨架时，才允许本地补最小声明。

- **军规 3：Mandatory Explicit Init**
  - 一旦本地声明 `DomainUser` / `DomainChannel` / `DomainMessage`，必须同步写出显式 `public init(...)`。
  - `init` 里必须一一赋值：`this.id = id`、`this.accessHash = accessHash`。

# Compile-Safe Positive Examples
- **正确的 struct 示例**
  ```text
  public struct DomainUser {
      public let id: Int64
      public let accessHash: Int64

      public init(id: Int64, accessHash: Int64) {
          this.id = id
          this.accessHash = accessHash
      }
  }
  ```

- **正确的 class 示例**
  ```text
  public class DomainChannel {
      public let id: Int64
      public let accessHash: Int64

      public init(id: Int64, accessHash: Int64) {
          this.id = id
          this.accessHash = accessHash
      }
  }
  ```

- **RealMessageService 局部 compile-safe 领域模型骨架**
  ```text
  public struct DomainMessage {
      public let id: Int32
      public let text: String
      public let peerId: Int64
      public let flags: Int32
      public let stableVersion: Int32

      public init(id: Int32, text: String, peerId: Int64, flags: Int32, stableVersion: Int32) {
          this.id = id
          this.text = text
          this.peerId = peerId
          this.flags = flags
          this.stableVersion = stableVersion
      }
  }
  ```

# Negative Contrast
- **反面例子：必炸**
  ```text
  public struct DomainMessage {
      public let id: Int32
      public let text: String
      public let peerId: Int64
  }
  ```

- **正面例子：唯一生路**
  ```text
  public struct DomainMessage {
      public let id: Int32
      public let text: String
      public let peerId: Int64

      public init(id: Int32, text: String, peerId: Int64) {
          this.id = id
          this.text = text
          this.peerId = peerId
      }
  }
  ```

# Repair Checklist
- 扫描所有本地声明：
  - `public struct Domain`
  - `public class Domain`
  - `public let`
- 只要发现 `let` 字段：
  - 立刻检查是否存在 `public init(...)`；
  - 不存在就马上补齐；
  - 存在但字段没覆盖全，也视为失败。
- 如果领域模型只是为了让 Service 临时编译：
  - 优先保持字段最小化；
  - 但**不能**通过删到不符合调用签名的程度来规避错误。

# Hard Verdict
只要候选中还出现以下任一项，就说明这层还没修穿：
- `public struct DomainUser {` 且无 `public init(`
- `public struct DomainChannel {` 且无 `public init(`
- `public struct DomainMessage {` 且无 `public init(`
- `the uninitialized member variable`
- `is not initialized in the constructor of class or struct`

# Sources
- 来源列表：
  - `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-031-round32-match-helper-push/temp_workspace/20260330T053001Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-07/src/services/RealMessageService.cj`
  - `artifacts/tmp_round33_probe/struct_bad.cj`
  - `artifacts/tmp_round33_probe/struct_ok.cj`
  - `artifacts/tmp_round33_probe/class_ok.cj`

# Evolution Log
- 版本演进记录：
  - `[2026-03-30] [V1.0-initial] 基于 Round 32 的真实 compile error 与本地 struct/class probe，新增领域模型初始化专项 Skill，强制模型在本地声明 Domain struct/class 时补齐显式 init。`
