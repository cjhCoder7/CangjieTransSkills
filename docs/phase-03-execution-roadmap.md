# Phase 03 执行版路线图与风险清单

## 当前执行坐标（本轮口径）

- 目标模块：`MTProtoClient.ets`
- 当前状态：`Phase 3B passed / Phase 3C Conditional Pass achieved`
- 当前推进：`Linux Staging-Core` 继续推进 `MTProtoClient.ets` 的 `Translate -> Review -> Verify -> Repair`；Windows 侧进入 `Staging-Full` readiness 取证
- 当前目标：继续把 `MTProtoClient` 的 compile-failed 收敛为 source-aligned entity 修复，并补齐 Windows 宿主的 Full Pass 前提
- 当前关键 Skill：`skills/SKILL_SCHEMA_V2.md` + `docs/strategy/phase-03-source-alignment-directives.md`
- 当前说明：`RealMessageService.ets` 及其样本 harness 已是已绿基线；当前 run-level 主战场已切换到 `MTProtoClient.ets`，后续仍应以最新 run 证据包持续更新。


## 一、文档目的

本文件用于把当前仓库对 `Phase 03: Physical Iron Test` 的描述性口径，收敛为可执行、可检查、可回溯的证据驱动口径。

适用场景：

- 判断当前真实进度到底处于“准入 / 编译 / 行为验证”中的哪一层；
- 明确本项目中的 `staging` 不是传统 Web 预发布站点，而是模块级受控验证环境；
- 给后续 Agent、人类协作者和评审提供统一的 promotion 闸门；
- 把“阶段通过”从主观叙述改成“证据包是否齐全、硬闸门是否通过”。

本文件不替代 `AGENTS.md`、`docs/roadmap.md`、`docs/evaluation-criteria.md`，而是在其基础上对当前 `Phase 03` 做执行层细化。

---

## 二、当前状态重命名

当前仓库虽然整体仍处于 `Phase 03: Physical Iron Test`，但执行层不宜继续把所有工作混写为一个笼统阶段。建议从本文件开始，将 `Phase 03` 细化为三个硬闸门子阶段：

1. `Phase 3A: Admission & Safety Baseline`
2. `Phase 3B: Physical Compile Stabilization`
3. `Phase 3C: Runtime Semantic Closure`

### 2.1 当前判定

- 当前主状态建议记为：`Phase 3B passed`
- `Phase 3C` 建议记为：`Conditional Pass achieved`
- `Staging-Full` 建议记为：`readiness blocked by Windows / GUI / target / log capture gaps`

判定依据：

- `RealMessageService.ets` 已取得真实 `BUILD SUCCESS`，样本 harness 也已形成缓存、并发、域纯度与 UI 刷新闭环绿证，说明 `3B` 已经有稳定退出证据；
- `MTProtoConfig.ets`、`CryptoUtils.ets`、`TLMethods.ets`、`TLSerialization.ets`、`TLDialogs.ets` 已绿，`MTProtoClient.ets` 的当前红灯已下沉为真实 `compile-failed` / source-aligned entity 问题，而不是 `3A` 准入噪声；
- `Staging-Full` 仍缺 `DevEco Studio`、仓颉插件、`hdc`、target 与真实 UI/Hilog 回采链路，因此当前只能宣称 `Conditional Pass`，不能误报 `Full Pass`。

### 2.2 使用规则

后续任何任务、日报、trace、run summary、阶段判断都应至少声明以下字段：

- `phase_major`
- `phase_substage`
- `promotion_candidate`
- `evidence_status`
- `blocked_by`

若未声明，不应直接写“Phase 03 通过 / 失败”。

---

## 三、执行总原则

### 3.1 总原则

- 先过 `3A`，再谈 `3B`；先过 `3B`，再谈 `3C`；
- 任一阶段都必须留下证据包，不能只留下口头结论；
- 任何“通过”都应带有明确产物路径、命令、日志或报告；
- 任何“失败”都必须进入可分类、可复现、可修复的错误族；
- 不允许通过跳过静态安全检查或临时人工 patch 的方式伪造阶段通过。

### 3.2 当前主战场

当前建议把 `TelegramHarmony` 中的 `MTProtoClient.ets` 作为 Linux `Staging-Core` 的当前主战场，把 `RealMessageService.ets` 及其样本 harness 作为已绿行为基线，因为：

- `RealMessageService.ets` 已完成 `Phase 3B` BUILD SUCCESS 与多类行为闭环，继续承担回归锚点；
- `MTProtoClient.ets` 是当前唯一剩余的核心红灯，覆盖 `[ASYNC_FLOW]`、协议编解码、transport callback 与 source alignment 的高压组合；
- 当前最新可信红灯已经收敛到默认参数、同包依赖直用、`SessionInfo` accessor、`Int32/Int64` 位宽等真实代码实体问题；
- `Staging-Full` 的下一步不在 Linux headless 节点，而在 Windows GUI 宿主 readiness 取证与后续 DevEco / hdc / target 打通。

这种“Linux 继续压实体红灯，Windows 补 Full Pass 宿主”的双轨执行面，最能避免把已绿基线重新拉回旧主战场，也能避免在缺 GUI 证据时误报物理通过。

---

## 四、Phase 3A：Admission & Safety Baseline

### 4.1 目标

证明目标模块已经达到“可安全进入真实编译器”的准入状态，而不是只停留在“模型生成了一份看起来像仓颉的候选代码”。

### 4.2 入口条件

进入 `3A` 时，至少应满足：

- 已明确目标文件与依赖闭包；
- 已记录源仓库链接、分支或 commit、拉取日期；
- 已能形成 TU 输入；
- 已能记录本轮命中的 Skill、检索来源与模型配置；
- 已能运行静态黑名单、污染检测或边界审查步骤。

### 4.3 核心工作包

1. 冻结源输入：文件路径、版本、依赖闭包、目标方法范围；
2. 形成翻译输入：TU、Repo Map、Skill 命中清单、提示词上下文；
3. 生成候选 `.cj` 代码并落盘；
4. 运行静态黑名单、防污染检查与边界检查；
5. 将失败项归类为有限、稳定的错误族；
6. 把新出现的高危模式回写到修复模板与 Pattern Memory。

### 4.4 硬核退出证据

`Phase 3A` 只有在以下证据全部具备时才算通过：

#### A. 源证据

- 目标源仓库地址；
- 拉取日期；
- 目标分支 / commit；
- 目标文件路径；
- 依赖闭包清单；
- 目标方法或目标责任边界。

建议产物：`source-manifest.json`。

#### B. 翻译输入证据

- TU 输入落盘；
- Repo Map 或依赖摘要落盘；
- 本轮命中的 Skill 与检索来源清单落盘；
- 关键提示词上下文可回溯。

建议产物：`tu-manifest.json`、`skill-manifest.json`。

#### C. 候选代码证据

- 至少一份候选 `.cj` 文件落盘；
- 候选文件能与源文件建立映射关系；
- 若只翻译了目标文件的局部方法，也必须显式说明裁剪边界。

#### D. 静态安全证据

- 静态黑名单检查结果已落盘；
- 不允许存在未分类高危项；
- `std.unsafe`、跨层 `Signal / ValueSignal`、`Array<UInt8>`、协议对象污染等项必须要么清零，要么进入显式 allowlist 并附带书面理由；
- 黑名单报告中的每个失败项都必须能映射到具体位置与修复建议。

建议产物：`static-firewall-report.json`。

#### E. 边界证据

- 已证明服务层、协议层、transport callback、UI 状态提交边界没有被拍扁；
- 已记录状态所有权与资源释放责任；
- 已识别 callback-entry、async-flow、signal-or-store 等高压边界。

建议产物：`boundary-contract.md` 或等价摘要。

#### F. 轨迹证据

- 已有本轮 trace；
- trace 中能回溯源输入、Skill、候选代码、静态检查、失败原因与下一步动作；
- 其他成员可直接根据 trace 找到产物和命令。

### 4.5 不通过信号

- 依赖闭包不完整；
- 源版本未冻结；
- 候选代码存在大段 ArkTS 语法或项目级禁用模式残留；
- 黑名单项未分类；
- 失败现象无法复现；
- 明显跨层污染仍被解释为“先编过再说”。

### 4.6 通过后的标准表述

`Phase 3A passed` 的唯一合法含义是：

> 该目标模块已形成完整证据包，且当前候选代码可以被安全送入真实物理编译器，后续失败若发生，将主要表现为编译或运行层问题，而不是输入污染与边界失真。

---

## 五、Phase 3B：Physical Compile Stabilization

### 5.1 目标

证明目标模块可以在真实物理仓颉编译链上稳定编译，并把“单次偶然成功”升级为“可重复、可回放的通过结果”。

### 5.2 入口条件

- `Phase 3A` 已通过；
- 真实编译器路径、版本与环境变量已冻结；
- 候选代码不再带未分类高危污染；
- 编译工作区与命令模板已固定。

### 5.3 核心工作包

1. 用固定 Linux x86_64 宿主机与固定 SDK 执行真实编译；
2. 在干净工作区重复运行编译，排除脏缓存影响；
3. 收集标准输出、标准错误、退出码、生成产物与路径；
4. 将编译错误映射为 repair taxonomy；
5. 将成功模式和失败模式回写到 verifier 规则、修复模板与 Pattern Memory；
6. 对相邻样本执行最小回归，避免新规则打坏已通过案例。

### 5.4 硬核退出证据

`Phase 3B` 只有在以下证据全部具备时才算通过：

#### A. 工具链证据

- 宿主机架构已记录；
- SDK 根路径已记录；
- `cjc`、`cjpm` 路径已记录；
- `cjc --version` 输出已记录；
- 当前环境变量快照已记录。

建议产物：`toolchain-manifest.json`。

#### B. 编译命令证据

- 实际执行命令已记录；
- 工作区路径已记录；
- 输出文件路径已记录；
- 若存在兼容性前处理，如软链补齐或 runtime 注入，也必须显式记录。

#### C. 可重复编译证据

- 同一候选代码在两个干净工作区内连续两次编译通过；
- 两次 run 的环境变量与工具链版本一致；
- 结果不依赖人工临时 patch。

#### D. 二进制产物证据

- 至少一份真实编译产物已生成；
- 产物路径、生成时间、hash 或等价校验信息已记录；
- 产物可被其他成员重新定位。

#### E. 编译报告证据

- verifier 或等价报告已明确给出 `pass / fail`；
- 错误类别、修复轮次、最终状态已结构化记录；
- 若失败，也必须给出下一轮 repair 建议。

#### F. 修复收敛证据

- 编译错误已收敛到有限 taxonomy；
- 本轮若新增错误族，必须同步写入 taxonomy，不允许长期悬空；
- 修复策略与高频模式已沉淀到模板或 Pattern Memory。

#### G. 最小回归证据

- 至少一个相邻样本或历史已通过候选执行回归；
- 新引入的 repair 规则未破坏既有通过结果。

### 5.5 不通过信号

- 只能在单个脏工作区内编译通过；
- 编译成功依赖手工修改而未沉淀规则；
- 每轮修复都产生新的未分类错误；
- 编译通过但黑名单回潮；
- 产物存在但命令、日志或环境变量缺失。

### 5.6 通过后的标准表述

`Phase 3B passed` 的唯一合法含义是：

> 该目标模块已经在固定物理工具链上形成可重复的真实编译通过结果，且该结果附带完整的命令、日志、产物与修复收敛证据。

---

## 六、Phase 3C：Runtime Semantic Closure

### 6.1 目标

证明目标模块不仅能编过，而且关键行为、关键边界与关键状态所有权没有发生本质失真。

### 6.2 入口条件

- `Phase 3B` 已通过；
- 关键方法的源 / 目标映射表已形成；
- 已写出最小行为核查清单；
- 已确定本轮是做 `Conditional Pass` 还是冲击 `Full Pass`。

### 6.3 核心工作包

1. 形成行为契约矩阵：输入、输出、状态变化、错误路径、边界责任；
2. 执行最小 dry-run 单测、语义断言或集成级行为检查；
3. 在具备权限时进入 Harmony 模拟器或真机验证；
4. 记录日志、截图、页面或功能到达证据；
5. 将运行问题再回写到 Skill、修复模板与 Pattern Memory。

### 6.4 `Conditional Pass` 与 `Full Pass`

为适应当前真实权限状态，`Phase 3C` 分为两档：

#### A. `Conditional Pass`

适用于 Harmony 模拟器 / 真机 / 仓颉插件权限尚未完全解锁，但已经具备行为层证据。

必须具备：

- 行为契约矩阵；
- 至少一种行为证据：dry-run 单测、语义断言或最小集成验证；
- 至少一份运行失败复现记录或行为日志；
- 能指出关键行为与关键边界没有本质走样。

#### B. `Full Pass`

适用于具备完整 Harmony 验证条件时。

除 `Conditional Pass` 的全部证据外，还必须额外具备：

- Harmony 模拟器或真机运行证据；
- 目标页面或目标功能到达证据；
- 截图、日志、时间戳、环境信息齐备；
- 人工功能核查清单与结果。

### 6.5 硬核退出证据

`Phase 3C` 的证据要求如下：

#### A. 行为契约证据

- 已列出关键方法；
- 已列出关键输入输出；
- 已列出状态所有权；
- 已列出失败路径和降级策略；
- 已列出 transport callback 与 UI 状态提交的隔离约束。

#### B. 行为验证证据

- 至少一种自动或半自动行为验证已运行；
- 验证命令、输入、输出和结论可回放；
- 验证结论可对应到具体源方法与目标实现。

#### C. 运行证据

- 若做 `Conditional Pass`，至少要有运行日志或失败复现证据；
- 若做 `Full Pass`，必须有模拟器或真机页面 / 功能到达证据。

#### D. 人工核查证据

- 若进入 `Full Pass`，必须补人工功能核查；
- 核查项应覆盖 UI、交互、状态刷新、边界错误处理与明显卡顿 / 崩溃。

### 6.6 不通过信号

- 只有编译成功，没有行为验证；
- 行为验证无法对应回源方法；
- 运行异常未形成复现记录；
- 模拟器或真机验证完全依赖口头描述；
- 状态所有权、异步边界或 callback 隔离仍存在明显偏移。

### 6.7 通过后的标准表述

`Phase 3C Conditional Pass` 的唯一合法含义是：

> 该目标模块已具备最小行为层证据，但仍待 Harmony 设备或模拟器验证补齐后，才能升级为完整通过。

`Phase 3C Full Pass` 的唯一合法含义是：

> 该目标模块已经同时具备真实编译通过证据与 Harmony 运行层证据，可作为更大规模模块推进的有效样板。

---

## 七、本项目中的 Staging 精确定义

### 7.1 结论先行

本项目中的 `staging` 不应再被表述为传统 Web 服务的“预发布站点”，而应被精确定义为：

> **模块级受控验证环境（Controlled Module Validation Environment）**

其目的不是对外提供服务，而是让翻译结果在受控工具链、受控输入、受控边界下完成 promotion 前验证。

### 7.2 标准定义

建议采用以下标准表述：

`Staging = Source Freeze + Skill/TU Freeze + Static Firewall + Physical Compile + Minimal Behavior Check + Optional Harmony Integration`

### 7.3 两层结构

#### A. `Staging-Core`

包含：

- 源输入冻结；
- Skill / TU 冻结；
- 静态黑名单 / 污染检查；
- 真实物理编译；
- 最小行为验证；
- 失败复现与证据回写。

这是当前项目默认的主工作面。

#### B. `Staging-Full`

在 `Staging-Core` 之上，额外包含：

- DevEco Studio 联调；
- 仓颉插件条件下的 Harmony 构建或运行验证；
- 模拟器或真机页面 / 功能到达证据；
- 人工功能核查。

这是更接近最终验收的验证面。

### 7.4 工具链定义

#### A. `Staging-Core` 强制工具链

- 宿主机：`Linux x86_64`
- 仓颉 SDK：当前已确认可用的 Linux SDK
- 编译器入口：`cjc`
- 包管理器入口：`cjpm`
- 编排入口：`scripts/pipeline_runner.py`
- 翻译与调度入口：`scripts/orchestrator.py`
- 编译与验证入口：`scripts/verifier.py`

建议最小环境变量快照：

- `DEVECO_CANGJIE_PATH`
- `CANGJIE_HARMONY_SDK_PATH`
- `CANGJIE_HOME`
- `CANGJIE_PATH`
- `PATH`
- `LD_LIBRARY_PATH`

#### B. `Staging-Full` 扩展工具链

- `DevEco Studio`
- 仓颉插件
- Harmony 模拟器
- Harmony 真机（如可用）

### 7.5 验证边界

`Staging` 包含：

- 模块级验证；
- 方法级映射；
- 静态安全；
- 真实编译；
- 最小行为检查；
- Harmony 条件下的页面 / 功能验证；
- 证据回写与 promotion 判断。

`Staging` 不包含：

- 完整 Telegram 全工程对外交付；
- 应用商店级发布；
- 未锁定版本的私有仓库联调；
- 无权限前提下的伪设备验证；
- 绕过黑名单或跳过证据记录的“快进通过”。

### 7.6 术语统一建议

后续团队默认将“Deploy to staging”改表述为：

- `进入 Staging-Core`
- `进入 Staging-Full`

若没有明确说清是哪一层，不应执行相应 promotion 动作。

---

## 八、风险清单

以下风险按当前阶段重要性排序。

### R1. 工具链权限与插件审批未完全锁定

- `等级`：`Critical`
- `现状`：Linux 物理编译链已打通，但 DevEco Studio、仓颉插件、Harmony 模拟器或真机验证能力仍可能受审批与权限约束影响。
- `影响`：`Phase 3B` 可推进，但 `Phase 3C Full Pass` 与最终验收会被卡在设备或插件证据层。
- `触发信号`：连续两个迭代周期仍无法提供模拟器或真机证据。
- `应对策略`：
  - 将 `Phase 3C` 明确拆为 `Conditional Pass` 与 `Full Pass`；
  - 把 Linux 物理编译与最小行为验证作为当前刚性闸门；
  - 为每轮 run 补充权限状态字段，记录是否具备插件、模拟器、真机条件；
  - 一旦权限解锁，优先补设备侧证据，而不是先扩张模块数量。

### R2. 多语言源仓库仍未完全冻结

- `等级`：`High`
- `现状`：Swift 目标源仓库与第三语言源仓库仍未最终锁定。
- `影响`：`Phase 4` 无法按证据推进，且“三语言覆盖”只能停留在叙述层。
- `触发信号`：阶段推进时仍使用“待定语言 / 待定仓库 / 后续再补”的表述。
- `应对策略`：
  - 为每种源语言建立 `repo-lock manifest`；
  - 先冻结 ArkTS 主样本，后冻结 Swift；
  - 第三语言必须在 `Phase 3B` 首个目标通过后立即完成选型；
  - 选型优先级以“公开、稳定、可回溯、小闭环容易成立”为准，不以语言名义上的代表性优先。

### R3. 当前主战场存在静态污染高压项

- `等级`：`High`
- `现状`：最新真实模块实验明确卡在静态黑名单失败与高危类型污染残留。
- `影响`：若不把该问题前置到 `Phase 3A`，则后续编译成功也可能只是带毒通过。
- `触发信号`：编译通过但黑名单回潮，或高危项以人工说明方式长期存在。
- `应对策略`：
  - 把高危词表从现场失败上升为项目级修复模板；
  - 对黑名单执行“零未分类容忍”；
  - 所有例外项必须显式进入 allowlist，并附位置与理由；
  - 将污染模式回写到 Pattern Memory 和 verifier 规则。

### R4. Repo Index / Repo Map / TU Bundler 仍可能存在结构盲区

- `等级`：`High`
- `现状`：`RealMessageService.ets` 会持续压测 `Promise`、`Signal`、协议对象、`callback-entry` 等结构抽取能力。
- `影响`：若依赖闭包或方法粒度抽取错误，则翻译输入、修复方向与证据判断都会失真。
- `触发信号`：依赖方法缺失、call edge 错归、泛型节点断裂、修复建议与真实代码不对齐。
- `应对策略`：
  - 用当前真实目标模块建立 parser gap 基线；
  - 对 method extraction、call edge、泛型识别建立 diff 指标；
  - 必要时引入更强结构解析通道；
  - 在 TU 中显式带出状态语义与依赖摘要，而不是只拼接源码片段。

### R5. 轨迹与证据格式尚未完全统一

- `等级`：`Medium-High`
- `现状`：仓库已强调轨迹优先，但字段模板与跨 run 对比口径仍有继续细化空间。
- `影响`：难以横向比较不同 run，也难以把成功模式升级为可搜索知识资产。
- `触发信号`：不同 trace 的字段不一致、缺日志路径、缺工具链快照、缺最终状态枚举。
- `应对策略`：
  - 统一 run manifest 字段；
  - 为 source、toolchain、skill、blacklist、repair、artifact 建立固定字段；
  - 所有阶段通过判断都依赖 manifest，而非自由文本总结。

### R6. 模型供应商与环境变量口径尚未锁死

- `等级`：`Medium`
- `现状`：模型网关、模型 ID、正式环境变量约定仍在演进中。
- `影响`：复现性下降，跨机器和跨成员对比不干净。
- `触发信号`：同一任务复跑但无法说明模型差异；日志中出现口径不一致的模型标识。
- `应对策略`：
  - 保留 provider-agnostic 适配层；
  - 每次 run 必须记录模型 ID、网关类型和关键参数；
  - 严禁在文档、日志、trace 中回显明文密钥。

### R7. `Staging` 术语长期含混会导致任务误分派

- `等级`：`Medium`
- `现状`：当前仓库是翻译实验平台，而不是传统线上服务仓库；若沿用 Web 部署语义，容易把“受控验证”误解为“对外预发布”。
- `影响`：任务优先级、验收口径与资源投入可能全部跑偏。
- `触发信号`：团队成员使用“发布 staging”时无法说明具体工具链、验证边界与产物位置。
- `应对策略`：
  - 统一改用 `Staging-Core / Staging-Full` 术语；
  - 在 runbook、当前阶段说明、日报模板中显式声明本轮进入的是哪一层 staging；
  - 若未说明，不执行 promotion。

---

## 九、风险处理纪律

- 只要存在任一 `Critical` 风险未受控，不允许宣称完整阶段通过；
- 若同时存在两个及以上 `High` 风险未受控，只允许继续 repair，不允许 promotion 到下一阶段；
- `Medium` 风险可以并行处理，但必须在文档中写明下一次复核时间与补齐条件；
- 风险项若已解除，应在阶段 summary 中明确写出解除证据，而不是只删掉风险描述。

---

## 十、立即执行顺序

建议按以下顺序推进：

1. 正式将当前状态改写为 `Phase 3A active / 3B ready / 3C conditional`；
2. 围绕 `RealMessageService.ets` 形成第一份标准化证据包：
   - `source-manifest.json`
   - `dependency-closure.json`
   - `skill-manifest.json`
   - `static-firewall-report.json`
3. 将当前高频黑名单失败项全部升级为可复用修复模板；
4. 在固定 Linux 物理编译链上达成“两次干净工作区连续编过”；
5. 补行为契约矩阵与最小行为验证，先争取 `Phase 3C Conditional Pass`；
6. 待权限解锁后补 Harmony 模拟器或真机证据，将 `Conditional Pass` 升级为 `Full Pass`；
7. 仅在首个真实模块完成 `Full Pass` 后，才扩展到下一 Telegram 模块或第三语言样本。

---

## 十一、结论

本项目的大方向是合理的，但若继续沿用宽口径的 `Phase 03` 叙述方式，阶段判断将长期停留在经验化与口头化层面。

从执行层看，真正需要建立的是：

- `3A / 3B / 3C` 的硬闸门；
- `Staging-Core / Staging-Full` 的统一术语；
- 以证据包驱动的 promotion 规则；
- 可回溯、可比较、可复用的风险与修复沉淀机制。

只有当“阶段通过”能够被证据包而非叙述性总结支撑时，项目状态才算真正从“叙述驱动”切换为“证据驱动”。
