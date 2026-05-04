# Pipeline Run-002 总结：聊天时间线虚拟化渲染 Skill 试产

## 1. 文档目的

本文用于汇总 run-002 中 `chat-timeline-virtualized-rendering` 这个 Architecture Skill 的生成过程、核心架构成果，以及它与上游 `message-delta-merge-and-batching` 的联动关系。

说明：

- 本文文件名按任务要求使用 `2026-03-25` 前缀；
- 但实际 run-002 执行时间发生在 `2026-03-26`。

---

## 2. 本轮任务目标

本轮的核心目标不是继续扩展 UI 技巧，而是继续沿 ArkTS 主线，试产一个更贴近 Telegram 级消息界面的高风险 Architecture Skill：

- `skills/chat-timeline-virtualized-rendering.md`

这个 Skill 要回答的，不是“一个列表怎么渲染”，而是：

- 上万条消息的聊天时间线如何窗口化显示；
- 如何在保持滚动流畅的同时控制活动节点数量；
- 如何用 `@Reusable` / `reuseId` 一类能力，抽象出组件复用池和模板分桶；
- 如何处理向上翻历史与向下追最新的双向分页；
- 如何让虚拟化渲染层与上游的消息增量合批层正确衔接。

---

## 3. 输入原材料与生成链路

本轮为生成器准备了四份输入：

- `docs/raw_docs/arkts-chat-timeline-virtualization.md`
- `skills/message-delta-merge-and-batching.md`
- `skills/signal-based-reactive-pipeline.md`
- `docs/architecture/telegram-arkts-teardown-001.md`

其中：

### 3.1 原始材料

`docs/raw_docs/arkts-chat-timeline-virtualization.md` 负责提供 ArkTS 侧的原始工程语义，重点覆盖：

- `LazyForEach`
- `Repeat.virtualScroll`
- `cachedCount`
- `@Reusable`
- `reuseId`
- `WaterFlow`
- 双向分页
- 锚点稳定
- 富媒体离屏回收

### 3.2 上游 Skill 约束

`skills/message-delta-merge-and-batching.md` 负责提供一条非常关键的上游前提：

- 虚拟化渲染层不应该直接面对原始消息流；
- 它应该面对已经被后台合批和增量归并后的稳定时间线区段。

### 3.3 响应式管道约束

`skills/signal-based-reactive-pipeline.md` 负责说明：

- 响应式流在后台完成变换；
- 主线程只接收最终安全可投递的结果。

### 3.4 Telegram 场景压力背景

`docs/architecture/telegram-arkts-teardown-001.md` 负责提醒生成器：

- 这不是普通长列表，而是即时通讯时间线；
- 分页、增量消息、已读状态、富媒体、滚动锚点都是真实压力场景。

---

## 4. 本轮最核心的架构映射成果

本轮最有价值的成果，不是把几个 ArkTS API 逐字翻译，而是把 ArkTS 的时间线虚拟化经验提升为几个可以在仓颉侧长期复用的架构角色。

### 4.1 `@Reusable` / `reuseId` 被提升为“组件复用池 + 模板分桶”

这是本轮最关键的抽象成果之一。

Skill 最终明确指出：

- `@Reusable` 的本质不是一个装饰器；
- `reuseId` 的本质不是一个零散属性；
- 它们在架构上的真正意义，是：
  - 为消息单元建立按模板类型划分的复用分桶；
  - 支持离屏节点回收；
  - 支持新进入窗口的消息单元从复用池中重新绑定；
  - 避免为每条消息长期保留独立 UI 节点。

也就是说，最终 Skill 并没有停留在“如何写装饰器”，而是把它重构为：

- `TimelineReusePool`
- `ReusableMessageCell`
- `RenderTemplateRegistry`
- `ReuseBucketId`

这一层抽象非常关键，因为它比装饰器语法更能迁移到仓颉侧的长期工程结构中。

### 4.2 时间线被拆成“完整真值”与“窗口投影”

Skill 明确将聊天时间线拆成两个不同层面：

- 完整消息真值层；
- 可见窗口与预加载窗口的投影层。

这个拆分非常重要，因为它避免了一个常见错误：

- 让页面直接持有完整的时间线数组并尝试全量渲染。

最终 Skill 中，仓颉侧推荐的角色包括：

- `VisibleRangeProjectionStore`
- `TimelineViewportWindow`
- `TimelinePreloadWindowPolicy`
- `MainThreadTimelineRenderer`

这说明生成结果已经开始具备非常明确的“窗口化渲染”思想，而不是笼统地说“用虚拟列表优化性能”。

### 4.3 双向分页被建模为独立协调器，而不是页面事件

Skill 没有把“上滑加载更多”和“下滑追最新”理解成两个按钮或两个普通滚动事件，而是把它们抽象成：

- `BidirectionalPaginationCoordinator`
- `TimelineAnchorManager`

这样做的价值在于：

- 历史消息插入时，系统先恢复锚点，再刷新当前活动窗口；
- 最新消息到来时，系统根据“是否贴底”决定是否自动跟随；
- 虚拟化渲染不再与分页行为纠缠在页面回调里。

### 4.4 `WaterFlow` 被正确降级为“媒体流场景参考”，而不是默认正文容器

本轮 Skill 并没有误把 `WaterFlow` 直接当成聊天正文时间线的默认容器。

相反，最终结论非常稳：

- 普通线性聊天消息时间线，默认仍应以线性滚动容器为主；
- `WaterFlow` 更适合作为媒体瀑布流、图库流、附件流等扩展场景参考；
- 这体现了模型和原材料没有把“复杂容器”误判成“默认正确容器”。

这是一个非常重要的质量信号。

---

## 5. 与上游合批 Skill 的联动关系

本轮生成的 Skill 最成功的地方之一，是它没有孤立存在，而是与上一轮的：

- `skills/message-delta-merge-and-batching.md`

形成了非常明确的上下游关系。

### 5.1 上游负责什么

`message-delta-merge-and-batching` 负责：

- 从高频消息流中做后台增量合并；
- 压缩离散变化；
- 产出稳定区段或批处理后的列表变化。

### 5.2 本轮虚拟化 Skill 负责什么

`chat-timeline-virtualized-rendering` 负责：

- 接住这些已经收敛过的数据；
- 将它们映射到可见窗口、预加载窗口和锚点管理；
- 控制组件复用池与活动节点集合；
- 只把当前需要的少量节点交给主线程绑定与渲染。

### 5.3 这条上下游链的意义

这意味着我们现在的 ArkTS 主线 Skill 已经形成了真实的架构链条：

1. **响应式管道**：后台接收和变换事件流；
2. **消息增量合批**：把高频消息压缩成稳定区段；
3. **时间线虚拟化渲染**：把稳定区段交给窗口化、锚点和复用池，再安全渲染到主线程。

这条链已经非常接近 Telegram 级即时通讯界面的核心渲染逻辑。

---

## 6. 本轮生成结果的质量判断

总体判断：本轮 Skill 的质量很高，而且明显守住了 V2 Schema 对 Architecture Skill 的要求。

### 6.1 它没有退化成组件说明书

最终 Skill 并没有停留在：

- `LazyForEach` 怎么用；
- `WaterFlow` 怎么用；
- `@Reusable` 怎么写；

而是提升到了：

- 真值与窗口投影分离；
- 模板分桶复用池；
- 活动节点预算；
- 双向分页锚点恢复；
- 富媒体离屏释放；
- 主线程节点绑定预算。

### 6.2 `Architecture Mapping` 很丰满

本轮最好的字段之一就是 `Architecture Mapping`。

它不只列出了源侧概念，还给出了目标侧建议角色：

- `TimelineViewportWindow`
- `TimelineAnchorManager`
- `BidirectionalPaginationCoordinator`
- `TimelineReusePool`
- `ReusableMessageCell`
- `RenderTemplateRegistry`
- `VisibleRangeProjectionStore`
- `MediaDeferredLoader`
- `MainThreadTimelineRenderer`

这说明 Skill 已经具备明显的“架构重建”能力，而不仅仅是“语法对照”能力。

### 6.3 `Performance Envelope` 也很有工程味

这个字段没有停留在“注意性能”这种空话，而是明确写出了：

- 活动节点数必须与可见窗口和预加载窗口绑定；
- 离屏节点不应继续持有大图和复杂解码结果；
- 复用池大小要受控；
- 富媒体节点需要离屏降级与惰性恢复；
- 主线程只应处理当前窗口的轻量绑定工作。

这已经足以指导后续工程实现。

---

## 7. 本轮仍然存在的限制

虽然本轮很成功，但有两个限制仍然成立。

### 7.1 当前仍是 mock 模式

本轮虽然真实调用了生成器，但输出来源仍然是：

- `artifacts/pipeline/chat-timeline-virtualized-rendering.mock.md`

因此，我们已经证明：

- Pipeline 通了；
- V2 结构稳了；
- 原材料和 Prompt 的组织方式是合理的；

但我们还没有证明：

- 真实大模型在同样 Prompt 下，也能稳定写出同等质量的 `Architecture Mapping` 和 `Performance Envelope`。

### 7.2 Prompt 正在变得更长

由于虚拟化、分页、复用池、富媒体等概念都很复杂，本轮 Prompt 进一步变长。

这带来两个后续问题：

- 成本会升高；
- 真实模型更可能在长上下文中丢字段或稀释关键架构约束。

这也是下一步做 A/B 的必要性所在。

---

## 8. 结论

本轮 run-002 可以判定为成功。

因为我们已经完成：

- 一份高价值 ArkTS 时间线原材料；
- 一个高质量的 Architecture Skill 试产；
- 一条与上游消息合批 Skill 紧密衔接的渲染架构链；
- 一次成功的 mock 模式全链路生成。

最重要的是，本轮证明了：

- 我们的 ArkTS 主线不仅能抽取“状态”和“消息合批”；
- 也能进一步抽取“聊天时间线虚拟化渲染”这种真正贴近 Telegram 级复杂度的高压能力。

---

## 9. 下一步建议

下一步最值得做的，就是立刻执行真实模型 A/B：

- 用真实 API 重新生成同一个 Skill；
- 对比 mock 与 real 的结构保持力和内容深度；
- 判断真实模型是否会在 `Architecture Mapping` 和 `Performance Envelope` 上塌陷；
- 反推 Prompt 是否需要压缩或强化。

如果真实模型也能稳住，那么我们的 V2 模具就真正进入可规模化阶段了。
