package ohos_app_cangjie_entry

class BillRecordModel {
    public var id: Int64
    public var billType: String
    public var category: String
    public var title: String
    public var amount: Float64
    public var timestamp: Float64

    public init(id: Int64, billType: String, category: String, title: String, amount: Float64, timestamp: Float64) {
        this.id = id
        this.billType = billType
        this.category = category
        this.title = title
        this.amount = amount
        this.timestamp = timestamp
    }
}

class FeatureResult {
    public var ok: Bool
    public var message: String

    public init(ok: Bool, message: String) {
        this.ok = ok
        this.message = message
    }
}

func featureSuccess(message: String): FeatureResult {
    FeatureResult(true, message)
}

func featureFailure(message: String): FeatureResult {
    FeatureResult(false, message)
}
