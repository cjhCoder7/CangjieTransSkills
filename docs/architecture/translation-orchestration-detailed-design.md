# Translation Unit 与翻译编排详细设计

## 1. 文档目的

本文是 `docs/architecture/repo-scale-translation-stack-design.md` 的子设计文档之一，专门细化仓库级翻译栈中的翻译单元、流水线编排、验证回路与经验沉淀机制。

本文重点回答以下问题：

1. 应如何定义 `Translation Unit`，才能让大型 ArkTS 模块被安全切分为可验证的最小作战单元；
2. `Translate → Review → Verify → Repair` 四个阶段应交换哪些工件、遵守哪些契约；
3. 错误驱动检索应在什么时机触发，并如何与 `Repo Index / Repo Map` 协同；
4. 如何把成功与失败沉淀为 `Pattern Memory`，形成越来越聪明的流水线。

本文只覆盖翻译单元、编排流程、验证机制与经验回写，不展开 Repo Index 的底层存储细节。

---

## 2. Translation Unit 的设计目标

`Translation Unit` 的设计目标不是方便分文件，而是让每一次翻译都满足以下四个条件：

1. **职责边界清晰**：知道当前单元在系统里负责什么；
2. **依赖闭包可计算**：知道首轮最少要带什么上下文；
3. **验证口径明确**：知道翻完后用什么证据判定成败；
4. **失败可局部修复**：知道出错后如何局部重试，而不是整页重写。

对于 Telegram 级别的工程，这四点比“翻译覆盖率高”更重要。

---

## 3. Translation Unit 类型体系

## 3.1 建议类型

建议至少定义以下 TU 类型：

1. `UI Shell Unit`
2. `State Core Unit`
3. `ViewModel / Presenter Unit`
4. `Service Adapter Unit`
5. `Domain Model Unit`
6. `Router / Navigation Unit`
7. `Interop Bridge Unit`
8. `Persistence Unit`
9. `Reactive Pipeline Unit`
10. `Verification Harness Unit`

## 3.2 各类型边界说明

### 3.2.1 `UI Shell Unit`

负责：

- 页面结构；
- 组件组合；
- 事件入口；
- 路由参数读取后的 UI 呈现。

不负责：

- 复杂状态拥有权；
- 长链异步效果调度；
- Native / C 边界；
- 深层缓存一致性策略。

### 3.2.2 `State Core Unit`

负责：

- 状态定义；
- 所有权；
- 可变字段与衍生字段；
- 生命周期范围；
- 一致性与持久化规则。

这是最需要契约化的 TU 类型之一。

### 3.2.3 `ViewModel / Presenter Unit`

负责：

- 事件到状态变更的映射；
- 异步效果发起；
- 状态提交节奏；
- UI 更新组织。

### 3.2.4 `Service Adapter Unit`

负责：

- 服务接口包装；
- 请求上下文管理；
- 错误映射；
- 与下游仓储、网络、桥接层的协作。

### 3.2.5 `Domain Model Unit`

负责：

- 类型定义；
- 协议对象；
- 序列化映射；
- 不可变或值语义契约。

### 3.2.6 `Router / Navigation Unit`

负责：

- 路由注册；
- 参数传递；
- 页面跳转生命周期衔接。

### 3.2.7 `Interop Bridge Unit`

负责：

- ArkTS 与 Native / C / TDLib 边界；
- ABI、线程、内存、错误传播；
- 回调转发与安全封装。

### 3.2.8 `Persistence Unit`

负责：

- 本地存储接口；
- 缓存读写；
- 状态恢复；
- 刷盘与一致性策略。

### 3.2.9 `Reactive Pipeline Unit`

负责：

- Signal / Store / Event 流转；
- 批量更新；
- 节流、防抖、合并；
- 主线程更新收敛。

### 3.2.10 `Verification Harness Unit`

负责：

- mock；
- 测试支架；
- 行为对拍输入输出；
- 供 Verify 使用的最小验证入口。

---

## 4. 复杂页面切分规范

## 4.1 总体原则

面对一个大型 ArkTS 页面，切分顺序建议为：

1. 先找边界；
2. 再找职责；
3. 最后才找视图。

原因是：大型页面最容易被错误地看成“UI 文件”，但真正的难点往往埋在状态、线程、回调和长列表更新里。

## 4.2 边界优先识别项

建议优先剥离以下区域：

- 路由适配与参数注入；
- 状态定义与状态拥有者；
- 异步任务发起点；
- Store / Signal / Cache 接入点；
- 主线程更新提交点；
- 生命周期钩子；
- Native 回调入口；
- 长列表与批量合并逻辑。

## 4.3 5000 行页面的推荐切分模板

对于超大页面，建议至少拆为以下 TU：

1. `Page Route Adapter`
2. `Page State Core`
3. `Page Event Dispatcher`
4. `Async Effect Coordinator`
5. `UI Composition Shell`
6. `List Rendering Subunit`
7. `Store / Service Adapter`

若页面复杂度更高，再增补：

8. `Timeline Delta Merge Unit`
9. `Virtualization Policy Unit`
10. `Interop Callback Bridge`

### 4.3.1 为什么不建议按函数平均切分

按函数平均切分会导致：

- 状态所有权被撕裂；
- 审查阶段看不到跨函数 contract；
- Verify 阶段难以定义可执行 oracle；
- Repair 阶段反复陷入“局部正确、整体失配”。

---

## 5. TU 元数据设计

每个 TU 都建议携带一份结构化元数据。其作用不是“描述得好看”，而是为 Translate、Review、Verify、Repair 提供统一接口。

## 5.1 必备字段

建议至少包含：

- TU ID；
- TU 类型；
- 来源快照；
- 来源文件 / 符号范围；
- 目标输出路径；
- 责任边界说明；
- 强依赖列表；
- 弱依赖列表；
- 相关 Skill 列表；
- 相关 Pattern Memory 列表；
- 线程约束；
- 状态所有权说明；
- 互操作约束；
- 验证 oracle；
- 风险等级；
- 建议翻译顺序；
- token 预算。

## 5.2 可选字段

建议在高风险模块中补充：

- 预期失败模式；
- 推荐错误驱动补拉路径；
- 是否允许多轮 Repair；
- 是否依赖相邻 TU 先完成。

---

## 6. 依赖闭包消费规则

本文不再定义 Repo Index 内部结构，但定义编排层如何消费它。

## 6.1 两层闭包模型

建议 Translation 流程显式区分：

- `Base Closure`：首轮翻译默认携带；
- `Extended Closure`：仅在错误触发时按需补拉。

## 6.2 Base Closure 的内容建议

Base Closure 通常包含：

- 当前 TU 源片段；
- 直接调用的关键签名；
- 直接读写的状态拥有者契约；
- 相关线程 / 生命周期约束；
- 必要的 Repo Map 摘要；
- 相关 Skill 与高相关 Pattern。

## 6.3 Extended Closure 的内容建议

Extended Closure 只在下列场景补拉：

- 编译缺符号；
- 接口签名不匹配；
- 状态 contract 违反；
- 线程切换错误；
- 互操作边界错误；
- 行为对拍不一致。

---

## 7. Translate 阶段详细设计

## 7.1 输入工件

Translate 阶段建议接收以下工件：

- TU 元数据；
- Base Closure；
- Repo Map 摘要；
- 相关 Skill；
- 相关 Pattern；
- 目标语言约束与输出要求。

## 7.2 输出工件

建议输出：

- 候选代码；
- 目标文件清单；
- 关键映射说明；
- 自述的不确定点；
- 自述的高风险点；
- 推荐优先验证项。

## 7.3 Translate 阶段的设计原则

- 翻译员不负责最终 correctness；
- 翻译员必须显式暴露不确定点；
- 翻译员不应私自扩大 TU 边界；
- 对不完整上下文，优先显式声明，而不是隐式臆造。

---

## 8. Review 阶段详细设计

## 8.1 Review 的角色定位

Review 不是“语气审校”，而是“架构契约审查”。

它应主要检查：

- 是否违反状态所有权；
- 是否违反主线程 / 后台线程约束；
- 是否破坏 Signal / Store / Cache 语义；
- 是否遗漏互操作边界规则；
- 是否越过 TU 责任边界；
- 是否削弱后续验证可行性。

## 8.2 输入工件

- 候选代码；
- TU 元数据；
- 相关 Skill；
- 相关 Pattern；
- Repo Map 风险摘要。

## 8.3 输出工件

建议输出结构化问题清单，每项问题至少包含：

- 问题 ID；
- 问题等级；
- 问题类型；
- 证据位置；
- 风险说明；
- 建议修复方向；
- 是否需要补拉上下文。

## 8.4 问题等级建议

- `blocker`：禁止进入 Verify；
- `major`：允许进入 Verify，但需重点观察；
- `minor`：可进入 Verify，作为优化建议记录；
- `note`：仅作为后续 Pattern 沉淀参考。

---

## 9. Verify 阶段详细设计

## 9.1 Verify 的定位

Verify 必须优先依赖“可执行证据”。

建议 Verify 关注以下证据类型：

- 编译是否通过；
- mock contract 是否通过；
- 单元测试是否通过；
- 行为对拍是否一致；
- 关键页面或关键路径是否可运行。

## 9.2 输入工件

- 审查后的候选产物；
- TU 验证 oracle；
- 相关测试或 mock harness；
- 必要的环境与日志约束。

## 9.3 输出工件

建议输出：

- 编译结果；
- 测试结果；
- 行为验证结果；
- 失败分类；
- 失败证据；
- 是否进入 Repair；
- 是否应回写新的 Pattern 或 Failure Taxonomy。

## 9.4 实现无关验证原则

建议 Verify 尽量使用“实现无关”标准：

- 只要 contract 和行为一致，就不因实现细节不同而判失败；
- 只要状态边界和线程边界正确，就允许内部组织方式有所变化；
- 不把文本相似度作为核心指标。

---

## 10. Repair 阶段详细设计

## 10.1 Repair 的定位

Repair 的目标是“利用失败证据做最小修复”，而不是“让模型重新自由发挥”。

## 10.2 输入工件

- 失败分类；
- 失败证据；
- 已翻译代码；
- 原 TU 元数据；
- 错误驱动补拉上下文。

## 10.3 输出工件

- 修复后的候选代码；
- 修复说明；
- 新增上下文说明；
- 若未修复成功，则输出根因假设和建议下一步。

## 10.4 Repair 的节制原则

- 只修当前失败相关区域；
- 不主动扩张 TU 边界；
- 不因局部失败而重写整个模块；
- 若连续失败，应优先怀疑索引质量或闭包质量，而不是盲目增加生成轮次。

---

## 11. 错误驱动检索详细设计

## 11.1 触发条件

建议在以下情况触发：

- Review 明确判断“缺少上下文”；
- Verify 出现可归类的编译错误；
- Verify 出现 contract 级行为错误；
- 同类错误在同一模块反复出现；
- Repair 两轮仍未收敛。

## 11.2 错误分类建议

建议至少区分：

1. `missing symbol`
2. `signature mismatch`
3. `state contract violation`
4. `thread boundary violation`
5. `interop boundary violation`
6. `lifecycle ownership violation`
7. `behavior mismatch`
8. `verification harness mismatch`
9. `retrieval insufficiency`
10. `index quality issue`

## 11.3 分类到补拉策略的映射

### 11.3.1 `missing symbol`

补拉优先级：

- 目标符号定义；
- 导入导出链；
- 邻近实现；
- 父接口签名。

### 11.3.2 `state contract violation`

补拉优先级：

- 状态拥有者定义；
- 写路径与读路径；
- 生命周期范围；
- 持久化与恢复策略。

### 11.3.3 `thread boundary violation`

补拉优先级：

- 主线程提交点；
- 异步边界；
- 回调入口；
- 生命周期钩子。

### 11.3.4 `interop boundary violation`

补拉优先级：

- Bridge contract；
- 线程切换要求；
- 生命周期 / 内存规则；
- 错误传播规则。

### 11.3.5 `behavior mismatch`

补拉优先级：

- 原实现行为轨迹；
- mock contract；
- 相邻 TU 协作上下文；
- 历史 Failure Pattern。

---

## 12. Verification Oracle 模型

## 12.1 Oracle 必备字段

建议每个 oracle 至少包含：

- 验证类型；
- 可执行入口；
- 观察信号；
- 成功判定；
- 典型失败症状；
- 是否允许实现无关评判；
- 是否依赖 mock；
- 是否依赖上游或下游 TU。

## 12.2 Oracle 模板建议

建议为不同 TU 类型准备不同模板：

- `UI Shell Oracle`
- `State Core Oracle`
- `Service Adapter Oracle`
- `Interop Bridge Oracle`
- `Reactive Pipeline Oracle`

这样能让 Verify 和 Repair 更早实现结构化，而不是每次从头定义测试口径。

---

## 13. Pattern Memory 详细设计

## 13.1 成功模式条目建议

建议每条成功 Pattern 至少包括：

- Pattern ID；
- 源侧模式；
- 目标侧模式；
- 适用前提；
- 禁用条件；
- 影响边界；
- 推荐 TU 类型；
- 推荐验证方式；
- 已验证样例；
- 常见误用。

## 13.2 失败模式条目建议

建议每条 Failure Pattern 至少包括：

- Failure ID；
- 错误分类；
- 触发条件；
- 失败表象；
- 根因判断；
- 推荐补拉上下文；
- 推荐修复策略；
- 是否已被规则覆盖；
- 是否已被索引改进吸收；
- 关联 Trace。

## 13.3 Pattern Memory 的回写触发点

建议在以下时机回写：

- 某个 TU 经过 Verify 明确成功；
- 同类失败重复出现两次以上；
- 一次 Repair 明显依赖新补拉上下文才成功；
- 同一失败被确认为索引质量问题而非翻译问题；
- 某个 Reviewer 规则经多次验证被证明有效。

## 13.4 Pattern 与 Skill 的协同方式

建议保持分层：

- Skill 提供通用知识和系统约束；
- Pattern Memory 提供本项目实战验证过的映射套路；
- Failure Pattern 反向推动 Skill 增补失败模型和禁用条件。

---

## 14. 运行指标与阶段性判断

为了避免流水线只“看起来很忙”，建议尽早记录以下指标：

- 单个 TU 首轮通过率；
- Review 拦截率；
- Verify 失败分类分布；
- Repair 收敛轮次；
- 因索引不足导致的失败比例；
- 因错误驱动补拉而成功的比例；
- 可沉淀为 Pattern 的成功任务比例。

这些指标能帮助判断：

- 问题更多出在 Index / Map；
- 还是出在 TU 切分；
- 还是出在 Review 规则不足；
- 还是出在 Verify 口径不清。

---

## 15. 当前阶段落地建议

建议后续实现按以下顺序推进：

1. 先为 2~3 类高价值 TU 定义元数据模板；
2. 再为这些 TU 定义对应 oracle；
3. 再把现有重试逻辑抽象成 Translate / Review / Verify / Repair 四段；
4. 再引入错误驱动补拉；
5. 最后才扩展到更多 TU 类型与更多模块。

这种顺序符合当前仓库“先做最小验证，再扩展范围”的原则。

---

## 16. 总结

本设计的核心思想是：真正决定仓库级代码翻译能否落地的，不是让模型一次看更多代码，而是让每一次翻译都围绕一个边界清晰、依赖可算、验证明确、失败可修的 `Translation Unit` 运转。

只要 TU 切得对，编排接口清楚，错误驱动检索能精确补拉上下文，再加上 Pattern Memory 持续沉淀，流水线就会形成真正的工程闭环；反之，即使模型很强，也会在大型仓库中反复陷入“局部正确、全局失配”的循环。
