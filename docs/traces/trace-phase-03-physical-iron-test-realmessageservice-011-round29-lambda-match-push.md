# Trace: Phase 03 Physical Iron Test — RealMessageService Round 29 Lambda Match Push

- 日期：`2026-03-30`
- 目标：`raw_docs/telegramharmony-phase02/src/services/RealMessageService.ets`
- 运行目录（首次）：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-027-round29-lambda-match-push`
- 运行目录（empty-guard 补跑）：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-028-round29-lambda-match-push-empty-guard`
- 新 Skill：`skills/cangjie-lambda-match-syntax-v1.md`

## 1. 本轮目的

Round 28 已经把系统推到多次 `review_passed -> compile-failed`，新的主错误集中在：

- `expected '=>' in lambda expression, found keyword 'match'`
- `expected '=>' in lambda expression, found keyword 'let'`

Round 29 的目的是用专门的 lambda / match 语法 Skill，把这层窗户纸捅穿，并继续冲击第一次真实 compile pass。

## 2. 本轮新增

### 2.1 新 Skill

新增 `skills/cangjie-lambda-match-syntax-v1.md`，焊死以下铁律：

- 闭包标准起手式必须是 `{ param: Type => ... }`
- `match` 分支优先保持单表达式
- `case _ => { let ... }` 这种多语句块直接视为高危坏味道
- 多语句逻辑优先抽 helper，而不是塞进 `case _ =>`

### 2.2 Prompt 高优先级接入

修改 `scripts/prompt_assembler.py`，当 repair guidance 里出现：

- `expected '=>'`
- `lambda expression`
- `match` / `let`

时，显著提高 lambda / closure / helper / match-expression 相关 Skill 的排序分数。

### 2.3 Compile Baseline 修订

同步修正 `skills/cangjie-service-compile-baseline-v1.md` 中的示例，去掉会诱发 `case _ => { ... }` 的坏模板。

### 2.4 Empty Candidate Guard

Round 29 首次运行暴露一个 verifier 漏洞：空候选文件在 `--output-type staticlib` 下会被 `cjc` 编过，导致出现“verify 通过但 generated_code 为空”的假阳性。

本轮已修复 `scripts/verifier.py`：

- 若 `candidate_bytes_written <= 0`，或候选文件大小为 0，则 compile 阶段直接返回 `empty-candidate-file`。

## 3. 首次 Round 29 结果

首次运行中，lambda / match Skill 确实产生了正向作用：

- 不再只卡在 `match` 分支块语法；
- 候选已经推进到更深一层的真实编译问题，如：
  - 命名参数前缀 `id:`
  - `Array.append` 不存在

但首次运行还出现一个假阳性：

- `attempt-02` 的 `generated_code` 为空；
- 由于 verifier 当时还没有 empty-candidate guard，`cjc --output-type staticlib` 仍返回 0；
- 这不是有效 compile pass，不能计作突破。

## 4. Empty Guard 补跑结果

在修复 verifier 后，按同一 Round 29 配置重新跑了一轮。

结果表明：

- 空候选假阳性已被彻底拦住；
- 但这一轮真实输出重新出现了明显的静态墙回退，例如：
  - `std.unsafe`
  - `TLUser` / `TLChannel`
  - `InputPeer`

因此，Round 29 的最终有效结论是：

- **没有拿到第一次真实 compile pass**；
- lambda / match 专项 Skill 是有效的，但当前模型输出仍然存在显著不稳定性，会在不同轮次之间发生“深层语法突破”和“静态墙回退”并存的震荡。

## 5. 本轮最重要的真实收获

### 收获 1：lambda / match 语法根因被物理确认

本轮通过本地 `cjc` 微实验确认：

- `case _ => { let ... }` 确实会触发 `expected '=>' in lambda expression`
- compile-safe 替代路线是 helper 提取，而不是继续在分支里硬塞块

### 收获 2：compile pass 假阳性根因被修掉

`empty-candidate-file` 现在已经被 verifier 捕获，后续不会再把“空代码编过 staticlib”误当胜利。

### 收获 3：系统现状被更准确地刻画

当前系统能力不是“已逼近 compile pass”，而是：

- 在某些轮次可以穿透到深层 compile 错误；
- 但整体生成稳定性还不足，仍会回退到 `std.unsafe` / `TL*` / `InputPeer` 这类高层污染。

## 6. 结论

Round 29 没有产出真正的物理级 compile pass。

但它产出了三件关键资产：

1. `skills/cangjie-lambda-match-syntax-v1.md`
2. Prompt 中针对 lambda / match 编译错误的高优先级路由
3. verifier 的 `empty-candidate-file` 防假阳性保护

这三件事会让后续 Round 30 及之后的结果更可信。
