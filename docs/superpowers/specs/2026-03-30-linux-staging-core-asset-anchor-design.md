# Linux Staging-Core 资产锚定设计

## 背景

当前仓库已经确认 `Phase 3C Conditional Pass` 达成，且 `Staging-Core` 是默认主工作面。此前对“Deploy to staging”的表述容易把 `Staging-Full` 的 GUI / Harmony 运行时要求误投射到当前 Linux 无头主战场，导致对既有 Linux 原生仓颉工具链的能力边界描述不够集中。

本轮需要把一个关键事实写成仓库级共识：

- 本地存在可追溯的 Linux SDK 原始压缩包：`/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip`
- 该 SDK 已经在当前宿主上被接线为真实 `cjc` / `cjpm` / runtime 环境；
- 当前可立即推进的“staging”应优先理解为 `Staging-Core` 的无头物理验证，而不是等待 GUI 宿主后才继续推进模块攻坚。

## 目标

1. 把 Linux SDK 压缩包原始路径补录为仓库级重要资产；
2. 在 `AGENTS.md`、`docs/resources.md`、`docs/strategy/phase-03-physical-compiler-setup.md` 三处建立统一表述；
3. 用新鲜的 Linux 实测命令再次确认 `cjc` / `cjpm` / `verifier` 路线仍可用；
4. 输出明确的下一步战术路线：继续打穿 `Staging-Core`，并把 `Staging-Full` 视为后续增强层，而非前置门槛。

## 非目标

- 本轮不把 `Staging-Full` 重新定义为 Linux headless；
- 本轮不伪造 Harmony 真 UI / 主线程物理证据；
- 本轮不启动新的大规模 Telegram 全工程翻译；
- 本轮不改动 `pipeline_runner.py`、`verifier.py` 或 Orchestrator 状态机逻辑。

## 方案对比

### 方案 A：只在回复里口头澄清

优点：快。

缺点：信息不会沉淀，后续 Agent 仍可能再次忽略 Linux SDK 原始资产。

### 方案 B：把资产锚定写入关键文档，并用新鲜验证命令固化证据

优点：既修正文档记忆，又保留可复现验证证据；最符合当前仓库“证据驱动”的工作方式。

缺点：需要同时修改多份文档，并跑一轮真实命令。

### 方案 C：顺手扩展大量 Staging-Core runbook

优点：信息最全。

缺点：超出本轮目标，容易把一次“资产锚定 + 战术校准”膨胀成大规模文档重构。

## 选定方案

采用方案 B。

## 设计细节

### 1. `AGENTS.md`：提升 Linux SDK 的项目级优先级

在“当前精确坐标”附近补一条明确说明：

- 当前宿主已确认具备 Linux 原生 `Staging-Core` 物理工具链；
- 原始压缩包位于 `资源/cangjie-sdk-linux-x64-6.1.0.818.zip`；
- 后续 Agent 不得再把 `Staging-Full` 条件误当成 `Staging-Core` 的前置门槛。

### 2. `docs/resources.md`：把 Linux SDK 原始压缩包纳入资源索引

新增一节“本地关键资产”，记录：

- 绝对路径；
- 版本号；
- 对应解压目录；
- 用途：`Staging-Core` 的真实编译 / 测试 / runtime 接线；
- 使用注意：必须使用能保留 symlink 的方式解压。

### 3. `docs/strategy/phase-03-physical-compiler-setup.md`：补“原始压缩包 → 解压工作目录”映射

当前文档已记录相对路径 `资源/cangjie-sdk-linux-x64-6.1.0.818.zip`，本轮需要补充：

- 当前宿主上的绝对路径；
- 为什么它是后续 Linux 进攻路线的锚点；
- 与 `artifacts/toolchains/...-unzip` 的对应关系。

### 4. 新鲜物理验证命令

本轮至少运行以下验证：

1. `cjc --version`
2. `cjpm --help` 或等价探活
3. 复用仓库现有 smoke 入口跑一次 `scripts/verifier.py` 的真实编译链验证

要求：

- 验证命令必须直接指向 Linux SDK 的真实入口；
- 若失败，只报告真实失败点，不扩大修复范围；
- 若成功，则将其作为“继续打穿 Staging-Core”的新鲜证据。

## 验证标准

本轮视为完成的条件：

- 文档三处均写入 Linux SDK 资产锚点；
- 至少一条新鲜命令证明 `cjc` 可运行；
- 至少一条新鲜命令证明 `verifier.py` 仍能接上真实 Linux toolchain；
- 最终说明清楚区分：`Staging-Core` 可继续推进；`Staging-Full` 不是当前 Linux 主战线的前置阻塞。

## 风险与缓解

### 风险 1：把“Linux 可推进”误写成“已完成 Full Pass”

缓解：所有文档都明确写 `Staging-Core` 与 `Staging-Full` 是两层结构，前者可继续推进，后者仍需独立证据。

### 风险 2：只记录相对路径，后续仍忽略原始资产来源

缓解：同时记录绝对路径和仓库内解压目录映射。

### 风险 3：验证命令失败导致范围扩大

缓解：只做最小 smoke 验证；若失败，停在真实失败点并回报，不顺手改动无关逻辑。
