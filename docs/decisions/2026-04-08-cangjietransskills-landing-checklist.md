# 2026-04-08 CangjieTransSkills 选择性吸收落位执行清单

## 1. 文档目的

本文将 [2026-04-08-cangjietransskills-absorption-plan-draft.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/docs/reports/2026-04-08-cangjietransskills-absorption-plan-draft.md) 进一步收敛为可执行的落位清单，回答三个更具体的问题：

1. 学长项目中拟吸收的内容应该分别落到 `docs/`、`scripts/` 还是 `full-pass sidecar`；
2. 每一条吸收动作的最小产物、最小验证和明确禁区是什么；
3. 在当前 `Phase05 -> Phase06` 主线下，哪些项应先做，哪些项应延后。

本文属于“外部仓选择性引入方式”的执行决策补充，不替代 [AGENTS.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/AGENTS.md)、
[current-phase.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/.claude/status/current-phase.md) 和 `artifacts/*` 原始证据。

## 2. 适用范围与硬约束

### 2.1 适用范围

本文只覆盖以下上游来源中的选择性吸收：

- [CLAUDE.md](/tmp/CangjieTransSkills-main/CLAUDE.md)
- [base-skill/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/base-skill/SKILL.md)
- [build.py](/tmp/CangjieTransSkills-main/.claude/skills/build/build.py)
- [harmonyos-ui-inspect/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/SKILL.md)
- [ui_capture.py](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py)
- [evolution/SKILL.md](/tmp/CangjieTransSkills-main/.claude/skills/evolution/SKILL.md)

### 2.2 硬约束

所有动作必须同时满足：

- 不破坏 `Phase05` 默认 baseline；
- 不改变当前 `summary/report/validator/promotion` 口径；
- 不引入第二套 SSOT；
- 不把 Mac 上成立的默认路径直接外推到 Windows/Linux；
- 不整包引入 700+ markdown 文档镜像。

### 2.3 当前主线优先级

在执行本清单时，当前仓的主线优先级保持不变：

1. 守住 `env -u SILICONFLOW_API_KEY bash scripts/run_mass_translation.sh docs/manifests/batch_manifest_phase05.json` 的 keyless deterministic baseline；
2. 基于 `raw_docs/phase06-ui-p0` 与 `docs/manifests/phase06_ui_source_corpus_p0.json` 建下一阶段 manifest；
3. 保住 Windows `artifacts/fullpass/windows-bcm-interop-closed-summary.json` 对应的 `full-pass-achieved` 证据。

## 3. 落位总图

| Lane | 目标 | 上游来源 | 目标落位 | 优先级 | 默认状态 |
|---|---|---|---|---|---|
| `docs/` | 吸方法层，不吸镜像正文 | `CLAUDE.md`、`base-skill`、`evolution`、taxonomy 类说明 | `docs/development-workflow.md`、新建路由/索引/模板文档 | `P0` | 应立即推进 |
| `scripts/` | 吸环境发现与工程元数据探测内核 | `build.py`、`ui_capture.py` 的非 UI 执行部分 | 新 helper + 现有 `find_harmony_artifact.py` / `scripts/README.md` / tests | `P1` | 在不扰动主线前提下推进 |
| `full-pass sidecar` | 吸 UI scenario DSL 与交互断言能力 | `ui_capture.py`、`harmonyos-ui-inspect/SKILL.md` | 新 sidecar 脚本 + opt-in refresh integration + schema/example + tests | `P2` | 只做 sidecar，不替代当前 gate |

## 4. `docs/` 落位清单

### `D-01`：把上游路由顺序吸收到现有开发流程文档

- 目标：
  - 将 `CLAUDE.md + base-skill` 的问题域路由顺序改写进本仓的协作说明。
- 上游来源：
  - [CLAUDE.md:5](/tmp/CangjieTransSkills-main/CLAUDE.md#L5)
  - [base-skill/SKILL.md:8](/tmp/CangjieTransSkills-main/.claude/skills/base-skill/SKILL.md#L8)
- 目标落位：
  - 更新 [development-workflow.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/docs/development-workflow.md)
- 最小产物：
  - 一节新的“外部参考仓查询优先级 / 问题域路由”说明
- 最小验证：
  - `test -f docs/development-workflow.md`
  - 文档内容不与 [AGENTS.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/AGENTS.md) 的 Skill Routing Matrix 冲突
- 禁区：
  - 不复制学长仓 `.env` 约定
  - 不引入“学长仓路由优先于本仓 SSOT”的措辞

### `D-02`：新增一页“选择性参考索引矩阵”

- 目标：
  - 将 `cangjie-kernel / cangjie-harmony` 的 taxonomy 提纯为本仓可用的查询矩阵。
- 上游来源：
  - `cangjie-kernel/SKILL.md`
  - `cangjie-harmony/SKILL.md`
- 目标落位：
  - 新增 `docs/architecture/cangjietransskills-reference-routing-matrix.md`
- 最小产物：
  - 只列当前项目高频主题，如：
    - 语言核心
    - ArkUI / Ability
    - interop
    - build/toolchain
    - UI 自动化
    - 文档下载兜底
- 最小验证：
  - `test -f docs/architecture/cangjietransskills-reference-routing-matrix.md`
  - 与 [scripts/README.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/scripts/README.md) 中现有脚本入口无冲突
- 禁区：
  - 不复制 `cangjie-harmony/**/*.md`
  - 不复制 `cangjie-kernel/**/*.md`

### `D-03`：新增经验记录模板，不替代 run-level 证据

- 目标：
  - 把 `evolution` 的记录方式改写为本仓可复用模板，用于沉淀桥接、构建、ArkUI、UI 自动化坑点。
- 上游来源：
  - [evolution/SKILL.md:18](/tmp/CangjieTransSkills-main/.claude/skills/evolution/SKILL.md#L18)
- 目标落位：
  - 新增 `docs/strategy/cangjietransskills-experience-record-template.md`
- 最小产物：
  - 模板字段至少包含：
    - 问题现象
    - 根因
    - 解决方式
    - 命令
    - 结果
    - 产物路径
    - 相关文档
- 最小验证：
  - `test -f docs/strategy/cangjietransskills-experience-record-template.md`
- 禁区：
  - 不用经验条目替代 `summary.json / report.json / failure.json`
  - 不把模板写成新 SSOT

### `D-04`：在原草案中补执行清单回链

- 目标：
  - 让分析草案和执行清单互相可导航。
- 目标落位：
  - 更新 [2026-04-08-cangjietransskills-absorption-plan-draft.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/docs/reports/2026-04-08-cangjietransskills-absorption-plan-draft.md)
- 最小产物：
  - 一段“后续执行清单见 `docs/decisions/...`”的回链
- 最小验证：
  - `rg -n "landing-checklist|执行清单" docs/reports/2026-04-08-cangjietransskills-absorption-plan-draft.md`

## 5. `scripts/` 落位清单

### `S-01`：新增环境发现 helper，只吸 `build.py` 的无副作用内核

- 目标：
  - 吸收 `build.py` 的环境发现与路径标准化思路，但不复制其默认构建流程。
- 上游来源：
  - [build.py:14](/tmp/CangjieTransSkills-main/.claude/skills/build/build.py#L14)
  - [build.py:42](/tmp/CangjieTransSkills-main/.claude/skills/build/build.py#L42)
  - [build.py:78](/tmp/CangjieTransSkills-main/.claude/skills/build/build.py#L78)
- 目标落位：
  - 新增 `scripts/harmony_env_probe.py`
- 最小产物：
  - 只负责：
    - `.env` 读取
    - DevEco / Cangjie SDK 路径发现
    - `envsetup` 环境捕获
    - Windows/Linux/macOS 路径标准化
- 最小验证：
  - 新增 `tests/test_harmony_env_probe.py`
  - `python -m unittest discover -s tests -p 'test_harmony_env_probe.py' -v`
- 禁区：
  - 不自动写回 `.openvk-version`
  - 不新增默认 `hvigor` 构建入口
  - 不把 `entry@default / product=default` 写死成通用行为

### `S-02`：扩展现有 `find_harmony_artifact.py`，不要再造第二套工程探测器

- 目标：
  - 将 `ui_capture.py` 中的项目元数据自动发现思路吸入现有探测器，而不是新增平行脚本。
- 上游来源：
  - [ui_capture.py:246](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L246)
  - [ui_capture.py:1138](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L1138)
- 现有落位基础：
  - [find_harmony_artifact.py](/volume/wzhang/cky-workspace/my_projects/Cangjie/scripts/find_harmony_artifact.py)
- 目标动作：
  - 优先增强现有脚本：
    - 自动项目根向上搜索
    - 多模块 / 多 `module.json5` 选择策略
    - `.hap` 候选优先级策略
    - 与 `host probe` 输出的字段对齐
- 最小验证：
  - 更新或新增 `tests/test_find_harmony_artifact.py`
  - `python -m unittest discover -s tests -p 'test_find_harmony_artifact.py' -v`
- 禁区：
  - 不新增第二个功能重叠的 `detect_project_info.py`
  - 不改变现有 `env` 输出字段名

### `S-03`：更新脚本目录说明，确保 helper 不被误判为主入口

- 目标：
  - 明确新增 helper 的职责边界，避免“辅助脚本”被当成默认入口。
- 目标落位：
  - 更新 [scripts/README.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/scripts/README.md)
- 最小产物：
  - 为 `harmony_env_probe.py` 与增强后的 `find_harmony_artifact.py` 补齐：
    - 用途
    - 输入
    - 输出
    - 依赖
    - 执行示例
- 最小验证：
  - `rg -n "harmony_env_probe|find_harmony_artifact" scripts/README.md`
- 禁区：
  - 不在 README 中把 helper 写成“默认 build 入口”
  - 不在 README 中弱化现有 `run_mass_translation.sh` 与 `full-pass-*` 的主线地位

### `S-04`：本轮不做的脚本项

- 不迁入学长仓整份 `build.py`
- 不新增新的统一 `build.sh` / `build.py` 去取代当前 pipeline
- 不引入任何默认依赖 GUI target 的脚本到 `Staging-Core`

## 6. `full-pass sidecar` 落位清单

### `F-01`：先定义 scenario DSL 的 repo-local 规范

- 目标：
  - 把 `ui_capture.py` 的动作/断言模型沉淀为本仓可维护的 sidecar 输入契约。
- 上游来源：
  - [ui_capture.py:41](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L41)
  - [harmonyos-ui-inspect/SKILL.md:140](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/SKILL.md#L140)
- 目标落位：
  - 新增 `docs/schemas/full-pass-ui-scenario.schema.json`
  - 新增 `docs/schemas/examples/full-pass-ui-scenario.sample.json`
- 最小产物：
  - 支持的动作至少包含：
    - `click`
    - `input`
    - `swipe`
    - `wait`
    - `snapshot`
  - 支持的断言至少包含：
    - `exists`
    - `text_equals`
    - `page_changed`
- 最小验证：
  - 以 repo-local example 做 schema 校验
- 禁区：
  - 不在第一步引入“自动生成 scenario”能力
  - 不让 scenario schema 直接替代 BCM/SMOKE 断言来源

### `F-02`：新增 UI sidecar runner，但默认关闭

- 目标：
  - 吸收 `ui_capture.py` 的目标匹配与交互执行内核，做成可复用的 sidecar runner。
- 上游来源：
  - [ui_capture.py:576](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L576)
  - [ui_capture.py:801](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L801)
  - [ui_capture.py:855](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L855)
  - [ui_capture.py:957](/tmp/CangjieTransSkills-main/.claude/skills/harmonyos-ui-inspect/ui_capture.py#L957)
- 目标落位：
  - 新增 `scripts/full-pass-ui-sidecar.py`
- 最小产物：
  - 输入：
    - `--scenario`
    - `--bundle`
    - `--ability`
    - `--target-id`
    - `--hdc-path`
    - `--out`
  - 输出：
    - `layout.before.json`
    - `layout.after.json`
    - `diff.json`
    - `sidecar-report.json`
- 最小验证：
  - 新增 `tests/test_full_pass_ui_sidecar.py`
  - `python -m unittest discover -s tests -p 'test_full_pass_ui_sidecar.py' -v`
- 禁区：
  - 不把 sidecar 输出直接视为 Full Pass 通过
  - 不要求 sidecar 成为 `full-pass-harmony-refresh.sh` 的必填步骤

### `F-03`：以 opt-in 方式挂接到现有 refresh harness

- 目标：
  - 让 UI sidecar 成为 `full-pass-harmony-refresh.sh` 的可选扩展，而不是替代。
- 现有基础：
  - [full-pass-harmony-refresh.sh](/volume/wzhang/cky-workspace/my_projects/Cangjie/scripts/full-pass-harmony-refresh.sh)
- 目标动作：
  - 为 refresh harness 增加可选环境变量：
    - `FULL_PASS_UI_SIDECAR_SCENARIO`
    - `FULL_PASS_UI_SIDECAR_ENABLE`
    - `FULL_PASS_UI_SIDECAR_OUT`
  - sidecar 输出写入 `run_root/full-pass-sidecar/`
- 最小验证：
  - `bash -n scripts/full-pass-harmony-refresh.sh`
  - 现有 `FULL_PASS_UI_SIDECAR_ENABLE=0` 默认路径行为不变
- 禁区：
  - 不改变当前 install / launch / exercise / filter / summary build 顺序
  - 不让 sidecar 成为 `FULL_PASS_EXPECTED_ASSERTIONS` 的唯一来源

### `F-04`：第二阶段再决定是否接入 summary builder

- 目标：
  - 只在 sidecar runner 稳定后，才考虑将其作为辅助证据并入 Full Pass summary。
- 现有基础：
  - [full-pass-summary-builder.py](/volume/wzhang/cky-workspace/my_projects/Cangjie/scripts/full-pass-summary-builder.py)
  - [full-pass-summary-validate.py](/volume/wzhang/cky-workspace/my_projects/Cangjie/scripts/full-pass-summary-validate.py)
- 目标动作：
  - 第二阶段可选增加：
    - `--sidecar-report`
    - `--sidecar-artifact-dir`
  - 仅把 sidecar 作为 supplementary evidence，不替换 Hilog / parsed_events 主证据面
- 最小验证：
  - 现有 example summary 仍能通过：
    - `python scripts/full-pass-summary-validate.py --summary docs/schemas/examples/full-pass-summary.valid.json --report <tmp>`
- 禁区：
  - 不允许 sidecar report 单独驱动 `promotion_assessment=full-pass-achieved`
  - 不允许弱化当前 BCM/SMOKE 断言闭环

### `F-05`：本轮不做的 sidecar 项

- 不直接迁入学长仓整份 `ui_capture.py`
- 不在第一轮实现“源码扫描自动生成 scenario”
- 不把 `screenshot + interaction_report.md` 直接写进 current-phase 作为通过证据

## 7. 推荐执行顺序

### 第一轮：只做 `docs/`

原因：

- 风险最低；
- 不动主线执行入口；
- 能最快把“怎么吸收”从口头约定变成 repo-local 文档约束。

建议顺序：

1. `D-04`
2. `D-01`
3. `D-03`
4. `D-02`

### 第二轮：做 `scripts/`

原因：

- 先补“环境发现 / 元数据探测”内核，再谈 UI sidecar；
- 可直接为后续 Windows / DevEco / Harmony 项目辅助脚本复用。

建议顺序：

1. `S-01`
2. `S-02`
3. `S-03`

### 第三轮：做 `full-pass sidecar`

原因：

- sidecar 是增强件，不是主线 blocker；
- 必须在 schema、脚本、refresh integration 和验证边界都明确后再进主仓。

建议顺序：

1. `F-01`
2. `F-02`
3. `F-03`
4. `F-04`

## 8. 暂不推进项

以下动作在当前阶段明确延后：

- 整包迁入 `cangjie-harmony/**/*.md`
- 整包迁入 `cangjie-kernel/**/*.md`
- 迁入 `cangjie-translate` 当前空壳经验目录
- 新建通用 `build.py` 替代当前 pipeline
- 让 UI sidecar 直接改写 current-phase / AGENTS 口径

## 9. 收口结论

本执行清单把“学长仓如何被吸收”拆成了三条互不混淆的线：

- `docs/`：只吸方法层和模板
- `scripts/`：只吸无副作用 helper 内核
- `full-pass sidecar`：只吸 UI 交互 DSL 与辅助证据能力

只要严格按这三条线推进，当前仓就能一边继续守住 `Phase05 -> Phase06 -> Full Pass` 主线，一边逐步吸收学长项目里真正有价值的部分，而不会把现有证据链退回去。
