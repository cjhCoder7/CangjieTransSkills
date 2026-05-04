# Learnings

Corrections, insights, and knowledge gaps captured during development.

**Categories**: correction | insight | knowledge_gap | best_practice

---

## [LRN-20260401-001] best_practice

**Logged**: 2026-04-01T03:40:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
`[ASYNC_FLOW]` 协议模块可以通过“已绿依赖 staged compile + package 归一”进入真实多文件编译，而不是继续被单文件 `cjc` 口径压制。

### Details
对 `MTProtoClient.ets` 相关依赖做物理实验后确认：`MTProtoConfig`、`CryptoUtils`、`TLMethods`、`TLSerialization`、`TLDialogs` 这批已绿候选在 staging 时只要统一 package 为 `core.mtproto`，就能一起通过 `cjc` 多文件编译。后续再把真实 `MTProtoClient` 候选放进去时，编译红灯会从“依赖上下文缺失”下沉为真实的候选语法/导入/类型问题。

### Suggested Action
后续处理 `AuthKeyCreator`、`MTProtoTransport`、`MTProtoClient` 这类依赖型模块时，默认开启 staged compile，并在 prompt 中明确“同包直用，不要自导入”。

### Metadata
- Source: conversation
- Related Files: scripts/precompiled_dependency_registry.py, scripts/workspace_manager.py, scripts/verifier.py, scripts/prompt_assembler.py
- Tags: async_flow, staged_compile, cjc, package_normalization

---
