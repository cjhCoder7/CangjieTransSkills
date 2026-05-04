# UI / 路由样本工程说明

本目录同时包含两层内容：

1. **样本翻译与分析层**：位于根目录，用于保留 ArkTS -> 仓颉 的首轮翻译代码、路由抽象和单测草案。
2. **工程装配层**：位于 `entry/src/main/cangjie/`，用于贴近标准 OpenHarmony / HarmonyOS 仓颉工程结构，方便后续直接导入 DevEco Studio。

## 项目结构说明

```text
samples/ui-routing-defining-page-layout
├── AppScope
│   └── app.json5
├── build-profile.json5
├── entry
│   ├── cjpm.toml
│   └── src
│       └── main
│           ├── cangjie
│           │   ├── entryability
│           │   │   └── EntryAbility.cj
│           │   ├── model
│           │   │   └── FoodModels.cj
│           │   └── pages
│           │       ├── FoodCategoryListPage.cj
│           │       └── FoodDetailPage.cj
│           ├── module.json5
│           └── resources
│               └── base
│                   ├── element
│                   │   └── string.json
│                   ├── media
│                   │   └── icon.png
│                   └── profile
│                       └── main_pages.json
├── FoodCategoryListPage.cj
├── FoodDetailPage.cj
├── FoodModels.cj
├── FoodNavigator.cj
├── oh-package.json5
├── README.md
└── UiRoutingTests.cj
```

### 仓颉源码与资源文件对应关系

- `AppScope/app.json5`
  - 应用级元信息，声明应用名、包名、图标和描述。
- `build-profile.json5`
  - 工程级构建配置，声明 product、SDK 版本和模块挂载关系。
- `oh-package.json5`
  - 工程级依赖配置，供 IDE 和 OHPM / Hvigor 同步依赖信息。
- `entry/src/main/module.json5`
  - 模块级配置，声明 `EntryAbility`、页面注册入口和设备类型。
- `entry/src/main/resources/base/profile/main_pages.json`
  - 页面注册表，列出当前模块中可通过 Router 访问的页面文件。
- `entry/src/main/cangjie/entryability/EntryAbility.cj`
  - 应用启动入口，在 `onWindowStageCreate()` 中加载首页 `FoodCategoryListPage`。
- `entry/src/main/cangjie/model/FoodModels.cj`
  - 页面共享的数据模型、分类过滤逻辑、网格拆行逻辑和详情查找函数。
- `entry/src/main/cangjie/pages/FoodCategoryListPage.cj`
  - 首页页面，负责列表 / 网格切换、分类过滤和 Router 跳转。
- `entry/src/main/cangjie/pages/FoodDetailPage.cj`
  - 详情页，负责读取 Router 参数并展示食物详情。
- `entry/src/main/resources/base/element/string.json`
  - 字符串资源，承接 `app.json5` / `module.json5` 中的 `$string:*` 引用。
- `entry/src/main/resources/base/media/icon.png`
  - 最小图标资源，承接 `$media:icon` 引用。
- 根目录下的 `FoodModels.cj`、`FoodCategoryListPage.cj`、`FoodDetailPage.cj`、`FoodNavigator.cj`、`UiRoutingTests.cj`
  - 这是首轮样本翻译与分析层代码，主要用于保留推导过程、单测草案和保守映射策略，不直接作为标准工程入口文件。

## IDE 导入指南

### 前置条件

1. 已安装 **DevEco Studio**。
2. 已安装 **仓颉插件**。
3. 本机已安装可用的 HarmonyOS / OpenHarmony SDK。
4. 若需要真机运行，已准备签名账号或本地签名材料。

### 通过 File -> Open 导入项目

1. 启动 DevEco Studio。
2. 在欢迎页或菜单栏中选择 `File -> Open`。
3. 选择目录 `samples/ui-routing-defining-page-layout/` 作为工程根目录。
4. 点击 `Open`。
5. 如果 IDE 弹出“是否信任当前工程”或类似安全提示，点击 `Trust Project` 或等价确认按钮。
6. 等待 IDE 识别 `AppScope/app.json5`、`build-profile.json5`、`oh-package.json5`、`entry/src/main/module.json5` 和 `entry/cjpm.toml`。

### 首次导入后的预期现象

首次导入后，IDE 可能会做以下自动动作：

1. 检查 `oh-package.json5` 的 `modelVersion` 是否需要升级。
2. 根据本地 SDK 版本，提示修正 `build-profile.json5` 中的 `compileSdkVersion`、`compatibleSdkVersion`、`targetSdkVersion`。
3. 生成或更新 `oh-package-lock.json5`。
4. 生成或更新 `.hvigor/`、`hvigor/`、`local.properties` 等本地构建辅助文件。
5. 提示补齐签名配置。

这些动作都属于正常的 IDE 自动适配过程。

### 如果遇到 Hvigor 同步失败，如何用 IDE 提示自动修复

#### 场景一：IDE 顶部或编辑器中出现 `Sync Now`

1. 直接点击 `Sync Now`。
2. 等待 IDE 重新解析 `build-profile.json5`、`oh-package.json5` 和模块配置。
3. 若同步完成后还有新的 `Update` 提示，继续点击 `Update`。

#### 场景二：IDE 提示 `Update`、`Use IDE Recommended Version` 或类似升级建议

1. 优先点击 `Update` 或 `Use IDE Recommended Version`。
2. 让 IDE 自动把本地可用的 SDK / 构建版本写回工程临时配置或提示你更新对应字段。
3. 更新完成后再次执行同步。

#### 场景三：提示 `oh-package-lock.json5` 缺失或依赖未安装

1. 点击 IDE 的 `Sync`、`Install` 或等价的依赖安装按钮。
2. 等待 IDE 基于 `oh-package.json5` 重新生成依赖锁文件。
3. 安装完成后再次触发工程同步。

#### 场景四：提示签名配置缺失

1. 进入 `File -> Project Structure -> Project -> Signing Configs`。
2. 勾选 `Automatically generate signature`，如果目标是 OpenHarmony 设备，则按本地环境选择相应签名方式。
3. 登录或配置证书后点击 `OK`。
4. 回到工程界面重新点击 `Sync Now` 或重新运行。

#### 场景五：提示 SDK 版本不匹配

1. 打开 `build-profile.json5`。
2. 如果 IDE 在编辑器顶部给出 `Update` 或 `Sync Now` 提示，优先直接点击提示按钮。
3. 若 IDE 明确指出本地只安装了某个版本，例如 API 12、API 18、API 22，则以本地可用 SDK 为准修改：
   - `default` 产品位：通常由 HarmonyOS NEXT SDK 驱动；
   - `ohos` 产品位：通常由 OpenHarmony SDK 驱动。
4. 修改后再次同步。

### 导入后建议的核对顺序

1. 先确认 `AppScope/app.json5` 和 `entry/src/main/module.json5` 被 IDE 正常识别。
2. 再确认 `entry/src/main/resources/base/profile/main_pages.json` 中的两个页面已被注册。
3. 再检查 `entry/src/main/cangjie/entryability/EntryAbility.cj` 是否能在 IDE 中被正确识别为仓颉源码。
4. 最后检查 `FoodCategoryListPage.cj` 与 `FoodDetailPage.cj` 是否可以跳转解析。

## 当前工程状态说明

- 当前工程已经具备应用级配置、模块级配置、页面入口、页面注册和基础资源实体。
- 当前工程尚未补齐由具体 IDE 版本决定的 `hvigorfile.ts`、`oh-package-lock.json5`、`.hvigor/`、`local.properties` 等文件。
- 这些文件更适合在真实 DevEco Studio 环境中由 IDE 自动生成，以避免人工伪造后与本地工具链版本不一致。

## 当前已完成的页面链路

1. `EntryAbility` 启动后加载 `FoodCategoryListPage`。
2. `FoodCategoryListPage` 通过官方 Router 跳转到 `FoodDetailPage`。
3. `FoodDetailPage` 通过 `getParams()` 读取 `foodId`，再映射回 `FoodData`。
4. `FoodDetailPage` 支持通过 `back()` 返回上一页。

## 后续建议

1. 在真实 DevEco Studio 环境中首次导入本目录，让 IDE 自动补齐本地构建文件。
2. 完成第一次同步后，执行最小编译验证。
3. 若 `pages` 注册名、Router 页面名或 SDK 版本字段与本地模板不一致，以 IDE 自动更新结果为准，并把实际差异回写到文档。
