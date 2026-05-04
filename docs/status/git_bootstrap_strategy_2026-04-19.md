# Git Bootstrap Strategy

更新时间：`2026-04-19`
适用仓库：`Cangjie`
状态：`bootstrap_strategy_frozen`
作用：冻结 `Cangjie` 从“已 git init 但无首个 commit”的状态进入安全首快照所需的 allowlist、sensitive exclude 与 first snapshot strategy。本文档只定义 bootstrap 规则，不授权任何高危 Git 动作。

## 1. Repo Facts

- 仓库是有效 Git repo，但当前没有首个 commit：
  - `git rev-parse --short HEAD` 失败，提示 `Needed a single revision`
- 这意味着：
  - 当前所有 `??` 都是预期现象
  - 现在最重要的不是“全仓一次性初始提交”
  - 而是先定义一个极窄、可审计的 first snapshot allowlist

## 2. Bootstrap Allowlist

### 2.1 Phase A: Governance And Recovery Only

首个 snapshot 只建议纳入控制面和治理面：

- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `README.md`
- `.gitignore`
- `.github/**`
- `docs/current_state.v2.md`
- `docs/runtime_contract.v2.md`
- `docs/domain_review_rubric.v2.md`
- `docs/status/**`
- `docs/agent_system/**`
- `docs/README.md`

### 2.2 Phase B: Minimal Project Skeleton

只有在 Phase A 已闭合后，才建议继续逐块纳入：

- `scripts/README.md`
- `samples/README.md`
- `research/README.md`
- `artifacts/README.md`
- 少量经过人工审查的 `specs/**`

### 2.3 Hold For Manual Review

以下对象不建议进入首个 snapshot：

- `artifacts/**`
- `raw_docs/**`
- `samples/**` 的具体内容
- `research/**` 大量外部材料
- 大块 `scripts/**`
- `third_party/**`
- 编译产物与实验输入文件：
  - `*.cjo`
  - `*.flag`
  - `main`

## 3. Sensitive Exclude

以下对象默认不应纳入首个 snapshot：

- `.codex/`
- `.env.local`
- `.env.full-pass.local`

说明：

- `.codex/` 含本地 agent 状态与认证面
- 本地 env 文件属于 machine-local 配置

以下对象当前先标为 `manual_review_hold`，而不是直接 ignore：

- `.claude/`

原因：

- 它可能包含本地运行状态
- 也可能包含 repo 级 runbooks / skills
- 在未逐项审查前，不应自动纳入首个 snapshot

## 4. First Snapshot Strategy

`Cangjie` 的 first snapshot 应固定为：

- `governance-only bootstrap commit`

建议 stage 范围：

- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `README.md`
- `.gitignore`
- `.github/**`
- `docs/current_state.v2.md`
- `docs/runtime_contract.v2.md`
- `docs/domain_review_rubric.v2.md`
- `docs/status/**`
- `docs/agent_system/**`
- `docs/status/git_bootstrap_strategy_2026-04-19.md`

明确不建议在 first snapshot 里 stage：

- `artifacts/**`
- `raw_docs/**`
- `samples/**`
- `research/**`
- `scripts/**`
- `third_party/**`

## 5. Commit Rhythm After First Snapshot

first snapshot 完成后，再进入：

1. 一块一块补 `specs/`
2. 一块一块补 `scripts/`
3. 每一块都先审查，再单独 snapshot commit

## 6. Stop Conditions

出现以下任一情况，停止普通 commit：

- 有人提议直接 `git add .`
- `.claude/` 未审查就要一并提交
- `artifacts/` 或 `raw_docs/` 想在同一个 commit 里大批纳入
- 需要任何高危 Git 操作

## 7. Recommended Immediate Action

当前最正确的动作不是“做首个巨型 initial commit”，而是：

1. 先用本策略限定首快照范围
2. 等用户确认后，再做一个极窄的 governance bootstrap commit
