# 2026-03-31 TelegramHarmony Batch-1 失败簇归因报告（V1）

## 1. 报告目标

本报告用于回答三个问题：

1. `Batch-1 real-compile` 当前为什么是 `0/4` counted target 通过；
2. 这四个失败是否已经进入“源侧语义/翻译映射”层，还是仍停留在 pipeline / verifier / contract 级别；
3. 下一轮 repair backlog 应该按什么顺序推进，才能最快把“小批量自动翻译 Pilot”推到可放量前夜。

本轮采用**按失败类型聚类**而不是按文件逐个拆解，因为我们当前需要优先识别“可以一枪打掉一簇”的系统性问题，而不是沉迷于逐文件手工补丁。

## 2. 输入与证据范围

### 2.1 运行输入

- manifest：`docs/manifests/telegramharmony-phase02-batch1-real-compile.json`
- 批次汇总：`artifacts/batch_runs/telegramharmony-phase02-batch1-real-compile/batch-summary.json`
- 目标文件：
  - `src/core/mtproto/MTProtoConfig.ets`
  - `src/core/mtproto/CryptoUtils.ets`
  - `src/core/mtproto/TLMethods.ets`
  - `src/core/mtproto/TLSerialization.ets`
- 执行模式：`mock translator + real compile + Linux SDK`

### 2.2 证据来源

每个 target 均抽取以下四类证据：

1. `runs/<label>/summary.json`
2. `runs/<label>/*.orchestration.json`
3. `artifacts.final_output_path` 指向的候选 `.cj` 文件
4. `scripts/static_blacklist_checker.py` 与当前静态墙规则实现

## 3. 核心结论

本轮 `Batch-1 real-compile` 的失败，**还没有进入“ArkTS 源侧语义映射本身失败”这一层**。当前看到的主要是：

- `CLUSTER-A / MOCK_ARTIFACT_COMPILE_POLLUTION`
- `CLUSTER-B / STATIC_BLACKLIST_SCOPE_LEAK`
- `CLUSTER-C / REVIEW_CONTRACT_GAP`

换句话说，当前失败更多是**候选物模板、静态墙作用域和审查契约噪声**的问题，而不是 Telegram Harmony 这四个模块本身已经证明“翻译不动”。

## 4. 失败簇总览

| Cluster ID | 名称 | 影响目标 | 当前层级 | 优先级 |
|---|---|---|---|---|
| `CLUSTER-A` | Mock 候选物语法污染 | `MTProtoConfig`、`CryptoUtils`（并横切影响其余 target） | Translator / Candidate Artifact | `P0` |
| `CLUSTER-B` | 静态墙作用域泄漏 | `TLMethods`、`TLSerialization` | Verifier / Static Firewall | `P0` |
| `CLUSTER-C` | Review 契约缺口 | `MTProtoConfig`、`CryptoUtils` | Reviewer Contract | `P1` |

## 5. Cluster 细分

### 5.1 `CLUSTER-A / MOCK_ARTIFACT_COMPILE_POLLUTION`

#### 5.1.1 受影响目标

- `src/core/mtproto/MTProtoConfig.ets`
- `src/core/mtproto/CryptoUtils.ets`

#### 5.1.2 观测症状

- `orchestration.final_status = failed`
- `verify_status = failed`
- `verify_failure_type = compile-failed`
- `review_issue_codes = ["missing-verification-matrix"]`

#### 5.1.3 直接证据

代表性候选物首部如下：

```text
# mock translator artifact
# target: src/core/mtproto/MTProtoConfig.ets
# attempt: 3
# declared_constraints: Translation Mapping, Architecture Mapping
# note: mock mode does not emit real .cj business code.
```

对应 `cjc` 错误出现在 `repair_guidance` 中，核心报错为：

- `error: expected '#' or '"' in raw string, found ' '`

也就是说，当前 mock translator 输出的头部并不是**对仓颉编译器友好的占位候选物**，导致 real compile 在还没触达业务逻辑前就被模板本身炸掉。

#### 5.1.4 根因判断

这不是 `MTProtoConfig` 或 `CryptoUtils` 的源侧语义映射失败，而是：

- `mock_mode=true` 仍然输出了“便于人读”的头部说明；
- 该头部对 `cjc` 来说不是合法注释/合法占位 stub；
- 所以 real compile 当前测到的是**mock artifact 模板错误**，而不是翻译质量。

#### 5.1.5 修复建议

优先推荐的修复路线：

1. 要么让 mock translator 在 `real-compile` 口径下输出**可被 `cjc` 接受的最小合法 `.cj` 占位物**；
2. 要么在 batch / pipeline 层明确禁止 `mock_mode=true + verify_dry_run=false` 这种组合进入 real compile；
3. 不要在修复这个问题之前，就把 `compile-failed` 解读为“文件翻译逻辑失败”。

#### 5.1.6 修复后断言

- 相同输入下，`MTProtoConfig` / `CryptoUtils` 不应再因为头部 `# ...` 行触发 `compile-failed`；
- 若仍失败，stderr 必须开始暴露**真实仓颉语法/类型/符号错误**，而不是 mock header 错误。

### 5.2 `CLUSTER-B / STATIC_BLACKLIST_SCOPE_LEAK`

#### 5.2.1 受影响目标

- `src/core/mtproto/TLMethods.ets`
- `src/core/mtproto/TLSerialization.ets`

#### 5.2.2 观测症状

- `orchestration.final_status = failed`
- `verify_status = blocked`
- `verify_failure_type = static-blacklist-failed`
- `review_issue_codes` 中出现：
  - `ARCH_DOMAIN_PURITY_VIOLATION`
  - `ARCH_PROTOCOL_ISOLATION`

#### 5.2.3 直接证据

静态墙证据片段直接命中：

- `snippet=# target: src/core/mtproto/TLMethods.ets`
- `snippet=# target: src/core/mtproto/TLSerialization.ets`

也就是说，当前被静态墙拦截的并不是候选业务代码内部真的出现了 Service 层不该知道的 `TL*` 语义，而是候选文件头部的 target metadata 直接把模块路径暴露给了扫描器。

更关键的是，`scripts/static_blacklist_checker.py` 当前的实现表现出两个口径问题：

1. `StaticBlacklistChecker.check(...)` 会扫描整份候选文本的所有行；
2. `strip_comments_preserve_layout(...)` 只处理 `//` 与 `/* ... */` 风格注释，不处理以 `#` 开头的头部行。

因此，`# target: src/core/mtproto/TLSerialization.ets` 这类 metadata 行并没有在进入静态墙前被剥离，最终触发了 `TLSerialization` / `TLMethods` 命中。

#### 5.2.4 根因判断

`CLUSTER-B` 不是“协议层模块真的违反了 RealMessageService 的领域纯洁度约束”，而是：

- Service 专属的 `TL*` 黑名单规则被无差别施加到了 `src/core/mtproto/*` 模块；
- 同时扫描输入面包含了候选文件的 metadata 头部；
- 两者叠加，制造了静态墙假阳性。

#### 5.2.5 修复建议

优先推荐的修复路线：

1. 给静态墙增加**target role / 路径分流**，避免把 `RealMessageService` 级别的 Service 约束直接扫到 `src/core/mtproto/*`；
2. 在进入静态墙前，先剥离批处理注入的 metadata 头部，或把它改写成扫描器与编译器都可忽略的格式；
3. 在这两步完成前，不要把 `TLMethods` / `TLSerialization` 的失败归类为“协议模块语义不纯”。

#### 5.2.6 修复后断言

- `TLMethods` / `TLSerialization` 不应再因为 `# target:` 行而触发 `static-blacklist-failed`；
- 静态墙若继续报警，必须命中**真实候选代码体**，且证据 snippet 不能来自 metadata header。

### 5.3 `CLUSTER-C / REVIEW_CONTRACT_GAP`

#### 5.3.1 受影响目标

- `src/core/mtproto/MTProtoConfig.ets`
- `src/core/mtproto/CryptoUtils.ets`

#### 5.3.2 观测症状

- `review_issue_codes = ["missing-verification-matrix"]`

#### 5.3.3 根因判断

这不是第一阻断项，因为 `CLUSTER-A` 先一步把 compile 撞死了；但它会持续污染 repair guidance，使 backlog 同时夹杂“候选模板错误”和“审查契约不完整”两类噪声。

#### 5.3.4 修复建议

- 把 `Verification Matrix` 从“建议项”升级为当前 TelegramHarmony Pilot 的显式契约；
- 确保 batch / pipeline 场景下的 candidate 或 orchestration 元数据能稳定声明这一约束，避免 reviewer 每轮都重复报警。

#### 5.3.5 修复后断言

- 在 `CLUSTER-A` 清除后，相同 target 不应再因为 `missing-verification-matrix` 占据 repair guidance 头部；
- reviewer 输出应开始聚焦真实映射问题，而不是契约模板缺项。

## 6. 推荐修复顺序（Backlog）

### 6.1 `B1-01`：修复 real-compile 下的 mock candidate 头部

目标：清空 `CLUSTER-A`。

成功标准：`MTProtoConfig` / `CryptoUtils` 不再被 `# mock translator artifact` 头部阻断。

### 6.2 `B1-02`：给静态墙增加作用域分流 + metadata 剥离

目标：清空 `CLUSTER-B`。

成功标准：`TLMethods` / `TLSerialization` 不再因 `# target:` metadata 被 static blacklist 误伤。

### 6.3 `B1-03`：补齐 Verification Matrix 契约

目标：降低 `CLUSTER-C` 噪声。

成功标准：repair guidance 开始聚焦真实失败，而不是反复提醒模板缺项。

## 7. 与“大规模自动翻译”关系

当前结论非常明确：

- **现在还不能开始大规模自动翻译。**
- 原因不是 ArkTS → 仓颉映射已经被证明失败，而是我们还没有把 Batch-1 的 pipeline/verifier/reviewer 假阳性清干净。

只有在满足以下门槛后，才建议进入 Batch-2 或更大批量：

1. `CLUSTER-A` 清零；
2. `CLUSTER-B` 清零；
3. Batch-1 counted target 在 `real-compile` 口径下稳定达到 `>= 3/4 passed`；
4. failure summary 开始主要反映真实仓颉语法/类型/依赖错误，而不是模板/扫描器错误。

## 8. 当前最重要的判断

本轮最重要的不是“哪一个 Telegram 文件最难翻译”，而是：

**我们已经确认 Batch-1 的第一波失败主因来自工具链编排口径，而不是源侧 API 或业务语义本身。**

这意味着后续只要按簇清障，`Staging-Core` 还有很大的放量空间；但如果跳过这一步直接扩大批次，只会把同一种假阳性批量复制到更多文件上。


## 9. B1-01 修复回写（2026-03-31）

针对 `CLUSTER-A / MOCK_ARTIFACT_COMPILE_POLLUTION`，已执行最小修复：

- `scripts/llm_adapter.py` 的 `MockLLMAdapter` 不再输出 `# ...` 头部；
- 改为输出仓颉可接受的 `// ...` 注释元数据 + 最小 `main(): Int64 { return 0 }` stub；
- 新增回归测试 `tests/test_llm_adapter.py`，锁定“mock translator 产物必须可供 real-compile 使用”的行为。

### 9.1 修复后验证结果

- `python -m unittest discover -s tests -p 'test_*.py' -v` → `18/18 OK`
- `python scripts/pipeline_batch_runner.py --manifest docs/manifests/telegramharmony-phase02-batch1-real-compile.json` → `status=passed`
- 最新批次汇总：`artifacts/batch_runs/telegramharmony-phase02-batch1-real-compile/batch-summary.json`

### 9.2 对三类失败簇的影响

- `CLUSTER-A`：已被当前修复直接清空；
- `CLUSTER-B`：在当前 mock translator 基线下，症状也随之消失，因为 `//` 注释会被静态墙剥离，不再让 metadata 头部误伤 `TLMethods` / `TLSerialization`；
- `CLUSTER-C`：当前不再阻断 Batch-1 mock+real-compile 基线，但它仍是 reviewer 契约质量问题，后续切到真实 translator 时仍建议补齐。

### 9.3 当前仍需保持的判断

这次全绿代表的是：

- **Linux `Staging-Core` 的 Batch-1 mock translator + real compile 物理编译基线已经打通。**

它暂时**不代表**：

- `MTProtoConfig`、`CryptoUtils`、`TLMethods`、`TLSerialization` 这四个 ArkTS 文件已经完成真实语义翻译并通过仓颉编译。

因此，下一阶段的主战线已经从“修物理编译基线”转移为：

1. 把 Batch-1 从 `mock translator` 切向真实翻译候选；
2. 在真实候选上重新验证静态墙作用域与 review 契约；
3. 抽取第一批真实类型/语义/依赖修复模式，作为大规模自动翻译前的 pattern backlog。
