---
name: harmonyos-ui-inspect
description: "采集 HarmonyOS 设备/模拟器上的 UI 截图与控件树，执行交互场景验证，输出差异报告和迭代建议"
allowed-tools: Bash(python3 *) Bash(hdc *) Read
argument-hint: "[--scenario scenario.json] [--emulator port]"
---

# HarmonyOS UI 分析反馈 Skill

## 目的

在应用构建成功并安装到设备后，采集截图与控件树，结合源码自动生成交互场景并执行真实验证，最后输出可落地的 UI 迭代建议。

## 适用场景

- 需要验证构建产物的界面表现
- 需要排查 UI 缺陷或交互问题
- 需要评估当前界面是否还要继续迭代

## 前置条件

- 构建已通过（`BUILD SUCCESSFUL`）
- 设备已连接且 `hdc` 可用（`hdc list targets` 有输出），或本地模拟器已启动
- 应用已安装，或有可安装的 `.hap` 文件

## 标准流程

### Step 0：确认设备连接

```bash
hdc list targets
```

输出示例：

```text
127.0.0.1:5555        # 模拟器（后续可用 --emulator 5555）
0123456789ABCDEF      # USB 设备（无需 --emulator）
```

处理规则：

- 输出含 `127.0.0.1:<port>`：记录端口，后续传 `--emulator <port>`
- 输出为设备 SN：按 USB 设备处理，不传 `--emulator`
- 输出为空或 `Empty`：先启动模拟器或连接设备

### Step 1：采集 UI 状态

常用命令：

```bash
# 在鸿蒙项目目录运行（自动检测 bundle/ability）
cd <鸿蒙项目目录>
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --out ./ui_capture_output

# 本地模拟器
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 --out ./ui_capture_output

# 任意目录运行并手动指定项目路径
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --project <项目路径> --out ./ui_capture_output

# 推荐：指定 --hap，确保安装的是最新包
python "${CLAUDE_SKILL_DIR}/ui_capture.py" --emulator 5555 \
  --hap "entry/build/default/outputs/default/entry-default-unsigned.hap" \
  --out ./ui_capture_output
```

参数说明：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--project` | 自动向上搜索 | 鸿蒙项目目录（含 `AppScope/`），用于读取 bundle/ability |
| `--bundle` | 自动检测 | 应用包名（来自 `AppScope/app.json5`） |
| `--ability` | 自动检测 | 启动 Ability（来自 `entry/src/main/module.json5`） |
| `--hap` | 无 | 指定后自动安装 hap |
| `--auto-hap` | 否 | 自动搜索 `entry/build/` 下最新的 `.hap` 文件并安装 |
| `--no-launch` | 否 | 应用已在前台时跳过启动 |
| `--wait` | `3` | 启动后等待秒数 |
| `--emulator` | 无 | 模拟器端口或地址（如 `5555` 或 `127.0.0.1:5555`），自动执行 `hdc tconn` |
| `--device` / `-t` | 无 | 指定目标设备 SN（多设备连接时使用） |
| `--scenario` | 无 | 指定场景 JSON，执行交互后二次采集并输出差异报告 |
| `--hilog` | 否 | 采集期间同时抓取 HiLog 日志，保存到输出目录 |
| `--timestamp` | 否 | 输出目录名追加时间戳（如 `ui_test_20260408_153836`），防止覆盖 |

> hdc 自动检测：脚本会自动在 DevEco Studio 安装路径和 `.env` 中查找 hdc，无需手动配置 PATH。
>
> 退出码：断言全部通过返回 0，有断言失败返回 2，可用于 CI 集成。

脚本不可用时，可手动执行等价命令：

```bash
hdc shell aa start -a EntryAbility -b com.example.personalfinancedashboard
sleep 3
hdc shell uitest screenCap -p /data/local/tmp/screen.png
hdc file recv /data/local/tmp/screen.png ./screenshot.png
hdc shell uitest dumpLayout -p /data/local/tmp/layout.json
hdc file recv /data/local/tmp/layout.json ./layout.json
```

### Step 2：读取采集结果（双验证）

依次读取 `ui_capture_output/`：

1. `screenshot.png`：视觉表现（颜色、布局、留白、文字渲染）
2. `layout.json`：结构事实（控件存在性、属性、层级）
3. `ui_summary.md`：类型分布、尺寸间距、交互统计摘要

双验证原则：结论必须同时有截图和控件树证据；若冲突，以控件树为准。

### Step 2.5：自动生成交互场景

基于源码与控件树自动生成 `auto_scenario.json`。

源码扫描（`entry/src/` 的 `.cj` 文件）与动作映射：

| 源码模式 | 含义 | 场景动作/断言 |
|----------|------|---------------|
| `.onClick(...)` | 点击事件 | `click` |
| `.onLongPress(...)` | 长按事件 | `long_click` |
| `.onChange(...)` / `.onTextChange(...)` | 值变化 | `input` + `text_changed` |
| `.onSwipe(...)` / `Scroll` / `List` + `ForEach` | 滑动 | `swipe` / `fling` |
| `Navigator` / `router.push` / `pushUrl` | 页面跳转 | `click` + `page_changed` |
| `@State var xxx` | 状态变量 | 找到绑定 UI 作为断言目标 |

关键规则：

- 追踪事件回调修改的 `@State`，把对应绑定控件作为断言目标
- 从 `layout.json` 提取候选节点：`clickable: true`、`scrollable: true`、`TextInput`，并记录 `key`/`text`/`type`/`bounds`
- 交叉匹配后组装步骤，定位优先级为 `key` > `text` > `type+index` > 坐标
- 操作间插入 `wait`（点击 0.5-1 秒，跳转 2-3 秒），关键转换点可插 `snapshot`
- A→B→A 场景优先用中间快照验证，不只看首尾 `page_changed`

### Step 3：执行交互验证

```bash
python "${CLAUDE_SKILL_DIR}/ui_capture.py" \
  --emulator 5555 --scenario ./auto_scenario.json --out ./ui_capture_output
```

场景 JSON 示例（支持 `//` 注释）：

```json
{
  "name": "计数器点击测试",
  "description": "验证点击按钮后计数器是否正确递增",
  "steps": [
    {"action": "click", "target": {"text": "点击计数"}},
    {"action": "wait", "seconds": 1},
    {"action": "click", "target": {"text": "点击计数"}},
    {"action": "click", "target": {"text": "点击计数"}}
  ],
  "assertions": [
    {"type": "text_equals", "target": {"key": "counter_display"}, "expected": "3", "message": "点击3次后计数器应为3"},
    {"type": "page_changed", "message": "界面应有变化"}
  ]
}
```

支持的动作（`steps[].action`）：

- `click`：单击
- `double_click`：双击
- `long_click`：长按（`duration` 毫秒）
- `input`：输入（`text`）
- `swipe`：滑动（`direction` 或 `from`+`to`）
- `fling`：快速滑动（`direction` 或 `from`+`to`，可配 `stepLen`、`speed`）
- `back`：返回键
- `home`：Home 键
- `wait`：等待（`seconds`）
- `snapshot`：中间快照（`label`）

目标定位（`target`）优先级：

1. 坐标：`{"x": 540, "y": 1200}`
2. key：`{"key": "btn_submit"}`
3. text：`{"text": "提交"}`
4. type+index：`{"type": "Button", "index": 0}`
5. hint：`{"hint": "请输入用户名"}`

支持的断言（`assertions[].type`）：

- `exists`：目标应存在
- `not_exists`：目标应消失
- `text_changed`：目标文本应变化
- `text_equals`：目标文本应等于 `expected`
- `clickable`：目标 clickable 状态符合 `expected`
- `count_changed`：某类控件数量变化（`target` 需含 `type`）
- `page_changed`：页面整体应变化

每条断言可附带 `message`。

执行产物：

1. 基线采集：`ui_capture_output/screenshot.png`、`ui_capture_output/layout.json`
2. 交互后二次采集：`ui_capture_output/after/screenshot.png`、`ui_capture_output/after/layout.json`
3. 差异数据：`ui_capture_output/diff.json`
4. 执行报告：`ui_capture_output/interaction_report.md`
5. 中间快照（如有）：`ui_capture_output/snapshot_<label>/`

### Step 4：分析与诊断

按以下维度输出结论：

- 控件完整性：是否白屏、关键控件是否存在、文本是否有效
- 交互可用性：`clickable`/`scrollable` 状态、是否具备 `key`、断言是否通过
- 布局合理性：重叠、溢出、截断、层级深度（>10 重点关注）、大片留白（>1/4 屏高）
- 视觉审美：正文 `>=14fp`、标题 `>=18fp`、同级间距差异不超 2 倍、可点击尺寸 `>=48x48vp`
- 数据与业务：状态变量与 UI 是否一致；源码声明的交互能力是否在控件树得到验证；`diff.json` 是否符合预期

### Step 5：输出建议报告

```markdown
## UI 反馈分析报告

### 当前状态
<一句话描述界面当前表现>

### 交互验证结果（如有）
**断言通过率**: X/Y
- ✅ <通过的断言>
- ❌ <失败的断言> → 原因 + 修复建议

### 发现的问题
1. [严重程度: 高/中/低] <问题描述> → 建议修复方式
2. ...

### 迭代建议
- [ ] <具体可执行的开发任务>
- [ ] ...

### 无需改动
<确认正常的部分，避免过度修改>
```

## 常见问题排查（优先顺序）

问题现象（满足任一项）：

- `screenshot.png` 是桌面/系统页面，不是目标应用
- `layout.json` 中几乎没有目标 `bundleName`，或过滤后窗口数为 0
- 日志显示已执行 `aa start`，但界面仍停留在桌面

排查步骤：

1. 确认应用已安装（推荐运行时传 `--hap`，或手动 `hdc install -r`）
2. 显式启动目标 Ability：`hdc -t 127.0.0.1:5555 shell aa start -b <bundleName> -a <abilityName>`
3. 检查 `entry/src/main/module.json5` 中 `EntryAbility.skills` 是否误含 `entity.system.home` / `action.system.home`
4. 用控件树确认是否采集到目标应用（出现目标 `bundleName`，且过滤后窗口数 >= 1）

## 核心原则

1. 双验证：截图 + 控件树，冲突时以控件树为准
2. 只基于数据：控件树没有的信息不下结论
3. 聚焦可执行：每个问题都要给出明确修复方向
4. 不过度设计：界面正常时明确标注“无需改动”
5. 源码驱动场景：事件绑定与可交互节点交叉得出，不凭空猜测
6. 真实交互优先：优先用 `--scenario` 验证，不只依赖静态属性
7. 可重复验证：场景 JSON 可版本化、可复用、可回归
