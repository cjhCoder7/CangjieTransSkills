package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Entry
@Component
class FoodDetailPage {
    let foodItems = initializeOnStartup()

    @State
    var foodItem: FoodData = emptyFoodData()

    func syncFromRoute(): Unit {
        match (getUIContext().getRouter().getParams()) {
            case Some(foodId) => this.foodItem = findFoodById(this.foodItems, foodId)
            case None => this.foodItem = emptyFoodData()
        }
    }

    protected override func aboutToAppear(): Unit {
        this.syncFromRoute()
    }

    protected override func onPageShow(): Unit {
        this.syncFromRoute()
    }

    func buildHeader(): Unit {
        Row {
            Button("返回")
                .margin(right: 12.vp)
                .onClick({evt => getUIContext().getRouter().back()})
            Text("Food Detail")
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
        }
        .width(100.percent)
        .padding(top: 16.vp, bottom: 16.vp, left: 16.vp, right: 16.vp)
    }

    func buildFoodSummary(): Unit {
        Column {
            Text(this.foodItem.name)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .margin(bottom: 8.vp)
            Text("图片资源：${this.foodItem.imageRef}")
                .margin(bottom: 8.vp)
            Text("分类：${categoryLabel(this.foodItem.category)}")
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 16.vp)
    }

    func buildNutritionTable(): Unit {
        Column {
            for (line in this.foodItem.nutritionLines()) {
                Text(line)
                    .margin(bottom: 8.vp)
            }
        }
        .width(100.percent)
        .padding(left: 16.vp, right: 16.vp, bottom: 24.vp)
    }

    func build() {
        Scroll {
            Column {
                this.buildHeader()
                this.buildFoodSummary()
                this.buildNutritionTable()
            }
            .width(100.percent)
        }
        .width(100.percent)
        .height(100.percent)
    }
}
