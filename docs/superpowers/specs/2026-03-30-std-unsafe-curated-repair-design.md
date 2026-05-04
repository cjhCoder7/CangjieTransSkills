# Std Unsafe Curated Repair Design

## 背景

`RealMessageService.ets` 在 `Phase 3B active` 的真实流水线中，认证层已恢复，但候选代码仍反复死于 `static-blacklist-failed`，其中 `std.unsafe` 残留最顽固，且伴随“注释声明已删除、实际仍保留”的自欺欺人回归。

## 目标

把针对 `std.unsafe` 的 repair 约束升级为三层刚性策略：

1. `Anti-Gaslighting`：禁止用注释伪装删除；
2. `Escape Hatch`：明确提供不用 `unsafe` 的合法替代；
3. `Anti-Oscillation`：修 `unsafe` 时严禁带回 `TL*` / `SignalPipe` 污染。

## 设计

### 1. 静态墙 repair hint 加固

直接增强 `static-unsafe-keyword` 的 `repair_hint`，让静态墙证据本身就携带三层约束。

### 2. Regression Protection 加固

在 `orchestrator.apply_regression_protection()` 中，当静态结果含 `std.unsafe` 时，额外注入三层修复警告，尤其强化“物理删除”和“不要在注释里撒谎”。

### 3. Translator Prompt 动态指令区

在 `PromptAssembler.build_translator_prompt()` 中新增 `[Dynamic Repair Directives]`，当 repair guidance 命中 `std.unsafe` 时，输出精炼版三层指令，避免关键信息被长 guidance 淹没。

## 验证

使用临时 Python 红绿测试验证：

- 静态墙 `stderr` 是否出现三层关键短语；
- Translator Prompt 是否出现 `[Dynamic Repair Directives]` 和三层硬指令。

## 非目标

- 本轮不重构整个黑名单体系；
- 本轮不改 pipeline 基础设施；
- 本轮不处理全部 TL 污染，只聚焦 `std.unsafe` 修复锚点与防震荡。
