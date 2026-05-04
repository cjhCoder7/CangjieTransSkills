# 2026-04-08 学长 CangjieTransSkills 吸取方案草案

## 1. 文档目标

本文用于回答四个问题：

1. 当前仓库应不应该切换到学长项目作为主线；
2. 学长项目里哪些内容值得吸收，哪些只能改造后吸收，哪些不建议吸收；
3. 吸收动作应该落到 `docs/`、`scripts/` 还是其他层；
4. 如何在不破坏当前 `Phase05 -> Phase06` 主线的前提下推进后续协作。

本文是**仓内草案**，不是新的 SSOT。当前状态裁决仍以 [AGENTS.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/AGENTS.md)、
[current-phase.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/.claude/status/current-phase.md) 与 `artifacts/*` 原始证据为准。

## 2. 当前仓主线对齐

### 2.1 Session Header 对齐结论

根据 [AGENTS.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/AGENTS.md#L8) 与 [current-phase.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/.claude/status/current-phase.md#L3)，当前仓库不是“待搭框架”的早期仓，而是已经具备以下主线资产：

- `Phase 05` keyless deterministic baseline；
- `docs/manifests/batch_manifest_phase05.json` 覆盖当前 10-target 全量语料；
- `raw_docs/phase06-ui-p0` 与 `docs/manifests/phase06_ui_source_corpus_p0.json` 已冻结为下一阶段 source corpus；
- Windows `artifacts/fullpass/windows-bcm-interop-closed-summary.json` 与 `windows-bcm-interop-closed-report.json` 已形成 `full-pass-achieved` 证据；
- `scripts/run_mass_translation.sh`、`scripts/pipeline_runner.py`、`scripts/pipeline_batch_runner.py`、`scripts/full-pass-summary-validate.py` 已构成当前默认执行与验证闭环。

### 2.2 本草案的约束

本草案必须同时满足四个优先目标：

- 性能；
- 稳健性；
- 可复现性；
- 证据链完整。

因此，任何“吸收学长项目”的动作都不得削弱当前仓的：

- deterministic baseline；
- structured evidence；
- promotion gate；
- `Staging-Core` / `Staging-Full` 分层口径。

## 3. 外部来源冻结

### 3.1 来源

- 交流纪要：[idea2.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/idea2.md)
- 学长项目快照：[资源/CangjieTransSkills-main (1).zip](/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/CangjieTransSkills-main%20%281%29.zip)
- 本地解压路径：`/tmp/CangjieTransSkills-main`

### 3.2 冻结方式与时间

- 分析日期：`2026-04-08 UTC`
- 冻结方式：`zip 快照只读分析`
- 口径限制：未核到对应 Git branch / commit / PR 上下文，因此**不得**将本草案表述为“对学长远端主线的最终判断”。

### 3.3 快照结构事实

执行命令：

```bash
unzip -l '资源/CangjieTransSkills-main (1).zip'
cd /tmp/CangjieTransSkills-main && rg --files --hidden -g '*.md' | wc -l
cd /tmp/CangjieTransSkills-main && rg --files --hidden -g '*.py' | wc -l
find /tmp/CangjieTransSkills-main -maxdepth 3 \( -type d -name tests -o -type d -name src -o -type d -name artifacts -o -type d -name raw_docs -o -type d -name samples \) | sort
```

结果：

- `zip` 条目时间为 `2026-04-08 20:02`
- `markdown = 701`
- `python = 3`
- 未发现 `tests/`、`src/`、`artifacts/`、`raw_docs/`、`samples/`

结论：

- 学长项目当前更接近 `skills + 文档镜像 + 少量辅助脚本`；
- 它不是和当前仓同构的 `pipeline / evidence / artifacts` 主线工程仓。

## 4. 输入与证据范围

### 4.1 当前仓证据

- [AGENTS.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/AGENTS.md)
- [current-phase.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/.claude/status/current-phase.md)
- [scripts/README.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/scripts/README.md)

### 4.2 学长项目关键文件

- [CLAUDE.md](/tmp/CangjieTransSkills-main/CLAUDE.md)
- [base-skill/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/base-skill/SKILL.md)
- [build/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/build/SKILL.md)
- [build.py](/tmp/CangjieTransSkills-main/.claude/skills/build/build.py)
- [harmonyos-ui-inspect/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/SKILL.md)
- [ui_capture.py](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py)
- [cangjie-translate/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/cangjie-translate/SKILL.md)
- [evolution/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/evolution/SKILL.md)
- [download-script/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/download-script/SKILL.md)

### 4.3 分析方法

本轮按以下顺序分析：

1. 先对齐当前仓热区；
2. 冻结外部来源；
3. 以 `性能 / 稳健性 / 可复现性 / 证据链` 为四个主尺度做模块级判断；
4. 对每个模块给出 `直接吸收 / 改造后吸收 / 不建议吸收` 分类；
5. 输出不改变当前主线的执行顺序。

## 5. 核心判断

### 5.1 战略定位

当前仓应继续作为：

- `执行主线`
- `证据主线`
- `promotion 裁决主线`

学长项目应定位为：

- `上游参考技能仓`
- `知识组织与路由参考层`
- `轻量 build / UI 辅助工具参考层`

不建议把学长项目改写为当前仓的主线基座，原因如下：

1. 当前仓已经形成 `pipeline -> verifier -> summary/report -> validator -> promotion` 闭环；
2. 学长项目缺少与此等价的 `artifacts / schema / tests / promotion gate`；
3. 学长项目的 build/UI 自动化更偏单机、单项目、单次调试；
4. 当前仓已经拿到 `Phase05` deterministic baseline 与 Windows `full-pass-achieved`，不应为对齐而回退。

### 5.2 当前最重要的边界

本方案坚持以下红线：

- 不新建第二套 SSOT；
- 不替换当前默认执行入口；
- 不把 Mac 上成立的链路直接外推到 Windows/Linux；
- 不将文档镜像整仓并入当前主仓；
- 不把 `screenshot + markdown report` 直接上升为 Full Pass promotion 依据。

## 6. 模块吸收矩阵

### 6.1 可直接吸收

#### `CLAUDE.md`

可吸收内容：

- skill 路由顺序；
- 工作流表达方式；
- 协作 triage 话术。

原因：

- [CLAUDE.md](/tmp/CangjieTransSkills-main/CLAUDE.md#L5) 对 `base-skill -> kernel -> harmony -> translate -> build -> ui-inspect -> evolution -> download-script` 的顺序表达清晰；
- 这类内容属于“方法层”，不会直接冲击当前证据体系。

吸收方式：

- 改写为本仓协作文档或 runbook 中的“查询优先级”段落；
- 不直接照搬 `.env`、commit message、项目结构等仓特定字段。

#### `base-skill/SKILL.md`

可吸收内容：

- 按问题域选择 skill 的 triage 模式。

原因：

- [base-skill/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/base-skill/SKILL.md#L8) 把“语言核心 / 鸿蒙开发 / 编译构建 / 代码翻译 / 经验总结 / UI 检测 / 原始文档”切得足够清楚；
- 这能减少后续查资料和技能调用时的来回跳转。

#### `evolution/SKILL.md`

可吸收内容：

- 经验条目模板；
- 经验索引方式。

原因：

- [evolution/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/evolution/SKILL.md#L18) 的模板足够简洁，适合沉淀桥接、ArkUI、构建和环境坑；
- 但它不能替代当前 run-level 证据链，因此只吸模板，不吸“经验记录取代证据”的口径。

### 6.2 改造后吸收

#### `build.py`

建议吸收的内核：

- `.env` 解析；
- `~/.cangjie-sdk` 自动发现；
- `envsetup` 环境捕获。

参考位置：

- [build.py:14](/tmp/CangjieTransSkills-main/.claude/skills/build/build.py#L14)
- [build.py:42](/tmp/CangjieTransSkills-main/.claude/skills/build/build.py#L42)
- [build.py:78](/tmp/CangjieTransSkills-main/.claude/skills/build/build.py#L78)

不应原样吸收的部分：

- `.openvk-version` 缺失时直接写回默认值；
- `entry@default` 与 `product=default` 固定假设；
- 脚本相对路径向上跳四级找项目根；
- 无测试、无 summary/report schema、无失败工件归档。

建议落位：

- 若后续需要，可在 `scripts/` 新增独立的 `harmony_env_discovery` 或 `deveco_build_prelight` 辅助脚本；
- 不替代当前 `pipeline` 或 `full-pass` 默认入口。

#### `harmonyos-ui-inspect/SKILL.md` + `ui_capture.py`

建议吸收的内核：

- scenario DSL；
- target matching 优先级；
- per-step `dumpLayout -> execute -> diff -> assertion` 执行模型；
- bundle/ability/HAP 自动发现思路。

参考位置：

- [ui_capture.py:41](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L41)
- [ui_capture.py:576](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L576)
- [ui_capture.py:801](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L801)
- [ui_capture.py:855](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L855)
- [ui_capture.py:957](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L957)
- [ui_capture.py:1138](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L1138)

不应原样吸收的部分：

- 偏 `.env + PATH + macOS 常见路径` 的 `hdc` 探测；
- `1333` 行单文件、缺少测试；
- 输出只落 `ui_summary.md / diff.json / interaction_report.md`，未对齐当前 `full-pass summary/report` schema；
- 更适合作为“临场 UI 调试器”，不适合作为 promotion gate。

建议落位：

- 作为 `scripts/full-pass-*` 的 sidecar 能力或独立 helper；
- 目标是把其 DSL/断言能力桥接到当前 `full-pass summary` 体系，而不是额外引入一套结果口径。

#### `cangjie-harmony/SKILL.md` 与 `cangjie-kernel/SKILL.md`

建议吸收的部分：

- taxonomy；
- 主题索引法；
- 查询矩阵组织方式。

原因：

- 它们适合帮助本仓建立更清晰的“去哪查什么”索引；
- 但不适合把整套文档树搬进当前主仓。

建议落位：

- `docs/` 下的索引页、能力矩阵或查阅矩阵；
- 不复制文档镜像本体。

#### `download_hm_docs.py`

建议吸收的部分：

- sparse checkout；
- branch fallback；
- index 生成思路。

前提：

- 只有在后续确认当前仓确实缺“官方文档离线冻结器”时才考虑；
- 当前优先级低于 `Phase05/Phase06` 主线。

### 6.3 不建议吸收

#### `cangjie-harmony/**/*.md` 与 `cangjie-kernel/**/*.md` 文档本体

不建议吸收原因：

- 体量过大；
- 维护成本高；
- 上下文噪声大；
- 当前边际收益低；
- 未为每份镜像补齐上游 commit/date/provenance。

它们更适合作为外部查询来源，不适合作为当前主仓资产整体引入。

#### `cangjie-translate`

不建议吸收原因：

- 当前几乎还是流程说明；
- 缺少成熟经验沉淀；
- 对当前项目的直接价值低于真实 pipeline 证据。

参考位置：

- [cangjie-translate/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/cangjie-translate/SKILL.md#L12)

#### 任何会形成第二套 SSOT 的入口文件

不建议吸收原因：

- 当前仓已明确 `AGENTS.md + current-phase.md + artifacts/*` 为状态裁决链；
- 引入第二套 authoritative 路由会持续污染后续协作。

## 7. 风险登记

### 7.1 证据链回退风险

如果把 `ui_capture.py` 的 `interaction_report.md` 直接当作通过证据，会绕开当前仓的：

- `summary.json`
- `report.json`
- schema validator
- promotion assessment

这会直接损害当前 `Full Pass` 口径。

### 7.2 可复现性回退风险

如果直接复用 `build.py` 的默认行为，会引入以下不稳定因素：

- 隐式写入 `.openvk-version`
- 自动选择“最新”SDK
- 固定 `entry@default` / `product=default`
- 单项目路径假设

这会冲击当前仓已经守住的 deterministic baseline。

### 7.3 平台误判风险

学长项目当前已知更偏 Mac 验证路径。若未经改造直接并入：

- Windows/Linux 可能出现 `hdc` 探测漂移；
- 目标设备选择不稳定；
- `HAP` 发现路径不一致；
- GUI 依赖被错误抬升为默认门槛。

### 7.4 文档膨胀风险

若整包吸入 700+ markdown 文档镜像：

- 会显著增加检索噪声；
- 会稀释当前仓的核心上下文；
- 会抬高后续维护成本。

## 8. 推荐执行顺序

### 8.1 第一阶段：只吸方法层

目标：

- 不动主线执行入口；
- 先把可低风险复用的方法层吸进来。

动作：

1. 把 `CLAUDE.md + base-skill` 改写为本仓协作路由文案；
2. 把 `evolution` 的经验模板改写为本仓可检索经验条目格式。

建议落位：

- `docs/`
- 必要时补一页协作路由或经验模板说明

### 8.2 第二阶段：脚本内核 sidecar 化

目标：

- 吸 `build.py` 与 `ui_capture.py` 的能力内核；
- 不替代当前默认执行链。

动作：

1. 抽出 `build.py` 的环境发现逻辑；
2. 设计 `ui_capture DSL -> full-pass summary bridge`；
3. 将其作为 `scripts/full-pass-*` 的 sidecar 能力或新 helper。

通过标准：

- 不改变当前 `scripts/run_mass_translation.sh`、`pipeline_runner.py`、`full-pass-summary-validate.py` 默认语义；
- 不引入新的 promotion 口径。

### 8.3 第三阶段：按需建立文档索引

目标：

- 只吸 taxonomy，不吸镜像正文。

动作：

1. 如果确有需要，再基于 `cangjie-harmony` / `cangjie-kernel` 建“查阅矩阵”；
2. 仅保留当前项目真正高频的主题入口；
3. 将大体量镜像继续留在外部来源，不整体迁入。

## 9. 近期推荐动作

本草案建议的近期下一步只有一件：

1. 基于本草案，再出一份**落位更具体的执行清单**，明确哪些项落 `docs/`、哪些项落 `scripts/`、哪些项先不做。

原因：

- 当前最值钱的主线仍是守住 [current-phase.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/.claude/status/current-phase.md#L6) 中已经明确的 `Phase05 baseline` 与 `Phase06 corpus`；
- 现在不应为了“吸收学长项目”打断现有翻译与证据主战线；
- 当前还没有必要搬迁大规模文档，最该优先的是方法层和 sidecar 能力设计。

对应执行清单见：

- [2026-04-08-cangjietransskills-landing-checklist.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/docs/decisions/2026-04-08-cangjietransskills-landing-checklist.md)

## 10. 本轮分析方式记录

本轮先后使用了：

- `codebase-onboarding`
- `repo-scan`
- `documentation-templates`
- `sequential-thinking`

同时按 `Planner -> Implementer -> Analyst -> Reviewer` 启用了四个只读子代理，统一结论如下：

- `Planner`：学长仓是上游参考操作层，当前仓是下游证据主线；
- `Implementer`：最值得吸的是方法论和脚本内核，不是整仓内容；
- `Analyst`：直接替换会回退证据链、可复现性和跨平台稳健性；
- `Reviewer`：不能把学长 zip 误判成 Telegram 主线进度，也不能让其替代当前 pipeline/evidence/schema 底座。

## 11. 收口结论

本草案的最终判断是：

- `当前仓继续做主线`
- `学长仓只做选择性上游参考`
- `先吸方法层，再做脚本 sidecar 化，最后才考虑文档索引提纯`

只要坚持这个顺序，你当前已经跑出来的 `Phase05`、`Phase06`、Windows `Full Pass` 证据就不会因为“对齐学长项目”而回退。
