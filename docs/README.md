# 文档索引

本目录用于承载项目的正式文档基线，目标是帮助后续人类成员与 AI Agent 快速理解项目背景、范围、约束和执行顺序。

## 文档清单

- `project-overview.md`
  - 项目背景、目标、范围、交付要求、当前约束。
- `roadmap.md`
  - 分阶段路线图、里程碑、阶段退出条件、当前阻塞。
- `requirements-baseline.md`
  - 项目级需求下限、范围边界、Skill 最低要求与阶段推进闸门。
- `evaluation-criteria.md`
  - Skill、翻译样本、阶段推进与最终验收的统一评测口径。
- `sample-record-template.md`
  - 小样本翻译与验证记录模板，用于 UI/路由、持久化、网络、日志四类样本。
- `execution-trace-template.md`
  - 单次执行链路模板，用于记录翻译、编译、报错分析、重试与回写过程。
- `resources.md`
  - 外部仓库、官方文档、工具入口、待补齐输入。
- `glossary.md`
  - 当前项目中常见术语与缩写释义。
- `development-workflow.md`
  - 后续开发、验证、记录与回写建议流程。
- `phase-03-execution-roadmap.md`
  - `Phase 03` 的执行版路线图、`3A / 3B / 3C` 硬闸门、`Staging-Core / Staging-Full` 定义与风险清单。
- `samples/ui-routing-DefiningPageLayout.md`
  - 首个 UI / 路由样本的完整翻译记录、差异分析与单测策略。
- `traces/trace-ui-routing-001.md`
  - 首个 UI / 路由样本的执行轨迹、检索路径与修复决策。
- `directory-structure.md`
  - 仓库目录职责说明与放置约定。
- `decisions/`
  - 架构、目录、工具选择等关键决策记录。
- `reports/`
  - 阶段汇报、实验结论、验证复盘与周报。
- `reports/2026-03-26-frontier-research-and-skill-strategy.md`
  - 针对 Skill 重要性、技术前沿、样本路线与构建方案的专项调研结论。

## 建议阅读顺序

1. `AGENTS.md`
2. `docs/status/INDEX.md`
3. `docs/current_state.v2.md`
4. `docs/status/current_task_handoff.md`
5. `/.claude/mission-control.md`
6. `docs/project-overview.md`
7. `docs/requirements-baseline.md`
8. `docs/evaluation-criteria.md`
9. `docs/roadmap.md`
10. `docs/resources.md`
11. `docs/directory-structure.md`
12. `docs/development-workflow.md`
13. 需要旧背景或长历史时再读 `/.claude/status/current-phase.md`

## 更新原则

- 项目目标、优先级或范围变化时，先更新 `AGENTS.md`，再同步更新本目录相关文档；
- 新增外部资源、样本、脚本或验证结论时，应补充到对应文档；
- 文档应明确区分“已确认事实”和“待确认事项”；
- 若文档与代码不一致，应优先补齐说明，避免后续 Agent 基于过时信息行动。
