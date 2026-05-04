# ArkTS Router / Navigation 到仓颉的映射

## Skill ID
page-routing-and-param-passing

## Skill Name
页面路由与参数传递映射

## Scope
- domain: page-routing
- source_language: ArkTS
- target_language: Cangjie
- platform: HarmonyOS NEXT
- priority: P0
- applies_to:
  - `Navigator` 点击跳转
  - `router.pushUrl` / `getRouter().pushUrl`
  - `getParams` / 页面进入时读取参数
  - `back` 返回上一级页面
- not_applies_to:
  - 仅涉及页面布局、不涉及页面跳转的场景
  - 纯网络或数据处理逻辑
  - 复杂多级嵌套路由栈调度

## Trigger Condition
- must_trigger_when:
  - 源代码中出现 `Navigator`、`router.pushUrl`、`getRouter().getParams()`、`router.back()`
  - 需要保留“从列表 / 网格页进入详情页”的交互链路
  - 需要在仓颉中实现可测试的路由栈与参数读取逻辑
- should_trigger_when:
  - 页面跳转 API 在仓颉公开文档里暂不完整，需要先抽象适配层
  - 希望用单测验证跳转行为而不是依赖完整设备环境
- must_not_trigger_when:
  - 任务只涉及静态页面展示，不涉及跳转或返回
  - 任务只涉及同一页面内部组件状态，不涉及页面参数
- related_keywords:
  - Navigator
  - pushUrl
  - getParams
  - back
  - RouteParams
  - FoodDetail
- related_files:
  - `pages/FoodCategoryList.ets`
  - `pages/FoodDetail.ets`
  - `samples/ui-routing-defining-page-layout/FoodNavigator.cj`
  - `samples/ui-routing-defining-page-layout/FoodDetailPage.cj`
- common_error_signals:
  - 点击条目后没有进入详情页
  - 详情页能打开，但参数为空
  - 返回按钮触发后页面栈不回退
  - 路由逻辑直接绑定到具体 UI 框架 API，导致无法单测

## Core Concept
- one_sentence_summary: 路由转换的核心不是把 ArkTS 的 `router` 名称逐字搬到仓颉，而是保留“页面栈 + 参数对象 + 返回行为”三件事，并把框架不确定性封装进适配层。
- key_facts:
  - ArkTS 样本里真正关键的是：点击条目时压栈，并把 `foodId` 作为详情页输入
  - OpenHarmony 官方 router 文档明确 `pushUrl` 可携带 `params`，`getParams` 读取当前页参数，`back` 控制返回
  - 第一批样本最需要的不是完整框架路由器，而是可测试的最小等价行为
- critical_constraints:
  - 不要把页面跳转写死在每个 UI 组件内部
  - 不要把参数读取与 UI 构建混杂到不可单测的位置
  - 在仓颉公开路由 API 未完全确认时，优先采用本地 `PageRouter` 抽象层
- mental_model: 先把 ArkTS `pushUrl/getParams/back` 还原成“push(current -> detail, payload) / current() / back()”三个核心动作，再让页面类基于这个接口工作。

## Progressive Modules
### Module 0 - Minimum
- purpose: 让 Agent 在最少信息下就能稳定迁移页面跳转。
- content:
  - 将路由语义先抽象成 `RouteRequest + PageRouter`
  - 列表页只负责调用 `router.push(makeFoodDetailRoute(food))`
  - 详情页在 `aboutToAppear()` 中读取当前路由参数
  - 返回按钮只调用 `router.back()`
- first_action:
  - 先识别源页、目标页和参数对象是什么
  - 再决定是否需要本地适配层

### Module 1 - Basic Mapping
- purpose: 处理 `Navigator`、`pushUrl`、`getParams`、`back` 的基础对应。
- content:
  - `Navigator({ target: 'pages/FoodDetail' }).params({ foodId: this.foodItem })` -> `router.push(makeFoodDetailRoute(foodItem))`
  - `router.pushUrl({ url: 'pages/FoodDetail', params: { foodId: this.foodItem } })` -> 同上
  - `this.getUIContext().getRouter().getParams()` -> `router.current()`
  - `router.back()` -> `router.back()`

### Module 2 - UI / System
- purpose: 把路由动作融入页面生命周期与交互。
- content:
  - 列表项按钮和网格项按钮都只调用统一的 `openFoodDetail(foodItem)`
  - 详情页在 `aboutToAppear()` 执行参数装载，而不是在多个地方重复解析参数
  - 返回按钮绑定统一的 `tapBack()`

### Module 3 - Advanced / AI
- purpose: 处理后续工程级路由扩展。
- content:
  - 当迁移到 TelegramHarmony 这类多页面工程时，可把 `PageRouter` 升级为支持命名路由、多级栈和错误页跳转的适配层
  - 当公开仓颉文档补齐正式路由 API 后，可把 `PageRouter` 的实现切换到底层框架实例，不改变页面类签名
  - 如果参数变复杂，可把 `RouteRequest` 拆成更强类型的路由对象

## Translation Mapping
- syntax_mapping:
  - `router.pushUrl({ url: "pages/FoodDetail", params: { foodId: item.id } })` -> `router.push(makeFoodDetailRoute(foodItem))`
  - `getParams()['foodId']` -> `router.current().food`
  - `router.back()` -> `router.back()`
- component_mapping:
  - 列表项点击 -> `Button("查看详情").onClick { _ => openFoodDetail(foodItem) }`
  - 返回图标点击 -> `Button("返回").onClick { _ => tapBack() }`
- state_mapping:
  - 当前详情页绑定数据 -> `@State var foodItem`
  - 当前路由 -> `router.current()`
- routing_mapping:
  - 主页 -> `makeHomeRoute()`
  - 详情页 -> `makeFoodDetailRoute(food)`
- api_mapping:
  - ArkTS `getUIContext().getRouter().getParams()` -> 仓颉 `PageRouter.current()`
  - ArkTS `router.back()` -> 仓颉 `PageRouter.back()`
- fallback_mapping:
  - 若仓颉官方路由 API 仍未公开稳定，则继续使用本地适配层并把框架接入放在实现层
- anti_patterns:
  - 不要在多个页面里重复解析同一个参数结构
  - 不要把路由栈逻辑写成全局可变散点状态
  - 不要让 UI 组件直接依赖未确认的底层路由 API

## Examples
### Positive Example
- source_snippet:

```arkts
Navigator({ target: 'pages/FoodDetail' }) {
  Row() {
    Text(this.foodItem.name)
  }
}
.params({ foodId: this.foodItem })
```

```arkts
router.pushUrl({ url: 'pages/FoodDetail', params: { foodId: this.foodItem } });
```

```arkts
this.foodItem = (this.getUIContext().getRouter().getParams() as RouteParamsType).foodId;
```

- target_snippet:

```cangjie
import std.collection.*

class FoodData {
    let id: String
    let name: String

    public init(id: String, name: String) {
        this.id = id
        this.name = name
    }
}

func emptyFoodData(): FoodData {
    FoodData(id: "-1", name: "Unknown")
}

class RouteRequest {
    let pageName: String
    let hasFood: Bool
    let food: FoodData

    public init(pageName: String, hasFood: Bool, food: FoodData) {
        this.pageName = pageName
        this.hasFood = hasFood
        this.food = food
    }
}

func makeHomeRoute(): RouteRequest {
    RouteRequest(pageName: "FoodCategoryListPage", hasFood: false, food: emptyFoodData())
}

func makeFoodDetailRoute(food: FoodData): RouteRequest {
    RouteRequest(pageName: "FoodDetailPage", hasFood: true, food: food)
}

interface PageRouter {
    func push(request: RouteRequest): Unit
    func back(): Unit
    func current(): RouteRequest
}

class MemoryPageRouter <: PageRouter {
    private let history = ArrayList<RouteRequest>()
    private var currentIndex: Int64 = 0

    public init() {
        history.append(makeHomeRoute())
    }

    public func push(request: RouteRequest): Unit {
        history.append(request)
        currentIndex = history.size - 1
    }

    public func back(): Unit {
        if (currentIndex > 0) {
            currentIndex = currentIndex - 1
        }
    }

    public func current(): RouteRequest {
        history[currentIndex]
    }
}

class FoodCategoryListPage {
    private let router: PageRouter

    public init(router: PageRouter) {
        this.router = router
    }

    public func openFoodDetail(foodItem: FoodData): Unit {
        router.push(makeFoodDetailRoute(foodItem))
    }
}

class FoodDetailPage {
    private let router: PageRouter
    @State var foodItem: FoodData = emptyFoodData()

    public init(router: PageRouter) {
        this.router = router
    }

    public func aboutToAppear(): Unit {
        let currentRoute = router.current()
        if (currentRoute.hasFood) {
            foodItem = currentRoute.food
        }
    }

    public func tapBack(): Unit {
        router.back()
    }

    public func build(): Unit {
        Column {
            Row {
                Button("返回")
                    .onClick { _ =>
                        tapBack()
                    }
                Text(foodItem.name)
            }
        }
        .width(100.percent)
        .height(100.percent)
    }
}
```

- why_this_mapping: 这段代码完整保留了 ArkTS 中“压栈进入详情页、详情页读取参数、点击返回退栈”的核心语义，并把不确定的底层框架 API 封装在 `PageRouter` 里。

### Negative Example
- source_snippet:

```arkts
router.pushUrl({ url: 'pages/FoodDetail', params: { foodId: this.foodItem } });
```

- target_snippet:

```cangjie
router.pushUrl("pages/FoodDetail", this.foodItem)
```

- why_it_fails: 当前公开仓颉一手资料没有给出正式 `pushUrl` 签名。直接造出看似同名的方法会把不确定性隐藏起来，后续既难替换，也难单测。

### Edge Case Example
- source_snippet:

```arkts
this.getUIContext().getRouter().back(1, { info: '来自Home页' });
```

- target_snippet:

```cangjie
class RouteRequest {
    let pageName: String
    let hasFood: Bool
    let food: FoodData
    let returnMessage: String

    public init(pageName: String, hasFood: Bool, food: FoodData, returnMessage: String) {
        this.pageName = pageName
        this.hasFood = hasFood
        this.food = food
        this.returnMessage = returnMessage
    }
}
```

- special_note: 当源路由包含回传数据时，应把回传对象也纳入 `RouteRequest` 或专门的返回载荷模型，而不是继续沿用只装 `food` 的最小结构。

## Retrieval Fallback
- fallback_when:
  - 需要确认 ArkTS router 的官方参数语义
  - 需要把本地 `PageRouter` 适配到底层 HarmonyOS 正式 API
  - 需要处理命名路由、回传参数或多级返回
- priority_sources:
  - OpenHarmony 官方 router API 文档
  - ArkTS 原样本的 `FoodCategoryList.ets` 与 `FoodDetail.ets`
  - 项目内 `FoodNavigator.cj` 与 `FoodDetailPage.cj`
- query_templates:
  - `router pushUrl getParams back params`
  - `FoodDetail getParams foodId`
  - `HarmonyOS router params serializable`
- python_script_examples:
  - `python scripts/search_official_docs.py --source openharmony-docs --query "router pushUrl getParams back params" --top-k 5 --save-to artifacts/retrieval/page-routing-official.json`
  - `python scripts/search_official_docs.py --source project-repo --query "PageRouter RouteRequest FoodDetailPage" --top-k 10 --save-to artifacts/retrieval/page-routing-local.json`
- cli_examples:
  - `curl -L https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/reference/apis-arkui/js-apis-router.md | rg -n "pushUrl|getParams|back\("`
  - `curl -L https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/UI/ArkTsComponentCollection/DefiningPageLayoutAndConnection/entry/src/main/ets/pages/FoodDetail.ets | rg -n "getParams|back|foodId"`
  - `rg -n "PageRouter|RouteRequest|openFoodDetail|aboutToAppear|tapBack" samples/ui-routing-defining-page-layout`
- result_recording_rule:
  - 记录命中的官方 router 语义、当前适配层如何覆盖它、哪些地方仍待正式 API 落地后替换

## Test & Debug
- unit_test_strategy:
  - Mock / Spy 一个 `PageRouter`
  - 断言点击条目后 `lastPushedPage()` 是否为 `FoodDetailPage`
  - 断言 `router.current().food` 是否为被点击的条目
  - 断言 `FoodDetailPage.aboutToAppear()` 是否正确读取参数
  - 断言 `tapBack()` 后当前页是否回到主页
- compile_check:
  - 当前环境若无法运行 DevEco + 仓颉插件，先审查接口和测试设计，不声称设备侧已验证
- runtime_check:
  - 后续在可运行环境中验证：点击 Tomato -> 详情页显示 Tomato -> 点击返回 -> 返回主页
- common_failures:
  - 详情页构造了，但未在 `aboutToAppear()` 中读取当前路由
  - 路由压栈了，但压入的载荷对象不完整
  - 返回按钮修改了 UI 状态，却没有真正回退路由栈
- debug_steps:
  - 先检查 `openFoodDetail` 是否唯一负责入栈
  - 再检查 `RouteRequest` 是否完整承载详情页所需字段
  - 再检查 `aboutToAppear()` 是否唯一负责参数装载
  - 最后检查 `tapBack()` 是否只通过路由接口回退
- when_to_update_skill:
  - 当确认仓颉正式路由 API 后
  - 当出现新的回传参数模式或多级路由需求后
  - 当 TelegramHarmony 需要更复杂路由时

## Sources
- official_docs:
  - name: OpenHarmony router API 文档
    url: https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/reference/apis-arkui/js-apis-router.md
    accessed_at: 2026-03-26
    version: docs master
  - name: 仓颉声明式 UI 白皮书
    url: https://docs.cangjie-lang.cn/docs/0.53.18/white_paper/source_zh_cn/cj-wp-declarative.html
    accessed_at: 2026-03-26
    version: 0.53.18
- sample_projects:
  - name: FoodCategoryList ArkTS
    path_or_url: https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/UI/ArkTsComponentCollection/DefiningPageLayoutAndConnection/entry/src/main/ets/pages/FoodCategoryList.ets
    accessed_at: 2026-03-26
    version_or_commit: master
  - name: FoodDetail ArkTS
    path_or_url: https://raw.githubusercontent.com/openharmony/applications_app_samples/master/code/UI/ArkTsComponentCollection/DefiningPageLayoutAndConnection/entry/src/main/ets/pages/FoodDetail.ets
    accessed_at: 2026-03-26
    version_or_commit: master
- target_repositories:
  - name: 本地路由适配层
    path_or_url: samples/ui-routing-defining-page-layout/FoodNavigator.cj
    accessed_at: 2026-03-26
    version_or_commit: workspace-current
- internal_records:
  - path: docs/samples/ui-routing-DefiningPageLayout.md
    note: 首个 UI / 路由样本的路由翻译分析
  - path: docs/traces/trace-ui-routing-001.md
    note: 路由 Skill 首次执行轨迹

## Version Notes
- sdk_version: 待确认
- api_version: ArkTS 原样本 README 标注为 API 14 SDK；OpenHarmony router 文档中 `pushUrl` / `getParams` / `back` 语义可确认
- toolchain_version: 仓颉文档版本 0.53.18；当前本地环境未安装可验证的 DevEco 仓颉插件
- compatibility_note: 当前 Skill 用本地 `PageRouter` 适配层承接框架不确定性，后续可替换为正式仓颉路由实现

## Known Gaps
- 当前公开仓颉官方资料未直接给出完整页面路由示例，因此本 Skill 采用适配层而不是直接硬编码底层 API 名称。
- 当前路由载荷只覆盖详情页携带 `FoodData` 的最小场景，尚未覆盖命名路由、回传对象和多级栈控制。

## Evolution Log
- [2026-03-26] [Codex] 创建首版页面路由与参数传递 Skill，使用 `PageRouter` 适配层将 ArkTS 的 `pushUrl/getParams/back` 语义迁移到仓颉可测试结构中。[原因：先保证跳转语义与单测能力成立]
