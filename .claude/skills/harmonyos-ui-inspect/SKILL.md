---
name: harmonyos-ui-inspect
description: "采集 HarmonyOS 设备/模拟器上的 UI 截图与控件树，执行交互场景验证，输出差异报告和迭代建议"
allowed-tools: Bash(loopx *), Bash(python3 *), Bash(hdc *), Read
argument-hint: "[--scenario scenario.json] [--emulator port] [--no-screenshot]"
---

# HarmonyOS UI 分析反馈 Skill

## LoopX 管理（强制）

读取之外的设备连接、安装、启动、采集和交互必须先加载 `cangjie-loopx-management`。若 UI 验证来自应用翻译流程，复用当前 Goal；若用户独立调用本 skill，自动创建或恢复 UI 验证 Goal（粒度参考 [独立 UI 验证](../cangjie-loopx-management/references/workflow-mapping.md#独立-ui-验证)）。

执行前读取 `quota should-run`。设备、HAP 或 `DEVECO_HOME` 缺失时创建具体用户 Gate；不得把环境缺失写成 UI 缺陷。截图、控件树和 HiLog 原文放在忽略目录，LoopX 只记录断言结果、问题摘要和稳定相对引用。

## 目的

在应用构建成功并安装到设备后，采集截图与控件树，执行真实交互验证，输出可落地的 UI 迭代建议。

## 前置检查（启动前必须完成）

| # | 检查项 | 检查方式 | 未通过时 |
|---|-------|---------|---------|
| 1 | 模型能力确认 | 参照 `base-skill` 第 1 步自检 | 纯文本 → 后续全程加 `--no-screenshot`；多模态 → 可选读截图 |
| 2 | 构建已通过 | 确认最近一次 `/build` 输出 `BUILD SUCCESSFUL` | 先执行 `/build` 完成构建 |
| 3 | 设备已连接 | `hdc list targets` 有输出 | 启动模拟器或连接 USB 设备（见 Step 0） |
| 4 | HAP 就绪 | 有 `.hap` 文件或应用已安装 | 使用 `--auto-hap` 或 `--hap <路径>`（见 Step 0.5） |
| 5 | `.env` 中 `DEVECO_HOME` 已配置 | 读取 `.env` | 提示用户补充 |

---

## 截图读取规则

> 模型能力已在「前置检查」#1 中确认。以下规则基于该结论执行。

**默认行为：只依赖文本产物（`ui_summary.md` + `layout.json`），不读取 `screenshot.png`。**

`ui_summary.md` 与 `layout.json` 已包含控件类型、文本、尺寸、间距、可点击性、屏幕利用率等完整结构化信息，足以覆盖绝大多数 UI 验证场景。

| 模型能力 | 行为 |
|---------|------|
| **纯文本** | 加 `--no-screenshot` 跳过截图采集，**禁止** Read `screenshot.png` |
| **多模态** | 默认产出 `screenshot.png`，但**仅在文本信息不足时**才 Read 它 |
| **不确定** | 按纯文本处理，先读 `ui_summary.md` |

---

## Step 0：确认设备连接

```bash
hdc list targets
```

- `127.0.0.1:5555` → 模拟器，后续加 `--emulator 5555`
- `0123456789ABCDEF` → USB 设备，无需 `--emulator`
- 空或 `Empty` → 先启动模拟器或连接设备

---

## Step 0.5：确认 HAP 就绪

- 已有 `.hap` 文件：后续步骤中使用 `--hap <路径>` 指定安装
- 刚构建完成：使用 `--auto-hap` 自动搜索 `entry/build/` 下最新 HAP
- 应用已安装且在前台：使用 `--no-launch` 跳过安装与启动

---

## Step 1：选择模式

| 目标 | 使用模式 |
|------|---------|
| 验证界面外观、排查白屏/缺件 | **模式 A：基础采集** |
| 逐步操作验证（推荐）| **模式 B：逐步交互** |

---

## 模式 A：基础采集

### A1. 执行采集

```bash
cd <鸿蒙项目目录>
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --out ./ui_capture_output

# 纯文本模型：加 --no-screenshot 跳过截图
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-screenshot --out ./ui_capture_output
```

常用参数：

| 参数 | 说明 |
|------|------|
| `--emulator 5555` | 连接本地模拟器 |
| `--hap <路径>` | 安装指定 .hap 包 |
| `--auto-hap` | 自动搜索 entry/build/ 下最新 .hap 安装 |
| `--no-launch` | 应用已在前台时跳过启动 |
| `--no-screenshot` | 跳过截图采集，仅产出控件树与文本摘要（纯文本模型必选） |
| `--wait N` | 启动后等待 N 秒（默认 3） |
| `--hilog` | 同时抓取 HiLog 日志 |
| `--timestamp` | 输出目录追加时间戳，防止多次运行互相覆盖 |

### A2. 读取结果

产物：

```
ui_capture_output/
├── screenshot.png    # 视觉截图（加 --no-screenshot 后不生成）
├── layout.json       # 控件树（hdc dumpLayout 原始输出）
└── ui_summary.md     # 摘要：类型分布、尺寸间距、屏幕利用率
```

**默认读取顺序**（纯文本优先）：

1. 读 `ui_summary.md` — 包含控件分布、文本/Hint/Key、尺寸、可点击性、屏幕利用率、间距分析
2. 需要更完整控件层次时再读 `layout.json`
3. **仅**当纯文本信息不足（如需判断颜色、渲染异常、图像资源加载）且模型支持视觉时才 Read `screenshot.png`

按"分析维度"输出报告。

---

## 模式 B：逐步交互（推荐）

**核心原则：不预先生成场景文件，而是看一步、做一步。每次执行单个动作后重新采集，根据实际结果决定下一步。**

### B1. 采集当前界面

```bash
# 标准（带截图）
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-launch --out ./ui_capture_output

# 纯文本模式
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-launch --no-screenshot --out ./ui_capture_output
```

读取 `ui_summary.md` 了解当前控件树（仅在需要视觉确认且模型支持时再读 `screenshot.png`）。

### B2. 执行单步动作

使用 `--do` 参数执行一个动作，执行完自动重新采集。`--no-screenshot` 对 `--do` 同样生效：

```bash
# 点击（按文字查找控件）— 纯文本模式
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-launch --no-screenshot \
  --do click --target '{"text":"下一步"}' \
  --out ./ui_capture_output

# 点击（按类型+索引）
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-launch \
  --do click --target '{"type":"ListItem","index":0}' \
  --out ./ui_capture_output

# 输入文本（先按 hint 找输入框）
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-launch \
  --do input --target '{"type":"TextInput","index":0}' --input-text "13800138000" \
  --out ./ui_capture_output

# 输入文本（按 hint 定位）
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-launch \
  --do input --target '{"hint":"Message"}' --input-text "Hello!" \
  --out ./ui_capture_output

# 向上滑动
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-launch \
  --do swipe --swipe-dir up \
  --out ./ui_capture_output

# 返回
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --no-launch \
  --do back \
  --out ./ui_capture_output
```

`--do` 支持的动作：`click` / `long_click` / `double_click` / `input` / `swipe` / `fling` / `back` / `home`

`--wait-after N`（默认 1.5s）：动作后等待 N 秒再采集，页面跳转等场景可适当加大（如 `--wait-after 3`）。

### B3. 读取结果并决定下一步

每次 `--do` 执行后，`layout.json` 和 `ui_summary.md` 会被覆盖为最新状态（`screenshot.png` 仅在未加 `--no-screenshot` 时覆盖）。读取 `ui_summary.md` 确认结果，再决定下一步动作。

**控件查找失败时**（`FAIL 未找到目标控件`）：先用模式 A 重新采集，读取 `ui_summary.md` 查看当前可用控件，再调整 `--target`。

---

## 分析维度

无论哪种模式，输出结论均覆盖以下维度（全部可从 `ui_summary.md` + `layout.json` 推导）：

- **控件完整性**：是否白屏（控件总数过低）、关键控件是否存在、文本是否有效
- **交互可用性**：`clickable`/`scrollable` 状态是否正确、关键控件是否设置了 `key`
- **布局合理性**：控件重叠、溢出截断、层级深度（>10 重点关注）、大片留白（>1/4 屏高）
- **视觉审美**：正文 `≥14fp`、标题 `≥18fp`、同级间距差异不超 2 倍、可点击尺寸 `≥48×48vp`

---

## 报告格式

```markdown
## UI 反馈分析报告

### 当前状态
<一句话描述界面当前表现>

### 交互验证结果（模式 B）
**断言通过率**: X/Y
- ✅ <通过的断言>
- ❌ <失败的断言> → 原因 + 修复建议

### 发现的问题
1. [严重程度: 高/中/低] <问题描述> → 建议修复方式

### 迭代建议
- [ ] <具体可执行的开发任务>

### 无需改动
<确认正常的部分，避免过度修改>
```

---

## 常见问题排查

**截图是桌面/系统页，不是目标应用**

1. 确认应用已安装（传 `--hap` 或 `--auto-hap`）
2. 显式启动：`hdc -t 127.0.0.1:5555 shell aa start -b <bundle> -a <ability>`
3. 检查 `module.json5` 中 `EntryAbility.skills` 是否含多余的 `entity.system.home`
4. 用 `layout.json` 确认目标 `bundleName` 是否出现（过滤后窗口数 ≥ 1）

**Read 截图时报错 / 模型不支持图像**

加 `--no-screenshot` 重跑，全程只用 `ui_summary.md` + `layout.json`。

**手动等价命令**（脚本不可用时）

```bash
hdc shell aa start -a EntryAbility -b com.example.app
sleep 3
hdc shell uitest screenCap -p /data/local/tmp/screen.png
hdc file recv /data/local/tmp/screen.png ./screenshot.png
hdc shell uitest dumpLayout -p /data/local/tmp/layout.json
hdc file recv /data/local/tmp/layout.json ./layout.json
```

---

## 核心原则

1. **文本优先**：`ui_summary.md` + `layout.json` 能回答的问题，不要读截图
2. **双验证**：视觉层与控件树冲突时以控件树为准，控件树没有的不下结论
3. **聚焦可执行**：每个问题给出明确修复方向
4. **不过度设计**：界面正常时明确标注"无需改动"
5. **真实交互优先**：能用模式 B 验证行为时，不只依赖模式 A 的静态采集
6. **状态闭环**：修复建议不能代表验证完成；只有重新采集并验证关键断言后才完成 UI Todo
7. **失败留痕**：交互失败时记录动作、预期、实际和下一动作，保留 Todo 未完成；原始证据不写入公开状态或 Git

如发现非显而易见的布局/组件/状态问题并已验证解决，可选记录到 `experiences/experiences.md`。
