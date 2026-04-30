package ohos_app_cangjie_entry

class BillQuery {
    public var keyword: Option<String> = Option<String>.None
    public var category: Option<String> = Option<String>.None
    public var startTime: Option<Float64> = Option<Float64>.None
    public var endTime: Option<Float64> = Option<Float64>.None
    public var minAmount: Option<Float64> = Option<Float64>.None
    public var maxAmount: Option<Float64> = Option<Float64>.None
}

class BillRepository {
    public func list(query!: BillQuery = BillQuery()): Array<BillRecordModel> {
        []
    }

    public func save(record: BillRecordModel): FeatureResult {
        featureSuccess("bill:${record.id}:saved")
    }

    public func delete(ids: Array<Int64>): FeatureResult {
        featureSuccess("bill:${ids.size}:deleted")
    }
}
