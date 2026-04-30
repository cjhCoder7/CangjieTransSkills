package ohos_app_cangjie_entry

class CategoryBudget {
    public var category: String
    public var limit: Float64
    public var used: Float64

    public init(category: String, limit: Float64, used: Float64) {
        this.category = category
        this.limit = limit
        this.used = used
    }
}

class BudgetManager {
    public func listCategoryBudgets(): Array<CategoryBudget> {
        []
    }

    public func saveCategoryBudget(budget: CategoryBudget): FeatureResult {
        featureSuccess("budget:${budget.category}:saved")
    }
}
