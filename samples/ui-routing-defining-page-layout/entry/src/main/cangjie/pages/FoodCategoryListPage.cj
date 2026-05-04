package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*

@Entry
@Component
class FoodCategoryListPage {
    let foodItems = initializeOnStartup()

    @State
    var showList: Bool = false

    @State
    var selectedCategoryLabel: String = "All"

    func toggleButtonLabel(): String {
        if (this.showList) {
            return "切换到网格"
        }
        return "切换到列表"
    }

    func visibleFoods(): ArrayList<FoodData> {
        return filterFoodsByCategory(this.foodItems, this.selectedCategoryLabel)
    }

    func toggleView(): Unit {
        this.showList = !this.showList
    }

    func selectCategory(label: String): Unit {
        this.selectedCategoryLabel = label
    }

    func openFoodDetail(foodItem: FoodData): Unit {
        getUIContext().getRouter().pushUrl(url: "FoodDetailPage", params: foodItem.id)
    }

    func buildHeader(): Unit {
        Row {
            Text("Food Browser")
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .margin(right: 12.vp)
            Button(this.toggleButtonLabel())
                .onClick({evt => this.toggleView()})
        }
        .width(100.percent)
        .padding(top: 16.vp, bottom: 12.vp, left: 16.vp, right: 16.vp)
    }

    func buildCategoryBar(): Unit {
        Scroll {
            Row {
                for (label in categoryLabels()) {
                    Button(label)
                        .margin(right: 8.vp, bottom: 8.vp)
                        .onClick({evt => this.selectCategory(label)})
                }
            }
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 12.vp)
    }

    func buildSummaryBar(): Unit {
        Row {
            Text("当前分类：${this.selectedCategoryLabel}")
                .margin(right: 12.vp)
            Text("条目数：${this.visibleFoods().size}")
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 12.vp)
    }

    func buildFoodListItem(foodItem: FoodData): Unit {
        Row {
            Column {
                Text(foodItem.name)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .margin(bottom: 4.vp)
                Text(foodItem.caloriesLabel())
                    .margin(bottom: 4.vp)
                Text("图片资源：${foodItem.imageRef}")
            }
            .width(65.percent)

            Button("查看详情")
                .onClick({evt => this.openFoodDetail(foodItem)})
        }
        .width(100.percent)
        .padding(top: 12.vp, bottom: 12.vp, left: 16.vp, right: 16.vp)
    }

    func buildFoodList(): Unit {
        Scroll {
            Column {
                for (foodItem in this.visibleFoods()) {
                    this.buildFoodListItem(foodItem)
                }
            }
        }
        .width(100.percent)
        .height(100.percent)
    }

    func buildFoodGridItem(foodItem: FoodData): Unit {
        Column {
            Text(foodItem.name)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin(bottom: 8.vp)
            Text("图片资源：${foodItem.imageRef}")
                .margin(bottom: 8.vp)
            Text(foodItem.compactCaloriesLabel())
                .margin(bottom: 8.vp)
            Button("进入详情")
                .onClick({evt => this.openFoodDetail(foodItem)})
        }
        .width(48.percent)
        .padding(top: 12.vp, bottom: 12.vp, left: 12.vp, right: 12.vp)
    }

    func buildBlankGridItem(): Unit {
        Column {
            Text("")
        }
        .width(48.percent)
    }

    func buildGridRow(rowItems: ArrayList<FoodData>): Unit {
        Row {
            if (rowItems.size > 0) {
                this.buildFoodGridItem(rowItems[0])
            }
            if (rowItems.size > 1) {
                this.buildFoodGridItem(rowItems[1])
            } else {
                this.buildBlankGridItem()
            }
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 8.vp)
    }

    func buildFoodGrid(): Unit {
        Scroll {
            Column {
                for (rowItems in buildGridRows(this.visibleFoods())) {
                    this.buildGridRow(rowItems)
                }
            }
        }
        .width(100.percent)
        .height(100.percent)
    }

    func build() {
        Column {
            this.buildHeader()
            this.buildCategoryBar()
            this.buildSummaryBar()
            if (this.showList) {
                this.buildFoodList()
            } else {
                this.buildFoodGrid()
            }
        }
        .width(100.percent)
        .height(100.percent)
    }
}
