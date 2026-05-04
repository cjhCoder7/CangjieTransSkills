# Skill Metadata
- Skill ID: `ARCH-TDLIB-C-INTEROP-BRIDGE-001`
- Skill Name: `tdlib-c-interop-bridge`
- Skill Class: `Architecture`
- Scope: 聚焦 ArkTS 通过 NAPI 或原生桥接与 TDLib C++ 通信，并映射到仓颉侧 CFunc、CPointer、handle wrapper、callback adapter 与主线程状态投递边界。
- Tags: `Architecture`, `C-Interop`, `TDLib`, `NAPI`, `ThreadSafety`, `Lifecycle`, `Bridge`
- Version: `2.0.0`

# Trigger Condition
- 任务触发条件: 当迁移任务涉及 ArkTS 与底层 C/C++ 库（如 TDLib）通过 NAPI 或原生桥接进行通信，且源码中存在句柄管理、JSON Buffer 传输、跨线程回调分发或长连接生命周期管理时触发。
- 强制触发条件: 源码中检测到 `libtdjson.so` 加载、`napi_create_threadsafe_function`、`client_create`/`client_send` 句柄模式、或 Native 回调直接更新 UI 状态的迹象。
- 不适用条件: 纯 ArkTS 业务逻辑迁移，或仅涉及简单 HTTP 请求无底层 C++ 交互的场景。

# Core Concept
- 最短知识结论: 核心是将 ArkTS 的 NAPI 命令总线模式重构为仓颉的 C 接口声明层与生命周期管理器，实现句柄所有权与回调线程的隔离，确保 Native 事件流安全投递至主线程。
- 一句话风险提示: 若在 Native 回调线程直接操作 UI 状态或未解绑页面生命周期，将导致线程安全崩溃与幽灵回调内存泄漏。

# Architecture Mapping
- 源侧角色:
    - Native ABI Layer: 负责 NAPI 函数声明与基础类型转换。
    - Bridge Adapter Layer: 负责 JSON 编解码、Handle 所有权与 Callback 注册分发。
    - Gateway / Service Layer: 负责请求路由、连接状态与长生命周期逻辑。
    - UI State Layer: 负责消费状态并渲染。
- 目标侧角色:
    - C Interface Declaration Layer: 仓颉侧声明 `CFunc`、`CPointer`，映射 `td_json_client_*` 等接口。
    - Native Handle Wrapper: 封装 `void*` 为强类型 Handle 对象，管理 `create/destroy` 生命周期。
    - Callback Adapter: 实现 C 函数指针到仓颉闭包的适配，负责跨线程数据搬运。
    - Gateway Singleton: 持有 Native Handle 实例，管理 Observer 订阅与请求 ID 匹配。
    - MainThread Event Dispatcher: 负责将后台事件投递至主线程 UI。
- 保留策略: 保留 Gateway 层的业务路由逻辑、请求响应匹配机制与分层架构设计。
- 重构策略: 将 NAPI 的数据类型转换逻辑下沉至仓颉 C-Interop 层，利用仓颉语言特性封装 CPointer 与 Handle，将回调线程与主线程状态更新通过显式队列解耦，移除 ArkTS 中间层的数据转换开销。

# Dependency Constraint
- 必需依赖: 仓颉 C-Interop SDK（`foreign func` 支持），TDLib C 动态库（`libtdjson.so` 或等效库），仓颉并发库（线程安全队列或 Handler 机制）。
- 可选依赖: 高性能 JSON 解析库（用于替代原生解析），共享内存管理库（用于高频 Buffer 传输优化）。
- 冲突依赖: 禁止在 UI 组件库中直接依赖 C Pointer 操作库，禁止混用不同生命周期的 Handle 管理器。
- 环境前提: 目标设备需支持 Native 线程与仓颉线程并发执行，需具备主线程 Looper 或事件分发机制。

# Boundary Contract
- 边界类型: C FFI Boundary (仓颉与 C++), Thread Boundary (Native 回调线程与仓颉主线程), Lifecycle Boundary (Gateway 与 Page)。
- 输入:
    - C 侧: `const char*` (请求 JSON), `void*` (client handle), `double` (timeout), `void*` (client_id)。
    - 仓颉侧: `String`, `HandleWrapper`, `Duration`, `CallbackRegistration`。
- 输出:
    - C 侧: `const char*` (响应 JSON), `int64` (request id), `void` (event)。
    - 仓颉侧: `Result<T>`, `Event`, `Error`, `Unit`。
- 生命周期归属:
    - Client Handle: 归属 Gateway 单例，全局唯一。
    - Request Context: 归属 Gateway 请求映射表。
    - Page Observer: 归属具体页面组件，随页面销毁。
- 资源释放责任:
    - C 侧: 负责释放 `td_json_client_receive` 返回的 JSON Buffer（若所有权未转移）。
    - 仓颉侧: Gateway 负责调用 `destroy`；Callback Adapter 负责注销函数指针；页面负责 unregister Observer。
- 错误传递方式:
    - Native ABI 错误（空指针、非法句柄）转为仓颉异常或顶层 Error Event。
    - TDLib 协议错误转为结构化 Error 对象，携带 code 与 message。
    - 业务错误转为状态流事件，不中断主流程。

# Execution Topology
- 线程模型:
    - Native Network Thread: TDLib 内部网络 IO。
    - Native Callback Thread: 执行 `td_json_client_receive` 循环，持有 C 回调上下文。
    - Bridge Worker (仓颉): 接收 Native 回调，执行 JSON 解析、Diff 计算、Delta 合批。
    - Main Thread (UI): 接收 Bridge Worker 投递的事件，更新 `@State` 或 Signal。
- 主线程提交点: 仅允许在 Main Thread Event Queue 处理阶段提交 UI 状态变更，严禁在 Bridge Worker 或 Native Thread 直接写入 UI 状态。
- 后台处理点: JSON 解析、对象反序列化、业务逻辑过滤、Delta 合并必须在 Bridge Worker 执行。
- 串行要求: 针对同一个 Client Handle 的 Send 操作建议串行化以保证顺序；Receive 循环必须单线程独占。
- 批处理要求: 高频更新流必须支持合批，例如 16ms 内的多次消息更新合并为一次 UI 提交，避免单条消息触发一次全量刷新。

# State Contract
- 状态所有者:
    - Native Handle: Gateway 单例持有，全局唯一。
    - Connection State: Gateway 持有，驱动 UI 全局状态。
    - Request Map: Gateway 持有，维护 request_id 与 callback 的映射。
    - Page State: 各页面组件持有，仅包含视图投影数据。
- 真值来源: TDLib Native 层是数据的唯一真值来源；UI 层仅是投影，不持有业务真值。
- 可变字段: 连接状态、请求队列、Observer 列表、本地缓存。
- 衍生字段: UI 展示用的格式化数据、未读计数聚合、虚拟列表索引。
- 持久化策略: Gateway 级别的连接配置需持久化；页面级状态随生命周期销毁；Session 数据由 Native 层管理。
- 一致性规则: 页面销毁时必须从 Gateway 注销 Observer，防止状态回写已销毁页面；Handle 销毁时必须清空请求映射表。

# Progressive Modules
## Module 1：概念最小版
建立 `td_json_client_create` 与 `td_json_client_destroy` 的 CFunc 映射，实现 Handle 的创建与销毁，验证基础 C-Interop 连通性，不涉及回调。
## Module 2：常见映射
实现 `send` 与 `receive` 的 JSON 字符串传递，封装 `CPointer` 读写，建立基础的请求-响应闭环，使用轮询模式验证通信。
## Module 3：跨层模式
引入 Callback Adapter，实现 Native 线程到仓颉主线程的事件投递，建立 Gateway 单例管理 Handle 生命周期，实现 Observer 注册机制。
## Module 4：工程级约束
增加错误分层处理、背压控制、Delta 合批逻辑，完善资源释放与异常隔离，确保页面销毁时的资源完全释放与幽灵回调防护。

# Translation Mapping
- ArkTS 对应写法: `napi_create_function`, `threadSafeFunction`, `string` <-> `char*` 手动转换, `globalThis.gateway` 单例。
- 仓颉对应写法: `foreign func [cname]`, `CPointer<T>` 包装, `CFunc` 回调类型定义, `Gateway` 类单例, `Handler` 或 `Emitter` 线程切换。
- 允许差异: 仓颉侧可利用语言原生特性更安全地封装指针，无需手动处理 `napi_value` 类型转换，内存管理模型不同。
- 禁止直译点: 禁止将 `napi_threadsafe_function` 的复杂调用逻辑直接翻译，应抽象为通用的跨线程事件分发器；禁止在仓颉中保留 ArkTS 的 `ref` 引用计数逻辑。

# Performance Envelope
- 主线程预算: JSON 解析与大对象构建严禁在主线程执行；主线程仅负责轻量状态合并与 UI 提交，预算控制在 5ms 以内。
- 吞吐量关注点: 关注 Native 回调频率与 UI 刷新频率的倍数关系；需实施 Delta 更新与批处理，避免每秒超过 60 次的状态提交。
- 内存关注点: 避免 JSON 字符串在 C 层与仓颉层的重复拷贝；关注长连接场景下的 Observer 累积导致的内存泄漏；监控 Native Buffer 的生命周期。
- 建议优化手段: 使用 External Buffer 或共享内存传递大数据；实现对象池复用高频对象；在 Bridge 层做消息预过滤，仅投递 UI 必要字段。

# Failure Model
- 失败场景:
    - Handle 已销毁仍调用 Send。
    - Native 回调访问已释放的仓颉对象。
    - JSON 解析失败导致数据丢失。
    - 网络断连导致请求超时。
    - 页面销毁后回调继续触发。
- 触发迹象: 随机崩溃；内存访问越界；UI 无响应或状态异常；日志中出现 `Invalid Handle` 或 `Use after free`。
- 恢复策略: Gateway 捕获异常并尝试重建连接；页面层监听连接状态重置 UI；废弃过期请求的响应；使用 WeakReference 持有 Observer。
- 禁止修复方式: 禁止使用 `try-catch` 包裹所有 Native 调用来掩盖生命周期错误；禁止在未知状态下强制重启 Client；禁止忽略 `Invalid Handle` 错误。

# Verification Matrix
- 验证目标: 验证 Handle 生命周期与页面解耦，以及线程安全。
- 输入条件: 创建页面 -> 触发 Native 交互 -> 销毁页面 -> 触发 Native 回调 -> 再次创建页面。
- 预期结果: 页面销毁后，Native 回调被自动过滤或丢弃，无内存泄漏，无崩溃，新页面状态正常。
- 验证层次: 单元测试（JSON 编解码）、集成测试（Gateway 生命周期）、压力测试（高频回调）、内存泄漏检测。

# Composition With Other Skills
- 上游 Skill: 无（底层基础 Skill）。
- 下游 Skill: `signal-based-reactive-pipeline` (状态响应), `message-delta-merge-and-batching` (消息合并), `chat-timeline-virtualized-rendering` (UI 渲染)。
- 组合顺序: 本 Skill 提供原始事件流 -> `message-delta-merge-and-batching` 进行预处理 -> `signal-based-reactive-pipeline` 转为响应式状态 -> `chat-timeline-virtualized-rendering` 渲染。
- 误用风险: 下游 Skill 若直接依赖 Native 数据结构而非 Gateway 投递的事件对象，将导致耦合过紧；若跳过 Delta Merge 直接渲染，会导致 UI 卡顿。

# Retrieval Fallback
- CLI / Python 检索示例:
    - `rg -n "napi_create_threadsafe_function" --type ts`
    - `rg -n "td_json_client" ./native/src/`
    - `python scripts/skill_generator_v2.py --source docs/raw_docs/arkts-tdlib-c-interop.md --skill-name tdlib-c-interop-bridge --skill-class Architecture`
- 官方资料回查入口: HarmonyOS NAPI 文档，仓颉语言 C-Interop 指南，TDLib JSON API 文档。
- 降级策略: 若无法确定具体 API 签名，优先保证架构分层逻辑正确，具体函数名留待实现期确认。

# Security / Privacy Constraint
- 数据暴露边界: 敏感聊天内容仅在 Native 层与 Gateway 层流转，最小化暴露给 UI 层的数据字段，日志中禁止打印完整请求/响应 JSON。
- 线程安全约束: 禁止并发读写 Handle；Callback 注册需加锁或使用线程安全容器；Native 指针必须封装为不可变对象。
- 隐私或敏感信息注意事项: 需对用户 ID、消息内容进行脱敏处理后再记录日志；Token 与密钥严禁存储在普通内存对象中。

# Migration Strategy
- 最小迁移路径: 先建立仓颉 C 接口声明层，验证 `create/destroy`；再迁移 `send/receive` 逻辑；最后迁移 Callback 分发与 Gateway 生命周期。
- 过渡层: 可保留 ArkTS Gateway 作为临时中转，逐步替换为仓颉实现，采用双向桥接验证数据一致性。
- 替换顺序: Native ABI Layer -> Bridge Adapter -> Gateway Service -> UI Binding。
- 回滚点: 若仓颉 C-Interop 出现兼容性问题，可回退至 ArkTS NAPI 调用仓颉封装层的混合模式。

# Examples
- 概念性示例: 展示 `CFunc` 声明与 `Gateway` 伪代码结构。
- 伪代码:
```c
// C Interface Declaration
foreign func td_json_client_create(): CPointer<Void>
foreign func td_json_client_send(client: CPointer<Void>, request: CPointer<Byte>)
foreign func td_json_client_receive(client: CPointer<Void>, timeout: CDouble): CPointer<Byte>
foreign func td_json_client_destroy(client: CPointer<Void>)
```
```javascript
// Gateway Singleton Concept
class TdGateway {
    private let handle: CPointer<Void>
    private let worker: BridgeWorker
    private let observers: MutableList<Observer>

    init() {
        this.handle = td_json_client_create()
        this.worker = BridgeWorker(handle)
        this.worker.onEvent = { event => this.dispatchEvent(event) }
    }

    public func send(request: String) {
        // Convert string to CPointer and call native send
    }

    private func dispatchEvent(event: Event) {
        // Post to main thread
        MainThreadDispatcher.post {
            for obs in observers { obs.onEvent(event) }
        }
    }
}
```
- 结构草图:
```
[Native C++ Thread] --(raw JSON)--> [Bridge Worker (CJ)]
                                      | (Parse & Batch)
                                      v
                               [Main Thread Queue]
                                      |
                                      v
                                [UI State Update]
```

# Test & Debug
- 单测策略: 针对 JSON 编解码、Handle 映射关系、Request ID 匹配逻辑进行单元测试。
- 集成验证: 模拟高频消息推送，验证背压与批处理效果；模拟页面频繁进出，验证内存稳定性与 Observer 清理。
- 诊断日志: 在 Bridge 层记录关键事件 ID、耗时、线程 ID，便于追踪时序问题；记录 Handle 创建与销毁时机。
- 排错步骤:
    1. 检查 Handle 引用计数是否归零。
    2. 检查 Observer 列表是否在页面销毁时清理。
    3. 检查线程上下文，确认是否在非主线程访问 UI。
    4. 检查 Native Buffer 是否正确释放。

# Sources
- 输入来源: `docs/raw_docs/arkts-tdlib-c-interop.md`
- 引用依据: 源文档中关于分层架构、线程模型、生命周期管理、JSON Buffer 传输与错误传播的描述。

# Known Gaps
- 当前未知: 仓颉 C-Interop SDK 具体的 API 命名与调用约定细节（如 `foreign func` 的具体语法糖）。
- 待验证: 仓颉线程与 Native 线程交互的具体性能开销与同步原语实现。
- 环境限制: 当前 Skill 未在真实仓颉编译环境与 TDLib 动态库上进行联调验证，仅基于架构设计推导。

# Evolution Log
- 版本记录: v1.0.0 初始生成。
- 本次改动: 基于源材料提炼架构映射、边界契约与执行拓扑，重点强化线程安全与生命周期管理。
- 后续补强方向: 补充具体的仓颉 C-Interop 代码片段示例，补充详细的错误码映射表，补充共享内存传输的具体实现方案。
