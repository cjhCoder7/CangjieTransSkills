---
name: cangjie-translate
description: "将其他语言代码翻译为仓颉语言。支持 ArkTS、Swift、Java 到仓颉的转换，记录翻译经验和等价写法差异"
context: fork
argument-hint: "[arkts|swift|java] [file-or-code]"
---

# 代码翻译为仓颉语言

将 $0 代码翻译为仓颉语言。

## 翻译流程

1. 分析源代码的语义和结构
2. 查阅 `cangjie-kernel` skill 确认仓颉语法和 API
3. 查阅 `cangjie-harmony` skill 确认 HarmonyOS 平台 API 的仓颉等价写法
4. 逐模块翻译，保持原有逻辑不变
5. 翻译完成后查阅 `evolution` skill 中的已知踩坑记录，避免重复犯错

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
