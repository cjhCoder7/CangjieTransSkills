# .claude 入口层与知识路由 Phase 1 设计稿

## 1. 背景

当前仓库已经不再只是“项目初始化 + 样本准备”状态，而是具备以下能力的实验平台：

- `repo_indexer -> repo_map_generator -> tu_bundler -> orchestrator -> verifier -> pattern_memory -> pipeline_runner` 的翻译与验证闭环；
- 面向 Harmony / Telegram 翻译场景的专项 Skill 库；
- 面向真实编译、真实报错、真实 Repair 轮次的轨迹与产物沉淀。

与此同时，当前仓库仍缺少一个对 Agent 更友好的统一入口层：

- 新进场 Agent 需要先读 `AGENTS.md`、再读 docs、再读 traces、再读 scripts README，首跳路径较长；
- 当前仓库缺少 `.claude/` 形式的 agent-native 入口；
- L1（通用仓颉语言知识）、L2（项目专项约束）、L3（真实实验现场）之间还没有显式路由协议；
- 未来吸收 private 基线中的 `cangjie-kernel` 与官方文档同步脚本时，缺少预置位和准入规则。

因此，本设计的目标不是重构当前翻译平台，而是在其之上增加一个“入口层神经中枢”，让 Agent 能在第一分钟内理解当前战况、命令入口、知识层级与失败分流规则。

---

## 2. 本次设计范围（Phase 1）

### 2.1 本次纳入范围

本次只设计并落地 **`.claude` 骨架与路由层**，并为后续两期预留接口：

1. `/.claude/mission-control.md`
   - 作为 Agent 的总控台入口；
2. `/.claude/status/current-phase.md`
   - 作为动态战况板；
3. `/.claude/runbooks/pipeline-runner.md`
   - 作为命令入口与短路规则手册；
4. `/.claude/skills/index.md`
   - 作为 L1 / L2 / L3 三层知识路由表；
5. `/.claude/skills/base-kernel/.placeholder`
   - 作为 Phase 2 通用 Kernel 知识吸收预置位；
6. `scripts/sync/README.md`
   - 作为 Phase 3 文档同步与切片流水线预置位。

### 2.2 本次明确不纳入范围

以下内容属于后续阶段，不在本次实现范围内：

- 不在本次直接导入 private 基线中的全部 `cangjie-kernel` 文档；
- 不在本次实现 `sync_docs.py` 与 `index_to_skill.py`；
- 不在本次直接改写现有 `skills/`、`scripts/` 的核心执行逻辑；
- 不在本次建立新的翻译或验证流水线；
- 不在本次替换现有 `AGENTS.md` 的项目协作总纲地位。

---

## 3. 设计目标

### 3.1 目标

本次入口层设计应满足以下目标：

1. **Agent 首跳清晰**
   - 新进场 Agent 能在 60 秒内知道当前阶段、主战场、命令入口与知识路由；
2. **动态与静态冷热分离**
   - 稳态规则与动态实验状态分文件维护，避免总控台漂移；
3. **三层知识显式路由**
   - 建立 L1 / L2 / L3 的优先级、入口方式、桥接规则与停止条件；
4. **失败短路机制明确**
   - 遇到静态黑名单、高危架构污染时，Agent 能快速进入项目级修复路径，而不是在语言层空转；
5. **为 Phase 2 / 3 预埋接口**
   - 后续可无缝接入 `base-kernel` 知识与文档同步脚本，而不破坏 Phase 1 结构。

### 3.2 非目标

- 本设计不试图用 `.claude` 替代完整项目文档体系；
- 本设计不试图把当前仓库退化为单纯知识仓库；
- 本设计不试图在入口层中复制所有 traces / reports / scripts README 内容；
- 本设计不试图把所有实验动态信息放进一个巨石文件中。

---

## 4. 迁移方案比较

### 4.1 方案 A：重入口单文件

把阶段状态、命令模板、知识路由、证据路径全部塞进 `mission-control.md`。

优点：
- 最直观；
- 最快看到结果。

缺点：
- 很快变成巨石文件；
- 高频实验更新会污染架构入口；
- Git 历史中难以区分“架构调整”和“战况刷新”。

### 4.2 方案 B：轻入口 + 强路由（推荐）

`mission-control.md` 只承担总控台职责，动态战况、命令模板和知识路由分别拆到独立文件。

优点：
- 结构稳定；
- 动态与静态冷热分离；
- 更适合长期演进；
- 更便于后续接入 Phase 2 / 3。

缺点：
- 文件数比单文件方案略多；
- 需要更明确的跨文件职责定义。

### 4.3 方案 C：极简骨架

仅创建 `mission-control.md` 与 `skills/index.md`，其他路径留空。

优点：
- 落地最快；
- 修改量最小。

缺点：
- Agent 仍然缺少清晰的命令入口与动态阶段说明；
- 对当前仓库高频实验的支撑不足。

### 4.4 结论

采用 **方案 B：轻入口 + 强路由**。

原因：
- 最符合当前仓库“实验平台 + 项目级约束 + 多轮迭代”的现实状态；
- 能把总控台保持在稳态层，而把频繁变化的实验结果收敛到专门状态文件；
- 后续最容易叠加 `base-kernel`、文档同步脚本和知识切片流水线。

---

## 5. Phase 1 文件结构与职责

### 5.1 `/.claude/mission-control.md`

职责：
- 作为 Agent 首跳总控台；
- 回答“现在在哪个阶段、先看什么、先跑什么、失败后去哪层找”；
- 维护稳定规则，而不是承载高频动态实验细节。

内容范围：
- 当前默认阶段锚点；
- 推荐阅读顺序；
- 命令入口总览；
- L1 / L2 / L3 的优先级规则；
- 失败分流原则；
- Guardrails；
- Phase 2 / 3 扩展点。

不应承载：
- 最新实验残留词清单；
- 具体某一轮运行的完整命令和日志；
- 长篇技能目录或样例代码。

### 5.2 `/.claude/status/current-phase.md`

职责：
- 作为当前阶段的动态战况板；
- 挂接最近一次或最近几次关键实验产物；
- 显式列出当前阶段主要阻塞项。

建议字段：
- `phase`
- `status`
- `focus`
- `latest_run`
- `evidence_paths`
- `blocked_by`
- `next_actions`

其中 `blocked_by` 应显式列出当前最顽固的 2~3 个阻塞模式，例如：
- `ArrayList`
- `std.unsafe`
- `static-blacklist-failed`
- 某类架构污染关键词

### 5.3 `/.claude/runbooks/pipeline-runner.md`

职责：
- 承载可复制执行的命令入口说明；
- 承载 `pipeline_runner.py`、`orchestrator.py`、`verifier.py` 的典型调用模板；
- 承载失败短路规则。

特别要求：
- 增加 **快速失败（Short-circuit）清单**；
- 若命中 `static-blacklist-failed`、高危污染词、Reviewer 高压项，应优先回到 L2 修复，不要在 L1 继续发散。

### 5.4 `/.claude/skills/index.md`

职责：
- 作为三层知识总路由表；
- 定义 Concept-first 与 Failure-first 两种入口；
- 定义 L1 / L2 / L3 的优先级、桥接规则与停止条件；
- 让 Agent 能在三层知识之间做因果式导航，而不是目录漫游。

### 5.5 `/.claude/skills/base-kernel/.placeholder`

职责：
- 明确 Phase 2 预置位；
- 标注未来要吸收 private 基线中的通用仓颉 kernel 知识；
- 标明接入前必须经过示例验真、补丁标记和准入分级。

### 5.6 `scripts/sync/README.md`

职责：
- 明确 Phase 3 预置位；
- 定义未来 `sync_docs.py` 与 `index_to_skill.py` 的目标职责；
- 标明与现有 `skills/`、`docs/`、`artifacts/` 的对接方式。

---

## 6. 三层知识模型（L1 / L2 / L3）

### 6.1 L1：Kernel Knowledge

定义：
- 通用仓颉语言、标准库、工具链、并发原语、CFFI 等知识底座。

回答的问题：
- 语法是否成立；
- 类型系统如何工作；
- 标准库 API 是否存在；
- `cjpm` / `cjc` 的一般行为是什么；
- `Atomic` / `Mutex` / `ArrayList` / `HashMap` / `CFFI` 的语言定义是什么。

默认目录：
- `/.claude/skills/base-kernel/`

### 6.2 L2：Harmony / Telegram Project Constraints

定义：
- 当前项目对 Harmony / Telegram 翻译的专项约束层。

回答的问题：
- 当前项目想要什么写法；
- 哪些架构边界不可越过；
- 语言上允许但项目中不推荐或禁止的写法有哪些；
- 针对协议污染、DTO 上浮、并发边界、主线程边界有哪些固定模板。

默认目录：
- `skills/`

### 6.3 L3：Real-time Pipeline Evidence

定义：
- 当前实验平台沉淀的真实运行现场。

回答的问题：
- 最近一次实验真实发生了什么；
- 哪些错误反复出现；
- 哪些 repair 路径已被证明失败；
- 哪些约束在真实编译器和 Reviewer 下比理论知识更有裁决权。

默认目录：
- `docs/traces/`
- `docs/samples/`
- `artifacts/pipeline_runs/`
- `artifacts/pattern_memory/`

### 6.4 优先级规则

若三层发生冲突，默认遵守：

`L3 真实证据 > L2 项目约束 > L1 一般知识`

解释：
- L1 说明“理论上可行”；
- L2 说明“项目里是否允许”；
- L3 说明“这次实验里是否真的成功”。

---

## 7. Skills Index 的双向桥接协议

### 7.1 两种入口模式

#### Concept-first

适用于：
- 先遇到一个概念；
- 还没有具体报错；
- 想确认“这个东西是什么”。

默认路径：
- `L1 -> L2 -> L3`

#### Failure-first

适用于：
- 已经拿到编译报错、静态黑名单、Reviewer 问题；
- 想最快定位修复路径。

默认路径：
- `L3 -> L2 -> L1`

### 7.2 四类桥接句式

#### Bridge A：L1 -> L2

模板：
- “语言允许，不等于项目推荐；继续检查 L2 项目约束。”

用途：
- 把理论概念落到项目级规则。

#### Bridge B：L2 -> L3

模板：
- “项目模板已明确，继续检查 L3 是否已有真实成功或失败先例。”

用途：
- 把项目模板与真实实验现场连接起来。

#### Bridge C：L3 -> L1

模板：
- “现场失败已确认，回查 L1 判断是语法错误、版本差异还是示例失效。”

用途：
- 从真实失败回溯语言定义。

增强规则：
- 若 L3 证明 L1 示例已过期或错误，必须在对应 L1 内容处打上 `[L3-DEPRECATED]` 标记。

#### Bridge D：L3 -> L2

模板：
- “现场失败优先解释为项目级违约，先查 L2 的替代模板。”

用途：
- 从真实失败回溯项目推荐修法。

### 7.3 停止条件（Stop Conditions）

出现以下情况时，应停止继续检索，转入修复或回写：

- 已找到项目级模板与真实先例；
- 报错属于已知高危黑名单类别；
- L3 已存在高度相似失败记录；
- L1 与 L2 已足够解释问题；
- 继续检索只会把问题从修复拖成百科漫游。

---

## 8. Failure Routing 与强制单向门

### 8.1 一般失败分流规则

- **语法 / 类型 / 构建问题**
  - 先查 L1，再对照 L3；
- **Harmony API / 页面 / 生命周期 / Router 问题**
  - 先查 L2，必要时回到官方文档；
- **架构污染 / 协议泄漏 / DTO 上浮**
  - 直接查 L2，再结合 L3；
- **静态黑名单 / Reviewer 高压项**
  - 先查 L3，再查 L2，最后如确需确认语言定义再补 L1。

### 8.2 强制单向门

若命中以下高危项，应触发：

`L3 -> L2 -> Repair`

并明确禁止：

`L3 -> L1 -> 寻找保留脏代码的理由`

典型高危项包括但不限于：
- `static-blacklist-failed`
- `std.unsafe`
- `import ... from`
- `Signal`
- `ValueSignal`
- `sendRequest`
- `Array<UInt8>` 在 Service 层直出
- 已知的协议污染与影子框架模式

解释：
- 这类问题首先是项目级违约；
- 不应被当成语言特性探索问题；
- 应优先进入 L2 替代模板和修复路径。

---

## 9. Phase 2：外来知识入场体检（接口设计）

### 9.1 核心目标

Phase 2 不直接导入 private 基线中的 kernel 文档，而是建立一套**知识准入制度**：

- 来源可追溯；
- 示例可验证；
- 版本偏移可标记；
- 项目禁区可警告；
- 对 Agent 可直接消费。

### 9.2 四段式知识炼金炉

#### Stage A：Ingest
- 记录来源、版本、路径、哈希、主题、是否含代码块。

#### Stage B：Extract
- 从文档中抽取可被体检的单位：
  - `executable-snippet`
  - `build-snippet`
  - `concept-only`
  - `api-reference-only`
  - `unsafe-or-high-risk`
  - `unknown-shape`

#### Stage C：Verify
- 不直接裸调 `cjc`；
- 通过 admission wrapper 构造最小工作区；
- 复用现有 `verifier.py` 作为底层体检引擎；
- 获取结构化验证结果和真实 stderr。

#### Stage D：Admit / Patch / Quarantine
- 根据验证结果，把知识分入不同准入等级，而不是粗暴二分。

### 9.3 准入等级

建议准入等级如下：

- `ADMITTED_VERIFIED`
- `ADMITTED_PATCHED`
- `ADMITTED_CONTEXT_ONLY`
- `ADMITTED_L2_RESTRICTED`
- `QUARANTINED_DEPRECATED`
- `REJECTED_HARMFUL`

### 9.4 标记协议

统一使用以下标记：

- `[L3-VERIFIED]`
- `[L3-PATCHED]`
- `[L3-DEPRECATED]`
- `[L2-RESTRICTED]`
- `[L3-BLOCKED-BY:<reason>]`

用途：
- 让 Agent 把这些状态视为结构化信号，而不是自然语言噪音。

### 9.5 体检不合格的处理原则

- **幻觉型知识** → `REJECTED_HARMFUL`
- **过期型知识** → `QUARANTINED_DEPRECATED`
- **可修复型知识** → `ADMITTED_PATCHED`
- **背景型知识** → `ADMITTED_CONTEXT_ONLY`
- **语言真实但项目禁用** → `ADMITTED_L2_RESTRICTED`

---

## 10. Phase 3：文档同步与切片流水线（接口设计）

### 10.1 目标

把 private 基线中的 `download_hm_docs.py` 思路迁入当前仓库，并升级为：

- `scripts/sync/sync_docs.py`
  - 负责从官方仓库同步文档镜像；
- `scripts/sync/index_to_skill.py`
  - 负责把下载回来的文档按逻辑切片并接入当前 Skill 库。

### 10.2 与当前仓库的关系

Phase 3 应与现有目录协同：

- 输出到本地文档镜像目录；
- 与 `skills/` 和未来 `/.claude/skills/base-kernel/` 对接；
- 必要的中间产物落到 `artifacts/`；
- 关键结论与规则回写到 `docs/` 与 traces。

### 10.3 本次只做预置位

本次 Phase 1 不实现脚本本体，只定义：
- 路径；
- 角色；
- 未来与现有系统的连接方式。

---

## 11. 数据流与工作流

### 11.1 Agent 进场后的推荐流程

1. 读 `AGENTS.md`
2. 读 `/.claude/status/current-phase.md`
3. 读 `/.claude/runbooks/pipeline-runner.md`
4. 读 `/.claude/skills/index.md`
5. 进入：
   - `L1`（若是语言 / 工具链问题）
   - `L2`（若是项目约束 / 架构问题）
   - `L3`（若已有真实报错或实验现场）
6. 若命中黑名单或高危污染，走 `L3 -> L2 -> Repair`
7. 若发现 L1 示例已过期，标记 `[L3-DEPRECATED]`

### 11.2 Phase 2 / 3 的后续流向

- 外来知识通过知识炼金炉体检后进入 `base-kernel`；
- 官方文档通过 `sync_docs.py` 同步；
- 文档切片通过 `index_to_skill.py` 与 Skill 库和 traces 连接；
- 最终由 `.claude` 入口层统一路由给 Agent 使用。

---

## 12. 风险与对策

### 12.1 风险：总控台膨胀

对策：
- 坚持冷热分离；
- 动态内容下沉到 `current-phase.md`；
- 命令模板下沉到 `runbooks/`。

### 12.2 风险：L1 过时示例污染项目

对策：
- 引入 `verifier.py` 体检机制；
- 强制使用 `[L3-DEPRECATED]` / `[L3-PATCHED]` 标记协议；
- 不通过体检的知识不得直接进入主 `base-kernel`。

### 12.3 风险：Agent 再次陷入百科漫游

对策：
- 在 `skills/index.md` 中写死桥接句式和停止条件；
- 对黑名单类问题启用强制单向门。

### 12.4 风险：入口层与实际实验状态漂移

对策：
- 稳态文件保持简洁；
- 高频更新集中到 `current-phase.md`；
- 每轮实验后优先更新战况板而不是重写总控台。

---

## 13. 验收标准

### 13.1 Phase 1 验收标准

若本设计被正确实现，应满足：

1. 新进场 Agent 能在 60 秒内明确：
   - 当前处于 `Phase 03: Physical Iron Test`；
   - 当前主战场是 Harmony / Telegram 模块级翻译；
   - 推荐入口命令在 `pipeline_runner.py`；
   - L1 / L2 / L3 的优先级与作用；
   - 命中高危项时应优先走 `L3 -> L2 -> Repair`。
2. `mission-control.md` 不因单次实验更新而频繁改动；
3. `current-phase.md` 能独立承载当前战况；
4. `skills/index.md` 能支持 Concept-first 和 Failure-first 两种导航路径；
5. Phase 2 / 3 预置位路径明确，后续可无缝扩展。

### 13.2 Phase 2 验收标准（预告）

- 外来 kernel 知识不会直接污染主知识层；
- 每条可执行示例有验证证据；
- 过期示例有 `[L3-DEPRECATED]` 标记；
- 项目禁用知识有 `[L2-RESTRICTED]` 标记。

### 13.3 Phase 3 验收标准（预告）

- 官方文档可复现同步；
- 文档切片能接入 Skill 构建流程；
- 中间产物路径清晰；
- 与现有 `skills/`、`docs/`、`artifacts/` 的连接明确。

---

## 14. 推荐实施顺序

### Task Group 1：入口层骨架
- 创建 `.claude/` 目录与 Phase 1 文件骨架；
- 写入总控台、战况板、runbook 与 skills index 初版。

### Task Group 2：Phase 2 / 3 预置位
- 创建 `base-kernel/.placeholder`；
- 创建 `scripts/sync/README.md`；
- 明确未来脚本接口。

### Task Group 3：文档回写与口径同步
- 更新仓库内关于“当前阶段”的描述；
- 减少 README / AGENTS 与真实能力之间的口径漂移。

---

## 15. 一句话总结

Phase 1 的价值，不是简单新增一个 `.claude` 目录，而是在当前仓库上方搭建一个：

- 面向 Agent 的总控台；
- 显式分层的知识路由系统；
- 面向未来 `base-kernel` 与文档同步流水线的扩展接口；
- 能把实验平台、专项 Skill 和真实证据统一调度起来的入口层神经中枢。
