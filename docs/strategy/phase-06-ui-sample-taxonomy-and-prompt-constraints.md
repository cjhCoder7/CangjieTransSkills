# Phase 06 UI 样本清单、标签体系与 Prompt 约束草案

## 1. 目标与边界

本文件用于把 `Phase 06` 的外部 UI 样本调研收敛成两类可落地资产：

- 一份机器可消费的样本清单：
  [phase06_ui_sample_manifest.json](/volume/wzhang/cky-workspace/my_projects/Cangjie/docs/manifests/phase06_ui_sample_manifest.json)
- 一套可回灌到 `scripts/prompt_assembler.py` 的标签体系与 prompt 约束草案

本文件不是宣传稿，也不是 `Full Pass` 结论文档。
它只服务于 `Staging-Core` 下的样本筛选、Phase 06 prompt 设计和后续 `Staging-Full` 物理验证准备。

## 2. 当前状态对齐

- 当前仓库阶段：`Phase 05: Mass Translation Pipeline Initialization`
- 当前主线：`Linux Staging-Core` 下维持 `service/core` 翻译和 verifier 证据链稳定
- 当前物理阻塞：`Staging-Full` 仍缺 `DevEco Studio`、仓颉插件、`hdc`、GUI/target 与真实 UI 日志回采链路
- 结论：Phase 06 当前只能先做 `样本清单 + 标签体系 + prompt 草案 + headless preflight`

## 3. Source Register

> 访问日期统一为 `2026-04-06`。仓库根目录未检测到 `.git`，repo-local 条目的 `branch/commit` 统一写 `N/A (repo root has no .git)`。

| Source | Branch / Commit | 用途 | 采用状态 |
|---|---|---|---|
| `https://gitcode.com/Cangjie/HarmonyOS-Examples` | `main@f29257acc564b5daedaba4c32b0f9530b3fc0c31` | Phase 06 基础页面/路由/列表样本池 | `primary` |
| `https://gitcode.com/Cangjie/HarmonyOS-Cangjie-Cases` | `main@2d0662bb5c97a15d6bc459688df6c9b23275f12f` | 混合开发、复杂交互、组件缺口与降级边界 | `primary` |
| `https://gitcode.com/Cangjie-TPC/markdown4cj` | `develop@f43cfb3ae1cd3092d9a8a94332c64815fc4572f9` | 复杂组件树、配置对象、plugin | `primary` |
| `https://gitcode.com/Cangjie-TPC/photoview4cj` | `develop@5da6027ebefb59aa146a1486402219a02ae69175` | 手势组件、视图模型、图片变换状态 | `primary` |
| `https://gitcode.com/Cangjie-TPC/svg4cj` | `develop@9b26512106db5d3963417bad2be316a99725a4a8` | View-Model-Renderer 模式参考 | `primary(P1)` |
| `https://gitcode.com/Cangjie-TPC/editor4cj` | `master@4f9a3b9551899ea5aaa6aec740cbb403dd0c8294` | Controller-owned-state 重型组件参考 | `primary(P1)` |
| `https://gitcode.com/MakerStudio/titlebar4cj` | `main@630893a5c34bcd25e261d5adf6d8ea1830d8523f` | 窄域可复用组件参考 | `primary(P1)` |
| `https://gitcode.com/szLilyWu/HttpNewsApp-Cangjie` | `main@9e02e67764a13281ec1c0d413700f878ba55c3c3` | 网络型客户端页面/路由/HTTP manager 参考 | `primary(P1)` |
| `https://gitcode.com/Cangjie-TPC/avif-ffi` | `develop@61dcbc64c4a95ead7d61b57f96db5b871f5a0f9d` | FFI / PixelMap / native decoder 边界 | `exception-only` |
| `https://gitcode.com/Cangjie-TPC/svga-cj` | `develop@e1f7bb4c74084cb9970fc84e854699c48f3048fb` | Hybrid Cangjie/ETS 边界 | `exception-only` |
| `https://gitcode.com/Cangjie-TPC/CangjieMagic` | `harmony_os@61beaadaa09b55afcb76177e1bdb0532b4b53ae1` | Agent DSL / MCP / toolset 基座 | `reference-only` |
| `https://gitcode.com/Maker-IOS-cangjie/cj_log` | `main@b0609761a9e79c5890fc23215588809bde2e45c1` | 日志与可观测性 | `reference-only` |
| `https://atomgit.com/org/cangjiechallenge/repos` | `N/A (organization index)` | 复杂应用评测池 | `deferred-pool` |
| repo-local `samples/ui-routing-defining-page-layout` | `N/A (repo root has no .git)` | UI 路由 control baseline | `control` |
| repo-local `samples/data-persistence-001` | `N/A (repo root has no .git)` | 持久化 control baseline | `control` |
| repo-local `samples/real-message-service-cache-001` | `N/A (repo root has no .git)` | UI refresh / main-thread control rail | `control` |

## 4. 样本采用顺序

### 4.1 P0 主样本

- `HarmonyOS-Examples`
  用于 `page-shell` 的基础页面、路由、列表、`@State/@Link` 传播
- `HarmonyOS-Cangjie-Cases`
  用于 `mixed-app-pattern`、`@Builder`、`@Provide/@Link`、组件缺口/降级边界
- `markdown4cj`
  用于 `rich-component` 的复杂组件树、配置对象、plugin
- `photoview4cj`
  用于 `gesture-component` 的交互态与视图模型

### 4.2 P1 扩展样本

- `svg4cj`
  用于 `view-model-renderer`
- `editor4cj`
  用于 `controller-owned-state`
- `titlebar4cj`
  用于窄域可复用组件边界
- `HttpNewsApp-Cangjie`
  用于客户端网络页面/路由/manager 分层

### 4.3 例外轨

- `avif-ffi`
  归类为 `ffi-exception`
- `svga-cj`
  归类为 `hybrid-exception`

### 4.4 延后评测池

- `cangjiechallenge` 组织下复杂应用仓
  只在 Phase 06 样本轨和 prompt 轨稳定后再进入多文件评测，不做首批 few-shot

## 5. 标签体系

结论：不要把所有标签做成 `8` 个并列主类。
应拆成 `结构标签 + 状态所有权标签 + 交互标签 + 例外标签 + 样本范围标签`。

### 5.1 结构标签

- `page-shell`
- `rich-component`

规则：每个文件样本必须且只能命中一个结构标签。

### 5.2 状态所有权标签

- `view-model-renderer`
- `controller-owned-state`

规则：每个文件样本必须且只能命中一个状态所有权标签。

### 5.3 交互标签

- `gesture-component`

规则：只在手势、缩放、拖拽、旋转、复杂交互优先级相关样本上附加。

### 5.4 例外标签

- `ffi-exception`
- `hybrid-exception`

规则：只要命中这两个标签之一，就必须进入边界约束轨，不能混入通用 UI few-shot。

### 5.5 样本范围标签

- `mixed-app-pattern`

规则：只用于样本级标记，不作为文件主标签。
含义是“该 repo/app 同时包含多种模式”，实际 prompt 仍必须按文件局部标签装配。

## 6. 标签解析规则

建议在 `prompt_assembler.py` 中引入如下解析顺序：

```text
[Tag Resolution]
structure = required
ownership = required
interaction = optional
exception = optional
sample_scope = optional
```

决策规则：

1. 先决出 `structure_tag`
2. 再决出 `ownership_tag`
3. 再看是否需要 `gesture-component`
4. 最后再判断是否命中 `ffi-exception` / `hybrid-exception`
5. `mixed-app-pattern` 只参与样本级组织，不参与文件级强约束替代

## 7. Prompt 约束草案

### 7.1 通用骨架

建议 Phase 06 的 UI prompt 结构采用：

```text
[Tag Resolution]
[Source Alignment Lock]
[Ownership Lock]
[Execution Lock]
[Boundary Lock]
[Hard Ban List]
```

### 7.2 通用锁

#### `[Source Alignment Lock]`

- 页面名、组件名、路由名、参数语义、事件名保持 `1:1`
- 不允许为了“看起来更仓颉”而重写 public UI contract
- 不允许把 source-aligned 页面/组件拆成无法追溯的 invented shell

#### `[Ownership Lock]`

- 明确唯一真值所有者
- 禁止 shadow state
- 禁止 duplicate store
- 禁止 invented bridge / fake provider / fake facade

#### `[Execution Lock]`

- 只在 `gesture-component`、异步 controller、`hybrid-exception` 命中时展开
- 保留手势优先级、取消语义、回调顺序、动画触发边界

#### `[Boundary Lock]`

- 只在 `ffi-exception` / `hybrid-exception` 命中时启用
- native / bridge / adapter 必须收敛在 `private/internal` 边界
- 除 source 明示外，public UI contract 不得外泄 FFI / hybrid 细节

#### `[Hard Ban List]`

- 禁止 inline service / repository / native shell
- 禁止 public contract 改写
- 禁止为过编译发明中间层
- 禁止把 `mixed-app-pattern` 的 app 级复杂度一次性压回单文件

## 8. 按标签追加的最小硬约束

### 8.1 `page-shell`

- 页面文件只保留 page / router / lifecycle / short-lived UI state
- 禁止在页文件内直接内联 repository / runtime / persistence 真值
- 允许页面聚合子组件，但不允许吸收子组件实现细节

### 8.2 `rich-component`

- 视为可复用视图块
- 输入只来自 props / 参数 / callback / model
- 禁止在组件文件里承担 page / ability / router 责任
- 禁止直接承载持久化或网络编排

### 8.3 `gesture-component`

- 手势 handler 只操作交互态 / 动画态 / view transform
- 必须保留阈值、取消语义、优先级和回调顺序
- 禁止在 gesture 回调里塞网络、存储或长事务

### 8.4 `view-model-renderer`

- UI 只消费外部 snapshot / render model / intents
- 禁止声明 shadow store、invented signal、service-local cache
- 副作用只上送，不在 renderer 文件内自我拥有

### 8.5 `controller-owned-state`

- controller / store / service 是唯一真值
- UI 只镜像最小 display state
- 异步编排、持久化、数据修复都留在 controller
- 不得把 controller 责任泄漏到 public UI contract

### 8.6 `ffi-exception`

- native / FFI 边界只能通过 `private/internal adapter` 收敛
- public UI contract 不得出现 FFI 细节，除非 source 明示
- 禁止 invented placeholder FFI、伪 bridge、伪 decoder shell

### 8.7 `hybrid-exception`

- 必须显式拆分 `UI shell / controller / native or runtime`
- 只允许单向数据流和显式回调边界
- 禁止把 hybrid 逻辑塌缩为单文件 mega page

### 8.8 `mixed-app-pattern`

- 仅表示样本跨文件、多模式
- prompt 必须按文件局部标签组装
- 禁止按整个 app 的混合语义一次性压到单文件翻译

## 9. Phase 06 默认约束组合

### 9.1 基线

- `Translation Mapping`
- `Architecture Mapping`

### 9.2 命中 `view-model-renderer` 或 `controller-owned-state`

- 追加 `State Contract`

### 9.3 命中 `gesture-component`

- 追加 `Execution Topology`

### 9.4 命中 `controller-owned-state`、`ffi-exception` 或 `hybrid-exception`

- 追加 `Dependency Constraint`

### 9.5 命中 `ffi-exception` 或 `hybrid-exception`

- 追加 `Boundary Contract`

## 10. 当前不能宣称的内容

按 `AGENTS.md` 与当前 `current-phase`：

- 不能写 `Full Pass`
- 不能写 `Harmony UI 已验证`
- 不能写 `UI 主线程物理证据齐全`
- 不能写 `DevEco / hdc / target 已验证`
- 不能写 `Phase 06 可无人工复现`

当前最多只能宣称：

- `样本来源已冻结`
- `样本切片已完成`
- `标签体系已收口`
- `prompt 约束草案已准备`
- `headless preflight 可进行`

## 11. 下一步对接动作

1. 用本文件的标签体系，为 `scripts/prompt_assembler.py` 新增 `ui` 车道
2. 为 `Phase 06` 建立首批 curated few-shot 片段包：
   - `HarmonyOS-Examples`
   - `HarmonyOS-Cangjie-Cases`
   - `markdown4cj`
   - `photoview4cj`
3. 在 `scripts/static_blacklist_checker.py` 中为 `ffi-exception` / `hybrid-exception` 准备例外保护，不让它们污染通用 UI 轨
4. 等 `Staging-Full` 宿主补齐后，再对 `P0` 样本做 DevEco import / emulator-device smoke / UI evidence 回采
