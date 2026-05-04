# HarmonyOS 仓颉应用 Skill Schema V1

## 1. 文档目的

本文档定义项目内 **鸿蒙仓颉应用 Skill** 的统一结构规范，用于指导后续所有 Skill 单元的创建、评审、维护与调用。

本 Schema 的目标不是限制最终目录形态，而是确保每一个 Skill 单元都具备：

- 可触发；
- 可理解；
- 可渐进展开；
- 可检索降级；
- 可测试验证；
- 可持续维护。

## 2. 设计原则

### 2.1 Schema 先于目录

- 本 Schema 优先定义 Skill 的内部知识结构；
- 目录树、文件命名和物理组织方式可以后续演化；
- 只要 Skill 内容遵守本 Schema，就允许后续适配不同目录方案。

### 2.2 渐进式披露

每个 Skill 不应一上来堆满所有资料，而应按复杂度逐层展开：

1. 先告诉 Agent 何时必须触发该 Skill；
2. 再给出最小核心概念；
3. 再给出基础语法与常见映射；
4. 再进入 UI / 系统能力 / AI 接口等复杂模块；
5. 若仍不足，再进入检索降级与调试环节。

### 2.3 以执行为导向

Skill 不应只是“知识说明卡片”，而应尽量回答：

- 什么时候使用；
- 如何实现；
- 怎么验证；
- 不会时如何查；
- 失败时怎么定位问题。

### 2.4 可回写与可维护

每个 Skill 后续都应支持：

- 补充新示例；
- 增加版本差异说明；
- 记录已知缺口；
- 回写验证结论和失败模式。

## 3. Skill 单元文件建议

每个 Skill 建议单独成文，文件名使用 `kebab-case`，例如：

- `ui-list-grid-layout.md`
- `page-routing-and-param-passing.md`
- `preferences-state-persistence.md`
- `http-request-and-permission.md`
- `hilog-and-file-logger.md`

如果后续要兼容机器处理，也可以在 Markdown 外增加同名 `.yaml` 或 `.json` 元数据文件，但第一阶段优先保证 Markdown 可读性。

## 4. 必选字段总览

每个 Skill 单元必须包含以下一级字段：

1. `Skill ID`
2. `Skill Name`
3. `Scope`
4. `Trigger Condition`
5. `Core Concept`
6. `Progressive Modules`
7. `Translation Mapping`
8. `Examples`
9. `Retrieval Fallback`
10. `Test & Debug`
11. `Sources`
12. `Version Notes`
13. `Known Gaps`
14. `Evolution Log`

以下章节对这些字段做详细定义。

## 5. 字段定义

### 5.1 Skill ID

**作用**：为 Skill 提供唯一标识，便于引用、索引、追踪与回写。

**要求**：

- 使用 `kebab-case`；
- 同一 Skill ID 不得复用；
- ID 应体现问题域，而不是文档章节号。

**推荐格式**：

```text
<domain>-<topic>-<capability>
```

**示例**：

```text
ui-list-grid-layout
network-http-request
state-preferences-persistence
```

### 5.2 Skill Name

**作用**：给人类与 Agent 提供可读名称。

**要求**：

- 使用中文或中英混合的清晰命名；
- 一眼能看出主题；
- 不要过宽泛。

**示例**：

```text
ArkUI 列表与网格布局转换
HTTP 请求与权限配置
Preferences 状态持久化
```

### 5.3 Scope

**作用**：定义 Skill 的适用边界。

**必填子字段**：

- `domain`：所属领域
- `source_language`：源语言
- `target_language`：目标语言
- `platform`：目标平台
- `priority`：优先级
- `applies_to`：适用问题清单
- `not_applies_to`：不适用问题清单

**推荐领域值**：

- `language-runtime`
- `ui-component`
- `page-routing`
- `state-management`
- `local-storage`
- `network`
- `system-capability`
- `build-debug`
- `ai-interface`
- `translation-pattern`

### 5.4 Trigger Condition（触发条件）

**作用**：告诉 Agent 何时必须调用此 Skill。

这是最关键字段之一。一个 Skill 写得再好，如果 Agent 不知道何时触发，它就无法稳定发挥价值。

**必须回答的问题**：

- 当前任务里出现了什么关键词、组件、接口或错误现象；
- 哪些情况下应该优先调用该 Skill；
- 哪些情况下只作为次级参考；
- 哪些情况下不该调用该 Skill。

**推荐子字段**：

- `must_trigger_when`
- `should_trigger_when`
- `must_not_trigger_when`
- `related_keywords`
- `related_files`
- `common_error_signals`

**示例写法**：

```yaml
Trigger Condition:
  must_trigger_when:
    - 任务涉及 ArkUI 列表、网格、Tabs 或页面布局渲染
    - 源代码中出现 List、Grid、ForEach、Tabs、Navigator、router 等模式
    - 需要将页面路由或组件树从 ArkTS 转为仓颉实现
  should_trigger_when:
    - 需要理解页面间参数传递和导航结构
    - UI 已可生成，但布局行为与原始页面不一致
  must_not_trigger_when:
    - 任务只涉及纯算法转换
    - 任务只涉及底层 C 互操作且不涉及页面 UI
  related_keywords:
    - List
    - Grid
    - Tabs
    - ForEach
    - router
    - Navigator
  related_files:
    - pages/*.ets
    - components/*.ets
  common_error_signals:
    - 页面不渲染
    - 路由跳转失败
    - 列表项状态不同步
```

### 5.5 Core Concept（核心概念）

**作用**：用最简短、最低成本的方式告诉 Agent 当前问题的本质。

**要求**：

- 尽量短；
- 不展开长篇背景；
- 优先提供实现判断所必需的事实；
- 如果存在最重要的“不要这么做”规则，也应放在这里。

**推荐子字段**：

- `one_sentence_summary`
- `key_facts`
- `critical_constraints`
- `mental_model`

**示例写法**：

```yaml
Core Concept:
  one_sentence_summary: ArkUI 页面转换的核心不是逐组件逐字直译，而是保持组件树、状态绑定和路由行为的一致性。
  key_facts:
    - List 和 Grid 既是布局容器，也是状态更新的主要渲染节点
    - ForEach 的数据源与 key 选择会直接影响重渲染行为
    - 页面跳转通常与参数传递、生命周期和状态恢复耦合
  critical_constraints:
    - 不要只翻译组件名称而忽略状态绑定方式
    - 不要把路由逻辑拆散到无法追踪的位置
  mental_model: 先保持页面结构和数据流稳定，再逐步优化组件细节与样式。
```

### 5.6 Progressive Modules（渐进模块）

**作用**：按复杂度逐层展开 Skill 内容。

这是本 Schema 的核心设计字段。建议至少拆为四层：

#### Module 0：最小必读层

适用于首次触发。

**应包含**：

- 当前 Skill 的一句话用途；
- 最关键的 3~5 条规则；
- 最常见的失败模式；
- 立即可执行的第一步动作。

#### Module 1：基础语法映射层

适用于处理语言层面映射。

**应包含**：

- ArkTS 到仓颉的基础语法对应关系；
- 常见控制流、数据结构、函数调用差异；
- 常见不可直译点；
- 最小示例。

#### Module 2：UI / 组件 / 系统能力层

适用于页面与系统能力转换。

**应包含**：

- UI 组件转换规则；
- 路由与页面生命周期；
- 状态与数据绑定；
- 网络、存储、权限、日志等系统能力映射；
- 典型工程目录对应关系。

#### Module 3：AI 接口 / 复杂场景层

适用于更高阶场景。

**应包含**：

- AI 接口调用模式；
- 多模块协同；
- 异步流程与回调链；
- 复杂状态流；
- 真实工程中的降级策略；
- 已知大模型容易犯错的位置。

**推荐结构模板**：

```yaml
Progressive Modules:
  module_0_minimum:
    purpose: 先给 Agent 足以启动任务的最小信息
    content:
      - 最关键规则 1
      - 最关键规则 2
      - 最关键规则 3
    first_action:
      - 先识别当前文件属于页面、组件还是系统能力代码
      - 再定位状态源与交互入口

  module_1_basic_mapping:
    purpose: 处理基础语法与语义映射
    content:
      - ArkTS 构造方式与仓颉对应写法
      - 常见函数与数据结构映射
      - 不可直译点列表

  module_2_ui_system:
    purpose: 处理页面、组件、路由、网络、存储等中层能力
    content:
      - UI 布局规则
      - 路由跳转与参数传递
      - 状态绑定与持久化
      - 权限声明与系统接口调用

  module_3_advanced_ai:
    purpose: 处理 AI 接口、多模块和复杂场景
    content:
      - AI 接口调用流程
      - 多模块协作边界
      - 异步与错误恢复策略
      - 常见复杂错误模式
```

### 5.7 Translation Mapping

**作用**：把“知识”进一步收敛成“映射规则”。

**推荐子字段**：

- `syntax_mapping`
- `component_mapping`
- `state_mapping`
- `routing_mapping`
- `api_mapping`
- `fallback_mapping`
- `anti_patterns`

**要求**：

- 优先写稳定、高频、可验证的映射；
- 不要塞入未经验证的大量猜测；
- 对无法确认的映射，明确标注“需检索确认”或“需实验验证”。

### 5.8 Examples

**作用**：提供最小可复用示例。

**推荐子字段**：

- `positive_example`
- `negative_example`
- `edge_case_example`
- `source_snippet`
- `target_snippet`
- `why_this_mapping`

**要求**：

- 至少给一个正向示例；
- 如条件允许，再给一个反例或常见错误示例；
- 示例必须与当前 Skill 强相关。

### 5.9 Retrieval Fallback（检索降级指令）

**作用**：当当前 Skill 无法直接解决问题时，告诉 Agent 如何去官方原始文档、样例仓库或目标工程中继续查找。

这是 Schema 中第二个极关键字段。没有检索降级，Skill 很容易变成孤岛。

**必须包含的内容**：

1. 何时判定当前 Skill 信息不足；
2. 应优先检索哪类来源；
3. 检索关键词怎么构造；
4. 检索后如何记录来源与结论；
5. 在脚本尚未实现时的 CLI 兜底命令。

**推荐子字段**：

- `fallback_when`
- `priority_sources`
- `query_templates`
- `python_script_examples`
- `cli_examples`
- `result_recording_rule`

**推荐来源优先级**：

1. 仓颉官方文档
2. OpenHarmony 官方样例
3. TelegramHarmony 或目标工程内相似实现
4. 项目历史 Skill / 样本记录 / 轨迹

**Python 脚本调用示例**：

后续建议实现 `scripts/search_official_docs.py`。在脚本落地前，模板中先统一使用以下示例格式：

```bash
python scripts/search_official_docs.py \
  --source cangjie-docs \
  --query "ArkUI List Grid Tabs router 页面跳转 参数传递" \
  --top-k 5 \
  --save-to artifacts/retrieval/ui-routing-search.json
```

```bash
python scripts/search_official_docs.py \
  --source openharmony-samples \
  --query "Preferences theme persistence ArkTS sample" \
  --top-k 5 \
  --save-to artifacts/retrieval/preferences-search.json
```

```bash
python scripts/search_official_docs.py \
  --source project-repo \
  --query "SignalKit ServiceLocator ChatListPage" \
  --top-k 10 \
  --save-to artifacts/retrieval/telegram-structure-search.json
```

**CLI 兜底示例**：

在检索脚本未实现时，允许使用如下命令兜底：

```bash
rg -n "List|Grid|Tabs|router|Navigator" third_party/TelegramHarmony
```

```bash
rg -n "Preferences|getPreferences|flush" third_party/applications_app_samples
```

```bash
curl -L "https://docs.cangjie-lang.cn/cjnative/user_manual/searchindex.js" | rg "test|coverage|pgo"
```

**结果记录规则**：

每次检索后必须记录：

- 查询时间；
- 查询关键词；
- 查询目标源；
- 命中链接或文件；
- 选中该结果的原因；
- 采用后对当前 Skill 或翻译任务的影响。

**示例写法**：

```yaml
Retrieval Fallback:
  fallback_when:
    - 当前 Skill 没有覆盖目标组件或接口
    - 生成代码能编译但行为与 ArkTS 原始页面不一致
    - 遇到未知权限、生命周期或系统能力调用
  priority_sources:
    - cangjie-official-docs
    - openharmony-samples
    - target-repository
    - project-history
  query_templates:
    - "ArkUI List Grid Tabs router parameter passing"
    - "Preferences persistence theme state restore"
    - "hilog file logger ArkTS sample"
  python_script_examples:
    - "python scripts/search_official_docs.py --source cangjie-docs --query 'ArkUI List Grid Tabs router' --top-k 5 --save-to artifacts/retrieval/ui-routing-search.json"
    - "python scripts/search_official_docs.py --source openharmony-samples --query 'Preferences persistence sample' --top-k 5 --save-to artifacts/retrieval/preferences-search.json"
  cli_examples:
    - "rg -n 'List|Grid|Tabs|router' third_party/TelegramHarmony"
    - "rg -n 'Preferences|getPreferences|flush' third_party/applications_app_samples"
  result_recording_rule:
    - 记录查询词、来源、命中文件、采用原因和回写结论
```

### 5.10 Test & Debug（测试与排错）

**作用**：明确如何验证 Skill 的正确性，以及在失败时如何排查。

Skill 如果不能连接到验证与排错，它就无法长期提升。

**必须包含的内容**：

- 推荐的验证层级；
- 单测如何生成；
- 编译失败如何记录；
- 运行行为不一致如何定位；
- 何时回写 Skill；
- 哪类问题需要升级为新 Skill 或新样本。

**推荐验证层级**：

1. **静态检查**：字段完整、示例存在、来源可追溯；
2. **映射检查**：ArkTS → 仓颉映射是否自洽；
3. **编译验证**：目标代码是否至少能完成最小编译；
4. **单元测试验证**：关键状态、函数、路由、存储或接口行为是否可测；
5. **运行验证**：页面、交互、日志、网络、存储行为是否符合预期。

**推荐子字段**：

- `unit_test_strategy`
- `compile_check`
- `runtime_check`
- `common_failures`
- `debug_steps`
- `when_to_update_skill`

**单测生成策略要求**：

- 先测最核心行为，而不是追求全覆盖；
- UI 场景重点测：状态变更、列表数据绑定、路由参数；
- 持久化场景重点测：写入、读取、刷新、重启后恢复；
- 网络场景重点测：请求构造、参数解析、错误处理；
- 日志场景重点测：日志级别、输出目标、关键事件记录。

**示例写法**：

```yaml
Test & Debug:
  unit_test_strategy:
    - 为关键状态流、参数转换、数据映射生成最小单元测试
    - 优先验证输入与输出行为，不先验证样式细节
  compile_check:
    - 记录编译命令、编译结果、错误码、关键报错位置
  runtime_check:
    - 记录页面是否渲染、交互是否触发、日志是否输出、数据是否持久化
  common_failures:
    - 组件树存在但状态未刷新
    - 路由可跳转但参数丢失
    - 持久化写入成功但读取时类型不一致
  debug_steps:
    - 先确认当前 Skill 是否覆盖该场景
    - 再检查映射规则与示例是否冲突
    - 再执行检索降级补资料
    - 最后依据编译或运行反馈修正 Skill
  when_to_update_skill:
    - 当同类错误出现两次及以上时
    - 当新增了稳定的映射模式时
    - 当官方文档版本变化导致旧结论失效时
```

### 5.11 Sources

**作用**：保证 Skill 可追溯。

**要求**：

- 至少记录来源名称、链接、访问时间、适用版本；
- 若引用样例或目标工程代码，记录文件路径与 commit；
- 若引用实验记录，记录对应样本记录或轨迹文件路径。

**推荐子字段**：

- `official_docs`
- `sample_projects`
- `target_repositories`
- `internal_records`

### 5.12 Version Notes

**作用**：记录版本差异与适配范围。

**要求**：

- 说明本 Skill 对应的 API、SDK、工具链或文档版本；
- 若版本不确定，明确写“待确认”；
- 出现跨版本行为差异时单独记录。

### 5.13 Known Gaps

**作用**：明确当前 Skill 尚未覆盖的内容，避免误用。

**要求**：

- 写清楚没覆盖什么；
- 写清楚目前的临时绕行方法；
- 需要检索时明确指向 `Retrieval Fallback`。

### 5.14 Evolution Log

**作用**：记录 Skill 的演化历史。

**推荐格式**：

```text
[YYYY-MM-DD] [作者/Agent] [变更内容] [原因]
```

## 6. 标准 Skill 模板

以下是后续创建单个 Skill 时建议直接复制使用的完整模板：

```markdown
# <Skill Name>

## Skill ID
<skill-id>

## Scope
- domain:
- source_language:
- target_language:
- platform:
- priority:
- applies_to:
  -
- not_applies_to:
  -

## Trigger Condition
- must_trigger_when:
  -
- should_trigger_when:
  -
- must_not_trigger_when:
  -
- related_keywords:
  -
- related_files:
  -
- common_error_signals:
  -

## Core Concept
- one_sentence_summary:
- key_facts:
  -
- critical_constraints:
  -
- mental_model:

## Progressive Modules
### Module 0 - Minimum
- purpose:
- content:
  -
- first_action:
  -

### Module 1 - Basic Mapping
- purpose:
- content:
  -

### Module 2 - UI / System
- purpose:
- content:
  -

### Module 3 - Advanced / AI
- purpose:
- content:
  -

## Translation Mapping
- syntax_mapping:
  -
- component_mapping:
  -
- state_mapping:
  -
- routing_mapping:
  -
- api_mapping:
  -
- fallback_mapping:
  -
- anti_patterns:
  -

## Examples
### Positive Example
- source_snippet:
- target_snippet:
- why_this_mapping:

### Negative Example
- source_snippet:
- target_snippet:
- why_it_fails:

### Edge Case Example
- source_snippet:
- target_snippet:
- special_note:

## Retrieval Fallback
- fallback_when:
  -
- priority_sources:
  -
- query_templates:
  -
- python_script_examples:
  -
- cli_examples:
  -
- result_recording_rule:
  -

## Test & Debug
- unit_test_strategy:
  -
- compile_check:
  -
- runtime_check:
  -
- common_failures:
  -
- debug_steps:
  -
- when_to_update_skill:
  -

## Sources
- official_docs:
  - name:
    url:
    accessed_at:
    version:
- sample_projects:
  - name:
    path_or_url:
    accessed_at:
    version_or_commit:
- target_repositories:
  - name:
    path_or_url:
    accessed_at:
    version_or_commit:
- internal_records:
  - path:
    note:

## Version Notes
- sdk_version:
- api_version:
- toolchain_version:
- compatibility_note:

## Known Gaps
-

## Evolution Log
- [YYYY-MM-DD] [作者/Agent] [变更内容] [原因]
```

## 7. 评审清单

创建或更新 Skill 时，至少自检以下问题：

1. 是否写清了 `Trigger Condition`；
2. 是否能用一句话说清 `Core Concept`；
3. 是否真的采用了 `Progressive Modules`，而不是把所有内容平铺；
4. 是否提供了检索降级示例，而不是只写“去查官方文档”；
5. 是否说明了如何做单测、编译验证和运行验证；
6. 是否写清了来源与版本；
7. 是否标注了已知缺口；
8. 是否具备回写空间。

## 8. 当前执行建议

基于本 Schema，建议下一步优先创建以下类型 Skill：

1. `ui-list-grid-layout`
2. `page-routing-and-param-passing`
3. `state-preferences-persistence`
4. `network-http-request-and-permission`
5. `dfx-hilog-and-file-logger`
6. `arkts-to-cangjie-basic-syntax-mapping`

这六类 Skill 足以直接支撑第一批“小样本验证”启动。
