package ohos_app_cangjie_entry

class BatchOperationManager {
    public func deleteBills(ids: Array<Int64>): FeatureResult {
        featureSuccess("batch:${ids.size}:deleted")
    }

    public func moveCategory(ids: Array<Int64>, category: String): FeatureResult {
        featureSuccess("batch:${ids.size}:moved:${category}")
    }
}
