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
