---
name: cangjie-translate
description: "将其他语言代码翻译为仓颉语言。支持 ArkTS、Swift、Java 到仓颉的转换，记录翻译经验和等价写法差异"
argument-hint: "[arkts|swift|java] [file-or-code]"
---

# 代码翻译为仓颉语言

将 $1 代码翻译为仓颉语言（待翻译内容：$2）。

## 翻译流程

1. 分析源代码的语义和结构
2. **复制资源文件** — 见下节"资源文件迁移"（强制，优先于代码翻译）
3. **（仅多模态模型）询问用户是否提供原项目 UI 参考截图** — 见下节"参考截图辅助翻译"
4. 查阅 `cangjie-kernel` skill 确认仓颉语法和 API
5. 查阅 `cangjie-harmony` skill 确认 HarmonyOS 平台 API 的仓颉等价写法
6. 逐模块翻译，保持原有逻辑不变
7. 翻译完成后查阅 `evolution` skill 中的已知踩坑记录，避免重复犯错

## 资源文件迁移（强制前置步骤）

**原则：翻译代码前，先把原项目的图片、图标、字体、音视频、本地化字符串等资源复制到仓颉工程对应目录。禁止在代码中使用 `"placeholder.png"`、`TODO`、占位 URL、或虚构资源名。**

### 识别源项目资源目录

按源语言类型定位：

| 源语言 | 典型资源目录 |
|--------|-------------|
| ArkTS（HarmonyOS） | `entry/src/main/resources/`（`base/media/`、`base/element/`、`rawfile/`） |
| Swift（iOS） | `Assets.xcassets/`、`Resources/`、`*.lproj/`、`Base.lproj/` |
| Java（Android） | `app/src/main/res/`（`drawable*/`、`mipmap*/`、`values*/`、`raw/`、`assets/`） |

### 映射到仓颉 HarmonyOS 工程

仓颉 HarmonyOS 项目资源放在 `entry/src/main/resources/`：

| 资源类型 | 目标位置 | 说明 |
|---------|---------|------|
| 位图（png/jpg/webp） | `base/media/` | 文件名全小写 + 下划线，如 `icon_home.png` |
| SVG 矢量图 | `base/media/` | 同上，仓颉 ArkUI 支持 svg |
| 颜色/字符串/尺寸 | `base/element/color.json`、`string.json`、`float.json` | 键名小写下划线 |
| 原始音视频/字体 | `rawfile/` | 保留原目录结构 |
| 多语言 | `zh_CN/element/`、`en_US/element/` | 与原项目 lproj/values-* 对应 |
| 多分辨率图（iOS @2x/@3x、Android mdpi/hdpi/xhdpi） | 选**最高分辨率**放入 `base/media/` | 鸿蒙按密度自动缩放，无需多份 |

### 执行步骤

1. **枚举源资源**：`Glob` 列出原项目资源目录下所有文件
2. **去重与选优**：多分辨率同名文件保留最高清版本；同一资源有多格式时优先 png > jpg > webp
3. **重命名**：驼峰 / 连字符 → 下划线小写（HarmonyOS 命名规范要求），如 `iconHome.png` → `icon_home.png`
4. **复制到目标目录**：用 `Bash(cp ...)` 或 `Write`（二进制文件直接 `cp`）
5. **更新映射表**：维护一份"原名 → 新名"映射，翻译代码时按此表替换引用
6. **string/color 等结构化资源**：从源 `.strings` / `.xml` / `.json` 提取键值，合并写入 `element/*.json`

### 代码引用方式

仓颉中通过 `$r("app.media.icon_home")` 或 `$rawfile("data.json")` 引用资源。翻译时把源代码的资源引用（如 ArkTS 的 `$r("app.media.xxx")`、Swift 的 `UIImage(named:)`、Android 的 `R.drawable.xxx`）统一改写为新的仓颉形式。

### 禁止项

- ❌ 不要用占位图（如 `https://placehold.co/...`、纯色方块）
- ❌ 不要写 `// TODO: 添加图标`
- ❌ 不要引用源项目里不存在的资源名
- ❌ 不要跳过资源迁移直接翻译代码

### 资源缺失时

如原项目确实没有某资源（如仅在运行时下载），在翻译报告末尾一句话列出："资源 X 在源项目未找到，需要用户提供"，由用户补充。

## 参考截图辅助翻译（仅多模态模型）

**适用条件**：当前模型支持图像输入（多模态），且翻译目标涉及 UI 还原（ArkTS 页面、Swift UIKit/SwiftUI 视图等）。纯文本模型**跳过本节**，仅基于代码翻译。

### 自检是否为多模态

在启动此流程前先自检：
- 如果 Read `.png`/`.jpg` 文件通常能正常解析为图像内容 → 多模态，继续执行
- 如果 Read 图像会报错或只返回文件元信息 → 纯文本模型，**不要**向用户索要截图，直接提示一句"当前模型不支持图像，将仅依赖源代码进行翻译"并跳到下一步

不确定时：默认按纯文本处理，不要主动索要截图。

### 工作流

**Step 1：询问用户**

翻译 UI 相关代码前，向用户提问（使用 AskUserQuestion 更佳）：

> 为了更准确还原原项目的视觉与交互，是否希望提供原项目 UI 截图作为参考？
> 如需提供，请将截图放入 **`./translate_refs/`** 目录（相对当前项目根目录），文件名建议采用 `页面名_描述.png`（如 `login_default.png`、`login_error.png`）。
> 放置完成后回复"已放置"或直接说不需要。

**Step 2：约定的截图目录**

- 默认路径：`<项目根>/translate_refs/`
- 用户可自定义，由用户在回复中说明实际路径
- Claude **不主动创建**该目录，仅读取用户已放入的文件

**Step 3：读取并使用截图**

用户确认放置后：

1. `Glob` 列出 `translate_refs/**/*.{png,jpg,jpeg,webp}` 所有截图
2. 依次 Read 每张截图（多模态模型会直接理解图像内容）
3. 在翻译时将视觉信息融入决策：
   - 控件层次、对齐、间距、圆角等视觉细节
   - 颜色、字号、状态差异（默认态/按下态/错误态）
   - 截图与代码不一致时，**以代码语义为准**，但可在注释或报告中标注"视觉差异：<描述>"供用户确认

**Step 4：跳过场景**

遇以下任一情况，**不要**读截图：
- 模型自检为纯文本
- `translate_refs/` 目录不存在或为空
- 用户明确表示不需要

### 注意事项

- 截图仅作辅助，**不替代**源代码分析；源代码不存在的逻辑不要臆造
- 不把截图内容写入代码注释（占空间且无意义），仅用于形成翻译决策
- 翻译完成后，若发现源码与截图有明显偏差，在最终交付说明中一句话列出差异，让用户决定是否调整

## 翻译规则

- 保持代码语义等价，不额外添加功能
- 使用仓颉惯用写法，不要逐行直译
- 类型映射优先查阅对应子目录下的经验文档（如有）
- 翻译后代码应可直接编译，注意仓颉与源语言的关键差异

## 经验文档

翻译过程中遇到的差异和踩坑，按源语言记录到对应子目录：

- ArkTS → 仓颉：[arkts2cangjie/](./arkts2cangjie/)
- Swift → 仓颉：[swift2cangjie/](./swift2cangjie/)
- Java → 仓颉：[java2cangjie/](./java2cangjie/)

每个子目录下按需创建主题文件（如 `types.md`、`ui.md`、`async.md`），并在子目录的 `README.md` 中维护索引。
