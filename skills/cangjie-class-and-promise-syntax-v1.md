# Skill Metadata
- Skill ID: `CJ-CLASS-PROMISE-SYNTAX-001`
- Skill Name: `cangjie-class-and-promise-syntax-v1`
- Skill Class: `Architecture`
- Scope: 针对真实 `cjc` 暴露的深层仓颉类声明、异步控制流、Promise 链式写法与包导入错误，强制 Translator 放弃 TypeScript/ArkTS 的 `.then/.catch/async` 习惯，收敛到当前物理环境真实可编译的保守写法。
- Tags: `cangjie`, `class`, `interface`, `promise`, `spawn`, `syntax`, `imports`, `compiler-feedback`
- Version: `V1.1`

# Trigger Condition
- 真实 `cjc` 报错命中以下任一关键词时必须加载：
  - `expected '{' or '<', found 'implements'`
  - `expected '{' or '<', found 'extends'`
  - `expected expression after '(', found '=>'`
  - `expected a member name after '.', found keyword 'catch'`
  - `can not find package 'ohos.signalkit'`
  - `can not find package 'ohos.models'`
  - `can not find package 'ohos.services'`
- 候选代码出现以下任一残留时强制加载：
  - `implements`
  - `extends`
  - `Promise(=> {`
  - `.then(`
  - `.catch(`
  - `async {`
  - `import { ... } from`
  - `import ohos.signalkit.*`
  - `import ohos.models.*`
  - `import ohos.services.*`

# Core Concept
- **类实现 / 继承统一用 `<:`**：仓颉里不要再写 `implements` / `extends`。
- **禁止 Promise 链式 TS 幻觉**：当前物理环境已经证明 `.then(...)`、`.catch(...)`、`async { ... }` 这类写法会把模型拉回 TS/ArkTS 的思维路径，必须禁用。
- **当前项目的保守基线**：优先使用同步调用 + 显式状态回填，或 `spawn { ... }` 触发后台任务；不要猜测 Promise/Future 链式 API。
- **导入必须服从物理白名单**：在当前 Linux x64 `cjc` 冒烟环境中，只能优先使用真实 SDK 能解析的 `std.*` 模块与当前工作区内真实存在的本地包。不要臆造 `ohos.*` 包名。

# Class / Interface Rule
- **严禁**：
  ```text
  export class RealMessageService implements IMessageService {
  public class RealMessageService implements IMessageService {
  class ChildService extends BaseService {
  ```
- **正确方向**：
  ```text
  public class RealMessageService <: IMessageService {
      ...
  }

  class ChildService <: BaseService {
      ...
  }
  ```
- **强制结论**：
  - `export class` 禁用
  - `implements` 禁用
  - `extends` 禁用
  - 类实现接口 / 继承统一改用 `<:`

# Async / Promise Rule
- **严禁的 TS / ArkTS 遗毒**：
  ```text
  return Promise(=> { ... })
  this.fetchMessages(params).then(...)
  this.fetchMessages(params).catch(...)
  async {
      ...
  }
  ```
- **为什么禁用**：
  - `.then/.catch` 不是当前仓颉物理验证过的调用范式；
  - `async { ... }` 在当前项目里没有被真实编译验证，属于高风险猜测；
  - 这类写法会导致模型继续输出 TS 风格箭头、Error 回调、链式 API，直接把代码带回源语言语法。
- **当前阶段唯一安全路线**：
  1. 如果目标是“返回可观察状态”：用 `Signal` / `ValueSignal` + `spawn { ... }` + 显式 `set(...)`
  2. 如果目标是“取一次结果”：优先改为同步函数签名，由 Adapter 返回真实值
  3. 如果目标是“后台副作用”：使用 `spawn { ... }`，不要链 `.then/.catch`
- **保守模板 A：同步 fetch + Signal 回填**：
  ```text
  public func getMessages(peerId: PeerId, limit: Int32): Signal<Array<Message>> {
      let signal = ValueSignal<Array<Message>>(Array<Message>())
      spawn {
          let messages = this.adapter.fetchMessages(peerId, limit)
          signal.set(messages)
      }
      return signal
  }
  ```
- **保守模板 B：Service 不写 Promise 链**：
  ```text
  public func fetchMessages(params: GetHistoryParams): Array<Message> {
      return this.adapter.fetchHistory(params.peerId, params.limit)
  }

  public func sendMessage(params: SendMessageParams): Message {
      return this.adapter.sendMessage(params)
  }
  ```
- **硬规则**：
  - 不准在 Service 层调用 `.then(...)`
  - 不准在 Service 层调用 `.catch(...)`
  - 不准在 Service 层写 `async { ... }`
  - 不准用回调链代替仓颉显式流程控制

# Import Whitelist (Physical Compiler Ground Truth)
以下白名单来自当前本地 Linux x64 真实 SDK：

`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/modules/linux_x86_64_cjnative/std`

## 允许优先使用的真实标准模块
- `import std.collection.*`
- `import std.convert.*`
- `import std.math.*`
- `import std.time.*`
- `import std.sync.*`
- `import std.ref.*`
- `import std.random.*`
- `import std.env.*`
- `import std.io.*`
- `import std.net.*`
- `import std.crypto.*`
- `import std.process.*`
- `import std.unicode.*`
- `import std.regex.*`
- `import std.database.*`
- `import std.argopt.*`
- `import std.objectpool.*`
- `import std.ast.*`

## 允许的本地项目包策略
- 只允许导入**当前 workspace 中真实存在且会被一同编译**的本地包
- 例如：
  - `import telegram.domain.*`
  - `import telegram.adapter.*`
  - `import core.mtproto.*`
- 前提：这些包必须在当前工作区内有真实源码或真实 `.cjo`，不能凭空写名字

## 当前物理环境下禁止臆造的包
- `import ohos.signalkit.*`
- `import ohos.models.*`
- `import ohos.services.*`
- 任何 `import { X } from '...'`

## 导入硬规则
- 先问自己：这个包在当前工作区或真实 SDK 模块里**真的存在吗**？
- 若不存在：
  - 不要导入它
  - 改为在当前文件内声明最小接口 / 最小领域类型
  - 或把接口留给本地项目包，不要伪造 `ohos.*`

# Few-Shot Contrast
- 对比一：类声明
  ```text
  // 错误
  export class RealMessageService implements IMessageService {

  // 正确方向
  public class RealMessageService <: IMessageService {
  ```
- 对比二：Promise 链
  ```text
  // 错误
  this.fetchMessages(params).then((msgs: Array<Message>) => {
      signal.set(msgs)
  }).catch((err: Error) => {
      println(err)
  })

  // 正确方向
  spawn {
      let msgs = this.fetchMessages(params)
      signal.set(msgs)
  }
  ```
- 对比三：异步块
  ```text
  // 错误
  let fetchTask = async {
      ...
  }

  // 当前阶段正确方向
  spawn {
      ...
  }
  ```
- 对比四：导入
  ```text
  // 错误
  import { Signal, ValueSignal } from '@ohos/signalkit'
  import ohos.signalkit.*

  // 正确方向
  import std.collection.*
  import std.time.*
  // 仅在本地真实存在时导入项目包
  import telegram.domain.*
  ```

# Repair Instruction Template
- 遇到 `export class` / `implements` / `extends`：
  - 立刻改成 `public class ... <: ... {}`
- 遇到 `.then(...)` / `.catch(...)`：
  - 立刻删除整个链式写法
  - 改为同步返回值 + `spawn { ... }` / 显式状态回填
- 遇到 `async { ... }`：
  - 立刻删除，改为 `spawn { ... }`
- 遇到 `import ohos.*`：
  - 立刻删除
  - 仅保留真实 `std.*` 导入或当前 workspace 中真实存在的本地包
- 遇到缺失类型：
  - 宁可在当前文件声明一个最小接口 / 领域结构，也不要臆造 `ohos.signalkit`、`ohos.models`、`ohos.services`

# Hard Verdict
只要代码里还出现以下任一项，就说明模型仍在把源语言异步 / 面向对象 / 导入系统硬套到仓颉上，必须直接打回：
- `export class`
- `implements`
- `extends`
- `Promise(=> {`
- `.then(`
- `.catch(`
- `async {`
- `import { ... } from`
- `import ohos.signalkit.*`
- `import ohos.models.*`
- `import ohos.services.*`
