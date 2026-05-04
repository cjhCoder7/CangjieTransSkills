# Cangjie

面向 HarmonyOS / 仓颉语言的代码翻译与 Skill 构建项目。

当前仓库的当前 authority 以 `AGENTS.md`、`docs/status/INDEX.md`、`docs/current_state.v2.md`、`docs/status/current_task_handoff.md` 为准；本 README 只提供项目概览与入口导航，不单独承载最新阶段判断。

## 当前目标

- 构建面向仓颉代码翻译的 `Agent + Skill` 工作流；
- 优先建设鸿蒙应用开发 Skill 能力；
- 先用小型 ArkTS Demo 验证 `ArkTS → 仓颉` 的翻译闭环；
- 验证稳定后，再推进 Telegram ArkTS 版本的仓颉化；
- 项目后期补齐 `Swift → 仓颉` 与 `Java/Python → 仓颉` 的转换验证。

## 建议阅读顺序

1. `AGENTS.md`：项目协作规则、模式路由、热区索引；
2. `docs/status/INDEX.md`：默认续接入口、latest report / raw_log_root / 状态索引；
3. `docs/current_state.v2.md`：项目级当前快照、active lane、allowed moves；
4. `docs/status/current_task_handoff.md`：当前 task 的持续状态、blocker、下一步；
5. `/.claude/mission-control.md`：`.claude` 辅助入口，已对齐到以上主路径；
6. `docs/README.md`：文档索引与使用方式；
7. `docs/project-overview.md`：项目背景、目标、范围、交付标准；
8. `docs/roadmap.md`：历史阶段划分、里程碑、退出条件；
9. `docs/resources.md`：外部仓库、文档、工具入口；
10. 需要旧背景或长历史时再读 `/.claude/status/current-phase.md` 与 `idea.md`。

## 当前目录

```text
.
├── AGENTS.md              协作总纲与约束入口
├── docs/                  项目正式文档
├── research/              调研、样本分析、映射与实验记录
├── scripts/               数据处理、检索、评测、自动化脚本
├── skills/                项目自建 Skill 内容
├── samples/               小型验证样本
├── third_party/           外部参考仓库或镜像代码
├── artifacts/             运行产物、日志、转换轨迹
└── idea.md                原始会议纪要
```

## 注意事项

- `idea.md` 保留原始讨论记录，但不应继续复制其中的敏感信息；
- 所有密钥统一通过环境变量或本地未提交配置管理；
- 外部仓库若被引入，必须记录来源链接、拉取时间和版本信息；
- 任何新实验都应留下输入、方法、结果与问题记录，保证可追溯。
