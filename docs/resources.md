# 资源索引

## 官方与核心参考

- `https://gitcode.com/Cangjie-SIG/CangjieSkills`
  - 用途：参考官方 Skill 目录组织、命名方式、检索与脚本配套方式。
  - 历史建议（早期规划背景）：优先分析其中与 HarmonyOS / Cangjie 开发最相关的 Skill。

- `https://gitcode.com/openharmony/docs_cangjie`
  - 用途：仓颉鸿蒙开发文档主来源。
  - 历史建议（早期规划背景）：后续做 Skill 抽取时记录具体页面、章节和访问时间。

- `https://gitcode.com/openharmony/applications_app_samples`
  - 用途：ArkTS / HarmonyOS 小样本来源。
  - 历史建议（早期规划背景）：优先筛选“小而全、依赖少、能快速验证”的样例。

- `https://github.com/ForestBook/TelegramHarmony`
  - 用途：Telegram HarmonyOS / ArkTS 参考工程。
  - 历史建议（早期规划背景）：暂作为后续主源工程候选，先不要直接全量翻译。

- `https://developer.huawei.com/consumer/cn/download`
  - 用途：DevEco Studio 与相关插件下载。

- `https://cangjie-lang.cn/`
  - 用途：仓颉语言官网与公开资料入口。

## 本地关键资产

- `Linux x86_64 Cangjie SDK 6.1.0.818`
  - 原始压缩包绝对路径：`/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip`
  - 当前解压目录：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip`
  - 用途：作为当前 `Staging-Core` 无头验证环境的真实 `cjc` / `cjpm` / runtime 接线资产，支撑 Linux 原生物理编译、单测与行为 smoke。
  - 使用注意：必须使用可保留 symlink 的解压方式（推荐系统 `unzip`），否则 `third_party/llvm` 与 runtime 布局可能失真，进而导致 `cjc` 探活或真实编译失败。

## 补充资料

- `https://my.feishu.cn/docx/QaZAdbBn8oRpgXx6nupceaHlndf`
  - 用途：早期周报与过程背景补充。

## 待补齐资源

以下资源尚未在仓库内落定，应作为后续补录项：

- Swift 源仓库地址；
- 第三语言（Java / Python）源仓库地址；
- 模型网关说明、环境变量规范、调用样例；
- 仓颉插件审批结果与访问说明；
- 若存在群文件 / 私有文档，应给出索引与访问前提。

## 资源记录建议

后续一旦真正拉取或镜像外部资源，建议在对应目录增加说明文件，至少包含：

- 来源链接；
- 拉取日期；
- 分支 / commit / 版本；
- 用途；
- 本地修改说明；
- 许可证或使用限制（如适用）。
