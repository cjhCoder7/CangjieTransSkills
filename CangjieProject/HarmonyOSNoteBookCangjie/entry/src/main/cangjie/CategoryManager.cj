package ohos_app_cangjie_entry

class CategoryItem {
    public var id: String
    public var catType: String
    public var name: String
    public var color: String
    public var sort: Int64

    public init(id: String, catType: String, name: String, color: String, sort: Int64) {
        this.id = id
        this.catType = catType
        this.name = name
        this.color = color
        this.sort = sort
    }
}

class CategoryManager {
    public func list(catType: String): Array<CategoryItem> {
        []
    }

    public func save(category: CategoryItem): FeatureResult {
        featureSuccess("category:${category.id}:saved")
    }

    public func remove(id: String): FeatureResult {
        featureSuccess("category:${id}:removed")
    }
}
