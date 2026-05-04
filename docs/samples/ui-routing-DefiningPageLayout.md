# 样本记录：DefiningPageLayoutAndConnection（UI / 路由）
## A. 基本信息

- `Record ID`：sample-ui-routing-defining-page-layout
- `创建日期`：2026-03-26
- `最近更新日期`：2026-03-26
- `作者 / Agent`：Codex CLI
- `样本类别`：UI / 路由
- `当前状态`：部分完成
- `优先级`：P0
- `对应阶段`：Phase 2
- `是否为第一批核心样本`：是

## B. 样本选择原因

### B.1 样本来源

- `来源仓库`：OpenHarmony applications_app_samples
- `来源链接`：https://github.com/openharmony/applications_app_samples
- `访问日期`：2026-03-26
- `分支 / commit / tag`：master（本次通过 raw GitHub 内容访问）
- `本地路径`：当前仓库未完整镜像源项目，本次通过原始源码链接提取关键文件
- `License / 使用限制`：仓库与文件头均指向 Apache License 2.0

### B.2 为什么选择这个样本

选择 `DefiningPageLayoutAndConnection` 作为第一批样本，是因为它同时覆盖了第一阶段最需要验证的两类能力：

1. **UI 布局能力**：
   - 它包含列表模式与网格模式两种典型布局；
   - 同一份数据既可以按列表渲染，也可以按分类后的网格渲染；
   - 它天然适合作为 `ui-list-grid-layout` Skill 的验证对象。

2. **页面连接能力**：
   - 它包含从列表 / 网格条目进入详情页的跳转；
   - 详情页会读取页面参数并支持返回；
   - 它天然适合作为 `page-routing-and-param-passing` Skill 的验证对象。

此外，这个样本还有三个很重要的优点：

- 功能边界清晰，没有复杂网络依赖；
- 核心页面只有分类页和详情页，结构足够小；
- 数据模型固定，便于把“翻译问题”和“业务问题”解耦。

### B.3 本样本要验证的 Skill

- `Skill 列表`：
  - `ui-list-grid-layout`
  - `page-routing-and-param-passing`
- `主验证 Skill`：`ui-list-grid-layout`
- `次验证 Skill`：`page-routing-and-param-passing`
- `希望从样本中反推形成的新 Skill`：
  - `arkts-to-cangjie-state-binding`
  - `resource-rendering-placeholder-strategy`

## C. 样本概述

### C.1 原始样本功能描述

该 ArkTS 样本的原始目标是构建一个“食物分类与详情查看”应用：

- 首页既支持列表模式，也支持按分类展示的网格模式；
- 用户可以在不同分类间切换，查看对应食物卡片；
- 用户点击列表项或网格项后，可以进入详情页；
- 详情页会展示食物名称、图片以及营养信息；
- 用户可以从详情页点击返回，回到上一页。

### C.2 工程结构概览

- `入口模块`：`pages/FoodCategoryList.ets`（作为 `@Entry` 页面）
- `核心页面`：
  - `pages/FoodCategoryList.ets`
  - `pages/FoodDetail.ets`
- `核心组件`：
  - `FoodListItem`
  - `FoodGridItem`
  - `FoodList`
  - `FoodGrid`
  - `FoodCategory`
  - `PageTitle`
  - `FoodImageDisplay`
  - `ContentTable`
- `核心状态 / 数据源`：
  - `showList`
  - `foodItems`
  - `FoodData` / `Category`
- `相关配置文件`：样本 README 未在当前分析中展开配置文件细节
- `相关权限声明`：README 标明不涉及权限
- `相关测试文件`：样本 README 未展示专门测试文件

### C.3 关键路径说明

1. 启动分类页 -> 默认显示网格 / 分类界面 -> 点击切换按钮 -> 切换到列表模式
2. 在分类页中选择分类 -> 网格数据重新过滤并渲染
3. 点击列表项或网格项 -> 跳转详情页 -> 详情页读取 `foodId` 参数 -> 点击返回回到上一页

## D. ArkTS 源代码片段

### D.1 源代码片段清单

#### 片段 1

- `片段名称`：FoodData.ets
- `文件路径`：`entry/src/main/ets/model/FoodData.ets`
- `起始行`：1
- `结束行`：完整文件
- `用途`：定义食物分类枚举与食物数据模型
- `为什么关键`：它是当前样本翻译中不可省略的核心逻辑

```arkts
/*
 * Copyright (c) 2021-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export enum Category  {
  Fruit,
  Vegetable,
  Nut,
  Seafood,
  Dessert
}

let NextId = 0;
export class FoodData {
  id: string;
  name: string;
  image: Resource
  category: Category;
  calories: number;
  protein: number;
  fat: number;
  carbohydrates: number;
  vitaminC: number;

  constructor(name: string, image: Resource, category: Category, calories: number, protein: number, fat: number, carbohydrates: number, vitaminC: number) {
    this.id = `${ NextId++ }`;
    this.name = name;
    this.image = image;
    this.category = category;
    this.calories = calories;
    this.protein = protein;
    this.fat = fat;
    this.carbohydrates = carbohydrates;
    this.vitaminC = vitaminC;
  }
}
```

#### 片段 2

- `片段名称`：FoodDataModels.ets
- `文件路径`：`entry/src/main/ets/model/FoodDataModels.ets`
- `起始行`：1
- `结束行`：完整文件
- `用途`：初始化样本数据
- `为什么关键`：它是当前样本翻译中不可省略的核心逻辑

```arkts
/*
 * Copyright (c) 2021-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { FoodData, Category } from './FoodData'

export interface FoodCompositionType {
  name: string,
  image: Resource,
  category: Category,
  calories: number,
  protein: number,
  fat: number,
  carbohydrates: number,
  vitaminC: number
}

const FoodComposition: FoodCompositionType[] = [
  { 'name': 'Tomato', 'image': $r('app.media.Tomato'), 'category': Category.Vegetable, 'calories': 17, 'protein': 0.9, 'fat': 0.2, 'carbohydrates': 3.9, 'vitaminC': 17.8 },
  { 'name': 'Walnut', 'image': $r('app.media.Walnut'), 'category': Category.Nut, 'calories': 654 , 'protein': 15, 'fat': 65, 'carbohydrates': 14, 'vitaminC': 1.3 },
  { 'name': 'Cucumber', 'image': $r('app.media.Cucumber'), 'category': Category.Vegetable, 'calories': 30, 'protein': 3, 'fat': 0, 'carbohydrates': 1.9, 'vitaminC': 2.1 },
  { 'name': 'Blueberry', 'image': $r('app.media.Blueberry'), 'category': Category.Fruit, 'calories': 57, 'protein': 0.7, 'fat': 0.3, 'carbohydrates': 14, 'vitaminC': 9.7 },
  { 'name': 'Crab', 'image': $r('app.media.Crab'), 'category': Category.Seafood, 'calories': 97, 'protein': 19, 'fat': 1.5, 'carbohydrates': 0, 'vitaminC': 7.6 },
  { 'name': 'IceCream', 'image': $r('app.media.IceCream'), 'category': Category.Dessert, 'calories': 207, 'protein': 3.5, 'fat': 11, 'carbohydrates': 24, 'vitaminC': 0.6 },
  { 'name': 'Onion', 'image': $r('app.media.Onion'), 'category': Category.Vegetable, 'calories': 39, 'protein': 1.1, 'fat': 0.1, 'carbohydrates': 9, 'vitaminC': 7.4 },
  { 'name': 'Mushroom', 'image': $r('app.media.Mushroom'), 'category': Category.Vegetable, 'calories': 22, 'protein': 3.1, 'fat': 0.3, 'carbohydrates': 3.3, 'vitaminC': 2.1 },
  { 'name': 'Kiwi', 'image': $r('app.media.Kiwi'), 'category': Category.Fruit, 'calories': 60 , 'protein': 1.1, 'fat': 0.5, 'carbohydrates': 15, 'vitaminC': 20.5 },
  { 'name': 'Pitaya', 'image': $r('app.media.Pitaya'), 'category': Category.Fruit, 'calories': 60, 'protein': 1.2, 'fat': 0, 'carbohydrates': 10, 'vitaminC': 60.9 },
  { 'name': 'Avocado', 'image': $r('app.media.Avocado'), 'category': Category.Fruit, 'calories': 160, 'protein': 2, 'fat': 15, 'carbohydrates': 9, 'vitaminC': 10 },
  { 'name': 'Strawberry', 'image': $r('app.media.Strawberry'), 'category': Category.Fruit, 'calories': 32, 'protein': 0.7, 'fat': 0.3, 'carbohydrates': 8, 'vitaminC': 58.8 }
]

export function initializeOnStartup(): Array<FoodData> {
  let FoodDataArray: Array<FoodData> = []
  FoodComposition.forEach(item => {
    FoodDataArray.push(new FoodData(item.name, item.image, item.category, item.calories, item.protein, item.fat, item.carbohydrates, item.vitaminC));
  })
  return FoodDataArray;
}
```

#### 片段 3

- `片段名称`：FoodCategoryList.ets
- `文件路径`：`entry/src/main/ets/pages/FoodCategoryList.ets`
- `起始行`：1
- `结束行`：完整文件
- `用途`：实现列表 / 网格布局、分类过滤、详情页跳转
- `为什么关键`：它是当前样本翻译中不可省略的核心逻辑

```arkts
/*
 * Copyright (c) 2021-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import router from '@ohos.router';
import { Category, FoodData } from '../model/FoodData';
import { initializeOnStartup } from '../model/FoodDataModels';

class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): T | undefined {
    return undefined;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdded(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChanged(index);
    })
  }
}

class MyDataSource extends BasicDataSource<FoodData> {
  public dataArray: FoodData[] = [];

  constructor(ele: FoodData[]) {
    super()
    for (let index = 0;index < ele.length; index++) {
      this.dataArray.push(ele[index])
    }
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): FoodData {
    return this.dataArray[index];
  }

  public addData(index: number, data: FoodData): void {
    this.dataArray.splice(index, 0)
    this.notifyDataAdd(index);
  }
}

@Component
struct FoodListItem {
  @Prop foodItem: FoodData;

  build() {
    Navigator({ target: 'pages/FoodDetail' }) {
      Row() {
        Row() {
          Image(this.foodItem.image)
            .objectFit(ImageFit.Contain)
            .autoResize(false)
            .height(40)
            .width(40)
        }
        .backgroundColor('#FFf1f3f5')
        .margin({ right: 16 })

        Text(this.foodItem.name)
          .fontSize(14)
          .flexGrow(1)
        Blank()
        Text(this.foodItem.calories + ' kcal')
          .fontSize(14)
      }
      .alignItems(VerticalAlign.Center)
      .height(64)
      .width('100%')
    }
    .width('100%')
    .params({ foodId: this.foodItem })
    .padding({ right: 24, left: 24 })
  }
}


@Component
struct FoodList {
  @Prop foodItems: FoodData[];

  build() {
    Column() {
      Row() {
        Text('Food List')
          .fontSize(20)
          .margin({ left: 20 })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .height('7%')
      .width('100%')
      .backgroundColor('#FFf1f3f5')

      List() {
        LazyForEach(new MyDataSource(this.foodItems), (item: FoodData, index) => {
          ListItem() {
            FoodListItem({ foodItem: item })
          }
          .id('foodListItem' + (index + 1))
        }, (item: FoodData) => item.id.toString())
      }
      .width('100%')
      .height('93%')
    }
    .width('100%')
  }
}

@Component
struct FoodGridItem {
  @Prop foodItem: FoodData;

  build() {
    Column() {
      Row() {
        Image(this.foodItem.image)
          .objectFit(ImageFit.Contain)
          .height(152)
          .width('100%')
      }.backgroundColor('#FFf1f3f5')

      Row() {
        Text(this.foodItem.name)
          .fontSize(14)
          .flexGrow(1)
          .padding({ left: 8 })
        Text(this.foodItem.calories + 'kcal')
          .fontSize(14)
          .margin({ right: 6 })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .height(32)
      .width('100%')
      .backgroundColor('#FFe5e5e5')
    }
    .height(184)
    .width('100%')
    .onClick(() => {
      router.pushUrl({ url: 'pages/FoodDetail', params: { foodId: this.foodItem } });
    })
  }
}

@Component
struct FoodGrid {
  @Prop foodItems: FoodData[];
  @State gridRowTemplate: string = '';
  @State heightValue: number = 0;

  aboutToAppear() {
    let rows = Math.round(this.foodItems.length / 2);
    this.gridRowTemplate = '1fr '.repeat(rows);
    this.heightValue = rows * 192 - 8;
  }

  build() {
    Scroll() {
      Grid() {
        LazyForEach(new MyDataSource(this.foodItems), (item: FoodData, index) => {
          GridItem() {
            FoodGridItem({ foodItem: item })
          }
          .id('foodGridItem' + (index + 1))
        }, (item: FoodData) => item.id.toString())
      }
      .rowsTemplate(this.gridRowTemplate)
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .height(this.heightValue)
    }
    .scrollBar(BarState.Off)
    .padding({ left: 16, right: 16 })
    .height('100%')
    .align(Alignment.Top)
  }
}

@Component
struct FoodCategory {
  @Prop foodItems: FoodData[];

  build() {
    Tabs() {
      TabContent() {
        FoodGrid({ foodItems: this.foodItems })
      }.tabBar('All')

      TabContent() {
        FoodGrid({ foodItems: this.foodItems.filter(item => (item.category === Category.Vegetable)) })
      }.tabBar('Vegetable')

      TabContent() {
        FoodGrid({ foodItems: this.foodItems.filter(item => (item.category === Category.Fruit)) })
      }.tabBar('Fruit')

      TabContent() {
        FoodGrid({ foodItems: this.foodItems.filter(item => (item.category === Category.Nut)) })
      }.tabBar('Nut')

      TabContent() {
        FoodGrid({ foodItems: this.foodItems.filter(item => (item.category === Category.Seafood)) })
      }.tabBar('Seafood')

      TabContent() {
        FoodGrid({ foodItems: this.foodItems.filter(item => (item.category === Category.Dessert)) })
      }.tabBar('Dessert')
    }
    .width('100%')
    .barWidth('80%')
    .barHeight(70)
    .barMode(BarMode.Scrollable)
  }
}

@Entry
@Component
struct FoodCategoryList {
  private foodItems: FoodData[] = initializeOnStartup();
  @State private showList: boolean = false;

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        if (this.showList) {
          FoodList({ foodItems: this.foodItems })
        } else {
          FoodCategory({ foodItems: this.foodItems })
        }
        Image($r('app.media.Switch'))
          .height(40)
          .width(24)
          .objectFit(ImageFit.Contain)
          .id('switch')
          .margin({ top: 15, right: 10 })
          .onClick(() => {
            this.showList = !this.showList
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}
```

#### 片段 4

- `片段名称`：FoodDetail.ets
- `文件路径`：`entry/src/main/ets/pages/FoodDetail.ets`
- `起始行`：1
- `结束行`：完整文件
- `用途`：实现详情页显示与返回逻辑
- `为什么关键`：它是当前样本翻译中不可省略的核心逻辑

```arkts
/*
 * Copyright (c) 2021-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import router from '@ohos.router';
import { FoodData } from '../model/FoodData';

@Component
struct PageTitle {
  build() {
    Row() {
      Image($r('app.media.Back'))
        .width(21.8)
        .height(19.6)
        .id('back')
      Text('Food Detail')
        .fontSize(21.8)
        .margin({ left: 17.4 })
    }
    .alignItems(VerticalAlign.Top)
    .height(61)
    .backgroundColor('#FFedf2f5')
    .padding({ top: 13, bottom: 15, left: 28.3 })
    .onClick(() => {
      router.back()
    })
  }
}

@Component
struct FoodImageDisplay {
  @Prop foodItem: FoodData;

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.foodItem.image)
        .objectFit(ImageFit.Contain)
      Text(this.foodItem.name)
        .fontSize(26)
        .fontWeight(500)
        .margin({ left: 26, bottom: 17.4 })
    }
    .backgroundColor('#FFedf2f5')
    .height(357)
  }
}

@Component
struct ContentTable {
  @Prop foodItem: FoodData;

  @Builder IngredientItem(title: string, name: string, value: string) {
    Row() {
      Text(title)
        .fontSize(17.4)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
      Row() {
        Text(name)
          .fontSize(17.4)
          .flexGrow(1)
        Text(value)
          .fontSize(17.4)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .layoutWeight(2)
    }
  }

  build() {
    Column() {
      this.IngredientItem('Calories', 'Calories', this.foodItem.calories + 'kcal')
      this.IngredientItem('Nutrition', 'Protein', this.foodItem.protein + 'g')
      this.IngredientItem(' ', 'Fat', this.foodItem.fat + 'g')
      this.IngredientItem(' ', 'Carbohydrates', this.foodItem.carbohydrates + 'g')
      this.IngredientItem(' ', 'VitaminC', this.foodItem.vitaminC + 'mg')
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 20, right: 20, left: 20 })
    .height(250)
  }
}

interface RouteParamsType {
  foodId: FoodData
}

@Entry
@Component
struct FoodDetail {
  @State foodItem: FoodData | undefined = undefined;

  aboutToAppear() {
    this.foodItem = (this.getUIContext().getRouter().getParams() as RouteParamsType).foodId;
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        FoodImageDisplay({ foodItem: this.foodItem })
        PageTitle()
      }

      ContentTable({ foodItem: this.foodItem })
    }
    .alignItems(HorizontalAlign.Center)
  }
}
```

### D.2 ArkTS 语义摘要

从语义上看，这个样本并不复杂，但包含了几个非常关键的模式：

1. **同一数据源的多布局投影**：`foodItems` 同时被列表模式和网格模式使用。
2. **状态驱动布局切换**：`showList` 控制页面显示列表还是网格。
3. **状态驱动分类过滤**：`Tabs` 的本质是“当前选中分类 + 过滤数据源 + 重新渲染”。
4. **页面级参数传递**：列表项和网格项都把 `foodId` 作为参数传给详情页。
5. **返回行为**：详情页点击返回时调用 `router.back()`。

## E. 目标语言预期（Cangjie）

### E.1 目标行为预期

仓颉版本希望保留以下行为：

- 首页默认是网格模式；
- 用户可切换到列表模式；
- 用户可切换分类，当前可见数据随之变化；
- 用户点击任一食物条目，进入详情页；
- 详情页正确展示对应食物信息；
- 用户点击返回后回到首页。

本阶段允许的保守降级有三项：

1. 把 ArkTS 的 `Tabs` 先降级成“分类按钮栏 + 状态机”；
2. 把未确认的框架级路由 API 抽象成 `PageRouter` 适配层；
3. 把图片渲染先降级为“图片资源标识展示”，优先验证布局、状态和路由。

### E.2 目标代码结构预期

- `目标模块划分`：
  - 数据模型：`FoodModels.cj`
  - 路由适配：`FoodNavigator.cj`
  - 分类页：`FoodCategoryListPage.cj`
  - 详情页：`FoodDetailPage.cj`
  - 单测：`UiRoutingTests.cj`
- `目标页面 / 组件划分`：分类页负责列表 / 网格切换与分类切换；详情页负责读取当前路由参数并展示内容
- `目标状态管理方式`：使用 `@State` 管理 `showList`、`selectedCategoryLabel` 与 `foodItem`
- `目标存储方式`：本样本不涉及持久化
- `目标日志策略`：本样本第一版不加入日志组件，后续通过轨迹和单测反馈回写
- `目标测试切入点`：视图模式切换、分类过滤结果、路由压栈、详情页读参、返回退栈

### E.3 目标代码草案

#### `samples/ui-routing-defining-page-layout/FoodModels.cj`

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
    let protein: Float64
    let fat: Float64
    let carbohydrates: Float64
    let vitaminC: Float64

    public init(
        id: String,
        name: String,
        imageRef: String,
        category: Category,
        calories: Int64,
        protein: Float64,
        fat: Float64,
        carbohydrates: Float64,
        vitaminC: Float64
    ) {
        this.id = id
        this.name = name
        this.imageRef = imageRef
        this.category = category
        this.calories = calories
        this.protein = protein
        this.fat = fat
        this.carbohydrates = carbohydrates
        this.vitaminC = vitaminC
    }

    public func caloriesLabel(): String {
        "${calories} kcal"
    }

    public func compactCaloriesLabel(): String {
        "${calories}kcal"
    }
}

func emptyFoodData(): FoodData {
    FoodData(
        id: "-1",
        name: "Unknown",
        imageRef: "app.media.Placeholder",
        category: Category.Fruit,
        calories: 0,
        protein: 0.0,
        fat: 0.0,
        carbohydrates: 0.0,
        vitaminC: 0.0
    )
}

func initializeOnStartup(): ArrayList<FoodData> {
    let foods = ArrayList<FoodData>()
    foods.append(FoodData("0", "Tomato", "app.media.Tomato", Category.Vegetable, 17, 0.9, 0.2, 3.9, 17.8))
    foods.append(FoodData("1", "Walnut", "app.media.Walnut", Category.Nut, 654, 15.0, 65.0, 14.0, 1.3))
    foods.append(FoodData("2", "Cucumber", "app.media.Cucumber", Category.Vegetable, 30, 3.0, 0.0, 1.9, 2.1))
    foods.append(FoodData("3", "Blueberry", "app.media.Blueberry", Category.Fruit, 57, 0.7, 0.3, 14.0, 9.7))
    foods.append(FoodData("4", "Crab", "app.media.Crab", Category.Seafood, 97, 19.0, 1.5, 0.0, 7.6))
    foods.append(FoodData("5", "IceCream", "app.media.IceCream", Category.Dessert, 207, 3.5, 11.0, 24.0, 0.6))
    foods.append(FoodData("6", "Onion", "app.media.Onion", Category.Vegetable, 39, 1.1, 0.1, 9.0, 7.4))
    foods.append(FoodData("7", "Mushroom", "app.media.Mushroom", Category.Vegetable, 22, 3.1, 0.3, 3.3, 2.1))
    foods.append(FoodData("8", "Kiwi", "app.media.Kiwi", Category.Fruit, 60, 1.1, 0.5, 15.0, 20.5))
    foods.append(FoodData("9", "Pitaya", "app.media.Pitaya", Category.Fruit, 60, 1.2, 0.0, 10.0, 60.9))
    foods.append(FoodData("10", "Avocado", "app.media.Avocado", Category.Fruit, 160, 2.0, 15.0, 9.0, 10.0))
    foods.append(FoodData("11", "Strawberry", "app.media.Strawberry", Category.Fruit, 32, 0.7, 0.3, 8.0, 58.8))
    foods
}

func categoryTabLabels(): ArrayList<String> {
    ArrayList<String>([
        "All",
        "Vegetable",
        "Fruit",
        "Nut",
        "Seafood",
        "Dessert"
    ])
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
```

#### `samples/ui-routing-defining-page-layout/FoodNavigator.cj`

```cangjie
import std.collection.*

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
    func historySize(): Int64
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

    public func historySize(): Int64 {
        history.size
    }
}

class SpyPageRouter <: PageRouter {
    private let history = ArrayList<RouteRequest>()
    private let pushedPages = ArrayList<String>()
    private var currentIndex: Int64 = 0

    public init() {
        history.append(makeHomeRoute())
    }

    public func push(request: RouteRequest): Unit {
        history.append(request)
        pushedPages.append(request.pageName)
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

    public func historySize(): Int64 {
        history.size
    }

    public func lastPushedPage(): String {
        if (pushedPages.size == 0) {
            ""
        } else {
            pushedPages[pushedPages.size - 1]
        }
    }
}
```

#### `samples/ui-routing-defining-page-layout/FoodCategoryListPage.cj`

```cangjie
import std.collection.*

class FoodPoster {
    let foodItem: FoodData

    public init(foodItem: FoodData) {
        this.foodItem = foodItem
    }

    public func build(): Unit {
        Column {
            Text("图片资源")
                .margin(bottom: 4.vp)
            Text(foodItem.imageRef)
        }
        .width(100.percent)
        .padding(top: 12.vp, bottom: 12.vp, left: 12.vp, right: 12.vp)
    }
}

class FoodCategoryListPage {
    private let router: PageRouter
    private let foodItems: ArrayList<FoodData>
    @State var showList: Bool = false
    @State var selectedCategoryLabel: String = "All"

    public init(router: PageRouter) {
        this.router = router
        this.foodItems = initializeOnStartup()
    }

    public func toggleView(): Unit {
        showList = !showList
    }

    public func currentViewMode(): String {
        if (showList) {
            "list"
        } else {
            "grid"
        }
    }

    public func selectedCategory(): String {
        selectedCategoryLabel
    }

    public func selectCategory(label: String): Unit {
        selectedCategoryLabel = label
    }

    public func tabLabels(): ArrayList<String> {
        categoryTabLabels()
    }

    public func visibleFoods(label: String): ArrayList<FoodData> {
        if (label == "All") {
            foodItems
        } else if (label == "Vegetable") {
            filterFoodsByCategory(foodItems, Category.Vegetable)
        } else if (label == "Fruit") {
            filterFoodsByCategory(foodItems, Category.Fruit)
        } else if (label == "Nut") {
            filterFoodsByCategory(foodItems, Category.Nut)
        } else if (label == "Seafood") {
            filterFoodsByCategory(foodItems, Category.Seafood)
        } else if (label == "Dessert") {
            filterFoodsByCategory(foodItems, Category.Dessert)
        } else {
            foodItems
        }
    }

    public func visibleFoodsForCurrentCategory(): ArrayList<FoodData> {
        visibleFoods(selectedCategoryLabel)
    }

    public func gridRowCount(): Int64 {
        buildGridRows(visibleFoodsForCurrentCategory()).size
    }

    public func openFoodDetail(foodItem: FoodData): Unit {
        router.push(makeFoodDetailRoute(foodItem))
    }

    private func buildHeader(): Unit {
        Row {
            Text("Food Browser")
                .margin(right: 12.vp)
            Button("切换视图")
                .onClick { _ =>
                    toggleView()
                }
        }
        .width(100.percent)
        .padding(top: 16.vp, bottom: 16.vp, left: 16.vp, right: 16.vp)
    }

    private func buildCategoryButton(label: String): Unit {
        Button(label)
            .margin(right: 8.vp, bottom: 8.vp)
            .onClick { _ =>
                selectCategory(label)
            }
    }

    private func buildCategoryBar(): Unit {
        Scroll {
            Row {
                for (label in tabLabels()) {
                    buildCategoryButton(label)
                }
            }
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 12.vp)
    }

    private func buildFoodListItem(foodItem: FoodData): Unit {
        Row {
            Column {
                Text(foodItem.name)
                    .margin(bottom: 4.vp)
                Text(foodItem.caloriesLabel())
            }
            .width(60.percent)

            Button("查看详情")
                .onClick { _ =>
                    openFoodDetail(foodItem)
                }
        }
        .width(100.percent)
        .padding(top: 12.vp, bottom: 12.vp, left: 16.vp, right: 16.vp)
    }

    private func buildFoodList(): Unit {
        Column {
            Row {
                Text("Food List")
            }
            .width(100.percent)
            .padding(left: 16.vp, right: 16.vp, bottom: 12.vp)

            Scroll {
                Column {
                    for (food in foodItems) {
                        buildFoodListItem(food)
                    }
                }
            }
            .width(100.percent)
        }
        .width(100.percent)
    }

    private func buildFoodGridItem(foodItem: FoodData): Unit {
        Column {
            FoodPoster(foodItem).build()
            Text(foodItem.name)
                .margin(top: 8.vp, bottom: 4.vp)
            Text(foodItem.compactCaloriesLabel())
                .margin(bottom: 8.vp)
            Button("进入详情")
                .onClick { _ =>
                    openFoodDetail(foodItem)
                }
        }
        .width(48.percent)
        .padding(top: 8.vp, bottom: 8.vp, left: 8.vp, right: 8.vp)
    }

    private func buildBlankGridItem(): Unit {
        Column {
            Text("")
        }
        .width(48.percent)
    }

    private func buildGridRow(rowItems: ArrayList<FoodData>): Unit {
        Row {
            if (rowItems.size > 0) {
                buildFoodGridItem(rowItems[0])
            }
            if (rowItems.size > 1) {
                buildFoodGridItem(rowItems[1])
            } else {
                buildBlankGridItem()
            }
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 8.vp)
    }

    private func buildFoodGrid(): Unit {
        Column {
            buildCategoryBar()
            Scroll {
                Column {
                    for (rowItems in buildGridRows(visibleFoodsForCurrentCategory())) {
                        buildGridRow(rowItems)
                    }
                }
            }
            .width(100.percent)
        }
        .width(100.percent)
    }

    public func build(): Unit {
        Column {
            buildHeader()
            if (showList) {
                buildFoodList()
            } else {
                buildFoodGrid()
            }
        }
        .width(100.percent)
        .height(100.percent)
    }
}
```

#### `samples/ui-routing-defining-page-layout/FoodDetailPage.cj`

```cangjie
import std.collection.*

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

    public func currentFoodName(): String {
        foodItem.name
    }

    public func currentNutritionLines(): ArrayList<String> {
        ArrayList<String>([
            "Calories: ${foodItem.calories}kcal",
            "Protein: ${foodItem.protein}g",
            "Fat: ${foodItem.fat}g",
            "Carbohydrates: ${foodItem.carbohydrates}g",
            "VitaminC: ${foodItem.vitaminC}mg"
        ])
    }

    public func tapBack(): Unit {
        router.back()
    }

    private func buildHeader(): Unit {
        Row {
            Button("返回")
                .margin(right: 12.vp)
                .onClick { _ =>
                    tapBack()
                }
            Text("Food Detail")
        }
        .width(100.percent)
        .padding(top: 16.vp, bottom: 16.vp, left: 16.vp, right: 16.vp)
    }

    private func buildFoodSummary(): Unit {
        Column {
            Text(foodItem.name)
                .margin(bottom: 8.vp)
            Text("图片资源: ${foodItem.imageRef}")
        }
        .width(100.percent)
        .padding(top: 16.vp, bottom: 16.vp, left: 16.vp, right: 16.vp)
    }

    private func buildNutritionTable(): Unit {
        Column {
            for (line in currentNutritionLines()) {
                Text(line)
                    .margin(bottom: 8.vp)
            }
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 16.vp)
    }

    public func build(): Unit {
        Column {
            buildHeader()
            buildFoodSummary()
            buildNutritionTable()
        }
        .width(100.percent)
        .height(100.percent)
    }
}
```

#### `samples/ui-routing-defining-page-layout/UiRoutingTests.cj`

```cangjie
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class UiRoutingPageTests {
    @TestCase
    public func defaultModeIsGrid(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        assertEqual("默认应进入网格视图", "", "grid", page.currentViewMode())
        assertEqual("默认分类应为 All", "", "All", page.selectedCategory())
    }

    @TestCase
    public func toggleViewChangesListMode(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.toggleView()
        assertEqual("切换后应进入列表视图", "", "list", page.currentViewMode())
    }

    @TestCase
    public func vegetableFilterReturnsOnlyVegetables(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.selectCategory("Vegetable")
        let vegetables = page.visibleFoodsForCurrentCategory()
        assertEqual("Vegetable 分类条目数量应正确", "", 4, vegetables.size)
        assertEqual("第一项应为 Tomato", "", "Tomato", vegetables[0].name)
        assertEqual("第二项应为 Cucumber", "", "Cucumber", vegetables[1].name)
        assertEqual("第三项应为 Onion", "", "Onion", vegetables[2].name)
        assertEqual("第四项应为 Mushroom", "", "Mushroom", vegetables[3].name)
    }

    @TestCase
    public func gridRowCountShouldMatchTwoColumnLayout(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.selectCategory("All")
        assertEqual("12 个元素在双列网格中应形成 6 行", "", 6, page.gridRowCount())
    }

    @TestCase
    public func openFoodDetailShouldPushRouterRequest(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let firstFood = page.visibleFoods("All")[0]
        page.openFoodDetail(firstFood)
        assertEqual("应跳转到详情页", "", "FoodDetailPage", router.lastPushedPage())
        assertEqual("路由历史应增加到 2", "", 2, router.historySize())
        assertEqual("当前路由中应带有 Tomato", "", "Tomato", router.current().food.name)
    }

    @TestCase
    public func detailPageShouldReadFoodFromRouter(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let targetFood = page.visibleFoods("All")[3]
        page.openFoodDetail(targetFood)
        let detailPage = FoodDetailPage(router: router)
        detailPage.aboutToAppear()
        assertEqual("详情页应加载 Blueberry", "", "Blueberry", detailPage.currentFoodName())
    }

    @TestCase
    public func detailPageBackShouldReturnToHome(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let targetFood = page.visibleFoods("All")[1]
        page.openFoodDetail(targetFood)
        let detailPage = FoodDetailPage(router: router)
        detailPage.aboutToAppear()
        detailPage.tapBack()
        assertEqual("返回后当前页面应为列表页", "", "FoodCategoryListPage", router.current().pageName)
    }
}
```

## F. 转换过程记录

### F.1 转换轮次概览

| 轮次 | 输入片段 | 使用 Skill | 是否检索降级 | 主要变更 | 当前结果 |
|---|---|---|---|---|---|
| Round 1 | `FoodData.ets` + `FoodDataModels.ets` | `ui-list-grid-layout` | 否 | 先落仓颉数据模型与初始化函数 | 数据层完成 |
| Round 2 | `FoodCategoryList.ets` | `ui-list-grid-layout` | 是 | 把 `Tabs` 降级为分类按钮栏，把 `Grid` 降级为双列行布局 | 页面结构完成 |
| Round 3 | `FoodCategoryList.ets` + `FoodDetail.ets` | `page-routing-and-param-passing` | 是 | 用 `PageRouter` 适配 `pushUrl/getParams/back` 语义 | 路由语义完成 |
| Round 4 | 全部仓颉代码 | 两个 Skill | 否 | 增加单测友好的查询方法与路由 Spy | 测试骨架完成 |

### F.2 每轮详细记录

#### Round 1

- `输入范围`：`FoodData.ets`、`FoodDataModels.ets`
- `使用的 Skill`：`ui-list-grid-layout`
- `是否进行了检索降级`：否
- `采用的主要映射规则`：ArkTS `enum` -> 仓颉 `enum`；ArkTS 数组初始化 -> 仓颉 `ArrayList.append`
- `输出变化摘要`：建立了 `FoodModels.cj`
- `当前问题`：图片资源与后续 UI 组件 API 仍待页面级落地时处理
- `是否进入下一轮`：是

#### Round 2

- `输入范围`：`FoodCategoryList.ets`
- `使用的 Skill`：`ui-list-grid-layout`
- `是否进行了检索降级`：是
- `检索来源`：仓颉声明式 UI 白皮书；ArkTS 样本源码
- `检索关键词`：`声明式 UI Column Row Button State`；`DefiningPageLayoutAndConnection List Grid Tabs`
- `采用的主要映射规则`：`showList` -> `@State var showList`；`Tabs` -> `selectedCategoryLabel + buildCategoryBar()`；`Grid` -> `buildGridRows()` + `buildGridRow()`；`LazyForEach` -> `for (item in items)`
- `输出变化摘要`：建立了 `FoodCategoryListPage.cj`
- `当前问题`：未直接使用框架级 `Tabs` / `Grid` API，而是使用保守等价实现
- `是否进入下一轮`：是

#### Round 3

- `输入范围`：`FoodCategoryList.ets`、`FoodDetail.ets`
- `使用的 Skill`：`page-routing-and-param-passing`
- `是否进行了检索降级`：是
- `检索来源`：OpenHarmony router API 文档；ArkTS `FoodDetail.ets`
- `检索关键词`：`pushUrl getParams back params`；`FoodDetail getParams foodId`
- `采用的主要映射规则`：`Navigator / pushUrl` -> `router.push(makeFoodDetailRoute(food))`；`getParams` -> `router.current()`；`back` -> `router.back()`
- `输出变化摘要`：建立了 `FoodNavigator.cj` 与 `FoodDetailPage.cj`
- `当前问题`：当前路由器是适配层，不是直接绑定到正式 HarmonyOS 仓颉 API
- `是否进入下一轮`：是

#### Round 4

- `输入范围`：全部仓颉翻译代码
- `使用的 Skill`：`ui-list-grid-layout`、`page-routing-and-param-passing`
- `是否进行了检索降级`：否
- `采用的主要映射规则`：为页面暴露单测友好的查询方法；引入 `SpyPageRouter` 以便断言 push/back 行为
- `输出变化摘要`：建立了 `UiRoutingTests.cj`
- `当前问题`：由于本地没有 DevEco + 仓颉插件，本轮未实际运行编译和单测
- `是否进入下一轮`：是，进入设备环境或插件环境后需要补验证

## G. 转换难点记录

### G.1 语法映射难点

1. **ArkTS 的 `LazyForEach` 并不应直接机械映射**：本次用 `for (item in items)` 与布局函数组合保留渲染语义。
2. **ArkTS 的 `filter(item => item.category === selectedCategory)` 在第一批样本中不宜直接保留**：当前稳定依赖改为显式 `filterFoodsByCategory`。
3. **ArkTS 的 `@Prop` / `@State` 组件属性模式与仓颉公开 UI 示例存在信息不对称**：本次统一采用“类字段 + 构造函数 + `@State` 状态”的表达。

### G.2 UI / 路由难点

1. **`Tabs` 的直接 API 没有在当前可确认的一手仓颉资料里拿到完整示例**：本次将其降级为 `selectedCategoryLabel` 驱动的按钮栏。
2. **`Grid` 组件的直接仓颉样例未在本轮调研中确认**：本次改为 `buildGridRows()` 把一维数组切成二维行。
3. **图片渲染不是本轮最关键验证点**：图片资源先降级为文本标识展示，不影响布局与路由验证。

### G.3 状态 / 存储 / 网络 / 日志难点

本样本主要是 UI / 路由，不涉及持久化、网络和日志主逻辑。状态上的主要难点是 `showList` 与 `selectedCategoryLabel` 必须成为唯一可信状态源，因此本次统一收敛到 `visibleFoods(label)` 与 `visibleFoodsForCurrentCategory()`。

### G.4 依赖与环境难点

- 当前本地环境中没有可直接验证的 DevEco Studio + 仓颉插件；
- 当前公开仓颉一手资料可确认声明式 UI 基础语法，但未完整确认路由与高级组件 API；
- 因此本轮采取了“保守、可测试、可回写”的翻译策略。

## H. 单测生成策略

### H.1 单测目标

1. **UI 状态**：默认进入网格模式；点击切换后进入列表模式；分类切换后，当前可见数据集发生变化。
2. **布局导出状态**：在 `All` 分类下，12 个元素形成 6 行双列网格；在 `Vegetable` 分类下，只保留 Tomato、Cucumber、Onion、Mushroom 四项。
3. **路由行为**：点击某个条目后，应压入 `FoodDetailPage` 路由；详情页 `aboutToAppear()` 后应能读到正确食物；返回按钮后应回退到 `FoodCategoryListPage`。

### H.2 单测切分

| 用例 ID | 用例名称 | 验证目标 | 输入 | 预期输出 | 优先级 |
|---|---|---|---|---|---|
| TC-01 | 默认模式为网格 | 初始 `showList` 状态 | 新建 `FoodCategoryListPage` | `currentViewMode() == "grid"` | 高 |
| TC-02 | 切换进入列表 | 验证切换按钮逻辑 | 调用 `toggleView()` | `currentViewMode() == "list"` | 高 |
| TC-03 | Vegetable 分类过滤正确 | 验证分类状态与数据过滤 | `selectCategory("Vegetable")` | 仅四个蔬菜条目 | 高 |
| TC-04 | 双列网格行数正确 | 验证布局分行逻辑 | 默认分类 `All` | `gridRowCount() == 6` | 中 |
| TC-05 | 点击条目压栈到详情页 | 验证路由 push 行为 | 调用 `openFoodDetail(firstFood)` | `router.lastPushedPage() == "FoodDetailPage"` | 高 |
| TC-06 | 详情页能正确读参 | 验证 getParams 语义映射 | 先 push，再执行 `aboutToAppear()` | `currentFoodName()` 正确 | 高 |
| TC-07 | 返回按钮回到首页 | 验证 back 行为 | 详情页执行 `tapBack()` | 当前页为 `FoodCategoryListPage` | 高 |

### H.3 单测生成策略说明

1. **Mock 哪些路由对象**：统一 mock 我们的 `PageRouter` 适配层，具体使用 `SpyPageRouter`。
2. **断言哪些 UI 状态**：优先断言页面暴露的“可见状态”，如 `currentViewMode()`、`selectedCategory()`、`visibleFoodsForCurrentCategory()`、`gridRowCount()`、`currentFoodName()`。
3. **为什么这样设计**：当前环境还未接入完整设备运行时，先通过状态与派生数据断言验证布局和路由语义。
4. **暂时不优先测试的内容**：图片资源真实渲染、视觉样式细节、滚动条与边距像素级表现、真实框架级 `Tabs` 和 `Grid` API 行为。

### H.4 单测代码草案

```cangjie
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class UiRoutingPageTests {
    @TestCase
    public func defaultModeIsGrid(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        assertEqual("默认应进入网格视图", "", "grid", page.currentViewMode())
        assertEqual("默认分类应为 All", "", "All", page.selectedCategory())
    }

    @TestCase
    public func toggleViewChangesListMode(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.toggleView()
        assertEqual("切换后应进入列表视图", "", "list", page.currentViewMode())
    }

    @TestCase
    public func vegetableFilterReturnsOnlyVegetables(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.selectCategory("Vegetable")
        let vegetables = page.visibleFoodsForCurrentCategory()
        assertEqual("Vegetable 分类条目数量应正确", "", 4, vegetables.size)
        assertEqual("第一项应为 Tomato", "", "Tomato", vegetables[0].name)
        assertEqual("第二项应为 Cucumber", "", "Cucumber", vegetables[1].name)
        assertEqual("第三项应为 Onion", "", "Onion", vegetables[2].name)
        assertEqual("第四项应为 Mushroom", "", "Mushroom", vegetables[3].name)
    }

    @TestCase
    public func gridRowCountShouldMatchTwoColumnLayout(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        page.selectCategory("All")
        assertEqual("12 个元素在双列网格中应形成 6 行", "", 6, page.gridRowCount())
    }

    @TestCase
    public func openFoodDetailShouldPushRouterRequest(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let firstFood = page.visibleFoods("All")[0]
        page.openFoodDetail(firstFood)
        assertEqual("应跳转到详情页", "", "FoodDetailPage", router.lastPushedPage())
        assertEqual("路由历史应增加到 2", "", 2, router.historySize())
        assertEqual("当前路由中应带有 Tomato", "", "Tomato", router.current().food.name)
    }

    @TestCase
    public func detailPageShouldReadFoodFromRouter(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let targetFood = page.visibleFoods("All")[3]
        page.openFoodDetail(targetFood)
        let detailPage = FoodDetailPage(router: router)
        detailPage.aboutToAppear()
        assertEqual("详情页应加载 Blueberry", "", "Blueberry", detailPage.currentFoodName())
    }

    @TestCase
    public func detailPageBackShouldReturnToHome(): Unit {
        let router = SpyPageRouter()
        let page = FoodCategoryListPage(router: router)
        let targetFood = page.visibleFoods("All")[1]
        page.openFoodDetail(targetFood)
        let detailPage = FoodDetailPage(router: router)
        detailPage.aboutToAppear()
        detailPage.tapBack()
        assertEqual("返回后当前页面应为列表页", "", "FoodCategoryListPage", router.current().pageName)
    }
}
```

## I. 编译与运行验证

### I.1 编译验证

- `构建命令`：当前未执行
- `构建环境`：当前工作空间未安装可用的 DevEco Studio + 仓颉插件环境
- `是否成功`：否（未执行）
- `关键输出`：无
- `关键报错位置`：无
- `报错解释`：本轮属于“源码翻译 + Skill 建设 + 单测设计”阶段，尚未进入设备侧编译验证

### I.2 运行验证

- `运行环境`：当前未执行，原因是当前工作空间未安装可用的 DevEco Studio + 仓颉插件环境
- `验证步骤`：
  1. 在具备仓颉插件的 DevEco 环境中创建或导入最小可编译工程，并将 `samples/ui-routing-defining-page-layout/` 中的仓颉文件接入页面入口
  2. 启动分类页，确认默认进入网格模式，且默认分类标签为 `All`
  3. 点击“切换视图”按钮，确认页面由网格模式切换为列表模式
  4. 在网格模式下点击 `Vegetable` 分类按钮，确认页面仅展示 `Tomato`、`Cucumber`、`Onion`、`Mushroom`
  5. 点击任意食物条目的“进入详情”或“查看详情”按钮，确认当前路由进入 `FoodDetailPage`，且详情页展示对应食物名称与营养信息
  6. 点击详情页“返回”按钮，确认路由回退到 `FoodCategoryListPage`
- `观察结果`：本轮未进行设备侧或模拟器侧实际运行，当前只能根据翻译代码结构、路由适配层设计和单测草案判断其逻辑闭环已经成立，真实界面渲染结果仍需后续在 DevEco 环境验证
- `是否达到目标行为`：部分达到
- `截图 / 日志 / 视频索引`：本轮无设备侧截图、运行日志或录屏产物

## J. 结果评估

### J.1 当前结果评分

- `语义保真度`：84
- `编译可行性`：52
- `运行正确性`：48
- `工程可维护性`：86
- `Skill 使用有效性`：90
- `轨迹与证据完整性`：92
- `总评`：75

### J.2 当前结论

当前判定为：**部分通过，还需要补 1~2 轮修复**。

原因如下：

- 正向部分：已完整保留数据模型、列表 / 网格切换、分类过滤、详情跳转、参数读取和返回语义；已形成真实 Skill、样本记录、执行轨迹和单测草案；已把不确定的框架 API 抽象为适配层。
- 未完成部分：尚未在 DevEco + 仓颉插件环境中做编译与设备运行验证；图片渲染、框架级 `Tabs` / `Grid` 组件仍采用保守等价实现；尚未把当前仓颉翻译接入真实 HarmonyOS 项目骨架。

## K. 回写建议

### K.1 应回写到哪些 Skill

- `Skill ID`：`ui-list-grid-layout`
- `回写内容`：`Tabs` 在第一批样本中可先降级为按钮栏状态机，`Grid` 可先降级为双列行布局
- `原因`：这是当前最稳的可测试实现路径

- `Skill ID`：`page-routing-and-param-passing`
- `回写内容`：路由适配层 `PageRouter` 在当前公开仓颉资料不完整时非常有价值
- `原因`：它显著提升了单测能力和框架替换能力

### K.2 是否应新增 Skill

- `是否需要新增 Skill`：是
- `建议 Skill 名称`：`arkts-to-cangjie-state-binding`
- `原因`：本样本反复暴露“状态是布局与路由两端的共享核心”这一事实，值得独立沉淀

### K.3 是否应调整评测标准

- `是否建议调整`：否
- `建议项`：无
- `原因`：当前评测标准已能很好覆盖本样本阶段判断

## L. 附录

### L.1 相关文件

- `samples/ui-routing-defining-page-layout/FoodModels.cj`
- `samples/ui-routing-defining-page-layout/FoodNavigator.cj`
- `samples/ui-routing-defining-page-layout/FoodCategoryListPage.cj`
- `samples/ui-routing-defining-page-layout/FoodDetailPage.cj`
- `samples/ui-routing-defining-page-layout/UiRoutingTests.cj`
- `skills/ui-list-grid-layout.md`
- `skills/page-routing-and-param-passing.md`

### L.2 相关执行轨迹

- `docs/traces/trace-ui-routing-001.md`

### L.3 相关文档与链接

- `skills/SKILL_SCHEMA_V1.md`
- `docs/requirements-baseline.md`
- `docs/evaluation-criteria.md`
- `docs/reports/2026-03-26-frontier-research-and-skill-strategy.md`
- https://docs.cangjie-lang.cn/docs/0.53.18/white_paper/source_zh_cn/cj-wp-declarative.html
- https://gitee.com/openharmony/docs/raw/master/zh-cn/application-dev/reference/apis-arkui/js-apis-router.md

### L.4 备注

- 本次翻译是第一轮“可测试、可回写、可继续迭代”的仓颉实现，不声称已达到设备侧最终形态。


## M. 工程骨架搭建补充记录

### M.1 本次搭建目标

- 在 `samples/ui-routing-defining-page-layout/` 下补出一套接近标准 OpenHarmony 仓颉应用的最小工程骨架；
- 让后续在具备 DevEco Studio + 仓颉插件环境时，可以直接把样本导入为标准目录结构继续验证；
- 将上一轮偏“翻译样本 / 可测试抽象”的代码，与这一轮偏“工程落地 / 页面实际装配”的代码区分开来；
- 保留首轮样本根目录下的翻译产物，用于差异分析与单测设计；
- 新增 `entry/src/main/cangjie/` 下的正式页面入口代码，用于承接 `EntryAbility`、页面注册和真实 Router。

### M.2 工程目录树

```text
samples/ui-routing-defining-page-layout
├── AppScope
│   └── app.json5
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
├── README.md
└── UiRoutingTests.cj
```

### M.3 配置与装配思路

1. **根级工程采用标准 OpenHarmony 目录职责**
   - `AppScope/app.json5` 放应用级元信息；
   - `entry/src/main/module.json5` 放模块级 Ability 配置与页面注册；
   - `entry/src/main/resources/base/profile/main_pages.json` 放页面路由声明；
   - `entry/src/main/cangjie/` 放可编译的仓颉源码。

2. **页面代码与样本翻译代码分层保留**
   - 根目录下的 `FoodCategoryListPage.cj`、`FoodDetailPage.cj`、`FoodModels.cj`、`FoodNavigator.cj` 继续保留为“样本翻译与测试草案层”；
   - 新建 `entry/src/main/cangjie/` 下的同主题文件，作为“工程装配层”；
   - 这样既不破坏上一轮的样本分析，又能为真实 DevEco 工程准备更标准的入口与资源结构。

3. **首页页面采用官方 `WindowStage.loadContent()` 机制挂载**
   - `EntryAbility.cj` 在 `onWindowStageCreate()` 中调用 `windowStage.loadContent("FoodCategoryListPage")`；
   - 该做法直接对齐仓颉官方 `UIAbility` 使用方式；
   - 首页类名和页面文件名均保持 `FoodCategoryListPage`，降低后续导入时的路径歧义。

4. **路由参数采用官方 Router 的字符串参数机制**
   - 根据仓颉 Router 参考文档，`pushUrl()` 与 `getParams()` 的参数类型当前为 `String`；
   - 因此本轮没有直接传整个对象，而是只传 `foodId`；
   - 详情页再通过 `findFoodById()` 从本地数据集中恢复对应 `FoodData`，减少 JSON 解析依赖和额外第三方库耦合。

5. **`cjpm.toml` 明确采用 `dynamic` 输出**
   - OpenHarmony 仓颉应用模块最终会被编译为 `.so` 参与 HAP 构建；
   - 因此本轮把 `output-type` 设为 `dynamic`；
   - `src-dir` 明确指向 `./src/main/cangjie`，让仓颉源码目录与官方工程结构保持一致。

### M.4 关键配置难点

1. **`main_pages.json` 的页面路径与 `loadContent()` / `pushUrl()` 的页面名并不完全同一层概念**
   - `main_pages.json` 负责注册页面文件路径，路径基于 `src/main/cangjie`；
   - `windowStage.loadContent()` 与 `Router.pushUrl()` 传的是页面名；
   - 因此本轮采取“文件路径放到 `pages/` 子目录，页面名与类名保持一致”的方式，减少注册层和调用层的心智负担。

2. **`app.json5` 的图标与标签属于强约束项**
   - 仓颉 / OpenHarmony 文档明确 `app.json5` 的 `icon` 与 `label` 是应用级必要信息；
   - 因此本轮同步创建了 `string.json` 和最小 `icon.png`，避免只写资源引用却没有实际资源文件。

3. **模块级 `icon` / `label` 在新版工具链下可以省略，但本轮仍选择显式配置**
   - 这样做的目的是在桌面图标、入口 Ability 和模块说明之间建立更完整的一致性；
   - 同时方便后续把该样本直接作为独立演示工程导入。

4. **首轮翻译中的 `PageRouter` 抽象与真实工程 Router 需要并存**
   - 样本分析层的 `PageRouter` 抽象仍然有价值，因为它支撑了可单测的行为推导；
   - 但工程装配层必须改用官方 `getUIContext().getRouter()` 才能真正挂接页面跳转；
   - 因此本轮没有删除旧抽象，而是在正式入口层新增基于官方 Router 的页面实现。

### M.5 本轮新增文件清单

- `samples/ui-routing-defining-page-layout/AppScope/app.json5`
- `samples/ui-routing-defining-page-layout/entry/cjpm.toml`
- `samples/ui-routing-defining-page-layout/entry/src/main/module.json5`
- `samples/ui-routing-defining-page-layout/entry/src/main/resources/base/profile/main_pages.json`
- `samples/ui-routing-defining-page-layout/entry/src/main/resources/base/element/string.json`
- `samples/ui-routing-defining-page-layout/entry/src/main/resources/base/media/icon.png`
- `samples/ui-routing-defining-page-layout/entry/src/main/cangjie/entryability/EntryAbility.cj`
- `samples/ui-routing-defining-page-layout/entry/src/main/cangjie/model/FoodModels.cj`
- `samples/ui-routing-defining-page-layout/entry/src/main/cangjie/pages/FoodCategoryListPage.cj`
- `samples/ui-routing-defining-page-layout/entry/src/main/cangjie/pages/FoodDetailPage.cj`

### M.6 本轮参考依据

- OpenHarmony 仓颉快速入门文档中的工程目录结构与 `WindowStage.loadContent()` 示例；
- OpenHarmony 仓颉 `app.json5` / `module.json5` 配置文档；
- OpenHarmony 仓颉 `Router` 参考文档；
- 仓颉官方 `cjpm` 手册中关于 `package`、`output-type` 与 `src-dir` 的配置说明。


## N. IDE 导入层配置补充记录

### N.1 本轮新增文件

- `samples/ui-routing-defining-page-layout/oh-package.json5`
- `samples/ui-routing-defining-page-layout/build-profile.json5`
- `samples/ui-routing-defining-page-layout/README.md`

### N.2 配置设计思路

1. **工程级 `oh-package.json5` 只保留最小公共依赖**
   - 本轮没有强行写入复杂三方库；
   - 仅保留工程级 `modelVersion`、描述和常见 `@ohos/hypium` 开发依赖；
   - 目的是让 IDE 能识别这是一个标准的 OpenHarmony / HarmonyOS 工程根目录，同时避免引入无效依赖。

2. **工程级 `build-profile.json5` 采用“双 product 位”策略**
   - `default`：保留 HarmonyOS NEXT 常见产品位，便于 DevEco Studio 首次识别；
   - `ohos`：保留 OpenHarmony 目标产品位，便于后续切到 OpenHarmony 设备；
   - 这样做的目的不是提前锁死某个 SDK 版本，而是给 IDE 留出最大自动修复空间。

3. **关键版本字段全部加入注释说明“以 IDE 自动适配为准”**
   - 当前没有真实本地 SDK 版本和签名环境；
   - 如果强行伪造绝对值，很容易在导入时制造二次错误；
   - 因此本轮在 `compatibleSdkVersion`、`targetSdkVersion`、`compileSdkVersion`、`signingConfigs` 等关键位置明确标注：后续以 IDE 的 `Sync Now` / `Update` 自动修复为准。

4. **README 从“样本产物说明”升级为“导入操作手册”**
   - 旧版 README 主要介绍样本翻译代码；
   - 本轮新版 README 增加了项目结构说明、仓颉源码与资源映射关系、导入步骤、Hvigor 同步失败的点击式修复路径；
   - 这样后续开发者拿到目录后即可按手册直接操作。

### N.3 本轮新增风险提示

- `build-profile.json5` 里的产品位与 SDK 版本仍然属于“工程初始化建议值”，不是最终锁定值；
- `signingConfigs` 故意留空，是为了避免在缺少真实证书时写出无效路径；
- `oh-package.json5` 与 `build-profile.json5` 落地后，首次导入仍然需要 IDE 自动生成锁文件、本地 hvigor 辅助目录和本地属性文件。

### N.4 当前阶段结论

- 这个样本现在已经具备：
  1. 页面源码；
  2. 应用级与模块级配置；
  3. 页面注册；
  4. 入口 Ability；
  5. 工程级依赖与构建配置；
  6. 面向 DevEco Studio 的导入说明。
- 因此本样本的“代码与工程基建”阶段可以视为完成。

## 附录：手动验证 Checklist

以下清单用于在拿到 DevEco Studio + 仓颉插件 + 可用 SDK 后，人工验证本样本是否真正达到“代码与工程基建完成”的目标。

### A. 工程导入与同步

- [ ] 通过 `File -> Open` 打开 `samples/ui-routing-defining-page-layout/` 后，IDE 能识别工程根目录。
- [ ] 首次导入后，`AppScope/app.json5`、`build-profile.json5`、`oh-package.json5`、`entry/src/main/module.json5`、`entry/cjpm.toml` 均能被 IDE 正常解析。
- [ ] 若 IDE 弹出 `Sync Now`、`Update`、`Use IDE Recommended Version` 等提示，点击后能完成同步，不出现阻塞性错误。
- [ ] 若 IDE 自动生成 `oh-package-lock.json5`、`.hvigor/`、`hvigor/`、`local.properties` 等本地文件，生成过程无异常中断。
- [ ] 若需要签名，进入 `Signing Configs` 后能成功配置自动签名或本地签名，不再出现签名缺失阻塞。

### B. 首页渲染

- [ ] 运行应用后，`EntryAbility` 能正常启动，并加载 `FoodCategoryListPage`。
- [ ] 首页标题 `Food Browser` 正常显示。
- [ ] 页面首次进入时，默认显示为网格模式。
- [ ] 页面首次进入时，默认分类为 `All`。
- [ ] 默认情况下，页面能展示全部食物条目，且不会白屏或闪退。

### C. 状态切换

- [ ] 点击“切换到列表”或“切换到网格”按钮后，页面能在列表模式和网格模式之间来回切换。
- [ ] 切换到列表模式后，条目以纵向列表形式展示。
- [ ] 切换回网格模式后，条目以双列网格行的形式展示。
- [ ] 多次重复切换视图后，页面状态仍然稳定，不出现错乱或卡死。

### D. 分类过滤

- [ ] 点击 `Vegetable` 分类后，仅显示 `Tomato`、`Cucumber`、`Onion`、`Mushroom`。
- [ ] 点击 `Fruit` 分类后，仅显示水果类条目。
- [ ] 点击 `Nut`、`Seafood`、`Dessert` 分类后，显示结果与数据模型一致。
- [ ] 点击 `All` 分类后，能恢复显示全部食物条目。
- [ ] 分类切换后，页面顶部“当前分类”和“条目数”摘要能同步更新。

### E. 路由跳转与返回

- [ ] 在网格模式下点击任意条目的“进入详情”按钮后，能够跳转到 `FoodDetailPage`。
- [ ] 在列表模式下点击任意条目的“查看详情”按钮后，能够跳转到 `FoodDetailPage`。
- [ ] 详情页顶部标题 `Food Detail` 正常显示。
- [ ] 点击详情页“返回”按钮后，能够回到列表页。
- [ ] 从不同食物条目进入详情页时，均能正确打开对应条目，不会固定停留在同一个详情数据上。

### F. 参数传递正确性

- [ ] 从 `Tomato` 进入详情页时，详情页名称显示为 `Tomato`。
- [ ] 从 `Blueberry` 进入详情页时，详情页名称显示为 `Blueberry`。
- [ ] 详情页展示的分类文案与所选食物一致。
- [ ] 详情页展示的热量和营养信息与 `FoodModels.cj` 中的数据一致。
- [ ] 多次连续点击不同条目进入详情页时，`foodId` 路由参数能正确驱动页面刷新。

### G. 稳定性与日志

- [ ] 应用冷启动进入首页时没有异常日志导致中断。
- [ ] 从首页进入详情页，再返回首页，再进入其他详情页的过程中没有崩溃。
- [ ] 如果查看日志，能够看到 `EntryAbility` 的 `onCreate`、`onWindowStageCreate`、`onForeground` 生命周期输出。
- [ ] 连续进行“分类切换 -> 视图切换 -> 详情跳转 -> 返回”组合操作时，应用保持稳定。

### H. 完成判定

- [ ] 若以上条目全部勾选完成，可判定 UI / 路由样本已经完成“人工验证闭环”。
- [ ] 若存在未通过项，应把失败现象、触发步骤、截图和日志回写到当前样本记录与对应执行轨迹中。
