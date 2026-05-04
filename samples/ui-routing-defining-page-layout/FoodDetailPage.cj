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
