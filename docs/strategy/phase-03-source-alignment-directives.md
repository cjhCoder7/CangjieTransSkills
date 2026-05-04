# Phase 03 Source Alignment Directives

## 1. 目标

本文件用于作为 `PromptAssembler` / `pipeline_runner.py` / `batch runner` 的小而硬的架构约束片段，专门约束真实翻译阶段不得偏离“翻译而非重构”的主线。

## 2. 核心铁律

- `raw_docs/telegramharmony-phase02/` 中的 ArkTS 源码是绝对真理；
- public API 必须执行 **最小代价等价映射**，严禁借翻译之名改造调用心智；
- 若源侧是同名 public 方法 / 同参数数量 / 同参数语义，则目标侧必须优先保持同名同义；
- 任何并发、锁、Epoch、缓存、线程切换等增强，只能封装在 `private` / `internal` 作用域；
- 真实翻译阶段允许出现红灯，但红灯必须来自真实的类型/语义/依赖问题，而不是 public contract rupture。

## 3. BCM-ALIGN 契约摘录

- `BCM-ALIGN-001 / Signature Parity`
  - public API 签名必须与 ArkTS 原版 `1:1` 对应；
  - 不得擅自加参数、拆接口、改返回心智、发明新的 public 类型。

- `BCM-ALIGN-002 / Encapsulated Enhancement`
  - `Epoch`、锁、缓存击穿、并发防御等增强功能不得改变原有业务调用心智；
  - 它们必须被封装在 `private` / `internal` 作用域下，对调用方保持语义透明。

## 4. 批量真实翻译口径

- Batch Pilot 首轮以“收集真实 failure/stderr 阵亡名单”为目标；
- 不追求首轮全绿，但必须守住 source alignment；
- 若 public API 已发生契约撕裂，则该候选即使编译通过也视为失败样本。
