# Kernel Admission Phase 2.1（Option 首块）设计稿

## 1. 背景

Phase 1 已为当前仓库建立 `.claude` 入口层神经中枢，明确了：

- `mission-control.md` 作为总控台；
- `current-phase.md` 作为动态战况板；
- `pipeline-runner.md` 作为命令入口手册；
- `skills/index.md` 作为 L1 / L2 / L3 三层知识路由总线；
- `/.claude/skills/base-kernel/` 作为 Phase 2 的预置位；
- `scripts/sync/` 作为 Phase 3 文档同步与切片流水线的预置位。

当前进入 Phase 2 的目标不是批量吸收全部 private kernel 文档，而是先选择一个最适合点燃“知识炼金炉”的最小单元，验证以下链路是否成立：

`外来 Markdown -> 代码块抽取 -> 最小工作区 -> verifier.py -> 真实 compile 证据 -> verdict -> 接收版 base-kernel 文档`

本阶段选择 `Option` 作为首个入场体检样本，其原因包括：

- 代码块相对独立；
- 依赖最少；
- 更适合作为 admission engine 的第一块垂直切片；
- 能覆盖 `standalone` / `wrappable` / `context-only` 三类 snippet 形态；
- 能在较低复杂度下建立 `[L3-VERIFIED]`、`[L3-DEPRECATED]` 等标记协议。

---

## 2. 本次范围（Phase 2.1）

### 2.1 纳入范围

本次 Phase 2.1 只做 `Option` 首块入场体检，目标包括：

1. 从外部 `Option` Markdown 文档抽取 fenced code block；
2. 对 snippet 做最小分类：
   - `standalone`
   - `wrappable`
   - `context-only`
3. 为可验证 snippet 生成最小工作区；
4. 复用现有 `scripts/verifier.py` 做真实 compile 级体检；
5. 生成结构化 admission 结果：
   - `source-manifest`
   - `admission-index`
   - `verify_result`
   - `run sandbox`
6. 生成一份接收版 `/.claude/skills/base-kernel/option.md`。

### 2.2 明确不纳入范围

本次不做以下内容：

- 不批量吸收整个 `cangjie-kernel`；
- 不做 HTML 文档处理；
- 不做多源文档同步；
- 不做复杂语义切片；
- 不做 Harmony 相关知识接入；
- 不做 `Atomic` / `ArrayList` / `CFFI` 等更复杂单元；
- 不做自动 patch 的完整策略；
- 不做批量并行 admission framework。

---

## 3. 设计目标

### 3.1 主目标

本次设计要证明以下最小命题：

> 一个外来 Markdown 技能文档中的代码块，可以被自动抽取、最小包装、交由 `verifier.py` 进行 compile 级体检，并根据结果生成可供 Agent 消费的 L1 接收版文档。

### 3.2 成功标准

本次最小成功标准为：

1. 至少抽取出 `Option` 文档中的 fenced code block；
2. 至少一个 snippet 进入 `standalone` 或 `wrappable` 路径并真实 compile 通过；
3. 至少一个 snippet 被判定为 `context-only`；
4. 生成 `admission-index.json`；
5. 生成 `/.claude/skills/base-kernel/option.md`；
6. 接收版文档中出现至少一个 `L3` 状态标签；
7. 每个进入 verifier 的 snippet 都有独立的 run sandbox 和 `verify_result.json`。

---

## 4. 实施方案比较

### 4.1 方案 A：手工体检

- 手工复制 `Option` 文档；
- 手工挑选 snippet；
- 手工运行 `cjc` / `verifier.py`；
- 手工写 verdict。

优点：
- 最快。

缺点：
- 不可复用；
- 证据链容易分散；
- 后续每个 kernel 单元都要重来。

### 4.2 方案 B：半自动 admission MVP（推荐）

- 人工指定输入文档；
- 脚本自动抽 fenced code block；
- 自动生成最小工作区；
- 自动调用 `verifier.py`；
- 自动生成 admission index；
- 自动生成接收版 `option.md`。

优点：
- 形成可复用的最小 admission 骨架；
- 不会第一轮就滑向大平台；
- 能直接复用于 `Atomic` / `ArrayList` / `cjpm` 等后续单元。

缺点：
- 第一轮还不够通用；
- 需要更清楚地限制功能边界。

### 4.3 方案 C：完整通用 admission framework

- 批量多文档处理；
- 多源文档输入；
- 自动 patch；
- 复杂分类与回写。

优点：
- 长期最优。

缺点：
- 第一轮过重；
- 容易掩盖 admission engine 最小价值；
- 极易与现有翻译平台耦合过深。

### 4.4 结论

采用 **方案 B：半自动 admission MVP**。

---

## 5. 文件结构与职责

### 5.1 Create

- `scripts/sync/kernel_admission.py`
  - Phase 2.1 admission runner；
  - 负责读取单个 Markdown、抽取 fenced block、分类 snippet、构造最小工作区、调用 `verifier.py`、生成 admission 结果。

- `/.claude/skills/base-kernel/option.md`
  - `Option` 的接收版文档；
  - 只展示经过准入判定后的结构化知识。

- `artifacts/knowledge_admission/source-manifest.jsonl`
  - 记录输入文档来源信息。

- `artifacts/knowledge_admission/admission-index.json`
  - 记录所有 snippet 的 shape、verdict、labels、证据路径。

- `artifacts/knowledge_admission/runs/option/<snippet-id>/...`
  - 每个 snippet 的独立 run sandbox。

### 5.2 Modify

- `scripts/sync/README.md`
  - 从单纯 placeholder 升级为包含 `kernel_admission.py` 的接口说明。

- `/.claude/skills/base-kernel/.placeholder`
  - 明确 `Option` 已作为首个 admission 样本接入。

### 5.3 不新增内容

本次不新增完整的 Skill schema 生成器，不修改现有 `verifier.py` 主逻辑，不引入新的测试框架。

---

## 6. 数据流设计

### 6.1 总体流程

`kernel_admission.py` 的最小数据流定义为：

1. **Load Source**
   - 读取单个 Markdown 文档；
   - 记录来源到 `source-manifest.jsonl`。

2. **Extract Fenced Blocks**
   - 抽取 fenced code block；
   - 为每个 snippet 记录：
     - `snippet_id`
     - `source_line_start`
     - `source_line_end`
     - `raw_code`
     - `heading_context`
     - `preceding_text_excerpt`

3. **Classify Snippet Shape**
   - 分类为：
     - `standalone`
     - `wrappable`
     - `context-only`

4. **Build Admission Sandbox**
   - 为每个可验证 snippet 创建独立 run 目录；
   - 生成：
     - `candidate.cj`
     - `tu.json`
     - `artifact.json`
     - `snippet.json`
     - `source_excerpt.md`

5. **Verify**
   - 调用现有 `scripts/verifier.py`；
   - 第一轮仅启用真实 compile；
   - unit test 与 behavior 仍保持 mock。

6. **Verdict**
   - 根据 compile 结果与 shape 生成 admission verdict；
   - 写入 `admission-index.json` 与 run 目录内的 `admission_result.json`。

7. **Assemble Accepted Document**
   - 生成 `/.claude/skills/base-kernel/option.md` 接收版文档；
   - 把 snippet 组织成 `verified` / `context-only` / `deprecated` 等区块。

---

## 7. Snippet 抽取与分类

### 7.1 抽取规则

第一轮只处理 fenced code block：

- 支持 ```` ```cangjie ````；
- 支持普通 ```` ``` ````；
- 保留原始顺序；
- 不处理 HTML 或行内代码。

### 7.2 Shape 分类规则

#### `standalone`
满足任一：
- 包含 `main()`；
- 包含 `main (`；
- 代码块本身已构成完整单文件程序。

#### `wrappable`
满足全部：
- 不包含 `main`；
- 包含完整定义，如 `func` / `enum`；
- 可通过最小 wrapper 转成可编译候选程序。

#### `context-only`
满足任一：
- 片段过短，只是语法演示；
- 明显依赖外部上下文；
- 无法通过极小 wrapper 变成单文件候选程序。

### 7.3 为什么只分三类

- 这足以支撑 `Option` 首块；
- 过早引入更复杂分类会遮蔽 admission engine 的核心价值；
- 后续处理 `Atomic` / `CFFI` 时再扩展更细粒度分类。

---

## 8. 最小工作区与 verifier 适配

### 8.1 Run Sandbox 目录

每个 snippet 的 run 目录建议为：

- `artifacts/knowledge_admission/runs/option/<snippet-id>/`

其中至少包含：

- `source_excerpt.md`
- `snippet.json`
- `candidate.cj`
- `tu.json`
- `artifact.json`
- `verify_result.json`
- `admission_result.json`

### 8.2 `candidate.cj` 生成规则

#### 对 `standalone`
- 直接写入原始 snippet。

#### 对 `wrappable`
- 用最小 wrapper 包裹；
- wrapper 只允许做最小入口补齐，不允许重写知识语义。

例如：

```cangjie
<原始 snippet>

main() {
    let _ = getString(Some(1))
}
```

#### 对 `context-only`
- 不生成 `candidate.cj`；
- 不进入真实 compile；
- 只在 admission index 和接收版文档中体现其背景知识价值。

### 8.3 `tu.json` 最小结构

第一轮 `tu.json` 仅需满足 `verifier.py` 的最小消费要求，建议结构：

```json
{
  "tu_id": "kernel-admission::option::snippet-001",
  "target": {
    "path": "candidate.cj",
    "role": "kernel-admission"
  },
  "snapshot": {
    "root_path": "<run_dir>"
  }
}
```

### 8.4 `artifact.json` 最小结构

建议结构：

```json
{
  "generated_code": "<candidate.cj 全文>",
  "metadata": {
    "workspace_dir": "<run_dir>",
    "attempt_dir": "<run_dir>",
    "candidate_file_path": "<run_dir>/candidate.cj",
    "candidate_rel_path": "candidate.cj"
  }
}
```

### 8.5 为什么直接复用 `verifier.py`

当前 `verifier.py` 已经具备：

- `--tu-json` / `--artifact-json` CLI；
- `candidate_file_path` / `workspace_dir` / `attempt_dir` 的真实消费路径；
- compile check 命令模板；
- stderr 捕获与结构化结果输出。

因此 Phase 2.1 不需要重写 compile admission checker，只需构造好最小工件。

---

## 9. Admission Verdict 与标签协议

### 9.1 双层判定模型

#### Layer 1：系统内部 verdict
写入 `admission-index.json`：

- `ADMITTED_VERIFIED`
- `ADMITTED_PATCHED`
- `ADMITTED_CONTEXT_ONLY`
- `ADMITTED_L2_RESTRICTED`
- `QUARANTINED_DEPRECATED`
- `REJECTED_HARMFUL`

#### Layer 2：Agent 可见标签
写入 `option.md`：

- `[L3-VERIFIED]`
- `[L3-PATCHED]`
- `[L3-CONTEXT-ONLY]`
- `[L3-DEPRECATED]`
- `[L2-RESTRICTED]`
- `[L3-BLOCKED-BY:<reason>]`

### 9.2 首轮建议主 verdict

`Option` 首轮主要启用：

- `ADMITTED_VERIFIED`
- `ADMITTED_CONTEXT_ONLY`
- `QUARANTINED_DEPRECATED`
- `REJECTED_HARMFUL`

`ADMITTED_PATCHED` 与 `ADMITTED_L2_RESTRICTED` 的协议先保留，但不在首轮大量使用。

### 9.3 判定规则

#### `standalone` / `wrappable` 且 compile pass
- verdict = `ADMITTED_VERIFIED`
- label = `[L3-VERIFIED]`

#### `context-only`
- verdict = `ADMITTED_CONTEXT_ONLY`
- label = `[L3-CONTEXT-ONLY]`

#### compile fail 且暂不引入 patch
- verdict = `QUARANTINED_DEPRECATED`
- label = `[L3-DEPRECATED]`

#### 命中高危黑名单或污染性模式
- 若是语言层存在但项目禁用：`ADMITTED_L2_RESTRICTED`
- 若本身是错误/污染性示例：`REJECTED_HARMFUL`

### 9.4 `[L3-DEPRECATED]` 的严格条件

只有在以下条件同时满足时才可打上 `[L3-DEPRECATED]`：

- snippet 真实进入 verifier；
- compile 真实失败；
- 失败不是 admission engine 自身 bug；
- 当前轮次不做自动 patch。

不能只凭“看起来像旧语法”就打标签。

### 9.5 强制单向门

命中以下高危项时，触发：

`L3 -> L2 -> Repair`

并明确禁止：

`L3 -> L1 -> 寻找保留脏代码的理由`

典型高危项：
- `static-blacklist-failed`
- `std.unsafe`
- `import ... from`
- `Signal`
- `ValueSignal`
- 污染性协议/字节流直出模式

---

## 10. `option.md` 接收版结构

`/.claude/skills/base-kernel/option.md` 不是原文复制，而是一份带 verdict 的接收版文档。

### 10.1 推荐结构

1. 文档头
   - 来源路径
   - intake 时间
   - 当前 admission 统计
2. 核心定义区
   - `Option<T>`
   - `?T`
   - `Some / None`
   - `??`
   - `match`
3. Verified Snippets
   - `[L3-VERIFIED]`
4. Context-only Snippets
   - `[L3-CONTEXT-ONLY]`
5. Deprecated / Quarantine
   - `[L3-DEPRECATED]`
6. Admission Metadata
   - `source-manifest`
   - `admission-index`
   - `runs root`

### 10.2 Snippet 卡片格式

每个 snippet 卡片至少包括：

- `snippet_id`
- `status`
- `shape`
- `source_lines`
- `evidence path`
- `code`
- `note/reason`

---

## 11. Section 4：最小 runbook、实施顺序与禁区边界

### 11.1 第一轮 CLI 形态

`kernel_admission.py` 第一轮建议只支持中等粒度 CLI：

```bash
python scripts/sync/kernel_admission.py \
  --source-markdown <path> \
  --topic option \
  --output-skill .claude/skills/base-kernel/option.md \
  --admission-root artifacts/knowledge_admission \
  --compiler-executable <cjc path> \
  --compiler-home <compiler home> \
  --runtime-lib-path <runtime lib path> \
  --tool-bin-path <tool bin path>
```

### 11.2 为什么不用超轻或超通用 CLI

- 超轻 CLI 会把路径和策略硬编码死，不利于第二块知识复用；
- 超通用 CLI 会过早暴露 patch mode、batch mode、HTML mode、semantic slicing 等复杂度。

中等粒度 CLI 最适合 Phase 2.1。

### 11.3 推荐实施顺序

按风险递增的顺序实现：

1. **Source manifest**
   - 能记录来源信息；
2. **Fenced block extraction**
   - 能把 Markdown 变成 snippet 列表；
3. **Shape classification**
   - 能判定 `standalone` / `wrappable` / `context-only`；
4. **Run sandbox generation**
   - 能生成 `candidate.cj` / `tu.json` / `artifact.json`；
5. **Verifier integration**
   - 能真实跑 compile check；
6. **Admission index**
   - 能形成结构化 verdict；
7. **Accepted document assembly**
   - 能输出接收版 `option.md`。

### 11.4 首轮明确禁区

Phase 2.1 第一轮明确不做：

- 自动 patch；
- 多文档批量 admission；
- HTML 输入；
- 语义切片；
- 自动原位回写外部文档；
- 完整 L2 restricted 模式识别引擎；
- unit test project generation；
- 并行处理或复杂缓存。

### 11.5 第一轮验证命令

建议至少验证以下两层：

#### A. Admission runner 产物存在性

- 输出 `source-manifest.jsonl`
- 输出 `admission-index.json`
- 输出 `option.md`
- 至少一个 run sandbox 目录存在

#### B. 真实 compile 证据

- 至少一个 `verify_result.json` 显示 compile 通过
- 至少一个 snippet 被判 `ADMITTED_CONTEXT_ONLY`
- 如存在失败 snippet，其 `verify_result.json` 与 `[L3-DEPRECATED]` 能对应起来

### 11.6 第一轮完成门槛

只有满足以下条件，才可宣称 Phase 2.1 跑通：

1. `kernel_admission.py` 能处理 `Option` 单文档；
2. 至少一条 snippet compile pass；
3. 至少一条 snippet context-only；
4. `admission-index.json` 生成；
5. `option.md` 生成；
6. `option.md` 中出现 `L3` 状态标签；
7. 所有进入 verifier 的 snippet 都有独立 run sandbox。

---

## 12. 风险与对策

### 12.1 风险：`kernel_admission.py` 过早膨胀成大平台

对策：
- 第一轮只接受单 Markdown；
- 禁止自动 patch 和多文档 batch；
- 实施顺序按风险递增推进。

### 12.2 风险：snippet 分类过于聪明，结果不稳定

对策：
- 只保留 `standalone` / `wrappable` / `context-only` 三分类；
- 先把 Admission Engine 的基本价值做实。

### 12.3 风险：verifier 工件格式不匹配

对策：
- 明确采用最小 `tu.json` 与 `artifact.json` 结构；
- 直接贴合 `verifier.py` 已有字段：
  - `workspace_dir`
  - `attempt_dir`
  - `candidate_file_path`
  - `candidate_rel_path`

### 12.4 风险：把“过期知识”和“有害知识”混为一谈

对策：
- `[L3-DEPRECATED]` 只在真实 compile 失败且有证据时使用；
- `REJECTED_HARMFUL` 仅用于真正有害或污染性知识；
- 默认优先使用 `context-only` 或 `deprecated`，避免动辄重刑。

---

## 13. 验收标准

若本设计被正确实现，则应满足：

1. `Option` 文档 fenced block 可以被抽取；
2. snippet 可以被稳定分成三类；
3. verifier 适配层能对接真实 `cjc`；
4. `admission-index.json` 成为结构化 verdict 入口；
5. `option.md` 成为首份带物理痛觉的 L1 接收版文档；
6. Phase 2.1 完成后，可不改协议地继续接入 `Atomic`、`ArrayList`、`cjpm` 等第二批 kernel 单元。

---

## 14. 一句话总结

Phase 2.1 的本质，不是导入 `Option` 文档，而是建立一条能够让外来 L1 知识先接受 `verifier.py + cjc` 物理痛觉、再以 verdict 与标签形式进入 `base-kernel` 的最小准入通道。
