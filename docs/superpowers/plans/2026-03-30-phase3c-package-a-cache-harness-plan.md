# Phase 3C Package A Cache Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 `RealMessageService` 构建最小缓存行为验证 Harness，断言 `BCM-STATE-001 ~ 004`，并把模型默认配置切到 `Pro/zai-org/GLM-5`。

**Architecture:** 使用一个独立的最小仓颉样本目录承载 `RealMessageService` 的测试版实现、`FakeAdapter` 与 `std.unittest` 用例，避免污染主流水线产物。模型配置通过 `.env.local` 的 `OPENAI_MODEL` 固化，并在测试执行中显式沿用同一模型名，确保后续行为修复链路与当前策略一致。

**Tech Stack:** Cangjie `std.unittest`、`cjpm`、项目现有 Python pipeline 脚本、`.env.local`

---

### Task 1: 固化模型配置

**Files:**
- Modify: `.env.local`

- [ ] **Step 1: 写入模型配置**

```dotenv
OPENAI_MODEL=Pro/zai-org/GLM-5
```

- [ ] **Step 2: 验证配置可见**

Run: `set -a; source .env.local; set +a; printf '%s\n' "$OPENAI_MODEL"`
Expected: 输出 `Pro/zai-org/GLM-5`

### Task 2: 创建最小仓颉缓存样本

**Files:**
- Create: `samples/real-message-service-cache-001/entry/cjpm.toml`
- Create: `samples/real-message-service-cache-001/RealMessageServiceCacheHarness.cj`
- Create: `samples/real-message-service-cache-001/RealMessageServiceCacheTests.cj`

- [ ] **Step 1: 写失败测试**

```cangjie
@TestCase
public func firstGetMessagesShouldPopulateCache(): Unit {
    let adapter = FakeMessageAdapter(...)
    let service = RealMessageService(adapter: adapter)
    let messages = service.getMessages(peerId, 2)
    assertEqual("首次读取应触发一次 adapter.getHistory", "", 1, adapter.getHistoryCallCount())
    assertEqual("首次读取后缓存应有 2 条消息", "", 2, messages.size)
}
```

- [ ] **Step 2: 运行测试验证其失败**

Run: `cd samples/real-message-service-cache-001/entry && cjpm test`
Expected: FAIL，原因是实现文件尚不存在或断言不成立

- [ ] **Step 3: 写最小实现与 FakeAdapter**

```cangjie
public class FakeMessageAdapter <: IMessageAdapter {
    private var historyCallCount: Int64 = 0
    ...
}
```

- [ ] **Step 4: 再跑测试验证变绿**

Run: `cd samples/real-message-service-cache-001/entry && cjpm test`
Expected: PASS

### Task 3: 记录证据与状态

**Files:**
- Modify: `docs/phase-03-behavior-contract-matrix-realmessageservice.md`
- Modify: `.claude/status/current-phase.md`

- [ ] **Step 1: 回写 Package A 结果**
- [ ] **Step 2: 更新状态板 latest_run / next_actions**
- [ ] **Step 3: 重新运行关键验证命令并记录结果**

