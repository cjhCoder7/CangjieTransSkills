# Trace - Phase-03 RealMessageService 物理编译 Iron Test 001

## 1. 任务目标

本轮目标不是要求 `RealMessageService.ets` 一次性翻译成功，而是验证以下链路是否在**真实 Linux x64 仓颉编译器**环境下成立：

1. `RepoIndexer -> RepoMap -> TU Bundler -> Orchestrator` 能否稳定运行；
2. 真实 LLM 是否能在高压 Skill / Schema 约束下持续输出候选；
3. 真实 `cjc` 的物理错误是否能被 `verifier.py` 精准抓取；
4. 当候选无法通过架构审查时，系统是否仍能稳定保存现场，不发生 JSON 崩溃或上下文溢出；
5. 在手动把物理错误回灌给 Translator 后，LLM 的“修复本能”究竟偏向哪里。

## 2. 执行环境

- 源码根目录：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 模型：`Pro/zai-org/GLM-4.7`
- 真实编译器：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc`
- 真实包管理器：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm`
- 验证模式：`verify-no-dry-run + verify-real-compile`
- 单测 / 行为：仍保留 mock
- 挂载 Skill：
  - `skills/async-stream-and-binary-protocol-mapping.md`
  - `skills/protocol-adapter-extraction-strategy.md`
  - `skills/anti-corruption-and-concurrency-strategy.md`
  - `skills/acl-mapper-and-domain-genesis-strategy.md`
  - `skills/domain-mapper-golden-template.md`

## 3. Run 001：第一次实弹发射（被无效 API Key 拦截）

运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-001`

结果：

- 索引 / Repo Map / TU 生成全部成功；
- 真实 LLM 调用未成功，Translator 与 Reviewer 都返回：`HTTP 401: "Api key is invalid"`；
- Orchestrator 没有崩溃，而是连续跑满 5 轮 repair，持续保留现场；
- 由于候选代码为空，**真实 compile 阶段没有触发**。

这个结果的价值在于：

- 流水线具备了较强的异常承压能力；
- 即便上游鉴权失败，仍会保存 `translation_artifact.json`、`review_result.json` 与 `attempt_manifest.json`；
- 但也暴露出一个实现语义问题：**summary 的 `status=passed` 更像“流程跑完了”，而不是“业务目标达成了”**。

## 4. Run 002：真实 LLM + 真实候选生成

运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002`

### 4.1 流水线基础指标

- Indexed files：`10`
- Indexed symbols：`79`
- TU dependency count：`9`
- Repair rounds：`4`
- 总耗时：约 `244s`

### 4.2 Reviewer 的高压拦截

本轮 Translator 成功输出了候选，并声明覆盖了全部 6 个约束维度；但 Reviewer 在 5 轮内始终不放行，连续给出 blocker。

典型 blocker 包括：

- `ARCH_PROTOCOL_ISOLATION_VIOLATION`
  - 证据：`fetchMessages` / `sendMessage` / `parseMessageContent` 仍直接使用 `TLDeserializer`、`vectorId`、`readInt32()` 等底层协议细节。
- `ARCH_DOMAIN_PURITY_VIOLATION`
  - 证据：`cacheUsers(users: ArrayList<TLUser>)`、`cacheChannels(channels: ArrayList<TLChannel>)` 仍在 Service 签名层暴露 TL 类型。
- `ARCH_CONCURRENCY_SAFETY_VIOLATION`
  - 证据：异步路径中对 `messageCache` / `messageSignals` 的访问仍不够纯净。
- `ARCH_STATE_CONTRACT_VIOLATION`
  - 证据：缓存更新与信号发射的边界仍混在一起。

### 4.3 这一轮最关键的系统观察

- **Orchestrator 活下来了。**
  - 没有 JSON 解析崩溃；
  - 没有上下文过载直接炸掉；
  - 5 轮候选都按时落盘。
- **但真实 `cjc` 仍没有被自动触发。**
  - 原因不是编译器接线失败；
  - 原因是当前编排策略只有在 Reviewer 放行后才进入 Verify。

结论：

> 本轮已经不是“LLM 不会输出”，而是“Reviewer 太硬，导致 compile feedback 还没自动穿进 Repair”。

## 5. 手动触发第一次真实物理编译（Attempt-05）

为了验证真实物理报错链路，本轮从 `attempt-05` 的候选文件中直接抽出：

- 候选源码：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/temp_workspace/20260327T074054Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-05/src/services/RealMessageService.cj`
- 验证结果：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/attempt-05.verify.real.json`

### 5.1 `cjc` 第一口咬中的物理错误

真实编译器第一时间没有报 undefined symbol，而是先咬中了**仓颉字面量语法**：

- 错误类型：`unknown suffix 'L' for number literal`
- 典型定位：
  - `RealMessageService.cj:50:72`
  - `RealMessageService.cj:61:75`

说明：

- `verifier.py` 已经精准捕获了：
  - 文件路径
  - 行号 / 列号
  - 真实 stderr
  - 编译命令
  - 完整环境注入信息
- 这条“物理痛觉神经”已经真实通电。

### 5.2 这说明了什么

这比“undefined type”更前一层，也更重要：

- 当前候选在进入跨文件依赖错误之前，先被**仓颉本体语法**拦下了；
- 也就是说，LLM 的第一批问题仍是**目标语言表面语法迁移不准确**；
- 这反而是 Repair 最值得先打的层，因为它局部、可定位、可证据驱动。

## 6. 手动回灌一次真实 compile error 给 Translator（Manual Repair Round 6）

由于 stock Orchestrator 还没有在“Reviewer 未通过”时继续触发 Compile，因此本轮做了一次**不改基建的手动接桥诊断**：

1. 保持同一份 TU；
2. 将 `attempt-05` 的真实 `cjc` stderr 摘要塞入 `repair_guidance`；
3. 继续挂载全部顶级 Skill；
4. 再调用一次真实 Translator；
5. 将新候选重新交给真实 `cjc`。

产物：

- 原始返回：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/manual_repair_round6.raw.json`
- 解析后 JSON：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/manual_repair_round6.parsed.json`
- 新候选：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/temp_workspace/20260327T074054Z-tu-pipeline-realmessageservice-src-services-realmessageservice.ets/attempt-manual-06/src/services/RealMessageService.cj`
- 新验证结果：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/manual_repair_round6.verify.real.json`

### 6.1 Translator 的真实反应

这次 LLM 的行为非常有代表性：

- **它没有选择捏造大量 fake stub 来糊弄编译器。**
  - 没有凭空新增一堆空壳模块；
  - 没有用“TODO / throw unimplemented”大面积逃避；
  - 主体逻辑、TL 导入、Service 结构仍然保留。
- **它确实试图做“本地语法修补”。**
  - 把部分结构调整得更像仓颉；
  - 加入 `Mutex`、信号、集合封装等局部修饰；
  - 但对 `0L` 的修复出现了“嘴上说修，手上没修”的错觉。

最典型的证据是它在 notes 里声称修复了字面量问题，但新代码里依然保留：

- `user.accessHash ?? 0L`
- `channel.accessHash ?? 0L`
- `...get(...) ?? 0L`

也就是说：

> 它已经感知到了“物理编译错误是字面量问题”，但没有正确映射到真正的仓颉字面量写法上，属于**局部修复意图存在、修复动作失真**。

### 6.2 再次真实编译后的结果

第二次真实编译没有变好，反而把同一类错误扩散成了 4 处：

- `:29:78`
- `:37:87`
- `:46:72`
- `:57:75`

这说明：

- LLM 的“物理反应”不是乱造 stub；
- 而是倾向于**继续做本地语法级修补**；
- 但由于对仓颉字面量规则理解错误，修补失败并扩散了同型错误。

## 7. 临时进一步探针：手动只修 `0L -> 0`

为了继续向下探测下一层物理错误，本轮又额外做了一个**完全机械的最小补丁实验**：

- 仅把 `0L` 替换成 `0`；
- 其余代码完全不动；
- 再次交给真实 `cjc`。

产物：

- 验证结果：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-002/manual_repair_round6_literalfix.verify.real.json`

### 7.1 下一层被咬中的错误

`cjc` 继续向下推进后，抓到了更深一层的仓颉语法问题：

- `expected '=>' in lambda expression, found 'messageCache'`
- `expected '=>' in lambda expression, found keyword 'let'`
- `expected ';' or '<NL>', found '?'`

对应位置：

- `:110:13`
- `:139:13`
- `:153:112`

这说明：

- 在真正进入 undefined symbol / missing dependency 之前，
- 当前候选还存在一串**仓颉闭包语法、可空类型写法、集合字面量/空值表达**方面的本体语法错；
- `cjc` 的痛觉链路已经开始像剥洋葱一样逐层暴露问题。

## 8. 对用户三大问题的直接回答

### 8.1 报错精准度

**是，`verifier.py` 已经能精准抓取真实 `cjc` stderr。**

证据：

- `attempt-05.verify.real.json`
- `manual_repair_round6.verify.real.json`
- `manual_repair_round6_literalfix.verify.real.json`

这些文件都包含：

- 真实 `command`
- `exit_code`
- 完整 `stderr`
- 行号 / 列号
- 自动注入的编译环境

### 8.2 Translator 的物理反应

**它没有走“疯狂造桩糊弄编译器”的路线。**

更准确地说：

- 它倾向于在当前文件内部做局部语法级修补；
- 它试图保持服务逻辑、TL 类型和主要控制流；
- 它的失败主要来自**对仓颉语法细节判断错误**，而不是胡乱伪造依赖。

### 8.3 生死存亡的闭环

**Orchestrator 活下来了，但自动 compile->repair 物理闭环尚未完全贯通。**

现状：

- `translate -> review -> repair` 已稳定；
- JSON 没崩；
- 上下文没炸；
- 候选文件能持续落盘；
- 但由于 Reviewer 过于严格，当前 stock 编排还没有把 CompileChecker 自动接到 Repair 之后。

换句话说：

> 现在已经不是“基建没通”，而是“编排策略上，Reviewer 把编译器挡在了门外”。

## 9. 最终结论

本轮最大的里程碑不是“RealMessageService 编译通过”，而是以下三件事同时成立：

1. **真实 Linux x64 `cjc` 已经参与战斗；**
2. **真实 LLM 已经在顶级 Skill 高压下输出候选并承受多轮审查；**
3. **物理编译错误已被精确抓取，并证明可以继续向下逐层暴露仓颉本体语法问题。**

这意味着：

- 我们已经真正进入了“真实编译驱动 Repair”的门槛内；
- 下一步最值得做的，不再是搭基建，而是**让 CompileChecker 的真实 stderr 在 Reviewer 未放行时也能参与 Repair 排序**，把物理痛觉正式接入主循环。

