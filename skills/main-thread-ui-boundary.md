# Skill Metadata
- Skill ID: `ARCH-MAIN-THREAD-UI-BOUNDARY-001`
- Skill Name: `main-thread-ui-boundary`
- Skill Class: `Architecture`
- Scope: 聚焦 ArkTS 后台计算与主线程 UI 提交边界，约束高频消息、列表数据源通知、页面生命周期失效和状态提交出口
- Tags: [`线程边界`, `UI状态提交`, `后台计算`, `生命周期管理`, `高频消息处理`]
- Version: `2.0.1`

# Trigger Condition
- 任务触发条件：检测到 ArkTS 代码中存在后台线程直接修改 `@State`、`@Link`、`@Prop`、`@StorageLink` 或 AppStorage 状态，或后台线程直接调用数据源通知方法
- 强制触发条件：发现高频消息场景（如聊天、通知流）中后台线程直接持有页面组件引用或直接调用 UI 更新方法
- 不适用条件：纯后台服务类组件、无 UI 绑定的数据处理逻辑、非高频状态更新场景

# Core Concept
- 最短知识结论：后台计算与主线程 UI 提交必须严格分离，后台只输出最小变更包，主线程只负责状态提交与 UI 更新
- 一句话风险提示：违反此架构将导致页面卡顿、状态混乱、内存泄漏和不可预测的 UI 行为

# Architecture Mapping
- 源侧角色：ArkTS 中的页面组件、taskpool 任务、数据源通知机制、生命周期回调
- 目标侧角色：仓颉侧的后台协调器、主线程派发器、页面投影 Store 与统一 UI 提交出口
- 保留策略：保留后台计算与主线程提交的分离原则，保留最小变更包生成机制，保留生命周期管理责任
- 重构策略：将后台任务与页面组件的直接引用重构为通过协调器间接通信，将分散的数据源通知重构为统一提交出口

# Dependency Constraint
- 必需依赖：后台任务调度机制、主线程状态提交接口、生命周期管理器、版本校验机制
- 可选依赖：增量 diff 算法、批处理窗口聚合器、错误分类与重试标记系统
- 冲突依赖：与直接操作 UI 状态的后台任务、全量数据重载机制、无版本校验的结果提交
- 环境前提：需要支持后台线程与主线程通信的运行时环境，需要支持状态绑定与 UI 更新的框架机制

# Boundary Contract
- 边界类型：计算边界（后台与主线程之间）、生命周期边界（页面存活与销毁）、状态所有权边界（后台数据与 UI 状态）
- 输入：原始高频事件流、后台计算任务、页面状态变更请求
- 输出：最小变更包、UI 状态更新指令、数据源通知事件
- 生命周期归属：页面组件拥有 UI 状态所有权，协调器拥有任务调度与结果提交责任
- 资源释放责任：协调器负责取消后台任务与订阅，页面组件负责释放 UI 资源
- 错误传递方式：通过错误分类标记、可重试标记、版本校验失败信号传递错误信息

# Execution Topology
- 线程模型：后台线程负责计算，主线程负责 UI 提交，两线程通过协调器通信
- 主线程提交点：页面投影 Store 更新、数据源通知方法调用、UI 状态绑定更新
- 后台处理点：消息解码、合批、版本校验、最小变更包生成、增量 diff 计算
- 串行要求：后台任务内部可并行，但结果提交必须串行到主线程
- 批处理要求：高频事件必须在后台进行批处理窗口聚合，生成最小变更包后再提交

# State Contract
- 状态所有者：页面组件拥有 UI 状态，协调器拥有计算中间状态，后台任务拥有临时数据
- 真值来源：原始事件流、网络回包、本地缓存、用户输入
- 可变字段：后台计算中的临时数据、协调器中的中间结果、页面组件中的 UI 状态
- 衍生字段：基于原始数据计算出的增量变更、UI 投影状态、列表数据源快照
- 持久化策略：原始数据持久化到本地存储，UI 状态不持久化，中间计算结果不持久化
- 一致性规则：后台计算结果必须经过版本校验才能提交，UI 状态更新必须遵循最小变更原则

# Progressive Modules
## Module 1：概念最小版
- 实现后台计算与主线程提交的基本分离
- 建立简单的任务调度与结果提交机制
- 实现基本的版本校验防止旧结果覆盖新状态

## Module 2：常见映射
- 映射高频消息场景的增量处理逻辑
- 实现数据源通知的统一提交出口
- 建立页面生命周期与任务取消的关联机制

## Module 3：跨层模式
- 集成增量 diff 算法优化列表更新
- 实现批处理窗口聚合减少提交频率
- 建立错误分类与重试机制

## Module 4：工程级约束
- 实现完整的资源管理与释放机制
- 建立性能监控与卡顿预警系统
- 实现复杂场景下的状态一致性保证

# Translation Mapping
- ArkTS 对应写法：使用 taskpool 执行后台计算，通过 @State/@Link 绑定 UI 状态，调用数据源通知方法更新列表
- 仓颉对应写法：使用后台协调器管理任务，通过主线程派发器提交状态更新，使用统一 UI 提交出口处理数据源通知
- 允许差异：仓颉侧可使用更灵活的任务调度机制，可支持更细粒度的状态管理
- 禁止直译点：禁止将后台 taskpool 直接映射为仓颉线程池，禁止将数据源通知方法直接移植，禁止将页面组件生命周期回调直接复制

# Performance Envelope
- 主线程预算：主线程提交阶段应控制在 16ms 以内，避免阻塞 UI 渲染
- 吞吐量关注点：高频消息场景下后台处理能力应达到 1000+ 条/秒，主线程提交应支持 60fps 滚动
- 内存关注点：后台计算过程中应避免持有页面组件引用，防止内存泄漏
- 建议优化手段：实现后台任务优先级调度，使用对象池减少内存分配，实现增量更新减少全量重建

# Failure Model
- 失败场景：后台任务持有已销毁页面的引用、旧版本结果覆盖新状态、高频消息导致主线程提交阻塞
- 触发迹象：页面切换后仍收到旧数据更新、列表滚动卡顿、内存持续增长、页面无响应
- 恢复策略：实现任务取消机制、版本校验、主线程提交限流、资源定期清理
- 禁止修复方式：禁止在后台线程直接修复 UI 问题，禁止通过增加线程数解决性能问题，禁止绕过版本校验机制

# Verification Matrix
| 验证目标 | 输入条件 | 预期结果 | 验证层次 |
|---------|---------|---------|---------|
| 后台任务不直接修改 UI 状态 | 后台任务执行 | 状态更新通过主线程提交 | 单元测试 |
| 页面销毁后不再接收更新 | 页面生命周期销毁 | 后台任务被取消 | 集成测试 |
| 高频消息场景保持流畅 | 1000条/秒消息输入 | UI 保持60fps滚动 | 性能测试 |
| 版本校验防止旧结果覆盖 | 多个任务并发完成 | 只提交最新版本结果 | 并发测试 |
| 资源正确释放 | 长时间运行与页面切换 | 内存无泄漏 | 内存分析 |

# Composition With Other Skills
- 上游 Skill：`message-delta-merge-and-batching`（负责后台消息合并与批处理）
- 下游 Skill：`chat-timeline-virtualized-rendering`（负责虚拟化列表渲染）
- 组合顺序：先执行后台消息合并，再进行主线程状态提交，最后进行虚拟化渲染
- 误用风险：如果跳过后台合并直接提交原始消息，会导致主线程压力过大；如果绕过主线程提交直接操作 UI，会导致状态不一致

# Retrieval Fallback
- CLI / Python 检索示例: `rg -n "taskpool|@State|notifyDataReload" --type ts` 与 `python scripts/skill_generator_v2.py --source docs/raw_docs/arkts-main-thread-ui-boundary.md --skill-name main-thread-ui-boundary --skill-class Architecture`
- 官方资料回查入口: HarmonyOS 开发者文档 > 声明式UI > 状态管理 > 线程与性能
- 降级策略: 如果无法使用仓颉专用工具，可使用通用代码搜索工具查找相关模式
- rg -n: 使用 ripgrep 搜索 ArkTS 代码中的后台任务与 UI 状态相关模式
- python scripts/skill_generator_v2.py: 使用官方技能生成器
- --source: 指定源文档路径
- --skill-name: 指定技能名称
- --skill-class: 指定技能类型为 Architecture

# Security / Privacy Constraint
- 数据暴露边界：后台计算中的临时数据不应包含敏感信息，UI 状态不应直接暴露原始数据
- 线程安全约束：主线程提交点必须确保状态更新的原子性，防止竞态条件
- 隐私或敏感信息注意事项：后台任务中处理的数据应避免持有敏感引用，结果提交时应过滤敏感字段

# Migration Strategy
- 最小迁移路径：先识别并隔离直接修改 UI 状态的后台代码，建立协调器层，逐步迁移提交逻辑
- 过渡层：在迁移期间可使用适配器模式同时支持新旧提交机制
- 替换顺序：先迁移后台计算逻辑，再迁移提交机制，最后优化生命周期管理
- 回滚点：在完成完整测试前，保留原有提交逻辑作为回退方案

# Examples
- 概念性示例:
  ```
  // 后台协调器
  class BackgroundCoordinator {
      var pendingTasks: [Task]
      var currentPage: Page?

      func submitResult(_ result: CalculationResult) {
          guard currentPage?.isAlive == true && result.isLatestVersion else {
              return
          }

          DispatchQueue.main.async {
              self.updateUI(with: result.minimalChangeSet)
          }
      }
  }

  // 主线程提交器
  class MainThreadSubmitter {
      func updateUI(with changeSet: MinimalChangeSet) {
          store.apply(changeSet)
          dataSource.notifyChanges(changeSet)
      }
  }
  ```
- 伪代码:
  ```
  // 错误的做法 - 直接在后台修改UI状态
  taskpool {
      state.messages = decodedMessages  // 错误：直接修改UI状态
      listDataSource.notifyDataReload() // 错误：后台调用UI方法
  }

  // 正确的做法 - 后台生成变更包，主线程提交
  taskpool {
      let changeSet = generateMinimalChangeSet(from: rawMessages)
      DispatchQueue.main.async {
          applyChangeSet(changeSet)  // 主线程提交
      }
  }
  ```
- 结构草图:
  ```
  ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
  │  后台计算任务    │───▶│   协调器         │───▶│  主线程提交器   │
  │ (解码/合并/diff) │    │ (版本校验/任务管理)│    │ (状态更新/通知) │
  └─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
                                               ┌────────▼────────┐
                                               │   UI组件        │
                                               │ (@State绑定)    │
                                               └─────────────────┘
  ```

# Test & Debug
- 单测策略：测试后台计算逻辑的正确性、版本校验机制、最小变更包生成
- 集成验证：测试完整流程从后台计算到UI更新的端到端行为
- 诊断日志：记录任务创建、提交、取消时间点，记录版本冲突情况
- 排错步骤：检查内存泄漏、验证版本校验、监控主线程提交耗时、分析UI更新频率

# Sources
- 输入来源: `docs/raw_docs/arkts-main-thread-ui-boundary.md`
- 引用依据: HarmonyOS 声明式UI开发指南、ArkTS 线程与性能最佳实践

# Known Gaps
- 当前未知: 仓颉侧具体API实现方式、后台任务调度机制细节
- 待验证: 在真实DevEco Studio与仓颉运行时环境下的端到端性能表现
- 环境限制: 无法在当前环境下验证高频消息场景下的实际表现，尚未进行端到端环境验证

# Evolution Log
- 版本记录: `2.0.1`
- 本次改动: 修复了 Retrieval Fallback 章节缺少 CLI / Python 检索示例的问题，补充了完整的检索命令
- 后续补强方向: 补充仓颉侧具体API映射示例，完善性能测试用例，增加实际场景案例分析，进行端到端环境验证
