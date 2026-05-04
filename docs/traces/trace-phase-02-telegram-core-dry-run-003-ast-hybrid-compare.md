# Trace - Phase-02 Telegram 核心模块 Dry-Run 003（AST / Hybrid Compare）

## 任务目标

验证 `scripts/repo_indexer.py` 在接入 `tree-sitter-languages` 后，是否已经具备以下能力：

- 支持 `--parser-mode [regex|ast|hybrid]` 三档解析模式；
- 在 `hybrid` 模式下输出 AST vs Regex 差异报告；
- 用 AST 上下文过滤 `console.info`、`array.push`、`toString` 等明显噪声调用边；
- 在 `RealMessageService.ets` 等真实复杂 ArkTS 片段上保持 method 级 owner binding 与 method → method call edge 粒度。

## 输入与执行命令

- 输入目录：`raw_docs/telegramharmony-phase02`
- 目标文件：`src/services/RealMessageService.ets`
- 依赖文件：
  - `src/core/mtproto/MTProtoClient.ets`
  - `src/core/mtproto/TLSerialization.ets`
  - `src/core/mtproto/MTProtoTransport.ets`
- 执行命令：

```bash
python scripts/repo_indexer.py \
  --root raw_docs/telegramharmony-phase02 \
  --db artifacts/pipeline_runs/phase02-telegram-core-dry-run-003-ast-hybrid-compare/repo_index.sqlite \
  --snapshot-label telegram-ast-compare \
  --parser-mode hybrid \
  --reset-db \
  --diff-report-path artifacts/pipeline_runs/phase02-telegram-core-dry-run-003-ast-hybrid-compare/diff-report.json
```

## AST Query 设计

当前 `TreeSitterQueryBackend` 采用 TypeScript grammar 作为 ArkTS 近似语法，核心 Query 分为三组：

### 1. Symbol Query

- `class_declaration` → `@symbol.class`
- `interface_declaration` → `@symbol.interface`
- `method_definition` → `@symbol.method`
- `function_declaration` / `generator_function_declaration` → `@symbol.function`
- `lexical_declaration -> variable_declarator -> arrow_function/function` → 箭头函数与匿名 function 赋值场景

### 2. Call Query

当前使用稳定的两段式 Query：

- `call_expression(function: (identifier))`
- `call_expression(function: (member_expression property: (property_identifier)))`

说明：

- 早期尝试将 `optional_chain` 直接写入 Query，但在当前 `tree-sitter==0.21.x` / `tree-sitter-languages==1.10.2` 组合下会触发 Query 语法错误；
- 本轮先采用稳定 Query + `member_expression` 文本抽取，仍可覆盖 `this.messageSignals.get(key)?.set(...)` 这类重要链路；
- `optional_chain` 的专门 Query 可留待后续 grammar 兼容性升级时补上。

### 3. Import Query

- `import_statement` → `@import.statement`

## 关键实现修复

### 1. 真正接通 AST / Hybrid 模式

新增并打通：

- `TreeSitterQueryBackend`
- `HybridParserBackend`
- `normalize_parser_mode(...)`
- `select_parser_backend(...)`
- `--parser-mode`
- `--diff-report-path`

### 2. 修复 byte offset 误切字符串问题

Tree-sitter 的 `start_byte` / `end_byte` 不能直接切 Python `str`；
本轮已改为统一基于 `source_bytes` 取片段并 `decode('utf-8', errors='ignore')`。

这一步是 AST 识别恢复正常的决定性修复。

### 3. 加入 AST clean-edge 过滤

当前已基于 AST receiver 上下文过滤：

- `console.info/log/debug/warn/error`
- `Date.now`
- 非 `this` 接收者上的 `push/pop/shift/unshift/slice/map/filter/forEach/toString`

同时保留对状态敏感或协议敏感的方法：

- `get`
- `set`
- `has`
- `sendRequest`
- `readInt32`
- `readString`
- `readBytes`

## 产物路径

- SQLite：`artifacts/pipeline_runs/phase02-telegram-core-dry-run-003-ast-hybrid-compare/repo_index.sqlite`
- Diff Report：`artifacts/pipeline_runs/phase02-telegram-core-dry-run-003-ast-hybrid-compare/diff-report.json`
- 本 Trace：`docs/traces/trace-phase-02-telegram-core-dry-run-003-ast-hybrid-compare.md`

## 全局结果摘要

- `Indexed Files = 10`
- `Symbol Nodes = 80`
- `Call Edges = 88`
- `Contains Edges = 126`
- `Import Edges = 0`
- `Parser Mode = hybrid`
- `Parser Backend = hybrid(ast+regex)`

## 主目标结果：`RealMessageService.ets`

### 1. Method 识别

`RealMessageService.ets` 的 methods 已恢复到 `8 / 8`：

- `constructor`
- `cacheUsers`
- `cacheChannels`
- `createInputPeer`
- `getMessages`
- `fetchMessages`
- `sendMessage`
- `parseMessageContent`

并且都已正确挂在 `RealMessageService` class 之下。

### 2. Call Edge 质量

本轮入库后的 target call edge 已具备 receiver 语义：

- `this.userAccessHashes.set`
- `this.messageSignals.has`
- `this.fetchMessages`
- `client.sendRequest`
- `deserializer.readInt32`
- `this.messageSignals.get(key)?.set`

这意味着 `call` 边不再只是“某个 method 调了一个名字”，而是已经带有可供 L3 / L4 使用的结构上下文。

### 3. 噪声过滤结果

对 `src/services/RealMessageService.ets`：

- `regex_call_count = 39`
- `ast_call_count = 37`
- `calls_ast_only_count = 5`
- `calls_regex_only_count = 7`
- `regex_noise_filtered_count = 7`
- `target_noise_call_count_after_hybrid_insert = 0`

被识别为 regex 噪声并从最终 call graph 中清掉的典型调用：

- `constructor -> info`
- `cacheUsers -> toString`
- `cacheChannels -> toString`
- `fetchMessages -> push`
- `getMessages -> error`
- `parseMessageContent -> error`
- `sendMessage -> now`

### 4. AST 新增的真实调用

AST 抓到而 regex 漏掉的典型调用：

- `createInputPeer -> BigInt`（4 处）
- `sendMessage -> BigInt`

这说明 AST 已经开始补足 regex 难以稳定覆盖的“构造型 / 全局函数型”调用。

## 依赖文件对照摘要

### `MTProtoClient.ets`

- `regex_symbol_count = 14`
- `ast_symbol_count = 14`
- `calls_regex_only_count = 2`
- `regex_noise_filtered_count = 2`

典型被过滤噪声：`error`、`now`

### `TLSerialization.ets`

- `regex_symbol_count = 13`
- `ast_symbol_count = 13`
- `ast_call_count = 12`，高于 regex 的 `8`
- `calls_ast_only_count = 4`
- `calls_regex_only_count = 0`

说明 AST 对二进制协议 helper 的 method 调用链可见性更强。

### `MTProtoTransport.ets`

- symbol 与 call 结果基本一致；
- 说明该文件的语法结构对 regex 已较友好，Hybrid 主要贡献在“结果校验”而非“纠错”。

## 结论

这轮升级意味着 `repo_indexer.py` 已正式从“Regex-only 原型”进入“AST / Hybrid 可压测”阶段：

- `L1 Repo Index` 已具备稳定 AST 主路径；
- `L2 Repo Map` 后续可直接消费更干净的 method → method call graph；
- `L3 TU Bundler` 可开始利用 receiver-aware 的依赖闭包；
- `L4 Reviewer / Repair` 后续可以基于 `[ASYNC_FLOW]`、`[BINARY_PROTO]` 与真实调用边触发更精确的架构 Skill；
- `Regex` 在此后更适合作为兜底与差异基准，而不是主事实源。

## 已知剩余问题

1. `optional_chain` 的 Tree-sitter Query 仍未稳定纳入显式规则；
2. `Import Edges = 0` 说明 import 解析虽然已抓到语句，但路径落边与模块解析仍可继续增强；
3. `tree-sitter` 当前版本会输出一个 `FutureWarning`，不影响本轮功能，但后续可考虑升级兼容方案。
