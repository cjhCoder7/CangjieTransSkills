# Phase 3C Full Pass Readiness Checklist

## 0. 文档定位

- `目标`：把 `RealMessageService` 从 `Staging-Core / Conditional Pass` 推进到 `Staging-Full / Full Pass` 前，先把物理环境缺口写成可检查、可补齐、可归档的 readiness checklist。
- `适用阶段`：`Phase 3C` 之后半程，尤其适用于从无头 CLI 服务器转向真实 Harmony UI / 模拟器 / 真机验证的 promotion 前评审。
- `关联文档`：
  - `docs/phase-03-execution-roadmap.md`
  - `docs/phase-03-behavior-contract-matrix-realmessageservice.md`
  - `docs/evaluation-criteria.md`
- `权威主机勘测证据`：`artifacts/environment/phase03-full-pass-host-survey.json`

本文件的核心价值，不是描述“如何赢”，而是明确说明：

> **我们现在为什么还不能宣称赢。**

---

## 1. 当前物理坐标判定

### 1.1 当前结论

当前应判定为：`Path B（环境未就绪 / 无头服务器）`。

### 1.2 判定证据

基于 `artifacts/environment/phase03-full-pass-host-survey.json`，当前宿主机具备：

- Linux x86_64 下的仓颉 CLI 工具链；
- `cjc` / `cjpm` 驱动的无头编译与单测能力；
- `Staging-Core` 所需的 dry-run / mock / behavior harness 证据链。

当前宿主机 **不具备** 已验证的：

- `DevEco Studio` 可执行安装；
- 仓颉插件已安装并可被 IDE / Harmony runtime 识别；
- HarmonyOS Emulator / 真机联调通道；
- `hdc` 或等价设备连接器；
- GUI / Windowing / Display Session；
- 主线程 UI 日志的物理级回采链路。

### 1.3 当前最诚实的判断

因此，当前可以宣称：

- `Phase 3C Conditional Pass achieved`；
- `Staging-Core` 已形成证据闭环。

当前 **不能** 宣称：

- `Phase 3C Full Pass`；
- `Staging-Full ready`；
- `Harmony UI / 主线程物理级验证已可自动化执行`。

---

## 2. Staging-Full 的精确定义

本项目中的 `Staging-Full` 不是普通“预发布环境”，而是 **具备真实 Harmony UI 运行时与物理证据回采能力的验证节点**。

一个节点只有在同时满足以下条件时，才可称为 `Staging-Full ready`：

1. **基础设施层**：存在可运行 Harmony UI 的物理宿主或真机联调通道；
2. **工具链层**：`DevEco Studio + 仓颉插件 + Harmony SDK + hdc` 均已完成安装、配置与探活；
3. **运行时层**：可以把真实 UI 主线程 / 工作线程日志安全回收为 `artifacts` 与 `summary.json`；
4. **验证层**：可以实际触发页面、路由、消息刷新与主线程响应链路，而不是只在 mock harness 中模拟；
5. **证据层**：每次 Full Pass run 都能产出设备信息、构建信息、原始日志、结构化摘要与失败原因分类。

若缺任一项，当前阶段仍应归类为：`Staging-Core` 或 `Staging-Full blocked`。

---

## 3. 缺口矩阵（Readiness Gap Matrix）

| 层级 | 硬核验收标准 | 当前状态 | 证据 | 风险级别 | 结论 |
|---|---|---|---|---|---|
| `Infrastructure` | 存在带 UI 渲染能力的 Harmony Emulator 或真机联调链路 | `未满足` | `DISPLAY/WAYLAND` 为空，未发现 emulator / simulator / qemu / DevEco 进程 | `Critical` | 当前宿主仅为 Headless CLI 节点 |
| `Infrastructure` | 已决定 `Staging-Full` 运行在哪种宿主：Linux 无头 / macOS 实机 / Windows 实机 | `未锁定` | 当前仓库只有 Linux CLI 工具链与 mac/windows 插件压缩包 | `Critical` | 必须先做宿主拓扑决策 |
| `Toolchain` | `DevEco Studio` 已安装且可启动 | `未满足` | 主机未发现 `deveco-studio` 可执行 | `Critical` | Full Pass 无法起跑 |
| `Toolchain` | 仓颉插件已安装并被 IDE / Harmony runtime 识别 | `未满足` | 当前仅见插件 zip，不等于已安装 | `Critical` | Full Pass 无法构建 UI 应用 |
| `Toolchain` | `hdc` 已安装、可枚举 target | `未满足` | 未发现 `hdc`；target 列表为空 | `High` | 无法自动联调 emulator / 真机 |
| `Runtime` | 可采集主线程 / 工作线程 / UI 刷新日志 | `未满足` | 目前只有 mock harness trace，无真实 Hilog 证据 | `Critical` | 无法形成物理级 Full Pass 证据 |
| `Runtime` | 可把设备日志安全回收到 `summary.json` | `未满足` | 尚无真实设备日志结构化回写脚本 | `High` | 证据链不闭环 |
| `Promotion` | 已定义 Full Pass 的 promotion gate | `部分满足` | `Phase 03` 路线图存在，但 Full Pass readiness checklist 此前缺失 | `Medium` | 本文用于补齐此缺口 |

---

## 4. 基建层（Infrastructure）Readiness Checklist

## 4.1 宿主拓扑决策闸门

在进入 Full Pass 之前，必须先回答：

### 选项 A：Linux 无头模拟器路线

仅在以下前提全部成立时才可采用：

- Harmony Emulator 官方支持 Linux 无头或远程渲染模式；
- 可在 CI / CLI 中稳定启动 emulator；
- 可通过 `hdc` 或等价通道联调与抓日志；
- 可在无人工桌面交互前提下稳定进入目标页面。

**当前状态**：`未验证，不应假设支持`。

### 选项 B：macOS / Windows 实体机作为 Staging-Full 节点

若 Linux 无头路线缺少官方支持或稳定性证据，应默认采用：

- `macOS` 或 `Windows` 实体机；
- 安装 `DevEco Studio` 与仓颉插件；
- 启动 Harmony Emulator 或接入真机；
- 通过本项目的自动化脚本远程触发构建、部署、日志采集。

**当前建议**：在没有 Linux 无头模拟器的官方支持证据前，**优先采用选项 B 作为默认 Full Pass 节点方案**。

## 4.2 基建层硬核退出证据

只有拿到以下任一组证据，基建层才可记为 `ready`：

- `DevEco Studio` 可启动截图 / 进程探活 / 版本记录；
- Harmony Emulator 已成功 boot，并被 `hdc` 枚举；
- 或真机已成功接入，并可稳定拉取日志；
- 目标应用已可被安装、启动、进入指定页面。

建议固化的证据文件：

- `artifacts/environment/full-pass-host-profile.json`
- `artifacts/environment/full-pass-target-profile.json`
- `artifacts/environment/full-pass-connectivity-check.log`

---

## 5. 工具层（Toolchain）Readiness Checklist

## 5.1 当前真实状态

当前 Linux 节点只有：

- `artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie`

它足以支撑：

- `cjc` 编译；
- `cjpm test`；
- 无头 mock harness 验证。

它 **不足以替代**：

- `DevEco Studio`；
- 仓颉插件安装后的 Harmony UI 构建链；
- emulator / device 联调；
- IDE 内部的 Full Pass 构建与运行时配置。

## 5.2 工具层必查项

### A. DevEco Studio

必须记录：

- 实际安装主机 OS；
- 安装包来源；
- 安装版本；
- 安装路径；
- 是否支持静默安装；
- 若支持静默安装，对应命令与日志路径。

**当前状态**：`未安装，未验证静默安装能力`。

### B. 仓颉插件

必须记录：

- 插件来源包；
- 插件版本；
- 插件安装方式（手工 / 静默 / IDE marketplace / 本地导入）；
- 安装完成后的识别证据；
- 是否需要审批权限。

**当前状态**：`仓库仅持有插件 zip，未取得已安装证据`。

### C. Harmony SDK / 设备连接器

必须记录：

- Harmony SDK 路径；
- `hdc` 路径；
- target 枚举结果；
- 部署命令与返回日志；
- 卸载 / 重装 / 冷启动命令模板。

**当前状态**：`未发现 hdc 与 target`。

## 5.3 工具层推荐项目环境变量（项目内部约定）

以下变量是 **项目自动化层建议命名**，不是厂商官方变量承诺：

- `STAGING_FULL_HOST_OS`
- `DEVECO_STUDIO_HOME`
- `HARMONY_SDK_HOME`
- `CANGJIE_PLUGIN_BUNDLE`
- `HDC_PATH`
- `HARMONY_TARGET_ID`
- `HARMONY_APP_BUNDLE`
- `HILOG_CAPTURE_CMD`
- `FULL_PASS_ARTIFACT_DIR`

注意：

- 在未核实官方安装路径前，不要把默认路径写死成事实；
- 所有路径都应先由探测脚本发现，再落盘到环境 profile；
- 若静默安装不可行，应明确记录为“需要人工预装，不纳入 CI 假设”。

## 5.4 工具层硬核退出证据

工具层要记为 `ready`，至少需满足：

- `DevEco Studio` 版本与路径已落盘；
- 仓颉插件可被识别；
- `hdc` 可执行且能列出 target；
- 可成功完成一次“构建 → 安装 → 启动”的最小链路。

---

## 6. 运行时层（Runtime）Readiness Checklist

## 6.1 Full Pass 需要什么运行时证据

相较于 `Staging-Core` 的 mock 证据，`Staging-Full` 必须新增以下真实运行时证据：

- 真 UI 页面可见；
- `fetch/send -> messageCache -> UI refresh` 的真实路径可触发；
- 能区分主线程与工作线程的日志标签；
- 能定位 `onDatasetChanged` / `SignalPipe` 等价事件到底发生在哪个线程；
- 原始日志可被安全导出并结构化入库。

## 6.2 日志回采桥（Hilog / 等价物）设计要求

### A. 应用侧日志标记

真实 Full Pass 之前，应用侧必须补齐可搜索、可解析、可结构化的日志 tag，例如：

- `RMS_FETCH_BEGIN`
- `RMS_FETCH_END`
- `RMS_SEND_BEGIN`
- `RMS_SEND_END`
- `RMS_UI_REFRESH_QUEUED`
- `RMS_UI_REFRESH_DELIVERED`
- `RMS_THREAD_CONTEXT`

每条日志至少应带：

- 时间戳；
- 线程上下文；
- peerId / route / bundle 级定位信息；
- 关键事件名。

### B. 主机侧日志抓取

主机侧必须具备以下能力：

1. 在测试开始前清理或标记本轮日志边界；
2. 启动设备 / emulator 侧日志流抓取；
3. 触发 UI 交互路径；
4. 停止抓取；
5. 将原始日志保存到 `artifacts/runtime_logs/...`；
6. 解析为结构化摘要并写入 `summary.json`。

### C. 建议的结构化摘要字段

该层已正式落盘唯一指定收单格式：`docs/schemas/full-pass-summary-schema.json`。

未来真机 / Emulator 的 `summary.json` 必须至少覆盖以下关键字段：

- `host_os`
- `target_type`（emulator / device）
- `target_id`
- `build_id`
- `bundle_name`
- `ui_route`
- `main_thread_refresh_seen`
- `worker_fetch_seen`
- `worker_send_seen`
- `refresh_delivery_context`
- `raw_log_path`
- `log_capture_command`
- `redaction_applied`

换言之，后续所有 Full Pass 证据都应向该 schema 对齐，而不是各模块各写各的 `summary.json`。

### D. 安全要求

日志回采时必须确保：

- 不回显明文 token / cookie / session；
- 不把设备唯一标识当作公开字段扩散；
- 原始日志与 summary 分层保存；
- 必要时先做脱敏再上传 artifacts。

## 6.3 运行时层硬核退出证据

只有当以下证据齐全时，运行时层才可记为 `ready`：

- 至少一次真实设备/模拟器日志抓取成功；
- 至少一次 UI 刷新事件在主线程上下文被检出；
- 至少一次 worker 侧 fetch/send 事件被检出；
- 原始日志路径与结构化摘要互相可回溯。

---

## 7. 风险定级与应对策略

| 风险 ID | 风险描述 | 等级 | 当前状态 | 应对策略 |
|---|---|---|---|---|
| `R1` | 当前节点为 Headless Linux CLI 宿主，缺少真实 Harmony UI 渲染能力 | `Critical` | `命中` | 停止伪 Full Pass，先完成宿主拓扑决策 |
| `R2` | `DevEco Studio` 与仓颉插件未安装 / 未探活 | `Critical` | `命中` | 优先补齐工具层安装与版本落盘 |
| `R3` | `hdc` / emulator / device 联调通道未建立 | `High` | `命中` | 建立 target 枚举与部署探测脚本 |
| `R4` | 主线程 / UI 刷新日志无物理级回采方案 | `High` | `命中` | 先定义日志 schema，再实现抓取与解析脚本 |
| `R5` | Linux 无头模拟器是否可行缺少厂商支持证据 | `High` | `未决` | 在未核实前，默认准备 macOS/Windows 实体节点 |
| `R6` | Full Pass 证据格式未标准化 | `Medium` | `命中` | 统一 `summary.json` 字段与 artifacts 目录规范 |

---

## 8. Promotion Gate：何时允许点火 Full Pass

只有当以下清单全部为 `Yes` 时，才允许起跑 `Phase 3C Full Pass`：

- [ ] 已锁定 `Staging-Full` 宿主拓扑（Linux headless / macOS / Windows / 真机）
- [ ] 已验证 `DevEco Studio` 安装可用
- [ ] 已验证仓颉插件安装可用
- [ ] 已验证 `hdc` 与 target 枚举可用
- [ ] 已验证最小应用可部署与启动
- [ ] 已验证可抓取真实 Hilog / 等价日志
- [ ] 已验证日志可写入 `summary.json`
- [ ] 已定义 UI 主线程 / worker 线程日志 tag
- [ ] 已定义 Full Pass 失败时的分类与回退策略

在任意一项未完成前，所有 Full Pass 尝试都应被记为：

> `blocked-by-environment`，而不是 `code failure`。

---

## 9. 建议的立即执行顺序

### Step 1：做宿主决策

- 确认 Linux 无头模拟器是否有官方支持与稳定证据；
- 若无，立即指定一台 `macOS` 或 `Windows` 实体机作为 `Staging-Full` 节点。

### Step 2：补齐工具层 profile

- 使用 `scripts/full-pass-host-probe.sh` 统一探测 `DevEco Studio`、仓颉插件、Harmony SDK、`hdc` / `adb`、GUI session 与 target 联通性；
- 产出 `artifacts/environment/full-pass-host-profile.json` 与 `artifacts/environment/full-pass-connectivity-check.log`；
- 推荐先执行：`scripts/full-pass-host-probe.sh --output artifacts/environment/full-pass-host-profile.json --log artifacts/environment/full-pass-connectivity-check.log --fail-if-blocked`。

### Step 3：打通最小部署链路

- 最小工程构建；
- 最小安装；
- 最小启动；
- target 可枚举；
- 原始日志可回收。

### Step 4：定义日志 schema

- 已固化基线 schema：`docs/schemas/full-pass-summary-schema.json`；
- 主线程 / worker / refresh 事件名；
- 原始日志路径；
- `summary.json` 字段；
- 脱敏规则。

### Step 5：再谈 Full Pass 脚本化

- 使用 `scripts/full-pass-summary-validate.py` 作为第二闸门，确保 `summary.json` 与 `raw_log_path` 构成完整证据闭环；
- 使用 `scripts/full-pass-summary-builder.py` 把过滤后的 Hilog 归一化为 schema 合法的 `summary.json`，禁止手工拼凑证据文件；
- 使用 `scripts/full-pass-harmony-refresh.sh` 作为真实 Harmony refresh harness 模板，强制串起 `preflight -> state reset -> log capture -> install -> launch -> exercise -> filter -> summary build`；
- `scripts/pipeline_runner.py` 已支持通过 `--full-pass-summary-path` 挂接第二闸门，并按退出码分流为 `passed / repair-required / infrastructure-error`；
- **默认点火口径已经固化**：若节点已配置好 `.env.full-pass.local`（至少包括 `FULL_PASS_HDC_SERIAL`、`FULL_PASS_PKG_NAME`、`FULL_PASS_ABILITY_NAME`、`FULL_PASS_HILOG_FILTER`、`FULL_PASS_CLEAN_DIR` 等标准别名变量），则可以直接执行标准命令：`set -a; source .env.full-pass.local; set +a; python scripts/pipeline_runner.py --src-root raw_docs/telegramharmony-phase02 --target-file src/services/RealMessageService.ets --mock-mode --verify-dry-run --full-pass-summary-path artifacts/fullpass/summary.json --full-pass-max-cycles 3 --full-pass-sync-current-phase`；
- 在上述默认口径下，若未显式提供 `--full-pass-refresh-cmd`，`pipeline_runner.py` 会优雅降级：首轮若发现 `summary.json` 已存在，则只做第二闸门校验；若 `summary.json` 缺失，或进入 `retry cycle`，则自动回落到内建的 `scripts/full-pass-harmony-refresh.sh` 标准别名模板；
- 若进一步提供 `--full-pass-refresh-cmd 'bash scripts/full-pass-harmony-refresh.sh --cycle {cycle} --summary {full_pass_summary_path} --run-root {run_root} --target-file {target_file} --orchestration-output {orchestration_output_path} --final-output {final_output_path} --report {full_pass_report_path}' --full-pass-max-cycles N`，则仍可覆盖默认模板，并把 `exit=10` 回灌成下一轮 Orchestrator 的 Repair Context，形成真正的外层物理修复闭环；
- 该 refresh harness 已内建三类物理传感器：`Timeout Guard`、`Log Pre-processor`、`State Reset`；但在当前 `Path B / Headless Linux` 宿主上，只能做脚本级自验证，不能误报真实 Full Pass；
- 只有完成 Step 1~4，且校验器能稳定区分“实验未通过”与“证据链断裂”后，才允许起草真正的 `Phase 3C Full Pass` 自动化验证计划。

---

## 10. 当前结论

当前项目最诚实、最工程化的判断是：

- `Phase 3C Conditional Pass`：**已达成**；
- `Phase 3C Full Pass`：**尚未具备起跑条件**；
- 当前主阻塞不是代码本身，而是 **真实 Harmony UI / 工具链 / 运行时环境未就绪**。

因此，此刻最正确的动作不是“假装点火 Full Pass”，而是：

> **先把 Full Pass 的桥修出来，再让真实 ArkUI 跑起来。**

