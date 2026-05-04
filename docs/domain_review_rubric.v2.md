# Domain Review Rubric v2

更新时间：`2026-04-18`

## 0. Glossary / Object Model / State Semantics

### Repo-specific canonical terms

#### `P22 / 311-311 frozen-pass checkpoint`

- object / scope：`Phase06 regular` 当前正式冻结的最高 checkpoint。
- canonical meaning：它承载 repo 当前最后一个正式 promoted checkpoint，而不是“可自然继续升格到 P23 的中间站”。
- authority or anchor：`docs/reports/2026-04-14-phase06-p22-regular-promotion.md`、`docs/current_state.v2.md`。
- not_equal_to：不等于 `Phase07` continuation lane，不等于 exploratory sample green，也不等于 `P23 mechanical-ready`。
- reviewer consequence：若把它误读成“P23 默认下一步”，后续 agent 会重开一个已被 reviewer 否决的 promotion 分支。

#### `Phase07 Telegram UI Incubation`

- object / scope：post-P22 之后独立存在的 bounded continuation lane。
- canonical meaning：它只允许沿 shared harness / Telegram app-shell / regression-first rail 做 repo-local continuation，不回写 `Phase06 regular` 正式 promotion 身份。
- authority or anchor：`specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`、`docs/current_state.v2.md`、当前 landed consume-slice reports。
- not_equal_to：不等于 `Phase06 regular` reserve expansion，不等于 `P23 relaunch`，也不等于 broader rollout。
- reviewer consequence：若把它写回 `Phase06` 或 `P23`，正式 checkpoint、current lane 与 promotion gate 会同时漂移。

#### `Linux Staging-Core / Windows Staging-Full`

- object / scope：当前 continuation lane 与更高等级 staging claim 的分层语义。
- canonical meaning：`Linux Staging-Core` 只证明 repo-local compile / unit / behavior；`Windows Staging-Full` 才承载更高一级的 physical / full-pass 语义。
- authority or anchor：`docs/domain_review_rubric.v2.md`、`docs/current_state.v2.md`、`artifacts/fullpass/*`。
- not_equal_to：二者不在同一层，不允许相互代写。
- reviewer consequence：若把 repo-local Linux 结果写成 Windows / Full Pass，continuation lane 会被包装成超出真实边界的能力证明。

### Recommended starter pack

#### `task / lane / checkpoint / authority_surface`

- `task` means：当前 handoff 或 report 中可独立落地、独立验证的 bounded slice，例如 `P1-41` consume slice。
- `lane` means：repo 级正在推进的主线，例如 `Phase07 Telegram UI Incubation`。
- `checkpoint` means：lane 内被 reviewer 接受并冻结的阶段节点，例如 `P22` 或某个 landed continuation slice。
- `authority_surface` means：足以改写 reviewer-visible promotion / staging 结论的正式 report、full-pass evidence 或 freeze review。
- not_equal_to：`task` 不等于 `lane`；`checkpoint` 不等于任意 sample 绿灯；`authority_surface` 不等于 README、raw docs 或 manifest 草稿。
- reviewer consequence：若四者混写，局部 sample / slice 结果会被错误抬升成 repo 当前阶段身份。

#### `consume_surface / evidence_only_surface / legacy_history_surface`

- `consume_surface` means：当前 `Phase07` 官方可继续恢复和消费的 shared-harness / Telegram app-shell reports、verification contracts 与 current state surfaces。
- `evidence_only_surface` means：解释当前边界的 sample、cache probe、raw docs 或 report bundle，本身不单独改写 promotion 身份。
- `legacy_history_surface` means：README 旧 `Phase03` 叙事、`.claude/status/current-phase.md`、`raw_docs/phase06-ui-p23` 与其它历史 / exploratory pages。
- resume semantics：默认只从 `consume_surface` 和 live truth 恢复；`evidence_only_surface` 按需读取；`legacy_history_surface` 只在追溯旧背景时读取。
- not_equal_to：`evidence_only_surface` 不等于当前 consume entry；`legacy_history_surface` 更不等于 live truth。
- reviewer consequence：若边界失守，旧 `Phase03`、`P23` exploratory assets 或 cache probe 会反向覆盖当前 `Phase07` 主线。

### Object model

#### `bounded continuation slice`

- lifecycle / ownership：由 `Phase07` 按 slice 递增落盘，先报告、再验证、再决定是否继续扩大边界。
- canonical role：作为当前 continuation lane 的最小 consume / regression 单元。
- visible to whom：`reviewer + planner`、`executor` 与当前 repo-local consumer 都可见。
- not_equal_to：不等于正式 promotion checkpoint、不等于 `P23` basis、也不等于 broader rollout approval。
- reviewer consequence：若把 bounded slice 写成 promoted checkpoint，后续 lane 会在 reviewer 未批准前被无界扩张。

### State semantics

#### `task_status / lane_status`

- `task_status` means：单个 consume slice、report 或 handoff task 的状态，例如 landed / blocked / in_review。
- `lane_status` means：repo 当前主线在更高层的身份结论，例如 `Phase07 exploratory-only continuation lane`。
- not_equal_to：task 绿灯不等于 lane 已 promotion-ready；lane exploratory-only 也不等于 task 无法继续 landed。
- reviewer consequence：若把 task 和 lane 混写，局部 slice 通过会被误写成 repo 正式升格。

#### `passed / accepted / archived`

- `passed` means：某个本层 build/runtime/report gate 在其局部标准下通过。
- `accepted` means：该结果已被 reviewer 接受，可进入当前层 consume 或 checkpoint 叙事。
- `archived` means：对象已进入历史留档，不再是默认 resume surface。
- not_equal_to：`passed` 不等于 `accepted`；`accepted` 不等于 promoted；`archived` 不等于“可以忽略其旧约束”。
- reviewer consequence：若三者混为“已完成”，promotion、resume 与历史边界会一起失真。

#### `planning_freeze_passed / execution_ready`

- `planning_freeze_passed` means：某个 continuation slice 的 requirements / design / tasks / verification contract 已冻结，允许继续做 bounded implementation / regression。
- `execution_ready` means：更高层 promotion 或 staging authority 已明确允许进入下一等级的 execution / rollout 叙事。
- not_equal_to：`Phase07` slice landed，不自动推出 `P23 mechanical-ready`、`Windows Staging-Full` 或 broader rollout ready。
- reviewer consequence：若把前者写成后者，repo-local continuation 结果会被误写成正式升格依据。

#### `raw_truth / effective_truth / reviewer_truth`

- `raw_truth` means：sample、raw docs、cache probe、local command results 与 exploratory artifacts。
- `effective_truth` means：在当前 `Phase07 exploratory-only` posture 下允许 repo 官方消费的 continuation-lane truth。
- `reviewer_truth` means：reviewer 基于正式 checkpoint、freeze review 与 full-pass authority 给出的最终 promotion / staging 结论。
- not_equal_to：`raw_truth` 不等于 current consume entry；`effective_truth` 不等于 promotion；`reviewer_truth` 也不等于任意 sample 的自我描述。
- reviewer consequence：若三层 truth 混写，`P22`、`Phase07` 与 `P23` 会被错误拼成一条连续乐观主线。

## 1. Canonical Boundary Pairs

### `P22 / 311-311 live passed / direct P23 mechanical-ready = No`

- 一句话定义：`P22 / 311/311 live passed` 是当前正式冻结 checkpoint；`direct P23 mechanical-ready = No` 是 post-P22 review 对下一步 promotion 的明确否决，不是待补写的空白位。
- 正证据长什么样：同一套正式证据同时保留 `docs/reports/2026-04-14-phase06-p22-regular-promotion.md` 和 post-P22 freeze / review 结论，且 `raw_docs/phase06-ui-p23` 等资产被降级为 exploratory only。
- 什么还不足以支持这个判断：看到 p23 scout、p23 mock、p23 manifest 或某个 sample 可以编过。
- 最常见混淆：把“P22 已封顶”误写成“P23 只差一点点就默认可升格”。
- 判错后果：后续 agent 会重新点燃一个已经被 reviewer 关闭的 promotion 方向。

### `Phase07 continuation lane / Phase06 regular reserve expansion`

- 一句话定义：`Phase07 Telegram UI Incubation` 是 post-P22 之后独立的 continuation lane；它不再属于 `Phase06 regular` reserve expansion。
- 正证据长什么样：当前任务与文档同时引用 `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`、`p0-3 verification contract`、`p1-7 detail-route retarget` 等 Phase07 surfaces。
- 什么还不足以支持这个判断：只是继续碰到了 Telegram UI、shared harness 或 cache sample，就被自然表述成“Phase06 下一批”。
- 最常见混淆：把 `Phase07` 的 bounded sample work 写成 `Phase06 regular` 延长线。
- 判错后果：正式 checkpoint、promotion gate 和 continuation lane 身份会全部混乱。

### `exploratory seed input / promoted evidence`

- 一句话定义：`samples/telegram-ui-vertical-slice-001`、`raw_docs/phase06-ui-p23` 这类对象当前只能是 exploratory input；promoted evidence 必须来自正式 checkpoint 或明确 landed continuation-lane artifact。
- 正证据长什么样：同一段结论会显式保留 “sample / seed / exploratory-only” 语义，并把 promoted claim 仅绑定到 `P22` 或已 landed 的 report + artifact bundle。
- 什么还不足以支持这个判断：某个 sample `cjpm test` 全绿、某个 app-shell slice 落地、某个目录结构很完整。
- 最常见混淆：把样本代码的可运行性当成 promotion 资格。
- 判错后果：后续 agent 会越权把 sample 直接升级为 live / promoted / mechanical-ready basis。

### `Linux Staging-Core / Windows Staging-Full`

- 一句话定义：`Linux Staging-Core` 只负责 repo-local compile / test / behavior；`Windows Staging-Full` 才对应更高一级的 full-pass / physical evidence 语义。
- 正证据长什么样：`Phase07` 只引用 Linux sample、`cjpm test`、runtime binary 和 verification artifacts；Windows 证据仍单独留在 `artifacts/fullpass/*`。
- 什么还不足以支持这个判断：某个 Linux sample 行为通过，或 shared harness 在 repo-local package 中可用。
- 最常见混淆：把 `Phase07` 的 repo-local consume slice 写成 Windows / Harmony 级能力证明。
- 判错后果：continuation lane 会被错误包装成远高于其真实边界的 staging claim。

### `cjpm test / timeout 5s unittest binary`

- 一句话定义：`cjpm test` 负责 build + unit 层；`timeout 5s ./target/release/unittest_bin/...` 才是 post-build runtime / no-deadlock gate。
- 正证据长什么样：同一轮验证同时给出 build / unit 结果和 post-build runtime 结果，两者都通过。
- 什么还不足以支持这个判断：只有 `cjpm test` 绿了，或只看到二进制存在。
- 最常见混淆：把第二个命令重新说成“又跑了一次单测”，从而抹掉 runtime/no-deadlock 语义。
- 判错后果：真实的启动挂死或 runtime deadlock 会被错误地吞进 unit green。

### `mixed timeout 5s cjpm test / timeout 5s cjpm test --skip-build`

- 一句话定义：mixed `timeout 5s ... cjpm test` 目前只是 compile-budget probe；`timeout 5s ... cjpm test --skip-build` 才是 cache sample 当前 canonical runtime/no-deadlock gate。
- 正证据长什么样：文档明确保留 mixed wrapper `124` 和 `--skip-build` 全绿并存，并把前者分类为 compile-budget known risk。
- 什么还不足以支持这个判断：只看到 mixed wrapper 返回 `124`，就直接宣判 runtime deadlock。
- 最常见混淆：把 build budget 超时和 runtime hang 混成一个红灯。
- 判错后果：cache sample 会被误报为不可继续推进，导致不必要的回滚或错误修复方向。

## 2. Promotion Ladder

### `baseline_guard_green`

- 进入条件：`Phase05` baseline manifest 或当前 bounded sample 的 canonical build/runtime gate 通过。
- 还不够进入下一层的伪证据：只完成一半验证，或只靠 mixed `5s` probe 判绿。
- 对下游意味着什么：说明 guardrail / local slice 没坏，但这本身不是 promotion。

### `phase07_slice_landed`

- 进入条件：bounded `Phase07` 切片有明确 report、source artifact、verification command 和 evidence bundle。
- 常见误写：把 landed slice 写成 `Phase06 regular` 新 checkpoint，或直接写成 live / promoted。
- 对下游意味着什么：可以作为 continuation-lane 的当前 consume entry，但仍必须保持 exploratory-only 语义。

### `formal_checkpoint_frozen`

- 进入条件：正式 promotion report、audit 和 coverage surface 全部闭合，例如当前的 `P22 / 311/311 live passed`。
- 还不够进入下一层的伪证据：landed continuation slice、exploratory sample 全绿、或新的 strategy/design 文档。
- 对下游意味着什么：这是当前真正能承载“正式阶段状态”的 authority。

### `mechanical_ready`

- 进入条件：存在明确 freeze review / promotion review 把下一步写成 mechanical-ready。
- 当前状态：不存在；当前明确结论仍是 `direct P23 mechanical-ready = No`。
- 对下游意味着什么：没有 reviewer 正式改写之前，任何 agent 都不能自己把 continuation lane抬升到这一层。

### `windows_staging_full_or_full_pass_claim`

- 进入条件：需要独立的 Windows / physical evidence，而不是 repo-local Linux sample 通过。
- promotion 必须依赖的 authority：`artifacts/fullpass/*` 这类明确 full-pass / interop-closed evidence。
- 对下游意味着什么：只有到这一层，才允许做更高等级的 Full Pass / physical staging 叙事。

## 3. Reviewer Gates

- 一票否决型 blocker：
  - 任何改写 `P22 / 311/311 live passed` 或把 `P23 mechanical-ready = No` 写没的叙事。
  - 任何把 `raw_docs/phase06-ui-p23`、`docs/manifests/phase06_ui_*_p23*.json`、`artifacts/ui_pilots/20260414-phase06-ui-p23-*` 当作 live input 或 promoted basis 的动作。
  - 任何把 `Phase07` sample / harness / app-shell slice 写成 Windows `Staging-Full`、Harmony live、promoted lane、Full Pass 或 `Phase06 regular` 新批次。
  - 任何把 mixed `timeout 5s ... cjpm test = 124` 直接定性为 runtime deadlock 的叙事。
  - 任何 clean shell 缺失 toolchain env 却仍把结果归因到当前代码切片本身。
- 可后置但必须显式说明的风险：
  - repo-local 仓颉 toolchain 注入仍是强依赖；不注入就会出现假红灯。
  - `Phase07` 当前只有 bounded continuation-lane 语义，没有 promotion / live 语义。
  - `Phase05` baseline rerun 能证明 guardrail 稳定，但不能替代 `Phase07` 当前 consume entry 的语义。
- 只影响叙述质量、不影响主线推进的问题：
  - report prose 还可以继续压缩。
  - sample / report 命名还能更统一。
  - 只要 authority split 不变，文档结构重排本身不是 blocker。

## 4. Common Narrative Traps

- 把 README 里的 `Phase03` 叙事继续当当前唯一事实。
- 把 `P22` 正式冻结和 `P23` 被否决的结论压成一句“post-P22 继续推进”。
- 把 `Phase07` repo-local sample 绿灯写成 promoted / live / full-pass 证据。
- 把 `Phase05` baseline rerun 误写成 `Phase07` 新进展。
- 把 mixed `5s` compile-budget probe 误写成 runtime deadlock。
- 把 Linux `Staging-Core` 和 Windows `Staging-Full` 混成同一层 staging 语义。

## 5. Common Failure Modes

- 环境注入缺失：`CANGJIE_HOME`、`PATH`、`LD_LIBRARY_PATH`、`CANGJIE_STDLIB_PATH` 未注入，导致假红灯。
- 边界错位：`Phase05`、`Phase06`、`Phase07` 的证据面被写成一条连续单线。
- 词义塌缩：`landed`、`promoted`、`mechanical-ready`、`full-pass` 被混用。
- 运行合同错配：`cjpm test`、post-build runtime binary、mixed `5s` wrapper 三种 gate 没有分开。
- sample 身份漂移：seed input 与 promoted basis 被混写。

## 6. Update Rules

只有当仓库特有词义、阶段定义或 reviewer gate 真正变化时才更新本文件。
