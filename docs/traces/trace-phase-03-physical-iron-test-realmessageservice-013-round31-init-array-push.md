# Trace: Phase 03 Physical Iron Test — RealMessageService Round 31 Init Array Push

- 日期：`2026-03-30`
- 目标：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
- 运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-030-round31-init-array-push`
- 模型：`Pro/zai-org/GLM-4.7`（SiliconFlow OpenAI-Compatible API）
- 核心新增：`skills/cangjie-init-array-time-syntax-v1.md`

## 1. 本轮目的

Round 30 已把主错误压缩到：

- `constructor` 语法幻觉
- `Array.append` / `existing + [message]`
- `DateTime.now().toMilliseconds()` / `.milliSeconds`
- 以及数组重建逻辑仍被塞回 `match` 分支块导致的 lambda 误判

Round 31 的目标是把这些点转成真实 compile-safe 模板，并继续冲击第一次 compile pass。

## 2. 本轮新增

### 2.1 新 Skill：`init / Array / DateTime` 专项

新增 `skills/cangjie-init-array-time-syntax-v1.md`，明确：

- 类初始化必须写 `init`，不能写 `constructor`；
- `Array<T>` 没有 `.append(...)`；
- `Array<T>` 不能用 `+ [item]` 追加；
- `DateTime.now()` 没有 `.toMilliseconds()` / `.milliSeconds`；
- 如果必须做 compile-safe 追加，使用 `Array<T>(size + 1, { index => ... })` 模板；
- 如果逻辑位于 `match` 分支中，仍应抽 helper，不能在 `case` 后直接塞块。

### 2.2 本地 `cjc` 微实验

在真实 `cjc --output-type staticlib` 下验证：

- `public init(...)`：可编译
- `public constructor(...)`：报错
- `Array.append(...)`：报错
- `existing + [item]`：报错
- `Int64(DateTime.now().nanosecond)`：可编译
- `Array<T>(existing.size + 1, { index => ... })`：可编译
- `public init + Array helper + HashMap.add(...)` 最小类：可编译

对应实验工件：

- `artifacts/tmp_round31_probe/`
- `artifacts/tmp_round31_array_probe/`
- `artifacts/tmp_round31_time_probe/`
- `artifacts/tmp_round31_service_probe/`

### 2.3 Pattern 进一步净化

进一步修改 `scripts/prompt_assembler.py`：

- few-shot 只保留经过过滤的真实 compile-safe 样例；
- 新增 curated pattern：`curated::service::init-array-helper::2026-03-30`
- 本轮进入 Prompt 的核心 pattern 收敛为：
  - `curated::service::init-array-helper::2026-03-30`
  - `curated::service::no-regression-helper-skeleton::2026-03-30`

## 3. 关键结果

Round 31 依然没有拿到 compile pass，但相比 Round 30 出现了一个清晰跃迁：

- `attempt-01`：`review_passed=true`，直接进入真实 `compile-failed`
- 主错误已经不再是 `constructor`
- `public init(...)` 已经成功进入候选

这说明：

- `init` 专项修正是有效的；
- 新的主瓶颈进一步缩小为“数组 helper 逻辑仍被塞回 `match` 分支块”。

## 4. 新的主错误

Round 31 最重要的 compile 证据：

- `attempt-01`：
  - `expected '=>' in lambda expression, found keyword 'let'`
  - `expected '=>' in lambda expression, found keyword 'this'`
  - 触发位置是 `sendMessage` 中 `case Some(existing) => { let newMessages = ... }`

也就是说：

- `init` 已修正；
- `Array<T>(size + 1, lambda)` 也开始被模型采纳；
- 但模型仍把“数组重建 + cache.add”塞进 `match` 分支块里，继续被编译器误判成 lambda 开头。

此外，本轮仍出现两类噪声回退：

- 个别轮次重新引入 `std.unsafe`
- 个别轮次回退到 `ArrayList`

说明 regression firewall 仍有价值，但“helper 必须离开 case 分支块”这条规则还需要继续加压。

## 5. 结论

Round 31 的核心收获是：

1. `constructor -> init` 已被真实修正；
2. `Array<T>(size + 1, lambda)` 已通过本地 `cjc` 物理验证；
3. 现在距离下一次突破只差一层：
   - 把 `sendMessage` / `resolveAccessHash` 中仍然放在 `case` 分支块里的多语句逻辑，继续抽成 helper；
   - 不允许 `case _ => { let ... }`、`case Some(existing) => { let ... }` 再出现。

## 6. 下一步

下一轮建议重点不是再扩新 API，而是：

- 对 `match` 分支块做更强的 helper-extraction 专项压制；
- 明确规定：**只要 `case` 后面要写 `let` / `this.` / `match`，就必须提到 helper 里**；
- 在 curated pattern 中进一步强化 `appendMessage(existing, message)` / `appendMessageToCache(key, message)` 的“helper 先行、case 只留单表达式”模板。
