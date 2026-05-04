# ArkUI List / Grid 布局到仓颉的映射

## Skill ID
ui-list-grid-layout

## Skill Name
ArkUI 列表与网格布局映射

## Scope
- domain: ui-component
- source_language: ArkTS
- target_language: Cangjie
- platform: HarmonyOS NEXT
- priority: P0
- applies_to:
  - 列表模式与网格模式切换
  - 双列卡片布局
  - 分类过滤后重新渲染当前数据集
  - 条目点击后触发详情行为
- not_applies_to:
  - 纯算法或纯数据结构转换
  - 只涉及底层网络协议、无 UI 布局的场景
  - 需要像素级还原动画细节的场景

## Trigger Condition
- must_trigger_when:
  - 源代码中出现 `List`、`Grid`、`LazyForEach`、`TabContent`、`ForEach`
  - 页面需要在“列表视图”和“网格视图”之间切换
  - 一个数据集要以不同布局模式重渲染
  - 任务要求从 ArkTS 页面布局转换为仓颉页面布局
- should_trigger_when:
  - 页面中存在分类筛选后再渲染的逻辑
  - 需要把 `Tabs` 的行为转换为更可测试的状态机
  - 需要在仓颉中先做功能等价实现，而不是逐组件逐字直译
- must_not_trigger_when:
  - 任务只涉及路由返回栈和参数传递，不涉及列表或网格渲染
  - 任务只涉及日志、网络、持久化等非 UI 场景
- related_keywords:
  - List
  - Grid
  - LazyForEach
  - Tabs
  - TabContent
  - category
  - filter
  - showList
- related_files:
  - `pages/FoodCategoryList.ets`
  - `components/*.ets`
  - `samples/ui-routing-defining-page-layout/FoodCategoryListPage.cj`
- common_error_signals:
  - 数据过滤正确但页面未刷新
  - 网格项数量正确但行列布局错误
  - 切换列表 / 网格模式后视图未更新
  - 分类切换后仍显示旧数据

## Core Concept
- one_sentence_summary: 列表 / 网格转换的核心不是照搬 ArkTS 组件名，而是保留“同一数据集在不同布局容器下的渲染语义”和“状态切换后的可测试行为”。
- key_facts:
  - ArkTS 中 `LazyForEach` 的本质是对数据集逐项渲染，不一定必须逐字映射为同名仓颉组件
  - `Tabs` 的核心语义是“当前选中分类状态 + 数据过滤 + 视图切换”，可以先降级为按钮栏状态机
  - 双列网格可先通过“按两项切分为一行”的方式稳定实现，再考虑升级到框架级 `Grid`
- critical_constraints:
  - 第一阶段不要因为公开文档未确认完整 `Tabs` API 就停止翻译
  - 优先保留可测试状态，如 `showList` 与 `selectedCategoryLabel`
  - 对图片展示等非核心行为可以先保守降级，只要不影响布局与跳转验证
- mental_model: 先抽出状态与数据，再把列表、网格和分类栏分别映射为仓颉中的可组合布局函数。

## Progressive Modules
### Module 0 - Minimum
- purpose: 给 Agent 最小必要知识，能开始翻译列表 / 网格页面。
- content:
  - 把 `showList` 转成仓颉 `@State` 变量。
  - 把 `Tabs` 先视为“分类状态 + 按钮栏 + 当前数据集过滤”。
  - 把 `LazyForEach` 先视为 `for (item in items)` 的声明式渲染循环。
  - 把双列 `Grid` 先视为 `buildGridRows(items)` 之后逐行渲染。
- first_action:
  - 先定位状态变量、数据源与点击入口。
  - 再决定哪些 UI 行为必须保留，哪些外观细节可暂时降级。

### Module 1 - Basic Mapping
- purpose: 处理基础语法与状态映射。
- content:
  - `@State showList: boolean` 映射为 `@State var showList: Bool = false`
  - `this.showList = !this.showList` 映射为 `showList = !showList`
  - `foodItems.filter(item => item.category == category)` 优先映射为显式 `for` 循环过滤函数，降低语法不确定性
  - `LazyForEach(data, itemBuilder)` 映射为 `for (item in data) { buildFoodListItem(item) }`

### Module 2 - UI / System
- purpose: 处理列表、网格、分类栏与点击行为。
- content:
  - 列表视图：`Column + for(item in items)` 即可先实现功能等价
  - 网格视图：先将数据拆成二维行结构，再逐行渲染两个卡片
  - 分类栏：先用 `Button` 组代替 `Tabs`，通过 `selectedCategoryLabel` 驱动当前数据集
  - 点击行为：列表项或网格项点击后调用由路由 Skill 提供的 `openFoodDetail`

### Module 3 - Advanced / AI
- purpose: 处理升级空间与复杂场景。
- content:
  - 如果后续公开仓颉文档确认了稳定的 `Tabs` / `Grid` 组件 API，可从按钮栏和双列行布局升级到原生组件
  - 如果页面含复杂筛选、排序、分页、异步加载，需拆出 ViewModel 或派生状态函数
  - 如果后续加入 AI 接口推荐分类，可将分类状态从静态字符串升级为领域模型

## Translation Mapping
- syntax_mapping:
  - `@State private showList: boolean = false` -> `@State var showList: Bool = false`
  - `foodItems.filter(item => condition)` -> `visibleFoods(label)` 中的显式条件分支与 `filterFoodsByCategory`
  - `LazyForEach(data, builder)` -> `for (item in data) { buildFoodGridItem(item) }`
- component_mapping:
  - `List + ListItem` -> `Column + buildFoodListItem`
  - `Grid + GridItem` -> `buildGridRows(items)` + `buildGridRow`
  - `Tabs + TabContent` -> `selectedCategoryLabel` + `buildCategoryBar`
- state_mapping:
  - 布局模式 -> `showList`
  - 当前分类 -> `selectedCategoryLabel`
  - 当前可见数据 -> `visibleFoodsForCurrentCategory()`
- routing_mapping:
  - 点击列表项 / 网格项 -> 调用 `openFoodDetail(foodItem)`
- api_mapping:
  - ArkTS `onClick` -> 仓颉 `.onClick { _ => openFoodDetail(foodItem) }`
  - ArkTS `filter` -> 仓颉手工过滤函数
- fallback_mapping:
  - 未确认的框架级 `Tabs` / `Grid` API -> 先使用按钮栏与双列行布局保证功能等价
- anti_patterns:
  - 不要直接照抄 `LazyForEach`、`TabContent` 名称而不验证仓颉侧是否有公开稳定 API
  - 不要把分类逻辑写死在多个分散位置，应统一收敛到 `visibleFoods(label)`
  - 不要把路由调用写进布局函数深处而无法单测

## Examples
### Positive Example
- source_snippet:

```arkts
Tabs() {
  TabContent() {
    FoodGrid({ foodItems: this.foodItems })
  }.tabBar('All')

  TabContent() {
    FoodGrid({ foodItems: this.foodItems.filter(item => (item.category === Category.Vegetable)) })
  }.tabBar('Vegetable')
}
```

- target_snippet:

```cangjie
import std.collection.*

enum Category {
    | Fruit
    | Vegetable
    | Nut
    | Seafood
    | Dessert
}

class FoodData {
    let id: String
    let name: String
    let imageRef: String
    let category: Category
    let calories: Int64

    public init(id: String, name: String, imageRef: String, category: Category, calories: Int64) {
        this.id = id
        this.name = name
        this.imageRef = imageRef
        this.category = category
        this.calories = calories
    }
}

func filterFoodsByCategory(items: ArrayList<FoodData>, category: Category): ArrayList<FoodData> {
    let selected = ArrayList<FoodData>()
    for (item in items) {
        if (item.category == category) {
            selected.append(item)
        }
    }
    selected
}

func buildGridRows(items: ArrayList<FoodData>): ArrayList<ArrayList<FoodData>> {
    let rows = ArrayList<ArrayList<FoodData>>()
    var index: Int64 = 0
    while (index < items.size) {
        let row = ArrayList<FoodData>()
        row.append(items[index])
        if (index + 1 < items.size) {
            row.append(items[index + 1])
        }
        rows.append(row)
        index = index + 2
    }
    rows
}

class FoodCategoryLayoutDemo {
    private let foodItems: ArrayList<FoodData>
    @State var selectedCategoryLabel: String = "All"

    public init(foodItems: ArrayList<FoodData>) {
        this.foodItems = foodItems
    }

    public func selectCategory(label: String): Unit {
        selectedCategoryLabel = label
    }

    public func visibleFoodsForCurrentCategory(): ArrayList<FoodData> {
        if (selectedCategoryLabel == "All") {
            foodItems
        } else if (selectedCategoryLabel == "Vegetable") {
            filterFoodsByCategory(foodItems, Category.Vegetable)
        } else if (selectedCategoryLabel == "Fruit") {
            filterFoodsByCategory(foodItems, Category.Fruit)
        } else if (selectedCategoryLabel == "Nut") {
            filterFoodsByCategory(foodItems, Category.Nut)
        } else if (selectedCategoryLabel == "Seafood") {
            filterFoodsByCategory(foodItems, Category.Seafood)
        } else {
            filterFoodsByCategory(foodItems, Category.Dessert)
        }
    }

    private func buildCategoryButton(label: String): Unit {
        Button(label)
            .margin(right: 8.vp)
            .onClick { _ =>
                selectCategory(label)
            }
    }

    private func buildCategoryBar(): Unit {
        Scroll {
            Row {
                buildCategoryButton("All")
                buildCategoryButton("Vegetable")
                buildCategoryButton("Fruit")
                buildCategoryButton("Nut")
                buildCategoryButton("Seafood")
                buildCategoryButton("Dessert")
            }
        }
    }

    private func buildGridItem(food: FoodData): Unit {
        Column {
            Text(food.name)
                .margin(bottom: 4.vp)
            Text("${food.calories}kcal")
        }
        .width(48.percent)
        .padding(top: 8.vp, bottom: 8.vp, left: 8.vp, right: 8.vp)
    }

    private func buildGrid(): Unit {
        Column {
            buildCategoryBar()
            for (rowItems in buildGridRows(visibleFoodsForCurrentCategory())) {
                Row {
                    if (rowItems.size > 0) {
                        buildGridItem(rowItems[0])
                    }
                    if (rowItems.size > 1) {
                        buildGridItem(rowItems[1])
                    } else {
                        Column { Text("") }.width(48.percent)
                    }
                }
                .width(100.percent)
                .padding(left: 16.vp, right: 16.vp, bottom: 8.vp)
            }
        }
    }

    public func build(): Unit {
        Column {
            buildGrid()
        }
        .width(100.percent)
        .height(100.percent)
    }
}
```

- why_this_mapping: 这段映射把 ArkTS `Tabs + filter + Grid` 组合重构为“分类状态 + 按钮栏 + 双列行布局”，在不依赖未确认仓颉 `Tabs` API 的情况下完整保留了页面行为。

### Negative Example
- source_snippet:

```arkts
this.foodItems.filter(item => (item.category === Category.Vegetable))
```

- target_snippet:

```cangjie
let vegetables = foodItems.filter { item => item.category == Category.Vegetable }
```

- why_it_fails: 当前公开一手资料里并未明确给出仓颉 `ArrayList` 的 `filter` API 细节。第一批样本中直接写高阶过滤，容易把问题从“布局映射”转移成“集合 API 不确定性”。因此更稳的方式是用显式循环写 `filterFoodsByCategory`。

### Edge Case Example
- source_snippet:

```arkts
Grid() {
  LazyForEach(new MyDataSource(this.foodItems), (item: FoodData, index) => {
    GridItem() {
      FoodGridItem({ foodItem: item })
    }
  }, (item: FoodData) => item.id.toString())
}
```

- target_snippet:

```cangjie
func buildGridRows(items: ArrayList<FoodData>): ArrayList<ArrayList<FoodData>> {
    let rows = ArrayList<ArrayList<FoodData>>()
    var index: Int64 = 0
    while (index < items.size) {
        let row = ArrayList<FoodData>()
        row.append(items[index])
        if (index + 1 < items.size) {
            row.append(items[index + 1])
        }
        rows.append(row)
        index = index + 2
    }
    rows
}
```

- special_note: 这是一种语义降级但行为稳定的方案，适合第一批样本。在公开仓颉组件文档进一步完备后，可将其替换为框架原生 `Grid`。

## Retrieval Fallback
- fallback_when:
  - 公开仓颉资料无法确认 `Grid`、`Tabs`、`LazyForEach` 的一一对应写法
  - 当前页面需要更高保真地还原 ArkTS 组件级 API
  - 分类切换和布局切换都正确，但实际渲染层还需升级到更贴近 HarmonyOS 组件的写法
- priority_sources:
  - 仓颉官方声明式 UI 白皮书
  - OpenHarmony `DefiningPageLayoutAndConnection` 样例原始代码
  - 项目内 `samples/ui-routing-defining-page-layout/` 样本翻译代码
- query_templates:
  - `声明式 UI Column Row Button State 布局`
  - `DefiningPageLayoutAndConnection List Grid Tabs ArkTS`
  - `仓颉 HarmonyOS UI 组件布局 状态绑定`
- python_script_examples:
  - `python scripts/search_official_docs.py --source cangjie-docs --query "声明式 UI Column Row Button State 布局" --top-k 5 --save-to artifacts/retrieval/ui-list-grid-layout-docs.json`
  - `python scripts/search_official_docs.py --source openharmony-samples --query "DefiningPageLayoutAndConnection List Grid Tabs" --top-k 5 --save-to artifacts/retrieval/ui-list-grid-layout-sample.json`
- cli_examples:
  - `curl -L https://docs.cangjie-lang.cn/docs/0.53.18/white_paper/source_zh_cn/cj-wp-declarative.html | rg -n "Column|Button|State|UI 组件布局|状态绑定"`
  - `curl -L https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/UI/ArkTsComponentCollection/DefiningPageLayoutAndConnection/entry/src/main/ets/pages/FoodCategoryList.ets | rg -n "List|Grid|Tabs|LazyForEach|showList|onClick"`
  - `rg -n "selectedCategoryLabel|buildGridRows|toggleView|visibleFoods" samples/ui-routing-defining-page-layout`
- result_recording_rule:
  - 记录查询词、命中来源、采用理由以及是否导致 Skill 规则被更新

## Test & Debug
- unit_test_strategy:
  - 测 `showList` 视图模式切换
  - 测 `selectedCategoryLabel` 的分类切换
  - 测 `visibleFoodsForCurrentCategory()` 的过滤结果
  - 测 `gridRowCount()` 是否符合双列网格预期
- compile_check:
  - 当前环境若没有 DevEco + 仓颉插件，可先做代码级审查与单测设计，不强行声称可编译
- runtime_check:
  - 后续在 DevEco 环境中验证：默认进入网格模式、点击切换进入列表模式、切换分类后数据更新
- common_failures:
  - 分类状态变了，但当前可见数据没有重新计算
  - 双列切分逻辑把最后一项丢失
  - 布局切换逻辑与分类状态混在一起，导致问题难以定位
- debug_steps:
  - 先检查 `showList` 与 `selectedCategoryLabel` 是否是唯一状态源
  - 再检查 `visibleFoods` 是否是唯一过滤入口
  - 再检查 `buildGridRows` 是否正确处理奇数与偶数项
  - 最后检查条目点击是否误把布局逻辑和路由逻辑耦合
- when_to_update_skill:
  - 当确认了更稳定的仓颉 `Grid` / `Tabs` API 时
  - 当新的样本证明按钮栏方案不足以覆盖更复杂分类场景时
  - 当双列布局需要升级到更高保真组件时

## Sources
- official_docs:
  - name: 仓颉声明式 UI 白皮书
    url: https://docs.cangjie-lang.cn/docs/0.53.18/white_paper/source_zh_cn/cj-wp-declarative.html
    accessed_at: 2026-03-26
    version: 0.53.18
- sample_projects:
  - name: DefiningPageLayoutAndConnection
    path_or_url: https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/UI/ArkTsComponentCollection/DefiningPageLayoutAndConnection/entry/src/main/ets/pages/FoodCategoryList.ets
    accessed_at: 2026-03-26
    version_or_commit: master
- target_repositories:
  - name: 本地样本翻译代码
    path_or_url: samples/ui-routing-defining-page-layout/FoodCategoryListPage.cj
    accessed_at: 2026-03-26
    version_or_commit: workspace-current
- internal_records:
  - path: docs/samples/ui-routing-DefiningPageLayout.md
    note: 本 Skill 在首个 UI / 路由样本中的实际应用记录
  - path: docs/traces/trace-ui-routing-001.md
    note: 本 Skill 的首次执行轨迹

## Version Notes
- sdk_version: 待确认
- api_version: ArkTS 原样本 README 标注为 API 14 SDK
- toolchain_version: 仓颉文档版本 0.53.18，当前本地环境未安装可验证的 DevEco 仓颉插件
- compatibility_note: 本 Skill 当前优先保证功能语义和测试可行性，不声称已对齐所有视觉组件 API 细节

## Known Gaps
- 当前公开一手资料未直接给出仓颉 `Tabs` 的完整示例，因此本 Skill 采用按钮栏状态机作为保守等价实现。
- 当前公开一手资料未直接给出仓颉 `Grid` 的完整示例，因此本 Skill 采用双列行切分作为稳定实现。
- 图片资源渲染在第一批样本中被降级为文本资源标识展示，待后续资源组件映射补齐。

## Evolution Log
- [2026-03-26] [Codex] 创建首版 List / Grid 布局 Skill，并基于 DefiningPageLayoutAndConnection 样本验证按钮栏 + 双列行布局的保守映射策略。[原因：先保证仓颉侧状态、布局和可测试行为成立]
