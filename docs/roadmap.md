# 项目路线图

## 当前正式状态 / 下一阶段

- 当前正式 checkpoint：`P22 / 311/311 live passed`
- `P23 mechanical-ready = No`
- post-P22 唯一 active direction：`phase summary / next-stage strategy`
- route-transition / archive / roadmap decisions 的 `canonical entry`：
  `docs/reports/2026-04-14-phase06-post-p22-phase-summary-and-next-stage-strategy.md`
- 本文其余 Phase 0 / Phase 1 / Phase 2 / Phase 3 / Phase 4 内容仅保留为历史阶段背景，不代表当前主线优先级或执行入口。

## 历史阶段背景：阶段划分

### Phase 0：文档与工程基线

目标：把项目从“会议纪要”推进到“可执行仓库”。

输出：

- `AGENTS.md` 协作总纲；
- `docs/` 文档目录；
- 基础仓库结构；
- 初步环境变量与产物管理约定。

退出条件：

- 后续 Agent 能从仓库中直接获得项目背景、范围、资源和目录约定；
- 初始目录职责明确；
- 明确当前优先级与未定事项。

### Phase 1：Skill 结构与文档抽取规范

目标：建立“文档 → Skill 单元”的最小转换规范。

输出：

- Skill 最小模板；
- 文档切片规则；
- 触发检索的规则说明；
- 一批试验性 Skill 单元。

退出条件：

- 至少能用一个示例说明如何从官方文档提炼出 Skill 单元；
- 明确哪些内容需要人工整理，哪些可自动化生成。

### Phase 2：ArkTS 小样本验证

目标：验证 `ArkTS → 仓颉` 的最小可行闭环。

输出：

- 1~3 个小型 ArkTS 样本；
- 翻译输入与输出；
- 编译 / 运行 / 问题记录；
- 样本评测标准。

退出条件：

- 至少一个样本完成可追溯翻译流程；
- 能说明成功与失败的判定标准；
- Skill 在样本场景中有明确价值。

### Phase 3：Telegram ArkTS 版本推进

目标：在小样本验证稳定后，逐步扩展到 Telegram ArkTS 工程。

输出：

- 模块拆解策略；
- 分阶段翻译计划；
- 功能验证清单；
- 关键坑位与兼容策略。

退出条件：

- 至少完成一段 Telegram ArkTS 模块级翻译与验证；
- 有持续扩展的任务拆解与里程碑安排。

### Phase 4：Swift 与第三语言补齐

目标：满足多语言转换考核要求。

输出：

- Swift 场景翻译方案；
- 第三语言源仓库与试验结果；
- 多语言共性与差异总结。

退出条件：

- 三种源语言均有明确的转换路径与至少一轮验证结果。

## 历史阶段背景：原始优先级

1. 文档与结构基线；
2. Skill 结构设计；
3. ArkTS 小样本验证；
4. Telegram ArkTS 工程推进；
5. Swift 与第三语言补齐。

## 历史阶段背景：原始阻塞

- 仓颉插件审批可能影响实际开发验证；
- 部分官方资料访问权限待确认；
- Swift 与第三语言源仓库尚未最终确定；
- 第一版评测标准已建立，但轨迹字段模板与量化阈值仍待后续细化。
