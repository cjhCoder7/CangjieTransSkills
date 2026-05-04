# ArkTS 与 TDLib C++ 互操作：NAPI / Native Bridge 原始材料

## 1. 问题背景

Telegram 级即时通讯应用的核心网络、协议与加密逻辑通常不会直接写在 ArkTS 声明式 UI 层，而是沉淀在更底层的 C / C++ 模块中。一个典型做法是将 TDLib 或等价的 MTProto 核心实现保留在 Native 层，然后由 ArkTS 通过 NAPI（Node-API）或 HarmonyOS 的原生桥接机制与它通信。

ArkTS 层的职责通常不是“自己理解 MTProto 细节”，而是：

- 把上层业务请求编码为 Native 能接受的命令；
- 把 Native 返回的事件、响应、错误转换为 ArkTS 可消费的对象；
- 把高频 Native 事件与 UI 生命周期、状态管理、主线程更新边界正确衔接；
- 在页面、全局状态树和 Native 长生命周期句柄之间建立明确的所有权边界。

## 2. ArkTS 侧常见互操作形态

### 2.1 句柄式 Client 管理

ArkTS 不会直接持有 C++ 对象实例本身，而是通过 Native 层暴露的句柄（handle）或整数 ID 管理一个 TDLib client。

常见模式：

- ArkTS 调用 `createClient()`；
- Native 层返回一个 client handle；
- 后续 `send(handle, request)`、`receive(handle, timeout)`、`destroy(handle)` 都通过这个 handle 路由；
- 页面组件不应直接拥有 handle，通常由全局网关、服务层或桥接协调器持有。

这意味着 ArkTS 到 Native 的边界更像“能力句柄 + 命令总线”，而不是“对象直连”。

### 2.2 JSON 字符串或 UTF-8 Buffer 传输

TDLib 常见的上层调用模式是：

- ArkTS 侧将请求编码为 JSON 字符串；
- 通过 NAPI 将字符串、UTF-8 缓冲区或外部 ArrayBuffer 传给 Native；
- Native 层调用底层 `td_json_client_send` 或等价接口；
- Native 层拿到结果后，再把 JSON 字符串或序列化结果回传给 ArkTS。

在高频场景下，如果每一次都做大对象深拷贝，会引入明显的额外开销。因此实际工程中会关注：

- 是否可以复用缓冲区；
- 是否可以通过共享内存或外部缓冲避免重复拷贝；
- 是否要把解析前的 JSON 文本先保留在 Native 侧，只把必要字段投递给 ArkTS。

### 2.3 轮询 receive 与回调混合模型

Native 侧常见有两种把结果送回上层的方式：

1. ArkTS 主动轮询 `receive(timeout)`；
2. Native 后台线程接到结果后，通过 callback / emitter / event queue 推送回 ArkTS。

在 Telegram 这类场景里，通常不是“一问一答”这么简单，而是：

- 请求响应混杂；
- 服务器主动推送更新；
- 多个并发请求的返回顺序不稳定；
- 一条消息可能先到基础数据，再到媒体元数据，再到下载状态更新。

所以 ArkTS 看到的 Native 输出更像高频异步事件流，而不是普通函数返回值。

## 3. 高频异步通信的关键难点

### 3.1 线程边界

Native 回调不一定运行在 UI 主线程。常见情况是：

- C++ 网络线程收到 TDLib 更新；
- Native bridge 在线程池或专门回调线程中完成序列化；
- 结果通过事件队列或任务投递回 ArkTS；
- ArkTS 再决定哪些更新需要投递到主线程 UI。

如果 ArkTS 直接把 Native callback 中的数据写进页面 `@State` 或数据源，就会把 Native 线程与 UI 线程错误耦合。

### 3.2 句柄生命周期与页面生命周期错位

TDLib client 往往是长生命周期对象，而页面是短生命周期对象。

风险包括：

- 页面退出后，Native 仍然持续回调；
- 旧页面订阅未释放，导致重复消费事件；
- handle 已销毁，但 ArkTS 侧仍继续 send；
- ArkTS 侧重连后创建了新 client，旧 client 的回调却仍然落回当前状态树。

因此需要一个独立的桥接协调器或 gateway 负责：

- client handle 的创建、复用、销毁；
- 回调订阅与解绑；
- 页面级 observer 的注册与释放；
- 连接状态重建；
- 过期结果隔离。

### 3.3 错误传播与异常隔离

Native 层错误不应直接以“崩溃”形式冒泡到 ArkTS。

工程上通常需要分层处理：

- Native ABI 错误，如空指针、非法句柄、序列化失败；
- TDLib 协议错误，如认证失败、限流、请求格式错误；
- ArkTS 业务错误，如请求上下文已失效、页面已销毁、事件类型未注册。

不同层级的错误应转换为不同类型的上抛事件或错误对象，避免上层把所有失败都混成“请求失败”。

### 3.4 背压与吞吐控制

如果 Native 在高峰期每秒推送大量消息更新，而 ArkTS 每条都立即解析、分发、刷新 UI，会出现：

- 事件队列膨胀；
- JSON 解析 CPU 飙升；
- UI 绑定状态更新过于频繁；
- 页面滑动卡顿。

因此更合理的模式是：

- Native / bridge 层先做分发分桶；
- ArkTS bridge adapter 做增量合批；
- 状态层只接收最小变更包；
- UI 层只消费窗口投影后的结果。

## 4. ArkTS 侧常见桥接分层

一个更稳健的 ArkTS 组织方式通常至少包含四层：

1. **Native ABI Layer**
   - 负责 NAPI 函数声明；
   - 负责 `create / send / receive / destroy` 之类的原生接口封装；
   - 负责基础类型转换。

2. **Bridge Adapter Layer**
   - 负责 handle 所有权；
   - 负责 JSON 编码 / 解码；
   - 负责 callback 注册与分发；
   - 负责回调线程到 ArkTS 事件管道的转发。

3. **Gateway / Service Layer**
   - 负责请求 ID、业务命令路由、错误语义化；
   - 负责连接状态、重连、登录状态、会话选择等长生命周期逻辑。

4. **State / UI Projection Layer**
   - 负责把 Gateway 输出转成页面可消费状态；
   - 负责与 Signal、Store、虚拟化时间线等上层结构组合；
   - 负责在主线程投递最终状态更新。

重点是：ArkTS 页面组件不应直接操作 Native handle。

## 5. 对仓颉迁移的关键启发

如果未来要把这条链路迁移到仓颉，核心不是“把 ArkTS 的 NAPI 函数逐行翻译”，而是要重新回答下面这些问题：

- 哪一层负责声明 C 接口？
- 哪一层负责把 `char*` / `const char*` / `void*` / callback function pointer 映射到仓颉可管理的类型？
- 哪一层负责 `CFunc`、`CPointer`、native handle 与仓颉对象之间的所有权边界？
- 哪一层负责把 Native callback thread 切回仓颉侧可控的事件管道？
- 哪一层负责决定页面销毁后是否还允许继续接收回调？
- 哪一层负责 request id 与 response / update stream 的匹配？

仓颉侧如果有原生 C-Interop 能力，那么它更适合承担：

- C 接口声明；
- 指针包装；
- handle 生命周期封装；
- callback adapter；
- 线程间桥接；
- 错误码与结构化错误对象转换。

而不是把这些复杂度继续暴露给 UI 页面。

## 6. 典型错误模式

### 6.1 页面直接持有 Native handle

这种设计会造成：

- 页面离开后 handle 不易统一销毁；
- 多页面共享连接时职责混乱；
- 页面热切换时容易出现重复回调和状态串线。

### 6.2 在 Native callback 里直接更新 UI 状态

这样做会把回调线程、ArkTS 状态系统和 UI 主线程强耦合，极易造成线程安全问题和主线程抖动。

### 6.3 每条 Native 更新都完整 JSON 解析后立刻全量分发

这会导致高频消息场景下的 CPU 与内存开销急剧放大，也不利于后续的消息合批与虚拟化渲染。

### 6.4 没有显式释放 callback / listener

长连接类 Native client 如果没有明确的 callback 解绑和资源释放策略，最终会形成最隐蔽的内存泄漏与幽灵回调问题。

## 7. 本轮 Skill 提炼重点

本轮希望模型重点提炼以下架构问题：

- ArkTS NAPI / Native bridge 到仓颉 `CFunc`、`CPointer`、handle wrapper 的角色映射；
- callback thread、bridge worker、ArkTS 事件层、主线程 UI 提交点的执行拓扑；
- Native handle、ArkTS gateway、页面 observer 三者的生命周期归属；
- 高频 JSON / buffer 通信的性能红线；
- 资源释放、错误分层、回调解绑与过期结果隔离的失败模型。

如果这些点能被结构化沉淀为 Skill，那么它将成为未来 Telegram 级迁移里最关键的底层护栏之一。
