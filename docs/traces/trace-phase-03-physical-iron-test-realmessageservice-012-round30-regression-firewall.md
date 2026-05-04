# Trace: Phase 03 Physical Iron Test — RealMessageService Round 30 Regression Firewall

- 日期：`2026-03-30`
- 目标：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
- 运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-029-round30-regression-firewall`
- 模型：`Pro/zai-org/GLM-4.7`（SiliconFlow OpenAI-Compatible API）
- 核心新增：`skills/cangjie-regression-firewall-v1.md`

## 1. 本轮目的

Round 29 证明了 lambda / match 专项 Skill 有效，但同时暴露出严重回退：系统会从深层 compile 区重新跌回 `std.unsafe`、`TL*`、`InputPeer` 等静态墙污染。

Round 30 的目标是：

- 冻结已经清除过的污染 token family；
- 保住 Round 28 的 `review_passed -> compile-failed` 成果；
- 让新的主错误继续停留在真实 `cjc` 语法 / API 层，而不是重新退回协议泄漏层。

## 2. 本轮新增

### 2.1 新 Skill：防回退硬墙

新增 `skills/cangjie-regression-firewall-v1.md`，明确：

- `std.unsafe`、`TL*`、`InputPeer`、`createInputPeer`、`SignalPipe`、`ValueSignal` 一旦清掉，就永久禁止回潮；
- 不确定时优先退回最小领域骨架 / helper，而不是重新引入协议对象；
- `HashMap[...] =` 视为缓存更新倒退，要求回到显式 `add(...)` 或 helper。

### 2.2 Prompt 排序升级

修改 `scripts/prompt_assembler.py`：

- 当 repair guidance 中出现 `static-blacklist-failed`、`std.unsafe`、`TLUser`、`TLChannel`、`InputPeer`、`createInputPeer` 等信号时，显著提升 regression firewall 相关 Skill 的排序分数；
- 让 `firewall` 在回退轮次中优先进入高权重队列。

### 2.3 Few-shot 反污染过滤

在 `scripts/prompt_assembler.py` 中新增 Pattern 过滤逻辑，剔除：

- `case _ => { ... }`
- `std.unsafe`
- `TL*` / `InputPeer` / `createInputPeer`
- `constructor(...)`
- `.append(...)`
- `+ [item]`
- mock artifact

防止 Prompt 自己把已知坏模板再喂回 Translator。

### 2.4 新 curated pattern

新增：`curated::service::no-regression-helper-skeleton::2026-03-30`

其核心特征是：

- Service 只保留基础类型与纯领域模型；
- `match` 分支使用 helper，不在 `case _ =>` 后直接塞块；
- 缓存更新使用 `HashMap.add(...)`。

## 3. 关键结果

Round 30 没有获得第一次真实 compile pass，但成功把主战场从“旧污染回潮”继续推进到更深的 compile 层：

- `attempt-02`：静态墙通过，`verify_failure_type=compile-failed`
- `attempt-03`：静态墙通过，`verify_failure_type=compile-failed`
- `attempt-05`：静态墙通过，`verify_failure_type=compile-failed`
- `attempt-06`：静态墙通过，`verify_failure_type=compile-failed`
- `attempt-07`：`review_passed=true`，`verify_failure_type=compile-failed`

说明：

- regression firewall 没有直接带来 compile pass；
- 但它成功把系统重新拉回“真实编译错误”轨道；
- 并把新的主错误压缩到更具体的 Cangjie API / 语法层。

## 4. 新的主错误

Round 30 末尾最关键的新证据：

- `public constructor(...)` 会触发：`expected declaration, found 'constructor'`
- `Array.append(...)` / `existing + [message]` 等集合幻觉开始成为下一层主问题
- 某些轮次仍会把多语句逻辑塞回 `match` 分支块中，继续触发 `expected '=>' in lambda expression`

典型证据见：

- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-029-round30-regression-firewall/RealMessageService.orchestration.json`
- `artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-029-round30-regression-firewall/console.log`

## 5. 结论

Round 30 的价值不在于 compile pass，而在于：

1. 把系统从 Round 29 的大幅回退中重新拉回 compile 轨道；
2. 证明“防回退 Skill + few-shot 反污染过滤”是有效的；
3. 把新的真实瓶颈明确定位到 `init / Array / DateTime / helper extraction` 这一层。

## 6. 下一步

下一轮应围绕以下点继续推进：

- `init` 替代 `constructor`
- `Array<T>` 的真实追加模板
- `DateTime` 的真实可用字段
- 把 `Array` 重建逻辑从 `match` 分支块中继续抽成 helper
