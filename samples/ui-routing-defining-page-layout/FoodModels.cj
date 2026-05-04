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
