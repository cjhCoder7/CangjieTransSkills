# 执行轨迹：V2 Skill 生成流水线 run-004 / tdlib-c-interop-bridge

## 1. Run 元信息

- **Run ID**：`run-004-tdlib-interop`
- **执行日期**：`2026-03-26`
- **执行目标**：在升级后的压缩 Prompt + 本地校验 + 自动修复工具链下，重新测试 `GLM-5` 对 Telegram 级底层架构问题的处理能力。
- **挑战主题**：ArkTS 通过 NAPI / Native Bridge 与 TDLib C++ 通信，并向未来仓颉 `CFunc`、`CPointer`、native handle wrapper、callback adapter 架构迁移。
- **模型**：`Pro/zai-org/GLM-5`
- **模式**：真实 API，非 mock
- **输入原材料**：`docs/raw_docs/arkts-tdlib-c-interop.md`
- **输出 Skill**：`skills/tdlib-c-interop-bridge.md`

## 2. 本轮实验设计原则

本轮不是重复测试旧主题，而是给 `GLM-5` 一次更公平、但也更困难的实战：

- **更公平**：不再使用旧版“超长 Prompt + 全文 Schema 注入”的低效策略；
- **更困难**：直接把测试主题升级为 Telegram 级底层 Boss——TDLib Native 通信与 C-Interop。

本轮的目标不是证明 `GLM-5` 会不会“写文档”，而是验证：

1. 在 Prompt 压缩后，`GLM-5` 是否仍会像之前一样超时；
2. 在真正的 Architecture 级高风险主题下，`GLM-5` 是否还能守住 V2 Schema；
3. 如果首轮输出有瑕疵，自动修复能否收敛。

## 3. 输入原材料设计要点

本轮原材料 `docs/raw_docs/arkts-tdlib-c-interop.md` 重点压入了以下架构信号：

- ArkTS 不直接持有 C++ 对象，而是通过 client handle / integer id 管理 Native client；
- ArkTS 与 TDLib 常见通过 JSON 字符串、UTF-8 Buffer、外部 ArrayBuffer 或共享内存进行高频通信；
- Native 输出不是普通同步返回，而是高频异步事件流；
- Native callback thread 不等于 UI 主线程；
- 页面生命周期与 Native handle 生命周期天然错位；
- 错误传播需要区分 ABI 错误、协议错误和业务错误；
- 高峰期必须考虑回调风暴、背压、合批和最小变更包。

这些输入刻意逼迫模型回答系统问题，而不是写浅层 API 对照表。

## 4. 实际执行命令

```bash
OPENAI_BASE_URL='https://api.siliconflow.cn/v1' \
OPENAI_API_KEY='<已配置，不在文档中回显>' \
python scripts/skill_generator_v2.py \
  --source docs/raw_docs/arkts-tdlib-c-interop.md \
  --skill-name tdlib-c-interop-bridge \
  --skill-id ARCH-TDLIB-C-INTEROP-BRIDGE-001 \
  --skill-class Architecture \
  --scope-hint '聚焦 ArkTS 通过 NAPI 或原生桥接与 TDLib C++ 通信，并映射到仓颉侧 CFunc、CPointer、handle wrapper、callback adapter 与主线程状态投递边界。' \
  --extra-instruction 'Architecture Mapping 必须明确把 ArkTS 的 NAPI/native bridge、client handle、JSON buffer 通信、callback 分发，映射为仓颉侧的 C 接口声明层、CFunc 回调适配器、CPointer 指针包装、native handle 生命周期管理器与 Gateway。' \
  --extra-instruction 'Boundary Contract 必须明确 char*、void*、回调函数指针、handle id、请求 JSON、响应 JSON、更新流、错误对象在边界两侧的输入输出与释放责任。' \
  --extra-instruction 'Execution Topology 必须写清 native callback thread、bridge worker、ArkTS 事件层、主线程 UI 提交点之间的线程拓扑，禁止把 native callback 直接写入页面状态。' \
  --extra-instruction 'State Contract 必须明确 native handle、gateway、observer、页面投影状态的所有权与失效规则，防止页面销毁后幽灵回调。' \
  --extra-instruction 'Performance Envelope 必须覆盖 JSON 序列化开销、buffer 复制、共享内存或外部缓冲复用、回调风暴、背压、批处理与主线程预算。' \
  --extra-instruction 'Failure Model 必须覆盖空指针、非法 handle、回调解绑遗漏、过期 client 回调、跨线程直接触 UI、错误分层丢失。' \
  --extra-instruction 'Composition With Other Skills 必须指出它是 signal-based-reactive-pipeline、message-delta-merge-and-batching、chat-timeline-virtualized-rendering 的上游底座。' \
  --extra-instruction 'Retrieval Fallback 必须使用 repo 内真实命令：至少包含一个 rg -n 命令，以及一个完整的 python scripts/skill_generator_v2.py --source <path> --skill-name <name> --skill-class Architecture 命令，不要发明 CLI 或假参数。' \
  --extra-instruction 'Examples 中允许写概念性 C-Interop 伪代码，但绝对不要生成完整 .cj 业务源码。' \
  --extra-instruction 'Known Gaps 必须诚实标注当前没有在真实仓颉 C-Interop SDK 与 TDLib ABI 上做编译联调验证。' \
  --model 'Pro/zai-org/GLM-5' \
  --max-source-chars 6500 \
  --timeout-seconds 240 \
  --max-attempts 3 \
  --dump-prompt-file artifacts/pipeline/tdlib-c-interop-bridge.prompt.txt \
  --dump-attempt-dir artifacts/pipeline/tdlib-c-interop-bridge.attempts \
  --output skills/tdlib-c-interop-bridge.md \
  --overwrite
```

## 5. 结果总览

### 5.1 是否超时

**没有超时。**

这是本轮最重要的结果之一。

上一轮旧流程里，`GLM-5` 在超长 Prompt 下两次超时，说明它曾被上下文负担拖死。本轮在压缩 Prompt 之后：

- 请求成功返回；
- 没有出现 transport timeout；
- 说明“GLM-5 做不了”这个结论之前是被旧 Prompt 工程污染过的。

### 5.2 Prompt 体量

- 本轮 Prompt 大小：`9511` 字符
- 对比旧版超长 Prompt（`114638` 字符），压缩幅度约为：`91.70%`

这说明即使在 Boss 级题目下，压缩骨架仍然能把上下文维持在一个现实可用的量级。

### 5.3 自动修复是否触发

**没有触发自动修复。**

证据：

- `artifacts/pipeline/tdlib-c-interop-bridge.attempts/` 中仅存在 `attempt-01.*` 文件；
- `attempt-01.issues.txt` 不存在；
- 说明 `GLM-5` 首轮输出已经通过了当前的本地校验器。

这比上一轮 `GLM-4.5-Air` 还要更进一步：

- 上一轮需要第二次 repair 才补齐 `CLI / Python 检索示例` 标签；
- 本轮 `GLM-5` 一轮过关。

## 6. 产物列表

- 原材料：`docs/raw_docs/arkts-tdlib-c-interop.md`
- 最终 Skill：`skills/tdlib-c-interop-bridge.md`
- Prompt：`artifacts/pipeline/tdlib-c-interop-bridge.prompt.txt`
- 运行日志：`artifacts/pipeline/tdlib-c-interop-bridge.run.log`
- 首轮原始输出：`artifacts/pipeline/tdlib-c-interop-bridge.attempts/attempt-01.raw.txt`
- 首轮提取 Markdown：`artifacts/pipeline/tdlib-c-interop-bridge.attempts/attempt-01.markdown.md`
- 首轮 Prompt：`artifacts/pipeline/tdlib-c-interop-bridge.attempts/attempt-01.prompt.txt`

## 7. 对生成内容的人工审查

### 7.1 强项：它真的抓住了 Architecture 级问题

这份 Skill 的强项非常明确：

- 在 `# Architecture Mapping` 中，把 ArkTS 的 NAPI / native bridge / Gateway / UI state layer，系统性映射到了仓颉侧的：
  - C Interface Declaration Layer
  - Native Handle Wrapper
  - Callback Adapter
  - Gateway Singleton
  - MainThread Event Dispatcher
- 在 `# Boundary Contract` 中，明确写出了：
  - `const char*`
  - `void*`
  - handle
  - request JSON
  - response JSON
  - 错误对象
  的边界输入输出与释放责任；
- 在 `# Execution Topology` 中，写清了：
  - Native Network Thread
  - Native Callback Thread
  - Bridge Worker
  - Main Thread
  的职责分层；
- 在 `# State Contract` 中，给出了 native handle、request map、page state 的归属与真值来源；
- 在 `# Performance Envelope` 与 `# Failure Model` 中，也覆盖了高频 JSON、buffer 复制、回调风暴、非法 handle、幽灵回调等真正的高风险问题。

这说明 `GLM-5` 在压缩 Prompt 下，不只是“结构没乱”，而是确实进入了系统级推演。

### 7.2 强项：对仓颉 C-Interop 的映射方向是对的

本轮最重要的 Boss 约束，是要求模型明确把 ArkTS Native bridge 映射到仓颉的原生 C-Interop 能力。

这一点它做到了：

- 明确提到了 `CFunc`；
- 明确提到了 `CPointer`；
- 明确提到了 handle wrapper；
- 明确提到了 callback adapter；
- 没有把问题降级成“ArkTS 调 API，仓颉也调 API”的浅层对照。

这意味着 V2 Schema 对这种底层互操作题目是有效的。

### 7.3 小瑕疵：局部仍有“合理但未仓库落地”的泛化痕迹

尽管首轮通过，但仍有几个值得记录的边缘问题：

1. `# Retrieval Fallback` 中出现了：
   - `rg -n "td_json_client" ./native/src/`

   这条命令本身是合法的，但 `./native/src/` 这个路径是模型推断出来的，并不是当前仓库中已知存在的路径。

2. `# Examples` 中出现了 `foreign func` 风格伪代码。
   - 这在本轮是可接受的，因为该章节被明确限定为“概念性示例 / 伪代码”；
   - 但它仍不是已经在真实仓颉 SDK 中验证过的正式语法。

这两个点说明：

- `GLM-5` 已经很强；
- 但即使一轮通过，它仍会在“未给定具体仓库事实”的局部位置自动补全合理细节；
- 后续如果我们希望继续降低幻觉，就应进一步增加“路径真实性断言”与“示例语法保守性断言”。

## 8. 对 GLM-5 的平反裁决

### 8.1 是否解决了超时问题

**是，明显解决了。**

至少在本轮 Boss 级题目下：

- 压缩后的 Prompt 没有再把它拖进超时；
- 说明之前的失败主要不是“模型智力不够”，而是“上下文工程太差”。

### 8.2 自我纠错能力如何

本轮没有进入 repair 阶段，因此无法直接观察 `GLM-5` 的二次修复表现。

但这本身已经是一个更强的正面信号：

- 它在首轮就满足了现有静态校验；
- 说明它的结构保持力和一次成稿能力，至少在压缩 Prompt 条件下明显优于旧流程里的表现。

### 8.3 最终判断

本轮可以给出一个非常清晰的结论：

> `GLM-5` 并不是做不了 V2 Architecture Skill；
> 它之前失败，主要是因为我们给它喂了不适合工业流水线的超长 Prompt。

换句话说：

- **项目方向没有问题；**
- **Schema V2 没有问题；**
- **GLM-5 本身也没有问题；**
- 真正被修正的是 Prompt 工程与工具链控制方式。

## 9. 下一步建议

基于本轮结果，最合理的下一步不是怀疑路线，而是继续把校验器往“事实约束”推进：

1. 增加 `Retrieval Fallback` 的路径真实性校验；
2. 增加 `Examples` 的“概念性伪代码”断言，避免被误读为正式仓颉语法；
3. 对 `Sources` / `官方资料回查入口` 加入更严格的来源级规则；
4. 继续用 `GLM-5` 试产下一个底层 Boss，比如：
   - `native-handle-ownership-and-invalidation`
   - `callback-thread-to-main-thread-handoff`
   - `ffi-buffer-lifetime-and-zero-copy-strategy`

## 10. 最终结论

run-004 的意义非常大，因为它完成了两件事：

1. **为 `GLM-5` 完成了一次真正公平的平反测试；**
2. **证明我们的流水线已经足以处理 Telegram 级别的底层互操作难题。**

本轮不是一次“侥幸成功”，而是一条更坚实的方法论证据：

- 压缩骨架降低上下文负担；
- 本地校验兜底结构；
- 自动修复负责二次收敛；
- 真实模型终于能把算力花在架构推演上，而不是浪费在读取一整本规范文档上。
