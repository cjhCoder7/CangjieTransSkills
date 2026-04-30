package ohos_app_cangjie_entry

class RecurringBillRule {
    public var id: String
    public var record: BillRecordModel
    public var dayOfMonth: Int64
    public var enabled: Bool

    public init(id: String, record: BillRecordModel, dayOfMonth: Int64, enabled: Bool) {
        this.id = id
        this.record = record
        this.dayOfMonth = dayOfMonth
        this.enabled = enabled
    }
}

class RecurringBillManager {
    public func listRules(): Array<RecurringBillRule> {
        []
    }

    public func saveRule(rule: RecurringBillRule): FeatureResult {
        featureSuccess("recurring:${rule.id}:saved")
    }
}
